// SPDX-License-Identifier: GPL-3.0

// 




pragma solidity 0.8.9;




contract NounSettlement {
  address payable public fomoExecutor;
  address payable public immutable nounsDaoTreasury;
  address public immutable fomoMultisig;
  INounsAuctionHouse public immutable auctionHouse;

  uint256 public maxPriorityFee = 40 * 10**9; // Prevents malicious actor burning all the ETH on gas
  uint256 private immutable OVERHEAD_GAS = 21000; // Handles gas outside gasleft checks, rounded up from ~20,254 in testing


  constructor(address _fomoExecutor, address _nounsDaoTreasury, address _nounsAuctionHouseAddress, address _fomoMultisig) {
    fomoExecutor = payable(_fomoExecutor);
    nounsDaoTreasury = payable(_nounsDaoTreasury);
    fomoMultisig = _fomoMultisig;
    auctionHouse = INounsAuctionHouse(_nounsAuctionHouseAddress);
  }


  /**
    Events for key actions or parameter updates
   */

  
  event FundsPulled(address _to, uint256 _amount);

  
  event ExecutorChanged(address _newExecutor);

  
  event MaxPriorityFeeChanged(uint256 _newMaxPriorityFee);


  /**
    Custom modifiers to handle access and refund
   */
  modifier onlyMultisig() {
    require(msg.sender == fomoMultisig, "Only callable by FOMO Multsig");
    _;
  }

  modifier onlyFOMO() {
    require(msg.sender == fomoExecutor, "Only callable by FOMO Nouns executor");
    _;
  }

  modifier refundGas() { // Executor must be EOA
    uint256 startGas = gasleft();
    require(tx.gasprice <= block.basefee + maxPriorityFee, "Gas price above current reasonable limit");
    _;
    uint256 endGas = gasleft();

    uint256 totalGasCost = tx.gasprice * (startGas - endGas + OVERHEAD_GAS);
    fomoExecutor.transfer(totalGasCost);
  }


  /**
    Fund management to allow donations and liquidation
   */

  
  function donateFunds() external payable { }
  receive() external payable { }
  fallback() external payable { }

  
  function pullFunds() external onlyMultisig {
    uint256 balance = address(this).balance;
    (bool sent, ) = nounsDaoTreasury.call{value: balance}("");
    require(sent, "Funds removal failed.");
    emit FundsPulled(nounsDaoTreasury, balance);
  }


  /**
    Change addresses or limits for the contract execution
   */
  
  
  function changeExecutorAddress(address _newFomoExecutor) external onlyMultisig {
    fomoExecutor = payable(_newFomoExecutor);
    emit ExecutorChanged(fomoExecutor);
  }

  
  function changeMaxPriorityFee(uint256 _newMaxPriorityFee) external onlyMultisig {
    maxPriorityFee = _newMaxPriorityFee;
    emit MaxPriorityFeeChanged(maxPriorityFee);
  }


  /**
    Settle the Auction & Mint the Desired Nouns
   */

  
  function settleAuction(bytes32 _desiredHash) public {
    bytes32 lastHash = blockhash(block.number - 1); // Only settle if desired Noun would be minted
    require(lastHash == _desiredHash, "Prior blockhash did not match intended hash");
    
    auctionHouse.settleCurrentAndCreateNewAuction();
  }

  
  function settleAuctionWithRefund(bytes32 _desiredHash) external refundGas onlyFOMO {
    settleAuction(_desiredHash);
  }
}

// 



/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.6;

interface INounsAuctionHouse {
    struct Auction {
        // ID for the Noun (ERC721 token ID)
        uint256 nounId;
        // The current highest bid amount
        uint256 amount;
        // The time that the auction started
        uint256 startTime;
        // The time that the auction is scheduled to end
        uint256 endTime;
        // The address of the current highest bid
        address payable bidder;
        // Whether or not the auction has been settled
        bool settled;
    }

    event AuctionCreated(uint256 indexed nounId, uint256 startTime, uint256 endTime);

    event AuctionBid(uint256 indexed nounId, address sender, uint256 value, bool extended);

    event AuctionExtended(uint256 indexed nounId, uint256 endTime);

    event AuctionSettled(uint256 indexed nounId, address winner, uint256 amount);

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(uint256 minBidIncrementPercentage);

    function settleAuction() external;

    function settleCurrentAndCreateNewAuction() external;

    function createBid(uint256 nounId) external payable;

    function pause() external;

    function unpause() external;

    function setTimeBuffer(uint256 timeBuffer) external;

    function setReservePrice(uint256 reservePrice) external;

    function setMinBidIncrementPercentage(uint8 minBidIncrementPercentage) external;
}