
pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}


/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}



contract BurnupGameAccessControl is Claimable, Pausable, CanReclaimToken {
    address public cfoAddress;
    address public cooAddress;
    
    function BurnupGameAccessControl() public {
        // The creator of the contract is the initial CFO.
        cfoAddress = msg.sender;
    
        // The creator of the contract is the initial COO.
        cooAddress = msg.sender;
    }
    
    
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }
    
    
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    
    
    function setCFO(address _newCFO) external onlyOwner {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }
    
    
    
    function setCOO(address _newCOO) external onlyOwner {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }
}



contract BurnupGameBase is BurnupGameAccessControl {
    using SafeMath for uint256;
    
    event NextGame(uint256 rows, uint256 cols, uint256 activityTimer, uint256 unclaimedTilePrice, uint256 buyoutReferralBonusPercentage, uint256 buyoutPrizePoolPercentage, uint256 buyoutDividendPercentage, uint256 buyoutFeePercentage);
    event Start(uint256 indexed gameIndex, address indexed starter, uint256 timestamp, uint256 prizePool, uint256 rows, uint256 cols, uint256 activityTimer, uint256 unclaimedTilePrice, uint256 buyoutReferralBonusPercentage, uint256 buyoutPrizePoolPercentage, uint256 buyoutDividendPercentage, uint256 buyoutFeePercentage);
    event End(uint256 indexed gameIndex, address indexed winner, uint256 indexed identifier, uint256 x, uint256 y, uint256 timestamp, uint256 prize);
    event Buyout(uint256 indexed gameIndex, address indexed player, uint256 indexed identifier, uint256 x, uint256 y, uint256 timestamp, uint256 timeoutTimestamp, uint256 newPrice, uint256 newPrizePool);
    event SpiceUpPrizePool(uint256 indexed gameIndex, address indexed spicer, uint256 spiceAdded, string message, uint256 newPrizePool);
    
    
    struct GameSettings {
        uint256 rows; // 5
        uint256 cols; // 8
        
        
        uint256 activityTimer; // 3600
        
        
        uint256 unclaimedTilePrice; // 0.01 ether
        
        
        /// bonus. In 1/1000th of a percentage.
        uint256 buyoutReferralBonusPercentage; // 750
        
        
        /// pool. In 1/1000th of a percentage.
        uint256 buyoutPrizePoolPercentage; // 10000
    
        
        /// surrounding the tile that is bought out. In in 1/1000th of
        /// a percentage.
        uint256 buyoutDividendPercentage; // 5000
    
        
        uint256 buyoutFeePercentage; // 2500
    }
    
    
    struct GameState {
        
        bool gameStarted;
    
        
        uint256 gameStartTimestamp;
    
        
        mapping (uint256 => address) identifierToOwner;
        
        
        mapping (uint256 => uint256) identifierToBuyoutTimestamp;
        
        
        mapping (uint256 => uint256) identifierToBuyoutPrice;
        
        
        uint256 lastFlippedTile;
        
        
        uint256 prizePool;
    }
    
    
    mapping (uint256 => GameSettings) public gameSettings;
    
    
    mapping (uint256 => GameState) public gameStates;
    
    
    uint256 public gameIndex = 0;
    
    
    GameSettings public nextGameSettings;
    
    function BurnupGameBase() public {
        // Initial settings.
        setNextGameSettings(
            4, // rows
            5, // cols
            3600, // activityTimer
            0.01 ether, // unclaimedTilePrice
            750, // buyoutReferralBonusPercentage
            10000, // buyoutPrizePoolPercentage
            5000, // buyoutDividendPercentage
            2500 // buyoutFeePercentage
        );
    }
    
    
    
    
    function validCoordinate(uint256 x, uint256 y) public view returns(bool) {
        return x < gameSettings[gameIndex].cols && y < gameSettings[gameIndex].rows;
    }
    
    
    
    
    function coordinateToIdentifier(uint256 x, uint256 y) public view returns(uint256) {
        require(validCoordinate(x, y));
        
        return (y * gameSettings[gameIndex].cols) + x;
    }
    
    
    
    /// Assumes the identifier is valid.
    function identifierToCoordinate(uint256 identifier) public view returns(uint256 x, uint256 y) {
        y = identifier / gameSettings[gameIndex].cols;
        x = identifier - (y * gameSettings[gameIndex].cols);
    }
    
    
    function setNextGameSettings(
        uint256 rows,
        uint256 cols,
        uint256 activityTimer,
        uint256 unclaimedTilePrice,
        uint256 buyoutReferralBonusPercentage,
        uint256 buyoutPrizePoolPercentage,
        uint256 buyoutDividendPercentage,
        uint256 buyoutFeePercentage
    )
        public
        onlyCFO
    {
        // Buyout dividend must be 2% at the least.
        // Buyout dividend percentage may be 12.5% at the most.
        require(2000 <= buyoutDividendPercentage && buyoutDividendPercentage <= 12500);
        
        // Buyout fee may be 5% at the most.
        require(buyoutFeePercentage <= 5000);
        
        nextGameSettings = GameSettings({
            rows: rows,
            cols: cols,
            activityTimer: activityTimer,
            unclaimedTilePrice: unclaimedTilePrice,
            buyoutReferralBonusPercentage: buyoutReferralBonusPercentage,
            buyoutPrizePoolPercentage: buyoutPrizePoolPercentage,
            buyoutDividendPercentage: buyoutDividendPercentage,
            buyoutFeePercentage: buyoutFeePercentage
        });
        
        NextGame(rows, cols, activityTimer, unclaimedTilePrice, buyoutReferralBonusPercentage, buyoutPrizePoolPercentage, buyoutDividendPercentage, buyoutFeePercentage);
    }
}



contract BurnupGameOwnership is BurnupGameBase {
    
    event Transfer(address indexed from, address indexed to, uint256 indexed deedId);
    
    
    function name() public pure returns (string _deedName) {
        _deedName = "Burnup Tiles";
    }
    
    
    function symbol() public pure returns (string _deedSymbol) {
        _deedSymbol = "BURN";
    }
    
    
    
    
    function _owns(address _owner, uint256 _identifier) internal view returns (bool) {
        return gameStates[gameIndex].identifierToOwner[_identifier] == _owner;
    }
    
    
    
    
    
    function _transfer(address _from, address _to, uint256 _identifier) internal {
        // Transfer ownership.
        gameStates[gameIndex].identifierToOwner[_identifier] = _to;
        
        // Emit the transfer event.
        Transfer(_from, _to, _identifier);
    }
    
    
    
    function ownerOf(uint256 _identifier) external view returns (address _owner) {
        _owner = gameStates[gameIndex].identifierToOwner[_identifier];

        require(_owner != address(0));
    }
    
    
    /// contract be VERY CAREFUL to ensure that it is aware of ERC-721, or your
    /// deed may be lost forever.
    
    
    
    function transfer(address _to, uint256 _identifier) external whenNotPaused {
        // One can only transfer their own deeds.
        require(_owns(msg.sender, _identifier));
        
        // Transfer ownership
        _transfer(msg.sender, _to, _identifier);
    }
}


/**
 * @title PullPayment
 * @dev Base contract supporting async send for pull payments. Inherit from this
 * contract and use asyncSend instead of send.
 */
contract PullPayment {
  using SafeMath for uint256;

  mapping(address => uint256) public payments;
  uint256 public totalPayments;

  /**
  * @dev withdraw accumulated balance, called by payee.
  */
  function withdrawPayments() public {
    address payee = msg.sender;
    uint256 payment = payments[payee];

    require(payment != 0);
    require(this.balance >= payment);

    totalPayments = totalPayments.sub(payment);
    payments[payee] = 0;

    assert(payee.send(payment));
  }

  /**
  * @dev Called by the payer to store the sent amount as credit to be pulled.
  * @param dest The destination address of the funds.
  * @param amount The amount to transfer.
  */
  function asyncSend(address dest, uint256 amount) internal {
    payments[dest] = payments[dest].add(amount);
    totalPayments = totalPayments.add(amount);
  }
}



contract BurnupHoldingAccessControl is Claimable, Pausable, CanReclaimToken {
    address public cfoAddress;
    
    /// Boolean indicating whether an address is a BurnUp Game contract.
    mapping (address => bool) burnupGame;

    function BurnupHoldingAccessControl() public {
        // The creator of the contract is the initial CFO.
        cfoAddress = msg.sender;
    }
    
    
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }
    
    
    modifier onlyBurnupGame() {
        // The sender must be a recognized BurnUp game address.
        require(burnupGame[msg.sender]);
        _;
    }

    
    
    function setCFO(address _newCFO) external onlyOwner {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }
    
    
    
    function addBurnupGame(address addr) external onlyOwner {
        burnupGame[addr] = true;
    }
    
    
    
    function removeBurnupGame(address addr) external onlyOwner {
        delete burnupGame[addr];
    }
}



contract BurnupHoldingReferral is BurnupHoldingAccessControl {

    event SetReferrer(address indexed referral, address indexed referrer);

    /// Referrer of player.
    mapping (address => address) addressToReferrerAddress;
    
    /// Get the referrer of a player.
    
    function referrerOf(address player) public view returns (address) {
        return addressToReferrerAddress[player];
    }
    
    /// Set the referrer for a player.
    
    
    function _setReferrer(address playerAddr, address referrerAddr) internal {
        addressToReferrerAddress[playerAddr] = referrerAddr;
        
        // Emit event.
        SetReferrer(playerAddr, referrerAddr);
    }
}



contract BurnupHoldingCore is BurnupHoldingReferral, PullPayment {
    using SafeMath for uint256;
    
    address public beneficiary1;
    address public beneficiary2;
    
    function BurnupHoldingCore(address _beneficiary1, address _beneficiary2) public {
        // The creator of the contract is the initial CFO.
        cfoAddress = msg.sender;
        
        // Set the two beneficiaries.
        beneficiary1 = _beneficiary1;
        beneficiary2 = _beneficiary2;
    }
    
    /// Pay the two beneficiaries. Sends both beneficiaries
    /// a halve of the payment.
    function payBeneficiaries() external payable {
        uint256 paymentHalve = msg.value.div(2);
        
        // We do not want a single wei to get stuck.
        uint256 otherPaymentHalve = msg.value.sub(paymentHalve);
        
        // Send payment for manual withdrawal.
        asyncSend(beneficiary1, paymentHalve);
        asyncSend(beneficiary2, otherPaymentHalve);
    }
    
    /// Sets a new address for Beneficiary one.
    
    function setBeneficiary1(address addr) external onlyCFO {
        beneficiary1 = addr;
    }
    
    /// Sets a new address for Beneficiary two.
    
    function setBeneficiary2(address addr) external onlyCFO {
        beneficiary2 = addr;
    }
    
    /// Set a referrer.
    
    
    function setReferrer(address playerAddr, address referrerAddr) external onlyBurnupGame whenNotPaused returns(bool) {
        if (referrerOf(playerAddr) == address(0x0) && playerAddr != referrerAddr) {
            // Set the referrer, if no referrer has been set yet, and the player
            // and referrer are not the same address.
            _setReferrer(playerAddr, referrerAddr);
            
            // Indicate success.
            return true;
        }
        
        // Indicate failure.
        return false;
    }
}



contract BurnupGameFinance is BurnupGameOwnership, PullPayment {
    /// Address of Burnup wallet
    BurnupHoldingCore burnupHolding;
    
    function BurnupGameFinance(address burnupHoldingAddress) public {
        burnupHolding = BurnupHoldingCore(burnupHoldingAddress);
    }
    
    
    
    function _claimedSurroundingTiles(uint256 _deedId) internal view returns (uint256[] memory) {
        var (x, y) = identifierToCoordinate(_deedId);
        
        // Find all claimed surrounding tiles.
        uint256 claimed = 0;
        
        // Create memory buffer capable of holding all tiles.
        uint256[] memory _tiles = new uint256[](8);
        
        // Loop through all neighbors.
        for (int256 dx = -1; dx <= 1; dx++) {
            for (int256 dy = -1; dy <= 1; dy++) {
                if (dx == 0 && dy == 0) {
                    // Skip the center (i.e., the tile itself).
                    continue;
                }
                
                uint256 nx = uint256(int256(x) + dx);
                uint256 ny = uint256(int256(y) + dy);
                
                if (nx >= gameSettings[gameIndex].cols || ny >= gameSettings[gameIndex].rows) {
                    // This coordinate is outside the game bounds.
                    continue;
                }
                
                // Get the coordinates of this neighboring identifier.
                uint256 neighborIdentifier = coordinateToIdentifier(
                    nx,
                    ny
                );
                
                if (gameStates[gameIndex].identifierToOwner[neighborIdentifier] != address(0x0)) {
                    _tiles[claimed] = neighborIdentifier;
                    claimed++;
                }
            }
        }
        
        // Memory arrays cannot be resized, so copy all
        // tiles from the buffer to the tile array.
        uint256[] memory tiles = new uint256[](claimed);
        
        for (uint256 i = 0; i < claimed; i++) {
            tiles[i] = _tiles[i];
        }
        
        return tiles;
    }
    
    
    
    function nextBuyoutPrice(uint256 price) public pure returns (uint256) {
        if (price < 0.02 ether) {
            return price.mul(200).div(100); // * 2.0
        } else {
            return price.mul(150).div(100); // * 1.5
        }
    }
    
    
    function _assignBuyoutProceeds(
        address currentOwner,
        uint256[] memory claimedSurroundingTiles,
        uint256 fee,
        uint256 currentOwnerWinnings,
        uint256 totalDividendPerBeneficiary,
        uint256 referralBonus,
        uint256 prizePoolFunds
    )
        internal
    {
    
        if (currentOwner != 0x0) {
            // Send the current owner's winnings.
            _sendFunds(currentOwner, currentOwnerWinnings);
        } else {
            // There is no current owner.
            fee = fee.add(currentOwnerWinnings);
        }
        
        // Assign dividends to owners of surrounding tiles.
        for (uint256 i = 0; i < claimedSurroundingTiles.length; i++) {
            address beneficiary = gameStates[gameIndex].identifierToOwner[claimedSurroundingTiles[i]];
            _sendFunds(beneficiary, totalDividendPerBeneficiary);
        }
        
        /// Distribute the referral bonuses (if any) for an address.
        address referrer1 = burnupHolding.referrerOf(msg.sender);
        if (referrer1 != 0x0) {
            _sendFunds(referrer1, referralBonus);
        
            address referrer2 = burnupHolding.referrerOf(referrer1);
            if (referrer2 != 0x0) {
                _sendFunds(referrer2, referralBonus);
            } else {
                // There is no second-level referrer.
                fee = fee.add(referralBonus);
            }
        } else {
            // There are no first and second-level referrers.
            fee = fee.add(referralBonus.mul(2));
        }
        
        // Send the fee to the holding contract.
        burnupHolding.payBeneficiaries.value(fee)();
        
        // Increase the prize pool.
        gameStates[gameIndex].prizePool = gameStates[gameIndex].prizePool.add(prizePoolFunds);
    }
    
    
    
    
    
    function _calculateAndAssignBuyoutProceeds(address currentOwner, uint256 _deedId, uint256[] memory claimedSurroundingTiles)
        internal 
        returns (uint256 price)
    {
        // The current price.
        
        if (currentOwner == 0x0) {
            price = gameSettings[gameIndex].unclaimedTilePrice;
        } else {
            price = gameStates[gameIndex].identifierToBuyoutPrice[_deedId];
        }
        
        // Calculate the variable dividends based on the buyout price
        // (only to be paid if there are surrounding tiles).
        uint256 variableDividends = price.mul(gameSettings[gameIndex].buyoutDividendPercentage).div(100000);
        
        // Calculate fees, referral bonus, and prize pool funds.
        uint256 fee            = price.mul(gameSettings[gameIndex].buyoutFeePercentage).div(100000);
        uint256 referralBonus  = price.mul(gameSettings[gameIndex].buyoutReferralBonusPercentage).div(100000);
        uint256 prizePoolFunds = price.mul(gameSettings[gameIndex].buyoutPrizePoolPercentage).div(100000);
        
        // Calculate and assign buyout proceeds.
        uint256 currentOwnerWinnings = price.sub(fee).sub(referralBonus.mul(2)).sub(prizePoolFunds);
        
        uint256 totalDividendPerBeneficiary;
        if (claimedSurroundingTiles.length > 0) {
            // If there are surrounding tiles, variable dividend is to be paid
            // based on the buyout price.
            // Calculate the dividend per surrounding tile.
            totalDividendPerBeneficiary = variableDividends / claimedSurroundingTiles.length;
            
            currentOwnerWinnings = currentOwnerWinnings.sub(variableDividends);
            // currentOwnerWinnings = currentOwnerWinnings.sub(totalDividendPerBeneficiary * claimedSurroundingTiles.length);
        }
        
        _assignBuyoutProceeds(
            currentOwner,
            claimedSurroundingTiles,
            fee,
            currentOwnerWinnings,
            totalDividendPerBeneficiary,
            referralBonus,
            prizePoolFunds
        );
    }
    
    
    /// funds to the beneficiary's balance for manual withdrawal.
    
    
    function _sendFunds(address beneficiary, uint256 amount) internal {
        if (!beneficiary.send(amount)) {
            // Failed to send funds. This can happen due to a failure in
            // fallback code of the beneficiary, or because of callstack
            // depth.
            // Send funds asynchronously for manual withdrawal by the
            // beneficiary.
            asyncSend(beneficiary, amount);
        }
    }
}



contract BurnupGameCore is BurnupGameFinance {
    
    function BurnupGameCore(address burnupHoldingAddress) public BurnupGameFinance(burnupHoldingAddress) {}
    
    
    
    
    
    
    function buyout(uint256 _gameIndex, bool startNewGameIfIdle, uint256 x, uint256 y) public payable {
        // Check to see if the game should end. Process payment.
        _processGameEnd();
        
        if (!gameStates[gameIndex].gameStarted) {
            // If the game is not started, the contract must not be paused.
            require(!paused);
            
            // If the game is not started, the player must be willing to start
            // a new game.
            require(startNewGameIfIdle);
            
            // Set the price and timeout.
            gameSettings[gameIndex] = nextGameSettings;
            
            // Start the game.
            gameStates[gameIndex].gameStarted = true;
            
            // Set game started timestamp.
            gameStates[gameIndex].gameStartTimestamp = block.timestamp;
            
            // Emit start event.
            Start(gameIndex, msg.sender, block.timestamp, gameStates[gameIndex].prizePool, gameSettings[gameIndex].rows, gameSettings[gameIndex].cols, gameSettings[gameIndex].activityTimer, gameSettings[gameIndex].unclaimedTilePrice, gameSettings[gameIndex].buyoutReferralBonusPercentage, gameSettings[gameIndex].buyoutPrizePoolPercentage, gameSettings[gameIndex].buyoutDividendPercentage, gameSettings[gameIndex].buyoutFeePercentage);
        }
    
        // Check the game index.
        if (startNewGameIfIdle) {
            // The given game index must be the current game index, or the previous
            // game index.
            require(_gameIndex == gameIndex || _gameIndex.add(1) == gameIndex);
        } else {
            // Only play on the game indicated by the player.
            require(_gameIndex == gameIndex);
        }
        
        uint256 identifier = coordinateToIdentifier(x, y);
        
        address currentOwner = gameStates[gameIndex].identifierToOwner[identifier];
        
        // Tile must be unowned, or active.
        if (currentOwner == address(0x0)) {
            // Tile must still be flippable.
            require(gameStates[gameIndex].gameStartTimestamp.add(gameSettings[gameIndex].activityTimer) >= block.timestamp);
        } else {
            // Tile must be active.
            require(gameStates[gameIndex].identifierToBuyoutTimestamp[identifier].add(gameSettings[gameIndex].activityTimer) >= block.timestamp);
        }
        
        // Get existing surrounding tiles.
        uint256[] memory claimedSurroundingTiles = _claimedSurroundingTiles(identifier);
        
        // Assign the buyout proceeds and retrieve the total cost.
        uint256 price = _calculateAndAssignBuyoutProceeds(currentOwner, identifier, claimedSurroundingTiles);
        
        // Enough Ether must be supplied.
        require(msg.value >= price);
        
        // Transfer the tile.
        _transfer(currentOwner, msg.sender, identifier);
        
        // Set this tile to be the most recently bought out.
        gameStates[gameIndex].lastFlippedTile = identifier;
        
        // Calculate and set the new tile price.
        gameStates[gameIndex].identifierToBuyoutPrice[identifier] = nextBuyoutPrice(price);
        
        // Set the buyout timestamp.
        gameStates[gameIndex].identifierToBuyoutTimestamp[identifier] = block.timestamp;
        
        // Emit event
        Buyout(gameIndex, msg.sender, identifier, x, y, block.timestamp, block.timestamp + gameSettings[gameIndex].activityTimer, gameStates[gameIndex].identifierToBuyoutPrice[identifier], gameStates[gameIndex].prizePool);
        
        // Calculate the excess Ether sent.
        // msg.value is greater than or equal to price,
        // so this cannot underflow.
        uint256 excess = msg.value - price;
        
        if (excess > 0) {
            // Refund any excess Ether (not susceptible to re-entry attack, as
            // the owner is assigned before the transfer takes place).
            msg.sender.transfer(excess);
        }
    }
    
    
    
    
    
    
    function buyoutAndSetReferrer(uint256 _gameIndex, bool startNewGameIfIdle, uint256 x, uint256 y, address referrerAddress) external payable {
        // Set the referrer.
        burnupHolding.setReferrer(msg.sender, referrerAddress);
    
        // Play.
        buyout(_gameIndex, startNewGameIfIdle, x, y);
    }
    
    
    
    
    function spiceUp(uint256 _gameIndex, string message) external payable {
        // Check to see if the game should end. Process payment.
        _processGameEnd();
        
        // Check the game index.
        require(_gameIndex == gameIndex);
    
        // Game must be live or unpaused.
        require(gameStates[gameIndex].gameStarted || !paused);
        
        // Funds must be sent.
        require(msg.value > 0);
        
        // Add funds to the prize pool.
        gameStates[gameIndex].prizePool = gameStates[gameIndex].prizePool.add(msg.value);
        
        // Emit event.
        SpiceUpPrizePool(gameIndex, msg.sender, msg.value, message, gameStates[gameIndex].prizePool);
    }
    
    
    function endGame() external {
        require(_processGameEnd());
    }
    
    
    function _processGameEnd() internal returns(bool) {
        address currentOwner = gameStates[gameIndex].identifierToOwner[gameStates[gameIndex].lastFlippedTile];
    
        // The game must be started.
        if (!gameStates[gameIndex].gameStarted) {
            return false;
        }
    
        // The last flipped tile must be owned (i.e. there has been at
        // least one flip).
        if (currentOwner == address(0x0)) {
            return false;
        }
        
        // The last flipped tile must have become inactive.
        if (gameStates[gameIndex].identifierToBuyoutTimestamp[gameStates[gameIndex].lastFlippedTile].add(gameSettings[gameIndex].activityTimer) >= block.timestamp) {
            return false;
        }
        
        // Assign prize pool to the owner of the last-flipped tile.
        if (gameStates[gameIndex].prizePool > 0) {
            _sendFunds(currentOwner, gameStates[gameIndex].prizePool);
        }
        
        // Get coordinates of last flipped tile.
        var (x, y) = identifierToCoordinate(gameStates[gameIndex].lastFlippedTile);
        
        // Emit event.
        End(gameIndex, currentOwner, gameStates[gameIndex].lastFlippedTile, x, y, gameStates[gameIndex].identifierToBuyoutTimestamp[gameStates[gameIndex].lastFlippedTile].add(gameSettings[gameIndex].activityTimer), gameStates[gameIndex].prizePool);
        
        // Increment the game index. This won't overflow before the heat death of the universe.
        gameIndex++;
        
        // Indicate ending the game was successful.
        return true;
    }
}