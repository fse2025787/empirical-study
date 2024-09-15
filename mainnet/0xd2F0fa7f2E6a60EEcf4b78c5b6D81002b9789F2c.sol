// SPDX-License-Identifier: ISC


// 
pragma solidity ^0.8.17;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== Timelock2Step ===========================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// ====================================================================

abstract contract Timelock2Step {
    
    address public pendingTimelockAddress;

    
    address public timelockAddress;

    constructor() {
        timelockAddress = msg.sender;
    }

    
    error OnlyTimelock();

    
    error OnlyPendingTimelock();

    
    
    
    event TimelockTransferStarted(address indexed previousTimelock, address indexed newTimelock);

    
    
    
    event TimelockTransferred(address indexed previousTimelock, address indexed newTimelock);

    
    
    function _isSenderTimelock() internal view returns (bool) {
        return msg.sender == timelockAddress;
    }

    
    function _requireTimelock() internal view {
        if (msg.sender != timelockAddress) revert OnlyTimelock();
    }

    
    
    function _isSenderPendingTimelock() internal view returns (bool) {
        return msg.sender == pendingTimelockAddress;
    }

    
    function _requirePendingTimelock() internal view {
        if (msg.sender != pendingTimelockAddress) revert OnlyPendingTimelock();
    }

    
    
    
    function _transferTimelock(address _newTimelock) internal {
        pendingTimelockAddress = _newTimelock;
        emit TimelockTransferStarted(timelockAddress, _newTimelock);
    }

    
    
    function _acceptTransferTimelock() internal {
        pendingTimelockAddress = address(0);
        _setTimelock(msg.sender);
    }

    
    
    
    function _setTimelock(address _newTimelock) internal {
        emit TimelockTransferred(timelockAddress, _newTimelock);
        timelockAddress = _newTimelock;
    }

    
    
    
    function transferTimelock(address _newTimelock) external virtual {
        _requireTimelock();
        _transferTimelock(_newTimelock);
    }

    
    
    function acceptTransferTimelock() external virtual {
        _requirePendingTimelock();
        _acceptTransferTimelock();
    }

    
    
    function renounceTimelock() external virtual {
        _requireTimelock();
        _requirePendingTimelock();
        _transferTimelock(address(0));
        _setTimelock(address(0));
    }
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// 
pragma solidity ^0.8.17;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== FraxLendPair ============================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Author
// Drake Evans: https://github.com/DrakeEvans

// Reviewers

// ====================================================================










contract SfrxEthDualOracleChainlinkUniV3 is Timelock2Step {
    uint128 public constant ORACLE_PRECISION = 1e18;
    address public immutable BASE_TOKEN;
    address public immutable QUOTE_TOKEN;

    // Chainlink Config
    address public immutable CHAINLINK_MULTIPLY_ADDRESS;
    address public immutable CHAINLINK_DIVIDE_ADDRESS;
    uint256 public immutable CHAINLINK_NORMALIZATION;
    uint256 public maxOracleDelay;

    // Uni V3 Data
    address public immutable UNI_V3_PAIR_ADDRESS;
    uint32 public immutable TWAP_DURATION;

    // SFRX DATA
    ISfrxEth public constant SFRXETH_ERC4626 = ISfrxEth(0xac3E018457B222d93114458476f3E3416Abbe38F);
    uint256 public constant SFRXETH_PRECISION = 1e18;
    uint256 public constant TWAP_PRECISION = 1e18;

    // Config Data
    uint8 internal constant DECIMALS = 18;
    string public name;
    uint256 public oracleType = 2;

    // events
    event SetMaxOracleDelay(uint256 _oldMaxOracleDelay, uint256 _newMaxOracleDelay);

    constructor(
        address _baseToken,
        address _quoteToken,
        address _chainlinkMultiplyAddress,
        address _chainlinkDivideAddress,
        uint256 _maxOracleDelay,
        address _uniV3PairAddress,
        uint32 _twapDuration,
        address _timeLockAddress,
        string memory _name
    ) Timelock2Step() {
        _setTimelock(_timeLockAddress);

        BASE_TOKEN = _baseToken;
        QUOTE_TOKEN = _quoteToken;
        CHAINLINK_MULTIPLY_ADDRESS = _chainlinkMultiplyAddress;
        CHAINLINK_DIVIDE_ADDRESS = _chainlinkDivideAddress;
        uint8 _multiplyDecimals = _chainlinkMultiplyAddress != address(0)
            ? AggregatorV3Interface(_chainlinkMultiplyAddress).decimals()
            : 0;
        uint8 _divideDecimals = _chainlinkDivideAddress != address(0)
            ? AggregatorV3Interface(_chainlinkDivideAddress).decimals()
            : 0;
        CHAINLINK_NORMALIZATION =
            10 **
                (18 +
                    _multiplyDecimals -
                    _divideDecimals +
                    IERC20Metadata(_baseToken).decimals() -
                    IERC20Metadata(_quoteToken).decimals());

        maxOracleDelay = _maxOracleDelay;

        UNI_V3_PAIR_ADDRESS = _uniV3PairAddress;
        if (_twapDuration == 0) revert("DURATION == 0");
        TWAP_DURATION = _twapDuration;

        name = _name;
    }

    
    
    
    function setMaxOracleDelay(uint256 _newMaxOracleDelay) external {
        _requireTimelock();
        emit SetMaxOracleDelay(maxOracleDelay, _newMaxOracleDelay);
        maxOracleDelay = _newMaxOracleDelay;
    }

    function _getChainlinkPrice() internal view returns (bool _isBadData, uint256 _price) {
        _price = uint256(1e36);

        if (CHAINLINK_MULTIPLY_ADDRESS != address(0)) {
            (, int256 _answer, , uint256 _updatedAt, ) = AggregatorV3Interface(CHAINLINK_MULTIPLY_ADDRESS)
                .latestRoundData();

            // If data is stale or negative, set bad data to true and return
            if (_answer <= 0 || (block.timestamp - _updatedAt > maxOracleDelay)) {
                _isBadData = true;
                return (_isBadData, _price);
            }
            _price = _price * uint256(_answer);
        }

        if (CHAINLINK_DIVIDE_ADDRESS != address(0)) {
            (, int256 _answer, , uint256 _updatedAt, ) = AggregatorV3Interface(CHAINLINK_DIVIDE_ADDRESS)
                .latestRoundData();

            // If data is stale or negative, set bad data to true and return
            if (_answer <= 0 || (block.timestamp - _updatedAt > maxOracleDelay)) {
                _isBadData = true;
                return (_isBadData, _price);
            }
            _price = _price / uint256(_answer);
        }

        // return price as ratio of Collateral/Asset including decimal differences
        // CHAINLINK_NORMALIZATION = 10**(18 + asset.decimals() - collateral.decimals() + multiplyOracle.decimals() - divideOracle.decimals())
        _price = _price / CHAINLINK_NORMALIZATION;
    }

    
    
    
    
    function getPrices() external view returns (bool _isBadData, uint256 _priceLow, uint256 _priceHigh) {
        address[] memory _pools = new address[](1);
        _pools[0] = UNI_V3_PAIR_ADDRESS;
        uint256 _price1 = (SFRXETH_PRECISION *
            IStaticOracle(0xB210CE856631EeEB767eFa666EC7C1C57738d438).quoteSpecificPoolsWithTimePeriod(
                ORACLE_PRECISION,
                BASE_TOKEN,
                QUOTE_TOKEN,
                _pools,
                TWAP_DURATION
            )) / SFRXETH_ERC4626.pricePerShare();

        uint256 _price2;
        (_isBadData, _price2) = _getChainlinkPrice();

        // If bad data return price1 for both, else set high to higher price and low to lower price
        _priceLow = _isBadData || _price1 < _price2 ? _price1 : _price2;
        _priceHigh = _isBadData || _price1 > _price2 ? _price1 : _price2;
    }

    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }
}

// 
pragma solidity >=0.8.17;

// NOTE: This file generated from sfrxEth contract at https://etherscan.io/address/0xac3e018457b222d93114458476f3e3416abbe38f#code
interface ISfrxEth {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function allowance(address, address) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function asset() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function convertToAssets(uint256 shares) external view returns (uint256);

    function convertToShares(uint256 assets) external view returns (uint256);

    function decimals() external view returns (uint8);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function depositWithSignature(
        uint256 assets,
        address receiver,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 shares);

    function lastRewardAmount() external view returns (uint192);

    function lastSync() external view returns (uint32);

    function maxDeposit(address) external view returns (uint256);

    function maxMint(address) external view returns (uint256);

    function maxRedeem(address owner) external view returns (uint256);

    function maxWithdraw(address owner) external view returns (uint256);

    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    function name() external view returns (string memory);

    function nonces(address) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

    function previewDeposit(uint256 assets) external view returns (uint256);

    function previewMint(uint256 shares) external view returns (uint256);

    function previewRedeem(uint256 shares) external view returns (uint256);

    function previewWithdraw(uint256 assets) external view returns (uint256);

    function pricePerShare() external view returns (uint256);

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    function rewardsCycleEnd() external view returns (uint32);

    function rewardsCycleLength() external view returns (uint32);

    function symbol() external view returns (string memory);

    function syncRewards() external;

    function totalAssets() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
}

// 
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// 

pragma solidity >=0.7.6 <0.9.0;





interface IStaticOracle {
  
  
  
  function UNISWAP_V3_FACTORY() external view returns (IUniswapV3Factory);

  
  
  
  function CARDINALITY_PER_MINUTE() external view returns (uint8);

  
  
  function supportedFeeTiers() external view returns (uint24[] memory);

  
  
  
  function isPairSupported(address tokenA, address tokenB) external view returns (bool);

  
  
  
  function getAllPoolsForPair(address tokenA, address tokenB) external view returns (address[] memory);

  
  
  
  
  
  
  
  
  
  function quoteAllAvailablePoolsWithTimePeriod(
    uint128 baseAmount,
    address baseToken,
    address quoteToken,
    uint32 period
  ) external view returns (uint256 quoteAmount, address[] memory queriedPools);

  
  
  /// is not prepared/configured correctly for the given period
  
  
  
  
  
  
  
  function quoteSpecificFeeTiersWithTimePeriod(
    uint128 baseAmount,
    address baseToken,
    address quoteToken,
    uint24[] calldata feeTiers,
    uint32 period
  ) external view returns (uint256 quoteAmount, address[] memory queriedPools);

  
  
  
  
  
  
  
  
  function quoteSpecificPoolsWithTimePeriod(
    uint128 baseAmount,
    address baseToken,
    address quoteToken,
    address[] calldata pools,
    uint32 period
  ) external view returns (uint256 quoteAmount);

  
  
  
  
  
  
  function prepareAllAvailablePoolsWithTimePeriod(
    address tokenA,
    address tokenB,
    uint32 period
  ) external returns (address[] memory preparedPools);

  
  
  
  
  
  
  
  function prepareSpecificFeeTiersWithTimePeriod(
    address tokenA,
    address tokenB,
    uint24[] calldata feeTiers,
    uint32 period
  ) external returns (address[] memory preparedPools);

  
  
  
  function prepareSpecificPoolsWithTimePeriod(address[] calldata pools, uint32 period) external;

  
  
  
  
  
  
  function prepareAllAvailablePoolsWithCardinality(
    address tokenA,
    address tokenB,
    uint16 cardinality
  ) external returns (address[] memory preparedPools);

  
  
  
  
  
  
  
  function prepareSpecificFeeTiersWithCardinality(
    address tokenA,
    address tokenB,
    uint24[] calldata feeTiers,
    uint16 cardinality
  ) external returns (address[] memory preparedPools);

  
  
  
  function prepareSpecificPoolsWithCardinality(address[] calldata pools, uint16 cardinality) external;

  
  
  
  function addNewFeeTier(uint24 feeTier) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3Factory {
    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    
    
    
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    
    
    
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    
    
    
    function owner() external view returns (address);

    
    
    
    
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    
    
    
    
    
    
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    
    
    
    
    
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    
    
    
    function setOwner(address _owner) external;

    
    
    
    
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}