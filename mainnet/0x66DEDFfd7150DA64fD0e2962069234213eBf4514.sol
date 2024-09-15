// SPDX-License-Identifier: GPL-3.0-only


// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity >=0.7.0;



interface IAnteTest {
    
    
    
    function testAuthor() external view returns (address);

    
    
    
    function protocolName() external view returns (string memory);

    
    
    
    
    function testedContracts(uint256 i) external view returns (address);

    
    
    
    function testName() external view returns (string memory);

    
    
    
    function checkTestPasses() external returns (bool);
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

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity >=0.7.0;






abstract contract AnteTest is IAnteTest {
    
    address public override testAuthor;
    
    string public override testName;
    
    string public override protocolName;
    
    address[] public override testedContracts;

    
    /// be set in the constructor of your AnteTest
    
    constructor(string memory _testName) {
        testAuthor = msg.sender;
        testName = _testName;
    }

    
    
    function getTestedContracts() external view returns (address[] memory) {
        return testedContracts;
    }

    
    function checkTestPasses() external virtual override returns (bool) {}
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;









contract AnteRibbonV2UpdatableThetaVaultPlungeTest is Ownable, AnteTest("RibbonV2 Theta Vaults don't lose 90% of TVL") {
    
    
    
    
    event AnteRibbonTestVaultAdded(address indexed vault, address[] vaultAssets, uint256 initialThreshold);

    
    
    
    
    event AnteRibbonTestPendingUpdate(address indexed vault, uint256 oldThreshold, uint256 newThreshold);

    
    
    
    
    event AnteRibbonTestUpdated(address indexed vault, uint256 oldThreshold, uint256 newThreshold);
    /// Opyn Controller
    IController internal controller = IController(0x4ccc2339F87F6c59c6893E1A678c2266cA58dC72);

    /// Array of Theta Vaults checked by this test
    address[] public thetaVaults;

    /// Mapping of asset to check for each vault
    // The Ribbon vault and Opyn controller don't provide this 100% reliably
    mapping(address => IERC20[]) public assets;

    /// Mapping of vault balance failure thresholds
    mapping(address => uint256) public thresholds;

    /// wstETH address, because we need to handle it differently
    IWSTETH public constant WSTETH = IWSTETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);

    /// Max number of vaults to test (to guard against block stuffing)
    uint256 public constant MAX_VAULTS = 20;

    /// Failure threshold as % of initial value (set to 10%)
    uint8 public constant INITIAL_FAILURE_THRESHOLD_PERCENT = 10;

    /// Minimum waiting period for major test updates by owner
    uint256 public constant UPDATE_WAITING_PERIOD = 172800; // 2 days

    /// Last timestamp test parameters were updated
    uint256 public lastUpdated;

    // Update-related variables
    address public pendingVault;
    uint256 public newThreshold;
    uint256 public updateCommittedTime;

    constructor() {
        protocolName = "Ribbon";

        // Initial set of vaults/assets - top vaults by TVL (90% of TVL as of 2022-11-30)
        thetaVaults.push(0x53773E034d9784153471813dacAFF53dBBB78E8c); // T-STETH-C vault
        // stETH vault balance calc includes WETH, stETH, and wstETH->stETH equivalent
        assets[0x53773E034d9784153471813dacAFF53dBBB78E8c] = [
            IERC20(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0), // wstETH
            IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84), // stETH
            IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2) // WETH
        ];

        thetaVaults.push(0xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624); // T-USDC-P-ETH vault
        assets[0xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624].push(
            IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) // USDC
        );

        thetaVaults.push(0x25751853Eab4D0eB3652B5eB6ecB102A2789644B); // T-ETH-C vault
        assets[0x25751853Eab4D0eB3652B5eB6ecB102A2789644B].push(
            IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2) // WETH
        );

        thetaVaults.push(0x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F); // T-WBTC-C vault
        assets[0x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F].push(
            IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599) // WBTC
        );

        // Set initial failure thresholds (10% of vault balance at time of test deploy)
        address vault;
        uint256 numVaults = thetaVaults.length;
        for (uint256 i; i < numVaults; i++) {
            vault = thetaVaults[i];
            thresholds[vault] = (calculateVaultBalance(vault) * INITIAL_FAILURE_THRESHOLD_PERCENT) / 100;
            testedContracts.push(vault);
        }
        lastUpdated = block.timestamp;
    }

    
    /// (by default, 10% of vault balance when added to test)
    
    function checkTestPasses() external view override returns (bool) {
        address vault;
        uint256 numVaults = thetaVaults.length;
        for (uint256 i; i < numVaults; i++) {
            vault = thetaVaults[i];
            if (calculateVaultBalance(vault) < thresholds[vault]) {
                return false;
            }
        }

        return true;
    }

    
    
    
    function calculateVaultBalance(address thetaVault) public view returns (uint256) {
        GammaTypes.Vault memory opynVault = controller.getVault(
            thetaVault,
            controller.getAccountVaultCounter(thetaVault)
        );

        uint256 totalBalance;
        IERC20 asset;
        uint256 numAssets = assets[thetaVault].length;
        for (uint256 i = 0; i < numAssets; i++) {
            asset = IERC20(assets[thetaVault][i]);
            if (address(asset) == address(WSTETH)) {
                // convert wstETH to stETH equivalent amount
                totalBalance += WSTETH.getStETHByWstETH(WSTETH.balanceOf(thetaVault));
            } else {
                totalBalance += asset.balanceOf(thetaVault);
            }
        }

        // Note: assumes the collateral asset of interest is 1st in array
        if (
            opynVault.collateralAmounts.length > 0 &&
            opynVault.collateralAssets.length > 0 &&
            opynVault.collateralAssets[0] == address(assets[thetaVault][0])
        ) {
            if (address(opynVault.collateralAssets[0]) == address(WSTETH)) {
                return totalBalance + WSTETH.getStETHByWstETH(opynVault.collateralAmounts[0]);
            } else {
                return totalBalance + opynVault.collateralAmounts[0];
            }
        } else {
            // in between rounds, so collateralAmounts is null array
            return totalBalance;
        }
    }

    // == ADMIN FUNCTIONS == //

    
    ///         to 10% of current TVL. Can only be called by owner (Ribbon)
    
    
    
    ///      the first asset in the array
    function addVault(address vault, address[] memory _assets) public onlyOwner {
        // Checks max vaults + valid Opyn vault for the given theta vault address
        require(thetaVaults.length < MAX_VAULTS, "Maximum number of tested vaults reached!");
        require(_assets.length > 0, "no assets provided!");
        GammaTypes.Vault memory opynVault = controller.getVault(vault, controller.getAccountVaultCounter(vault));
        require(opynVault.collateralAmounts.length > 0, "Invalid vault");
        require(
            opynVault.collateralAssets.length > 0 && opynVault.collateralAssets[0] == _assets[0],
            "primary assets don't match!"
        );

        uint256 numAssets = _assets.length;
        assets[vault] = new IERC20[](numAssets);
        for (uint256 i = 0; i < numAssets; i++) {
            assets[vault][i] = IERC20(_assets[i]);
        }

        uint256 balance = calculateVaultBalance(vault);
        require(balance > 0, "Vault has no balance!");

        thetaVaults.push(vault);
        thresholds[vault] = (balance * INITIAL_FAILURE_THRESHOLD_PERCENT) / 100;
        testedContracts.push(vault);
        lastUpdated = block.timestamp;

        emit AnteRibbonTestVaultAdded(vault, _assets, thresholds[vault]);
    }

    
    ///         period before update is made. Can only be called by owner (Ribbon)
    
    
    function commitUpdateFailureThreshold(address vault, uint256 threshold) public onlyOwner {
        require(assets[vault].length > 0, "Vault not in list");
        require(pendingVault == address(0), "Another update already pending!");
        require(calculateVaultBalance(vault) >= threshold, "test would fail proposed threshold!");

        pendingVault = vault;
        newThreshold = threshold;
        updateCommittedTime = block.timestamp;
        emit AnteRibbonTestPendingUpdate(pendingVault, thresholds[pendingVault], newThreshold);
    }

    
    ///         Can be called by anyone, just costs gas
    function executeUpdateFailureThreshold() public {
        require(pendingVault != address(0), "No update pending!");
        require(
            block.timestamp > updateCommittedTime + UPDATE_WAITING_PERIOD,
            "Need to wait 2 days to adjust failure threshold!"
        );
        emit AnteRibbonTestUpdated(pendingVault, thresholds[pendingVault], newThreshold);
        thresholds[pendingVault] = newThreshold;

        pendingVault = address(0);
        lastUpdated = block.timestamp;
    }
}

// 
pragma solidity =0.8.4;

library GammaTypes {
    // vault is a struct of 6 arrays that describe a position a user has, a user can have multiple vaults.
    struct Vault {
        // addresses of oTokens a user has shorted (i.e. written) against this vault
        address[] shortOtokens;
        // addresses of oTokens a user has bought and deposited in this vault
        // user can be long oTokens without opening a vault (e.g. by buying on a DEX)
        // generally, long oTokens will be 'deposited' in vaults to act as collateral
        // in order to write oTokens against (i.e. in spreads)
        address[] longOtokens;
        // addresses of other ERC-20s a user has deposited as collateral in this vault
        address[] collateralAssets;
        // quantity of oTokens minted/written for each oToken address in shortOtokens
        uint256[] shortAmounts;
        // quantity of oTokens owned and held in the vault for each oToken address in longOtokens
        uint256[] longAmounts;
        // quantity of ERC-20 deposited as collateral in the vault for each ERC-20 address in collateralAssets
        uint256[] collateralAmounts;
    }
}

interface IOtoken {
    function underlyingAsset() external view returns (address);

    function strikeAsset() external view returns (address);

    function collateralAsset() external view returns (address);

    function strikePrice() external view returns (uint256);

    function expiryTimestamp() external view returns (uint256);

    function isPut() external view returns (bool);
}

interface IOtokenFactory {
    function getOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external view returns (address);

    function createOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external returns (address);

    function getTargetOtokenAddress(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external view returns (address);

    event OtokenCreated(
        address tokenAddress,
        address creator,
        address indexed underlying,
        address indexed strike,
        address indexed collateral,
        uint256 strikePrice,
        uint256 expiry,
        bool isPut
    );
}

interface IController {
    // possible actions that can be performed
    enum ActionType {
        OpenVault,
        MintShortOption,
        BurnShortOption,
        DepositLongOption,
        WithdrawLongOption,
        DepositCollateral,
        WithdrawCollateral,
        SettleVault,
        Redeem,
        Call,
        Liquidate
    }

    struct ActionArgs {
        // type of action that is being performed on the system
        ActionType actionType;
        // address of the account owner
        address owner;
        // address which we move assets from or to (depending on the action type)
        address secondAddress;
        // asset that is to be transfered
        address asset;
        // index of the vault that is to be modified (if any)
        uint256 vaultId;
        // amount of asset that is to be transfered
        uint256 amount;
        // each vault can hold multiple short / long / collateral assets
        // but we are restricting the scope to only 1 of each in this version
        // in future versions this would be the index of the short / long / collateral asset that needs to be modified
        uint256 index;
        // any other data that needs to be passed in for arbitrary function calls
        bytes data;
    }

    struct RedeemArgs {
        // address to which we pay out the oToken proceeds
        address receiver;
        // oToken that is to be redeemed
        address otoken;
        // amount of oTokens that is to be redeemed
        uint256 amount;
    }

    function getPayout(address _otoken, uint256 _amount) external view returns (uint256);

    function operate(ActionArgs[] calldata _actions) external;

    function getAccountVaultCounter(address owner) external view returns (uint256);

    function oracle() external view returns (address);

    function getVault(address _owner, uint256 _vaultId) external view returns (GammaTypes.Vault memory);

    function getProceed(address _owner, uint256 _vaultId) external view returns (uint256);

    function isSettlementAllowed(
        address _underlying,
        address _strike,
        address _collateral,
        uint256 _expiry
    ) external view returns (bool);
}

// 
pragma solidity =0.8.4;

interface IWSTETH {
    function getStETHByWstETH(uint256 _amount) external view returns (uint256);

    function getWstETHByStETH(uint256 _amount) external view returns (uint256);

    function stEthPerToken() external view returns (uint256);

    function tokensPerStEth() external view returns (uint256);

    function stETH() external view returns (address);

    function wrap(uint256 _amount) external returns (uint256);

    function unwrap(uint256 _amount) external returns (uint256);

    function approve(address _recipient, uint256 _amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint256);
}

interface ISTETH {
    function getBufferedEther(uint256 _amount) external view returns (uint256);

    function getPooledEthByShares(uint256 _amount) external view returns (uint256);

    function getSharesByPooledEth(uint256 _amount) external view returns (uint256);

    function submit(address _referralAddress) external payable returns (uint256);

    function withdraw(uint256 _amount, bytes32 _pubkeyHash) external returns (uint256);

    function approve(address _recipient, uint256 _amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint256);
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
