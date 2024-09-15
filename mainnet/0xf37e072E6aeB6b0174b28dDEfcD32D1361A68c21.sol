// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// 
pragma solidity ^0.8.0;

enum PriceFeedType {
    CHAINLINK_ORACLE,
    YEARN_ORACLE,
    CURVE_2LP_ORACLE,
    CURVE_3LP_ORACLE,
    CURVE_4LP_ORACLE,
    ZERO_ORACLE,
    WSTETH_ORACLE,
    BOUNDED_ORACLE,
    COMPOSITE_ORACLE
}

interface IPriceFeedType {
    
    function priceFeedType() external view returns (PriceFeedType);

    
    function skipPriceCheck() external view returns (bool);
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
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




interface ILPPriceFeedEvents {
    
    event NewLimiterParams(uint256 lowerBound, uint256 upperBound);
}

interface ILPPriceFeedExceptions {
    
    error ValueOutOfRangeException();

    
    error IncorrectLimitsException();
}

// 
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;



interface IVersion {
    
    function version() external view returns (uint256);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IPriceOracleV2Events {
    
    event NewPriceFeed(address indexed token, address indexed priceFeed);
}

interface IPriceOracleV2Exceptions {
    
    error ZeroPriceException();

    
    error ChainPriceStaleException();

    
    error PriceOracleNotExistsException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;








abstract contract ACLTrait is Pausable {
    // ACL contract to check rights
    IACL public immutable _acl;

    
    
    constructor(address addressProvider) {
        if (addressProvider == address(0)) revert ZeroAddressException(); // F:[AA-2]

        _acl = IACL(AddressProvider(addressProvider).getACL());
    }

    
    modifier configuratorOnly() {
        if (!_acl.isConfigurator(msg.sender))
            revert CallerNotConfiguratorException();
        _;
    }

    
    function pause() external {
        if (!_acl.isPausableAdmin(msg.sender))
            revert CallerNotPausableAdminException();
        _pause();
    }

    
    function unpause() external {
        if (!_acl.isUnpausableAdmin(msg.sender))
            revert CallerNotUnPausableAdminException();

        _unpause();
    }
}


interface ILPPriceFeed is
    AggregatorV3Interface,
    IPriceFeedType,
    ILPPriceFeedEvents,
    ILPPriceFeedExceptions
{
    
    
    
    function setLimiter(uint256 _lowerBound) external;

    
    function lowerBound() external view returns (uint256);

    
    function upperBound() external view returns (uint256);

    
    
    function delta() external view returns (uint256);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




contract PriceFeedChecker is IPriceOracleV2Exceptions {
    function _checkAnswer(
        uint80 roundID,
        int256 price,
        uint256 updatedAt,
        uint80 answeredInRound
    ) internal pure {
        if (price <= 0) revert ZeroPriceException(); // F:[PO-5]
        if (answeredInRound < roundID || updatedAt == 0)
            revert ChainPriceStaleException(); // F:[PO-5]
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IAddressProviderEvents {
    
    event AddressSet(bytes32 indexed service, address indexed newAddress);
}

// 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;






// EXCEPTIONS




/// internal exchange rate.
abstract contract LPPriceFeed is ILPPriceFeed, PriceFeedChecker, ACLTrait {
    
    
    uint256 public lowerBound;

    
    uint256 public immutable delta;

    
    uint8 public constant override decimals = 8;

    
    string public override description;

    
    
    
    
    constructor(
        address addressProvider,
        uint256 _delta,
        string memory _description
    ) ACLTrait(addressProvider) {
        description = _description; // F:[LPF-1]
        delta = _delta; // F:[LPF-1]
    }

    
    ///      do not store historical data.
    function getRoundData(uint80)
        external
        pure
        virtual
        override
        returns (
            uint80, // roundId,
            int256, // answer,
            uint256, // startedAt,
            uint256, // updatedAt,
            uint80 // answeredInRound
        )
    {
        revert NotImplementedException(); // F:[LPF-2]
    }

    
    /// Reverts if below lowerBound and returns min(value, upperBound)
    
    function _checkAndUpperBoundValue(uint256 value)
        internal
        view
        returns (uint256)
    {
        uint256 lb = lowerBound;
        if (value < lb) revert ValueOutOfRangeException(); // F:[LPF-3]

        uint256 uBound = _upperBound(lb);

        return (value > uBound) ? uBound : value;
    }

    
    
    ///                    from the lower bound
    function setLimiter(uint256 _lowerBound)
        external
        override
        configuratorOnly // F:[LPF-4]
    {
        _setLimiter(_lowerBound); // F:[LPF-4,5]
    }

    
    function _setLimiter(uint256 _lowerBound) internal {
        if (
            _lowerBound == 0 ||
            !_checkCurrentValueInBounds(_lowerBound, _upperBound(_lowerBound))
        ) revert IncorrectLimitsException(); // F:[LPF-4]

        lowerBound = _lowerBound; // F:[LPF-5]
        emit NewLimiterParams(lowerBound, _upperBound(_lowerBound)); // F:[LPF-5]
    }

    function _upperBound(uint256 lb) internal view returns (uint256) {
        return (lb * (PERCENTAGE_FACTOR + delta)) / PERCENTAGE_FACTOR; // F:[LPF-5]
    }

    
    function upperBound() external view returns (uint256) {
        return _upperBound(lowerBound); // F:[LPF-5]
    }

    function _checkCurrentValueInBounds(
        uint256 _lowerBound,
        uint256 _upperBound
    ) internal view virtual returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IACLExceptions {
    
    error AddressNotPausableAdminException(address addr);

    
    error AddressNotUnpausableAdminException(address addr);
}

interface IACLEvents {
    
    event PausableAdminAdded(address indexed newAdmin);

    
    event PausableAdminRemoved(address indexed admin);

    
    event UnpausableAdminAdded(address indexed newAdmin);

    
    event UnpausableAdminRemoved(address indexed admin);
}


interface IAddressProvider is IAddressProviderEvents, IVersion {
    
    function getACL() external view returns (address);

    
    function getContractsRegister() external view returns (address);

    
    function getAccountFactory() external view returns (address);

    
    function getDataCompressor() external view returns (address);

    
    function getGearToken() external view returns (address);

    
    function getWethToken() external view returns (address);

    
    function getWETHGateway() external view returns (address);

    
    function getPriceOracle() external view returns (address);

    
    function getTreasuryContract() external view returns (address);

    
    function getLeveragedActions() external view returns (address);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;





contract Claimable is Ownable {
    
    address public pendingOwner;

    
    modifier onlyPendingOwner() {
        if (msg.sender != pendingOwner) {
            revert("Claimable: Sender is not pending owner");
        }
        _;
    }

    
    /// transfer ownership yet
    
    function transferOwnership(address newOwner) public override onlyOwner {
        require(
            newOwner != address(0),
            "Claimable: new owner is the zero address"
        );
        pendingOwner = newOwner;
    }

    
    function claimOwnership() external onlyPendingOwner {
        _transferOwnership(pendingOwner);
        pendingOwner = address(0);
    }
}


interface IPriceOracleV2 is
    IPriceOracleV2Events,
    IPriceOracleV2Exceptions,
    IVersion
{
    
    
    
    function convertToUSD(uint256 amount, address token)
        external
        view
        returns (uint256);

    
    
    
    function convertFromUSD(uint256 amount, address token)
        external
        view
        returns (uint256);

    
    ///
    
    
    
    function convert(
        uint256 amount,
        address tokenFrom,
        address tokenTo
    ) external view returns (uint256);

    
    
    
    
    
    
    
    function fastCheck(
        uint256 amountFrom,
        address tokenFrom,
        uint256 amountTo,
        address tokenTo
    ) external view returns (uint256 collateralFrom, uint256 collateralTo);

    
    
    function getPrice(address token) external view returns (uint256);

    
    
    function priceFeeds(address token)
        external
        view
        returns (address priceFeed);

    
    ///      with additional parameters
    
    function priceFeedsWithFlags(address token)
        external
        view
        returns (
            address priceFeed,
            bool skipCheck,
            uint256 decimals
        );
}
// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;








// EXCEPTIONS


uint256 constant RANGE_WIDTH = 200; // 2%


contract YearnPriceFeed is LPPriceFeed {
    
    AggregatorV3Interface public immutable priceFeed;

    
    IYVault public immutable yVault;

    
    uint256 public immutable decimalsDivider;

    PriceFeedType public constant override priceFeedType =
        PriceFeedType.YEARN_ORACLE;
    uint256 public constant override version = 2;

    
    
    ///         since they perform their own sanity checks
    bool public constant override skipPriceCheck = true;

    constructor(
        address addressProvider,
        address _yVault,
        address _priceFeed
    )
        LPPriceFeed(
            addressProvider,
            RANGE_WIDTH, // F:[YPF-1]
            _yVault != address(0)
                ? string(
                    abi.encodePacked(
                        IERC20Metadata(_yVault).name(),
                        " priceFeed"
                    ) // F:[YPF-1]
                )
                : ""
        )
    {
        if (_yVault == address(0) || _priceFeed == address(0))
            revert ZeroAddressException(); // F:[OYPF-2]

        yVault = IYVault(_yVault); // F:[OYPF-1]
        priceFeed = AggregatorV3Interface(_priceFeed); // F:[OYPF-1]

        decimalsDivider = 10**IYVault(_yVault).decimals(); // F:[OYPF-1]
        uint256 pricePerShare = IYVault(_yVault).pricePerShare(); // F:[OYPF-1]
        _setLimiter(pricePerShare); // F:[OYPF-1]
    }

    
    
    ///         See more at https://dev.gearbox.fi/docs/documentation/oracle/yearn-pricefeed
    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        (roundId, answer, startedAt, updatedAt, answeredInRound) = priceFeed
            .latestRoundData(); // F:[OYPF-4]

        // Sanity check for chainlink pricefeed
        _checkAnswer(roundId, answer, updatedAt, answeredInRound); // F:[OYPF-5]

        uint256 pricePerShare = yVault.pricePerShare(); // F:[OYPF-4]

        // Checks that pricePerShare is within bounds
        pricePerShare = _checkAndUpperBoundValue(pricePerShare); // F:[OYPF-5]

        answer = int256((pricePerShare * uint256(answer)) / decimalsDivider); // F:[OYPF-4]
    }

    function _checkCurrentValueInBounds(uint256 _lowerBound, uint256 _uBound)
        internal
        view
        override
        returns (bool)
    {
        uint256 pps = yVault.pricePerShare();
        if (pps < _lowerBound || pps > _uBound) {
            return false;
        }
        return true;
    }
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
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




error ZeroAddressException();


error NotImplementedException();


error AddressIsNotContractException(address);


error IncorrectTokenContractException();


///      correct price feed
error IncorrectPriceFeedException();


error CallerNotConfiguratorException();


error CallerNotPausableAdminException();


error CallerNotUnPausableAdminException();

error TokenIsNotAddedToCreditManagerException(address token);

// 
pragma solidity ^0.8.10;



interface IYVault is IERC20 {
    function token() external view returns (address);

    function deposit() external returns (uint256);

    function deposit(uint256 _amount) external returns (uint256);

    function deposit(uint256 _amount, address recipient)
        external
        returns (uint256);

    function withdraw() external returns (uint256);

    function withdraw(uint256 maxShares) external returns (uint256);

    function withdraw(uint256 maxShares, address recipient)
        external
        returns (uint256);

    function withdraw(
        uint256 maxShares,
        address recipient,
        uint256 maxLoss
    ) external returns (uint256);

    function pricePerShare() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// 
pragma solidity ^0.8.10;



uint16 constant PERCENTAGE_FACTOR = 1e4; //percentage plus two decimals
uint256 constant HALF_PERCENT = PERCENTAGE_FACTOR / 2;

/**
 * @title PercentageMath library
 * @author Aave
 * @notice Provides functions to perform percentage calculations
 * @dev Percentages are defined by default with 2 decimals of precision (100.00). The precision is indicated by PERCENTAGE_FACTOR
 * @dev Operations are rounded half up
 **/

library PercentageMath {
    /**
     * @dev Executes a percentage multiplication
     * @param value The value of which the percentage needs to be calculated
     * @param percentage The percentage of the value to be calculated
     * @return The percentage of value
     **/
    function percentMul(uint256 value, uint256 percentage)
        internal
        pure
        returns (uint256)
    {
        if (value == 0 || percentage == 0) {
            return 0; // T:[PM-1]
        }

        //        require(
        //            value <= (type(uint256).max - HALF_PERCENT) / percentage,
        //            Errors.MATH_MULTIPLICATION_OVERFLOW
        //        ); // T:[PM-1]

        return (value * percentage + HALF_PERCENT) / PERCENTAGE_FACTOR; // T:[PM-1]
    }

    /**
     * @dev Executes a percentage division
     * @param value The value of which the percentage needs to be calculated
     * @param percentage The percentage of the value to be calculated
     * @return The value divided the percentage
     **/
    function percentDiv(uint256 value, uint256 percentage)
        internal
        pure
        returns (uint256)
    {
        require(percentage != 0, Errors.MATH_DIVISION_BY_ZERO); // T:[PM-2]
        uint256 halfPercentage = percentage / 2; // T:[PM-2]

        //        require(
        //            value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR,
        //            Errors.MATH_MULTIPLICATION_OVERFLOW
        //        ); // T:[PM-2]

        return (value * PERCENTAGE_FACTOR + halfPercentage) / percentage;
    }
}


interface IACL is IACLEvents, IACLExceptions, IVersion {
    
    
    function isPausableAdmin(address addr) external view returns (bool);

    
    
    function isUnpausableAdmin(address addr) external view returns (bool);

    
    
    function isConfigurator(address account) external view returns (bool);

    
    function owner() external view returns (address);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;





// Repositories & services
bytes32 constant CONTRACTS_REGISTER = "CONTRACTS_REGISTER";
bytes32 constant ACL = "ACL";
bytes32 constant PRICE_ORACLE = "PRICE_ORACLE";
bytes32 constant ACCOUNT_FACTORY = "ACCOUNT_FACTORY";
bytes32 constant DATA_COMPRESSOR = "DATA_COMPRESSOR";
bytes32 constant TREASURY_CONTRACT = "TREASURY_CONTRACT";
bytes32 constant GEAR_TOKEN = "GEAR_TOKEN";
bytes32 constant WETH_TOKEN = "WETH_TOKEN";
bytes32 constant WETH_GATEWAY = "WETH_GATEWAY";
bytes32 constant LEVERAGED_ACTIONS = "LEVERAGED_ACTIONS";



contract AddressProvider is Claimable, IAddressProvider {
    // Mapping from contract keys to respective addresses
    mapping(bytes32 => address) public addresses;

    // Contract version
    uint256 public constant version = 2;

    constructor() {
        // @dev Emits first event for contract discovery
        emit AddressSet("ADDRESS_PROVIDER", address(this));
    }

    
    function getACL() external view returns (address) {
        return _getAddress(ACL); // F:[AP-3]
    }

    
    
    function setACL(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(ACL, _address); // F:[AP-3]
    }

    
    function getContractsRegister() external view returns (address) {
        return _getAddress(CONTRACTS_REGISTER); // F:[AP-4]
    }

    
    
    function setContractsRegister(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(CONTRACTS_REGISTER, _address); // F:[AP-4]
    }

    
    function getPriceOracle() external view override returns (address) {
        return _getAddress(PRICE_ORACLE); // F:[AP-5]
    }

    
    
    function setPriceOracle(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(PRICE_ORACLE, _address); // F:[AP-5]
    }

    
    function getAccountFactory() external view returns (address) {
        return _getAddress(ACCOUNT_FACTORY); // F:[AP-6]
    }

    
    
    function setAccountFactory(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(ACCOUNT_FACTORY, _address); // F:[AP-6]
    }

    
    function getDataCompressor() external view override returns (address) {
        return _getAddress(DATA_COMPRESSOR); // F:[AP-7]
    }

    
    
    function setDataCompressor(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(DATA_COMPRESSOR, _address); // F:[AP-7]
    }

    
    function getTreasuryContract() external view returns (address) {
        return _getAddress(TREASURY_CONTRACT); // F:[AP-8]
    }

    
    
    function setTreasuryContract(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(TREASURY_CONTRACT, _address); // F:[AP-8]
    }

    
    function getGearToken() external view override returns (address) {
        return _getAddress(GEAR_TOKEN); // F:[AP-9]
    }

    
    
    function setGearToken(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(GEAR_TOKEN, _address); // F:[AP-9]
    }

    
    function getWethToken() external view override returns (address) {
        return _getAddress(WETH_TOKEN); // F:[AP-10]
    }

    
    
    function setWethToken(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(WETH_TOKEN, _address); // F:[AP-10]
    }

    
    function getWETHGateway() external view override returns (address) {
        return _getAddress(WETH_GATEWAY); // F:[AP-11]
    }

    
    
    function setWETHGateway(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(WETH_GATEWAY, _address); // F:[AP-11]
    }

    
    function getLeveragedActions() external view returns (address) {
        return _getAddress(LEVERAGED_ACTIONS); // T:[AP-7]
    }

    
    
    function setLeveragedActions(address _address)
        external
        onlyOwner // T:[AP-15]
    {
        _setAddress(LEVERAGED_ACTIONS, _address); // T:[AP-7]
    }

    
    function _getAddress(bytes32 key) internal view returns (address) {
        address result = addresses[key];
        require(result != address(0), Errors.AS_ADDRESS_NOT_FOUND); // F:[AP-1]
        return result; // F:[AP-3, 4, 5, 6, 7, 8, 9, 10, 11]
    }

    
    
    
    function _setAddress(bytes32 key, address value) internal {
        addresses[key] = value; // F:[AP-3, 4, 5, 6, 7, 8, 9, 10, 11]
        emit AddressSet(key, value); // F:[AP-2]
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


library Errors {
    //
    // COMMON
    //
    string public constant ZERO_ADDRESS_IS_NOT_ALLOWED = "Z0";
    string public constant NOT_IMPLEMENTED = "NI";
    string public constant INCORRECT_PATH_LENGTH = "PL";
    string public constant INCORRECT_ARRAY_LENGTH = "CR";
    string public constant REGISTERED_CREDIT_ACCOUNT_MANAGERS_ONLY = "CP";
    string public constant REGISTERED_POOLS_ONLY = "RP";
    string public constant INCORRECT_PARAMETER = "IP";

    //
    // MATH
    //
    string public constant MATH_MULTIPLICATION_OVERFLOW = "M1";
    string public constant MATH_ADDITION_OVERFLOW = "M2";
    string public constant MATH_DIVISION_BY_ZERO = "M3";

    //
    // POOL
    //
    string public constant POOL_CONNECTED_CREDIT_MANAGERS_ONLY = "PS0";
    string public constant POOL_INCOMPATIBLE_CREDIT_ACCOUNT_MANAGER = "PS1";
    string public constant POOL_MORE_THAN_EXPECTED_LIQUIDITY_LIMIT = "PS2";
    string public constant POOL_INCORRECT_WITHDRAW_FEE = "PS3";
    string public constant POOL_CANT_ADD_CREDIT_MANAGER_TWICE = "PS4";

    //
    // ACCOUNT FACTORY
    //
    string public constant AF_CANT_CLOSE_CREDIT_ACCOUNT_IN_THE_SAME_BLOCK =
        "AF1";
    string public constant AF_MINING_IS_FINISHED = "AF2";
    string public constant AF_CREDIT_ACCOUNT_NOT_IN_STOCK = "AF3";
    string public constant AF_EXTERNAL_ACCOUNTS_ARE_FORBIDDEN = "AF4";

    //
    // ADDRESS PROVIDER
    //
    string public constant AS_ADDRESS_NOT_FOUND = "AP1";

    //
    // CONTRACTS REGISTER
    //
    string public constant CR_POOL_ALREADY_ADDED = "CR1";
    string public constant CR_CREDIT_MANAGER_ALREADY_ADDED = "CR2";

    //
    // CREDIT ACCOUNT
    //
    string public constant CA_CONNECTED_CREDIT_MANAGER_ONLY = "CA1";
    string public constant CA_FACTORY_ONLY = "CA2";

    //
    // ACL
    //
    string public constant ACL_CALLER_NOT_PAUSABLE_ADMIN = "ACL1";
    string public constant ACL_CALLER_NOT_CONFIGURATOR = "ACL2";

    //
    // WETH GATEWAY
    //
    string public constant WG_DESTINATION_IS_NOT_WETH_COMPATIBLE = "WG1";
    string public constant WG_RECEIVE_IS_NOT_ALLOWED = "WG2";
    string public constant WG_NOT_ENOUGH_FUNDS = "WG3";

    //
    // TOKEN DISTRIBUTOR
    //
    string public constant TD_WALLET_IS_ALREADY_CONNECTED_TO_VC = "TD1";
    string public constant TD_INCORRECT_WEIGHTS = "TD2";
    string public constant TD_NON_ZERO_BALANCE_AFTER_DISTRIBUTION = "TD3";
    string public constant TD_CONTRIBUTOR_IS_NOT_REGISTERED = "TD4";
}

interface IPriceOracleV2Ext is IPriceOracleV2 {
    
    
    
    function addPriceFeed(address token, address priceFeed) external;
}