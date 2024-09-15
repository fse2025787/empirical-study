// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

// File: contracts\interface\INestMapping.sol

// 

pragma solidity ^0.8.3;


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

// File: contracts\lib\IERC20.sol

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

// File: contracts\interface\INestQuery.sol


interface INestQuery {
    
    
    
    
    
    function triggeredPrice(address tokenAddress) external view returns (uint blockNumber, uint price);

    
    
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447,
    ///         it means that the volatility has exceeded the range that can be expressed
    function triggeredPriceInfo(address tokenAddress) external view returns (
        uint blockNumber,
        uint price,
        uint avgPrice,
        uint sigmaSQ
    );

    
    
    
    
    
    function findPrice(
        address tokenAddress,
        uint height
    ) external view returns (uint blockNumber, uint price);

    
    
    
    
    function latestPrice(address tokenAddress) external view returns (uint blockNumber, uint price);

    
    
    
    
    function lastPriceList(address tokenAddress, uint count) external view returns (uint[] memory);

    
    
    
    
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447,
    ///         it means that the volatility has exceeded the range that can be expressed
    function latestPriceAndTriggeredPriceInfo(address tokenAddress) external view 
    returns (
        uint latestPriceBlockNumber,
        uint latestPriceValue,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );

    
    
    
    
    
    
    function triggeredPrice2(address tokenAddress) external view returns (
        uint blockNumber,
        uint price,
        uint ntokenBlockNumber,
        uint ntokenPrice
    );

    
    
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447, 
    ///         it means that the volatility has exceeded the range that can be expressed
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447,
    ///         it means that the volatility has exceeded the range that can be expressed
    function triggeredPriceInfo2(address tokenAddress) external view returns (
        uint blockNumber,
        uint price,
        uint avgPrice,
        uint sigmaSQ,
        uint ntokenBlockNumber,
        uint ntokenPrice,
        uint ntokenAvgPrice,
        uint ntokenSigmaSQ
    );

    
    
    
    
    
    
    function latestPrice2(address tokenAddress) external view returns (
        uint blockNumber,
        uint price,
        uint ntokenBlockNumber,
        uint ntokenPrice
    );
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

// File: contracts\NestMapping.sol


abstract contract NestMapping is NestBase, INestMapping {

    // constructor() { }

    
    address _nestTokenAddress;

    
    address _nestNodeAddress;

    
    address _nestLedgerAddress;

    
    address _nestMiningAddress;

    
    address _ntokenMiningAddress;

    
    address _nestPriceFacadeAddress;

    
    address _nestVoteAddress;

    
    address _nestQueryAddress;

    
    address _nnIncomeAddress;

    
    address _nTokenControllerAddress;
    
    
    mapping(string=>address) _registeredAddress;

    
    
    
    
    
    
    
    
    
    
    
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
    ) override external onlyGovernance {
        
        if (nestTokenAddress != address(0)) {
            _nestTokenAddress = nestTokenAddress;
        }
        if (nestNodeAddress != address(0)) {
            _nestNodeAddress = nestNodeAddress;
        }
        if (nestLedgerAddress != address(0)) {
            _nestLedgerAddress = nestLedgerAddress;
        }
        if (nestMiningAddress != address(0)) {
            _nestMiningAddress = nestMiningAddress;
        }
        if (ntokenMiningAddress != address(0)) {
            _ntokenMiningAddress = ntokenMiningAddress;
        }
        if (nestPriceFacadeAddress != address(0)) {
            _nestPriceFacadeAddress = nestPriceFacadeAddress;
        }
        if (nestVoteAddress != address(0)) {
            _nestVoteAddress = nestVoteAddress;
        }
        if (nestQueryAddress != address(0)) {
            _nestQueryAddress = nestQueryAddress;
        }
        if (nnIncomeAddress != address(0)) {
            _nnIncomeAddress = nnIncomeAddress;
        }
        if (nTokenControllerAddress != address(0)) {
            _nTokenControllerAddress = nTokenControllerAddress;
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    function getBuiltinAddress() override external view returns (
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
    ) {
        return (
            _nestTokenAddress,
            _nestNodeAddress,
            _nestLedgerAddress,
            _nestMiningAddress,
            _ntokenMiningAddress,
            _nestPriceFacadeAddress,
            _nestVoteAddress,
            _nestQueryAddress,
            _nnIncomeAddress,
            _nTokenControllerAddress
        );
    }

    
    
    function getNestTokenAddress() override external view returns (address) { return _nestTokenAddress; }

    
    
    function getNestNodeAddress() override external view returns (address) { return _nestNodeAddress; }

    
    
    function getNestLedgerAddress() override external view returns (address) { return _nestLedgerAddress; }

    
    
    function getNestMiningAddress() override external view returns (address) { return _nestMiningAddress; }

    
    
    function getNTokenMiningAddress() override external view returns (address) { return _ntokenMiningAddress; }

    
    
    function getNestPriceFacadeAddress() override external view returns (address) { return _nestPriceFacadeAddress; }

    
    
    function getNestVoteAddress() override external view returns (address) { return _nestVoteAddress; }

    
    
    function getNestQueryAddress() override external view returns (address) { return _nestQueryAddress; }

    
    
    function getNnIncomeAddress() override external view returns (address) { return _nnIncomeAddress; }

    
    
    function getNTokenControllerAddress() override external view returns (address) { return _nTokenControllerAddress; }

    
    
    
    function registerAddress(string memory key, address addr) override external onlyGovernance {
        _registeredAddress[key] = addr;
    }

    
    
    
    function checkAddress(string memory key) override external view returns (address) {
        return _registeredAddress[key];
    }
}

// File: contracts\NestGovernance.sol


contract NestGovernance is NestMapping, INestGovernance {

    // constructor() {
    //     _governance = address(this);
    //     _governanceMapping[msg.sender] = GovernanceInfo(msg.sender, uint96(0xFFFFFFFFFFFFFFFFFFFFFFFF));
    // }

    
    
    function initialize(address nestGovernanceAddress) override public {

        // While initialize NestGovernance, nestGovernanceAddress is address(this),
        // So must let nestGovernanceAddress to 0
        require(nestGovernanceAddress == address(0), "NestGovernance:!address");

        // nestGovernanceAddress is address(this)
        super.initialize(address(this));

        // Add msg.sender to governance
        _governanceMapping[msg.sender] = GovernanceInfo(msg.sender, uint96(0xFFFFFFFFFFFFFFFFFFFFFFFF));
    }

    
    struct GovernanceInfo {
        address addr;
        uint96 flag;
    }

    
    mapping(address=>GovernanceInfo) _governanceMapping;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) override external onlyGovernance {
        
        if (flag > 0) {
            _governanceMapping[addr] = GovernanceInfo(addr, uint96(flag));
        } else {
            _governanceMapping[addr] = GovernanceInfo(address(0), uint96(0));
        }
    }

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) override external view returns (uint) {
        return _governanceMapping[addr].flag;
    }

    
    
    
    
    function checkGovernance(address addr, uint flag) override public view returns (bool) {
        return _governanceMapping[addr].flag > flag;
    }

    
    
    
    function checkOwners(address addr) external view returns (bool) {
        return checkGovernance(addr, 0);
    }
}