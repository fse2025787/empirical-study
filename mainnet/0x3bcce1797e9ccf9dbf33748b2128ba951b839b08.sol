// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-06-06
*/

// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File contracts/custom/ChainParameter.sol

// 

pragma solidity ^0.8.6;


contract ChainParameter {

    // Block time. ethereum 14 seconds, BSC 3 seconds, polygon 2.2 seconds
    uint constant BLOCK_TIME = 14;

    // Minimal exercise block period. 180000
    uint constant MIN_PERIOD = 180000;

    uint constant MIN_EXERCISE_BLOCK = 180000;
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

//MIT

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


// File contracts/libs/TransferHelper.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value,gas:5000}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/interfaces/IHedgeDAO.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;


interface IHedgeDAO {

    
    
    
    event ApplicationChanged(address addr, uint flag);
    
    
    
    
    function setApplication(address addr, uint flag) external;

    
    
    
    function checkApplication(address addr) external view returns (uint);

    
    
    function addETHReward(address pool) external payable;

    
    
    function totalETHRewards(address pool) external view returns (uint);

    
    
    
    
    
    function settle(address pool, address tokenAddress, address to, uint value) external payable;
}


// File contracts/interfaces/IHedgeMapping.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;


interface IHedgeMapping {

    
    
    
    
    
    
    
    function setBuiltinAddress(
        address dcuToken,
        address hedgeDAO,
        address hedgeOptions,
        address hedgeFutures,
        address hedgeVaultForStaking,
        address nestPriceFacade
    ) external;

    
    
    
    
    
    
    
    function getBuiltinAddress() external view returns (
        address dcuToken,
        address hedgeDAO,
        address hedgeOptions,
        address hedgeFutures,
        address hedgeVaultForStaking,
        address nestPriceFacade
    );

    
    
    function getDCUTokenAddress() external view returns (address);

    
    
    function getHedgeDAOAddress() external view returns (address);

    
    
    function getHedgeOptionsAddress() external view returns (address);

    
    
    function getHedgeFuturesAddress() external view returns (address);

    
    
    function getHedgeVaultForStakingAddress() external view returns (address);

    
    
    function getNestPriceFacade() external view returns (address);

    
    
    
    function registerAddress(string calldata key, address addr) external;

    
    
    
    function checkAddress(string calldata key) external view returns (address);
}


// File contracts/interfaces/IHedgeGovernance.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;

interface IHedgeGovernance is IHedgeMapping {

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    
    
    
    /// to pass the check
    
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File contracts/HedgeBase.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;

contract HedgeBase {

    
    address public _governance;

    
    
    function initialize(address governance) public virtual {
        require(_governance == address(0), "Hedge:!initialize");
        _governance = governance;
    }

    
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || IHedgeGovernance(governance).checkGovernance(msg.sender, 0), "Hedge:!gov");
        _governance = newGovernance;
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(IHedgeGovernance(_governance).checkGovernance(msg.sender, 0), "Hedge:!gov");
        _;
    }
}


// File contracts/custom/HedgeFrequentlyUsed.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;

contract HedgeFrequentlyUsed is HedgeBase {

    // Address of DCU contract
    address constant DCU_TOKEN_ADDRESS = 0xf56c6eCE0C0d6Fbb9A53282C0DF71dBFaFA933eF;

    // Address of NestOpenPrice contract
    address constant NEST_OPEN_PRICE = 0xE544cF993C7d477C7ef8E91D28aCA250D135aa03;
    
    // USDT base
    uint constant USDT_BASE = 1 ether;
}


// File contracts/interfaces/INestBatchPrice2.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;


interface INestBatchPrice2 {

    
    
    
    
    
    function triggeredPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        address payback
    ) external payable returns (uint[] memory prices);

    
    
    
    
    
    /// i * 4 + 2 is the ith average price and i * 4 + 3 is the ith volatility
    function triggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        address payback
    ) external payable returns (uint[] memory prices);

    
    
    
    
    
    
    function findPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        uint height, 
        address payback
    ) external payable returns (uint[] memory prices);

    
    
    
    
    
    
    /// the price results of group i quotation pairs
    function lastPriceList(
        uint channelId, 
        uint[] calldata pairIndices, 
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);

    
    
    
    
    
    
    /// and the last four are: trigger price block number, trigger price, average price and volatility
    function lastPriceListAndTriggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);
}


// File contracts/custom/FortPriceAdapter.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;

contract FortPriceAdapter is HedgeFrequentlyUsed {
    
    // token configuration
    struct TokenConfig {
        // The channelId for call nest price
        uint16 channelId;
        // The pairIndex for call nest price
        uint16 pairIndex;

        // SigmaSQ for token
        uint64 sigmaSQ;
        // MIU_LONG for token
        uint64 miuLong;
        // MIU_SHORT for token
        uint64 miuShort;
    }

    // Post unit: 2000usd
    uint constant POST_UNIT = 2000 * USDT_BASE;

    function _pairIndices(uint pairIndex) private pure returns (uint[] memory pairIndices) {
        pairIndices = new uint[](1);
        pairIndices[0] = pairIndex;
    }

    // Query latest 2 price
    function _lastPriceList(
        TokenConfig memory tokenConfig, 
        uint fee, 
        address payback
    ) internal returns (uint[] memory prices) {
        prices = INestBatchPrice2(NEST_OPEN_PRICE).lastPriceList {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), 2, payback);

        prices[1] = _toUSDTPrice(prices[1]);
        prices[3] = _toUSDTPrice(prices[3]);
    }

    // Query latest price
    function _latestPrice(
        TokenConfig memory tokenConfig, 
        uint fee, 
        address payback
    ) internal returns (uint oraclePrice) {
        uint[] memory prices = INestBatchPrice2(NEST_OPEN_PRICE).lastPriceList {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), 1, payback);

        oraclePrice = _toUSDTPrice(prices[1]);
    }

    // Find price by blockNumber
    function _findPrice(
        TokenConfig memory tokenConfig, 
        uint blockNumber, 
        uint fee, 
        address payback
    ) internal returns (uint oraclePrice) {
        uint[] memory prices = INestBatchPrice2(NEST_OPEN_PRICE).findPrice {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), blockNumber, payback);

        oraclePrice = _toUSDTPrice(prices[1]);
    }

    // Convert to usdt based price
    function _toUSDTPrice(uint rawPrice) internal pure returns (uint) {
        return POST_UNIT * 1 ether / rawPrice;
    }
}


// File contracts/FortFuturesFix.sol

//GPL-3.0-or-later

pragma solidity ^0.8.6;

contract FortFuturesFix is ChainParameter, HedgeFrequentlyUsed, FortPriceAdapter {

    
    struct Account {
        // Amount of margin
        uint128 balance;
        // Base price
        uint64 basePrice;
        // Base block
        uint32 baseBlock;
    }

    
    struct FutureInfo {
        // Target token address
        address tokenAddress; 
        // Lever of future
        uint32 lever;
        // true: call, false: put
        bool orientation;

        // Token index in _tokenConfigs
        uint16 tokenIndex;
        
        // Account mapping
        mapping(address=>Account) accounts;
    }

    // Minimum balance quantity. If the balance is less than this value, it will be liquidated
    uint constant MIN_VALUE = 10 ether;

    // Mapping from composite key to future index
    mapping(uint=>uint) _futureMapping;

    // PlaceHolder
    mapping(address=>uint) _bases;

    // Future array
    FutureInfo[] _futures;

    // token to index mapping
    mapping(address=>uint) _tokenMapping;

    // Token configs
    TokenConfig[] _tokenConfigs;

    constructor() {
    }

    
    
    
    
    function balanceOf(uint index, uint oraclePrice, address addr) external view returns (uint) {
        FutureInfo storage fi = _futures[index];
        Account memory account = fi.accounts[addr];
        return _balanceOf(
            _tokenConfigs[fi.tokenIndex],
            uint(account.balance), 
            _decodeFloat(account.basePrice), 
            uint(account.baseBlock),
            oraclePrice, 
            fi.orientation, 
            uint(fi.lever)
        );
    }

    
    
    
    function fix(uint index, address addr) external onlyGovernance {
        Account storage account = _futures[index].accounts[addr];
        account.basePrice = _encodeFloat(_decodeFloat(account.basePrice) * 10e12);
    }

    
    
    
    function _encodeFloat(uint value) private pure returns (uint64) {

        uint exponent = 0; 
        while (value > 0x3FFFFFFFFFFFFFF) {
            value >>= 4;
            ++exponent;
        }
        return uint64((value << 6) | exponent);
    }

    
    
    
    function _decodeFloat(uint64 floatValue) private pure returns (uint) {
        return (uint(floatValue) >> 6) << ((uint(floatValue) & 0x3F) << 2);
    }

    // Calculate net worth
    function _balanceOf(
        TokenConfig memory tokenConfig,
        uint balance,
        uint basePrice,
        uint baseBlock,
        uint oraclePrice, 
        bool ORIENTATION, 
        uint LEVER
    ) private view returns (uint) {

        if (balance > 0) {
            uint left;
            uint right;
            // Call
            if (ORIENTATION) {
                left = balance + (LEVER << 64) * balance * oraclePrice / basePrice
                        / _expMiuT(uint(tokenConfig.miuLong), baseBlock);
                right = balance * LEVER;
            } 
            // Put
            else {
                left = balance * (1 + LEVER);
                right = (LEVER << 64) * balance * oraclePrice / basePrice 
                        / _expMiuT(uint(tokenConfig.miuShort), baseBlock);
            }

            if (left > right) {
                balance = left - right;
            } else {
                balance = 0;
            }
        }

        return balance;
    }

    // Calculate e^μT
    function _expMiuT(uint miu, uint baseBlock) private view returns (uint) {
        // return _toUInt(ABDKMath64x64.exp(
        //     _toInt128((orientation ? MIU_LONG : MIU_SHORT) * (block.number - baseBlock) * BLOCK_TIME)
        // ));

        // Using approximate algorithm: x*(1+rt)
        return miu * (block.number - baseBlock) * BLOCK_TIME + 0x10000000000000000;
    }
}