// SPDX-License-Identifier: BUSL-1.1


// 
pragma solidity >=0.7.6 <0.9.0;


interface IPriceProvider {
    
    /// It unifies all tokens decimal to 18, examples:
    /// - if asses == quote it returns 1e18
    /// - if asset is USDC and quote is ETH and ETH costs ~$3300 then it returns ~0.0003e18 WETH per 1 USDC
    
    
    function getPrice(address _asset) external view returns (uint256 price);

    
    /// Some providers implementations need time to "build" buffer for TWAP price,
    /// so price may not be available yet but this method will return true.
    
    
    function assetSupported(address _asset) external view returns (bool);

    
    
    function quoteToken() external view returns (address);

    
    
    /// but this should NOT be treated as security check
    
    function priceProviderPing() external pure returns (bytes4);
}

// 
pragma solidity >=0.7.6 <0.9.0;








/// like Chainlink to calculate TWAP prices for assets. Each price provider should support a single price source
/// and multiple assets.
abstract contract PriceProvider is IPriceProvider {
    
    IPriceProvidersRepository public immutable priceProvidersRepository;

    
    address public immutable override quoteToken;

    modifier onlyManager() {
        if (priceProvidersRepository.manager() != msg.sender) revert("OnlyManager");
        _;
    }

    
    constructor(IPriceProvidersRepository _priceProvidersRepository) {
        if (
            !Ping.pong(_priceProvidersRepository.priceProvidersRepositoryPing)            
        ) {
            revert("InvalidPriceProviderRepository");
        }

        priceProvidersRepository = _priceProvidersRepository;
        quoteToken = _priceProvidersRepository.quoteToken();
    }

    
    function priceProviderPing() external pure override returns (bytes4) {
        return this.priceProviderPing.selector;
    }

    function _revertBytes(bytes memory _errMsg, string memory _customErr) internal pure {
        if (_errMsg.length > 0) {
            assembly { // solhint-disable-line no-inline-assembly
                revert(add(32, _errMsg), mload(_errMsg))
            }
        }

        revert(_customErr);
    }
}
// 
pragma solidity 0.8.13;







contract ChainlinkV3PriceProvider is PriceProvider {
    using SafeMath for uint256;

    struct AssetData {
        // Time threshold to invalidate stale prices
        uint256 heartbeat;
        // If true, we bypass the aggregator and consult the fallback provider directly
        bool forceFallback;
        // If true, the aggregator returns price in USD, so we need to convert to QUOTE
        bool convertToQuote;
        // Chainlink aggregator proxy
        AggregatorV3Interface aggregator;
        // Provider used if the aggregator's price is invalid or if it became disabled
        IPriceProvider fallbackProvider;
    }

    
    AggregatorV3Interface private immutable _QUOTE_AGGREGATOR; // solhint-disable-line var-name-mixedcase

    
    uint8 private immutable _QUOTE_AGGREGATOR_DECIMALS; // solhint-disable-line var-name-mixedcase

    
    // solhint-disable-next-line var-name-mixedcase
    uint256 private immutable _MAX_PRICE_DIFF = type(uint256).max / (100 * EMERGENCY_PRECISION);
    
    // @dev Precision to use for the EMERGENCY_THRESHOLD
    uint256 public constant EMERGENCY_PRECISION = 1e6;

    
    uint256 public constant EMERGENCY_THRESHOLD = 10 * EMERGENCY_PRECISION; // solhint-disable-line var-name-mixedcase

    
    uint8 private immutable _QUOTE_TOKEN_DECIMALS; // solhint-disable-line var-name-mixedcase

    
    address public emergencyManager;

    
    uint256 public quoteAggregatorHeartbeat;

    
    mapping(address => AssetData) public assetData;

    event NewAggregator(address indexed asset, AggregatorV3Interface indexed aggregator, bool convertToQuote);
    event NewFallbackPriceProvider(address indexed asset, IPriceProvider indexed fallbackProvider);
    event NewHeartbeat(address indexed asset, uint256 heartbeat);
    event NewQuoteAggregatorHeartbeat(uint256 heartbeat);
    event NewEmergencyManager(address indexed emergencyManager);
    event AggregatorDisabled(address indexed asset, AggregatorV3Interface indexed aggregator);

    error AggregatorDidNotChange();
    error AggregatorPriceNotAvailable();
    error AssetNotSupported();
    error EmergencyManagerDidNotChange();
    error EmergencyThresholdNotReached();
    error FallbackProviderAlreadySet();
    error FallbackProviderDidNotChange();
    error FallbackProviderNotSet();
    error HeartbeatDidNotChange();
    error InvalidAggregator();
    error InvalidAggregatorDecimals();
    error InvalidFallbackPriceProvider();
    error InvalidHeartbeat();
    error OnlyEmergencyManager();
    error QuoteAggregatorHeartbeatDidNotChange();

    modifier onlyAssetSupported(address _asset) {
        if (!assetSupported(_asset)) {
            revert AssetNotSupported();
        }

        _;
    }

    constructor(
        IPriceProvidersRepository _priceProvidersRepository,
        address _emergencyManager,
        AggregatorV3Interface _quoteAggregator,
        uint256 _quoteAggregatorHeartbeat
    ) PriceProvider(_priceProvidersRepository) {
        _setEmergencyManager(_emergencyManager);
        _QUOTE_TOKEN_DECIMALS = IERC20LikeV2(quoteToken).decimals();
        _QUOTE_AGGREGATOR = _quoteAggregator;
        _QUOTE_AGGREGATOR_DECIMALS = _quoteAggregator.decimals();
        quoteAggregatorHeartbeat = _quoteAggregatorHeartbeat;
    }

    
    function assetSupported(address _asset) public view override returns (bool) {
        AssetData storage data = assetData[_asset];

        // Asset is supported if:
        //     - the asset is the quote token
        //       OR
        //     - the aggregator address is defined AND
        //         - the aggregator is not disabled
        //           OR
        //         - the fallback is defined

        if (_asset == quoteToken) {
            return true;
        }

        if (address(data.aggregator) != address(0)) {
            return !data.forceFallback || address(data.fallbackProvider) != address(0);
        }

        return false;
    }

    
    function getPrice(address _asset) public view override returns (uint256) {
        address quote = quoteToken;

        if (_asset == quote) {
            return 10 ** _QUOTE_TOKEN_DECIMALS;
        }

        (bool success, uint256 price) = _getAggregatorPrice(_asset);

        return success ? price : _getFallbackPrice(_asset);
    }

    
    
    
    
    
    function setupAsset(
        address _asset,
        AggregatorV3Interface _aggregator,
        IPriceProvider _fallbackProvider,
        uint256 _heartbeat,
        bool _convertToQuote
    ) external onlyManager {
        // This has to be done first so that `_setAggregator` works
        _setHeartbeat(_asset, _heartbeat);

        if (!_setAggregator(_asset, _aggregator, _convertToQuote)) revert AggregatorDidNotChange();

        // We don't care if this doesn't change
        _setFallbackPriceProvider(_asset, _fallbackProvider);
    }

    
    
    
    function setAggregator(address _asset, AggregatorV3Interface _aggregator, bool _convertToQuote)
        external
        onlyManager
        onlyAssetSupported(_asset)
    {
        if (!_setAggregator(_asset, _aggregator, _convertToQuote)) revert AggregatorDidNotChange();
    }

    
    
    
    function setFallbackPriceProvider(address _asset, IPriceProvider _fallbackProvider)
        external
        onlyManager
        onlyAssetSupported(_asset)
    {
        if (!_setFallbackPriceProvider(_asset, _fallbackProvider)) {
            revert FallbackProviderDidNotChange();
        }
    }

    
    
    
    function setHeartbeat(address _asset, uint256 _heartbeat)
        external
        onlyManager
        onlyAssetSupported(_asset)
    {
        if (!_setHeartbeat(_asset, _heartbeat)) revert HeartbeatDidNotChange();
    }

    
    
    function setQuoteAggregatorHeartbeat(uint256 _heartbeat)
        external
        onlyManager
    {
        if (!_setQuoteAggregatorHeartbeat(_heartbeat)) revert QuoteAggregatorHeartbeatDidNotChange();
    }

    
    
    function setEmergencyManager(address _emergencyManager) external onlyManager {
        if (!_setEmergencyManager(_emergencyManager)) revert EmergencyManagerDidNotChange();
    }

    
    /// fallback provider. The only way to reenable the asset is by calling setupAsset or setAggregator again.
    /// Can only be called by the emergencyManager.
    
    function emergencyDisable(address _asset) external {
        if (msg.sender != emergencyManager) {
            revert OnlyEmergencyManager();
        }

        (bool success, uint256 price) = _getAggregatorPrice(_asset);

        if (!success) {
            revert AggregatorPriceNotAvailable();
        }

        uint256 fallbackPrice = _getFallbackPrice(_asset);

        uint256 diff;

        unchecked {
            // It is ok to uncheck because of the initial fallbackPrice >= price check
            diff = fallbackPrice >= price ? fallbackPrice - price : price - fallbackPrice;
        }

        if (diff > _MAX_PRICE_DIFF || (diff * 100 * EMERGENCY_PRECISION) / price < EMERGENCY_THRESHOLD) {
            revert EmergencyThresholdNotReached();
        }

        // Disable main aggregator, fallback stays enabled
        assetData[_asset].forceFallback = true;

        emit AggregatorDisabled(_asset, assetData[_asset].aggregator);
    }

    function getFallbackProvider(address _asset) external view returns (IPriceProvider) {
        return assetData[_asset].fallbackProvider;
    }

    function _getAggregatorPrice(address _asset) private view returns (bool success, uint256 price) {
        AssetData storage data = assetData[_asset];

        uint256 heartbeat = data.heartbeat;
        bool forceFallback = data.forceFallback;
        AggregatorV3Interface aggregator = data.aggregator;

        if (address(aggregator) == address(0)) revert AssetNotSupported();

        (
            /*uint80 roundID*/,
            int256 aggregatorPrice,
            /*uint256 startedAt*/,
            uint256 timestamp,
            /*uint80 answeredInRound*/
        ) = aggregator.latestRoundData();

        // If a valid price is returned and it was updated recently
        if (!forceFallback && _isValidPrice(aggregatorPrice, timestamp, heartbeat)) {
            uint256 result;

            if (data.convertToQuote) {
                // _toQuote performs decimal normalization internally
                result = _toQuote(uint256(aggregatorPrice));
            } else {
                uint8 aggregatorDecimals = aggregator.decimals();
                result = _normalizeWithDecimals(uint256(aggregatorPrice), aggregatorDecimals);
            }

            return (true, result);
        }

        return (false, 0);
    }

    function _getFallbackPrice(address _asset) private view returns (uint256) {
        IPriceProvider fallbackProvider = assetData[_asset].fallbackProvider;

        if (address(fallbackProvider) == address(0)) revert FallbackProviderNotSet();

        return fallbackProvider.getPrice(_asset);
    }

    function _setEmergencyManager(address _emergencyManager) private returns (bool changed) {
        if (_emergencyManager == emergencyManager) {
            return false;
        }

        emergencyManager = _emergencyManager;

        emit NewEmergencyManager(_emergencyManager);

        return true;
    }

    function _setAggregator(
        address _asset,
        AggregatorV3Interface _aggregator,
        bool _convertToQuote
    ) private returns (bool changed) {
        if (address(_aggregator) == address(0)) revert InvalidAggregator();

        AssetData storage data = assetData[_asset];

        if (data.aggregator == _aggregator && data.forceFallback == false) {
            return false;
        }

        // There doesn't seem to be a way to verify if this is a "valid" aggregator (other than getting the price)
        data.forceFallback = false;
        data.aggregator = _aggregator;

        (bool success,) = _getAggregatorPrice(_asset);

        if (!success) revert AggregatorPriceNotAvailable();

        if (_convertToQuote && _aggregator.decimals() != _QUOTE_AGGREGATOR_DECIMALS) {
            revert InvalidAggregatorDecimals();
        }

        // We want to always update this
        assetData[_asset].convertToQuote = _convertToQuote;

        emit NewAggregator(_asset, _aggregator, _convertToQuote);

        return true;
    }

    function _setFallbackPriceProvider(address _asset, IPriceProvider _fallbackProvider)
        private
        returns (bool changed)
    {
        if (_fallbackProvider == assetData[_asset].fallbackProvider) {
            return false;
        }

        assetData[_asset].fallbackProvider = _fallbackProvider;

        if (address(_fallbackProvider) != address(0)) {
            if (
                !priceProvidersRepository.isPriceProvider(_fallbackProvider) ||
                !_fallbackProvider.assetSupported(_asset) ||
                _fallbackProvider.quoteToken() != quoteToken
            ) {
                revert InvalidFallbackPriceProvider();
            }

            // Make sure it doesn't revert
            _getFallbackPrice(_asset);
        }

        emit NewFallbackPriceProvider(_asset, _fallbackProvider);

        return true;
    }

    function _setHeartbeat(address _asset, uint256 _heartbeat) private returns (bool changed) {
        // Arbitrary limit, Chainlink's threshold is always less than a day
        if (_heartbeat > 2 days) revert InvalidHeartbeat();

        if (_heartbeat == assetData[_asset].heartbeat) {
            return false;
        }

        assetData[_asset].heartbeat = _heartbeat;

        emit NewHeartbeat(_asset, _heartbeat);

        return true;
    }

    function _setQuoteAggregatorHeartbeat(uint256 _heartbeat) private returns (bool changed) {
        // Arbitrary limit, Chainlink's threshold is always less than a day
        if (_heartbeat > 2 days) revert InvalidHeartbeat();

        if (_heartbeat == quoteAggregatorHeartbeat) {
            return false;
        }

        quoteAggregatorHeartbeat = _heartbeat;

        emit NewQuoteAggregatorHeartbeat(_heartbeat);

        return true;
    }

    
    
    
    function _normalizeWithDecimals(uint256 _price, uint8 _decimals) private view returns (uint256) {
        // We want to return the price of 1 asset token, but with the decimals of the quote token
        if (_QUOTE_TOKEN_DECIMALS == _decimals) {
            return _price;
        } else if (_QUOTE_TOKEN_DECIMALS < _decimals) {
            return _price / 10 ** (_decimals - _QUOTE_TOKEN_DECIMALS);
        } else {
            return _price * 10 ** (_QUOTE_TOKEN_DECIMALS - _decimals);
        }
    }

    
    function _toQuote(uint256 _price) private view returns (uint256) {
       (
            /*uint80 roundID*/,
            int256 aggregatorPrice,
            /*uint256 startedAt*/,
            uint256 timestamp,
            /*uint80 answeredInRound*/
        ) = _QUOTE_AGGREGATOR.latestRoundData();

        // If an invalid price is returned
        if (!_isValidPrice(aggregatorPrice, timestamp, quoteAggregatorHeartbeat)) {
            revert AggregatorPriceNotAvailable();
        }

        // _price and aggregatorPrice should both have the same decimals so we normalize here
        return _price * 10 ** _QUOTE_TOKEN_DECIMALS / uint256(aggregatorPrice);
    }

    function _isValidPrice(int256 _price, uint256 _timestamp, uint256 _heartbeat) private view returns (bool) {
        return _price > 0 && block.timestamp - _timestamp < _heartbeat;
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// 
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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
pragma solidity >=0.7.6;


/// Solidity version than the rest of the codebase. This way de won't need to include
/// an additional version of OpenZeppelin's library.
interface IERC20LikeV2 {
    function decimals() external view returns (uint8);
    function balanceOf(address) external view returns(uint256);
}

// 
pragma solidity >=0.7.6 <0.9.0;


library Ping {
    function pong(function() external pure returns(bytes4) pingFunction) internal pure returns (bool) {
        return pingFunction.address != address(0) && pingFunction.selector == pingFunction();
    }
}

// 
pragma solidity >=0.7.6 <0.9.0;



interface IPriceProvidersRepository {
    
    
    event NewPriceProvider(IPriceProvider indexed newPriceProvider);

    
    
    event PriceProviderRemoved(IPriceProvider indexed priceProvider);

    
    
    
    event PriceProviderForAsset(address indexed asset, IPriceProvider indexed priceProvider);

    
    
    function addPriceProvider(IPriceProvider _priceProvider) external;

    
    
    function removePriceProvider(IPriceProvider _priceProvider) external;

    
    
    
    
    function setPriceProviderForAsset(address _asset, IPriceProvider _priceProvider) external;

    
    
    
    function getPrice(address _asset) external view returns (uint256 price);

    
    
    
    function priceProviders(address _asset) external view returns (IPriceProvider priceProvider);

    
    
    function quoteToken() external view returns (address);

    
    
    function manager() external view returns (address);

    
    
    
    function providersReadyForAsset(address _asset) external view returns (bool);

    
    
    
    function isPriceProvider(IPriceProvider _provider) external view returns (bool);

    
    
    function providersCount() external view returns (uint256);

    
    
    function providerList() external view returns (address[] memory);

    
    
    function priceProvidersRepositoryPing() external pure returns (bytes4);
}