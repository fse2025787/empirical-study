// SPDX-License-Identifier: MIT


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
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * 
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

pragma solidity 0.8.12;









/// of this module
interface ITreasury {
    
    function stablecoin() external view returns (IAgToken);

    
    
    
    
    function isGovernor(address admin) external view returns (bool);

    
    
    
    
    /// queries the `CoreBorrow` contract
    function isGovernorOrGuardian(address admin) external view returns (bool);

    
    /// as a `VaultManager``
    
    
    function isVaultManager(address _vaultManager) external view returns (bool);

    
    
    
    /// it to the new module
    function setFlashLoanModule(address _flashLoanModule) external;
}

// 

pragma solidity 0.8.12;






// ========================= Key Structs and Enums =============================


/// to parameters which signification is detailed in the `VaultManagerStorage` file
struct VaultParameters {
    uint256 debtCeiling;
    uint64 collateralFactor;
    uint64 targetHealthFactor;
    uint64 interestRate;
    uint64 liquidationSurcharge;
    uint64 maxLiquidationDiscount;
    bool whitelistingActivated;
    uint256 baseBoost;
}


struct Vault {
    // Amount of collateral deposited in the vault, in collateral decimals. For example, if the collateral
    // is USDC with 6 decimals, then `collateralAmount` will be in base 10**6
    uint256 collateralAmount;
    // Normalized value of the debt (that is to say of the stablecoins borrowed). It is expressed
    // in the base of Angle stablecoins (i.e. `BASE_TOKENS = 10**18`)
    uint256 normalizedDebt;
}


/// amount that could be repaid by liquidating the position

struct LiquidationOpportunity {
    // Maximum stablecoin amount that can be repaid upon liquidating the vault
    uint256 maxStablecoinAmountToRepay;
    // Collateral amount given to the person in the case where the maximum amount to repay is given
    uint256 maxCollateralAmountGiven;
    // Threshold value of stablecoin amount to repay: it is ok for a liquidator to repay below threshold,
    // but if this threshold is non null and the liquidator wants to repay more than threshold, it should repay
    // the max stablecoin amount given in this vault
    uint256 thresholdRepayAmount;
    // Discount proposed to the liquidator on the collateral
    uint256 discount;
    // Amount of debt in the vault
    uint256 currentDebt;
}


/// essential data for vaults being liquidated
struct LiquidatorData {
    // Current amount of stablecoins the liquidator should give to the contract
    uint256 stablecoinAmountToReceive;
    // Current amount of collateral the contract should give to the liquidator
    uint256 collateralAmountToGive;
    // Bad debt accrued across the liquidation process
    uint256 badDebtFromLiquidation;
    // Oracle value (in stablecoin base) at the time of the liquidation
    uint256 oracleValue;
    // Value of the `interestAccumulator` at the time of the call
    uint256 newInterestAccumulator;
}


/// to the caller or associated addresses
struct PaymentData {
    // Stablecoin amount the contract should give
    uint256 stablecoinAmountToGive;
    // Stablecoin amount owed to the contract
    uint256 stablecoinAmountToReceive;
    // Collateral amount the contract should give
    uint256 collateralAmountToGive;
    // Collateral amount owed to the contract
    uint256 collateralAmountToReceive;
}


enum ActionType {
    createVault,
    closeVault,
    addCollateral,
    removeCollateral,
    repayDebt,
    borrow,
    getDebtIn,
    permit
}

// ========================= Interfaces =============================





/// of this module (without getters)
interface IVaultManagerFunctions {
    
    
    
    
    function accrueInterestToTreasury() external returns (uint256 surplusValue, uint256 badDebtValue);

    
    
    
    /// internal debt amount
    
    /// arbitraging difference in minting fees
    
    /// differences in repay fees
    
    function getDebtOut(
        uint256 vaultID,
        uint256 amountStablecoins,
        uint256 senderBorrowFee,
        uint256 senderRepayFee
    ) external;

    
    
    
    function getVaultDebt(uint256 vaultID) external view returns (uint256);

    
    
    /// over time
    function getTotalDebt() external view returns (uint256);

    
    
    
    /// calling this function
    function setTreasury(address _treasury) external;

    
    
    
    
    function createVault(address toVault) external returns (uint256);

    
    /// this function can perform any of the allowed actions in the order of their choice
    
    
    
    /// should either be the `msg.sender` or be approved by the latter
    
    
    
    
    /// or how much has been received). Note that the values in the struct are not aggregated and you could have in the output
    /// a positive amount of stablecoins to receive as well as a positive amount of stablecoins to give
    
    /// or computations (like `oracleValue`) are done only once
    
    /// use the latest `vaultID`. This is the default behavior, and unless you're engaging into some complex protocol actions
    /// it is encouraged to use `vaultID = 0` only when the first action of the batch is `createVault`
    function angle(
        ActionType[] memory actions,
        bytes[] memory datas,
        address from,
        address to,
        address who,
        bytes memory repayData
    ) external returns (PaymentData memory paymentData);

    
    /// without having to provide `who` and `repayData` parameters
    function angle(
        ActionType[] memory actions,
        bytes[] memory datas,
        address from,
        address to
    ) external returns (PaymentData memory paymentData);

    
    
    
    
    
    
    /// contract has been initialized
    
    /// boost
    function initialize(
        ITreasury _treasury,
        IERC20 _collateral,
        IOracle _oracle,
        VaultParameters calldata params,
        string memory _symbol
    ) external;
}





/// of this module
interface IVaultManagerStorage {
    
    function dust() external view returns (uint256);

    
    /// determines the minimum collateral ratio of a position
    function collateralFactor() external view returns (uint64);

    
    /// the same rights as this `VaultManager` on the stablecoin contract
    function stablecoin() external view returns (IAgToken);

    
    function treasury() external view returns (ITreasury);

    
    function oracle() external view returns (IOracle);

    
    /// The stored value is not necessarily the true value: this one is recomputed every time an action takes place
    /// within the protocol. It is in base `BASE_INTEREST`
    function interestAccumulator() external view returns (uint256);

    
    function collateral() external view returns (IERC20);

    
    /// This value is expressed in the base of Angle stablecoins (`BASE_TOKENS = 10**18`)
    function totalNormalizedDebt() external view returns (uint256);

    
    function debtCeiling() external view returns (uint256);

    
    function vaultData(uint256 vaultID) external view returns (uint256 collateralAmount, uint256 normalizedDebt);

    
    /// `vaultID` for each vault: it is like `tokenID` in basic ERC721 contracts
    function vaultIDCount() external view returns (uint256);
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.0;



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

pragma solidity 0.8.12;







/// of this module or of the first module of the Angle Protocol
interface IAgToken is IERC20Upgradeable {
    // ======================= Minter Role Only Functions ===========================

    
    
    
    
    /// associated to this stablecoin as well as the flash loan module (if activated) and potentially contracts
    /// whitelisted by governance
    function mint(address account, uint256 amount) external;

    
    
    
    
    
    /// to do so by a `sender` address willing to burn tokens from another `burner` address
    
    function burnFrom(
        uint256 amount,
        address burner,
        address sender
    ) external;

    
    
    
    
    /// requested to do so by an address willing to burn tokens from its address
    function burnSelf(uint256 amount, address burner) external;

    // ========================= Treasury Only Functions ===========================

    
    
    
    function addMinter(address minter) external;

    
    
    
    function removeMinter(address minter) external;

    
    
    function setTreasury(address _treasury) external;

    // ========================= External functions ================================

    
    
    
    function isMinter(address minter) external view returns (bool);
}

// 

pragma solidity 0.8.12;





/// of this module
interface ICoreBorrow {
    
    /// module initialized on it
    
    
    function isFlashLoanerTreasury(address treasury) external view returns (bool);

    
    
    
    function isGovernor(address admin) external view returns (bool);

    
    
    
    
    /// role by calling the `addGovernor` function
    function isGovernorOrGuardian(address admin) external view returns (bool);
}

// 

pragma solidity 0.8.12;








/// of this module
interface IFlashAngle {
    
    function core() external view returns (ICoreBorrow);

    
    
    
    
    function accrueInterestToTreasury(IAgToken stablecoin) external returns (uint256 balance);

    
    
    
    function addStablecoinSupport(address _treasury) external;

    
    
    
    function removeStablecoinSupport(address _treasury) external;

    
    
    
    function setCore(address _core) external;
}

// 

pragma solidity 0.8.12;







/// of this module
interface IOracle {
    
    
    /// of the out currency
    
    /// value is 10**18
    function read() external view returns (uint256);

    
    
    
    /// this function after being requested to do so by a `treasury` contract
    
    /// to the `oracle` contract and as such we may need governors to be able to call this function as well
    function setTreasury(address _treasury) external;

    
    function treasury() external view returns (ITreasury treasury);
}




interface IVaultManager is IVaultManagerFunctions, IVaultManagerStorage, IERC721Metadata {

}

// 

pragma solidity 0.8.12;














/// a given stablecoin
contract Treasury is ITreasury, Initializable {
    using SafeERC20 for IERC20;

    
    uint256 public constant BASE_PARAMS = 10**9;

    // =============================== References ==================================

    
    ICoreBorrow public core;
    
    IFlashAngle public flashLoanModule;
    
    IAgToken public stablecoin;
    
    address public surplusManager;
    
    address[] public vaultManagerList;
    
    mapping(address => uint256) public vaultManagerMap;

    // =============================== Variables ===================================

    
    /// linked to this stablecoin
    uint256 public badDebt;
    
    /// only a share of this `surplusBuffer` will go to governance. Once a share of the surplus buffer has been
    /// given to governance, then this surplus is reset
    uint256 public surplusBuffer;

    // =============================== Parameter ===================================

    
    uint64 public surplusForGovernance;

    // =============================== Events ======================================

    event BadDebtUpdated(uint256 badDebtValue);
    event CoreUpdated(address indexed _core);
    event NewTreasurySet(address indexed _treasury);
    event Recovered(address indexed token, address indexed to, uint256 amount);
    event SurplusBufferUpdated(uint256 surplusBufferValue);
    event SurplusForGovernanceUpdated(uint64 _surplusForGovernance);
    event SurplusManagerUpdated(address indexed _surplusManager);
    event VaultManagerToggled(address indexed vaultManager);

    // =============================== Errors ======================================

    error AlreadyVaultManager();
    error InvalidAddress();
    error InvalidTreasury();
    error NotCore();
    error NotGovernor();
    error NotVaultManager();
    error RightsNotRemoved();
    error TooBigAmount();
    error TooHighParameterValue();
    error ZeroAddress();

    // =============================== Modifier ====================================

    
    modifier onlyGovernor() {
        if (!core.isGovernor(msg.sender)) revert NotGovernor();
        _;
    }

    
    
    
    function initialize(ICoreBorrow _core, IAgToken _stablecoin) public initializer {
        if (address(_stablecoin) == address(0) || address(_core) == address(0)) revert ZeroAddress();
        core = _core;
        stablecoin = _stablecoin;
    }

    
    constructor() initializer {}

    // ========================= View Functions ====================================

    
    function isGovernor(address admin) external view returns (bool) {
        return core.isGovernor(admin);
    }

    
    function isGovernorOrGuardian(address admin) external view returns (bool) {
        return core.isGovernorOrGuardian(admin);
    }

    
    function isVaultManager(address _vaultManager) external view returns (bool) {
        return vaultManagerMap[_vaultManager] == 1;
    }

    // ============= External Permissionless Functions =============================

    
    /// `Treasury` contract as well as from the fees of the `FlashLoan` module
    
    
    
    /// (or the `badDebt` if more losses were made than profits)
    function fetchSurplusFromAll() external returns (uint256, uint256) {
        return _fetchSurplusFromAll();
    }

    
    
    
    
    function fetchSurplusFromFlashLoan() external returns (uint256, uint256) {
        uint256 surplusBufferValue = surplusBuffer + flashLoanModule.accrueInterestToTreasury(stablecoin);
        return _updateSurplusAndBadDebt(surplusBufferValue, badDebt);
    }

    
    
    
    /// the situation where rewards are still distributed to governance even though a `VaultManager` has made
    /// a big loss
    
    /// holders
    
    function pushSurplus() external returns (uint256 governanceAllocation) {
        address _surplusManager = surplusManager;
        if (_surplusManager == address(0)) {
            revert ZeroAddress();
        }
        (uint256 surplusBufferValue, ) = _fetchSurplusFromAll();
        surplusBuffer = 0;
        emit SurplusBufferUpdated(0);
        governanceAllocation = (surplusForGovernance * surplusBufferValue) / BASE_PARAMS;
        stablecoin.transfer(_surplusManager, governanceAllocation);
    }

    
    /// from an external source
    
    
    
    /// a program like Olympus Pro), then this function needs to be called
    
    
    /// the `surplusBuffer` and hence the amount going to governance
    function updateBadDebt(uint256 amount) external returns (uint256 badDebtValue) {
        stablecoin.burnSelf(amount, address(this));
        badDebtValue = badDebt - amount;
        badDebt = badDebtValue;
        emit BadDebtUpdated(badDebtValue);
    }

    // ==================== Internal Utility Functions =============================

    
    function _fetchSurplusFromAll() internal returns (uint256 surplusBufferValue, uint256 badDebtValue) {
        (surplusBufferValue, badDebtValue) = _fetchSurplusFromList(vaultManagerList);
        // It will fail anyway if the `flashLoanModule` is the zero address
        if (address(flashLoanModule) != address(0))
            surplusBufferValue += flashLoanModule.accrueInterestToTreasury(stablecoin);
        (surplusBufferValue, badDebtValue) = _updateSurplusAndBadDebt(surplusBufferValue, badDebtValue);
    }

    
    /// `surplusBuffer` and `badDebtValue`
    
    
    
    /// with the `_updateSurplusAndBadDebt` function
    function _fetchSurplusFromList(address[] memory vaultManagers)
        internal
        returns (uint256 surplusBufferValue, uint256 badDebtValue)
    {
        badDebtValue = badDebt;
        surplusBufferValue = surplusBuffer;
        uint256 newSurplus;
        uint256 newBadDebt;
        for (uint256 i = 0; i < vaultManagers.length; i++) {
            (newSurplus, newBadDebt) = IVaultManager(vaultManagers[i]).accrueInterestToTreasury();
            surplusBufferValue += newSurplus;
            badDebtValue += newBadDebt;
        }
    }

    
    /// and/or a list of `VaultManager` contracts
    
    
    
    
    /// previously
    
    /// this function tries to reconcile both values and makes sure that we either have surplus or bad debt but not both
    /// at the same time
    function _updateSurplusAndBadDebt(uint256 surplusBufferValue, uint256 badDebtValue)
        internal
        returns (uint256, uint256)
    {
        if (badDebtValue > 0) {
            // If we have bad debt we need to burn stablecoins that accrued to the protocol
            // We still need to make sure that we're not burning too much or as much as we can if the debt is big
            uint256 balance = stablecoin.balanceOf(address(this));
            // We are going to burn `min(balance, badDebtValue)`
            uint256 toBurn = balance <= badDebtValue ? balance : badDebtValue;
            stablecoin.burnSelf(toBurn, address(this));
            // If we burned more than `surplusBuffer`, we set surplus to 0. It means we had to tap into Treasury reserve
            surplusBufferValue = toBurn >= surplusBufferValue ? 0 : surplusBufferValue - toBurn;
            badDebtValue -= toBurn;
            // Note here that the stablecoin balance is necessarily greater than the surplus buffer, and so if
            // `surplusBuffer >= toBurn`, then `badDebtValue = toBurn`
        }
        surplusBuffer = surplusBufferValue;
        badDebt = badDebtValue;
        emit SurplusBufferUpdated(surplusBufferValue);
        emit BadDebtUpdated(badDebtValue);
        return (surplusBufferValue, badDebtValue);
    }

    // ============================ Governor Functions =============================

    
    
    function addMinter(address minter) external onlyGovernor {
        if (minter == address(0)) revert ZeroAddress();
        stablecoin.addMinter(minter);
    }

    
    
    
    
    function addVaultManager(address vaultManager) external onlyGovernor {
        if (vaultManagerMap[vaultManager] == 1) revert AlreadyVaultManager();
        if (address(IVaultManager(vaultManager).treasury()) != address(this)) revert InvalidTreasury();
        vaultManagerMap[vaultManager] = 1;
        vaultManagerList.push(vaultManager);
        emit VaultManagerToggled(vaultManager);
        stablecoin.addMinter(vaultManager);
    }

    
    
    function removeMinter(address minter) external onlyGovernor {
        // To remove the minter role to a `VaultManager` you have to go through the `removeVaultManager` function
        if (vaultManagerMap[minter] == 1) revert InvalidAddress();
        stablecoin.removeMinter(minter);
    }

    
    
    
    function removeVaultManager(address vaultManager) external onlyGovernor {
        if (vaultManagerMap[vaultManager] != 1) revert NotVaultManager();
        delete vaultManagerMap[vaultManager];
        // deletion from `vaultManagerList` loop
        uint256 vaultManagerListLength = vaultManagerList.length;
        for (uint256 i = 0; i < vaultManagerListLength - 1; i++) {
            if (vaultManagerList[i] == vaultManager) {
                // replace the `VaultManager` to remove with the last of the list
                vaultManagerList[i] = vaultManagerList[vaultManagerListLength - 1];
                break;
            }
        }
        // remove last element in array
        vaultManagerList.pop();
        emit VaultManagerToggled(vaultManager);
        stablecoin.removeMinter(vaultManager);
    }

    
    /// to a contract
    
    
    
    
    
    /// and from the flash loan module
    
    /// from the surplus and not from the `surplusBuffer`
    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 amountToRecover
    ) external onlyGovernor {
        // Cannot recover stablecoin if badDebt or tap into the surplus buffer
        if (tokenAddress == address(stablecoin)) {
            _fetchSurplusFromAll();
            // If balance is non zero then this means, after the call to `fetchSurplusFromAll` that
            // bad debt is necessarily null
            uint256 balance = stablecoin.balanceOf(address(this));
            if (amountToRecover + surplusBuffer > balance) revert TooBigAmount();
            stablecoin.transfer(to, amountToRecover);
        } else {
            IERC20(tokenAddress).safeTransfer(to, amountToRecover);
        }
        emit Recovered(tokenAddress, to, amountToRecover);
    }

    
    
    
    
    function setTreasury(address _treasury) external onlyGovernor {
        if (ITreasury(_treasury).stablecoin() != stablecoin) revert InvalidTreasury();
        // Flash loan role should be removed before calling this function
        if (core.isFlashLoanerTreasury(address(this))) revert RightsNotRemoved();
        emit NewTreasurySet(_treasury);
        for (uint256 i = 0; i < vaultManagerList.length; i++) {
            IVaultManager(vaultManagerList[i]).setTreasury(_treasury);
        }
        // A `TreasuryUpdated` event is triggered in the stablecoin
        stablecoin.setTreasury(_treasury);
    }

    
    
    
    /// which means
    function setSurplusForGovernance(uint64 _surplusForGovernance) external onlyGovernor {
        if (_surplusForGovernance > BASE_PARAMS) revert TooHighParameterValue();
        surplusForGovernance = _surplusForGovernance;
        emit SurplusForGovernanceUpdated(_surplusForGovernance);
    }

    
    /// protocol
    
    function setSurplusManager(address _surplusManager) external onlyGovernor {
        if (_surplusManager == address(0)) revert ZeroAddress();
        surplusManager = _surplusManager;
        emit SurplusManagerUpdated(_surplusManager);
    }

    
    
    /// function has been called on the `CoreBorrow` contract
    
    /// calling the contract is still a governor in the new core
    function setCore(ICoreBorrow _core) external onlyGovernor {
        if (!_core.isGovernor(msg.sender)) revert NotGovernor();
        core = ICoreBorrow(_core);
        emit CoreUpdated(address(_core));
    }

    
    function setFlashLoanModule(address _flashLoanModule) external {
        if (msg.sender != address(core)) revert NotCore();
        address oldFlashLoanModule = address(flashLoanModule);
        flashLoanModule = IFlashAngle(_flashLoanModule);
        if (oldFlashLoanModule != address(0)) {
            stablecoin.removeMinter(oldFlashLoanModule);
        }
        // We may want to cancel the module
        if (_flashLoanModule != address(0)) {
            stablecoin.addMinter(_flashLoanModule);
        }
    }
}