// SPDX-License-Identifier: MIT

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

pragma solidity =0.8.9;






// @dev These functions are not gas efficient and should _not_ be called on chain.
contract MellowContractLens {
    struct RootVaultInfo {
        // vault-specific
        IERC20RootVault rootVault;
        uint256 latestMaturity;
        bool vaultCompleted;
        bool vaultPaused;
        // user-specific
        uint256 pendingUserDeposit;
        uint256 committedUserDeposit;
        bool canWithdrawOrRollover;
    }

    struct RouterInfo {
        IERC20Minimal token;
        uint256 feePerDeposit;
        uint256 accumulatedFees;
        uint256 pendingDepositsCount;
        uint256 tokenBalance;
        uint256 ethBalance;
        bool isRegisteredForAutoRollover;
        RootVaultInfo[] erc20RootVaults;
    }

    function getVaultMaturity(IERC20RootVault rootVault)
        external
        view
        returns (uint256)
    {
        uint256 latestMaturity = 0;

        // Get latest maturity of the underlying margin engines
        uint256[] memory subvaultNFTs = rootVault.subvaultNfts();

        for (uint256 k = 1; k < subvaultNFTs.length; k++) {
            address voltzVault = rootVault.subvaultAt(k);
            IMarginEngine marginEngine = IVoltzVault(voltzVault).marginEngine();
            uint256 maturity = marginEngine.termEndTimestampWad() / 1e18;
            if (maturity > latestMaturity) {
               latestMaturity = maturity;
            }
        }

        return latestMaturity;
    }

    function getOptimisersInfo(
        IMellowMultiVaultRouter[] memory routers,
        address userAddress
    ) external view returns (RouterInfo[] memory) {
        RouterInfo[] memory routersInfo = new RouterInfo[](routers.length);

        for (uint256 i = 0; i < routers.length; ++i) {
            IMellowMultiVaultRouter router = routers[i];

            // Get token
            routersInfo[i].token = router.token();

            // Get fee per deposit 
            routersInfo[i].feePerDeposit = router.getFee();

            // Get accummulated fees
            routersInfo[i].accumulatedFees = router.getTotalFee();

            // Get the number of pending deposits
            routersInfo[i].pendingDepositsCount = router.getVaultDepositsCount();

            // Get root vaults
            IERC20RootVault[] memory rootVaults = router.getVaults();

            uint256[] memory lpTokenBalances = new uint256[](0);
            if (userAddress != address(0)) {
                // Get user's LP token balances
                lpTokenBalances = router.getLPTokenBalances(userAddress);

                // Get balances
                routersInfo[i].tokenBalance = routersInfo[i].token.balanceOf(
                    userAddress
                );
                routersInfo[i].ethBalance = userAddress.balance;

                // Get the status of user for auto-rollover
                routersInfo[i].isRegisteredForAutoRollover = router
                    .isRegisteredForAutoRollover(userAddress);
            }

            // Loop through all root vaults assigned to this router
            RootVaultInfo[] memory rootVaultsInfo = new RootVaultInfo[](
                rootVaults.length
            );
            for (uint256 j = 0; j < rootVaults.length; ++j) {
                IERC20RootVault rootVault = rootVaults[j];

                // Store root vault
                rootVaultsInfo[j].rootVault = rootVault;

                if (userAddress != address(0)) {
                    // Track pending deposit
                    IMellowMultiVaultRouter.BatchedDeposit[]
                        memory batchedDeposits = router.getBatchedDeposits(j);
                    for (uint256 k = 0; k < batchedDeposits.length; ++k) {
                        if (batchedDeposits[k].author == userAddress) {
                            rootVaultsInfo[j]
                                .pendingUserDeposit += batchedDeposits[k]
                                .amount;
                        }
                    }

                    // Track committed deposit
                    uint256 totalLpTokens = rootVault.totalSupply();

                    if (totalLpTokens > 0) {
                        (uint256[] memory minTokenAmounts, ) = rootVault.tvl();
                        uint256 tvl = minTokenAmounts[0];

                        rootVaultsInfo[j].committedUserDeposit +=
                            (lpTokenBalances[j] * tvl) /
                            totalLpTokens;
                    }

                    // Get ability to withdraw or rollover
                    rootVaultsInfo[j].canWithdrawOrRollover = router
                        .canWithdrawOrRollover(j, userAddress);
                }

                // Get latest maturity
                rootVaultsInfo[j].latestMaturity = router.getVaultMaturity(j);

                // Get whether the vault is completed or not
                rootVaultsInfo[j].vaultCompleted = router.isVaultCompleted(j);

                // Get whether the vault is paused or not
                rootVaultsInfo[j].vaultPaused = router.isVaultPaused(j);
            }

            routersInfo[i].erc20RootVaults = rootVaultsInfo;
        }

        return routersInfo;
    }
}

// 

pragma solidity =0.8.9;



interface IERC20Minimal {
    
    
    
    function balanceOf(address account) external view returns (uint256);

    
    
    
    
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    
    
    
    
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    
    
    
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    
    
    
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    // For example, if decimals equals 2, a balance of 505 tokens should be displayed to a user as 5,05 (505 / 10 ** 2).
    // Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei.
    function decimals() external view returns (uint8);

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    
    
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// 

pragma solidity 0.8.9;




interface IERC20RootVault is IERC20 {
    
    
    
    
    
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

    
    function vaultTokens() external view returns (address[] memory);

    
    
    function subvaultNfts() external view returns (uint256[] memory);

    
    function vaultGovernance() external view returns (IVaultGovernance);

    
    
    /// other DeFi protocol. For example, for USDC Yearn Vault this would be total USDC balance that could be withdrawn for Yearn to this contract.
    /// The tvl itself is estimated in some range. Sometimes the range is exact, sometimes it's not
    
    
    function tvl()
        external
        view
        returns (
            uint256[] memory minTokenAmounts,
            uint256[] memory maxTokenAmounts
        );

    
    
    
    function subvaultAt(uint256 index) external view returns (address);
}

// 

pragma solidity =0.8.9;

interface IMarginEngine {
    
    
    function termEndTimestampWad() external view returns (uint256);
}

// 

pragma solidity =0.8.9;




interface IMellowMultiVaultRouter {
    struct BatchedDeposit {
        address author;
        uint256 amount;
    }

    struct BatchedDeposits {
        mapping(uint256 => BatchedDeposit) batch;
        uint256 current;
        uint256 size;
    }

    struct BatchedAutoRollover {
        uint256 fromVault;
        uint256 lpTokensAutoRolledOver;
    }

    struct BatchedAutoRollovers {
        mapping(uint256 => BatchedAutoRollover) batch;
        uint256 current;
        uint256 size;
    }

    // -------------------  INITIALIZER -------------------

    
    function initialize(
        IWETH weth_,
        IERC20Minimal token_,
        IERC20RootVault[] memory vaults_
    ) external;

    // -------------------  GETTERS -------------------

    
    function weth() external view returns (IWETH);

    
    function token() external view returns (IERC20Minimal);

    
    function getBatchedDeposits(uint256 index)
        external
        view
        returns (BatchedDeposit[] memory);

    
    function getLPTokenBalances(address owner)
        external
        view
        returns (uint256[] memory);

    
    function getVaults() external view returns (IERC20RootVault[] memory);

    
    function isVaultCompleted(uint256 index) external view returns (bool);

    
    function isVaultPaused(uint256 index) external view returns (bool);

    function getVaultMaturity(uint256 vaultIndex)
        external
        view
        returns (uint256);

    function getCachedVaultMaturity(uint256 vaultIndex)
        external
        returns (uint256);

    
    function getFee() external view returns (uint256);

    
    function getTotalFee() external view returns (uint256);

    
    function getVaultDepositsCount() external view returns (uint256);

    // -------------------  CHECKS  -------------------

    function validWeights(uint256[] memory weights)
        external
        view
        returns (bool);

    function canWithdrawOrRollover(uint256 vaultIndex, address owner)
        external
        view
        returns (bool);

    // -------------------  SETTERS  -------------------

    
    
    function addVault(IERC20RootVault vault_) external;

    
    
    function setCompletion(uint256 index, bool completed) external;

    
    
    function setPausability(uint256 index, bool paused) external;

    
    
    function setFee(uint256 fee_) external;

    
    function refreshDepositCount() external;

    // -------------------  DEPOSITS  -------------------

    
    function depositEth(uint256[] memory weights) external payable;

    
    function depositErc20(uint256 amount, uint256[] memory weights) external;

    
    function depositEthAndRegisterForAutoRollover(
        uint256[] memory weights,
        bool registration
    ) external payable;

    
    function depositErc20AndRegisterForAutoRollover(
        uint256 amount,
        uint256[] memory weights,
        bool registration
    ) external;

    // -------------------  BATCH PUSH  -------------------

    
    /// and transfer deserving fee to sender
    function submitAllBatchesForFee() external;

    
    /// and transfer deserving fee to sender
    function submitBatchForFee(
        uint256 index,
        uint256 batchSize,
        address account
    ) external;

    
    function submitBatch(uint256 index, uint256 batchSize) external;

    // -------------------  WITHDRAWALS  -------------------

    
    function claimLPTokens(
        uint256 index,
        uint256[] memory minTokenAmounts,
        bytes[] memory vaultsOptions
    ) external;

    
    function rolloverLPTokens(
        uint256 index,
        uint256[] memory minTokenAmounts,
        bytes[] memory vaultsOptions,
        uint256[] memory weights
    ) external;

    // -------------------  AUTO-ROLLOVERS  -------------------
    
    function registerForAutoRollover(bool registration) external;

    
    function triggerAutoRollover(uint256 vaultIndex) external;

    function setAutoRolloverWeights(uint256[] memory autoRolloverWeights)
        external;

    // AUTO-ROLLOVER GETTERS

    
    function totalAutoRolloverLPTokens(uint256 vaultIndex)
        external
        view
        returns (uint256);

    function isRegisteredForAutoRollover(address owner)
        external
        view
        returns (bool);

    
    function getBatchedAutoRollovers(uint256 index)
        external
        view
        returns (BatchedAutoRollover[] memory);

    function getAutoRolloverWeights() external view returns (uint256[] memory);

    function getAutoRolledOverVaults() external view returns (uint256[] memory);

    function getPendingAutoRolloverDeposits(uint256 vaultIndex)
        external
        view
        returns (uint256);

    
    function getAutoRolloverExchangeRatesWad(uint256 fromVault, uint256 toVault)
        external
        view
        returns (uint256);

    function getPropagatedAutoRolloverLPTokens(address owner)
        external
        view
        returns (uint256[] memory);
}

// 
pragma solidity 0.8.9;

interface IVaultGovernance {
    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    function delayedStrategyParamsTimestamp(uint256 nft)
        external
        view
        returns (uint256);

    
    function delayedProtocolParamsTimestamp() external view returns (uint256);

    
    
    function delayedProtocolPerVaultParamsTimestamp(uint256 nft)
        external
        view
        returns (uint256);

    
    function internalParamsTimestamp() external view returns (uint256);
}

// 
pragma solidity 0.8.9;



interface IVoltzVault {
    
    function marginEngine() external view returns (IMarginEngine);
}

// 

pragma solidity =0.8.9;



interface IWETH is IERC20Minimal {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}