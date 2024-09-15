// SPDX-License-Identifier: MIT
pragma abicoder v2;


// 
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// 
// OpenZeppelin Contracts v4.4.0 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;



/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// 
pragma solidity 0.8.9;

interface IERC1271 {
    
    
    ///
    /// MUST return the bytes4 magic value 0x1626ba7e when function passes.
    ///
    /// MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
    ///
    /// MUST allow external calls
    
    
    
    function isValidSignature(bytes32 _hash, bytes memory _signature) external view returns (bytes4 magicValue);
}

// 
pragma solidity 0.8.9;



interface IDefaultAccessControl is IAccessControlEnumerable {
    
    
    
    function isAdmin(address who) external view returns (bool);

    
    
    
    function isOperator(address who) external view returns (bool);
}

// 
pragma solidity 0.8.9;



interface IVault is IERC165 {
    

    function initialized() external view returns (bool);

    
    function nft() external view returns (uint256);

    
    function vaultGovernance() external view returns (IVaultGovernance);

    
    function vaultTokens() external view returns (address[] memory);

    
    
    
    function isVaultToken(address token) external view returns (bool);

    
    
    /// other DeFi protocol. For example, for USDC Yearn Vault this would be total USDC balance that could be withdrawn for Yearn to this contract.
    /// The tvl itself is estimated in some range. Sometimes the range is exact, sometimes it's not
    
    
    function tvl() external view returns (uint256[] memory minTokenAmounts, uint256[] memory maxTokenAmounts);

    
    function pullExistentials() external view returns (uint256[] memory);
}

// 
pragma solidity 0.8.9;

interface IVaultRoot {
    
    
    
    function hasSubvault(uint256 nft_) external view returns (bool);

    
    
    
    function subvaultAt(uint256 index) external view returns (address);

    
    
    
    function subvaultOneBasedIndex(uint256 nft_) external view returns (uint256);

    
    
    function subvaultNfts() external view returns (uint256[] memory);
}

// 
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// 
pragma solidity 0.8.9;




interface IUnitPricesGovernance is IDefaultAccessControl, IERC165 {
    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    
    function stagedUnitPrices(address token) external view returns (uint256);

    
    
    
    function stagedUnitPricesTimestamps(address token) external view returns (uint256);

    
    
    
    function unitPrices(address token) external view returns (uint256);

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    
    
    function stageUnitPrice(address token, uint256 value) external;

    
    
    function rollbackUnitPrice(address token) external;

    
    
    function commitUnitPrice(address token) external;
}

// 
pragma solidity =0.8.9;



interface IPeripheryImmutableState {
    
    function factory() external view returns (address);

    
    function WETH9() external view returns (address);
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
pragma solidity =0.8.9;



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

    
    
    function protocolPerformanceFees() external view returns (uint128 token0, uint128 token1);

    
    
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
pragma solidity 0.8.9;




interface IAggregateVault is IVault, IVaultRoot {}

// 
pragma solidity 0.8.9;




interface IIntegrationVault is IVault, IERC1271 {
    
    /// the contract balance and convert it to yUSDC.
    
    ///
    /// Also notice that this operation doesn't guarantee that tokenAmounts will be invested in full.
    
    
    
    
    function push(
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) external returns (uint256[] memory actualTokenAmounts);

    
    /// After the `push` it returns all the leftover tokens back (`push` method doesn't guarantee that tokenAmounts will be invested in full).
    
    
    
    
    function transferAndPush(
        address from,
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) external returns (uint256[] memory actualTokenAmounts);

    
    
    /// Strategy is approved address for the vault NFT.
    /// When called by vault owner this method just pulls the tokens from the protocol to the `to` address
    /// When called by strategy on vault other than zero vault it pulls the tokens to zero vault (required `to` == zero vault)
    /// When called by strategy on zero vault it pulls the tokens to zero vault, pushes tokens on the `to` vault, and reclaims everything that's left.
    /// Thus any vault other than zero vault cannot have any tokens on it
    ///
    /// Tokens **must** be a subset of Vault Tokens. However, the convention is that if tokenAmount == 0 it is the same as token is missing.
    ///
    /// Pull is fulfilled on the best effort basis, i.e. if the tokenAmounts overflows available funds it withdraws all the funds.
    
    
    
    
    
    function pull(
        address to,
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) external returns (uint256[] memory actualTokenAmounts);

    
    
    
    
    function reclaimTokens(address[] memory tokens) external returns (uint256[] memory actualTokenAmounts);

    
    
    /// Strategy is approved address for the vault NFT.
    ///
    /// Since this method allows sending arbitrary transactions, the destinations of the calls
    /// are whitelisted by Protocol Governance.
    
    
    
    
    function externalCall(
        address to,
        bytes4 selector,
        bytes memory data
    ) external payable returns (bytes memory result);
}

// 
pragma solidity 0.8.9;





interface IVaultGovernance {
    
    
    
    struct InternalParams {
        IProtocolGovernance protocolGovernance;
        IVaultRegistry registry;
        IVault singleton;
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    function delayedStrategyParamsTimestamp(uint256 nft) external view returns (uint256);

    
    function delayedProtocolParamsTimestamp() external view returns (uint256);

    
    
    function delayedProtocolPerVaultParamsTimestamp(uint256 nft) external view returns (uint256);

    
    function internalParamsTimestamp() external view returns (uint256);

    
    function internalParams() external view returns (InternalParams memory);

    
    
    function stagedInternalParams() external view returns (InternalParams memory);

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    
    function stageInternalParams(InternalParams memory newParams) external;

    
    function commitInternalParams() external;
}

// 
pragma solidity 0.8.9;




interface IProtocolGovernance is IDefaultAccessControl, IUnitPricesGovernance {
    
    
    
    
    
    
    struct Params {
        uint256 maxTokensPerVault;
        uint256 governanceDelay;
        address protocolTreasury;
        uint256 forceAllowMask;
        uint256 withdrawLimit;
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    
    function stagedPermissionGrantsTimestamps(address target) external view returns (uint256);

    
    
    
    function stagedPermissionGrantsMasks(address target) external view returns (uint256);

    
    
    
    function permissionMasks(address target) external view returns (uint256);

    
    
    function stagedParamsTimestamp() external view returns (uint256);

    
    function stagedParams() external view returns (Params memory);

    
    function params() external view returns (Params memory);

    
    function permissionAddresses() external view returns (address[] memory);

    
    function stagedPermissionGrantsAddresses() external view returns (address[] memory);

    
    
    
    function addressesByPermission(uint8 permissionId) external view returns (address[] memory);

    
    
    
    function hasPermission(address addr, uint8 permissionId) external view returns (bool);

    
    
    
    function hasAllPermissions(address target, uint8[] calldata permissionIds) external view returns (bool);

    
    function maxTokensPerVault() external view returns (uint256);

    
    function governanceDelay() external view returns (uint256);

    
    function protocolTreasury() external view returns (address);

    
    /// This bitmask is xored with ordinary mask.
    function forceAllowMask() external view returns (uint256);

    
    
    
    function withdrawLimit(address token) external view returns (uint256);

    
    function stagedValidatorsAddresses() external view returns (address[] memory);

    
    
    
    function stagedValidatorsTimestamps(address target) external view returns (uint256);

    
    
    
    function stagedValidators(address target) external view returns (address);

    
    function validatorsAddresses() external view returns (address[] memory);

    
    
    
    function validatorsAddress(uint256 i) external view returns (address);

    
    
    
    function validators(address target) external view returns (address);

    // -------------------  EXTERNAL, MUTATING, GOVERNANCE, IMMEDIATE  -------------------

    
    function rollbackStagedValidators() external;

    
    
    function revokeValidator(address target) external;

    
    
    
    function stageValidator(address target, address validator) external;

    
    
    
    function commitValidator(address target) external;

    
    
    function commitAllValidatorsSurpassedDelay() external returns (address[] memory);

    
    function rollbackStagedPermissionGrants() external;

    
    
    
    function commitPermissionGrants(address target) external;

    
    
    function commitAllPermissionGrantsSurpassedDelay() external returns (address[] memory);

    
    
    
    function revokePermissions(address target, uint8[] memory permissionIds) external;

    
    /// Reverts if governance delay has not passed yet.
    function commitParams() external;

    // -------------------  EXTERNAL, MUTATING, GOVERNANCE, DELAY  -------------------

    
    
    function stageParams(Params memory newParams) external;

    
    /// Resets commit delay and permissions if there are already staged permissions for this address.
    
    
    function stagePermissionGrants(address target, uint8[] memory permissionIds) external;
}

// 
pragma solidity =0.8.9;




interface IVaultRegistry is IERC721 {
    
    
    
    function vaultForNft(uint256 nftId) external view returns (address vault);

    
    
    
    function nftForVault(address vault) external view returns (uint256 nftId);

    
    
    
    function isLocked(uint256 nft) external view returns (bool);

    
    
    
    
    function registerVault(address vault, address owner) external returns (uint256 nft);

    
    function vaultsCount() external view returns (uint256);

    
    function vaults() external view returns (address[] memory);

    
    function protocolGovernance() external view returns (IProtocolGovernance);

    
    function stagedProtocolGovernance() external view returns (IProtocolGovernance);

    
    function stagedProtocolGovernanceTimestamp() external view returns (uint256);

    
    
    function stageProtocolGovernance(IProtocolGovernance newProtocolGovernance) external;

    
    function commitStagedProtocolGovernance() external;

    
    
    
    function lockNft(uint256 nft) external;
}

// 
pragma solidity 0.8.9;







/// and authorized.
interface INonfungiblePositionManager is IPeripheryImmutableState, IERC721 {
    
    
    
    
    
    
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
pragma solidity =0.8.9;



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
    IUniswapV3PoolActions
{

}

// 
pragma solidity 0.8.9;

interface IOracle {
    
    
    
    
    /// The safety indexes are:
    ///
    /// 1 - unsafe, this is typically a spot price that can be easily manipulated,
    ///
    /// 2 - 4 - more or less safe, this is typically a uniV3 oracle, where the safety is defined by the timespan of the average price
    ///
    /// 5 - safe - this is typically a chailink oracle
    
    
    
    
    
    function priceX96(
        address token0,
        address token1,
        uint256 safetyIndicesSet
    ) external view returns (uint256[] memory pricesX96, uint256[] memory safetyIndices);
}

// 
pragma solidity 0.8.9;



interface IERC20RootVaultHelper {
    function getTvlToken0(
        uint256[] calldata tvls,
        address[] calldata tokens,
        IOracle oracle
    ) external view returns (uint256 tvl0);
}

// 
pragma solidity 0.8.9;





interface IERC20RootVault is IAggregateVault, IERC20 {
    
    
    
    
    
    
    function initialize(
        uint256 nft_,
        address[] memory vaultTokens_,
        address strategy_,
        uint256[] memory subvaultNfts_,
        IERC20RootVaultHelper helper_
    ) external;

    
    function lastFeeCharge() external view returns (uint64);

    
    function totalWithdrawnAmountsTimestamp() external view returns (uint64);

    
    
    function totalWithdrawnAmounts(uint256 _index) external view returns (uint256);

    
    function lpPriceHighWaterMarkD18() external view returns (uint256);

    
    function depositorsAllowlist() external view returns (address[] memory);

    
    
    
    function addDepositorsToAllowlist(address[] calldata depositors) external;

    
    
    
    function removeDepositorsFromAllowlist(address[] calldata depositors) external;

    
    
    
    
    
    function deposit(
        uint256[] memory tokenAmounts,
        uint256 minLpTokens,
        bytes memory vaultOptions
    ) external returns (uint256[] memory actualTokenAmounts);

    
    
    
    
    
    
    function withdraw(
        address to,
        uint256 lpTokenAmount,
        uint256[] memory minTokenAmounts,
        bytes[] memory vaultsOptions
    ) external returns (uint256[] memory actualTokenAmounts);
}

// 
pragma solidity 0.8.9;





interface IERC20RootVaultGovernance is IVaultGovernance {
    
    
    
    
    
    
    
    
    struct DelayedStrategyParams {
        address strategyTreasury;
        address strategyPerformanceTreasury;
        bool privateVault;
        uint256 managementFee;
        uint256 performanceFee;
        address depositCallbackAddress;
        address withdrawCallbackAddress;
    }

    
    
    
    struct DelayedProtocolParams {
        uint256 managementFeeChargeDelay;
        IOracle oracle;
    }

    
    
    
    struct StrategyParams {
        uint256 tokenLimitPerAddress;
        uint256 tokenLimit;
    }

    
    
    struct DelayedProtocolPerVaultParams {
        uint256 protocolFee;
    }

    
    
    struct OperatorParams {
        bool disableDeposit;
    }

    
    function MAX_PROTOCOL_FEE() external view returns (uint256);

    
    function MAX_MANAGEMENT_FEE() external view returns (uint256);

    
    function MAX_PERFORMANCE_FEE() external view returns (uint256);

    
    function delayedProtocolParams() external view returns (DelayedProtocolParams memory);

    
    function stagedDelayedProtocolParams() external view returns (DelayedProtocolParams memory);

    
    
    function delayedProtocolPerVaultParams(uint256 nft) external view returns (DelayedProtocolPerVaultParams memory);

    
    
    function stagedDelayedProtocolPerVaultParams(uint256 nft)
        external
        view
        returns (DelayedProtocolPerVaultParams memory);

    
    
    function strategyParams(uint256 nft) external view returns (StrategyParams memory);

    
    function operatorParams() external view returns (OperatorParams memory);

    
    
    function delayedStrategyParams(uint256 nft) external view returns (DelayedStrategyParams memory);

    
    
    function stagedDelayedStrategyParams(uint256 nft) external view returns (DelayedStrategyParams memory);

    
    
    
    function setStrategyParams(uint256 nft, StrategyParams calldata params) external;

    
    
    function setOperatorParams(OperatorParams calldata params) external;

    
    
    
    function stageDelayedProtocolPerVaultParams(uint256 nft, DelayedProtocolPerVaultParams calldata params) external;

    
    
    
    function commitDelayedProtocolPerVaultParams(uint256 nft) external;

    
    
    
    function stageDelayedStrategyParams(uint256 nft, DelayedStrategyParams calldata params) external;

    
    
    
    function commitDelayedStrategyParams(uint256 nft) external;

    
    
    
    function stageDelayedProtocolParams(DelayedProtocolParams calldata params) external;

    
    function commitDelayedProtocolParams() external;

    
    
    
    
    
    function createVault(
        address[] memory vaultTokens_,
        address strategy_,
        uint256[] memory subvaultNfts_,
        address owner_
    ) external returns (IERC20RootVault vault, uint256 nft);
}

// 
pragma solidity 0.8.9;





interface IGearboxRootVault is IAggregateVault, IERC20 {
    
    
    
    
    
    
    function initialize(
        uint256 nft_,
        address[] memory vaultTokens_,
        address strategy_,
        uint256[] memory subvaultNfts_,
        address
    ) external;

    
    function lastFeeCharge() external view returns (uint64);

    
    function gearboxVault() external view returns (IIntegrationVault);

    
    function erc20Vault() external view returns (IIntegrationVault);

    
    function primaryToken() external view returns (address);

    
    function isClosed() external view returns (bool);

    
    function lpPriceHighWaterMarkD18() external view returns (uint256);

    
    function depositorsAllowlist() external view returns (address[] memory);

    
    
    
    function addDepositorsToAllowlist(address[] calldata depositors) external;

    
    
    
    function removeDepositorsFromAllowlist(address[] calldata depositors) external;

    
    
    
    
    
    function deposit(
        uint256[] memory tokenAmounts,
        uint256 minLpTokens,
        bytes memory vaultOptions
    ) external returns (uint256[] memory actualTokenAmounts);

    
    function currentEpoch() external view returns (uint256);

    
    function totalCurrentEpochLpWitdrawalRequests() external view returns (uint256);

    
    function totalLpTokensWaitingWithdrawal() external view returns (uint256);

    
    function lastEpochChangeTimestamp() external view returns (uint256);

    
    
    function primaryTokensToClaim(address addr) external view returns (uint256);

    
    
    function lpTokensWaitingForClaim(address addr) external view returns (uint256);

    
    
    function withdrawalRequests(address addr) external view returns (uint256);

    
    
    function latestRequestEpoch(address addr) external view returns (uint256);

    
    
    function epochToPriceForLpTokenD18(uint256 epoch) external view returns (uint256);

    
    
    
    
    function withdraw(
        address to,
        bytes[] memory vaultsOptions
    ) external returns (uint256[] memory actualTokenAmounts);

    
    
    
    function registerWithdrawal(uint256 lpTokenAmount) external returns (uint256 amountRegistered);

    
    
    
    function cancelWithdrawal(uint256 lpTokenAmount) external returns (uint256 amountRemained);

    
    function invokeExecution() external;

    
    function shutdown() external;

    
    function reopen() external;
}

// 
pragma solidity 0.8.9;






interface IUniV3Vault is IERC721Receiver, IIntegrationVault {
    struct Options {
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    
    function positionManager() external view returns (INonfungiblePositionManager);

    
    function pool() external view returns (IUniswapV3Pool);

    
    function uniV3Nft() external view returns (uint256);

    
    
    
    function liquidityToTokenAmounts(uint128 liquidity) external view returns (uint256[] memory tokenAmounts);

    
    
    
    function tokenAmountsToLiquidity(uint256[] memory tokenAmounts) external view returns (uint128 liquidity);

    
    
    
    
    
    
    function initialize(
        uint256 nft_,
        address[] memory vaultTokens_,
        uint24 fee_,
        address uniV3Helper_
    ) external;

    
    function collectEarnings() external returns (uint256[] memory collectedEarnings);
}

// 
pragma solidity 0.8.9;




library CommonLibrary {
    uint256 constant DENOMINATOR = 10**9;
    uint256 constant D18 = 10**18;
    uint256 constant YEAR = 365 * 24 * 3600;
    uint256 constant Q128 = 2**128;
    uint256 constant Q96 = 2**96;
    uint256 constant Q48 = 2**48;
    uint256 constant Q160 = 2**160;
    uint256 constant UNI_FEE_DENOMINATOR = 10**6;

    
    
    function sortUint(uint256[] memory arr) internal pure {
        uint256 l = arr.length;
        for (uint256 i = 0; i < l; ++i) {
            for (uint256 j = i + 1; j < l; ++j) {
                if (arr[i] > arr[j]) {
                    uint256 temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
    }

    
    
    
    function isSortedAndUnique(address[] memory tokens) internal pure returns (bool) {
        if (tokens.length < 2) {
            return true;
        }
        for (uint256 i = 0; i < tokens.length - 1; ++i) {
            if (tokens[i] >= tokens[i + 1]) {
                return false;
            }
        }
        return true;
    }

    
    
    /// Requires both sets of tokens to be sorted. When tokens are not sorted, it's undefined behavior.
    /// If there is a token in tokensToProject that is not part of tokens and corresponding tokenAmountsToProject > 0, reverts.
    /// Zero token amount is eqiuvalent to missing token
    function projectTokenAmounts(
        address[] memory tokens,
        address[] memory tokensToProject,
        uint256[] memory tokenAmountsToProject
    ) internal pure returns (uint256[] memory) {
        uint256[] memory res = new uint256[](tokens.length);
        uint256 t = 0;
        uint256 tp = 0;
        while ((t < tokens.length) && (tp < tokensToProject.length)) {
            if (tokens[t] < tokensToProject[tp]) {
                res[t] = 0;
                t++;
            } else if (tokens[t] > tokensToProject[tp]) {
                if (tokenAmountsToProject[tp] == 0) {
                    tp++;
                } else {
                    revert("TPS");
                }
            } else {
                res[t] = tokenAmountsToProject[tp];
                t++;
                tp++;
            }
        }
        while (t < tokens.length) {
            res[t] = 0;
            t++;
        }
        return res;
    }

    
    
    
    function sqrtX96(uint256 xX96) internal pure returns (uint256) {
        uint256 sqX96 = sqrt(xX96);
        return sqX96 << 48;
    }

    
    
    
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x4) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }

    
    
    
    
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    
    
    
    
    
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, ExceptionsLibrary.INVALID_LENGTH);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}

// 
pragma solidity 0.8.9;


library ExceptionsLibrary {
    string constant ADDRESS_ZERO = "AZ";
    string constant VALUE_ZERO = "VZ";
    string constant EMPTY_LIST = "EMPL";
    string constant NOT_FOUND = "NF";
    string constant INIT = "INIT";
    string constant DUPLICATE = "DUP";
    string constant NULL = "NULL";
    string constant TIMESTAMP = "TS";
    string constant FORBIDDEN = "FRB";
    string constant ALLOWLIST = "ALL";
    string constant LIMIT_OVERFLOW = "LIMO";
    string constant LIMIT_UNDERFLOW = "LIMU";
    string constant INVALID_VALUE = "INV";
    string constant INVARIANT = "INVA";
    string constant INVALID_TARGET = "INVTR";
    string constant INVALID_TOKEN = "INVTO";
    string constant INVALID_INTERFACE = "INVI";
    string constant INVALID_SELECTOR = "INVS";
    string constant INVALID_STATE = "INVST";
    string constant INVALID_LENGTH = "INVL";
    string constant LOCK = "LCKD";
    string constant DISABLED = "DIS";
}

// 
pragma solidity >=0.4.0;



library FixedPoint128 {
    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
}

// 
pragma solidity =0.8.9;




library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}

// 
pragma solidity =0.8.9;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // diff: original lib works under 0.7.6 with overflows enabled
        unchecked {
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
            // diff: original uint256 twos = -denominator & denominator;
            uint256 twos = uint256(-int256(denominator)) & denominator;
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
    }

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // diff: original lib works under 0.7.6 with overflows enabled
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}

// 
pragma solidity =0.8.9;






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
        uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
        return toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    
    
    
    
    
    
    function getLiquidityForAmount1(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return toUint128(FullMath.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
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
            FullMath.mulDiv(
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

        return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
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
pragma solidity 0.8.9;





library OracleLibrary {
    
    
    
    
    
    
    function consult(address pool, uint32 secondsAgo)
        internal
        view
        returns (
            int24 arithmeticMeanTick,
            uint128 harmonicMeanLiquidity,
            bool withFail
        )
    {
        require(secondsAgo != 0, "BP");

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        try IUniswapV3Pool(pool).observe(secondsAgos) returns (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        ) {
            int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
            uint160 secondsPerLiquidityCumulativesDelta = secondsPerLiquidityCumulativeX128s[1] -
                secondsPerLiquidityCumulativeX128s[0];

            arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(secondsAgo)));
            // Always round to negative infinity
            if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int56(uint56(secondsAgo)) != 0))
                arithmeticMeanTick--;

            // We are multiplying here instead of shifting to ensure that harmonicMeanLiquidity doesn't overflow uint128
            uint192 secondsAgoX160 = uint192(secondsAgo) * type(uint160).max;
            harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32));
        } catch {
            return (0, 0, true);
        }
    }
}

// 
pragma solidity >=0.5.0;


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
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}

// 
pragma solidity >=0.6.8 <0.9.0;










library PositionValue {
    
    /// that a given nonfungible position manager token is worth
    
    
    
    
    
    function total(
        INonfungiblePositionManager positionManager,
        uint256 tokenId,
        uint160 sqrtRatioX96
    ) internal view returns (uint256 amount0, uint256 amount1) {
        (uint256 amount0Principal, uint256 amount1Principal) = principal(positionManager, tokenId, sqrtRatioX96);
        (uint256 amount0Fee, uint256 amount1Fee) = fees(positionManager, tokenId);
        return (amount0Principal + amount0Fee, amount1Principal + amount1Fee);
    }

    
    /// that the position is burned
    
    
    
    
    
    function principal(
        INonfungiblePositionManager positionManager,
        uint256 tokenId,
        uint160 sqrtRatioX96
    ) internal view returns (uint256 amount0, uint256 amount1) {
        (, , , , , int24 tickLower, int24 tickUpper, uint128 liquidity, , , , ) = positionManager.positions(tokenId);

        return
            LiquidityAmounts.getAmountsForLiquidity(
                sqrtRatioX96,
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                liquidity
            );
    }

    struct FeeParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 positionFeeGrowthInside0LastX128;
        uint256 positionFeeGrowthInside1LastX128;
        uint256 tokensOwed0;
        uint256 tokensOwed1;
    }

    
    
    
    
    
    function fees(INonfungiblePositionManager positionManager, uint256 tokenId)
        internal
        view
        returns (uint256 amount0, uint256 amount1)
    {
        (
            ,
            ,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 positionFeeGrowthInside0LastX128,
            uint256 positionFeeGrowthInside1LastX128,
            uint256 tokensOwed0,
            uint256 tokensOwed1
        ) = positionManager.positions(tokenId);

        return
            _fees(
                positionManager,
                FeeParams({
                    token0: token0,
                    token1: token1,
                    fee: fee,
                    tickLower: tickLower,
                    tickUpper: tickUpper,
                    liquidity: liquidity,
                    positionFeeGrowthInside0LastX128: positionFeeGrowthInside0LastX128,
                    positionFeeGrowthInside1LastX128: positionFeeGrowthInside1LastX128,
                    tokensOwed0: tokensOwed0,
                    tokensOwed1: tokensOwed1
                })
            );
    }

    function _fees(INonfungiblePositionManager positionManager, FeeParams memory feeParams)
        private
        view
        returns (uint256 amount0, uint256 amount1)
    {
        (uint256 poolFeeGrowthInside0LastX128, uint256 poolFeeGrowthInside1LastX128) = _getFeeGrowthInside(
            IUniswapV3Pool(
                PoolAddress.computeAddress(
                    positionManager.factory(),
                    PoolAddress.PoolKey({token0: feeParams.token0, token1: feeParams.token1, fee: feeParams.fee})
                )
            ),
            feeParams.tickLower,
            feeParams.tickUpper
        );

        unchecked {
            amount0 =
                FullMath.mulDiv(
                    poolFeeGrowthInside0LastX128 - feeParams.positionFeeGrowthInside0LastX128,
                    feeParams.liquidity,
                    FixedPoint128.Q128
                ) +
                feeParams.tokensOwed0;

            amount1 =
                FullMath.mulDiv(
                    poolFeeGrowthInside1LastX128 - feeParams.positionFeeGrowthInside1LastX128,
                    feeParams.liquidity,
                    FixedPoint128.Q128
                ) +
                feeParams.tokensOwed1;
        }
    }

    function _getFeeGrowthInside(
        IUniswapV3Pool pool,
        int24 tickLower,
        int24 tickUpper
    ) private view returns (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) {
        unchecked {
            (, int24 tickCurrent, , , , , ) = pool.slot0();
            (, , uint256 lowerFeeGrowthOutside0X128, uint256 lowerFeeGrowthOutside1X128, , , , ) = pool.ticks(
                tickLower
            );
            (, , uint256 upperFeeGrowthOutside0X128, uint256 upperFeeGrowthOutside1X128, , , , ) = pool.ticks(
                tickUpper
            );

            if (tickCurrent < tickLower) {
                feeGrowthInside0X128 = lowerFeeGrowthOutside0X128 - upperFeeGrowthOutside0X128;
                feeGrowthInside1X128 = lowerFeeGrowthOutside1X128 - upperFeeGrowthOutside1X128;
            } else if (tickCurrent < tickUpper) {
                uint256 feeGrowthGlobal0X128 = pool.feeGrowthGlobal0X128();
                uint256 feeGrowthGlobal1X128 = pool.feeGrowthGlobal1X128();
                feeGrowthInside0X128 = feeGrowthGlobal0X128 - lowerFeeGrowthOutside0X128 - upperFeeGrowthOutside0X128;
                feeGrowthInside1X128 = feeGrowthGlobal1X128 - lowerFeeGrowthOutside1X128 - upperFeeGrowthOutside1X128;
            } else {
                feeGrowthInside0X128 = upperFeeGrowthOutside0X128 - lowerFeeGrowthOutside0X128;
                feeGrowthInside1X128 = upperFeeGrowthOutside1X128 - lowerFeeGrowthOutside1X128;
            }
        }
    }
}

// 
pragma solidity =0.8.9;



/// prices between 2**-128 and 2**128
library TickMath {
    
    int24 internal constant MIN_TICK = -887272;
    
    int24 internal constant MAX_TICK = -MIN_TICK;

    
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    
    
    
    
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        // diff: original require(absTick <= uint256(MAX_TICK), "T");
        require(absTick <= uint256(int256(MAX_TICK)), "T");

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
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, "R");
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
pragma solidity =0.8.9;













contract DataCollector {
    INonfungiblePositionManager public immutable positionManager;
    IVaultRegistry public immutable vaultRegistry;
    IUniswapV3Factory public immutable factory;
    address public immutable usdc;
    UniV3Helper public immutable uniV3Helper;
    uint256 public constant Q96 = 2**96;

    struct VaultRequest {
        uint256[] erc20VaultNfts;
        uint256[] moneyVaultNfts;
        uint256[] uniV3VaultNfts;
        uint24 fee;
        uint256 rootVaultNft;
        address user;
        uint256 domainPositionNft;
        bool isGearboxStrategy;
    }

    struct VaultResponse {
        uint256[] pricesToUsdcX96;
        uint256 tokenLpLimitPerUser;
        uint256 tokenLpLimit;
        uint256 userLpBalance;
        uint256 totalSupply;
        uint256[][] erc20VaultTvls;
        uint256[][] moneyVaultTvls;
        uint256[][] uniV3VaultTvls;
        uint256[][] uniV3VaultSpotTvls;
        uint256[] rootVaultTvl;
        uint256[] rootVaultSpotTvl;
        uint256[] domainPositionSpotTvl;
    }

    constructor(
        address usdc_,
        INonfungiblePositionManager positionManager_,
        IVaultRegistry vaultRegistry_,
        UniV3Helper uniV3Helper_
    ) {
        require(
            usdc_ != address(0) &&
                address(positionManager_) != address(0) &&
                address(vaultRegistry_) != address(0) &&
                address(uniV3Helper_) != address(0)
        );
        usdc = usdc_;
        positionManager = positionManager_;
        vaultRegistry = vaultRegistry_;
        uniV3Helper = uniV3Helper_;
        factory = IUniswapV3Factory(positionManager_.factory());
    }

    function collect(VaultRequest[] memory requests) external view returns (VaultResponse[] memory responses) {
        uint256 n = requests.length;
        responses = new VaultResponse[](n);
        for (uint256 requestIndex = 0; requestIndex < n; ++requestIndex) {
            VaultRequest memory request = requests[requestIndex];
            VaultResponse memory response;
            address[] memory vaultTokens;
            {
                response.erc20VaultTvls = new uint256[][](request.erc20VaultNfts.length);
                for (uint256 i = 0; i < request.erc20VaultNfts.length; ++i) {
                    (response.erc20VaultTvls[i], ) = IVault(vaultRegistry.vaultForNft(request.erc20VaultNfts[i])).tvl();
                }
            }

            {
                response.moneyVaultTvls = new uint256[][](request.moneyVaultNfts.length);
                for (uint256 i = 0; i < request.moneyVaultNfts.length; ++i) {
                    (response.moneyVaultTvls[i], ) = IVault(vaultRegistry.vaultForNft(request.moneyVaultNfts[i])).tvl();
                }
            }

            IERC20RootVault rootVault = IERC20RootVault(vaultRegistry.vaultForNft(request.rootVaultNft));
            IERC20RootVaultGovernance rootVaultGovernance = IERC20RootVaultGovernance(
                address(rootVault.vaultGovernance())
            );
            {
                (response.rootVaultTvl, ) = rootVault.tvl();
                response.rootVaultSpotTvl = response.rootVaultTvl;
                response.totalSupply = rootVault.totalSupply();
                if (request.isGearboxStrategy) {
                    require(response.erc20VaultTvls.length == 1, "Invalid length");
                    response.totalSupply -= IGearboxRootVault(address(rootVault)).totalLpTokensWaitingWithdrawal();
                    response.rootVaultTvl[0] -= response.erc20VaultTvls[0][0];
                    response.rootVaultTvl[1] -= response.erc20VaultTvls[0][1];
                }
                response.userLpBalance = rootVault.balanceOf(request.user);
                vaultTokens = rootVault.vaultTokens();
            }

            {
                response.uniV3VaultTvls = new uint256[][](request.uniV3VaultNfts.length);
                response.uniV3VaultSpotTvls = new uint256[][](request.uniV3VaultNfts.length);
                for (uint256 i = 0; i < request.uniV3VaultNfts.length; ++i) {
                    IUniV3Vault uniV3Vault = IUniV3Vault(vaultRegistry.vaultForNft(request.uniV3VaultNfts[i]));
                    (response.uniV3VaultTvls[i], ) = uniV3Vault.tvl();
                    if (response.uniV3VaultTvls[i][0] > 0 || response.uniV3VaultTvls[i][1] > 0) {
                        uint256 uniV3Nft = uniV3Vault.uniV3Nft();
                        (uint256 fees0, uint256 fees1) = uniV3Helper.getFeesByNft(uniV3Nft);
                        (, , , , , , , uint128 liquidity, , , , ) = positionManager.positions(uniV3Nft);
                        response.uniV3VaultSpotTvls[i] = uniV3Vault.liquidityToTokenAmounts(liquidity);
                        response.uniV3VaultSpotTvls[i][0] += fees0;
                        response.uniV3VaultSpotTvls[i][1] += fees1;
                    } else {
                        response.uniV3VaultSpotTvls[i] = new uint256[](2);
                    }
                    response.rootVaultSpotTvl[0] -= response.uniV3VaultTvls[i][0];
                    response.rootVaultSpotTvl[1] -= response.uniV3VaultTvls[i][1];
                    response.rootVaultSpotTvl[0] += response.uniV3VaultSpotTvls[i][0];
                    response.rootVaultSpotTvl[1] += response.uniV3VaultSpotTvls[i][1];
                }
            }

            IERC20RootVaultGovernance.StrategyParams memory limits = rootVaultGovernance.strategyParams(
                request.rootVaultNft
            );

            response.tokenLpLimit = limits.tokenLimit;
            response.tokenLpLimitPerUser = limits.tokenLimitPerAddress;
            {
                response.pricesToUsdcX96 = new uint256[](vaultTokens.length);
                for (uint256 i = 0; i < vaultTokens.length; i++) {
                    address token = vaultTokens[i];
                    if (token == usdc) {
                        response.pricesToUsdcX96[i] = Q96;
                    } else {
                        IUniswapV3Pool pool = IUniswapV3Pool(factory.getPool(usdc, token, request.fee));
                        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
                        uint256 priceX96 = FullMath.mulDiv(sqrtPriceX96, sqrtPriceX96, Q96);
                        if (pool.token0() == usdc) {
                            priceX96 = FullMath.mulDiv(Q96, Q96, priceX96);
                        }
                        response.pricesToUsdcX96[i] = priceX96;
                    }
                }
            }

            if (request.domainPositionNft != 0) {
                IUniswapV3Pool pool = IUniswapV3Pool(factory.getPool(vaultTokens[0], vaultTokens[1], request.fee));
                (uint256 fees0, uint256 fees1) = uniV3Helper.getFeesByNft(request.domainPositionNft);
                (, , , , , , , uint128 liquidity, , , , ) = positionManager.positions(request.domainPositionNft);
                response.domainPositionSpotTvl = uniV3Helper.liquidityToTokenAmounts(
                    liquidity,
                    pool,
                    request.domainPositionNft
                );
                response.domainPositionSpotTvl[0] += fees0;
                response.domainPositionSpotTvl[1] += fees1;
            }

            responses[requestIndex] = response;
        }
    }
}

// 
pragma solidity 0.8.9;







contract UniV3Helper {
    INonfungiblePositionManager public immutable positionManager;

    constructor(INonfungiblePositionManager positionManager_) {
        require(address(positionManager_) != address(0));
        positionManager = positionManager_;
    }

    function liquidityToTokenAmounts(
        uint128 liquidity,
        IUniswapV3Pool pool,
        uint256 uniV3Nft
    ) external view returns (uint256[] memory tokenAmounts) {
        tokenAmounts = new uint256[](2);
        (, , , , , int24 tickLower, int24 tickUpper, , , , , ) = positionManager.positions(uniV3Nft);

        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint160 sqrtPriceAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtPriceBX96 = TickMath.getSqrtRatioAtTick(tickUpper);
        (tokenAmounts[0], tokenAmounts[1]) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96,
            sqrtPriceAX96,
            sqrtPriceBX96,
            liquidity
        );
    }

    function tokenAmountsToLiquidity(
        uint256[] memory tokenAmounts,
        IUniswapV3Pool pool,
        uint256 uniV3Nft
    ) external view returns (uint128 liquidity) {
        (, , , , , int24 tickLower, int24 tickUpper, , , , , ) = positionManager.positions(uniV3Nft);
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint160 sqrtPriceAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtPriceBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96,
            sqrtPriceAX96,
            sqrtPriceBX96,
            tokenAmounts[0],
            tokenAmounts[1]
        );
    }

    function tokenAmountsToMaximalLiquidity(
        uint160 sqrtRatioX96,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1
    ) external pure returns (uint128 liquidity) {
        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = LiquidityAmounts.getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = LiquidityAmounts.getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = LiquidityAmounts.getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

            liquidity = liquidity0 > liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = LiquidityAmounts.getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
        }
    }

    
    function getPoolByNft(uint256 uniV3Nft) public view returns (IUniswapV3Pool pool) {
        (, , address token0, address token1, uint24 fee, , , , , , , ) = positionManager.positions(uniV3Nft);
        pool = IUniswapV3Pool(IUniswapV3Factory(positionManager.factory()).getPool(token0, token1, fee));
    }

    
    function getFeesByNft(uint256 uniV3Nft) external view returns (uint256 fees0, uint256 fees1) {
        (fees0, fees1) = PositionValue.fees(positionManager, uniV3Nft);
    }

    
    function calculateTvlBySqrtPriceX96(uint256 uniV3Nft, uint160 sqrtPriceX96)
        public
        view
        returns (uint256[] memory tokenAmounts)
    {
        tokenAmounts = new uint256[](2);
        (tokenAmounts[0], tokenAmounts[1]) = PositionValue.total(positionManager, uniV3Nft, sqrtPriceX96);
    }

    
    function calculateTvlByMinMaxPrices(
        uint256 uniV3Nft,
        uint256 minPriceX96,
        uint256 maxPriceX96
    ) external view returns (uint256[] memory minTokenAmounts, uint256[] memory maxTokenAmounts) {
        minTokenAmounts = new uint256[](2);
        maxTokenAmounts = new uint256[](2);
        (uint256 fees0, uint256 fees1) = PositionValue.fees(positionManager, uniV3Nft);

        uint160 minSqrtPriceX96 = uint160(CommonLibrary.sqrtX96(minPriceX96));
        uint160 maxSqrtPriceX96 = uint160(CommonLibrary.sqrtX96(maxPriceX96));
        (uint256 amountMin0, uint256 amountMin1) = PositionValue.principal(positionManager, uniV3Nft, minSqrtPriceX96);
        (uint256 amountMax0, uint256 amountMax1) = PositionValue.principal(positionManager, uniV3Nft, maxSqrtPriceX96);

        if (amountMin0 > amountMax0) (amountMin0, amountMax0) = (amountMax0, amountMin0);
        if (amountMin1 > amountMax1) (amountMin1, amountMax1) = (amountMax1, amountMin1);

        minTokenAmounts[0] = amountMin0 + fees0;
        maxTokenAmounts[0] = amountMax0 + fees0;
        minTokenAmounts[1] = amountMin1 + fees1;
        maxTokenAmounts[1] = amountMax1 + fees1;
    }

    function getTickDeviationForTimeSpan(
        int24 tick,
        address pool_,
        uint32 secondsAgo
    ) external view returns (bool withFail, int24 deviation) {
        int24 averageTick;
        (averageTick, , withFail) = OracleLibrary.consult(pool_, secondsAgo);
        deviation = tick - averageTick;
    }

    
    function getPositionTokenAmountsByCapitalOfToken0(
        uint256 lowerPriceSqrtX96,
        uint256 upperPriceSqrtX96,
        uint256 spotPriceForSqrtFormulasX96,
        uint256 spotPriceX96,
        uint256 capital
    ) external pure returns (uint256 token0Amount, uint256 token1Amount) {
        // sqrt(upperPrice) * (sqrt(price) - sqrt(lowerPrice))
        uint256 lowerPriceTermX96 = FullMath.mulDiv(
            upperPriceSqrtX96,
            spotPriceForSqrtFormulasX96 - lowerPriceSqrtX96,
            CommonLibrary.Q96
        );
        // sqrt(price) * (sqrt(upperPrice) - sqrt(price))
        uint256 upperPriceTermX96 = FullMath.mulDiv(
            spotPriceForSqrtFormulasX96,
            upperPriceSqrtX96 - spotPriceForSqrtFormulasX96,
            CommonLibrary.Q96
        );

        token1Amount = FullMath.mulDiv(
            FullMath.mulDiv(capital, spotPriceX96, CommonLibrary.Q96),
            lowerPriceTermX96,
            lowerPriceTermX96 + upperPriceTermX96
        );

        token0Amount = capital - FullMath.mulDiv(token1Amount, CommonLibrary.Q96, spotPriceX96);
    }
}