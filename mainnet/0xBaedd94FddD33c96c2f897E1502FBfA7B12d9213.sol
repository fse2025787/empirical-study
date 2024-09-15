// SPDX-License-Identifier: MIT
pragma abicoder v2;
pragma experimental ABIEncoderV2;


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

// 
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * 
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// 

pragma solidity >=0.6.0 <0.9.0;



abstract contract AccessControlMixin {
    IAccessControlProxy public accessControlProxy;

    function _initAccessControl(address _accessControlProxy) internal {
        accessControlProxy = IAccessControlProxy(_accessControlProxy);
    }

    modifier hasRole(bytes32 _role, address _account) {
        accessControlProxy.checkRole(_role, _account);
        _;
    }

    modifier onlyRole(bytes32 _role) {
        accessControlProxy.checkRole(_role, msg.sender);
        _;
    }

    modifier onlyGovOrDelegate() {
        accessControlProxy.checkGovOrDelegate(msg.sender);
        _;
    }

    modifier isVaultManager() {
        accessControlProxy.checkVaultOrGov(msg.sender);
        _;
    }

    modifier isKeeper() {
        accessControlProxy.checkKeeperOrVaultOrGov(msg.sender);
        _;
    }
}

// 

pragma solidity ^0.8.0;



interface IStrategy {
    struct OutputInfo {
        uint256 outputCode; //0：default path，Greater than 0：specify output path
        address[] outputTokens; //output tokens
    }

    event Borrow(address[] _assets, uint256[] _amounts);

    event Repay(uint256 _withdrawShares, uint256 _totalShares, address[] _assets, uint256[] _amounts);

    event SetIsWantRatioIgnorable(bool _oldValue, bool _newValue);

    
    function getVersion() external pure returns (string memory);

    
    function name() external view returns (string memory);

    
    function protocol() external view returns (uint16);

    
    function vault() external view returns (IVault);

    
    function harvester() external view returns (address);

    
    function getWantsInfo() external view returns (address[] memory _assets, uint256[] memory _ratios);

    
    function getWants() external view returns (address[] memory _wants);

    // @notice Provide the strategy output path when withdraw.
    function getOutputsInfo() external view returns (OutputInfo[] memory _outputsInfo);

    
    function setIsWantRatioIgnorable(bool _isWantRatioIgnorable) external;

    
    function getPositionDetail()
        external
        view
        returns (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool _isUsd,
            uint256 _usdValue
        );

    
    function estimatedTotalAssets() external view returns (uint256);

    
    function get3rdPoolAssets() external view returns (uint256);

    
    function harvest() external returns (address[] memory _rewardsTokens, uint256[] memory _claimAmounts);

    
    
    
    function borrow(address[] memory _assets, uint256[] memory _amounts) external;

    
    
    
    function repay(
        uint256 _withdrawShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) external returns (address[] memory _assets, uint256[] memory _amounts);

    
    function isWantRatioIgnorable() external view returns (bool);

    
    function poolQuota() external view returns (uint256);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// 
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";





abstract contract AssetHelpers {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    
    /// This is helpful for fully trusted contracts, such as adapters that
    /// interact with external protocol like Uniswap, Compound, etc.
    function __approveAssetMaxAsNeeded(
        address _asset,
        address _target,
        uint256 _neededAmount
    ) internal {
        if (IERC20Upgradeable(_asset).allowance(address(this), _target) < _neededAmount) {
            IERC20Upgradeable(_asset).safeApprove(_target, 0);
            IERC20Upgradeable(_asset).safeApprove(_target, _neededAmount);
        }
    }

    
    function __getAssetBalances(address _target, address[] memory _assets) internal view returns (uint256[] memory _balances) {
        _balances = new uint256[](_assets.length);
        for (uint256 i=0; i < _assets.length; i++) {
            _balances[i] = IERC20Upgradeable(_assets[i]).balanceOf(_target);
        }

        return _balances;
    }

    
    /// Requires an adequate allowance for each asset granted to the current contract for the target.
    function __pullFullAssetBalances(address _target, address[] memory _assets) internal returns (uint256[] memory _amountsTransferred) {
        _amountsTransferred = new uint256[](_assets.length);
        for (uint256 i=0; i < _assets.length; i++) {
            IERC20Upgradeable assetContract = IERC20Upgradeable(_assets[i]);
            _amountsTransferred[i] = assetContract.balanceOf(_target);
            if (_amountsTransferred[i] > 0) {
                assetContract.safeTransferFrom(_target, address(this), _amountsTransferred[i]);
            }
        }

        return _amountsTransferred;
    }

    
    /// Requires an adequate allowance for each asset granted to the current contract for the target.
    function __pullPartialAssetBalances(
        address _target,
        address[] memory _assets,
        uint256[] memory _amountsToExclude
    ) internal returns (uint256[] memory _amountsTransferred) {
        _amountsTransferred = new uint256[](_assets.length);
        for (uint256 i=0; i < _assets.length; i++) {
            IERC20Upgradeable assetContract = IERC20Upgradeable(_assets[i]);
            _amountsTransferred[i] = assetContract.balanceOf(_target) - _amountsToExclude[i];
            if (_amountsTransferred[i] > 0) {
                assetContract.safeTransferFrom(_target, address(this), _amountsTransferred[i]);
            }
        }

        return _amountsTransferred;
    }

    
    function __pushFullAssetBalances(address _target, address[] memory _assets) internal returns (uint256[] memory _amountsTransferred) {
        _amountsTransferred = new uint256[](_assets.length);
        for (uint256 i=0; i < _assets.length; i++) {
            IERC20Upgradeable assetContract = IERC20Upgradeable(_assets[i]);
            _amountsTransferred[i] = assetContract.balanceOf(address(this));
            if (_amountsTransferred[i] > 0) {
                assetContract.safeTransfer(_target, _amountsTransferred[i]);
            }
        }

        return _amountsTransferred;
    }
}
// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// 
pragma solidity ^0.8.0;









abstract contract UniswapV3LiquidityActionsMixin is AssetHelpers {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event UniV3Initialized(address _token0, address _token1, uint24 _fee);
    event UniV3NFTPositionAdded(uint256 indexed _tokenId, uint128 _liquidity, uint256 _amount0, uint256 _amount1);
    event UniV3NFTPositionRemoved(uint256 indexed _tokenId);
    event UniV3NFTCollect(uint256 _nftId, uint256 _amount0, uint256 _amount1);

    INonfungiblePositionManager internal constant nonfungiblePositionManager = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    IUniswapV3Pool public pool;

    address internal token0;
    address internal token1;
    uint24 internal fee;

    function _initializeUniswapV3Liquidity(address _pool) internal {
        pool = IUniswapV3Pool(_pool);
        token0 = pool.token0();
        token1 = pool.token1();
        fee = pool.fee();

        // Approve the NFT manager once for the max of each token
        IERC20Upgradeable(token0).safeApprove(address(nonfungiblePositionManager), type(uint256).max);
        IERC20Upgradeable(token1).safeApprove(address(nonfungiblePositionManager), type(uint256).max);
        emit UniV3Initialized(token0, token1, fee);
    }

    function __collectAll(uint256 _nftId) internal returns (uint256, uint256){
        return __collect(_nftId, type(uint128).max, type(uint128).max);
    }

    
    function __collect(uint256 _nftId, uint128 _amount0, uint128 _amount1) internal returns (uint256 __amount0, uint256 __amount1){
        (__amount0, __amount1) = nonfungiblePositionManager.collect(INonfungiblePositionManager.CollectParams({
            tokenId : _nftId,
            recipient : address(this),
            amount0Max : _amount0,
            amount1Max : _amount1
            })
        );
        emit UniV3NFTCollect(_nftId, __amount0, __amount1);
    }

    
    /// Uses a low-level staticcall() and truncated decoding of `.positions()`
    /// in order to avoid compilation error.
    function __getLiquidityForNFT(uint256 _nftId) internal view returns (uint128 _liquidity) {
        (bool _success, bytes memory _returnData) = address(nonfungiblePositionManager).staticcall(
            abi.encodeWithSelector(INonfungiblePositionManager.positions.selector, _nftId)
        );
        require(_success, string(_returnData));

        (,,,,,,, _liquidity) = abi.decode(
            _returnData,
            (uint96, address, address, address, uint24, int24, int24, uint128)
        );

        return _liquidity;
    }

    
    function __mint(INonfungiblePositionManager.MintParams memory _params) internal returns (
        uint256 _tokenId,
        uint128 _liquidity,
        uint256 _amount0,
        uint256 _amount1
    ){
        (_tokenId, _liquidity, _amount0, _amount1) = nonfungiblePositionManager.mint(_params);
        emit UniV3NFTPositionAdded(_tokenId, _liquidity, _amount0, _amount1);
    }

    
    /// _liquidity == 0 signifies no _liquidity to be removed (i.e., only collect and burn).
    /// 0 < _liquidity 0 < max uint128 signifies the full amount of _liquidity is known (more gas-efficient).
    /// _liquidity == max uint128 signifies the full amount of _liquidity is unknown.
    function __purge(
        uint256 _nftId,
        uint128 _liquidity,
        uint256 _amount0Min,
        uint256 _amount1Min
    ) internal {
        if (_liquidity == type(uint128).max) {
            // This consumes a lot of unnecessary gas because of all the SLOAD operations,
            // when we only care about `_liquidity`.
            // Should ideally only be used in the rare case where a griefing attack
            // (i.e., frontrunning the tx and adding extra _liquidity dust) is a concern.
            _liquidity = __getLiquidityForNFT(_nftId);
        }

        if (_liquidity > 0) {
            nonfungiblePositionManager.decreaseLiquidity(INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId : _nftId,
                liquidity : _liquidity,
                amount0Min : _amount0Min,
                amount1Min : _amount1Min,
                deadline : block.timestamp
            }));
        }

        __collectAll(_nftId);

        // Reverts if _liquidity or uncollected tokens are remaining
        nonfungiblePositionManager.burn(_nftId);

        emit UniV3NFTPositionRemoved(_nftId);
    }
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolImmutables {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);
}

// 
pragma solidity >=0.5.0;



/// per transaction
interface IUniswapV3PoolState {
    
    /// when accessed externally.
    
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// 
pragma solidity >=0.5.0;



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolActions {
    
    
    
    function initialize(uint160 sqrtPriceX96) external;

    
    
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    
    
    
    
    
    
    
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    
    
    
    
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    
    
    
    
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    
    
    /// the input observationCardinalityNext.
    
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolEvents {
    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

// 

pragma solidity ^0.8.0;











abstract contract BaseStrategy is IStrategy, Initializable, AccessControlMixin {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using StableMath for uint256;

    IVault public override vault;
    IValueInterpreter public valueInterpreter;
    address public override harvester;
    uint16 public override protocol;
    string public override name;
    address[] public wants;
    bool public override isWantRatioIgnorable;

    modifier onlyVault() {
        require(msg.sender == address(vault));
        _;
    }

    function _initialize(
        address _vault,
        address _harvester,
        string memory _name,
        uint16 _protocol,
        address[] memory _wants
    ) internal {
        protocol = _protocol;
        harvester = _harvester;
        name = _name;
        vault = IVault(_vault);
        valueInterpreter = IValueInterpreter(vault.valueInterpreter());

        _initAccessControl(vault.accessControlProxy());

        require(_wants.length > 0, "wants is required");
        for (uint256 i = 0; i < _wants.length; i++) {
            require(_wants[i] != address(0), "SAI");
        }
        wants = _wants;
    }

    
    function getVersion() external pure virtual override returns (string memory);

    
    function setIsWantRatioIgnorable(bool _isWantRatioIgnorable) external override isVaultManager {
        bool _oldValue = isWantRatioIgnorable;
        isWantRatioIgnorable = _isWantRatioIgnorable;
        emit SetIsWantRatioIgnorable(_oldValue, _isWantRatioIgnorable);
    }

    
    function getWantsInfo()
        external
        view
        virtual
        override
        returns (address[] memory _assets, uint256[] memory _ratios);

    
    function getWants() external view override returns (address[] memory) {
        return wants;
    }

    // @notice Provide the strategy output path when withdraw.
    function getOutputsInfo() external view virtual override returns (OutputInfo[] memory _outputsInfo);

    
    function getPositionDetail()
        public
        view
        virtual
        override
        returns (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool _isUsd,
            uint256 _usdValue
        );

    
    function estimatedTotalAssets() external view virtual override returns (uint256) {
        (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool _isUsd,
            uint256 _usdValue
        ) = getPositionDetail();
        if (_isUsd) {
            return _usdValue;
        } else {
            uint256 _totalUsdValue = 0;
            for (uint256 i = 0; i < _tokens.length; i++) {
                _totalUsdValue += queryTokenValue(_tokens[i], _amounts[i]);
            }
            return _totalUsdValue;
        }
    }

    
    function get3rdPoolAssets() external view virtual override returns (uint256);

    
    function harvest()
        external
        virtual
        override
        returns (address[] memory _rewardsTokens, uint256[] memory _claimAmounts)
    {
        vault.report(_rewardsTokens, _claimAmounts);
    }

    
    
    
    function borrow(address[] memory _assets, uint256[] memory _amounts) external override onlyVault {
        depositTo3rdPool(_assets, _amounts);
        emit Borrow(_assets, _amounts);
    }

    
    
    
    function repay(
        uint256 _repayShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) public virtual override onlyVault returns (address[] memory _assets, uint256[] memory _amounts) {
        require(_repayShares > 0 && _totalShares >= _repayShares, "cannot repay 0 shares");
        _assets = wants;
        uint256[] memory _balancesBefore = new uint256[](_assets.length);
        for (uint256 i = 0; i < _assets.length; i++) {
            _balancesBefore[i] = balanceOfToken(_assets[i]);
        }

        withdrawFrom3rdPool(_repayShares, _totalShares, _outputCode);
        _amounts = new uint256[](_assets.length);
        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 _balanceAfter = balanceOfToken(_assets[i]);
            _amounts[i] =
                _balanceAfter -
                _balancesBefore[i] +
                (_balancesBefore[i] * _repayShares) /
                _totalShares;
        }

        transferTokensToTarget(address(vault), _assets, _amounts);

        emit Repay(_repayShares, _totalShares, _assets, _amounts);
    }

    
    function poolQuota() public view virtual override returns (uint256) {
        return type(uint256).max;
    }

    
    
    
    function depositTo3rdPool(address[] memory _assets, uint256[] memory _amounts) internal virtual;

    
    
    
    function withdrawFrom3rdPool(
        uint256 _withdrawShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) internal virtual;

    
    function balanceOfToken(address _tokenAddress) internal view returns (uint256) {
        return IERC20Upgradeable(_tokenAddress).balanceOf(address(this));
    }

    
    function queryTokenValue(address _token, uint256 _amount)
        internal
        view
        returns (uint256 _valueInUSD)
    {
        _valueInUSD = valueInterpreter.calcCanonicalAssetValueInUsd(_token, _amount);
    }

    
    function decimalUnitOfToken(address _token) internal view returns (uint256) {
        return 10**IERC20MetadataUpgradeable(_token).decimals();
    }

    
    
    
    
    function transferTokensToTarget(
        address _target,
        address[] memory _assets,
        uint256[] memory _amounts
    ) internal {
        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 _amount = _amounts[i];
            if (_amount > 0) {
                IERC20Upgradeable(_assets[i]).safeTransfer(address(_target), _amount);
            }
        }
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// 
pragma solidity ^0.8.0;




/// require the pool to exist.
interface IPoolInitializer {
    
    
    
    
    
    
    
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}

// 
pragma solidity ^0.8.0;





interface IERC721Permit is IERC721 {
    
    
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    
    
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    
    
    
    
    
    
    
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}

// 
pragma solidity ^0.8.0;




interface IPeripheryPayments {
    
    
    
    
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    
    
    /// that use ether for the input amount
    function refundETH() external payable;

    
    
    
    
    
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}

// 
pragma solidity ^0.8.0;



interface IPeripheryImmutableState {
    
    function factory() external view returns (address);

    
    function WETH9() external view returns (address);
}
// 
pragma solidity ^0.8.0;
















contract UniswapV3Strategy is BaseStrategy, UniswapV3LiquidityActionsMixin, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event UniV3SetBaseThreshold(int24 _baseThreshold);
    event UniV3SetLimitThreshold(int24 _limitThreshold);
    event UniV3SetPeriod(uint256 _period);
    event UniV3SetMinTickMove(int24 _minTickMove);
    event UniV3SetMaxTwapDeviation(int24 _maxTwapDeviation);
    event UniV3SetTwapDuration(uint32 _twapDuration);

    int24 internal baseThreshold;
    int24 internal limitThreshold;
    int24 internal minTickMove;
    int24 internal maxTwapDeviation;
    int24 internal lastTick;
    int24 internal tickSpacing;
    uint256 internal period;
    uint256 internal lastTimestamp;
    uint32 internal twapDuration;

    struct MintInfo {
        uint256 tokenId;
        int24 tickLower;
        int24 tickUpper;
    }

    MintInfo internal baseMintInfo;
    MintInfo internal limitMintInfo;

    function initialize(
        address _vault,
        address _harvester,
        string memory _name,
        address _pool,
        int24 _baseThreshold,
        int24 _limitThreshold,
        uint256 _period,
        int24 _minTickMove,
        int24 _maxTwapDeviation,
        uint32 _twapDuration,
        int24 _tickSpacing
    ) external initializer {
        _initializeUniswapV3Liquidity(_pool);
        address[] memory _wants = new address[](2);
        _wants[0] = token0;
        _wants[1] = token1;
        baseThreshold = _baseThreshold;
        limitThreshold = _limitThreshold;
        period = _period;
        minTickMove = _minTickMove;
        maxTwapDeviation = _maxTwapDeviation;
        twapDuration = _twapDuration;
        tickSpacing = _tickSpacing;
        super._initialize(_vault, _harvester, _name, uint16(ProtocolEnum.UniswapV3), _wants);
    }

    function getVersion() external pure override returns (string memory) {
        return "1.0.0";
    }

    function getStatus() public view returns(int24 baseThreshold, int24 limitThreshold, int24 minTickMove, int24 maxTwapDeviation, int24 lastTick, int24 tickSpacing, uint256 period, uint256 lastTimestamp, uint32 twapDuration) {
        return (baseThreshold, limitThreshold, minTickMove, maxTwapDeviation, lastTick, tickSpacing, period, lastTimestamp, twapDuration);
    }

    function getMintInfo() public view returns(uint256 baseTokenId, int24 baseTickUpper, int24 baseTickLower, uint256 limitTokenId, int24 limitTickUpper, int24 limitTickLower) {
        return (baseMintInfo.tokenId, baseMintInfo.tickUpper, baseMintInfo.tickLower, limitMintInfo.tokenId, limitMintInfo.tickUpper, limitMintInfo.tickLower);
    }

    function getWantsInfo()
        public
        view
        override
        returns (address[] memory _assets, uint256[] memory _ratios)
    {
        _assets = wants;
        int24 _tickLower = baseMintInfo.tickLower;
        int24 _tickUpper = baseMintInfo.tickUpper;
        (, int24 _tick,,,,,) = pool.slot0();
        if (baseMintInfo.tokenId == 0 || shouldRebalance(_tick)) {
            (,, _tickLower, _tickUpper) = getSpecifiedRangesOfTick(_tick);
        }

        (uint256 _amount0, uint256 _amount1) = getAmountsForLiquidity(
		_tickLower, 
		_tickUpper,
		pool.liquidity()
	);
        _ratios = new uint256[](2);
        _ratios[0] = _amount0;
        _ratios[1] = _amount1;
    }

    function getOutputsInfo()
        external
        view
        virtual
        override
        returns (OutputInfo[] memory _outputsInfo)
    {
        _outputsInfo = new OutputInfo[](1);
        OutputInfo memory _info0 = _outputsInfo[0];
        _info0.outputCode = 0;
        _info0.outputTokens = wants;
    }

    function getSpecifiedRangesOfTick(int24 _tick) 
    	internal 
	    view 
        returns (
            int24 _tickFloor, 
            int24 _tickCeil, 
            int24 _tickLower, 
            int24 _tickUpper
        ) 
    {
        _tickFloor = _floor(_tick);
        _tickCeil = _tickFloor + tickSpacing;
        _tickLower = _tickFloor - baseThreshold;
        _tickUpper = _tickCeil + baseThreshold;
    }

    function getAmountsForLiquidity(
        int24 _tickLower, 
        int24 _tickUpper, 
        uint128 _liquidity
    ) internal view returns (uint256, uint256) {
        (uint160 _sqrtPriceX96, , , , , ,) = pool.slot0();
        (uint256 _amount0, uint256 _amount1) = LiquidityAmounts.getAmountsForLiquidity(
            _sqrtPriceX96, TickMath.getSqrtRatioAtTick(_tickLower), TickMath.getSqrtRatioAtTick(_tickUpper), _liquidity
            );
        return (_amount0, _amount1);
    }

    function getPositionDetail()
        public
        view
        override
        returns (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool _isUsd,
            uint256 _usdValue
        )
    {
        _tokens = wants;
        _amounts = new uint256[](2);
        _amounts[0] = balanceOfToken(token0);
        _amounts[1] = balanceOfToken(token1);
        (uint256 _amount0, uint256 _amount1) = balanceOfPoolWants(baseMintInfo);
        _amounts[0] += _amount0;
        _amounts[1] += _amount1;
        (_amount0, _amount1) = balanceOfPoolWants(limitMintInfo);
        _amounts[0] += _amount0;
        _amounts[1] += _amount1;
    }

    function balanceOfPoolWants(MintInfo memory _mintInfo)
        internal
        view
        returns (uint256, uint256)
    {
        if (_mintInfo.tokenId == 0) return (0, 0);
        return
            getAmountsForLiquidity(
                _mintInfo.tickLower,
                _mintInfo.tickUpper,
                balanceOfLpToken(_mintInfo.tokenId)
            );
    }

    function get3rdPoolAssets() external view override returns (uint256 totalAssets) {
        address _pool = IUniswapV3Factory(nonfungiblePositionManager.factory()).getPool(
            token0,
            token1,
            fee
        );
        totalAssets = queryTokenValue(token0, IERC20Minimal(token0).balanceOf(_pool));
        totalAssets += queryTokenValue(token1, IERC20Minimal(token1).balanceOf(_pool));
    }

    function harvest()
        public
        override
        returns (address[] memory _rewardsTokens, uint256[] memory _claimAmounts)
    {
        _rewardsTokens = wants;
        _claimAmounts = new uint256[](2);
        if (baseMintInfo.tokenId > 0) {
            (uint256 _amount0, uint256 _amount1) = __collectAll(baseMintInfo.tokenId);
            _claimAmounts[0] += _amount0;
            _claimAmounts[1] += _amount1;
        }

        if (limitMintInfo.tokenId > 0) {
            (uint256 _amount0, uint256 _amount1) = __collectAll(limitMintInfo.tokenId);
            _claimAmounts[0] += _amount0;
            _claimAmounts[1] += _amount1;
        }

        vault.report(_rewardsTokens, _claimAmounts);
    }

    function depositTo3rdPool(address[] memory _assets, uint256[] memory _amounts)
        internal
        override
    {
        (, int24 _tick, , , , , ) = pool.slot0();
        if (baseMintInfo.tokenId == 0) {
            (,, int24 _tickLower, int24 _tickUpper) = getSpecifiedRangesOfTick(_tick);
            mintNewPosition(
                _tickLower,
                _tickUpper, 
                balanceOfToken(token0), 
                balanceOfToken(token1), 
                true
            );
            lastTimestamp = block.timestamp;
            lastTick = _tick;
        } else {
            if (shouldRebalance(_tick)) {
                rebalance(_tick);
            } else {
                //add _liquidity
                INonfungiblePositionManager.IncreaseLiquidityParams
                    memory _params = INonfungiblePositionManager.IncreaseLiquidityParams({
                        tokenId: baseMintInfo.tokenId,
                        amount0Desired: balanceOfToken(token0),
                        amount1Desired: balanceOfToken(token1),
                        amount0Min: 0,
                        amount1Min: 0,
                        deadline: block.timestamp
                    });
                nonfungiblePositionManager.increaseLiquidity(_params);
            }
        }
    }

    function withdrawFrom3rdPool(
        uint256 _withdrawShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) internal override {
        if (_withdrawShares == _totalShares) {
            harvest();
        }
        withdraw(baseMintInfo.tokenId, _withdrawShares, _totalShares);
        withdraw(limitMintInfo.tokenId, _withdrawShares, _totalShares);
        if (_withdrawShares == _totalShares) {
            delete baseMintInfo;
            delete limitMintInfo;
        }
    }

    function withdraw(
        uint256 _tokenId,
        uint256 _withdrawShares,
        uint256 _totalShares
    ) internal {
        uint128 _withdrawLiquidity = uint128(
            (balanceOfLpToken(_tokenId) * _withdrawShares) / _totalShares
        );
        if (_withdrawLiquidity <= 0) return;
        if (_withdrawShares == _totalShares) {
            __purge(_tokenId, type(uint128).max, 0, 0);
        } else {
            removeLiquidity(_tokenId, _withdrawLiquidity);
        }
    }

    function removeLiquidity(uint256 _tokenId, uint128 _liquidity) internal {
        // remove _liquidity
        INonfungiblePositionManager.DecreaseLiquidityParams
            memory _params = INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: _tokenId,
                liquidity: _liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        (uint256 _amount0, uint256 _amount1) = nonfungiblePositionManager.decreaseLiquidity(_params);
        if (_amount0 > 0 || _amount1 > 0) {
            __collect(_params.tokenId, uint128(_amount0), uint128(_amount1));
        }
    }

    function balanceOfLpToken(uint256 _tokenId) public view returns (uint128) {
        if (_tokenId == 0) return 0;
        return __getLiquidityForNFT(_tokenId);
    }

    function rebalanceByKeeper() external nonReentrant isKeeper {
        (, int24 _tick, , , , , ) = pool.slot0();
        require(shouldRebalance(_tick), "cannot rebalance");
        rebalance(_tick);
    }

    function rebalance(int24 _tick) internal {
        harvest();
        // Withdraw all current _liquidity
        uint128 _baseLiquidity = balanceOfLpToken(baseMintInfo.tokenId);
        if (_baseLiquidity > 0) {
            __purge(baseMintInfo.tokenId, type(uint128).max, 0, 0);
            delete baseMintInfo;
        }

        uint128 _limitLiquidity = balanceOfLpToken(limitMintInfo.tokenId);
        if (_limitLiquidity > 0) {
            __purge(limitMintInfo.tokenId, type(uint128).max, 0, 0);
            delete limitMintInfo;
        }

        if (_baseLiquidity <= 0 && _limitLiquidity <= 0) return;

        // Mint new base and limit position
        (
            int24 _tickFloor,
            int24 _tickCeil,
            int24 _tickLower,
            int24 _tickUpper
        ) = getSpecifiedRangesOfTick(_tick);
        uint256 _balance0 = balanceOfToken(token0);
        uint256 _balance1 = balanceOfToken(token1);
        if (_balance0 > 0 && _balance1 > 0) {
            mintNewPosition(
                _tickLower,
                _tickUpper,
                _balance0,
                _balance1,
                true
            );
            _balance0 = balanceOfToken(token0);
            _balance1 = balanceOfToken(token1);
        }

        if (_balance0 > 0 || _balance1 > 0) {
            // Place bid or ask order on Uniswap depending on which token is left
            if (
                getLiquidityForAmounts(_tickFloor - limitThreshold, _tickFloor, _balance0, _balance1) >
                getLiquidityForAmounts(_tickCeil, _tickCeil + limitThreshold, _balance0, _balance1)
            ) {
                mintNewPosition(_tickFloor - limitThreshold, _tickFloor, _balance0, _balance1, false);
            } else {
                mintNewPosition(_tickCeil, _tickCeil + limitThreshold, _balance0, _balance1, false);
            }
        }
        lastTimestamp = block.timestamp;
        lastTick = _tick;
    }

    function shouldRebalance(int24 _tick) public view returns (bool) {
        // check enough time has passed
        if (block.timestamp < lastTimestamp + period) {
            return false;
        }

        // check price has moved enough
        if ((_tick > lastTick ? _tick - lastTick : lastTick - _tick) < minTickMove) {
            return false;
        }

        // check price near _twap
        int24 _twap = getTwap();
        int24 _twapDeviation = _tick > _twap ? _tick - _twap : _twap - _tick;
        if (_twapDeviation > maxTwapDeviation) {
            return false;
        }

        // check price not too close to boundary
        int24 _maxThreshold = baseThreshold > limitThreshold ? baseThreshold : limitThreshold;
        if (
            _tick < TickMath.MIN_TICK + _maxThreshold + tickSpacing ||
            _tick > TickMath.MAX_TICK - _maxThreshold - tickSpacing
        ) {
            return false;
        }

        (, , int24 _tickLower, int24 _tickUpper) = getSpecifiedRangesOfTick(_tick);
        if (baseMintInfo.tokenId != 0 && _tickLower == baseMintInfo.tickLower && _tickUpper == baseMintInfo.tickUpper) {
            return false;
        }

        return true;
    }

    function getLiquidityForAmounts(
        int24 _tickLower,
        int24 _tickUpper,
        uint256 _amount0,
        uint256 _amount1
    ) internal view returns (uint128) {
        (uint160 _sqrtPriceX96, , , , , , ) = pool.slot0();
        return
            LiquidityAmounts.getLiquidityForAmounts(
                _sqrtPriceX96,
                TickMath.getSqrtRatioAtTick(_tickLower),
                TickMath.getSqrtRatioAtTick(_tickUpper),
                _amount0,
                _amount1
            );
    }

    // Fetches time-weighted average price in ticks from Uniswap _pool.
    function getTwap() public view returns (int24) {
        uint32[] memory _secondsAgo = new uint32[](2);
        _secondsAgo[0] = twapDuration;
        _secondsAgo[1] = 0;

        (int56[] memory _tickCumulatives, ) = pool.observe(_secondsAgo);
        return int24((_tickCumulatives[1] - _tickCumulatives[0]) / int32(twapDuration));
    }

    // Rounds _tick down towards negative infinity so that it's a multiple of `tickSpacing`.
    function _floor(int24 _tick) internal view returns (int24) {
        // compressed=-27633, _tick=-276330, tickSpacing=10
        int24 compressed = _tick / tickSpacing;
        if (_tick < 0 && _tick % tickSpacing != 0) compressed--;
        return compressed * tickSpacing;
    }

    function mintNewPosition(
        int24 _tickLower,
        int24 _tickUpper,
        uint256 _amount0Desired,
        uint256 _amount1Desired,
        bool _base
    )
        internal
        returns (
            uint256 _tokenId,
            uint128 _liquidity,
            uint256 _amount0,
            uint256 _amount1
        )
    {
        INonfungiblePositionManager.MintParams memory _params = INonfungiblePositionManager
            .MintParams({
                token0: token0,
                token1: token1,
                fee: fee,
                tickLower: _tickLower,
                tickUpper: _tickUpper,
                amount0Desired: _amount0Desired,
                amount1Desired: _amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });
        (_tokenId, _liquidity, _amount0, _amount1) = __mint(_params);
        if (_base) {
            baseMintInfo = MintInfo({
                tokenId: _tokenId,
                tickLower: _tickLower,
                tickUpper: _tickUpper
            });
        } else {
            limitMintInfo = MintInfo({
                tokenId: _tokenId,
                tickLower: _tickLower,
                tickUpper: _tickUpper
            });
        }
    }

    function _checkThreshold(int24 _threshold) internal view {
        require(
            _threshold > 0 && _threshold <= TickMath.MAX_TICK && _threshold % tickSpacing == 0,
            "TE"
        );
    }

    function setBaseThreshold(int24 _baseThreshold) external isVaultManager {
        _checkThreshold(_baseThreshold);
        baseThreshold = _baseThreshold;
        emit UniV3SetBaseThreshold(_baseThreshold);
    }

    function setLimitThreshold(int24 _limitThreshold) external isVaultManager {
        _checkThreshold(_limitThreshold);
        limitThreshold = _limitThreshold;
        emit UniV3SetLimitThreshold(_limitThreshold);
    }

    function setPeriod(uint256 _period) external isVaultManager {
        period = _period;
        emit UniV3SetPeriod(_period);
    }

    function setMinTickMove(int24 _minTickMove) external isVaultManager {
        require(_minTickMove >= 0, "MINE");
        minTickMove = _minTickMove;
        emit UniV3SetMinTickMove(_minTickMove);
    }

    function setMaxTwapDeviation(int24 _maxTwapDeviation) external isVaultManager {
        require(_maxTwapDeviation >= 0, "MAXE");
        maxTwapDeviation = _maxTwapDeviation;
        emit UniV3SetMaxTwapDeviation(_maxTwapDeviation);
    }

    function setTwapDuration(uint32 _twapDuration) external isVaultManager {
        require(_twapDuration > 0, "TWAPE");
        twapDuration = _twapDuration;
        emit UniV3SetTwapDuration(_twapDuration);
    }
}

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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

// 
pragma solidity >=0.5.0;










/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// 
pragma solidity >=0.5.0;



interface IERC20Minimal {
    
    
    
    function balanceOf(address account) external view returns (uint256);

    
    
    
    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    
    
    
    function allowance(address owner, address spender) external view returns (uint256);

    
    
    
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    
    
    
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
pragma solidity >=0.5.0;



/// prices between 2**-128 and 2**128
library TickMath {
    
    int24 internal constant MIN_TICK = -887272;
    
    int24 internal constant MAX_TICK = -MIN_TICK;

    
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    
    
    
    
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(int(MAX_TICK)), 'T');

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    
    
    /// ever return.
    
    
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}

// 
pragma solidity >=0.5.0;










library SqrtPriceMath {
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    
    
    /// far enough to get the desired output amount, and in the exact input case (decreasing price) we need to move the
    /// price less in order to not send too much output.
    /// The most precise formula for this is liquidity * sqrtPX96 / (liquidity +- amount * sqrtPX96),
    /// if this is impossible because of overflow, we calculate liquidity / (liquidity / sqrtPX96 +- amount).
    
    
    
    
    
    function getNextSqrtPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {
        // we short circuit amount == 0 because the result is otherwise not guaranteed to equal the input price
        if (amount == 0) return sqrtPX96;
        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;

        if (add) {
            uint256 product;
            if ((product = amount * sqrtPX96) / amount == sqrtPX96) {
                uint256 denominator = numerator1 + product;
                if (denominator >= numerator1)
                    // always fits in 160 bits
                    return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));
            }

            return uint160(UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount)));
        } else {
            uint256 product;
            // if the product overflows, we know the denominator underflows
            // in addition, we must check that the denominator does not underflow
            require((product = amount * sqrtPX96) / amount == sqrtPX96 && numerator1 > product);
            uint256 denominator = numerator1 - product;
            return FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();
        }
    }

    
    
    /// far enough to get the desired output amount, and in the exact input case (increasing price) we need to move the
    /// price less in order to not send too much output.
    /// The formula we compute is within <1 wei of the lossless version: sqrtPX96 +- amount / liquidity
    
    
    
    
    
    function getNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {
        // if we're adding (subtracting), rounding down requires rounding the quotient down (up)
        // in both cases, avoid a mulDiv for most inputs
        if (add) {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? (amount << FixedPoint96.RESOLUTION) / liquidity
                        : FullMath.mulDiv(amount, FixedPoint96.Q96, liquidity)
                );

            return uint256(sqrtPX96).add(quotient).toUint160();
        } else {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? UnsafeMath.divRoundingUp(amount << FixedPoint96.RESOLUTION, liquidity)
                        : FullMath.mulDivRoundingUp(amount, FixedPoint96.Q96, liquidity)
                );

            require(sqrtPX96 > quotient);
            // always fits 160 bits
            return uint160(sqrtPX96 - quotient);
        }
    }

    
    
    
    
    
    
    
    function getNextSqrtPriceFromInput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountIn,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // round to make sure that we don't pass the target price
        return
            zeroForOne
                ? getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountIn, true)
                : getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountIn, true);
    }

    
    
    
    
    
    
    
    function getNextSqrtPriceFromOutput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountOut,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // round to make sure that we pass the target price
        return
            zeroForOne
                ? getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountOut, false)
                : getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountOut, false);
    }

    
    
    /// i.e. liquidity * (sqrt(upper) - sqrt(lower)) / (sqrt(upper) * sqrt(lower))
    
    
    
    
    
    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
        uint256 numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

        require(sqrtRatioAX96 > 0);

        return
            roundUp
                ? UnsafeMath.divRoundingUp(
                    FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtRatioBX96),
                    sqrtRatioAX96
                )
                : FullMath.mulDiv(numerator1, numerator2, sqrtRatioBX96) / sqrtRatioAX96;
    }

    
    
    
    
    
    
    
    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            roundUp
                ? FullMath.mulDivRoundingUp(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    
    
    
    
    
    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount0) {
        return
            liquidity < 0
                ? -getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
    }

    
    
    
    
    
    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount1) {
        return
            liquidity < 0
                ? -getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
    }
}

// 

pragma solidity ^0.8.0;



abstract contract BaseClaimableStrategy is BaseStrategy {

    
    /// recognizing any profits or losses and adjusting the Strategy's position.
    
    
    function harvest()
        public
        virtual
        override
        returns (
            address[] memory _rewardsTokens,
            uint256[] memory _claimAmounts
        )
    {
        (_rewardsTokens, _claimAmounts) = claimRewards();
        // transfer reward token to harvester
        transferTokensToTarget(harvester, _rewardsTokens, _claimAmounts);
        vault.report(_rewardsTokens, _claimAmounts);
    }

    
    
    
    function claimRewards()
        internal
        virtual
        returns (
            address[] memory _rewardsTokens,
            uint256[] memory _claimAmounts
        );

    
    
    
    function repay(uint256 _repayShares, uint256 _totalShares,uint256 _outputCode)
        public
        virtual
        override
        onlyVault
        returns (address[] memory _assets, uint256[] memory _amounts)
    {
        // if withdraw all need claim rewards
        if (_repayShares == _totalShares) {
            harvest();
        }
        return super.repay(_repayShares, _totalShares,_outputCode);
    }
}

// 
pragma solidity ^0.8.0;











/// and authorized.
interface INonfungiblePositionManager is
IPoolInitializer,
IPeripheryPayments,
IPeripheryImmutableState,
IERC721Metadata,
IERC721Enumerable,
IERC721Permit
{
    
    
    
    
    
    
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    
    
    
    
    
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    
    
    
    
    
    
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function positions(uint256 tokenId)
    external
    view
    returns (
        uint96 nonce,
        address operator,
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint128 tokensOwed0,
        uint128 tokensOwed1
    );

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    
    
    /// a method does not exist, i.e. the pool is assumed to be initialized.
    
    
    
    
    
    function mint(MintParams calldata params)
    external
    payable
    returns (
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    
    
    /// amount0Desired The desired amount of token0 to be spent,
    /// amount1Desired The desired amount of token1 to be spent,
    /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// deadline The time by which the transaction must be included to effect the change
    
    
    
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
    external
    payable
    returns (
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    
    
    /// amount The amount by which liquidity will be decreased,
    /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// deadline The time by which the transaction must be included to effect the change
    
    
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
    external
    payable
    returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    
    
    /// recipient The account that should receive the tokens,
    /// amount0Max The maximum amount of token0 to collect,
    /// amount1Max The maximum amount of token1 to collect
    
    
    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    
    /// must be collected first.
    
    function burn(uint256 tokenId) external payable;
}

// 
pragma solidity >=0.5.0;






library LiquidityAmounts {
    
    
    
    function toUint128(uint256 x) private pure returns (uint128 y) {
        require((y = uint128(x)) == x);
    }

    
    
    
    
    
    
    function getLiquidityForAmount0(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = UniswapV3FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
        return toUint128(UniswapV3FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    
    
    
    
    
    
    function getLiquidityForAmount1(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return toUint128(UniswapV3FullMath.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
    }

    
    /// pool prices and the prices at the tick boundaries
    
    
    
    
    
    
    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
        }
    }

    
    
    
    
    
    function getAmount0ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
        UniswapV3FullMath.mulDiv(
            uint256(liquidity) << FixedPoint96.RESOLUTION,
            sqrtRatioBX96 - sqrtRatioAX96,
            sqrtRatioBX96
        ) / sqrtRatioAX96;
    }

    
    
    
    
    
    function getAmount1ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return UniswapV3FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    
    /// pool prices and the prices at the tick boundaries
    
    
    
    
    
    
    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
        } else {
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }
}

// 
pragma solidity >=0.6.0 <0.9.0;

enum ProtocolEnum {
    Balancer,
    UniswapV2,
    Dodo,
    Sushi_Kashi,
    Sushi_Swap,
    Convex,
    Rari,
    UniswapV3,
    YearnEarn,
    YearnV2,
    YearnIronBank,
    GUni,
    Stargate,
    DForce,
    Synapse,
    Aura
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
pragma solidity >=0.7.0;



library LowGasSafeMath {
    
    
    
    
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    
    
    
    
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    
    
    
    
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    
    
    
    
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    
    
    
    
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}

// 
pragma solidity >=0.5.0;



library SafeCast {
    
    
    
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    
    
    
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    
    
    
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}

// 
pragma solidity >=0.4.0;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = (type(uint256).max - denominator + 1) & denominator;
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// 
pragma solidity >=0.5.0;



library UnsafeMath {
    
    
    
    
    
    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }
}

// 
pragma solidity >=0.4.0;




library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

pragma solidity >=0.6.0 <0.9.0;

library BocRoles {
    bytes32 internal constant GOV_ROLE = 0x00;

    bytes32 internal constant DELEGATE_ROLE = keccak256("DELEGATE_ROLE");

    bytes32 internal constant VAULT_ROLE = keccak256("VAULT_ROLE");

    bytes32 internal constant KEEPER_ROLE = keccak256("KEEPER_ROLE");
}

// 

pragma solidity ^0.8.0;



// Based on StableMath from Stability Labs Pty. Ltd.
// https://github.com/mstable/mStable-contracts/blob/master/contracts/shared/StableMath.sol

library StableMath {

    /**
     * @dev Scaling unit for use in specific calculations,
     * where 1 * 10**18, or 1e18 represents a unit '1'
     */
    uint256 private constant FULL_SCALE = 1e18;

    /***************************************
                    Helpers
    ****************************************/

    /**
     * @dev Adjust the scale of an integer
     * @param to Decimals to scale to
     * @param from Decimals to scale from
     */
    function scaleBy(
        uint256 x,
        uint256 to,
        uint256 from
    ) internal pure returns (uint256) {
        if (to > from) {
            x = x * (10 ** (to - from));
        } else if (to < from) {
            x = x / (10 ** (from - to));
        }
        return x;
    }

    /***************************************
               Precise Arithmetic
    ****************************************/

    /**
     * @dev Multiplies two precise units, and then truncates by the full scale
     * @param x Left hand input to multiplication
     * @param y Right hand input to multiplication
     * @return Result after multiplying the two inputs and then dividing by the shared
     *         scale unit
     */
    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulTruncateScale(x, y, FULL_SCALE);
    }

    /**
     * @dev Multiplies two precise units, and then truncates by the given scale. For example,
     * when calculating 90% of 10e18, (10e18 * 9e17) / 1e18 = (9e36) / 1e18 = 9e18
     * @param x Left hand input to multiplication
     * @param y Right hand input to multiplication
     * @param scale Scale unit
     * @return Result after multiplying the two inputs and then dividing by the shared
     *         scale unit
     */
    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {
        // e.g. assume scale = fullScale
        // z = 10e18 * 9e17 = 9e36
        uint256 z = x * y;
        // return 9e36 / 1e18 = 9e18
        return z / scale;
    }

    /**
     * @dev Multiplies two precise units, and then truncates by the full scale, rounding up the result
     * @param x Left hand input to multiplication
     * @param y Right hand input to multiplication
     * @return Result after multiplying the two inputs and then dividing by the shared
     *          scale unit, rounded up to the closest base unit.
     */
    function mulTruncateCeil(uint256 x, uint256 y)
    internal
    pure
    returns (uint256)
    {
        // e.g. 8e17 * 17268172638 = 138145381104e17
        uint256 scaled = x * y;
        // e.g. 138145381104e17 + 9.99...e17 = 138145381113.99...e17
        uint256 ceil = scaled + (FULL_SCALE - 1);
        // e.g. 13814538111.399...e18 / 1e18 = 13814538111
        return ceil / FULL_SCALE;
    }

    /**
     * @dev Precisely divides two units, by first scaling the left hand operand. Useful
     *      for finding percentage weightings, i.e. 8e18/10e18 = 80% (or 8e17)
     * @param x Left hand input to division
     * @param y Right hand input to division
     * @return Result after multiplying the left operand by the scale, and
     *         executing the division on the right hand input.
     */
    function divPrecisely(uint256 x, uint256 y)
    internal
    pure
    returns (uint256)
    {
        // e.g. 8e18 * 1e18 = 8e36
        uint256 z = x * FULL_SCALE;
        // e.g. 8e36 / 10e18 = 8e17
        return z / y;
    }

    /**
     * @dev Precisely divides two units, by first scaling the left hand operand. Useful
     *      for finding percentage weightings, i.e. 8e18/10e18 = 80% (or 8e17)
     * @param x Left hand input to division
     * @param y Right hand input to division
     * @return Result after multiplying the left operand by the scale, and
     *         executing the division on the right hand input.
     */
    function divPreciselyScale(uint256 x, uint256 y, uint256 scale)
    internal
    pure
    returns (uint256)
    {
        // e.g. 8e18 * 1e18 = 8e36
        uint256 z = x * scale;
        // e.g. 8e36 / 10e18 = 8e17
        return z / y;
    }
}

// 

pragma solidity ^0.8.0;

interface IValueInterpreter {

    
    
    
    
    
    
    /// but not a view because calls to price feeds can potentially update third party state
    function calcCanonicalAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) external view returns (uint256);

    
    
    
    
    
    
    /// but not a view because calls to price feeds can potentially update third party state.
    /// Does not handle a derivative quote asset.
    function calcCanonicalAssetsTotalValue(
        address[] calldata _baseAssets,
        uint256[] calldata _amounts,
        address _quoteAsset
    ) external view returns (uint256);

    
    
    
    
    
    function calcCanonicalAssetValueInUsd(
        address _baseAsset,
        uint256 _amount
    ) external view returns (uint256);

     
    
    
    
    function price(address _baseAsset) external view returns (uint256);
}

// 

pragma solidity >=0.6.0 <0.9.0;

interface IAccessControlProxy {
    function isGovOrDelegate(address _account) external view returns (bool);

    function isVaultOrGov(address _account) external view returns (bool);

    function isKeeperOrVaultOrGov(address _account) external view returns (bool);

    function hasRole(bytes32 _role, address _account) external view returns (bool);

    function checkRole(bytes32 _role, address _account) external view;

    function checkGovOrDelegate(address _account) external view;

    function checkVaultOrGov(address _account) external view;

    function checkKeeperOrVaultOrGov(address _account) external;
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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




interface IVault {
    
    
    
    
    
    struct StrategyParams {
        uint256 lastReport;
        uint256 totalDebt;
        uint256 profitLimitRatio;
        uint256 lossLimitRatio;
        bool enforceChangeLimit;
    }

    
    
    
    struct StrategyAdd {
        address strategy;
        uint256 profitLimitRatio;
        uint256 lossLimitRatio;
    }

    event AddAsset(address _asset);
    event RemoveAsset(address _asset);
    event AddStrategies(address[] _strategies);
    event RemoveStrategies(address[] _strategies);
    event RemoveStrategyByForce(address _strategy);
    event Mint(address _account, address[] _assets, uint256[] _amounts, uint256 _mintAmount);
    event Burn(
        address _account,
        uint256 _amount,
        uint256 _actualAmount,
        uint256 _shareAmount,
        address[] _assets,
        uint256[] _amounts
    );
    event Exchange(
        address _platform,
        address _srcAsset,
        uint256 _srcAmount,
        address _distAsset,
        uint256 _distAmount
    );
    event Redeem(address _strategy, uint256 _debtChangeAmount, address[] _assets, uint256[] _amounts);
    event LendToStrategy(
        address indexed _strategy,
        address[] _wants,
        uint256[] _amounts,
        uint256 _lendValue
    );
    event RepayFromStrategy(
        address indexed _strategy,
        uint256 _strategyWithdrawValue,
        uint256 _strategyTotalValue,
        address[] _assets,
        uint256[] _amounts
    );
    event RemoveStrategyFromQueue(address[] _strategies);
    event SetEmergencyShutdown(bool _shutdown);
    event RebasePaused();
    event RebaseUnpaused();
    event RebaseThresholdUpdated(uint256 _threshold);
    event TrusteeFeeBpsChanged(uint256 _basis);
    event MaxTimestampBetweenTwoReportedChanged(uint256 _maxTimestampBetweenTwoReported);
    event MinCheckedStrategyTotalDebtChanged(uint256 _minCheckedStrategyTotalDebt);
    event MinimumInvestmentAmountChanged(uint256 _minimumInvestmentAmount);
    event TreasuryAddressChanged(address _address);
    event ExchangeManagerAddressChanged(address _address);
    event SetAdjustPositionPeriod(bool _adjustPositionPeriod);
    event RedeemFeeUpdated(uint256 _redeemFeeBps);
    event SetWithdrawalQueue(address[] _queues);
    event Rebase(uint256 _totalShares, uint256 _totalValue, uint256 _newUnderlyingUnitsPerShare);
    event StrategyReported(
        address indexed _strategy,
        uint256 _gain,
        uint256 _loss,
        uint256 _lastStrategyTotalDebt,
        uint256 _nowStrategyTotalDebt,
        address[] _rewardTokens,
        uint256[] _claimAmounts,
        uint256 _type
    );
    event StartAdjustPosition(
        uint256 _totalDebtOfBeforeAdjustPosition,
        address[] _trackedAssets,
        uint256[] _vaultCashDetatil,
        uint256[] _vaultBufferCashDetail
    );
    event EndAdjustPosition(
        uint256 _transferValue,
        uint256 _redeemValue,
        uint256 _totalDebt,
        uint256 _totalValueOfAfterAdjustPosition,
        uint256 _totalValueOfBeforeAdjustPosition
    );
    event PegTokenSwapCash(uint256 _pegTokenAmount, address[] _assets, uint256[] _amounts);

    
    function getVersion() external pure returns (string memory);

    
    function getSupportAssets() external view returns (address[] memory _assets);

    
    function checkIsSupportAsset(address _asset) external view;

    
    function getTrackedAssets() external view returns (address[] memory _assets);

    
    function valueOfTrackedTokens() external view returns (uint256 _totalValue);

    
    function valueOfTrackedTokensIncludeVaultBuffer() external view returns (uint256 _totalValue);

    
    function totalAssets() external view returns (uint256);

    
    function totalAssetsIncludeVaultBuffer() external view returns (uint256);

    
    function totalValue() external view returns (uint256);

    
    function startAdjustPosition() external;

    
    function endAdjustPosition() external;

    
    function underlyingUnitsPerShare() external view returns (uint256);

    
    function getPegTokenPrice() external view returns (uint256);

    /**
     * @dev Internal to calculate total value of all assets held in Vault.
     * @return _value Total value(by chainlink price) in USD (1e18)
     */
    function totalValueInVault() external view returns (uint256 _value);

    /**
     * @dev Internal to calculate total value of all assets held in Strategies.
     * @return _value Total value(by chainlink price) in USD (1e18)
     */
    function totalValueInStrategies() external view returns (uint256 _value);

    
    function getStrategies() external view returns (address[] memory _strategies);

    
    function checkActiveStrategy(address _strategy) external view;

    
    
    
    
    
    function estimateMint(address[] memory _assets, uint256[] memory _amounts)
        external
        view
        returns (uint256 _shareAmount);

    
    
    
    
    
    function mint(
        address[] memory _assets,
        uint256[] memory _amounts,
        uint256 _minimumAmount
    ) external returns (uint256 _shareAmount);

    
    
    
    function burn(uint256 _amount, uint256 _minimumAmount)
        external
        returns (address[] memory _assets, uint256[] memory _amounts);

    
    function rebase() external;

    
    function lend(address _strategy, IExchangeAggregator.ExchangeToken[] calldata _exchangeTokens)
        external;

    
    function redeem(
        address _strategy,
        uint256 _amount,
        uint256 _outputCode
    ) external;

    /**
     * @dev Exchange from '_fromToken' to '_toToken'
     * @param _fromToken The token swap from
     * @param _toToken The token swap to
     * @param _amount The amount to swap
     * @param _exchangeParam The struct of ExchangeParam, see {ExchangeParam} struct
     * @return _exchangeAmount The real amount to exchange
     * Emits a {Exchange} event.
     */
    function exchange(
        address _fromToken,
        address _toToken,
        uint256 _amount,
        IExchangeAggregator.ExchangeParam memory _exchangeParam
    ) external returns (uint256);

    /**
     * @dev Report the current asset of strategy caller
     * @param _rewardTokens The reward token list
     * @param _claimAmounts The claim amount list
     * Emits a {StrategyReported} event.
     */
    function report(address[] memory _rewardTokens, uint256[] memory _claimAmounts) external;

    
    function setEmergencyShutdown(bool _active) external;

    
    function setAdjustPositionPeriod(bool _adjustPositionPeriod) external;

    /**
     * @dev Set a minimum difference ratio automatically rebase.
     * rebase
     * @param _threshold _threshold is the numerator and the denominator is 10000000 (x/10000000).
     */
    function setRebaseThreshold(uint256 _threshold) external;

    /**
     * @dev Set a fee in basis points to be charged for a redeem.
     * @param _redeemFeeBps Basis point fee to be charged
     */
    function setRedeemFeeBps(uint256 _redeemFeeBps) external;

    /**
     * @dev Sets the treasuryAddress that can receive a portion of yield.
     *      Setting to the zero address disables this feature.
     */
    function setTreasuryAddress(address _address) external;

    /**
     * @dev Sets the exchangeManagerAddress that can receive a portion of yield.
     */
    function setExchangeManagerAddress(address _exchangeManagerAddress) external;

    /**
     * @dev Sets the TrusteeFeeBps to the percentage of yield that should be
     *      received in basis points.
     */
    function setTrusteeFeeBps(uint256 _basis) external;

    
    function setWithdrawalQueue(address[] memory _queues) external;

    function setStrategyEnforceChangeLimit(address _strategy, bool _enabled) external;

    function setStrategySetLimitRatio(
        address _strategy,
        uint256 _lossRatioLimit,
        uint256 _profitLimitRatio
    ) external;

    /**
     * @dev Set the deposit paused flag to true to prevent rebasing.
     */
    function pauseRebase() external;

    /**
     * @dev Set the deposit paused flag to true to allow rebasing.
     */
    function unpauseRebase() external;

    
    function addAsset(address _asset) external;

    
    function removeAsset(address _asset) external;

    
    
    ///      Vault may invest funds into the strategy,
    ///      and the strategy will invest the funds in the 3rd protocol
    function addStrategy(StrategyAdd[] memory _strategyAdds) external;

    
    
    function removeStrategy(address[] memory _strategies) external;

    function forceRemoveStrategy(address _strategy) external;

    /***************************************
                     WithdrawalQueue
     ****************************************/
    function getWithdrawalQueue() external view returns (address[] memory);

    function removeStrategyFromQueue(address[] memory _strategies) external;

    
    function adjustPositionPeriod() external view returns (bool);

    
    function emergencyShutdown() external view returns (bool);

    
    function rebasePaused() external view returns (bool);

    
    /// over this difference ratio automatically rebase.
    /// rebaseThreshold is the numerator and the denominator is 10000000 x/10000000.
    function rebaseThreshold() external view returns (uint256);

    
    function trusteeFeeBps() external view returns (uint256);

    
    function redeemFeeBps() external view returns (uint256);

    
    function totalDebt() external view returns (uint256);

    
    function exchangeManager() external view returns (address);

    
    function strategies(address _strategy) external view returns (StrategyParams memory);

    
    function withdrawQueue() external view returns (address[] memory);

    
    function treasury() external view returns (address);

    
    function valueInterpreter() external view returns (address);

    
    function accessControlProxy() external view returns (address);

    
    function setMinCheckedStrategyTotalDebt(uint256 _minCheckedStrategyTotalDebt) external;

    
    function minCheckedStrategyTotalDebt() external view returns (uint256);

    
    function setMaxTimestampBetweenTwoReported(uint256 _maxTimestampBetweenTwoReported) external;

    
    function maxTimestampBetweenTwoReported() external view returns (uint256);

    
    function setMinimumInvestmentAmount(uint256 _minimumInvestmentAmount) external;

    
    function minimumInvestmentAmount() external view returns (uint256);

    
    function setVaultBufferAddress(address _address) external;

    
    function vaultBufferAddress() external view returns (address);

    
    function setPegTokenAddress(address _address) external;

    
    function pegTokenAddress() external view returns (address);

    
    function setAdminImpl(address _newImpl) external;
}

// 

pragma solidity ^0.8.0;



interface IExchangeAggregator {
    /**
     * @param platform Called exchange platforms
     * @param method The method of the exchange platform
     * @param encodeExchangeArgs The encoded parameters to call
     * @param slippage The slippage when exchange
     * @param oracleAdditionalSlippage The additional slippage for oracle estimated
     */
    struct ExchangeParam {
        address platform;
        uint8 method;
        bytes encodeExchangeArgs;
        uint256 slippage;
        uint256 oracleAdditionalSlippage;
    }

    /**
     * @param platform Called exchange platforms
     * @param method The method of the exchange platform
     * @param data The encoded parameters to call
     * @param swapDescription swap info
     */
    struct SwapParam {
        address platform;
        uint8 method;
        bytes data;
        IExchangeAdapter.SwapDescription swapDescription;
    }

    /**
     * @param srcToken The token swap from
     * @param dstToken The token swap to
     * @param amount The amount to swap
     * @param exchangeParam The struct of ExchangeParam
     */
    struct ExchangeToken {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        ExchangeParam exchangeParam;
    }

    event ExchangeAdapterAdded(address[] _exchangeAdapters);

    event ExchangeAdapterRemoved(address[] _exchangeAdapters);

    event Swap(
        address _platform,
        uint256 _amount,
        address _srcToken,
        address _dstToken,
        uint256 _exchangeAmount,
        address indexed _receiver,
        address _sender
    );

    function swap(
        address _platform,
        uint8 _method,
        bytes calldata _data,
        IExchangeAdapter.SwapDescription calldata _sd
    ) external payable returns (uint256);

    function batchSwap(SwapParam[] calldata _swapParams) external payable returns (uint256[] memory);

    function getExchangeAdapters()
        external
        view
        returns (address[] memory _exchangeAdapters, string[] memory _identifiers);

    function addExchangeAdapters(address[] calldata _exchangeAdapters) external;

    function removeExchangeAdapters(address[] calldata _exchangeAdapters) external;
}

// 

pragma solidity >=0.6.0 <0.9.0;


interface IExchangeAdapter {
    /**
     * @param amount The amount to swap
     * @param srcToken The token swap from
     * @param dstToken The token swap to
     * @param receiver The user to receive `dstToken`
     */
    struct SwapDescription {
        uint256 amount;
        address srcToken;
        address dstToken;
        address receiver;
    }

    
    function identifier() external pure returns (string memory _identifier);

    /**
     * @notice Swap with `_sd` data by using `_method` and `_data` on `_platform`.
     * @param _method The method of the exchange platform
     * @param _encodedCallArgs The encoded parameters to call
     * @param _sd The description info of this swap
     * @return The expected amountIn to swap
     */
    function swap(
        uint8 _method,
        bytes calldata _encodedCallArgs,
        SwapDescription calldata _sd
    ) external payable returns (uint256);
}

// 
pragma solidity ^0.8.0;


library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            ))
        );
    }
}

// 

pragma solidity ^0.8.0;




library UniswapV3FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
    unchecked {
        // 512-bit multiply [prod1 prod0] = a * b.
        // Compute the product mod 2**256 and mod 2**256 - 1,
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product.
        uint256 prod1; // Most significant 256 bits of the product.
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }
        // Handle non-overflow cases, 256 by 256 division.
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }
        // Make sure the result is less than 2**256 -
        // also prevents denominator == 0.
        require(denominator > prod1);
        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////
        // Make division exact by subtracting the remainder from [prod1 prod0] -
        // compute remainder using mulmod.
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number.
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }
        // Factor powers of two out of denominator -
        // compute largest power of two divisor of denominator
        // (always >= 1).
        uint256 twos = uint256(-int256(denominator)) & denominator;
        // Divide denominator by power of two.
        assembly {
            denominator := div(denominator, twos)
        }
        // Divide [prod1 prod0] by the factors of two.
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos -
        // if twos is zero, then it becomes one.
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;
        // Invert denominator mod 2**256 -
        // now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // for four bits. That is, denominator * inv = 1 mod 2**4.
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // Inverse mod 2**8.
        inv *= 2 - denominator * inv; // Inverse mod 2**16.
        inv *= 2 - denominator * inv; // Inverse mod 2**32.
        inv *= 2 - denominator * inv; // Inverse mod 2**64.
        inv *= 2 - denominator * inv; // Inverse mod 2**128.
        inv *= 2 - denominator * inv; // Inverse mod 2**256.
        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }
    }

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
    unchecked {
        if (mulmod(a, b, denominator) != 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
    }
}
