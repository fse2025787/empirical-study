// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

// File: contracts\lib\IERC20.sol

// 

pragma solidity ^0.8.3;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\interface\INestMining.sol


interface INestMining {
    
    
    
    
    
    
    event Post(address tokenAddress, address miner, uint index, uint ethNum, uint price);

    /* ========== Structures ========== */
    
    
    struct Config {
        
        // Eth number of each post. 30
        // We can stop post and taking orders by set postEthUnit to 0 (closing and withdraw are not affected)
        uint32 postEthUnit;

        // Post fee(0.0001eth，DIMI_ETHER). 1000
        uint16 postFeeUnit;

        // Proportion of miners digging(10000 based). 8000
        uint16 minerNestReward;
        
        // The proportion of token dug by miners is only valid for the token created in version 3.0
        // (10000 based). 9500
        uint16 minerNTokenReward;

        // When the circulation of ntoken exceeds this threshold, post() is prohibited(Unit: 10000 ether). 500
        uint32 doublePostThreshold;
        
        // The limit of ntoken mined blocks. 100
        uint16 ntokenMinedBlockLimit;

        // -- Public configuration
        // The number of times the sheet assets have doubled. 4
        uint8 maxBiteNestedLevel;
        
        // Price effective block interval. 20
        uint16 priceEffectSpan;

        // The amount of nest to pledge for each post（Unit: 1000). 100
        uint16 pledgeNest;
    }

    
    struct PriceSheetView {
        
        // Index of the price sheeet
        uint32 index;

        // Address of miner
        address miner;

        // The block number of this price sheet packaged
        uint32 height;

        // The remain number of this price sheet
        uint32 remainNum;

        // The eth number which miner will got
        uint32 ethNumBal;

        // The eth number which equivalent to token's value which miner will got
        uint32 tokenNumBal;

        // The pledged number of nest in this sheet. (Unit: 1000nest)
        uint24 nestNum1k;

        // The level of this sheet. 0 expresses initial price sheet, a value greater than 0 expresses bite price sheet
        uint8 level;

        // Post fee shares, if there are many sheets in one block, this value is used to divide up mining value
        uint8 shares;

        // The token price. (1eth equivalent to (price) token)
        uint152 price;
    }

    /* ========== Configuration ========== */

    
    
    function setConfig(Config memory config) external;

    
    
    function getConfig() external view returns (Config memory);

    
    
    
    function setNTokenAddress(address tokenAddress, address ntokenAddress) external;

    
    
    
    function getNTokenAddress(address tokenAddress) external view returns (address);

    /* ========== Mining ========== */

    
    
    
    
    
    function post(address tokenAddress, uint ethNum, uint tokenAmountPerEth) external payable;

    
    
    
    
    
    
    function post2(address tokenAddress, uint ethNum, uint tokenAmountPerEth, uint ntokenAmountPerEth) external payable;

    
    
    
    
    
    
    function takeToken(address tokenAddress, uint index, uint takeNum, uint newTokenAmountPerEth) external payable;

    
    
    
    
    
    
    function takeEth(address tokenAddress, uint index, uint takeNum, uint newTokenAmountPerEth) external payable;
    
    
    
    
    
    function close(address tokenAddress, uint index) external;

    
    
    
    
    function closeList(address tokenAddress, uint[] memory indices) external;

    
    
    
    
    
    function closeList2(address tokenAddress, uint[] memory tokenIndices, uint[] memory ntokenIndices) external;

    
    ///     It calculates from priceInfo to the newest that is effective.
    function stat(address tokenAddress) external;

    
    
    function settle(address tokenAddress) external;

    
    
    
    
    
    
    function list(address tokenAddress, uint offset, uint count, uint order) external view returns (PriceSheetView[] memory);

    
    
    
    function estimate(address tokenAddress) external view returns (uint);

    
    
    
    
    
    function getMinedBlocks(address tokenAddress, uint index) external view returns (uint minedBlocks, uint totalShares);

    /* ========== Accounts ========== */

    
    
    
    function withdraw(address tokenAddress, uint value) external;

    
    
    
    
    function balanceOf(address tokenAddress, address addr) external view returns (uint);

    
    
    
    function indexAddress(uint index) external view returns (address);
    
    
    
    
    function getAccountIndex(address addr) external view returns (uint);

    
    
    function getAccountCount() external view returns (uint);
}

// File: contracts\interface\INestVote.sol


interface INestVote {

    
    
    
    
    event NIPSubmitted(address proposer, address contractAddress, uint index);

    
    
    
    
    event NIPVote(address voter, uint index, uint amount);

    
    
    
    event NIPExecute(address executor, uint index);

    
    struct Config {

        // Proportion of votes required (10000 based). 5100
        uint32 acceptance;

        // Voting time cycle (seconds). 5 * 86400
        uint64 voteDuration;

        // The number of nest votes need to be staked. 100000 nest
        uint96 proposalStaking;
    }

    // Proposal
    struct ProposalView {

        // Index of proposal
        uint index;
        
        // The immutable field and the variable field are stored separately
        /* ========== Immutable field ========== */

        // Brief of this proposal
        string brief;

        // The contract address which will be executed when the proposal is approved. (Must implemented IVotePropose)
        address contractAddress;

        // Voting start time
        uint48 startTime;

        // Voting stop time
        uint48 stopTime;

        // Proposer
        address proposer;

        // Staked nest amount
        uint96 staked;

        /* ========== Mutable field ========== */

        // Gained value
        // The maximum value of uint96 can be expressed as 79228162514264337593543950335, which is more than the total 
        // number of nest 10000000000 ether. Therefore, uint96 can be used to express the total number of votes
        uint96 gainValue;

        // The state of this proposal
        uint32 state;  // 0: proposed | 1: accepted | 2: cancelled

        // The executor of this proposal
        address executor;

        // The execution time (if any, such as block number or time stamp) is placed in the contract and is limited by the contract itself

        // Circulation of nest
        uint96 nestCirculation;
    }
    
    
    
    function setConfig(Config memory config) external;

    
    
    function getConfig() external view returns (Config memory);

    /* ========== VOTE ========== */
    
    
    
    
    function propose(address contractAddress, string memory brief) external;

    
    
    
    function vote(uint index, uint value) external;

    
    
    function withdraw(uint index) external;

    
    
    function execute(uint index) external;

    
    
    function cancel(uint index) external;

    
    
    
    function getProposeInfo(uint index) external view returns (ProposalView memory);

    
    
    function getProposeCount() external view returns (uint);

    
    
    
    
    
    function list(uint offset, uint count, uint order) external view returns (ProposalView[] memory);

    
    
    function getNestCirculation() external view returns (uint);

    
    
    
    
    function upgradeProxy(address proxyAdmin, address proxy, address implementation) external;

    
    ///      Can only be called by the current owner
    
    
    function transferUpgradeAuthority(address proxyAdmin, address newOwner) external;
}

// File: contracts\interface\IVotePropose.sol


interface IVotePropose {

    
    function run() external;
}

// File: contracts\interface\INestMapping.sol


interface INestMapping {

    
    
    
    
    
    
    
    
    
    
    
    function setBuiltinAddress(
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    ) external;

    
    
    
    
    
    
    
    
    
    
    
    function getBuiltinAddress() external view returns (
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    );

    
    
    function getNestTokenAddress() external view returns (address);

    
    
    function getNestNodeAddress() external view returns (address);

    
    
    function getNestLedgerAddress() external view returns (address);

    
    
    function getNestMiningAddress() external view returns (address);

    
    
    function getNTokenMiningAddress() external view returns (address);

    
    
    function getNestPriceFacadeAddress() external view returns (address);

    
    
    function getNestVoteAddress() external view returns (address);

    
    
    function getNestQueryAddress() external view returns (address);

    
    
    function getNnIncomeAddress() external view returns (address);

    
    
    function getNTokenControllerAddress() external view returns (address);

    
    
    
    function registerAddress(string memory key, address addr) external;

    
    
    
    function checkAddress(string memory key) external view returns (address);
}

// File: contracts\interface\INestGovernance.sol


interface INestGovernance is INestMapping {

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    
    
    
    
    function checkGovernance(address addr, uint flag) external view returns (bool);
}

// File: contracts\interface\IProxyAdmin.sol


interface IProxyAdmin {

    
    
    
    function upgrade(address proxy, address implementation) external;

    
    ///      Can only be called by the current owner
    
    function transferOwnership(address newOwner) external;
}

// File: contracts\lib\TransferHelper.sol

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// File: contracts\interface\INestLedger.sol


interface INestLedger {

    
    
    
    event ApplicationChanged(address addr, uint flag);
    
    
    struct Config {
        
        // nest reward scale(10000 based). 2000
        uint16 nestRewardScale;

        // // ntoken reward scale(10000 based). 8000
        // uint16 ntokenRewardScale;
    }
    
    
    
    function setConfig(Config memory config) external;

    
    
    function getConfig() external view returns (Config memory);

    
    
    
    function setApplication(address addr, uint flag) external;

    
    
    
    function checkApplication(address addr) external view returns (uint);

    
    
    function carveETHReward(address ntokenAddress) external payable;

    
    
    function addETHReward(address ntokenAddress) external payable;

    
    
    function totalETHRewards(address ntokenAddress) external view returns (uint);

    
    
    
    
    
    function pay(address ntokenAddress, address tokenAddress, address to, uint value) external;

    
    
    
    
    
    function settle(address ntokenAddress, address tokenAddress, address to, uint value) external payable;
}

// File: contracts\NestBase.sol


contract NestBase {

    // Address of nest token contract
    address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;

    // Genesis block number of nest
    // NEST token contract is created at block height 6913517. However, because the mining algorithm of nest1.0
    // is different from that at present, a new mining algorithm is adopted from nest2.0. The new algorithm
    // includes the attenuation logic according to the block. Therefore, it is necessary to trace the block
    // where the nest begins to decay. According to the circulation when nest2.0 is online, the new mining
    // algorithm is used to deduce and convert the nest, and the new algorithm is used to mine the nest2.0
    // on-line flow, the actual block is 5120000
    uint constant NEST_GENESIS_BLOCK = 5120000;

    
    
    function initialize(address nestGovernanceAddress) virtual public {
        require(_governance == address(0), 'NEST:!initialize');
        _governance = nestGovernanceAddress;
    }

    
    address public _governance;

    
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    
    function update(address nestGovernanceAddress) virtual public {

        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = nestGovernanceAddress;
    }

    
    
    
    function migrate(address tokenAddress, uint value) external onlyGovernance {

        address to = INestGovernance(_governance).getNestLedgerAddress();
        if (tokenAddress == address(0)) {
            INestLedger(to).addETHReward { value: value } (address(0));
        } else {
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(INestGovernance(_governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _;
    }

    modifier noContract() {
        require(msg.sender == tx.origin, "NEST:!contract");
        _;
    }
}

// File: contracts\NestVote.sol


contract NestVote is NestBase, INestVote {
    
    // constructor() { }

    
    struct UINT {
        uint value;
    }

    
    struct Proposal {

        // The immutable field and the variable field are stored separately
        /* ========== Immutable field ========== */

        // Brief of this proposal
        string brief;

        // The contract address which will be executed when the proposal is approved. (Must implemented IVotePropose)
        address contractAddress;

        // Voting start time
        uint48 startTime;

        // Voting stop time
        uint48 stopTime;

        // Proposer
        address proposer;

        // Staked nest amount
        uint96 staked;

        /* ========== Mutable field ========== */

        // Gained value
        // The maximum value of uint96 can be expressed as 79228162514264337593543950335, which is more than the total 
        // number of nest 10000000000 ether. Therefore, uint96 can be used to express the total number of votes
        uint96 gainValue;

        // The state of this proposal. 0: proposed | 1: accepted | 2: cancelled
        uint32 state;

        // The executor of this proposal
        address executor;

        // The execution time (if any, such as block number or time stamp) is placed in the contract and is limited by the contract itself
    }
    
    // Configuration
    Config _config;

    // Array for proposals
    Proposal[] public _proposalList;

    // Staked ledger
    mapping(uint =>mapping(address =>UINT)) public _stakedLedger;
    
    address _nestLedgerAddress;
    //address _nestTokenAddress;
    address _nestMiningAddress;
    address _nnIncomeAddress;

    uint32 constant PROPOSAL_STATE_PROPOSED = 0;
    uint32 constant PROPOSAL_STATE_ACCEPTED = 1;
    uint32 constant PROPOSAL_STATE_CANCELLED = 2;

    uint constant NEST_TOTAL_SUPPLY = 10000000000 ether;

    
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    
    function update(address nestGovernanceAddress) override public {
        super.update(nestGovernanceAddress);

        (
            //address nestTokenAddress
            ,//_nestTokenAddress, 
            //address nestNodeAddress
            ,
            //address nestLedgerAddress
            _nestLedgerAddress, 
            //address nestMiningAddress
            _nestMiningAddress, 
            //address ntokenMiningAddress
            ,
            //address nestPriceFacadeAddress
            ,
            //address nestVoteAddress
            ,
            //address nestQueryAddress
            ,
            //address nnIncomeAddress
            _nnIncomeAddress, 
            //address nTokenControllerAddress
              
        ) = INestGovernance(nestGovernanceAddress).getBuiltinAddress();
    }

    
    
    function setConfig(Config memory config) override external onlyGovernance {
        require(uint(config.acceptance) <= 10000, "NestVote:!value");
        _config = config;
    }

    
    
    function getConfig() override external view returns (Config memory) {
        return _config;
    }

    /* ========== VOTE ========== */
    
    
    
    
    function propose(address contractAddress, string memory brief) override external noContract
    {
        // The target address cannot already have governance permission to prevent the governance permission from being covered
        require(!INestGovernance(_governance).checkGovernance(contractAddress, 0), "NestVote:!governance");
     
        Config memory config = _config;
        uint index = _proposalList.length;

        // Create voting structure
        _proposalList.push(Proposal(
        
            // Brief of this propose
            //string brief;
            brief,

            // The contract address which will be executed when the proposal is approved. (Must implemented IVotePropose)
            //address contractAddress;
            contractAddress,

            // Voting start time
            //uint48 startTime;
            uint48(block.timestamp),

            // Voting stop time
            //uint48 stopTime;
            uint48(block.timestamp + uint(config.voteDuration)),

            // Proposer
            //address proposer;
            msg.sender,

            config.proposalStaking,

            uint96(0), 
            
            PROPOSAL_STATE_PROPOSED, 

            address(0)
        ));

        // Stake nest
        IERC20(NEST_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), uint(config.proposalStaking));

        emit NIPSubmitted(msg.sender, contractAddress, index);
    }

    
    
    
    function vote(uint index, uint value) override external noContract
    {
        // 1. Load the proposal
        Proposal memory p = _proposalList[index];

        // 2. Check
        // Check time region
        // Note: stop time is not include stopTime
        require(block.timestamp >= uint(p.startTime) && block.timestamp < uint(p.stopTime), "NestVote:!time");
        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");

        // 3. Update voting ledger
        UINT storage balance = _stakedLedger[index][msg.sender];
        balance.value += value;

        // 4. Update voting information
        _proposalList[index].gainValue = uint96(uint(p.gainValue) + value);

        // 5. Stake nest
        IERC20(NEST_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), value);

        emit NIPVote(msg.sender, index, value);
    }

    
    
    function withdraw(uint index) override external noContract
    {
        // 1. Update voting ledger
        UINT storage balance = _stakedLedger[index][msg.sender];
        uint balanceValue = balance.value;
        balance.value = 0;

        // 2. In the proposal state, the number of votes obtained needs to be updated
        if (_proposalList[index].state == PROPOSAL_STATE_PROPOSED) {
            _proposalList[index].gainValue = uint96(uint(_proposalList[index].gainValue) - balanceValue);
        }

        // 3. Return staked nest
        IERC20(NEST_TOKEN_ADDRESS).transfer(msg.sender, balanceValue);
    }

    
    
    function execute(uint index) override external noContract
    {
        Config memory config = _config;

        // 1. Load proposal
        Proposal memory p = _proposalList[index];

        // 2. Check status
        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");
        require(block.timestamp < uint(p.stopTime), "NestVote:!time");
        // The target address cannot already have governance permission to prevent the governance permission from being covered
        address governance = _governance;
        require(!INestGovernance(governance).checkGovernance(p.contractAddress, 0), "NestVote:!governance");

        // 3. Check the gaine rate
        IERC20 nest = IERC20(NEST_TOKEN_ADDRESS);

        // Calculate the circulation of nest
        uint nestCirculation = _getNestCirculation(nest);
        require(uint(p.gainValue) * 10000 >= nestCirculation * uint(config.acceptance), "NestVote:!gainValue");

        // 3. Temporarily grant execution permission
        INestGovernance(governance).setGovernance(p.contractAddress, 1);

        // 4. Execute
        _proposalList[index].state = PROPOSAL_STATE_ACCEPTED;
        _proposalList[index].executor = msg.sender;
        IVotePropose(p.contractAddress).run();

        // 5. Delete execution permission
        INestGovernance(governance).setGovernance(p.contractAddress, 0);
        
        // Return nest
        nest.transfer(p.proposer, uint(p.staked));

        emit NIPExecute(msg.sender, index);
    }

    
    
    function cancel(uint index) override external noContract {

        // 1. Load proposal
        Proposal memory p = _proposalList[index];

        // 2. Check state
        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");
        require(block.timestamp >= uint(p.stopTime), "NestVote:!time");

        // 3. Update status
        _proposalList[index].state = PROPOSAL_STATE_CANCELLED;

        // 4. Return staked nest
        IERC20(NEST_TOKEN_ADDRESS).transfer(p.proposer, uint(p.staked));
    }

    // Convert PriceSheet to PriceSheetView
    //function _toPriceSheetView(PriceSheet memory sheet, uint index) private view returns (PriceSheetView memory) {
    function _toProposalView(Proposal memory proposal, uint index, uint nestCirculation) private pure returns (ProposalView memory) {

        return ProposalView(
            // Index of the proposal
            index,
            // Brief of proposal
            //string brief;
            proposal.brief,
            // The contract address which will be executed when the proposal is approved. (Must implemented IVotePropose)
            //address contractAddress;
            proposal.contractAddress,
            // Voting start time
            //uint48 startTime;
            proposal.startTime,
            // Voting stop time
            //uint48 stopTime;
            proposal.stopTime,
            // Proposer
            //address proposer;
            proposal.proposer,
            // Staked nest amount
            //uint96 staked;
            proposal.staked,
            // Gained value
            // The maximum value of uint96 can be expressed as 79228162514264337593543950335, which is more than the total 
            // number of nest 10000000000 ether. Therefore, uint96 can be used to express the total number of votes
            //uint96 gainValue;
            proposal.gainValue,
            // The state of this proposal
            //uint32 state;  // 0: proposed | 1: accepted | 2: cancelled
            proposal.state,
            // The executor of this proposal
            //address executor;
            proposal.executor,

            // Circulation of nest
            uint96(nestCirculation)
        );
    }

    
    
    
    function getProposeInfo(uint index) override external view returns (ProposalView memory) {
        return _toProposalView(_proposalList[index], index, getNestCirculation());
    }

    
    
    function getProposeCount() override external view returns (uint) {
        return _proposalList.length;
    }

    
    
    
    
    
    function list(uint offset, uint count, uint order) override external view returns (ProposalView[] memory) {
        
        Proposal[] storage proposalList = _proposalList;
        ProposalView[] memory result = new ProposalView[](count);
        uint nestCirculation = getNestCirculation();
        uint length = proposalList.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {

            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                --index;
                result[i++] = _toProposalView(proposalList[index], index, nestCirculation);
            }
        } 
        // Positive sequence
        else {
            
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                result[i++] = _toProposalView(proposalList[index], index, nestCirculation);
                ++index;
            }
        }

        return result;
    }

    // Get Circulation of nest
    function _getNestCirculation(IERC20 nest) private view returns (uint) {

        return NEST_TOTAL_SUPPLY 
            - nest.balanceOf(_nestMiningAddress)
            - nest.balanceOf(_nnIncomeAddress)
            - nest.balanceOf(_nestLedgerAddress)
            - nest.balanceOf(address(0x1));
    }

    
    
    function getNestCirculation() override public view returns (uint) {
        return _getNestCirculation(IERC20(NEST_TOKEN_ADDRESS));
    }

    
    
    
    
    function upgradeProxy(address proxyAdmin, address proxy, address implementation) override external onlyGovernance {
        IProxyAdmin(proxyAdmin).upgrade(proxy, implementation);
    }

    
    ///      Can only be called by the current owner
    
    
    function transferUpgradeAuthority(address proxyAdmin, address newOwner) override external onlyGovernance {
        IProxyAdmin(proxyAdmin).transferOwnership(newOwner);
    }
}