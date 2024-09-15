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

// File: contracts\interface\INestPriceFacade.sol


interface INestPriceFacade {
    
    
    struct Config {

        // Single query fee（0.0001 ether, DIMI_ETHER). 100
        uint16 singleFee;

        // Double query fee（0.0001 ether, DIMI_ETHER). 100
        uint16 doubleFee;

        // The normal state flag of the call address. 0
        uint8 normalFlag;
    }

    
    
    function setConfig(Config memory config) external;

    
    
    function getConfig() external view returns (Config memory);

    
    
    
    function setAddressFlag(address addr, uint flag) external;

    
    
    
    function getAddressFlag(address addr) external view returns(uint);

    
    
    
    function setNestQuery(address tokenAddress, address nestQueryAddress) external;

    
    
    
    function getNestQuery(address tokenAddress) external view returns (address);

    
    
    
    
    
    function triggeredPrice(address tokenAddress, address paybackAddress) external payable returns (uint blockNumber, uint price);

    
    
    
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447,
    ///         it means that the volatility has exceeded the range that can be expressed
    function triggeredPriceInfo(address tokenAddress, address paybackAddress) external payable returns (uint blockNumber, uint price, uint avgPrice, uint sigmaSQ);

    
    
    
    
    
    
    function findPrice(address tokenAddress, uint height, address paybackAddress) external payable returns (uint blockNumber, uint price);

    
    
    
    
    
    function latestPrice(address tokenAddress, address paybackAddress) external payable returns (uint blockNumber, uint price);

    
    
    
    
    
    function lastPriceList(address tokenAddress, uint count, address paybackAddress) external payable returns (uint[] memory);

    
    
    
    
    
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447,
    ///         it means that the volatility has exceeded the range that can be expressed
    function latestPriceAndTriggeredPriceInfo(address tokenAddress, address paybackAddress) 
    external 
    payable 
    returns (
        uint latestPriceBlockNumber, 
        uint latestPriceValue,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );

    
    
    
    
    
    
    
    function triggeredPrice2(address tokenAddress, address paybackAddress) external payable returns (uint blockNumber, uint price, uint ntokenBlockNumber, uint ntokenPrice);

    
    
    
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447, 
    ///         it means that the volatility has exceeded the range that can be expressed
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447,
    ///         it means that the volatility has exceeded the range that can be expressed
    function triggeredPriceInfo2(address tokenAddress, address paybackAddress) external payable returns (uint blockNumber, uint price, uint avgPrice, uint sigmaSQ, uint ntokenBlockNumber, uint ntokenPrice, uint ntokenAvgPrice, uint ntokenSigmaSQ);

    
    
    
    
    
    
    
    function latestPrice2(address tokenAddress, address paybackAddress) external payable returns (uint blockNumber, uint price, uint ntokenBlockNumber, uint ntokenPrice);
}

// File: contracts\interface\INestRedeeming.sol


interface INestRedeeming {

    
    struct Config {

        // Redeem activate threshold, when the circulation of token exceeds this threshold, 
        // activate redeem (Unit: 10000 ether). 500 
        uint32 activeThreshold;

        // The number of nest redeem per block. 1000
        uint16 nestPerBlock;

        // The maximum number of nest in a single redeem. 300000
        uint32 nestLimit;

        // The number of ntoken redeem per block. 10
        uint16 ntokenPerBlock;

        // The maximum number of ntoken in a single redeem. 3000
        uint32 ntokenLimit;

        // Price deviation limit, beyond this upper limit stop redeem (10000 based). 500
        uint16 priceDeviationLimit;
    }

    
    
    function setConfig(Config memory config) external;

    
    
    function getConfig() external view returns (Config memory);

    
    
    
    
    
    function redeem(address ntokenAddress, uint amount, address paybackAddress) external payable;

    
    
    function quotaOf(address ntokenAddress) external view returns (uint);
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

// File: contracts\NestRedeeming.sol


contract NestRedeeming is NestBase, INestRedeeming {

    // 
    // constructor(address nestTokenAddress) {
    //     NEST_TOKEN_ADDRESS = nestTokenAddress;
    // }

    
    struct GovernanceInfo {
        address addr;
        uint96 flag;
    }

    
    struct RedeemInfo {
        
        // Redeem quota consumed
        // block.number * quotaPerBlock - quota
        uint128 quota;

        // Redeem threshold by circulation of ntoken, when this value equal to config.activeThreshold, 
        // redeeming is enabled without checking the circulation of the ntoken
        // When config.activeThreshold modified, it will check whether repo is enabled again according to the circulation
        uint32 threshold;
    }

    // Configuration
    Config _config;

    // Redeeming ledger
    mapping(address=>RedeemInfo) _redeemLedger;

    address _nestLedgerAddress;
    address _nestPriceFacadeAddress;

    
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    
    function update(address nestGovernanceAddress) override public {
        super.update(nestGovernanceAddress);

        (
            //address nestTokenAddress
            ,
            //address nestNodeAddress
            ,
            //address nestLedgerAddress
            _nestLedgerAddress, 
            //address nestMiningAddress
            ,
            //address ntokenMiningAddress
            ,
            //address nestPriceFacadeAddress
            _nestPriceFacadeAddress, 
            //address nestVoteAddress
            ,
            //address nestQueryAddress
            , 
            //address nnIncomeAddress
            ,
            //address nTokenControllerAddress
              
        ) = INestGovernance(nestGovernanceAddress).getBuiltinAddress();
    }

    
    
    function setConfig(Config memory config) override external onlyGovernance {
        _config = config;
    }

    
    
    function getConfig() override external view returns (Config memory) {
        return _config;
    }

    
    
    
    
    
    function redeem(address ntokenAddress, uint amount, address paybackAddress) override external payable {
        
        // 1. Load configuration
        Config memory config = _config;

        // 2. Check redeeming stat
        RedeemInfo storage redeemInfo = _redeemLedger[ntokenAddress];
        RedeemInfo memory ri = redeemInfo;
        if (ri.threshold != config.activeThreshold) {
            // Since nest has started redeeming and has a large circulation, we will not check its circulation separately here
            require(IERC20(ntokenAddress).totalSupply() >= uint(config.activeThreshold) * 10000 ether, "NestRedeeming:!totalSupply");
            redeemInfo.threshold = config.activeThreshold;
        }

        // 3. Query price
        (
            /* uint latestPriceBlockNumber */, 
            uint latestPriceValue,
            /* uint triggeredPriceBlockNumber */,
            /* uint triggeredPriceValue */,
            uint triggeredAvgPrice,
            /* uint triggeredSigma */
        ) = INestPriceFacade(_nestPriceFacadeAddress).latestPriceAndTriggeredPriceInfo { value: msg.value } (ntokenAddress, paybackAddress);

        // 4. Calculate the number of eth that can be exchanged for redeem
        uint value = amount * 1 ether / latestPriceValue;

        // 5. Calculate redeem quota
        (uint quota, uint scale) = _quotaOf(config, ri, ntokenAddress);
        redeemInfo.quota = uint128(scale - (quota - amount));

        // 6. Check the redeeming amount and price deviation
        // This check is not required
        // require(quota >= amount, "NestRedeeming:!amount");
        require(
            latestPriceValue * 10000 <= triggeredAvgPrice * (10000 + uint(config.priceDeviationLimit)) && 
            latestPriceValue * 10000 >= triggeredAvgPrice * (10000 - uint(config.priceDeviationLimit)), "NestRedeeming:!price");
        
        // 7. Ntoken transferred to redeem
        address nestLedgerAddress = _nestLedgerAddress;
        TransferHelper.safeTransferFrom(ntokenAddress, msg.sender, nestLedgerAddress, amount);
        
        // 8. Settlement
        // If a token is not a real token, it should also have no funds in the account book and cannot complete the settlement. 
        // Therefore, it is no longer necessary to check whether the token is a legal token
        INestLedger(nestLedgerAddress).pay(ntokenAddress, address(0), msg.sender, value);
    }

    
    
    function quotaOf(address ntokenAddress) override public view returns (uint) {

        // 1. Load configuration
        Config memory config = _config;

        // 2. Check redeem state
        RedeemInfo storage redeemInfo = _redeemLedger[ntokenAddress];
        RedeemInfo memory ri = redeemInfo;
        if (ri.threshold != config.activeThreshold) {
            // Since nest has started redeeming and has a large circulation, we will not check its circulation separately here
            if (IERC20(ntokenAddress).totalSupply() < uint(config.activeThreshold) * 10000 ether) 
            {
                return 0;
            }
        }

        // 3. Calculate redeem quota
        (uint quota, ) = _quotaOf(config, ri, ntokenAddress);
        return quota;
    }

    // Calculate redeem quota
    function _quotaOf(Config memory config, RedeemInfo memory ri, address ntokenAddress) private view returns (uint quota, uint scale) {

        // Calculate redeem quota
        uint quotaPerBlock;
        uint quotaLimit;
        // nest config
        if (ntokenAddress == NEST_TOKEN_ADDRESS) {
            quotaPerBlock = uint(config.nestPerBlock);
            quotaLimit = uint(config.nestLimit);
        } 
        // ntoken config
        else {
            quotaPerBlock = uint(config.ntokenPerBlock);
            quotaLimit = uint(config.ntokenLimit);
        }
        // Calculate
        scale = block.number * quotaPerBlock * 1 ether;
        quota = scale - ri.quota;
        if (quota > quotaLimit * 1 ether) {
            quota = quotaLimit * 1 ether;
        }
    }
}