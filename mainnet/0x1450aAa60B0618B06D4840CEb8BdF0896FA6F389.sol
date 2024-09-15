// SPDX-License-Identifier: MIT


// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




enum ClosureAction {
    CLOSE_ACCOUNT,
    LIQUIDATE_ACCOUNT,
    LIQUIDATE_EXPIRED_ACCOUNT,
    LIQUIDATE_PAUSED
}

interface ICreditManagerV2Events {
    
    event ExecuteOrder(address indexed borrower, address indexed target);

    
    event NewConfigurator(address indexed newConfigurator);
}

interface ICreditManagerV2Exceptions {
    
    ///      the connected Credit Facade, or an allowed adapter
    error AdaptersOrCreditFacadeOnlyException();

    
    ///      the connected Credit Facade
    error CreditFacadeOnlyException();

    
    ///      the connected Credit Configurator
    error CreditConfiguratorOnlyException();

    
    ///      to the zero address or an address that already owns a Credit Account
    error ZeroAddressOrUserAlreadyHasAccountException();

    
    ///      target contract
    error TargetContractNotAllowedException();

    
    error NotEnoughCollateralException();

    
    ///      or was forbidden
    error TokenNotAllowedException();

    
    error AllowanceFailedException();

    
    error HasNoOpenedAccountException();

    
    error TokenAlreadyAddedException();

    
    error TooManyTokensException();

    
    ///      and there are not enough unused token to disable
    error TooManyEnabledTokensException();

    
    error ReentrancyLockException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


enum AdapterType {
    ABSTRACT,
    UNISWAP_V2_ROUTER,
    UNISWAP_V3_ROUTER,
    CURVE_V1_EXCHANGE_ONLY,
    YEARN_V2,
    CURVE_V1_2ASSETS,
    CURVE_V1_3ASSETS,
    CURVE_V1_4ASSETS,
    CURVE_V1_STECRV_POOL,
    CURVE_V1_WRAPPER,
    CONVEX_V1_BASE_REWARD_POOL,
    CONVEX_V1_BOOSTER,
    CONVEX_V1_CLAIM_ZAP,
    LIDO_V1,
    UNIVERSAL,
    LIDO_WSTETH_V1
}

interface IAdapterExceptions {
    
    ///      that is not recognized as collateral in the connected
    ///      Credit Manager
    error TokenIsNotInAllowedList(address);
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



interface IVersion {
    
    function version() external view returns (uint256);
}

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IAdapter is IAdapterExceptions {
    
    function creditManager() external view returns (ICreditManagerV2);

    
    function creditFacade() external view returns (address);

    
    function targetContract() external view returns (address);

    
    function _gearboxAdapterType() external pure returns (AdapterType);

    
    function _gearboxAdapterVersion() external pure returns (uint16);
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

interface ICreditFacadeEvents {
    
    ///      Credit Facade
    event OpenCreditAccount(
        address indexed onBehalfOf,
        address indexed creditAccount,
        uint256 borrowAmount,
        uint16 referralCode
    );

    
    event CloseCreditAccount(address indexed borrower, address indexed to);

    
    event LiquidateCreditAccount(
        address indexed borrower,
        address indexed liquidator,
        address indexed to,
        uint256 remainingFunds
    );

    
    event LiquidateExpiredCreditAccount(
        address indexed borrower,
        address indexed liquidator,
        address indexed to,
        uint256 remainingFunds
    );

    
    event IncreaseBorrowedAmount(address indexed borrower, uint256 amount);

    
    event DecreaseBorrowedAmount(address indexed borrower, uint256 amount);

    
    event AddCollateral(
        address indexed onBehalfOf,
        address indexed token,
        uint256 value
    );

    
    event MultiCallStarted(address indexed borrower);

    
    event MultiCallFinished();

    
    event TransferAccount(address indexed oldOwner, address indexed newOwner);

    
    event TransferAccountAllowed(
        address indexed from,
        address indexed to,
        bool state
    );

    
    event TokenEnabled(address indexed borrower, address indexed token);

    
    event TokenDisabled(address indexed borrower, address indexed token);
}

interface ICreditFacadeExceptions is ICreditManagerV2Exceptions {
    
    ///      requires expirability
    error NotAllowedWhenNotExpirableException();

    
    ///      not allowed in whitelisted mode
    error NotAllowedInWhitelistedMode();

    
    error AccountTransferNotAllowedException();

    
    error CantLiquidateWithSuchHealthFactorException();

    
    error CantLiquidateNonExpiredException();

    
    error IncorrectCallDataException();

    
    ///      an account
    error ForbiddenDuringClosureException();

    
    error IncreaseAndDecreaseForbiddenInOneCallException();

    
    ///      during a multicall
    error UnknownMethodException();

    
    error IncreaseDebtForbiddenException();

    
    error CantTransferLiquidatableAccountException();

    
    error BorrowedBlockLimitException();

    
    error BorrowAmountOutOfLimitsException();

    
    ///      at the end of a multicall, if revertIfReceivedLessThan was called
    error BalanceLessThanMinimumDesiredException(address);

    
    error OpenAccountNotAllowedAfterExpirationException();

    
    error ExpectedBalancesAlreadySetException();

    
    ///      that is not allowed with any forbidden tokens enabled
    error ActionProhibitedWithForbiddenTokensException();
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// 
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;






abstract contract AbstractAdapter is IAdapter {
    using Address for address;

    ICreditManagerV2 public immutable override creditManager;
    address public immutable override creditFacade;
    address public immutable override targetContract;

    constructor(address _creditManager, address _targetContract) {
        if (_creditManager == address(0) || _targetContract == address(0))
            revert ZeroAddressException(); // F:[AA-2]

        creditManager = ICreditManagerV2(_creditManager); // F:[AA-1]
        creditFacade = ICreditManagerV2(_creditManager).creditFacade(); // F:[AA-1]
        targetContract = _targetContract; // F:[AA-1]
    }

    
    
    
    function _approveToken(address token, uint256 amount) internal {
        creditManager.approveCreditAccount(
            msg.sender,
            targetContract,
            token,
            amount
        );
    }

    
    
    function _execute(bytes memory callData)
        internal
        returns (bytes memory result)
    {
        result = creditManager.executeOrder(
            msg.sender,
            targetContract,
            callData
        );
    }

    
    
    
    
    
    
    
    
    function _executeMaxAllowanceFastCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        bytes memory callData,
        bool allowTokenIn,
        bool disableTokenIn
    ) internal returns (bytes memory result) {
        uint256 balanceInBefore;
        uint256 balanceOutBefore;

        if (msg.sender != creditFacade) {
            balanceInBefore = IERC20(tokenIn).balanceOf(creditAccount); // F:[AA-4A]
            balanceOutBefore = IERC20(tokenOut).balanceOf(creditAccount); // F:[AA-4A]
        }

        if (allowTokenIn) {
            _approveToken(tokenIn, type(uint256).max);
        }

        result = creditManager.executeOrder(
            msg.sender,
            targetContract,
            callData
        );

        if (allowTokenIn) {
            _approveToken(tokenIn, type(uint256).max);
        }

        _fastCheck(
            creditAccount,
            tokenIn,
            tokenOut,
            balanceInBefore,
            balanceOutBefore,
            disableTokenIn
        );
    }

    
    /// See params and other details above
    function _executeMaxAllowanceFastCheck(
        address tokenIn,
        address tokenOut,
        bytes memory callData,
        bool allowTokenIn,
        bool disableTokenIn
    ) internal returns (bytes memory result) {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[AA-3]

        result = _executeMaxAllowanceFastCheck(
            creditAccount,
            tokenIn,
            tokenOut,
            callData,
            allowTokenIn,
            disableTokenIn
        );
    }

    
    
    
    
    
    
    
    function _safeExecuteFastCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        bytes memory callData,
        bool allowTokenIn,
        bool disableTokenIn
    ) internal returns (bytes memory result) {
        uint256 balanceInBefore;
        uint256 balanceOutBefore;

        if (msg.sender != creditFacade) {
            balanceInBefore = IERC20(tokenIn).balanceOf(creditAccount);
            balanceOutBefore = IERC20(tokenOut).balanceOf(creditAccount); // F:[AA-4A]
        }

        if (allowTokenIn) {
            _approveToken(tokenIn, type(uint256).max);
        }

        result = creditManager.executeOrder(
            msg.sender,
            targetContract,
            callData
        );

        if (allowTokenIn) {
            _approveToken(tokenIn, 1);
        }

        _fastCheck(
            creditAccount,
            tokenIn,
            tokenOut,
            balanceInBefore,
            balanceOutBefore,
            disableTokenIn
        );
    }

    
    /// See params and other details above
    function _safeExecuteFastCheck(
        address tokenIn,
        address tokenOut,
        bytes memory callData,
        bool allowTokenIn,
        bool disableTokenIn
    ) internal returns (bytes memory result) {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        );

        result = _safeExecuteFastCheck(
            creditAccount,
            tokenIn,
            tokenOut,
            callData,
            allowTokenIn,
            disableTokenIn
        );
    }

    //
    // HEALTH CHECK FUNCTIONS
    //

    
    /// it for multicalls (since a full collateral check is always performed after a multicall)
    
    
    
    
    
    
    function _fastCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        uint256 balanceInBefore,
        uint256 balanceOutBefore,
        bool disableTokenIn
    ) private {
        if (msg.sender != creditFacade) {
            creditManager.fastCollateralCheck(
                creditAccount,
                tokenIn,
                tokenOut,
                balanceInBefore,
                balanceOutBefore
            );
        } else {
            if (disableTokenIn)
                creditManager.disableToken(creditAccount, tokenIn);
            creditManager.checkAndEnableToken(creditAccount, tokenOut);
        }
    }

    
    /// it for multicalls (since a full collateral check is always performed after a multicall)
    
    function _fullCheck(address creditAccount) internal {
        if (msg.sender != creditFacade) {
            creditManager.fullCollateralCheck(creditAccount);
        }
    }

    
    /// it for multicalls (since a full collateral check is always performed after a multicall,
    /// and includes enabled token optimization by default)
    
    
    ///         (e.g., claiming rewards)
    function _checkAndOptimizeEnabledTokens(address creditAccount) internal {
        if (msg.sender != creditFacade) {
            creditManager.checkAndOptimizeEnabledTokens(creditAccount);
        }
    }
}


///         by the Credit Facade or allowed adapters. Users are not allowed to
///         interact with the Credit Manager directly
interface ICreditManagerV2 is
    ICreditManagerV2Events,
    ICreditManagerV2Exceptions,
    IVersion
{
    //
    // CREDIT ACCOUNT MANAGEMENT
    //

    
    /// - Takes Credit Account from the factory;
    /// - Requests the pool to lend underlying to the Credit Account
    ///
    
    
    function openCreditAccount(uint256 borrowedAmount, address onBehalfOf)
        external
        returns (address);

    
    /// - Checks whether the contract is paused, and, if so, if the payer is an emergency liquidator.
    ///   Only emergency liquidators are able to liquidate account while the CM is paused.
    ///   Emergency liquidations do not pay a liquidator premium or liquidation fees.
    /// - Calculates payments to various recipients on closure:
    ///    + Computes amountToPool, which is the amount to be sent back to the pool.
    ///      This includes the principal, interest and fees, but can't be more than
    ///      total position value
    ///    + Computes remainingFunds during liquidations - these are leftover funds
    ///      after paying the pool and the liquidator, and are sent to the borrower
    ///    + Computes protocol profit, which includes interest and liquidation fees
    ///    + Computes loss if the totalValue is less than borrow amount + interest
    /// - Checks the underlying token balance:
    ///    + if it is larger than amountToPool, then the pool is paid fully from funds on the Credit Account
    ///    + else tries to transfer the shortfall from the payer - either the borrower during closure, or liquidator during liquidation
    /// - Send assets to the "to" address, as long as they are not included into skipTokenMask
    /// - If convertWETH is true, the function converts WETH into ETH before sending
    /// - Returns the Credit Account back to factory
    ///
    
    
    
    
    
    
    
    function closeCreditAccount(
        address borrower,
        ClosureAction closureActionType,
        uint256 totalValue,
        address payer,
        address to,
        uint256 skipTokenMask,
        bool convertWETH
    ) external returns (uint256 remainingFunds);

    
    ///
    /// - Increase debt:
    ///   + Increases debt by transferring funds from the pool to the credit account
    ///   + Updates the cumulative index to keep interest the same. Since interest
    ///     is always computed dynamically as borrowedAmount * (cumulativeIndexNew / cumulativeIndexOpen - 1),
    ///     cumulativeIndexOpen needs to be updated, as the borrow amount has changed
    ///
    /// - Decrease debt:
    ///   + Repays debt partially + all interest and fees accrued thus far
    ///   + Updates cunulativeIndex to cumulativeIndex now
    ///
    
    
    
    
    function manageDebt(
        address creditAccount,
        uint256 amount,
        bool increase
    ) external returns (uint256 newBorrowedAmount);

    
    
    
    
    
    function addCollateral(
        address payer,
        address creditAccount,
        address token,
        uint256 amount
    ) external;

    
    
    
    function transferAccountOwnership(address from, address to) external;

    
    
    
    
    
    function approveCreditAccount(
        address borrower,
        address targetContract,
        address token,
        uint256 amount
    ) external;

    
    /// This is the intended pathway for state-changing interactions with 3rd-party protocols
    
    
    
    function executeOrder(
        address borrower,
        address targetContract,
        bytes memory data
    ) external returns (bytes memory);

    //
    // COLLATERAL VALIDITY AND ACCOUNT HEALTH CHECKS
    //

    
    /// into account health and total value calculations
    
    
    function checkAndEnableToken(address creditAccount, address token) external;

    
    
    ///         participate in the operation and computes a % change in weighted value between
    ///         inbound and outbound collateral. The cumulative negative change across several
    ///         swaps in sequence cannot be larger than feeLiquidation (a fee that the
    ///         protocol is ready to waive if needed). Since this records a % change
    ///         between just two tokens, the corresponding % change in TWV will always be smaller,
    ///         which makes this check safe.
    ///         More details at https://dev.gearbox.fi/docs/documentation/risk/fast-collateral-check#fast-check-protection
    
    
    
    
    
    function fastCollateralCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        uint256 balanceInBefore,
        uint256 balanceOutBefore
    ) external;

    
    /// value of all enabled collateral tokens
    
    function fullCollateralCheck(address creditAccount) external;

    
    ///      does not violate the maximal enabled token limit and tries
    ///      to disable unused tokens if it does
    
    function checkAndOptimizeEnabledTokens(address creditAccount) external;

    
    
    ///         but can also be called separately from the Credit Facade to remove
    ///         unwanted tokens
    
    function disableToken(address creditAccount, address token)
        external
        returns (bool);

    //
    // GETTERS
    //

    
    
    function getCreditAccountOrRevert(address borrower)
        external
        view
        returns (address);

    
    
    
    ///        * CLOSE_ACCOUNT: The account is healthy and is closed normally
    ///        * LIQUIDATE_ACCOUNT: The account is unhealthy and is being liquidated to avoid bad debt
    ///        * LIQUIDATE_EXPIRED_ACCOUNT: The account has expired and is being liquidated (lowered liquidation premium)
    ///        * LIQUIDATE_PAUSED: The account is liquidated while the system is paused due to emergency (no liquidation premium)
    
    
    
    
    
    
    function calcClosePayments(
        uint256 totalValue,
        ClosureAction closureActionType,
        uint256 borrowedAmount,
        uint256 borrowedAmountWithInterest
    )
        external
        view
        returns (
            uint256 amountToPool,
            uint256 remainingFunds,
            uint256 profit,
            uint256 loss
        );

    
    
    
    
    
    function calcCreditAccountAccruedInterest(address creditAccount)
        external
        view
        returns (
            uint256 borrowedAmount,
            uint256 borrowedAmountWithInterest,
            uint256 borrowedAmountWithInterestAndFees
        );

    
    /// Only enabled tokens are counted as collateral for the Credit Account
    
    ///         the bit at the position equal to token's index to 1
    function enabledTokensMap(address creditAccount)
        external
        view
        returns (uint256);

    
    ///      the last full check, in RAY format
    function cumulativeDropAtFastCheckRAY(address creditAccount)
        external
        view
        returns (uint256);

    
    
    function collateralTokens(uint256 id)
        external
        view
        returns (address token, uint16 liquidationThreshold);

    
    
    function collateralTokensByMask(uint256 tokenMask)
        external
        view
        returns (address token, uint16 liquidationThreshold);

    
    function collateralTokensCount() external view returns (uint256);

    
    
    function tokenMasksMap(address token) external view returns (uint256);

    
    function forbiddenTokenMask() external view returns (uint256);

    
    function adapterToContract(address adapter) external view returns (address);

    
    function contractToAdapter(address targetContract)
        external
        view
        returns (address);

    
    function underlying() external view returns (address);

    
    function pool() external view returns (address);

    
    
    function poolService() external view returns (address);

    
    function creditAccounts(address borrower) external view returns (address);

    
    function creditConfigurator() external view returns (address);

    
    function wethAddress() external view returns (address);

    
    
    function liquidationThresholds(address token)
        external
        view
        returns (uint16);

    
    function maxAllowedEnabledTokenLength() external view returns (uint8);

    
    
    /// that are able to liquidate positions while the contracts are paused,
    /// e.g. when there is a risk of bad debt while an exploit is being patched.
    /// In the interest of fairness, emergency liquidators do not receive a premium
    /// And are compensated by the Gearbox DAO separately.
    function canLiquidateWhilePaused(address) external view returns (bool);

    
    
    
    ///         during unhealthy account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremium)
    
    ///         during expired account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremiumExpired)
    function fees()
        external
        view
        returns (
            uint16 feeInterest,
            uint16 feeLiquidation,
            uint16 liquidationDiscount,
            uint16 feeLiquidationExpired,
            uint16 liquidationDiscountExpired
        );

    
    function creditFacade() external view returns (address);

    
    function priceOracle() external view returns (IPriceOracleV2);

    
    function universalAdapter() external view returns (address);

    
    function version() external view returns (uint256);

    
    function checkEmergencyPausable(address caller, bool state)
        external
        returns (bool);
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

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;



interface IPoolServiceEvents {
    
    event AddLiquidity(
        address indexed sender,
        address indexed onBehalfOf,
        uint256 amount,
        uint256 referralCode
    );

    
    event RemoveLiquidity(
        address indexed sender,
        address indexed to,
        uint256 amount
    );

    
    event Borrow(
        address indexed creditManager,
        address indexed creditAccount,
        uint256 amount
    );

    
    event Repay(
        address indexed creditManager,
        uint256 borrowedAmount,
        uint256 profit,
        uint256 loss
    );

    
    event NewInterestRateModel(address indexed newInterestRateModel);

    
    event NewCreditManagerConnected(address indexed creditManager);

    
    event BorrowForbidden(address indexed creditManager);

    
    event UncoveredLoss(address indexed creditManager, uint256 loss);

    
    event NewExpectedLiquidityLimit(uint256 newLimit);

    
    event NewWithdrawFee(uint256 fee);
}

// 
pragma solidity ^0.8.10;

interface IBooster {
    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);

    function depositAll(uint256 _pid, bool _stake) external returns (bool);

    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);

    function withdrawAll(uint256 _pid) external returns (bool);

    // function earmarkRewards(uint256 _pid) external returns (bool);

    // function earmarkFees() external returns (bool);

    //
    // GETTERS
    //

    function poolInfo(uint256 i) external view returns (PoolInfo memory);

    function poolLength() external view returns (uint256);

    function staker() external view returns (address);

    function minter() external view returns (address);

    function crv() external view returns (address);

    function registry() external view returns (address);

    function stakerRewards() external view returns (address);

    function lockRewards() external view returns (address);

    function lockFees() external view returns (address);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;






struct CollateralToken {
    
    address token;
    
    uint16 liquidationThreshold;
}


struct CreditManagerOpts {
    
    uint128 minBorrowedAmount;
    
    uint128 maxBorrowedAmount;
    
    CollateralToken[] collateralTokens;
    
    address degenNFT;
    
    bool expirable;
}

interface ICreditConfiguratorEvents {
    
    event TokenLiquidationThresholdUpdated(
        address indexed token,
        uint16 liquidityThreshold
    );

    
    event TokenAllowed(address indexed token);

    
    event TokenForbidden(address indexed token);

    
    event ContractAllowed(address indexed protocol, address indexed adapter);

    
    event ContractForbidden(address indexed protocol);

    
    event LimitsUpdated(uint256 minBorrowedAmount, uint256 maxBorrowedAmount);

    
    event FeesUpdated(
        uint16 feeInterest,
        uint16 feeLiquidation,
        uint16 liquidationPremium,
        uint16 feeLiquidationExpired,
        uint16 liquidationPremiumExpired
    );

    
    event PriceOracleUpgraded(address indexed newPriceOracle);

    
    event CreditFacadeUpgraded(address indexed newCreditFacade);

    
    event CreditConfiguratorUpgraded(address indexed newCreditConfigurator);

    
    event IncreaseDebtForbiddenModeChanged(bool);

    
    event LimitPerBlockUpdated(uint128);

    
    event AddedToUpgradeable(address);

    
    event RemovedFromUpgradeable(address);

    
    event ExpirationDateUpdated(uint40);

    
    event MaxEnabledTokensUpdated(uint8);

    
    event EmergencyLiquidatorAdded(address);

    
    event EmergencyLiquidatorRemoved(address);
}


interface ICreditConfiguratorExceptions {
    
    
    ///         on updating fees
    error SetLTForUnderlyingException();

    
    error IncorrectLiquidationThresholdException();

    
    error IncorrectFeesException();

    
    error IncorrectLimitsException();

    
    error IncorrectExpirationDateException();

    
    error CreditManagerOrFacadeUsedAsTargetContractsException();

    
    error AdapterUsedTwiceException();

    
    ///      or retrieving the Credit Manager from it fails
    error IncompatibleContractException();

    
    error ContractIsNotAnAllowedAdapterException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




interface IConvexV1BaseRewardPoolAdapterErrors {
    
    ///      allowed in its corresponding Credit Manager
    error TokenIsNotAddedToCreditManagerException(address token);
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

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




///   - Holds collateral assets
///   - Stores general parameters: borrowed amount, cumulative index at open and block when it was initialized
///   - Transfers assets
///   - Executes financial orders by calling connected protocols on its behalf
///
///  More: https://dev.gearbox.fi/developers/credit/credit_account

interface ICrediAccountExceptions {
    
    error CallerNotCreditManagerException();

    
    error CallerNotFactoryException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IAccountFactoryEvents {
    
    
    event AccountMinerChanged(address indexed miner);

    
    event NewCreditAccount(address indexed account);

    
    event InitializeCreditAccount(
        address indexed account,
        address indexed creditManager
    );

    
    event ReturnCreditAccount(address indexed account);

    
    ///      by root
    event TakeForever(address indexed creditAccount, address indexed to);
}

interface IAccountFactoryGetters {
    
    
    function getNext(address creditAccount) external view returns (address);

    
    function head() external view returns (address);

    
    function tail() external view returns (address);

    
    function countCreditAccountsInStock() external view returns (uint256);

    
    
    function creditAccounts(uint256 id) external view returns (address);

    
    function countCreditAccounts() external view returns (uint256);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;



interface IDegenNFTExceptions {
    
    error CreditFacadeOrConfiguratorOnlyException();

    
    error MinterOnlyException();

    
    error InvalidCreditFacadeException();

    
    error InsufficientBalanceException();
}

interface IDegenNFTEvents {
    
    event NewMinterSet(address indexed);

    
    event NewCreditFacadeAdded(address indexed);

    
    event NewCreditFacadeRemoved(address indexed);
}

interface ICreditFacade is
    ICreditFacadeEvents,
    ICreditFacadeExceptions,
    IVersion
{
    //
    // CREDIT ACCOUNT MANAGEMENT
    //

    
    /// without any additional action.
    
    
    /// msg.sender != obBehalfOf
    
    /// as the user's own collateral, equivalent to 2x leverage.
    
    function openCreditAccount(
        uint256 amount,
        address onBehalfOf,
        uint16 leverageFactor,
        uint16 referralCode
    ) external payable;

    
    
    
    /// msg.sender != obBehalfOf
    
    /// at least a call to addCollateral, as otherwise the health check at the end will fail.
    
    function openCreditAccountMulticall(
        uint256 borrowedAmount,
        address onBehalfOf,
        MultiCall[] calldata calls,
        uint16 referralCode
    ) external payable;

    
    /// - Wraps ETH to WETH and sends it msg.sender if value > 0
    /// - Executes the multicall - the main purpose of a multicall when closing is to convert all assets to underlying
    /// in order to pay the debt.
    /// - Closes credit account:
    ///    + Checks the underlying balance: if it is greater than the amount paid to the pool, transfers the underlying
    ///      from the Credit Account and proceeds. If not, tries to transfer the shortfall from msg.sender.
    ///    + Transfers all enabled assets with non-zero balances to the "to" address, unless they are marked
    ///      to be skipped in skipTokenMask
    ///    + If convertWETH is true, converts WETH into ETH before sending to the recipient
    /// - Emits a CloseCreditAccount event
    ///
    
    
    
    
    function closeCreditAccount(
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// - Computes the total value and checks that hf < 1. An account can't be liquidated when hf >= 1.
    ///   Total value has to be computed before the multicall, otherwise the liquidator would be able
    ///   to manipulate it.
    /// - Wraps ETH to WETH and sends it to msg.sender (liquidator) if value > 0
    /// - Executes the multicall - the main purpose of a multicall when liquidating is to convert all assets to underlying
    ///   in order to pay the debt.
    /// - Liquidate credit account:
    ///    + Computes the amount that needs to be paid to the pool. If totalValue * liquidationDiscount < borrow + interest + fees,
    ///      only totalValue * liquidationDiscount has to be paid. Since liquidationDiscount < 1, the liquidator can take
    ///      totalValue * (1 - liquidationDiscount) as premium. Also computes the remaining funds to be sent to borrower
    ///      as totalValue * liquidationDiscount - amountToPool.
    ///    + Checks the underlying balance: if it is greater than amountToPool + remainingFunds, transfers the underlying
    ///      from the Credit Account and proceeds. If not, tries to transfer the shortfall from the liquidator.
    ///    + Transfers all enabled assets with non-zero balances to the "to" address, unless they are marked
    ///      to be skipped in skipTokenMask. If the liquidator is confident that all assets were converted
    ///      during the multicall, they can set the mask to uint256.max - 1, to only transfer the underlying
    ///    + If convertWETH is true, converts WETH into ETH before sending
    /// - Emits LiquidateCreditAccount event
    ///
    
    
    
    
    function liquidateCreditAccount(
        address borrower,
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// this Credit Facade is expired
    /// The general flow of liquidation is nearly the same as normal liquidations, with two main differences:
    ///     - An account can be liquidated on an expired Credit Facade even with hf > 1. However,
    ///       no accounts can be liquidated through this function if the Credit Facade is not expired.
    ///     - Liquidation premiums and fees for liquidating expired accounts are reduced.
    /// It is still possible to normally liquidate an underwater Credit Account, even when the Credit Facade
    /// is expired.
    
    
    
    
    
    function liquidateExpiredCreditAccount(
        address borrower,
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// - Borrows the requested amount from the pool
    /// - Updates the CA's borrowAmount / cumulativeIndexOpen
    ///   to correctly compute interest going forward
    /// - Performs a full collateral check
    ///
    
    function increaseDebt(uint256 amount) external;

    
    /// - Decreases the debt by paying the requested amount + accrued interest + fees back to the pool
    /// - It's also include to this payment interest accrued at the moment and fees
    /// - Updates cunulativeIndex to cumulativeIndex now
    ///
    
    function decreaseDebt(uint256 amount) external;

    
    
    
    
    function addCollateral(
        address onBehalfOf,
        address token,
        uint256 amount
    ) external payable;

    
    ///  - Wraps ETH and sends it back to msg.sender, if value > 0
    ///  - Executes the Multicall
    ///  - Performs a fullCollateralCheck to verify that hf > 1 after all actions
    
    function multicall(MultiCall[] calldata calls) external payable;

    
    
    function hasOpenedCreditAccount(address borrower)
        external
        view
        returns (bool);

    
    
    
    
    function approve(
        address targetContract,
        address token,
        uint256 amount
    ) external;

    
    
    
    function approveAccountTransfer(address from, bool state) external;

    
    
    function enableToken(address token) external;

    
    /// By default, this action is forbidden, and the user has to approve transfers from sender to itself
    /// by calling approveAccountTransfer.
    /// This is done to prevent malicious actors from transferring compromised accounts to other users.
    
    function transferAccountOwnership(address to) external;

    //
    // GETTERS
    //

    
    ///
    
    
    
    function calcTotalValue(address creditAccount)
        external
        view
        returns (uint256 total, uint256 twv);

    /**
     * @dev Calculates health factor for the credit account
     *
     *          sum(asset[i] * liquidation threshold[i])
     *   Hf = --------------------------------------------
     *         borrowed amount + interest accrued + fees
     *
     *
     * More info: https://dev.gearbox.fi/developers/credit/economy#health-factor
     *
     * @param creditAccount Credit account address
     * @return hf = Health factor in bp (see PERCENTAGE FACTOR in PercentageMath.sol)
     */
    function calcCreditAccountHealthFactor(address creditAccount)
        external
        view
        returns (uint256 hf);

    
    /// otherwise returns false
    
    function isTokenAllowed(address token) external view returns (bool);

    
    function creditManager() external view returns (ICreditManagerV2);

    
    
    
    function transfersAllowed(address from, address to)
        external
        view
        returns (bool);

    
    
    
    function params()
        external
        view
        returns (
            uint128 maxBorrowedAmountPerBlock,
            bool isIncreaseDebtForbidden,
            uint40 expirationDate
        );

    
    
    function limits()
        external
        view
        returns (uint128 minBorrowedAmount, uint128 maxBorrowedAmount);

    
    function degenNFT() external view returns (address);

    
    function underlying() external view returns (address);
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// 
pragma solidity ^0.8.10;


interface IBaseRewardPool {
    //
    // STATE CHANGING FUNCTIONS
    //

    function stake(uint256 _amount) external returns (bool);

    function stakeAll() external returns (bool);

    function stakeFor(address _for, uint256 _amount) external returns (bool);

    function withdraw(uint256 amount, bool claim) external returns (bool);

    function withdrawAll(bool claim) external;

    function withdrawAndUnwrap(uint256 amount, bool claim)
        external
        returns (bool);

    function withdrawAllAndUnwrap(bool claim) external;

    function getReward(address _account, bool _claimExtras)
        external
        returns (bool);

    function getReward() external returns (bool);

    function donate(uint256 _amount) external returns (bool);

    //
    // GETTERS
    //

    function earned(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function extraRewardsLength() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function rewardToken() external view returns (IERC20);

    function stakingToken() external view returns (IERC20);

    function duration() external view returns (uint256);

    function operator() external view returns (address);

    function rewardManager() external view returns (address);

    function pid() external view returns (uint256);

    function periodFinish() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function queuedRewards() external view returns (uint256);

    function currentRewards() external view returns (uint256);

    function historicalRewards() external view returns (uint256);

    function newRewardRatio() external view returns (uint256);

    function userRewardPerTokenPaid(address account)
        external
        view
        returns (uint256);

    function rewards(address account) external view returns (uint256);

    function extraRewards(uint256 i) external view returns (address);
}// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

















contract ConvexV1BoosterAdapter is
    AbstractAdapter,
    IBooster,
    ACLTrait,
    ReentrancyGuard
{
    
    address public immutable crv;

    
    address public immutable minter;

    
    mapping(uint256 => address) public pidToPhantomToken;

    AdapterType public constant _gearboxAdapterType =
        AdapterType.CONVEX_V1_BOOSTER;
    uint16 public constant _gearboxAdapterVersion = 1;

    
    
    
    constructor(address _creditManager, address _booster)
        ACLTrait(
            address(
                IPoolService(ICreditManagerV2(_creditManager).poolService())
                    .addressProvider()
            )
        )
        AbstractAdapter(_creditManager, _booster)
    {
        crv = IBooster(_booster).crv(); // F: [ACVX1_B_01]
        minter = IBooster(_booster).minter(); // F: [ACVX1_B_01]
    }

    
    
    
    
    /// The input token does not need to be disabled, because this does not spend the entire
    /// balance, generally
    function deposit(
        uint256 _pid,
        uint256,
        bool _stake
    ) external returns (bool) {
        return _deposit(_pid, _stake, msg.data, false);
    }

    
    
    
    /// The input token does need to be disabled, because this spends the entire balance
    function depositAll(uint256 _pid, bool _stake) external returns (bool) {
        return _deposit(_pid, _stake, msg.data, true);
    }

    
    /// - Invokes a safe allowance fast check call to target, with passed calldata
    
    
    
    
    /// Input token: Curve LP Token
    /// Output token: Phantom token if _stake == true, otherwise Convex LP Token
    /// Input token is allowed, since the target does a transferFrom of Curve LP tokens
    function _deposit(
        uint256 _pid,
        bool _stake,
        bytes memory callData,
        bool disableTokenIn
    ) internal returns (bool) {
        PoolInfo memory pool = IBooster(targetContract).poolInfo(_pid);

        address tokenIn = pool.lptoken; // F: [ACVX1_B_02-05]
        address tokenOut = _stake ? pidToPhantomToken[_pid] : pool.token; // F: [ACVX1_B_02-05]

        _safeExecuteFastCheck(
            tokenIn,
            tokenOut,
            callData,
            true,
            disableTokenIn
        );

        return true;
    }

    
    
    
    /// The input token does not need to be disabled, because this does not spend the entire
    /// balance, generally
    function withdraw(uint256 _pid, uint256) external returns (bool) {
        return _withdraw(_pid, msg.data, false);
    }

    
    
    /// The input token does need to be disabled, because this spends the entire balance
    function withdrawAll(uint256 _pid) external returns (bool) {
        return _withdraw(_pid, msg.data, true);
    }

    
    /// - Invokes a safe allowance fast check call to target, with passed calldata
    
    
    
    /// Input token: Convex LP token
    /// Output token: Curve LP token
    /// Input token is not allowed, since the target directly burns Convex LP tokens
    function _withdraw(
        uint256 _pid,
        bytes memory callData,
        bool disableTokenIn
    ) internal returns (bool) {
        PoolInfo memory pool = IBooster(targetContract).poolInfo(_pid);

        address tokenIn = pool.token; // F: [ACVX1_B_06-07]
        address tokenOut = pool.lptoken; // F: [ACVX1_B_06-07]

        _safeExecuteFastCheck(
            tokenIn,
            tokenOut,
            callData,
            false,
            disableTokenIn
        );

        return true;
    }

    //
    // GETTERS
    //

    
    
    function poolInfo(uint256 i) external view returns (PoolInfo memory) {
        return IBooster(targetContract).poolInfo(i); // F: [ACVX1_B_08]
    }

    
    function poolLength() external view returns (uint256) {
        return IBooster(targetContract).poolLength(); // F: [ACVX1_B_08]
    }

    
    function staker() external view returns (address) {
        return IBooster(targetContract).staker(); // F: [ACVX1_B_08]
    }

    
    function registry() external view returns (address) {
        return IBooster(targetContract).registry();
    }

    
    function stakerRewards() external view returns (address) {
        return IBooster(targetContract).stakerRewards();
    }

    
    function lockRewards() external view returns (address) {
        return IBooster(targetContract).lockRewards();
    }

    
    function lockFees() external view returns (address) {
        return IBooster(targetContract).lockFees();
    }

    ///
    /// CONFIGURATION
    ///

    
    /// - Iterates through all known adapters
    /// - If an adapter is a BaseRewardPool adapter, gets the pid and the phantom token address,
    /// and adds them to the mapping
    
    /// the user deposits with staking
    function updateStakedPhantomTokensMap() external configuratorOnly {
        ICreditConfigurator cc = ICreditConfigurator(
            creditManager.creditConfigurator()
        );

        address[] memory allowedContracts = cc.allowedContracts();
        uint256 len = allowedContracts.length;

        for (uint256 i = 0; i < len; ) {
            address allowedContract = allowedContracts[i];

            address adapter = creditManager.contractToAdapter(allowedContract);
            AdapterType aType = IAdapter(adapter)._gearboxAdapterType();

            if (aType == AdapterType.CONVEX_V1_BASE_REWARD_POOL) {
                uint256 pid = IConvexV1BaseRewardPoolAdapter(adapter).pid();
                pidToPhantomToken[pid] = IConvexV1BaseRewardPoolAdapter(adapter)
                    .stakedPhantomToken();
            }

            unchecked {
                ++i;
            }
        }
    }
}



///   - Adding/removing pool liquidity
///   - Managing diesel tokens & diesel rates
///   - Taking/repaying Credit Manager debt
/// More: https://dev.gearbox.fi/developers/pool/abstractpoolservice
interface IPoolService is IPoolServiceEvents, IVersion {
    //
    // LIQUIDITY MANAGEMENT
    //

    /**
     * @dev Adds liquidity to pool
     * - transfers the underlying to the pool
     * - mints Diesel (LP) tokens to onBehalfOf
     * @param amount Amount of tokens to be deposited
     * @param onBehalfOf The address that will receive the dToken
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without a facilitator.
     */
    function addLiquidity(
        uint256 amount,
        address onBehalfOf,
        uint256 referralCode
    ) external;

    /**
     * @dev Removes liquidity from pool
     * - burns LP's Diesel (LP) tokens
     * - returns the equivalent amount of underlying to 'to'
     * @param amount Amount of Diesel tokens to burn
     * @param to Address to transfer the underlying to
     */

    function removeLiquidity(uint256 amount, address to)
        external
        returns (uint256);

    /**
     * @dev Lends pool funds to a Credit Account
     * @param borrowedAmount Credit Account's debt principal
     * @param creditAccount Credit Account's address
     */
    function lendCreditAccount(uint256 borrowedAmount, address creditAccount)
        external;

    /**
     * @dev Repays the Credit Account's debt
     * @param borrowedAmount Amount of principal ro repay
     * @param profit The treasury profit from repayment
     * @param loss Amount of underlying that the CA wan't able to repay
     * @notice Assumes that the underlying (including principal + interest + fees)
     *         was already transferred
     */
    function repayCreditAccount(
        uint256 borrowedAmount,
        uint256 profit,
        uint256 loss
    ) external;

    //
    // GETTERS
    //

    /**
     * @dev Returns the total amount of liquidity in the pool, including borrowed and available funds
     */
    function expectedLiquidity() external view returns (uint256);

    /**
     * @dev Returns the limit on total liquidity
     */
    function expectedLiquidityLimit() external view returns (uint256);

    /**
     * @dev Returns the available liquidity, which is expectedLiquidity - totalBorrowed
     */
    function availableLiquidity() external view returns (uint256);

    /**
     * @dev Calculates the current interest index, RAY format
     */
    function calcLinearCumulative_RAY() external view returns (uint256);

    /**
     * @dev Calculates the current borrow rate, RAY format
     */
    function borrowAPY_RAY() external view returns (uint256);

    /**
     * @dev Returns the total borrowed amount (includes principal only)
     */
    function totalBorrowed() external view returns (uint256);

    /**
     * ç
     **/

    function getDieselRate_RAY() external view returns (uint256);

    /**
     * @dev Returns the address of the underlying
     */
    function underlyingToken() external view returns (address);

    /**
     * @dev Returns the address of the diesel token
     */
    function dieselToken() external view returns (address);

    /**
     * @dev Returns the address of a Credit Manager by its id
     */
    function creditManagers(uint256 id) external view returns (address);

    /**
     * @dev Returns the number of known Credit Managers
     */
    function creditManagersCount() external view returns (uint256);

    /**
     * @dev Maps Credit Manager addresses to their status as a borrower.
     *      Returns false if borrowing is not allowed.
     */
    function creditManagersCanBorrow(address id) external view returns (bool);

    
    function toDiesel(uint256 amount) external view returns (uint256);

    
    function fromDiesel(uint256 amount) external view returns (uint256);

    
    function withdrawFee() external view returns (uint256);

    
    function _timestampLU() external view returns (uint256);

    
    function _cumulativeIndex_RAY() external view returns (uint256);

    
    function addressProvider() external view returns (AddressProvider);
}

interface ICreditConfigurator is
    ICreditConfiguratorEvents,
    ICreditConfiguratorExceptions,
    IVersion
{
    //
    // STATE-CHANGING FUNCTIONS
    //

    
    
    
    function addCollateralToken(address token, uint16 liquidationThreshold)
        external;

    
    
    
    function setLiquidationThreshold(address token, uint16 liquidationThreshold)
        external;

    
    
    function allowToken(address token) external;

    
    /// Forbidden tokens are counted as collateral during health checks, however, they cannot be enabled
    /// or received as a result of adapter operation anymore. This means that a token can never be
    /// acquired through adapter operations after being forbidden.
    
    function forbidToken(address token) external;

    
    /// or updates adapter address if a contract already has a connected adapter
    
    
    function allowContract(address targetContract, address adapter) external;

    
    
    function forbidContract(address targetContract) external;

    
    
    
    function setLimits(uint128 _minBorrowedAmount, uint128 _maxBorrowedAmount)
        external;

    
    
    
    
    
    
    function setFees(
        uint16 _feeInterest,
        uint16 _feeLiquidation,
        uint16 _liquidationPremium,
        uint16 _feeLiquidationExpired,
        uint16 _liquidationPremiumExpired
    ) external;

    
    /// from the address provider
    function upgradePriceOracle() external;

    
    
    
    function upgradeCreditFacade(address _creditFacade, bool migrateParams)
        external;

    
    
    function upgradeCreditConfigurator(address _creditConfigurator) external;

    
    /// In Credit Facade (and, consequently, the Credit Manager)
    
    function setIncreaseDebtForbidden(bool _mode) external;

    
    
    function setLimitPerBlock(uint128 newLimit) external;

    
    
    
    /// Or other practices and patterns potentially detrimental to security;
    /// Contracts from the list have certain restrictions applied to them
    function addContractToUpgradeable(address addr) external;

    
    
    function removeContractFromUpgradeable(address addr) external;

    
    /// To a CreditManager with an expirable pool
    
    function setExpirationDate(uint40 newExpirationDate) external;

    
    
    
    /// can make liquidations and health checks prohibitively expensive in terms of gas,
    /// hence the number is limited
    function setMaxEnabledTokens(uint8 maxEnabledTokens) external;

    
    
    
    /// that are able to liquidate positions while the contracts are paused,
    /// e.g. when there is a risk of bad debt while an exploit is being patched.
    /// In the interest of fairness, emergency liquidators do not receive a premium
    /// And are compensated by the Gearbox DAO separately.
    function addEmergencyLiquidator(address liquidator) external;

    
    
    function removeEmergencyLiquidator(address liquidator) external;

    //
    // GETTERS
    //

    
    function addressProvider() external view returns (IAddressProvider);

    
    function creditFacade() external view returns (CreditFacade);

    
    function creditManager() external view returns (CreditManager);

    
    function underlying() external view returns (address);

    
    function allowedContracts() external view returns (address[] memory);
}

interface IConvexV1BaseRewardPoolAdapter is
    IAdapter,
    IBaseRewardPool,
    IConvexV1BaseRewardPoolAdapterErrors
{
    
    ///      staked in the adapter's targer Convex pool
    function curveLPtoken() external view returns (address);

    
    ///      a Credit Account's staked balance in a Convex
    ///      pool
    function stakedPhantomToken() external view returns (address);

    
    
    function extraReward1() external view returns (address);

    
    
    function extraReward2() external view returns (address);

    
    function cvx() external view returns (address);
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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

interface IPriceOracleV2Ext is IPriceOracleV2 {
    
    
    
    function addPriceFeed(address token, address priceFeed) external;
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

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

// LIBRARIES







// INTERFACES








// CONSTANTS




uint256 constant ADDR_BIT_SIZE = 160;
uint256 constant INDEX_PRECISION = 10**9;

struct Slot1 {
    
    uint16 feeInterest;
    
    uint16 feeLiquidation;
    
    /// At liquidation, the borrower's funds are discounted, and the pool is paid out of discounted value
    /// The liquidator takes the difference between the discounted and actual values as premium.
    uint16 liquidationDiscount;
    
    uint16 feeLiquidationExpired;
    
    /// liquidationDiscount (meaning lower premium).
    uint16 liquidationDiscountExpired;
    
    IPriceOracleV2 priceOracle;
    
    uint16 ltUnderlying;
}



///
/// More info: https://dev.gearbox.fi/developers/credit/credit_manager
contract CreditManager is ICreditManagerV2, ACLTrait {
    using SafeERC20 for IERC20;
    using Address for address payable;
    using SafeCast for uint256;

    
    /// since there are other non-zero values packed into the same slot
    bool private entered;

    bool public emergencyLiquidation;

    
    uint8 public override maxAllowedEnabledTokenLength = 12;

    
    address public override creditFacade;

    
    Slot1 internal slot1;

    
    mapping(address => address) public override creditAccounts;

    
    IAccountFactory public immutable _accountFactory;

    
    address public immutable override underlying;

    
    
    address public immutable override poolService;

    
    address public immutable override pool;

    
    address public immutable override wethAddress;

    
    address public immutable wethGateway;

    
    address public creditConfigurator;

    
    
    mapping(uint256 => uint256) internal collateralTokensCompressed;

    
    uint256 public collateralTokensCount;

    
    
    ///         the token's index (i.e., tokenMask = 2 ** index)
    ///         Masks are used to efficiently check set inclusion, since it only involves
    ///         a single AND and comparison to zero
    mapping(address => uint256) internal tokenMasksMapInternal;

    
    uint256 public override forbiddenTokenMask;

    
    /// Only enabled tokens are counted as collateral for the Credit Account
    
    ///         the bit at the position equal to token's index to 1
    mapping(address => uint256) public override enabledTokensMap;

    
    /// See more details in fastCollateralCheck()
    mapping(address => uint256) public cumulativeDropAtFastCheckRAY;

    
    mapping(address => address) public override adapterToContract;

    
    mapping(address => address) public override contractToAdapter;

    
    
    /// that are able to liquidate positions while the contracts are paused,
    /// e.g. when there is a risk of bad debt while an exploit is being patched.
    /// In the interest of fairness, emergency liquidators do not receive a premium
    /// And are compensated by the Gearbox DAO separately.
    mapping(address => bool) public override canLiquidateWhilePaused;

    
    
    address public universalAdapter;

    
    uint256 public constant override version = 2;

    //
    // MODIFIERS
    //

    
    
    modifier nonReentrant() {
        if (entered) {
            revert ReentrancyLockException();
        }

        entered = true;
        _;
        entered = false;
    }

    
    modifier adaptersOrCreditFacadeOnly() {
        if (
            adapterToContract[msg.sender] == address(0) &&
            msg.sender != creditFacade
        ) revert AdaptersOrCreditFacadeOnlyException(); //
        _;
    }

    
    modifier creditFacadeOnly() {
        if (msg.sender != creditFacade) revert CreditFacadeOnlyException();
        _;
    }

    
    modifier creditConfiguratorOnly() {
        if (msg.sender != creditConfigurator)
            revert CreditConfiguratorOnlyException();
        _;
    }

    modifier whenNotPausedOrEmergency() {
        require(!paused() || emergencyLiquidation, "Pausable: paused");
        _;
    }

    
    
    constructor(address _pool)
        ACLTrait(address(IPoolService(_pool).addressProvider()))
    {
        IAddressProvider addressProvider = IPoolService(_pool)
            .addressProvider();

        pool = _pool; // F:[CM-1]
        poolService = _pool; // F:[CM-1]

        address _underlying = IPoolService(pool).underlyingToken(); // F:[CM-1]
        underlying = _underlying; // F:[CM-1]

        // The underlying is the first token added as collateral
        _addToken(_underlying); // F:[CM-1]

        wethAddress = addressProvider.getWethToken(); // F:[CM-1]
        wethGateway = addressProvider.getWETHGateway(); // F:[CM-1]

        // Price oracle is stored in Slot1, as it is accessed frequently with fees
        slot1.priceOracle = IPriceOracleV2(addressProvider.getPriceOracle()); // F:[CM-1]
        _accountFactory = IAccountFactory(addressProvider.getAccountFactory()); // F:[CM-1]
        creditConfigurator = msg.sender; // F:[CM-1]
    }

    //
    // CREDIT ACCOUNT MANAGEMENT
    //

    
    /// - Takes Credit Account from the factory;
    /// - Requests the pool to lend underlying to the Credit Account
    ///
    
    
    function openCreditAccount(uint256 borrowedAmount, address onBehalfOf)
        external
        override
        whenNotPaused // F:[CM-5]
        nonReentrant
        creditFacadeOnly // F:[CM-2]
        returns (address)
    {
        // Takes a Credit Account from the factory and sets initial parameters
        // The Credit Account will be connected to this Credit Manager until closing
        address creditAccount = _accountFactory.takeCreditAccount(
            borrowedAmount,
            IPoolService(pool).calcLinearCumulative_RAY()
        ); // F:[CM-8]

        // Requests the pool to transfer tokens the Credit Account
        IPoolService(pool).lendCreditAccount(borrowedAmount, creditAccount); // F:[CM-8]

        // Checks that the onBehalfOf does not already have an account, and records it as owner
        _safeCreditAccountSet(onBehalfOf, creditAccount); // F:[CM-7]

        // Initializes the enabled token mask for Credit Account to 1 (only the underlying is enabled)
        enabledTokensMap[creditAccount] = 1; // F:[CM-8]

        // Returns the address of the opened Credit Account
        return creditAccount; // F:[CM-8]
    }

    
    /// - Checks whether the contract is paused, and, if so, if the payer is an emergency liquidator.
    ///   Only emergency liquidators are able to liquidate account while the CM is paused.
    ///   Emergency liquidations do not pay a liquidator premium or liquidation fees.
    /// - Calculates payments to various recipients on closure:
    ///    + Computes amountToPool, which is the amount to be sent back to the pool.
    ///      This includes the principal, interest and fees, but can't be more than
    ///      total position value
    ///    + Computes remainingFunds during liquidations - these are leftover funds
    ///      after paying the pool and the liquidator, and are sent to the borrower
    ///    + Computes protocol profit, which includes interest and liquidation fees
    ///    + Computes loss if the totalValue is less than borrow amount + interest
    /// - Checks the underlying token balance:
    ///    + if it is larger than amountToPool, then the pool is paid fully from funds on the Credit Account
    ///    + else tries to transfer the shortfall from the payer - either the borrower during closure, or liquidator during liquidation
    /// - Send assets to the "to" address, as long as they are not included into skipTokenMask
    /// - If convertWETH is true, the function converts WETH into ETH before sending
    /// - Returns the Credit Account back to factory
    ///
    
    
    
    
    
    
    
    function closeCreditAccount(
        address borrower,
        ClosureAction closureActionType,
        uint256 totalValue,
        address payer,
        address to,
        uint256 skipTokenMask,
        bool convertWETH
    )
        external
        override
        nonReentrant
        creditFacadeOnly // F:[CM-2]
        returns (uint256 remainingFunds)
    {
        // If the contract is paused and the payer is the emergency liquidator,
        // changes closure action to LIQUIDATE_PAUSED, so that the premium is nullified
        // If the payer is not an emergency liquidator, reverts
        if (paused()) {
            if (
                canLiquidateWhilePaused[payer] &&
                (closureActionType == ClosureAction.LIQUIDATE_ACCOUNT ||
                    closureActionType ==
                    ClosureAction.LIQUIDATE_EXPIRED_ACCOUNT)
            ) {
                closureActionType = ClosureAction.LIQUIDATE_PAUSED; // F: [CM-12, 13]
            } else revert("Pausable: paused"); // F:[CM-5]
        }

        // Checks that the Credit Account exists for the borrower
        address creditAccount = getCreditAccountOrRevert(borrower); // F:[CM-6, 9, 10]

        // Sets borrower's Credit Account to zero address in the map
        // This needs to be done before other actions, to prevent inconsistent state
        // in the middle of closing transaction - e.g., _transferAssetsTo can be used to report a lower
        // value of a CA to third parties before the end of the function execution, since it
        // gives up control flow when some assets are already removed from the account
        delete creditAccounts[borrower]; // F:[CM-9]

        // Makes all computations needed to close credit account
        uint256 amountToPool;
        uint256 borrowedAmount;

        {
            uint256 profit;
            uint256 loss;
            uint256 borrowedAmountWithInterest;
            (
                borrowedAmount,
                borrowedAmountWithInterest,

            ) = calcCreditAccountAccruedInterest(creditAccount); // F:

            (amountToPool, remainingFunds, profit, loss) = calcClosePayments(
                totalValue,
                closureActionType,
                borrowedAmount,
                borrowedAmountWithInterest
            ); // F:[CM-10,11,12]

            uint256 underlyingBalance = IERC20(underlying).balanceOf(
                creditAccount
            );

            // If there is an underlying surplus, transfers it to the "to" address
            if (underlyingBalance > amountToPool + remainingFunds + 1) {
                unchecked {
                    _safeTokenTransfer(
                        creditAccount,
                        underlying,
                        to,
                        underlyingBalance - amountToPool - remainingFunds - 1,
                        convertWETH
                    ); // F:[CM-10,12,16]
                }
                // If there is an underlying shortfall, attempts to transfer it from the payer
            } else {
                unchecked {
                    IERC20(underlying).safeTransferFrom(
                        payer,
                        creditAccount,
                        amountToPool + remainingFunds - underlyingBalance + 1
                    ); // F:[CM-11,13]
                }
            }

            // Transfers the due funds to the pool
            _safeTokenTransfer(
                creditAccount,
                underlying,
                pool,
                amountToPool,
                false
            ); // F:[CM-10,11,12,13]

            // Signals to the pool that debt has been repaid. The pool relies
            // on the Credit Manager to repay the debt correctly, and does not
            // check internally whether the underlying was actually transferred
            IPoolService(pool).repayCreditAccount(borrowedAmount, profit, loss); // F:[CM-10,11,12,13]
        }

        // transfer remaining funds to the borrower [liquidations only]
        if (remainingFunds > 1) {
            _safeTokenTransfer(
                creditAccount,
                underlying,
                borrower,
                remainingFunds,
                false
            ); // F:[CM-13,18]
        }

        // Tokens in skipTokenMask are disabled before transferring all assets
        uint256 enabledTokensMask = enabledTokensMap[creditAccount] &
            ~skipTokenMask; // F:[CM-14]
        _transferAssetsTo(creditAccount, to, convertWETH, enabledTokensMask); // F:[CM-14,17,19]

        // Returns Credit Account to the factory
        _accountFactory.returnCreditAccount(creditAccount); // F:[CM-9]
    }

    
    ///
    /// - Increase debt:
    ///   + Increases debt by transferring funds from the pool to the credit account
    ///   + Updates the cumulative index to keep interest the same. Since interest
    ///     is always computed dynamically as borrowedAmount * (cumulativeIndexNew / cumulativeIndexOpen - 1),
    ///     cumulativeIndexOpen needs to be updated, as the borrow amount has changed
    ///
    /// - Decrease debt:
    ///   + Repays debt partially + all interest and fees accrued thus far
    ///   + Updates cunulativeIndex to cumulativeIndex now
    ///
    
    
    
    
    function manageDebt(
        address creditAccount,
        uint256 amount,
        bool increase
    )
        external
        whenNotPaused // F:[CM-5]
        nonReentrant
        creditFacadeOnly // F:[CM-2]
        returns (uint256 newBorrowedAmount)
    {
        (
            uint256 borrowedAmount,
            uint256 cumulativeIndexAtOpen_RAY,
            uint256 cumulativeIndexNow_RAY
        ) = _getCreditAccountParameters(creditAccount);

        uint256 newCumulativeIndex;
        if (increase) {
            newBorrowedAmount = borrowedAmount + amount;

            // Computes the new cumulative index to keep the interest
            // unchanged with different principal

            newCumulativeIndex = _calcNewCumulativeIndex(
                borrowedAmount,
                amount,
                cumulativeIndexNow_RAY,
                cumulativeIndexAtOpen_RAY,
                true
            );

            // Requests the pool to lend additional funds to the Credit Account
            IPoolService(pool).lendCreditAccount(amount, creditAccount); // F:[CM-20]
        } else {
            // Computes the interest accrued thus far
            uint256 interestAccrued = (borrowedAmount *
                cumulativeIndexNow_RAY) /
                cumulativeIndexAtOpen_RAY -
                borrowedAmount; // F:[CM-21]

            // Computes profit, taken as a percentage of the interest rate
            uint256 profit = (interestAccrued * slot1.feeInterest) /
                PERCENTAGE_FACTOR; // F:[CM-21]

            if (amount >= interestAccrued + profit) {
                // If the amount covers all of the interest and fees, they are
                // paid first, and the remainder is used to pay the principal
                newBorrowedAmount =
                    borrowedAmount +
                    interestAccrued +
                    profit -
                    amount;

                // Pays the amount back to the pool
                ICreditAccount(creditAccount).safeTransfer(
                    underlying,
                    pool,
                    amount
                ); // F:[CM-21]

                // Signals the pool that the debt was partially repaid
                IPoolService(pool).repayCreditAccount(
                    amount - interestAccrued - profit,
                    profit,
                    0
                ); // F:[CM-21]

                // Since interest is fully repaid, the Credit Account's cumulativeIndexAtOpen
                // is set to the current cumulative index - which means interest starts accruing
                // on the new principal from zero
                newCumulativeIndex = IPoolService(pool)
                    .calcLinearCumulative_RAY(); // F:[CM-21]
            } else {
                // If the amount is not enough to cover interest and fees,
                // it is split between the two pro-rata. Since the fee is the percentage
                // of interest, this ensures that the new fee is consistent with the
                // new pending interest
                uint256 amountToInterest = (amount * PERCENTAGE_FACTOR) /
                    (PERCENTAGE_FACTOR + slot1.feeInterest);
                uint256 amountToFees = amount - amountToInterest;

                // Since interest and fees are paid out first, the principal
                // remains unchanged
                newBorrowedAmount = borrowedAmount;

                // Pays the amount back to the pool
                ICreditAccount(creditAccount).safeTransfer(
                    underlying,
                    pool,
                    amount
                ); // F:[CM-21]

                // Signals the pool that the debt was partially repaid
                IPoolService(pool).repayCreditAccount(0, amountToFees, 0); // F:[CM-21]

                // Since the interest was only repaid partially, we need to recompute the
                // cumulativeIndexAtOpen, so that "borrowAmount * (indexNow / indexAtOpenNew - 1)"
                // is equal to interestAccrued - amountToInterest

                newCumulativeIndex = _calcNewCumulativeIndex(
                    borrowedAmount,
                    amountToInterest,
                    cumulativeIndexNow_RAY,
                    cumulativeIndexAtOpen_RAY,
                    false
                );
            }
        }
        //
        // Sets new parameters on the Credit Account
        ICreditAccount(creditAccount).updateParameters(
            newBorrowedAmount,
            newCumulativeIndex
        ); // F:[CM-20. 21]
    }

    
    
    
    
    
    
    
    ///         * Debt principal is increased by delta - in this case, the principal is changed
    ///           but the interest / fees have to stay the same
    ///         * Interest is decreased by delta - in this case, the principal stays the same,
    ///           but the interest changes. The delta is assumed to have fee repayment excluded.
    ///         The debt decrease case where delta > interest + fees is trivial and should be handled outside
    ///         this function.
    function _calcNewCumulativeIndex(
        uint256 borrowedAmount,
        uint256 delta,
        uint256 cumulativeIndexNow,
        uint256 cumulativeIndexOpen,
        bool isIncrease
    ) internal pure returns (uint256 newCumulativeIndex) {
        if (isIncrease) {
            // In case of debt increase, the principal increases by exactly delta, but interest has to be kept unchanged
            // newCumulativeIndex is proven to be the solution to
            // borrowedAmount * (cumulativeIndexNow / cumulativeIndexOpen - 1) ==
            // == (borrowedAmount + delta) * (cumulativeIndexNow / newCumulativeIndex - 1)

            uint256 newBorrowedAmount = borrowedAmount + delta;

            newCumulativeIndex = ((cumulativeIndexNow *
                newBorrowedAmount *
                INDEX_PRECISION) /
                ((INDEX_PRECISION * cumulativeIndexNow * borrowedAmount) /
                    cumulativeIndexOpen +
                    INDEX_PRECISION *
                    delta));
        } else {
            // In case of debt decrease, the principal is the same, but the interest is reduced exactly by delta
            // newCumulativeIndex is proven to be the solution to
            // borrowedAmount * (cumulativeIndexNow / cumulativeIndexOpen - 1) - delta ==
            // == borrowedAmount * (cumulativeIndexNow / newCumulativeIndex - 1)

            newCumulativeIndex =
                (INDEX_PRECISION * cumulativeIndexNow * cumulativeIndexOpen) /
                (INDEX_PRECISION *
                    cumulativeIndexNow -
                    (INDEX_PRECISION * delta * cumulativeIndexOpen) /
                    borrowedAmount);
        }
    }

    
    
    
    
    
    function addCollateral(
        address payer,
        address creditAccount,
        address token,
        uint256 amount
    )
        external
        whenNotPaused // F:[CM-5]
        nonReentrant
        creditFacadeOnly // F:[CM-2]
    {
        // Checks that the token is not forbidden
        // And enables it so that it is counted in collateral
        _checkAndEnableToken(creditAccount, token); // F:[CM-22]

        IERC20(token).safeTransferFrom(payer, creditAccount, amount); // F:[CM-22]
    }

    
    
    
    function transferAccountOwnership(address from, address to)
        external
        override
        whenNotPausedOrEmergency // F:[CM-5]
        nonReentrant
        creditFacadeOnly // F:[CM-2]
    {
        address creditAccount = getCreditAccountOrRevert(from); // F:[CM-6]
        delete creditAccounts[from]; // F:[CM-24]

        _safeCreditAccountSet(to, creditAccount); // F:[CM-23, 24]
    }

    
    
    
    
    
    function approveCreditAccount(
        address borrower,
        address targetContract,
        address token,
        uint256 amount
    )
        external
        override
        whenNotPausedOrEmergency // F:[CM-5]
        nonReentrant
    {
        // This function can only be called by connected adapters (must be a correct adapter/contract pair),
        // Credit Facade or Universal Adapter
        if (
            (adapterToContract[msg.sender] != targetContract &&
                msg.sender != creditFacade &&
                msg.sender != universalAdapter) || targetContract == address(0)
        ) {
            revert AdaptersOrCreditFacadeOnlyException(); // F:[CM-3,25]
        }

        // Checks that the token is a collateral token
        // Forbidden tokens can be approved, since users need that to
        // sell them off
        if (tokenMasksMap(token) == 0) revert TokenNotAllowedException(); // F:

        address creditAccount = getCreditAccountOrRevert(borrower); // F:[CM-6]

        // Attempts to set allowance directly to the required amount
        // If unsuccessful, assumes that the token requires setting allowance to zero first
        if (!_approve(token, targetContract, creditAccount, amount, false)) {
            _approve(token, targetContract, creditAccount, 0, true); // F:
            _approve(token, targetContract, creditAccount, amount, true);
        }
    }

    
    /// Uses Credit Account's execute to properly handle both ERC20-compliant and
    /// non-compliant (no returned value from "approve") tokens
    function _approve(
        address token,
        address targetContract,
        address creditAccount,
        uint256 amount,
        bool revertIfFailed
    ) internal returns (bool) {
        // Makes a low-level call to approve from the Credit Account
        // and parses the value. If nothing or true was returned,
        // assumes that the call succeeded
        try
            ICreditAccount(creditAccount).execute(
                token,
                abi.encodeWithSelector(
                    IERC20.approve.selector,
                    targetContract,
                    amount
                )
            )
        returns (bytes memory result) {
            if (result.length == 0 || abi.decode(result, (bool)) == true)
                return true;
        } catch {}

        // On the first try, failure is allowed to handle tokens
        // that prohibit changing allowance from non-zero value;
        // After that, failure results in a revert
        if (revertIfFailed) revert AllowanceFailedException();
        return false;
    }

    
    /// This is the intended pathway for state-changing interactions with 3rd-party protocols
    
    
    
    function executeOrder(
        address borrower,
        address targetContract,
        bytes memory data
    )
        external
        override
        whenNotPausedOrEmergency // F:[CM-5]
        nonReentrant
        returns (bytes memory)
    {
        // Checks that msg.sender is the adapter associated with the passed
        // target contract. The exception is the Universal Adapter, which
        // can potentially call any target.
        if (
            adapterToContract[msg.sender] != targetContract ||
            targetContract == address(0)
        ) {
            if (msg.sender != universalAdapter)
                revert TargetContractNotAllowedException(); // F:[CM-28]
        }

        address creditAccount = getCreditAccountOrRevert(borrower); // F:[CM-6]

        // Emits an event
        emit ExecuteOrder(borrower, targetContract); // F:[CM-29]

        // Returned data is provided as-is to the caller;
        // It is expected that is is parsed and returned as a correct type
        // by the adapter itself.
        return ICreditAccount(creditAccount).execute(targetContract, data); // F:[CM-29]
    }

    //
    // COLLATERAL VALIDITY AND ACCOUNT HEALTH CHECKS
    //

    
    /// into account health and total value calculations
    
    
    function checkAndEnableToken(address creditAccount, address token)
        external
        override
        whenNotPausedOrEmergency
        adaptersOrCreditFacadeOnly // F:[CM-3]
        nonReentrant
    {
        _checkAndEnableToken(creditAccount, token); // F:[CM-30]
    }

    
    
    
    function _checkAndEnableToken(address creditAccount, address token)
        internal
    {
        uint256 tokenMask = tokenMasksMap(token); // F:[CM-30,31]

        // Checks that the token is valid collateral recognized by the system
        // and that it is not forbidden
        if (tokenMask == 0 || forbiddenTokenMask & tokenMask != 0)
            revert TokenNotAllowedException(); // F:[CM-30]

        // Performs an inclusion check using token masks,
        // to avoid accidentally disabling the token
        if (enabledTokensMap[creditAccount] & tokenMask == 0)
            enabledTokensMap[creditAccount] |= tokenMask; // F:[CM-31]
    }

    
    
    ///         participate in the operation and computes a % change in weighted value between
    ///         inbound and outbound collateral. The cumulative negative change across several
    ///         swaps in sequence cannot be larger than feeLiquidation (a fee that the
    ///         protocol is ready to waive if needed). Since this records a % change
    ///         between just two tokens, the corresponding % change in TWV will always be smaller,
    ///         which makes this check safe.
    ///         More details at https://dev.gearbox.fi/docs/documentation/risk/fast-collateral-check#fast-check-protection
    
    
    
    
    
    function fastCollateralCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        uint256 balanceInBefore,
        uint256 balanceOutBefore
    )
        external
        override
        adaptersOrCreditFacadeOnly // F:[CM-3]
        nonReentrant
    {
        // Checks that inbound collateral is known and not forbidden
        // Enables it if disabled, to include it into TWV
        _checkAndEnableToken(creditAccount, tokenOut); // [CM-32]

        uint256 balanceInAfter = IERC20(tokenIn).balanceOf(creditAccount); // F: [CM-34]
        uint256 balanceOutAfter = IERC20(tokenOut).balanceOf(creditAccount); // F: [CM-34]

        (uint256 amountInCollateral, uint256 amountOutCollateral) = slot1
            .priceOracle
            .fastCheck(
                balanceInBefore - balanceInAfter,
                tokenIn,
                balanceOutAfter - balanceOutBefore,
                tokenOut
            ); // F:[CM-34]

        // Disables tokenIn if the entire balance was spent by the operation
        if (balanceInAfter <= 1) _disableToken(creditAccount, tokenIn); // F:[CM-33]

        // Collateral values must be compared weighted by respective LTs,
        // as otherwise a high-LT (e.g., underlying) token can be swapped
        // to an equivalent amount of a low-LT asset. Without weighting, this would
        // pass the check (since inbound and outbound values are equal),
        // while the health factor of the account would be reduced severely.
        amountOutCollateral *= liquidationThresholds(tokenOut); // F:[CM-34]
        amountInCollateral *= liquidationThresholds(tokenIn); // F:[CM-34]

        // If the value of inbound collateral is larger than inbound collateral
        // a health check does not need to be performed;
        // However, the number of enabled tokens needs to be checked against the limit,
        // as a new collateral token was potentially enabled
        if (amountOutCollateral >= amountInCollateral) {
            _checkAndOptimizeEnabledTokens(creditAccount); // F:[CM-35]
            return; // F:[CM-34]
        }

        // The new cumulative drop in value is computed in RAY format, for precision
        uint256 cumulativeDropRAY = RAY -
            ((amountOutCollateral * RAY) / amountInCollateral) +
            cumulativeDropAtFastCheckRAY[creditAccount]; // F:[CM-36]

        // If then new cumulative drop is less than feeLiquidation, the check is successful,
        // otherwise, a full collateral check is required
        if (
            cumulativeDropRAY <=
            (slot1.feeLiquidation * RAY) / PERCENTAGE_FACTOR
        ) {
            cumulativeDropAtFastCheckRAY[creditAccount] = cumulativeDropRAY; // F:[CM-36]
            _checkAndOptimizeEnabledTokens(creditAccount); // F:[CM-37]
            return;
        }

        // If a fast collateral check didn't pass, a full check is performed and
        // the cumulative drop is reset back to 0 (1 for gas-efficiency).
        _fullCollateralCheck(creditAccount); // F:[CM-34,36]
        cumulativeDropAtFastCheckRAY[creditAccount] = 1; // F:[CM-36]
    }

    
    /// value of all enabled collateral tokens
    
    function fullCollateralCheck(address creditAccount)
        external
        override
        adaptersOrCreditFacadeOnly // F:[CM-3]
        nonReentrant
    {
        _fullCollateralCheck(creditAccount);
    }

    
    
    function _fullCollateralCheck(address creditAccount) internal {
        IPriceOracleV2 _priceOracle = slot1.priceOracle;

        uint256 enabledTokenMask = enabledTokensMap[creditAccount];
        uint256 borrowAmountPlusInterestRateUSD;
        uint256 len;
        unchecked {
            // The total weighted value of a Credit Account has to be compared
            // with the entire debt sum, including interest and fees
            (
                ,
                ,
                uint256 borrowedAmountWithInterestAndFees
            ) = calcCreditAccountAccruedInterest(creditAccount);

            borrowAmountPlusInterestRateUSD = _priceOracle.convertToUSD(
                borrowedAmountWithInterestAndFees * PERCENTAGE_FACTOR,
                underlying
            );

            len = _getMaxIndex(enabledTokenMask) + 1;
        }

        uint256 tokenMask;
        uint256 twvUSD;
        bool atLeastOneTokenWasDisabled;

        for (uint256 i; i < len; ) {
            // The order of evaluation is adjusted to optimize for
            // farming, as it is the largest expected use case
            // Since farming positions are at the end of the collateral token list
            // the loop moves through token masks in descending order (except underlying, which is
            // checked first)
            unchecked {
                tokenMask = i == 0 ? 1 : 1 << (len - i);
            }

            // CASE enabledTokenMask & tokenMask == 0 F:[CM-38]
            if (enabledTokenMask & tokenMask != 0) {
                (
                    address token,
                    uint16 liquidationThreshold
                ) = collateralTokensByMask(tokenMask);
                uint256 balance = IERC20(token).balanceOf(creditAccount);

                // Collateral calculations are only done if there is a non-zero balance
                if (balance > 1) {
                    twvUSD +=
                        _priceOracle.convertToUSD(balance, token) *
                        liquidationThreshold;

                    // Full collateral check evaluates a Credit Account's health factor lazily;
                    // Once the TWV computed thus far exceeds the debt, the check is considered
                    // successful, and the function returns without evaluating any further collateral
                    if (twvUSD >= borrowAmountPlusInterestRateUSD) {
                        // Since a full collateral check is usually called after an operation or MultiCall
                        // involving many tokens, potentially many new tokens can be enabled. As such,
                        // the function needs to check whether the enabled token limit is violated,
                        // and disable any unused tokens, if so. Note that the number of enabled tokens
                        // is calculated from the updated enabledTokenMask, so some of the unused tokens may have already
                        // been disabled
                        uint256 totalTokensEnabled = _calcEnabledTokens(
                            enabledTokenMask
                        );
                        if (totalTokensEnabled > maxAllowedEnabledTokenLength) {
                            unchecked {
                                _optimizeEnabledTokens(
                                    creditAccount,
                                    enabledTokenMask,
                                    totalTokensEnabled,
                                    // At this stage in the function, at least underlying
                                    // must have been processed, so it can be skipped
                                    1,
                                    // Since the function disables all unused tokens it finds
                                    // and iterates in descending order,
                                    // _optimizeEnabledTokens only needs to check up to len - i
                                    len - i
                                ); // F:[CM-41] where i=0
                            }
                        } else {
                            // Saves enabledTokensMask if at least one token was disabled
                            if (atLeastOneTokenWasDisabled) {
                                enabledTokensMap[
                                    creditAccount
                                ] = enabledTokenMask; // F:[CM-39]
                            }
                        }

                        return; // F:[CM-40]
                    }
                    // Zero-balance tokens are disabled; this is done by flipping the
                    // bit in enabledTokenMask, which is then written into storage at the
                    // very end, to avoid redundant storage writes
                } else {
                    enabledTokenMask ^= tokenMask; // F:[CM-39]
                    atLeastOneTokenWasDisabled = true; // F:[CM-39]
                }
            }

            unchecked {
                ++i;
            }
        }
        revert NotEnoughCollateralException();
    }

    
    ///      does not violate the maximal enabled token limit and tries
    ///      to disable unused tokens if it does
    
    function checkAndOptimizeEnabledTokens(address creditAccount)
        external
        override
        adaptersOrCreditFacadeOnly // F: [CM-2]
    {
        _checkAndOptimizeEnabledTokens(creditAccount);
    }

    
    function _checkAndOptimizeEnabledTokens(address creditAccount) internal {
        uint256 enabledTokenMask = enabledTokensMap[creditAccount];
        uint256 totalTokensEnabled = _calcEnabledTokens(enabledTokenMask);

        if (totalTokensEnabled > maxAllowedEnabledTokenLength) {
            uint256 maxIndex = _getMaxIndex(enabledTokenMask) + 1;

            _optimizeEnabledTokens(
                creditAccount,
                enabledTokenMask,
                totalTokensEnabled,
                0,
                maxIndex
            );
        }
    }

    
    ///      provided token mask
    
    function _calcEnabledTokens(uint256 enabledTokenMask)
        internal
        pure
        returns (uint256 totalTokensEnabled)
    {
        // Bit mask is a number encoding enabled tokens as 1's;
        // Therefore, to count the number of enabled tokens, we simply
        // need to keep shifting the mask by one bit and checking if the rightmost bit is 1,
        // until the whole mask is 0;
        // Since bit shifting is overflow-safe and the loop has at most 256 steps,
        // the whole function can be marked as unsafe to optimize gas
        unchecked {
            while (enabledTokenMask > 0) {
                totalTokensEnabled += enabledTokenMask & 1;
                enabledTokenMask = enabledTokenMask >> 1;
            }
        }
    }

    
    ///      on a Credit Account and disables them, until the total number
    ///      of enabled tokens is at maxAllowedEnabledTokenLength
    
    
    
    
    
    function _optimizeEnabledTokens(
        address creditAccount,
        uint256 enabledTokenMask,
        uint256 totalTokensEnabled,
        uint256 minIndex,
        uint256 maxIndex
    ) internal {
        // The whole block can be marked unchecked, since:
        // - maxIndex < 256 at all times (i.e., tokenMask < 2 ** 256);
        // - totalTokensEnabled does not go lower than maxAllowedEnabledTokenLength
        //   (the function returns at that point)
        unchecked {
            for (uint256 i = minIndex; i < maxIndex; ) {
                uint256 tokenMask = 1 << i;
                if (enabledTokenMask & tokenMask != 0) {
                    (address token, ) = collateralTokensByMask(tokenMask);
                    uint256 balance = IERC20(token).balanceOf(creditAccount);

                    if (balance <= 1) {
                        enabledTokenMask ^= tokenMask;
                        --totalTokensEnabled;
                        if (
                            totalTokensEnabled <= maxAllowedEnabledTokenLength
                        ) {
                            enabledTokensMap[creditAccount] = enabledTokenMask;
                            return;
                        }
                    }
                }

                ++i;
            }
        }
        revert TooManyEnabledTokensException();
    }

    
    
    ///         but can also be called separately from the Credit Facade to remove
    ///         unwanted tokens
    function disableToken(address creditAccount, address token)
        external
        override
        whenNotPausedOrEmergency // F:[CM-5]
        adaptersOrCreditFacadeOnly // F:[CM-3]
        nonReentrant
        returns (bool)
    {
        return _disableToken(creditAccount, token);
    }

    
    function _disableToken(address creditAccount, address token)
        internal
        returns (bool wasChanged)
    {
        // The enabled token mask encodes all enabled tokens as 1,
        // therefore the corresponding bit is set to 0 to disable it
        uint256 tokenMask = tokenMasksMap(token);
        if (enabledTokensMap[creditAccount] & tokenMask != 0) {
            enabledTokensMap[creditAccount] &= ~tokenMask; // F:[CM-46]
            wasChanged = true;
        }
    }

    
    /// and temporarily enables a special emergencyLiquidator mode to allow liquidation.
    
    /// multicalls during liquidations. emergencyLiquidation mode is enabled temporarily
    /// (for the span of a single multicall) to override
    /// the paused state and allow a special privileged role to liquidate unhealthy positions, if the
    /// contracts are paused due to an emergency.
    
    ///
    ///
    
    
    
    /// to call this function to disable the emergencyLiquidation mode.
    function checkEmergencyPausable(address caller, bool state)
        external
        creditFacadeOnly // F:[CM-2]
        returns (bool)
    {
        bool pausable = paused(); // F: [CM-67]
        if (pausable && canLiquidateWhilePaused[caller]) {
            emergencyLiquidation = state; // F: [CM-67]
        }
        return pausable; // F: [CM-67]
    }

    //
    // INTERNAL HELPERS
    //

    
    
    
    
    
    ///        in the mask will be transferred. If any tokens need to be skipped, they must be
    ///        excluded from the mask beforehand.
    function _transferAssetsTo(
        address creditAccount,
        address to,
        bool convertWETH,
        uint256 enabledTokensMask
    ) internal {
        // Since underlying should have been transferred to "to" before this function is called
        // (if there is a surplus), its tokenMask of 1 is skipped
        uint256 tokenMask = 2;

        // Since enabledTokensMask encodes all enabled tokens as 1,
        // tokenMask > enabledTokensMask is equivalent to the last 1 bit being passed
        // The loop can be ended at this point
        while (tokenMask <= enabledTokensMask) {
            // enabledTokensMask & tokenMask == tokenMask when the token is enabled,
            // and 0 otherwise
            if (enabledTokensMask & tokenMask != 0) {
                (address token, ) = collateralTokensByMask(tokenMask); // F:[CM-44]
                uint256 amount = IERC20(token).balanceOf(creditAccount); // F:[CM-44]
                if (amount > 1) {
                    // 1 is subtracted from amount to leave a non-zero value
                    // in the balance mapping, optimizing future writes
                    // Since the amount is checked to be more than 1,
                    // the block can be marked as unchecked

                    // F:[CM-44]
                    unchecked {
                        _safeTokenTransfer(
                            creditAccount,
                            token,
                            to,
                            amount - 1,
                            convertWETH
                        ); // F:[CM-44]
                    }
                }
            }

            // The loop iterates by moving 1 bit to the left,
            // which corresponds to moving on to the next token
            tokenMask = tokenMask << 1; // F:[CM-44]
        }
    }

    
    ///      Able to unwrap WETH before sending, if requested
    
    
    
    
    function _safeTokenTransfer(
        address creditAccount,
        address token,
        address to,
        uint256 amount,
        bool convertToETH
    ) internal {
        if (convertToETH && token == wethAddress) {
            ICreditAccount(creditAccount).safeTransfer(
                token,
                wethGateway,
                amount
            ); // F:[CM-45]
            IWETHGateway(wethGateway).unwrapWETH(to, amount); // F:[CM-45]
        } else {
            ICreditAccount(creditAccount).safeTransfer(token, to, amount); // F:[CM-45]
        }
    }

    
    ///      have an account already
    
    
    function _safeCreditAccountSet(address borrower, address creditAccount)
        internal
    {
        if (borrower == address(0) || creditAccounts[borrower] != address(0))
            revert ZeroAddressOrUserAlreadyHasAccountException(); // F:[CM-7]
        creditAccounts[borrower] = creditAccount; // F:[CM-7]
    }

    //
    // GETTERS
    //

    
    
    
    ///        * CLOSE_ACCOUNT: The account is healthy and is closed normally
    ///        * LIQUIDATE_ACCOUNT: The account is unhealthy and is being liquidated to avoid bad debt
    ///        * LIQUIDATE_EXPIRED_ACCOUNT: The account has expired and is being liquidated (lowered liquidation premium)
    ///        * LIQUIDATE_PAUSED: The account is liquidated while the system is paused due to emergency (no liquidation premium)
    
    
    
    
    
    
    function calcClosePayments(
        uint256 totalValue,
        ClosureAction closureActionType,
        uint256 borrowedAmount,
        uint256 borrowedAmountWithInterest
    )
        public
        view
        override
        returns (
            uint256 amountToPool,
            uint256 remainingFunds,
            uint256 profit,
            uint256 loss
        )
    {
        // The amount to be paid to pool is computed with fees included
        // The pool will compute the amount of Diesel tokens to treasury
        // based on profit
        amountToPool =
            borrowedAmountWithInterest +
            ((borrowedAmountWithInterest - borrowedAmount) *
                slot1.feeInterest) /
            PERCENTAGE_FACTOR; // F:[CM-43]

        if (
            closureActionType == ClosureAction.LIQUIDATE_ACCOUNT ||
            closureActionType == ClosureAction.LIQUIDATE_EXPIRED_ACCOUNT ||
            closureActionType == ClosureAction.LIQUIDATE_PAUSED
        ) {
            // LIQUIDATION CASE
            uint256 totalFunds;

            // During liquidation, totalValue of the account is discounted
            // by (1 - liquidationPremium). This means that totalValue * liquidationPremium
            // is removed from all calculations and can be claimed by the liquidator at the end of transaction

            // The liquidation premium depends on liquidation type:
            // * For normal unhealthy account liquidations, usual premium applies
            // * For expiry liquidations, the premium is typically reduced,
            //   since the account does not risk bad debt, so the liquidation
            //   is not as urgent
            // * For emergency (paused) liquidations, there is not premium.
            //   This is done in order to preserve fairness, as emergency liquidator
            //   is a priviledged role. Any compensation to the emergency liquidator must
            //   be coordinated with the DAO out of band.

            if (closureActionType == ClosureAction.LIQUIDATE_ACCOUNT) {
                // UNHEALTHY ACCOUNT CASE
                totalFunds =
                    (totalValue * slot1.liquidationDiscount) /
                    PERCENTAGE_FACTOR; // F:[CM-43]

                amountToPool +=
                    (totalValue * slot1.feeLiquidation) /
                    PERCENTAGE_FACTOR; // F:[CM-43]
            } else if (
                closureActionType == ClosureAction.LIQUIDATE_EXPIRED_ACCOUNT
            ) {
                // EXPIRED ACCOUNT CASE
                totalFunds =
                    (totalValue * slot1.liquidationDiscountExpired) /
                    PERCENTAGE_FACTOR; // F:[CM-43]

                amountToPool +=
                    (totalValue * slot1.feeLiquidationExpired) /
                    PERCENTAGE_FACTOR; // F:[CM-43]
            } else {
                // PAUSED CASE
                totalFunds = totalValue; // F: [CM-43]
                amountToPool +=
                    (totalValue * slot1.feeLiquidation) /
                    PERCENTAGE_FACTOR; // F:[CM-43]
            }

            // If there are any funds left after all respective payments (this
            // includes the liquidation premium, since totalFunds is already
            // discounted from totalValue), they are recorded to remainingFunds
            // and will later be sent to the borrower.

            // If totalFunds is not sufficient to cover the entire payment to pool,
            // the Credit Manager will repay what it can. When totalFunds >= debt + interest,
            // this simply means that part of protocol fees will be waived (profit is reduced). Otherwise,
            // there is bad debt (loss > 0).

            // Since values are compared to each other before subtracting,
            // this can be marked as unchecked to optimize gas

            unchecked {
                if (totalFunds > amountToPool) {
                    remainingFunds = totalFunds - amountToPool - 1; // F:[CM-43]
                } else {
                    amountToPool = totalFunds; // F:[CM-43]
                }

                if (totalFunds >= borrowedAmountWithInterest) {
                    profit = amountToPool - borrowedAmountWithInterest; // F:[CM-43]
                } else {
                    loss = borrowedAmountWithInterest - amountToPool; // F:[CM-43]
                }
            }
        } else {
            // CLOSURE CASE

            // During closure, it is assumed that the user has enough to cover
            // the principal + interest + fees. closeCreditAccount, thus, will
            // attempt to charge them the entire amount.

            // Since in this case amountToPool + borrowedAmountWithInterest + fee,
            // this block can be marked as unchecked

            unchecked {
                profit = amountToPool - borrowedAmountWithInterest; // F:[CM-43]
            }
        }
    }

    
    
    function collateralTokens(uint256 id)
        public
        view
        returns (address token, uint16 liquidationThreshold)
    {
        // Collateral tokens are stored under their masks rather than
        // indicies, so this is simply a convenience function that wraps
        // the getter by mask
        return collateralTokensByMask(1 << id);
    }

    
    
    function collateralTokensByMask(uint256 tokenMask)
        public
        view
        override
        returns (address token, uint16 liquidationThreshold)
    {
        // The underlying is a special case and its mask is always 1
        if (tokenMask == 1) {
            token = underlying; // F:[CM-47]
            liquidationThreshold = slot1.ltUnderlying;
        } else {
            // The address and LT of a collateral token are compressed into a single uint256
            // The first 160 bits of the number is the address, and any bits after that are interpreted as LT
            uint256 collateralTokenCompressed = collateralTokensCompressed[
                tokenMask
            ]; // F:[CM-47]

            // Unsafe downcasting is justified, since the right 160 bits of collateralTokenCompressed
            // always stores the uint160 encoded address and the extra bits need to be cut
            token = address(uint160(collateralTokenCompressed)); // F:[CM-47]
            liquidationThreshold = (collateralTokenCompressed >> ADDR_BIT_SIZE)
                .toUint16(); // F:[CM-47]
        }
    }

    
    
    function getCreditAccountOrRevert(address borrower)
        public
        view
        override
        returns (address result)
    {
        result = creditAccounts[borrower]; // F:[CM-48]
        if (result == address(0)) revert HasNoOpenedAccountException(); // F:[CM-48]
    }

    
    
    
    
    
    function calcCreditAccountAccruedInterest(address creditAccount)
        public
        view
        override
        returns (
            uint256 borrowedAmount,
            uint256 borrowedAmountWithInterest,
            uint256 borrowedAmountWithInterestAndFees
        )
    {
        uint256 cumulativeIndexAtOpen_RAY;
        uint256 cumulativeIndexNow_RAY;
        (
            borrowedAmount,
            cumulativeIndexAtOpen_RAY,
            cumulativeIndexNow_RAY
        ) = _getCreditAccountParameters(creditAccount); // F:[CM-49]

        // Interest is never stored and is always computed dynamically
        // as the difference between the current cumulative index of the pool
        // and the cumulative index recorded in the Credit Account
        borrowedAmountWithInterest =
            (borrowedAmount * cumulativeIndexNow_RAY) /
            cumulativeIndexAtOpen_RAY; // F:[CM-49]

        // Fees are computed as a percentage of interest
        borrowedAmountWithInterestAndFees =
            borrowedAmountWithInterest +
            ((borrowedAmountWithInterest - borrowedAmount) *
                slot1.feeInterest) /
            PERCENTAGE_FACTOR; // F: [CM-49]
    }

    
    
    
    
    ///         interest in conjunction  with current pool index. Not necessarily the index
    ///         value at the time of account opening, since it can be updated by manageDebt.
    
    function _getCreditAccountParameters(address creditAccount)
        internal
        view
        returns (
            uint256 borrowedAmount,
            uint256 cumulativeIndexAtOpen_RAY,
            uint256 cumulativeIndexNow_RAY
        )
    {
        borrowedAmount = ICreditAccount(creditAccount).borrowedAmount(); // F:[CM-49,50]
        cumulativeIndexAtOpen_RAY = ICreditAccount(creditAccount)
            .cumulativeIndexAtOpen(); // F:[CM-49,50]
        cumulativeIndexNow_RAY = IPoolService(pool).calcLinearCumulative_RAY(); // F:[CM-49,50]
    }

    
    
    function liquidationThresholds(address token)
        public
        view
        override
        returns (uint16 lt)
    {
        // Underlying is a special case and its LT is stored separately
        if (token == underlying) return slot1.ltUnderlying; // F:[CM-47]

        uint256 tokenMask = tokenMasksMap(token);
        if (tokenMask == 0) revert TokenNotAllowedException();
        (, lt) = collateralTokensByMask(tokenMask); // F:[CM-47]
    }

    
    
    function tokenMasksMap(address token)
        public
        view
        override
        returns (uint256 mask)
    {
        mask = (token == underlying) ? 1 : tokenMasksMapInternal[token];
    }

    
    
    
    function _getMaxIndex(uint256 mask) internal pure returns (uint256 index) {
        if (mask == 1) return 0;

        // Performs a binary search within the range of all token indices
        // If right-shifting a mask by n turns it into 1, then n is the largest index

        uint256 high = 256;
        uint256 low = 1;

        while (true) {
            index = (high + low) >> 1;
            uint256 testMask = 1 << index;

            if (testMask & mask != 0 && (mask >> index == 1)) break;

            if (testMask >= mask) {
                high = index;
            } else {
                low = index;
            }
        }
    }

    
    
    
    ///         during unhealthy account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremium)
    
    ///         during expired account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremiumExpired)
    function fees()
        external
        view
        override
        returns (
            uint16 feeInterest,
            uint16 feeLiquidation,
            uint16 liquidationDiscount,
            uint16 feeLiquidationExpired,
            uint16 liquidationDiscountExpired
        )
    {
        feeInterest = slot1.feeInterest; // F:[CM-51]
        feeLiquidation = slot1.feeLiquidation; // F:[CM-51]
        liquidationDiscount = slot1.liquidationDiscount; // F:[CM-51]
        feeLiquidationExpired = slot1.feeLiquidationExpired; // F:[CM-51]
        liquidationDiscountExpired = slot1.liquidationDiscountExpired; // F:[CM-51]
    }

    
    function priceOracle() external view override returns (IPriceOracleV2) {
        return slot1.priceOracle;
    }

    //
    // CONFIGURATION
    //
    // The following function change vital Credit Manager parameters
    // and can only be called by the Credit Configurator
    //

    
    
    function addToken(address token)
        external
        creditConfiguratorOnly // F:[CM-4]
    {
        _addToken(token); // F:[CM-52]
    }

    
    
    function _addToken(address token) internal {
        // Checks that the token is not already known (has an associated token mask)
        if (tokenMasksMapInternal[token] > 0)
            revert TokenAlreadyAddedException(); // F:[CM-52]

        // Checks that there aren't too many tokens
        // Since token masks are 256 bit numbers with each bit corresponding to 1 token,
        // only at most 256 are supported
        if (collateralTokensCount >= 256) revert TooManyTokensException(); // F:[CM-52]

        // The tokenMask of a token is a bit mask with 1 at position corresponding to its index
        // (i.e. 2 ** index or 1 << index)
        uint256 tokenMask = 1 << collateralTokensCount;
        tokenMasksMapInternal[token] = tokenMask; // F:[CM-53]
        collateralTokensCompressed[tokenMask] = uint256(uint160(token)); // F:[CM-47]
        collateralTokensCount++; // F:[CM-47]
    }

    
    
    
    ///         during unhealthy account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremium)
    
    ///         during expired account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremiumExpired)
    function setParams(
        uint16 _feeInterest,
        uint16 _feeLiquidation,
        uint16 _liquidationDiscount,
        uint16 _feeLiquidationExpired,
        uint16 _liquidationDiscountExpired
    )
        external
        creditConfiguratorOnly // F:[CM-4]
    {
        slot1.feeInterest = _feeInterest; // F:[CM-51]
        slot1.feeLiquidation = _feeLiquidation; // F:[CM-51]
        slot1.liquidationDiscount = _liquidationDiscount; // F:[CM-51]
        slot1.feeLiquidationExpired = _feeLiquidationExpired; // F:[CM-51]
        slot1.liquidationDiscountExpired = _liquidationDiscountExpired; // F:[CM-51]
    }

    //
    // CONFIGURATION
    //

    
    
    ///         TWV with. They denote the risk of the token, with
    ///         more volatile and unpredictable tokens having lower LTs.
    
    
    function setLiquidationThreshold(address token, uint16 liquidationThreshold)
        external
        creditConfiguratorOnly // F:[CM-4]
    {
        // Underlying is a special case and its LT is stored in Slot1,
        // to be accessed frequently
        if (token == underlying) {
            // F:[CM-47]
            slot1.ltUnderlying = liquidationThreshold; // F:[CM-47]
        } else {
            uint256 tokenMask = tokenMasksMap(token); // F:[CM-47, 54]
            if (tokenMask == 0) revert TokenNotAllowedException();

            // Token address and liquidation threshold are encoded into a single uint256
            collateralTokensCompressed[tokenMask] =
                (collateralTokensCompressed[tokenMask] & type(uint160).max) |
                (uint256(liquidationThreshold) << 160); // F:[CM-47]
        }
    }

    
    
    
    ///         or received as a result of adapter operation anymore. This means that a token can never be
    ///         acquired through adapter operations after being forbidden. Accounts that have enabled forbidden tokens
    ///         also can't borrow any additional funds until they disable those tokens.
    function setForbidMask(uint256 _forbidMask)
        external
        creditConfiguratorOnly // F:[CM-4]
    {
        forbiddenTokenMask = _forbidMask; // F:[CM-55]
    }

    
    
    function setMaxEnabledTokens(uint8 newMaxEnabledTokens)
        external
        creditConfiguratorOnly // F: [CM-4]
    {
        maxAllowedEnabledTokenLength = newMaxEnabledTokens; // F: [CC-37]
    }

    
    
    
    
    ///         to disallow a particular target or adapter, since this would set values in respective
    ///         mappings to address(0).
    function changeContractAllowance(address adapter, address targetContract)
        external
        creditConfiguratorOnly
    {
        if (adapter != address(0)) {
            adapterToContract[adapter] = targetContract; // F:[CM-56]
        }
        if (targetContract != address(0)) {
            contractToAdapter[targetContract] = adapter; // F:[CM-56]
        }

        // The universal adapter can potentially target multiple contracts,
        // so it is set using a special vanity address
        if (targetContract == UNIVERSAL_CONTRACT) {
            universalAdapter = adapter; // F:[CM-56]
        }
    }

    
    
    function upgradeCreditFacade(address _creditFacade)
        external
        creditConfiguratorOnly // F:[CM-4]
    {
        creditFacade = _creditFacade;
    }

    
    
    function upgradePriceOracle(address _priceOracle)
        external
        creditConfiguratorOnly // F:[CM-4]
    {
        slot1.priceOracle = IPriceOracleV2(_priceOracle);
    }

    
    
    function addEmergencyLiquidator(address liquidator)
        external
        creditConfiguratorOnly // F:[CM-4]
    {
        canLiquidateWhilePaused[liquidator] = true;
    }

    
    
    function removeEmergencyLiquidator(address liquidator)
        external
        creditConfiguratorOnly // F: [CM-4]
    {
        canLiquidateWhilePaused[liquidator] = false;
    }

    
    
    function setConfigurator(address _creditConfigurator)
        external
        creditConfiguratorOnly // F:[CM-4]
    {
        creditConfigurator = _creditConfigurator; // F:[CM-58]
        emit NewConfigurator(_creditConfigurator); // F:[CM-58]
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;






//  DATA



/// INTERFACES






// CONSTANTS




// EXCEPTIONS


struct Params {
    
    uint128 maxBorrowedAmountPerBlock;
    
    bool isIncreaseDebtForbidden;
    
    uint40 expirationDate;
}

struct Limits {
    
    uint128 minBorrowedAmount;
    
    uint128 maxBorrowedAmount;
}




/// with the Credit Manager are forbidden. There are two ways the Credit Manager can be interacted with:
/// - Through CreditFacade, which provides all the required account management function: open / close / liquidate / manageDebt,
/// as well as Multicalls that allow to perform multiple actions within a single transaction, with a single health check
/// - Through adapters, which call the Credit Manager directly, but only allow interactions with specific target contracts
contract CreditFacade is ICreditFacade, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    
    ICreditManagerV2 public immutable creditManager;

    
    bool public immutable whitelisted;

    
    bool public immutable expirable;

    
    Params public override params;

    
    Limits public override limits;

    
    address public immutable underlying;

    
    mapping(address => mapping(address => bool))
        public
        override transfersAllowed;

    
    address public immutable wethAddress;

    
    address public immutable override degenNFT;

    
    uint256 internal totalBorrowedInBlock;

    
    EnumerableSet.AddressSet internal upgradeableContracts;

    
    uint256 public constant override version = 2;

    
    modifier creditConfiguratorOnly() {
        if (msg.sender != creditManager.creditConfigurator())
            revert CreditConfiguratorOnlyException();

        _;
    }

    
    
    
    
    constructor(
        address _creditManager,
        address _degenNFT,
        bool _expirable
    ) {
        // Additional check that _creditManager is not address(0)
        if (_creditManager == address(0)) revert ZeroAddressException(); // F:[FA-1]

        creditManager = ICreditManagerV2(_creditManager); // F:[FA-1A]
        underlying = ICreditManagerV2(_creditManager).underlying(); // F:[FA-1A]
        wethAddress = ICreditManagerV2(_creditManager).wethAddress(); // F:[FA-1A]

        degenNFT = _degenNFT; // F:[FA-1A]
        whitelisted = _degenNFT != address(0); // F:[FA-1A]

        expirable = _expirable;
    }

    // Notice: ETH interactions
    // CreditFacade implements a new flow for interacting with WETH compared to V1.
    // During all actions, any sent ETH value is automatically wrapped into WETH and
    // sent back to the message sender. This makes the protocol's behavior regarding
    // ETH more flexible and consistent, since there is no need to pre-wrap WETH before
    // interacting with the protocol, and no need to compute how much unused ETH has to be sent back.

    
    /// without any additional action.
    /// - Performs sanity checks to determine whether opening an account is allowed
    /// - Wraps ETH to WETH and sends it msg. sender is value > 0
    /// - Requests CreditManager to open a Credit Account with a specified borrowed amount
    /// - Transfers collateral in the underlying asset from the user
    /// - Emits OpenCreditAccount event
    ///
    /// More info: https://dev.gearbox.fi/developers/credit/credit_manager#open-credit-account
    ///
    
    
    /// msg.sender != obBehalfOf
    
    /// as the user's own collateral, equivalent to 2x leverage.
    
    function openCreditAccount(
        uint256 amount,
        address onBehalfOf,
        uint16 leverageFactor,
        uint16 referralCode
    ) external payable override nonReentrant {
        uint256 borrowedAmount = (amount * leverageFactor) / LEVERAGE_DECIMALS; // F:[FA-5]

        // Checks whether the new borrowed amount does not violate the block limit
        _checkAndUpdateBorrowedBlockLimit(borrowedAmount); // F:[FA-11A]

        // Checks that the borrowed amount is within the borrowing limits
        _revertIfOutOfBorrowedLimits(borrowedAmount); // F:[FA-11B]

        // Checks that the msg.sender can open an account for onBehalfOf
        _revertIfOpenCreditAccountNotAllowed(onBehalfOf); // F:[FA-4A, 4B]

        // Wraps ETH and sends it back to msg.sender
        _wrapETH(); // F:[FA-3A]

        // Gets the LT of the underlying
        (, uint256 ltu) = creditManager.collateralTokens(0); // F:[FA-6]

        // In order for the account to pass the health check after opening,
        // the inequality "(amount + borrowedAmount) * LTU > borrowedAmount" must hold
        // this can be transformed into "amount * LTU > borrowedAmount * (1 - LTU)"
        if (amount * ltu <= borrowedAmount * (PERCENTAGE_FACTOR - ltu))
            revert NotEnoughCollateralException(); // F:[FA-6]

        // Opens credit accnount and borrows funds from the pool
        // Returns the new credit account's address
        address creditAccount = creditManager.openCreditAccount(
            borrowedAmount,
            onBehalfOf
        ); // F:[FA-5]

        // Emits openCreditAccount event before adding collateral, so that order of events is correct
        emit OpenCreditAccount(
            onBehalfOf,
            creditAccount,
            borrowedAmount,
            referralCode
        ); // F:[FA-5]

        // Transfers collateral from the user to the new Credit Account
        addCollateral(onBehalfOf, creditAccount, underlying, amount); // F:[FA-5]
    }

    
    /// - Opens credit account with the desired borrowed amount
    /// - Executes all operations in a multicall
    /// - Checks that the new account has enough collateral
    /// - Emits OpenCreditAccount event
    ///
    
    
    /// msg.sender != onBehalfOf
    
    /// at least a call to addCollateral, as otherwise the health check at the end will fail.
    
    function openCreditAccountMulticall(
        uint256 borrowedAmount,
        address onBehalfOf,
        MultiCall[] calldata calls,
        uint16 referralCode
    ) external payable override nonReentrant {
        // Checks whether the new borrowed amount does not violate the block limit
        _checkAndUpdateBorrowedBlockLimit(borrowedAmount); // F:[FA-11]

        // Checks that the msg.sender can open an account for onBehalfOf
        _revertIfOpenCreditAccountNotAllowed(onBehalfOf); // F:[FA-4A, 4B]

        // Checks that the borrowed amount is within the borrowing limits
        _revertIfOutOfBorrowedLimits(borrowedAmount); // F:[FA-11B]

        // Wraps ETH and sends it back to msg.sender address
        _wrapETH(); // F:[FA-3B]

        // Requests the Credit Manager to open a Credit Account
        address creditAccount = creditManager.openCreditAccount(
            borrowedAmount,
            onBehalfOf
        ); // F:[FA-8]

        // emits a new event
        emit OpenCreditAccount(
            onBehalfOf,
            creditAccount,
            borrowedAmount,
            referralCode
        ); // F:[FA-8]

        // F:[FA-10]: no free flashloans through opening a Credit Account
        // and immediately decreasing debt
        if (calls.length != 0)
            _multicall(calls, onBehalfOf, creditAccount, false, true); // F:[FA-8]

        // Checks that the new credit account has enough collateral to cover the debt
        creditManager.fullCollateralCheck(creditAccount); // F:[FA-8, 9]
    }

    
    /// - Wraps ETH to WETH and sends it msg.sender if value > 0
    /// - Executes the multicall - the main purpose of a multicall when closing is to convert all assets to underlying
    /// in order to pay the debt.
    /// - Closes credit account:
    ///    + Checks the underlying balance: if it is greater than the amount paid to the pool, transfers the underlying
    ///      from the Credit Account and proceeds. If not, tries to transfer the shortfall from msg.sender.
    ///    + Transfers all enabled assets with non-zero balances to the "to" address, unless they are marked
    ///      to be skipped in skipTokenMask
    ///    + If convertWETH is true, converts WETH into ETH before sending to the recipient
    /// - Emits a CloseCreditAccount event
    ///
    
    
    
    
    function closeCreditAccount(
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable override nonReentrant {
        // Check for existing CA
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[FA-2]

        // Wraps ETH and sends it back to msg.sender
        _wrapETH(); // F:[FA-3C]

        // [FA-13]: Calls to CreditFacade are forbidden during closure
        if (calls.length != 0)
            _multicall(calls, msg.sender, creditAccount, true, false); // F:[FA-2, 12, 13]

        // Requests the Credit manager to close the Credit Account
        creditManager.closeCreditAccount(
            msg.sender,
            ClosureAction.CLOSE_ACCOUNT,
            0,
            msg.sender,
            to,
            skipTokenMask,
            convertWETH
        ); // F:[FA-2, 12]

        // Emits a CloseCreditAccount event
        emit CloseCreditAccount(msg.sender, to); // F:[FA-12]
    }

    
    /// - Computes the total value and checks that hf < 1. An account can't be liquidated when hf >= 1.
    ///   Total value has to be computed before the multicall, otherwise the liquidator would be able
    ///   to manipulate it.
    /// - Wraps ETH to WETH and sends it to msg.sender (liquidator) if value > 0
    /// - Executes the multicall - the main purpose of a multicall when liquidating is to convert all assets to underlying
    ///   in order to pay the debt.
    /// - Liquidate credit account:
    ///    + Computes the amount that needs to be paid to the pool. If totalValue * liquidationDiscount < borrow + interest + fees,
    ///      only totalValue * liquidationDiscount has to be paid. Since liquidationDiscount < 1, the liquidator can take
    ///      totalValue * (1 - liquidationDiscount) as premium. Also computes the remaining funds to be sent to borrower
    ///      as totalValue * liquidationDiscount - amountToPool.
    ///    + Checks the underlying balance: if it is greater than amountToPool + remainingFunds, transfers the underlying
    ///      from the Credit Account and proceeds. If not, tries to transfer the shortfall from the liquidator.
    ///    + Transfers all enabled assets with non-zero balances to the "to" address, unless they are marked
    ///      to be skipped in skipTokenMask. If the liquidator is confident that all assets were converted
    ///      during the multicall, they can set the mask to uint256.max - 1, to only transfer the underlying
    ///    + If convertWETH is true, converts WETH into ETH before sending
    /// - Emits LiquidateCreditAccount event
    ///
    
    
    
    
    function liquidateCreditAccount(
        address borrower,
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable override nonReentrant {
        // Checks that the CA exists to revert early for late liquidations and save gas
        address creditAccount = creditManager.getCreditAccountOrRevert(
            borrower
        ); // F:[FA-2]

        // Checks that the to address is not zero
        if (to == address(0)) revert ZeroAddressException(); // F:[FA-16A]

        // Checks that the account hf < 1 and computes the totalValue
        // before the multicall
        (bool isLiquidatable, uint256 totalValue) = _isAccountLiquidatable(
            creditAccount
        ); // F:[FA-14]

        // An account can't be liquidated if hf >= 1
        if (!isLiquidatable)
            revert CantLiquidateWithSuchHealthFactorException(); // F:[FA-14]

        // Wraps ETH and sends it back to msg.sender
        _wrapETH(); // F:[FA-3D]

        // Checks if the liquidation is done while the contract is paused
        bool emergencyLiquidation = _checkIfEmergencyLiquidator(true);

        if (calls.length != 0)
            _multicall(calls, borrower, creditAccount, true, false); // F:[FA-15]

        if (emergencyLiquidation) {
            _checkIfEmergencyLiquidator(false);
        }

        // Liquidates the CA and sends the remaining funds to the borrower
        uint256 remainingFunds = creditManager.closeCreditAccount(
            borrower,
            ClosureAction.LIQUIDATE_ACCOUNT,
            totalValue,
            msg.sender,
            to,
            skipTokenMask,
            convertWETH
        ); // F:[FA-15]

        emit LiquidateCreditAccount(borrower, msg.sender, to, remainingFunds); // F:[FA-15]
    }

    
    /// this Credit Facade is expired
    /// The general flow of liquidation is nearly the same as normal liquidations, with two main differences:
    ///     - An account can be liquidated on an expired Credit Facade even with hf > 1. However,
    ///       no accounts can be liquidated through this function if the Credit Facade is not expired.
    ///     - Liquidation premiums and fees for liquidating expired accounts are reduced.
    /// It is still possible to normally liquidate an underwater Credit Account, even when the Credit Facade
    /// is expired.
    
    
    
    
    
    function liquidateExpiredCreditAccount(
        address borrower,
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable override nonReentrant {
        // Checks that the CA exists to revert early for late liquidations and save gas
        address creditAccount = creditManager.getCreditAccountOrRevert(
            borrower
        );

        // Checks that the to address is not zero
        if (to == address(0)) revert ZeroAddressException();

        // Checks that this Credit Facade is expired and reverts if not
        if (!_isExpired()) {
            revert CantLiquidateNonExpiredException(); // F: [FA-47,48]
        }

        // Calculates the total value of an account
        (uint256 totalValue, ) = calcTotalValue(creditAccount);

        // Wraps ETH and sends it back to msg.sender address
        _wrapETH();

        // Checks if the liquidsation during pause
        bool emergencyLiquidation = _checkIfEmergencyLiquidator(true);

        if (calls.length != 0)
            _multicall(calls, borrower, creditAccount, true, false); // F:[FA-49]

        if (emergencyLiquidation) {
            _checkIfEmergencyLiquidator(false);
        }

        // Liquidates the CA and sends the remaining funds to the borrower
        uint256 remainingFunds = creditManager.closeCreditAccount(
            borrower,
            ClosureAction.LIQUIDATE_EXPIRED_ACCOUNT,
            totalValue,
            msg.sender,
            to,
            skipTokenMask,
            convertWETH
        ); // F:[FA-49]

        // Emits event
        emit LiquidateExpiredCreditAccount(
            borrower,
            msg.sender,
            to,
            remainingFunds
        ); // F:[FA-49]
    }

    
    /// - Borrows the requested amount from the pool
    /// - Updates the CA's borrowAmount / cumulativeIndexOpen
    ///   to correctly compute interest going forward
    /// - Performs a full collateral check
    ///
    
    function increaseDebt(uint256 amount) external override nonReentrant {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[FA-2]

        _increaseDebt(msg.sender, creditAccount, amount);

        // Checks that the credit account has enough collateral to cover the new borrowed amount
        creditManager.fullCollateralCheck(creditAccount); // F:[FA-17]
    }

    
    function _increaseDebt(
        address borrower,
        address creditAccount,
        uint256 amount
    ) internal {
        // It is forbidden to take new debt if increaseDebtForbidden mode is enabled
        if (params.isIncreaseDebtForbidden)
            revert IncreaseDebtForbiddenException(); // F:[FA-18C]

        // Checks that the borrowed amount does not violate the per block limit
        _checkAndUpdateBorrowedBlockLimit(amount); // F:[FA-18A]

        // Checks that there are no forbidden tokens, as borrowing
        // is prohibited when forbidden tokens are enabled on the account
        _checkForbiddenTokens(creditAccount);

        // Requests the Credit Manager to borrow additional funds from the pool
        uint256 newBorrowedAmount = creditManager.manageDebt(
            creditAccount,
            amount,
            true
        ); // F:[FA-17]

        // Checks that the new total borrowed amount is within bounds
        _revertIfOutOfBorrowedLimits(newBorrowedAmount); // F:[FA-18B]

        // Emits event
        emit IncreaseBorrowedAmount(borrower, amount); // F:[FA-17]
    }

    
    /// and the set of forbidden tokens
    
    /// pool funds to dangerous or exploited collateral, without immediately
    /// liquidating accounts that hold the forbidden token
    /// There are two ways pool funds can be exposed:
    ///     - The CA owner tries to swap borrowed funds to the forbidden asset:
    ///       this will be blocked by checkAndEnableToken, which is invoked for tokenOut
    ///       after every operation;
    ///     - The CA owner with an already enabled forbidden token transfers it
    ///       to the account - they can't use addCollateral / enableToken due to checkAndEnableToken,
    ///       but can transfer the token directly when it is enabled and it will be counted in the collateral -
    ///       an borrows against it. This check is used to prevent this.
    /// If the owner has a forbidden token and want to take more debt, they must first
    /// dispose of the token and disable it.
    function _checkForbiddenTokens(address creditAccount) internal view {
        uint256 enabledTokenMask = creditManager.enabledTokensMap(
            creditAccount
        );
        uint256 forbiddenTokenMask = creditManager.forbiddenTokenMask();

        if (enabledTokenMask & forbiddenTokenMask > 0) {
            revert ActionProhibitedWithForbiddenTokensException();
        }
    }

    
    /// - Decreases the debt by paying the requested amount + accrued interest + fees back to the pool
    /// - It's also include to this payment interest accrued at the moment and fees
    /// - Updates cunulativeIndex to cumulativeIndex now
    ///
    
    function decreaseDebt(uint256 amount) external override nonReentrant {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[FA-2]

        _decreaseDebt(msg.sender, creditAccount, amount); // F:[FA-19]

        // We need this check, cause after paying debt back, it potentially could be
        // another portfolio structure, which has lower Hf
        creditManager.fullCollateralCheck(creditAccount); // F:[FA-19]
    }

    
    function _decreaseDebt(
        address borrower,
        address creditAccount,
        uint256 amount
    ) internal {
        // Requests the creditManager to reduce the borrowed sum by amount
        uint256 newBorrowedAmount = creditManager.manageDebt(
            creditAccount,
            amount,
            false
        ); // F:[FA-19]

        // Checks that the new borrowed amount is within limits
        _revertIfOutOfBorrowedLimits(newBorrowedAmount); // F:[FA-20]

        // Emits an event
        emit DecreaseBorrowedAmount(borrower, amount); // F:[FA-19]
    }

    
    
    
    
    function addCollateral(
        address onBehalfOf,
        address token,
        uint256 amount
    ) external payable override nonReentrant {
        // Wraps ETH and sends it back to msg.sender
        _wrapETH(); // F:[FA-3E]

        // Checks that onBehalfOf has an account
        address creditAccount = creditManager.getCreditAccountOrRevert(
            onBehalfOf
        ); // F:[FA-2]

        addCollateral(onBehalfOf, creditAccount, token, amount);

        // Since this action can enable new tokens, Credit Manager
        // needs to check that the max enabled token limit is not
        // breached
        creditManager.checkAndOptimizeEnabledTokens(creditAccount); // F: [FA-21C]
    }

    function addCollateral(
        address onBehalfOf,
        address creditAccount,
        address token,
        uint256 amount
    ) internal {
        // Checks that msg.sender can transfer funds to onBehalfOf's account
        // This is done to prevent malicious actors sending bad collateral
        // to users
        // mgs.sender can only add collateral if transfer are approved
        // from itself to onBehalfOf
        _revertIfActionOnAccountNotAllowed(onBehalfOf); // F: [FA-21A]

        // Requests Credit Manager to transfer collateral to the Credit Account
        creditManager.addCollateral(msg.sender, creditAccount, token, amount); // F:[FA-21]

        // Emits event
        emit AddCollateral(onBehalfOf, token, amount); // F:[FA-21]
    }

    
    ///  - Wraps ETH and sends it back to msg.sender, if value > 0
    ///  - Executes the Multicall
    ///  - Performs a fullCollateralCheck to verify that hf > 1 after all actions
    
    function multicall(MultiCall[] calldata calls)
        external
        payable
        override
        nonReentrant
    {
        // Checks that msg.sender has an account
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        );

        // Wraps ETH and sends it back to msg.sender
        _wrapETH(); // F:[FA-3F]

        if (calls.length != 0) {
            _multicall(calls, msg.sender, creditAccount, false, false);

            // Performs a fullCollateralCheck
            // During a multicall, all intermediary health checks are skipped,
            // as one fullCollateralCheck at the end is sufficient
            creditManager.fullCollateralCheck(creditAccount);
        }
    }

    
    /// - Transfers ownership from  borrower to this contract, as most adapter and Credit Manager functions retrieve
    ///   the Credit Account by msg.sender
    /// - Executes the provided list of calls:
    ///   + if targetContract == address(this), parses call data in the struct and calls the appropriate function (see _processCreditFacadeMulticall below)
    ///   + if targetContract == adapter, calls the adapter with call data as provided. Adapters skip health checks when Credit Facade is the msg.sender,
    ///     as it performs the necessary health checks on its own
    
    
    
    ///                  multicalls on closure.
    
    ///                  increasing and decreasing debt within a single multicall.
    function _multicall(
        MultiCall[] calldata calls,
        address borrower,
        address creditAccount,
        bool isClosure,
        bool increaseDebtWasCalled
    ) internal {
        // Takes ownership of the Credit Account
        creditManager.transferAccountOwnership(borrower, address(this)); // F:[FA-26]

        // Emits event for multicall start - used in analytics to track actions within multicalls
        emit MultiCallStarted(borrower); // F:[FA-26]

        // Declares the expectedBalances array, which can later be used for slippage control
        Balance[] memory expectedBalances;

        uint256 len = calls.length; // F:[FA-26]
        for (uint256 i = 0; i < len; ) {
            MultiCall calldata mcall = calls[i]; // F:[FA-26]

            // Reverts of calldata has less than 4 bytes
            if (mcall.callData.length < 4) revert IncorrectCallDataException(); // F:[FA-22]

            if (mcall.target == address(this)) {
                // No internal calls on closure except slippage control, to avoid loss manipulation
                if (isClosure) {
                    bytes4 method = bytes4(mcall.callData);
                    if (
                        method !=
                        ICreditFacadeExtended.revertIfReceivedLessThan.selector
                    ) revert ForbiddenDuringClosureException(); // F:[FA-13]
                }

                //
                // CREDIT FACADE
                //

                // increaseDebtWasCalled and expectedBalances are parameters that persist throughout multicall,
                // therefore they are passed to the internal function processor, which returns updated values
                (
                    increaseDebtWasCalled,
                    expectedBalances
                ) = _processCreditFacadeMulticall(
                    borrower,
                    creditAccount,
                    mcall.callData,
                    increaseDebtWasCalled,
                    expectedBalances
                );
            } else {
                //
                // ADAPTERS
                //

                // Checks that the target is an allowed adapter and not CreditManager
                // As CreditFacade has powerful permissions in CreditManagers,
                // functionCall to it is strictly forbidden, even if
                // the Configurator adds it as an adapter
                if (
                    creditManager.adapterToContract(mcall.target) ==
                    address(0) ||
                    mcall.target == address(creditManager)
                ) revert TargetContractNotAllowedException(); // F:[FA-24]

                // Makes a call
                mcall.target.functionCall(mcall.callData); // F:[FA-29]
            }

            unchecked {
                ++i;
            }
        }

        // If expectedBalances was set by calling revertIfGetLessThan,
        // checks that actual token balances are not less than expected balances
        if (expectedBalances.length != 0)
            _compareBalances(expectedBalances, creditAccount);

        // Emits event for multicall end - used in analytics to track actions within multicalls
        emit MultiCallFinished(); // F:[FA-27,27,29]

        // Returns ownership back to the borrower
        creditManager.transferAccountOwnership(address(this), borrower); // F:[FA-27,27,29]
    }

    
    
    
    
    
    
    function _processCreditFacadeMulticall(
        address borrower,
        address creditAccount,
        bytes calldata callData,
        bool increaseDebtWasCalledBefore,
        Balance[] memory expectedBalancesBefore
    )
        internal
        returns (bool increaseDebtWasCalled, Balance[] memory expectedBalances)
    {
        increaseDebtWasCalled = increaseDebtWasCalledBefore;
        expectedBalances = expectedBalancesBefore;

        bytes4 method = bytes4(callData);

        //
        // REVERT_IF_GET_LESS_THAN
        //

        // This is an extension function that instructs CreditFacade to check token balances at the end
        // Used to control slippage after the entire sequence of operations, since tracking slippage
        // On each operation is not ideal
        if (method == ICreditFacadeExtended.revertIfReceivedLessThan.selector) {
            // Method can only be called once since the provided Balance array
            // contains deltas that are added to the current balances
            // Calling this function again could potentially override old values
            // and cause confusion, especially if called later in the MultiCall
            if (expectedBalances.length != 0)
                revert ExpectedBalancesAlreadySetException(); // F:[FA-45A]

            // Retrieves the balance list from calldata
            expectedBalances = abi.decode(callData[4:], (Balance[])); // F:[FA-45]

            // Sets expected balances to currentBalance + delta
            expectedBalances = _storeBalances(expectedBalances, creditAccount); // F:[FA-45]
        }
        //
        // ADD COLLATERAL
        //
        else if (method == ICreditFacade.addCollateral.selector) {
            // Parses parameters from calldata
            (address onBehalfOf, address token, uint256 amount) = abi.decode(
                callData[4:],
                (address, address, uint256)
            ); // F:[FA-26, 27]

            // In case onBehalfOf isn't the owner of the currently processed account,
            // retrieves onBehalfOf's account
            addCollateral(
                onBehalfOf,
                onBehalfOf == borrower
                    ? creditAccount
                    : creditManager.getCreditAccountOrRevert(onBehalfOf),
                token,
                amount
            ); // F:[FA-26, 27]
        }
        //
        // INCREASE DEBT
        //
        else if (method == ICreditFacade.increaseDebt.selector) {
            // Sets increaseDebtWasCalled to prevent debt reductions afterwards,
            // as that could be used to get free flash loans
            increaseDebtWasCalled = true; // F:[FA-28]

            // Parses parameters from calldata
            uint256 amount = abi.decode(callData[4:], (uint256)); // F:[FA-26]
            _increaseDebt(borrower, creditAccount, amount); // F:[FA-26]
        }
        //
        // DECREASE DEBT
        //
        else if (method == ICreditFacade.decreaseDebt.selector) {
            // it's forbidden to call decreaseDebt after increaseDebt, in the same multicall
            if (increaseDebtWasCalled)
                revert IncreaseAndDecreaseForbiddenInOneCallException(); // F:[FA-28]

            // Parses parameters from calldata
            uint256 amount = abi.decode(callData[4:], (uint256)); // F:[FA-27]

            _decreaseDebt(borrower, creditAccount, amount); // F:[FA-27]
        }
        //
        // ENABLE TOKEN
        //
        else if (method == ICreditFacade.enableToken.selector) {
            // Parses token
            address token = abi.decode(callData[4:], (address)); // F: [FA-53]

            // Executes enableToken for creditAccount
            _enableToken(borrower, creditAccount, token); // F: [FA-53]
        }
        //
        // DISABLE TOKEN
        //
        // This is an extenstion method used to disable tokens on a Credit Account
        // Can be used to remove troublesome tokens (e.g., forbidden tokens) from an account
        else if (method == ICreditFacadeExtended.disableToken.selector) {
            // Parses token
            address token = abi.decode(callData[4:], (address)); // F: [FA-54]

            // Executes disableToken for creditAccount
            _disableToken(borrower, creditAccount, token); // F: [FA-54]
        } else {
            // Reverts if the passed selector is unrecognized
            revert UnknownMethodException(); // F:[FA-23]
        }
    }

    
    
    
    function _storeBalances(Balance[] memory expected, address creditAccount)
        internal
        view
        returns (Balance[] memory)
    {
        uint256 len = expected.length; // F:[FA-45]
        for (uint256 i = 0; i < len; ) {
            expected[i].balance += IERC20(expected[i].token).balanceOf(
                creditAccount
            ); // F:[FA-45]
            unchecked {
                ++i;
            }
        }

        return expected; // F:[FA-45]
    }

    
    /// Reverts if at least one balance is lower than expected
    
    
    function _compareBalances(Balance[] memory expected, address creditAccount)
        internal
        view
    {
        uint256 len = expected.length; // F:[FA-45]
        for (uint256 i = 0; i < len; ) {
            if (
                IERC20(expected[i].token).balanceOf(creditAccount) <
                expected[i].balance
            ) revert BalanceLessThanMinimumDesiredException(expected[i].token); // F:[FA-45]
            unchecked {
                ++i;
            }
        }
    }

    
    
    
    
    function approve(
        address targetContract,
        address token,
        uint256 amount
    ) external override nonReentrant {
        // Checks that targetContract is a non-zero address and is not in the upgradeable contracts list
        // If an upgradeable contract is compromised, and an attacker is able to call transferFrom from it,
        // they would be able to steal funds from Credit Accounts while circumventing all health checks
        // Thus, this action is only allowed for immutable and highly secure contracts
        if (
            creditManager.contractToAdapter(targetContract) == address(0) ||
            upgradeableContracts.contains(targetContract)
        )
            // F: [FA-51]
            revert TargetContractNotAllowedException(); // F:[FA-30]

        // Requests Credit Manager to set token allowance from Credit Account to contract
        creditManager.approveCreditAccount(
            msg.sender,
            targetContract,
            token,
            amount
        ); // F:[FA-31]
    }

    
    /// By default, this action is forbidden, and the user has to approve transfers from sender to itself
    /// by calling approveAccountTransfer.
    /// This is done to prevent malicious actors from transferring compromised accounts to other users.
    
    function transferAccountOwnership(address to)
        external
        override
        nonReentrant
    {
        // In whitelisted mode only select addresses can have Credit Accounts
        // So this action is prohibited
        if (whitelisted) revert NotAllowedInWhitelistedMode(); // F:[FA-32]

        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[FA-2]

        // Checks that transfer is allowed
        if (!transfersAllowed[msg.sender][to])
            revert AccountTransferNotAllowedException(); // F:[FA-33]

        /// Checks that the account hf > 1, as it is forbidden to transfer
        /// accounts that are liquidatable
        (bool isLiquidatable, ) = _isAccountLiquidatable(creditAccount); // F:[FA-34]

        if (isLiquidatable) revert CantTransferLiquidatableAccountException(); // F:[FA-34]

        // Requests the Credit Manager to transfer the account
        creditManager.transferAccountOwnership(msg.sender, to); // F:[FA-35]

        // Emits event
        emit TransferAccount(msg.sender, to); // F:[FA-35]
    }

    
    /// -  For expirable Credit Facade, expiration date must not be reached
    /// -  For whitelisted mode, msg.sender must open the account for themselves
    ///    and have at least one DegenNFT to burn
    /// -  Otherwise, checks that account transfers from msg.sender to onBehalfOf
    ///    are approved
    
    function _revertIfOpenCreditAccountNotAllowed(address onBehalfOf) internal {
        // Opening new Credit Accounts is prohibited in increaseDebtForbidden mode
        if (params.isIncreaseDebtForbidden)
            revert IncreaseDebtForbiddenException(); // F:[FA-7]

        // Checks that this CreditFacade is not expired
        if (_isExpired()) {
            revert OpenAccountNotAllowedAfterExpirationException(); // F: [FA-46]
        }

        // F:[FA-5] covers case when degenNFT == address(0)
        if (degenNFT != address(0)) {
            // F:[FA-4B]

            // In whitelisted mode, users can only open an account by burning a DegenNFT
            // And opening an account for another address is forbidden
            if (whitelisted && msg.sender != onBehalfOf)
                revert NotAllowedInWhitelistedMode(); // F:[FA-4B]

            IDegenNFT(degenNFT).burn(onBehalfOf, 1); // F:[FA-4B]
        }

        _revertIfActionOnAccountNotAllowed(onBehalfOf);
    }

    
    
    function _revertIfActionOnAccountNotAllowed(address onBehalfOf)
        internal
        view
    {
        // msg.sender must either be the account owner themselves,
        // or be approved for transfers
        if (
            msg.sender != onBehalfOf &&
            !transfersAllowed[msg.sender][onBehalfOf]
        ) revert AccountTransferNotAllowedException(); // F:[FA-04C]
    }

    
    /// amount borrowed in current block
    function _checkAndUpdateBorrowedBlockLimit(uint256 amount) internal {
        // Skipped in whitelisted mode, since there is a strict limit on the number
        // of credit accounts that can be opened, which implies a limit on borrowing
        if (!whitelisted) {
            uint256 _limitPerBlock = params.maxBorrowedAmountPerBlock; // F:[FA-18]

            // If the limit is unit128.max, the check is disabled
            // F:[FA-36] test case when _limitPerBlock == type(uint128).max
            if (_limitPerBlock != type(uint128).max) {
                (
                    uint64 lastBlock,
                    uint128 lastLimit
                ) = getTotalBorrowedInBlock(); // F:[FA-18, 37]

                uint256 newLimit = (lastBlock == block.number)
                    ? amount + lastLimit // F:[FA-37]
                    : amount; // F:[FA-18, 37]

                if (newLimit > _limitPerBlock)
                    revert BorrowedBlockLimitException(); // F:[FA-18]

                _updateTotalBorrowedInBlock(uint128(newLimit)); // F:[FA-37]
            }
        }
    }

    
    
    function _revertIfOutOfBorrowedLimits(uint256 borrowedAmount)
        internal
        view
    {
        // Checks that amount is in limits
        if (
            borrowedAmount < uint256(limits.minBorrowedAmount) ||
            borrowedAmount > uint256(limits.maxBorrowedAmount)
        ) revert BorrowAmountOutOfLimitsException(); // F:
    }

    function _checkIfEmergencyLiquidator(bool state) internal returns (bool) {
        return creditManager.checkEmergencyPausable(msg.sender, state);
    }

    
    ///      and the total amount borrowed in that block
    function getTotalBorrowedInBlock()
        public
        view
        returns (uint64 blockLastUpdate, uint128 borrowedInBlock)
    {
        blockLastUpdate = uint64(totalBorrowedInBlock >> 128); // F:[FA-37]
        borrowedInBlock = uint128(totalBorrowedInBlock & type(uint128).max); // F:[FA-37]
    }

    
    
    function _updateTotalBorrowedInBlock(uint128 borrowedInBlock) internal {
        totalBorrowedInBlock = uint256(block.number << 128) | borrowedInBlock; // F:[FA-37]
    }

    
    
    
    function approveAccountTransfer(address from, bool state)
        external
        override
        nonReentrant
    {
        transfersAllowed[from][msg.sender] = state; // F:[FA-38]

        // Emits event
        emit TransferAccountAllowed(from, msg.sender, state); // F:[FA-38]
    }

    
    
    function enableToken(address token) external override nonReentrant {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[FA-2]

        _enableToken(msg.sender, creditAccount, token);

        // Since this action potentially increases the number of enabled tokens,
        // the Credit Manager is requested to check that the max limit for enabled tokens
        // is not violated
        creditManager.checkAndOptimizeEnabledTokens(creditAccount); // F: [FA-39A]
    }

    
    
    
    function _enableToken(
        address borrower,
        address creditAccount,
        address token
    ) internal {
        // Will revert if the token is not known or forbidden,
        // If the token is disabled, adds the respective bit to the mask, otherwise does nothing
        creditManager.checkAndEnableToken(creditAccount, token); // F:[FA-39]

        // Emits event
        emit TokenEnabled(borrower, token);
    }

    function _disableToken(
        address borrower,
        address creditAccount,
        address token
    ) internal {
        // If the token is enabled, removes a respective bit from the mask,
        // otherwise does nothing
        if (creditManager.disableToken(creditAccount, token)) {
            // Emits event
            emit TokenDisabled(borrower, token);
        } // F: [FA-54]
    }

    //
    // GETTERS
    //

    
    /// otherwise returns false
    
    function isTokenAllowed(address token)
        public
        view
        override
        returns (bool allowed)
    {
        uint256 tokenMask = creditManager.tokenMasksMap(token); // F:[FA-40]
        allowed =
            (tokenMask != 0) &&
            (creditManager.forbiddenTokenMask() & tokenMask == 0); // F:[FA-40]
    }

    
    /// More: https://dev.gearbox.fi/developers/credit/economy#totalUSD-value
    ///
    
    
    
    function calcTotalValue(address creditAccount)
        public
        view
        override
        returns (uint256 total, uint256 twv)
    {
        IPriceOracleV2 priceOracle = IPriceOracleV2(
            creditManager.priceOracle()
        ); // F:[FA-41]

        (uint256 totalUSD, uint256 twvUSD) = _calcTotalValueUSD(
            priceOracle,
            creditAccount
        );
        total = priceOracle.convertFromUSD(totalUSD, underlying); // F:[FA-41]
        twv =
            priceOracle.convertFromUSD(twvUSD, underlying) /
            PERCENTAGE_FACTOR; // F:[FA-41]
    }

    
    
    
    
    
    function _calcTotalValueUSD(
        IPriceOracleV2 priceOracle,
        address creditAccount
    ) internal view returns (uint256 totalUSD, uint256 twvUSD) {
        uint256 tokenMask = 1;
        uint256 enabledTokensMask = creditManager.enabledTokensMap(
            creditAccount
        ); // F:[FA-41]

        while (tokenMask <= enabledTokensMask) {
            if (enabledTokensMask & tokenMask != 0) {
                (address token, uint16 liquidationThreshold) = creditManager
                    .collateralTokensByMask(tokenMask);
                uint256 balance = IERC20(token).balanceOf(creditAccount); // F:[FA-41]

                if (balance > 1) {
                    uint256 value = priceOracle.convertToUSD(balance, token); // F:[FA-41]

                    unchecked {
                        totalUSD += value; // F:[FA-41]
                    }
                    twvUSD += value * liquidationThreshold; // F:[FA-41]
                }
            } // T:[FA-41]

            tokenMask = tokenMask << 1; // F:[FA-41]
        }
    }

    /**
     * @dev Calculates health factor for the credit account
     *
     *          sum(asset[i] * liquidation threshold[i])
     *   Hf = --------------------------------------------
     *         borrowed amount + interest accrued + fees
     *
     *
     * More info: https://dev.gearbox.fi/developers/credit/economy#health-factor
     *
     * @param creditAccount Credit account address
     * @return hf = Health factor in bp (see PERCENTAGE FACTOR in PercentageMath.sol)
     */
    function calcCreditAccountHealthFactor(address creditAccount)
        public
        view
        override
        returns (uint256 hf)
    {
        (, uint256 twv) = calcTotalValue(creditAccount); // F:[FA-42]
        (, , uint256 borrowAmountWithInterestAndFees) = creditManager
            .calcCreditAccountAccruedInterest(creditAccount); // F:[FA-42]
        hf = (twv * PERCENTAGE_FACTOR) / borrowAmountWithInterestAndFees; // F:[FA-42]
    }

    
    
    function hasOpenedCreditAccount(address borrower)
        public
        view
        override
        returns (bool)
    {
        return creditManager.creditAccounts(borrower) != address(0); // F:[FA-43]
    }

    
    function _wrapETH() internal {
        if (msg.value > 0) {
            IWETH(wethAddress).deposit{ value: msg.value }(); // F:[FA-3]
            IWETH(wethAddress).transfer(msg.sender, msg.value); // F:[FA-3]
        }
    }

    
    
    
    
    function _isAccountLiquidatable(address creditAccount)
        internal
        view
        returns (bool isLiquidatable, uint256 totalValue)
    {
        IPriceOracleV2 priceOracle = IPriceOracleV2(
            creditManager.priceOracle()
        ); // F:[FA-14]

        (uint256 totalUSD, uint256 twvUSD) = _calcTotalValueUSD(
            priceOracle,
            creditAccount
        );

        // Computes total value in underlying
        totalValue = priceOracle.convertFromUSD(totalUSD, underlying); // F:[FA-14]

        (, , uint256 borrowAmountWithInterestAndFees) = creditManager
            .calcCreditAccountAccruedInterest(creditAccount); // F:[FA-14]

        // borrowAmountPlusInterestRateUSD x 10000 to be compared with USD values multiplied by LTs
        uint256 borrowAmountPlusInterestRateUSD = priceOracle.convertToUSD(
            borrowAmountWithInterestAndFees,
            underlying
        ) * PERCENTAGE_FACTOR;

        // Checks that current Hf < 1
        isLiquidatable = twvUSD < borrowAmountPlusInterestRateUSD;
    }

    
    function _isExpired() internal view returns (bool isExpired) {
        isExpired = (expirable) && (block.timestamp >= params.expirationDate); // F: [FA-46,47,48]
    }

    //
    // CONFIGURATION
    //

    
    
    /// without pausing the entire system. E.g., if a bug is reported
    /// that can potentially lead to loss of funds, but there is no
    /// immediate threat, new borrowing can be stopped, while other
    /// functionality (trading, closing/liquidating accounts) is retained
    function setIncreaseDebtForbidden(bool _mode)
        external
        creditConfiguratorOnly // F:[FA-44]
    {
        params.isIncreaseDebtForbidden = _mode;
    }

    
    
    /// the monitoring system serves to minimize loss from hacks
    /// While an attacker would be able to steal, in worst case,
    /// up to (limitPerBlock * n blocks) of funds, the monitoring
    /// system would pause the contracts after detecting suspicious
    /// activity
    function setLimitPerBlock(uint128 newLimit)
        external
        creditConfiguratorOnly // F:[FA-44]
    {
        params.maxBorrowedAmountPerBlock = newLimit;
    }

    
    
    function setExpirationDate(uint40 newExpirationDate)
        external
        creditConfiguratorOnly
    {
        if (!expirable) {
            revert NotAllowedWhenNotExpirableException();
        }
        params.expirationDate = newExpirationDate;
    }

    
    
    /// for liquidations, since very small amounts will make liquidations unprofitable for liquidators
    
    /// credit account - especially relevant in whitelisted mode.
    function setCreditAccountLimits(
        uint128 _minBorrowedAmount,
        uint128 _maxBorrowedAmount
    ) external creditConfiguratorOnly {
        limits.minBorrowedAmount = _minBorrowedAmount; // F:
        limits.maxBorrowedAmount = _maxBorrowedAmount; // F:
    }

    //
    // CONTRACT WATCHLIST CONFIGURATION AND GETTERS
    //

    
    /// Direct approvals are forbidden for contracts marked as "upgradeable" for
    /// security reasions
    
    
    
    /// Or other practices and patterns potentially detrimental to security
    /// Contracts from the list have certain restrictions applied to them
    function setUpgradeable(address addr, bool addOrRemove)
        external
        creditConfiguratorOnly
    {
        if (addOrRemove) {
            upgradeableContracts.add(addr); // F: [FA-50]
        } else {
            upgradeableContracts.remove(addr); // F: [FA-50]
        }
    }

    
    
    function isUpgradeableContract(address addr) external view returns (bool) {
        return upgradeableContracts.contains(addr); // F: [FA-50]
    }

    
    function upgradeableContractsList()
        external
        view
        returns (address[] memory)
    {
        return upgradeableContracts.values(); // F: [FA-50]
    }
}

interface ICreditAccount is ICrediAccountExceptions, IVersion {
    
    
    function initialize() external;

    
    
    
    
    function connectTo(
        address _creditManager,
        uint256 _borrowedAmount,
        uint256 _cumulativeIndexAtOpen
    ) external;

    
    
    
    function updateParameters(
        uint256 _borrowedAmount,
        uint256 _cumulativeIndexAtOpen
    ) external;

    
    
    
    function cancelAllowance(address token, address targetContract) external;

    
    
    
    
    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) external;

    
    function borrowedAmount() external view returns (uint256);

    
    function cumulativeIndexAtOpen() external view returns (uint256);

    
    function since() external view returns (uint256);

    
    function creditManager() external view returns (address);

    
    function factory() external view returns (address);

    
    
    
    function execute(address destination, bytes memory data)
        external
        returns (bytes memory);
}

interface IAccountFactory is
    IAccountFactoryGetters,
    IAccountFactoryEvents,
    IVersion
{
    
    function takeCreditAccount(
        uint256 _borrowedAmount,
        uint256 _cumulativeIndexAtOpen
    ) external returns (address);

    
    
    function returnCreditAccount(address usedAccount) external;
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

interface IWETHGateway {
    
    
    
    
    function addLiquidityETH(
        address pool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;

    
    ///       - burns lp's diesel (LP) tokens
    ///       - unwraps WETH to ETH and sends to the LP
    
    
    
    function removeLiquidityETH(
        address pool,
        uint256 amount,
        address payable to
    ) external;

    
    
    
    function unwrapWETH(address to, uint256 amount) external;
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

// Denominations

uint256 constant WAD = 1e18;
uint256 constant RAY = 1e27;

// 25% of type(uint256).max
uint256 constant ALLOWANCE_THRESHOLD = type(uint96).max >> 3;

// FEE = 50%
uint16 constant DEFAULT_FEE_INTEREST = 50_00; // 50%

// LIQUIDATION_FEE 1.5%
uint16 constant DEFAULT_FEE_LIQUIDATION = 1_50; // 1.5%

// LIQUIDATION PREMIUM 4%
uint16 constant DEFAULT_LIQUIDATION_PREMIUM = 4_00; // 4%

// LIQUIDATION_FEE_EXPIRED 2%
uint16 constant DEFAULT_FEE_LIQUIDATION_EXPIRED = 1_00; // 2%

// LIQUIDATION PREMIUM EXPIRED 2%
uint16 constant DEFAULT_LIQUIDATION_PREMIUM_EXPIRED = 2_00; // 2%

// DEFAULT PROPORTION OF MAX BORROWED PER BLOCK TO MAX BORROWED PER ACCOUNT
uint16 constant DEFAULT_LIMIT_PER_BLOCK_MULTIPLIER = 2;

// Seconds in a year
uint256 constant SECONDS_PER_YEAR = 365 days;
uint256 constant SECONDS_PER_ONE_AND_HALF_YEAR = (SECONDS_PER_YEAR * 3) / 2;

// OPERATIONS

// Leverage decimals - 100 is equal to 2x leverage (100% * collateral amount + 100% * borrowed amount)
uint8 constant LEVERAGE_DECIMALS = 100;

// Maximum withdraw fee for pool in PERCENTAGE_FACTOR format
uint8 constant MAX_WITHDRAW_FEE = 100;

uint256 constant EXACT_INPUT = 1;
uint256 constant EXACT_OUTPUT = 2;

address constant UNIVERSAL_CONTRACT = 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC;

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// 
pragma solidity ^0.8.10;

struct MultiCall {
    address target;
    bytes callData;
}

library MultiCallOps {
    function copyMulticall(MultiCall memory call)
        internal
        pure
        returns (MultiCall memory)
    {
        return MultiCall({ target: call.target, callData: call.callData });
    }

    function trim(MultiCall[] memory calls)
        internal
        pure
        returns (MultiCall[] memory trimmed)
    {
        uint256 len = calls.length;

        if (len == 0) return calls;

        uint256 foundLen;
        while (calls[foundLen].target != address(0)) {
            unchecked {
                ++foundLen;
                if (foundLen == len) return calls;
            }
        }

        if (foundLen > 0) return copy(calls, foundLen);
    }

    function copy(MultiCall[] memory calls, uint256 len)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        res = new MultiCall[](len);
        for (uint256 i; i < len; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
    }

    function clone(MultiCall[] memory calls)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        return copy(calls, calls.length);
    }

    function append(MultiCall[] memory calls, MultiCall memory newCall)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len = calls.length;
        res = new MultiCall[](len + 1);
        for (uint256 i; i < len; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
        res[len] = copyMulticall(newCall);
    }

    function prepend(MultiCall[] memory calls, MultiCall memory newCall)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len = calls.length;
        res = new MultiCall[](len + 1);
        res[0] = copyMulticall(newCall);

        for (uint256 i = 1; i < len + 1; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
    }

    function concat(MultiCall[] memory calls1, MultiCall[] memory calls2)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len1 = calls1.length;
        uint256 lenTotal = len1 + calls2.length;

        if (lenTotal == calls1.length) return clone(calls1);
        if (lenTotal == calls2.length) return clone(calls2);

        res = new MultiCall[](lenTotal);

        for (uint256 i; i < lenTotal; ) {
            res[i] = (i < len1)
                ? copyMulticall(calls1[i])
                : copyMulticall(calls2[i - len1]);
            unchecked {
                ++i;
            }
        }
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

struct Balance {
    address token;
    uint256 balance;
}

library BalanceOps {
    error UnknownToken(address);

    function copyBalance(Balance memory b)
        internal
        pure
        returns (Balance memory)
    {
        return Balance({ token: b.token, balance: b.balance });
    }

    function addBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance += amount;
    }

    function subBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance -= amount;
    }

    function getBalance(Balance[] memory b, address token)
        internal
        pure
        returns (uint256 amount)
    {
        return b[getIndex(b, token)].balance;
    }

    function setBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance = amount;
    }

    function getIndex(Balance[] memory b, address token)
        internal
        pure
        returns (uint256 index)
    {
        for (uint256 i; i < b.length; ) {
            if (b[i].token == token) {
                return i;
            }

            unchecked {
                ++i;
            }
        }
        revert UnknownToken(token);
    }

    function copy(Balance[] memory b, uint256 len)
        internal
        pure
        returns (Balance[] memory res)
    {
        res = new Balance[](len);
        for (uint256 i; i < len; ) {
            res[i] = copyBalance(b[i]);
            unchecked {
                ++i;
            }
        }
    }

    function clone(Balance[] memory b)
        internal
        pure
        returns (Balance[] memory)
    {
        return copy(b, b.length);
    }

    function getModifiedAfterSwap(
        Balance[] memory b,
        address tokenFrom,
        uint256 amountFrom,
        address tokenTo,
        uint256 amountTo
    ) internal pure returns (Balance[] memory res) {
        res = copy(b, b.length);
        setBalance(res, tokenFrom, getBalance(b, tokenFrom) - amountFrom);
        setBalance(res, tokenTo, getBalance(b, tokenTo) + amountTo);
    }
}

interface IDegenNFT is
    IDegenNFTExceptions,
    IDegenNFTEvents,
    IVersion,
    IERC721Metadata
{
    
    function minter() external view returns (address);

    
    function totalSupply() external view returns (uint256);

    
    function baseURI() external view returns (string memory);

    
    
    
    function mint(address to, uint256 amount) external;

    
    
    
    function burn(address from, uint256 amount) external;
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;






interface ICreditFacadeExtended {
    
    ///      and compare with actual balances at the end of a multicall, reverts
    ///      if at least one is less than expected
    
    
    ///         itself and can only be used within a multicall
    function revertIfReceivedLessThan(Balance[] memory expected) external;

    
    
    function enableToken(address token) external;

    
    
    
    ///         itself and can only be used within a multicall
    function disableToken(address token) external;

    
    
    
    
    function addCollateral(
        address onBehalfOf,
        address token,
        uint256 amount
    ) external payable;

    
    /// - Borrows the requested amount from the pool
    /// - Updates the CA's borrowAmount / cumulativeIndexOpen
    ///   to correctly compute interest going forward
    /// - Performs a full collateral check
    ///
    
    function increaseDebt(uint256 amount) external;

    
    /// - Decreases the debt by paying the requested amount + accrued interest + fees back to the pool
    /// - It's also include to this payment interest accrued at the moment and fees
    /// - Updates cunulativeIndex to cumulativeIndex now
    ///
    
    function decreaseDebt(uint256 amount) external;
}

// 

pragma solidity >=0.7.4;

interface IWETH {
    
    function deposit() external payable;

    
    function transfer(address to, uint256 value) external returns (bool);

    
    function withdraw(uint256) external;
}
