// SPDX-License-Identifier: AGPL-3.0-only


// 
pragma solidity 0.8.15;

//     ███████    █████       █████ █████ ██████   ██████ ███████████  █████  █████  █████████
//   ███░░░░░███ ░░███       ░░███ ░░███ ░░██████ ██████ ░░███░░░░░███░░███  ░░███  ███░░░░░███
//  ███     ░░███ ░███        ░░███ ███   ░███░█████░███  ░███    ░███ ░███   ░███ ░███    ░░░
// ░███      ░███ ░███         ░░█████    ░███░░███ ░███  ░██████████  ░███   ░███ ░░█████████
// ░███      ░███ ░███          ░░███     ░███ ░░░  ░███  ░███░░░░░░   ░███   ░███  ░░░░░░░░███
// ░░███     ███  ░███      █    ░███     ░███      ░███  ░███         ░███   ░███  ███    ░███
//  ░░░███████░   ███████████    █████    █████     █████ █████        ░░████████  ░░█████████
//    ░░░░░░░    ░░░░░░░░░░░    ░░░░░    ░░░░░     ░░░░░ ░░░░░          ░░░░░░░░    ░░░░░░░░░

//============================================================================================//
//                                        GLOBAL TYPES                                        //
//============================================================================================//


enum Actions {
    InstallModule,
    UpgradeModule,
    ActivatePolicy,
    DeactivatePolicy,
    ChangeExecutor,
    MigrateKernel
}


struct Instruction {
    Actions action;
    address target;
}


struct Permissions {
    Keycode keycode;
    bytes4 funcSelector;
}

type Keycode is bytes5;

//============================================================================================//
//                                       UTIL FUNCTIONS                                       //
//============================================================================================//

error TargetNotAContract(address target_);
error InvalidKeycode(Keycode keycode_);

// solhint-disable-next-line func-visibility
function toKeycode(bytes5 keycode_) pure returns (Keycode) {
    return Keycode.wrap(keycode_);
}

// solhint-disable-next-line func-visibility
function fromKeycode(Keycode keycode_) pure returns (bytes5) {
    return Keycode.unwrap(keycode_);
}

// solhint-disable-next-line func-visibility
function ensureContract(address target_) view {
    if (target_.code.length == 0) revert TargetNotAContract(target_);
}

// solhint-disable-next-line func-visibility
function ensureValidKeycode(Keycode keycode_) pure {
    bytes5 unwrapped = Keycode.unwrap(keycode_);
    for (uint256 i = 0; i < 5; ) {
        bytes1 char = unwrapped[i];
        if (char < 0x41 || char > 0x5A) revert InvalidKeycode(keycode_); // A-Z only
        unchecked {
            i++;
        }
    }
}

//============================================================================================//
//                                        COMPONENTS                                          //
//============================================================================================//


abstract contract KernelAdapter {
    error KernelAdapter_OnlyKernel(address caller_);

    Kernel public kernel;

    constructor(Kernel kernel_) {
        kernel = kernel_;
    }

    
    modifier onlyKernel() {
        if (msg.sender != address(kernel)) revert KernelAdapter_OnlyKernel(msg.sender);
        _;
    }

    
    function changeKernel(Kernel newKernel_) external onlyKernel {
        kernel = newKernel_;
    }
}


///         interacted with and mutated through policies.

abstract contract Module is KernelAdapter {
    error Module_PolicyNotPermitted(address policy_);

    constructor(Kernel kernel_) KernelAdapter(kernel_) {}

    
    modifier permissioned() {
        if (!kernel.modulePermissions(KEYCODE(), Policy(msg.sender), msg.sig))
            revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    
    function KEYCODE() public pure virtual returns (Keycode) {}

    
    
    
    function VERSION() external pure virtual returns (uint8 major, uint8 minor) {}

    
    
    
    function INIT() external virtual onlyKernel {}
}

// 
pragma solidity >=0.8.0;




abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}




abstract contract Policy is KernelAdapter {
    error Policy_ModuleDoesNotExist(Keycode keycode_);

    constructor(Kernel kernel_) KernelAdapter(kernel_) {}

    
    function isActive() external view returns (bool) {
        return kernel.isPolicyActive(this);
    }

    
    function getModuleAddress(Keycode keycode_) internal view returns (address) {
        address moduleForKeycode = address(kernel.getModuleForKeycode(keycode_));
        if (moduleForKeycode == address(0)) revert Policy_ModuleDoesNotExist(keycode_);
        return moduleForKeycode;
    }

    
    
    function configureDependencies() external virtual returns (Keycode[] memory dependencies) {}

    
    
    function requestPermissions() external view virtual returns (Permissions[] memory requests) {}
}

// 
pragma solidity ^0.8.0;

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

    function latestRound() external view returns (uint256);

    function getAnswer(uint256 roundId) external view returns (int256);

    function getTimestamp(uint256 roundId) external view returns (uint256);

    event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

    event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

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
pragma solidity >=0.8.0;





interface IBondAuctioneer {
    
    
    
    
    function createMarket(bytes memory params_) external returns (uint256);

    
    
    
    function closeMarket(uint256 id_) external;

    
    
    
    
    
    
    function purchaseBond(
        uint256 id_,
        uint256 amount_,
        uint256 minAmountOut_
    ) external returns (uint256 payout);

    
    
    
    ///                                 tuneInterval should be greater than tuneAdjustmentDelay
    
    
    ///                                 1. Tune interval - Frequency of tuning
    ///                                 2. Tune adjustment delay - Time to implement downward tuning adjustments
    ///                                 3. Debt decay interval - Interval over which debt should decay completely
    function setIntervals(uint256 id_, uint32[3] calldata intervals_) external;

    
    
    
    
    
    function pushOwnership(uint256 id_, address newOwner_) external;

    
    
    
    
    function pullOwnership(uint256 id_) external;

    
    
    
    ///                     1. Tune interval - amount of time between tuning adjustments
    ///                     2. Tune adjustment delay - amount of time to apply downward tuning adjustments
    ///                     3. Minimum debt decay interval - minimum amount of time to let debt decay to zero
    ///                     4. Minimum deposit interval - minimum amount of time to wait between deposits
    ///                     5. Minimum market duration - minimum amount of time a market can be created for
    ///                     6. Minimum debt buffer - the minimum amount of debt over the initial debt to trigger a market shutdown
    
    
    function setDefaults(uint32[6] memory defaults_) external;

    
    
    
    function setAllowNewMarkets(bool status_) external;

    
    
    
    
    
    function setCallbackAuthStatus(address creator_, bool status_) external;

    /* ========== VIEW FUNCTIONS ========== */

    
    
    
    
    
    
    
    
    function getMarketInfoForPurchase(uint256 id_)
        external
        view
        returns (
            address owner,
            address callbackAddr,
            ERC20 payoutToken,
            ERC20 quoteToken,
            uint48 vesting,
            uint256 maxPayout
        );

    
    
    
    //
    // if price is below minimum price, minimum price is returned
    function marketPrice(uint256 id_) external view returns (uint256);

    
    
    
    function marketScale(uint256 id_) external view returns (uint256);

    
    
    
    
    
    ///                     Inputting the zero address will take into account just the protocol fee.
    
    function payoutFor(
        uint256 amount_,
        uint256 id_,
        address referrer_
    ) external view returns (uint256);

    
    
    
    ///                     Inputting the zero address will take into account just the protocol fee.
    function maxAmountAccepted(uint256 id_, address referrer_) external view returns (uint256);

    
    
    function isInstantSwap(uint256 id_) external view returns (bool);

    
    
    function isLive(uint256 id_) external view returns (bool);

    
    
    function ownerOf(uint256 id_) external view returns (address);

    
    function getTeller() external view returns (IBondTeller);

    
    function getAggregator() external view returns (IBondAggregator);

    
    function currentCapacity(uint256 id_) external view returns (uint256);
}

// 
pragma solidity 0.8.15;






abstract contract RolesConsumer {
    ROLESv1 public ROLES;

    modifier onlyRole(bytes32 role_) {
        ROLES.requireRole(role_, msg.sender);
        _;
    }
}

// 
pragma solidity 0.8.15;



abstract contract ROLESv1 is Module {
    // =========  EVENTS ========= //

    event RoleGranted(bytes32 indexed role_, address indexed addr_);
    event RoleRevoked(bytes32 indexed role_, address indexed addr_);

    // =========  ERRORS ========= //

    error ROLES_InvalidRole(bytes32 role_);
    error ROLES_RequireRole(bytes32 role_);
    error ROLES_AddressAlreadyHasRole(address addr_, bytes32 role_);
    error ROLES_AddressDoesNotHaveRole(address addr_, bytes32 role_);
    error ROLES_RoleDoesNotExist(bytes32 role_);

    // =========  STATE ========= //

    
    mapping(address => mapping(bytes32 => bool)) public hasRole;

    // =========  FUNCTIONS ========= //

    
    function saveRole(bytes32 role_, address addr_) external virtual;

    
    function removeRole(bytes32 role_, address addr_) external virtual;

    
    
    function requireRole(bytes32 role_, address caller_) external virtual;

    
    function ensureValidRole(bytes32 role_) external pure virtual;
}

// 
pragma solidity >=0.8.0;



interface IHeart {
    // =========  EVENTS ========= //

    event Beat(uint256 timestamp_);
    event RewardIssued(address to_, uint256 rewardAmount_);
    event RewardUpdated(ERC20 token_, uint256 rewardAmount_);

    // =========  ERRORS ========= //

    error Heart_OutOfCycle();
    error Heart_BeatStopped();
    error Heart_InvalidParams();
    error Heart_BeatAvailable();

    // =========  CORE FUNCTIONS ========= //

    
    
    
    
    function beat() external;

    // =========  ADMIN FUNCTIONS ========= //

    
    
    function resetBeat() external;

    
    
    
    function activate() external;

    
    
    
    function deactivate() external;

    
    
    
    function setOperator(address operator_) external;

    
    
    
    
    function setRewardTokenAndAmount(ERC20 token_, uint256 reward_) external;

    
    
    function withdrawUnspentRewards(ERC20 token_) external;

    // =========  VIEW FUNCTIONS ========= //

    
    function frequency() external view returns (uint256);
}
// 
pragma solidity >=0.8.0;





abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}




contract Kernel {
    // =========  EVENTS ========= //

    event PermissionsUpdated(
        Keycode indexed keycode_,
        Policy indexed policy_,
        bytes4 funcSelector_,
        bool granted_
    );
    event ActionExecuted(Actions indexed action_, address indexed target_);

    // =========  ERRORS ========= //

    error Kernel_OnlyExecutor(address caller_);
    error Kernel_ModuleAlreadyInstalled(Keycode module_);
    error Kernel_InvalidModuleUpgrade(Keycode module_);
    error Kernel_PolicyAlreadyActivated(address policy_);
    error Kernel_PolicyNotActivated(address policy_);

    // =========  PRIVILEGED ADDRESSES ========= //

    
    address public executor;

    // =========  MODULE MANAGEMENT ========= //

    
    Keycode[] public allKeycodes;

    
    mapping(Keycode => Module) public getModuleForKeycode;

    
    mapping(Module => Keycode) public getKeycodeForModule;

    
    mapping(Keycode => Policy[]) public moduleDependents;

    
    mapping(Keycode => mapping(Policy => uint256)) public getDependentIndex;

    
    
    mapping(Keycode => mapping(Policy => mapping(bytes4 => bool))) public modulePermissions;

    // =========  POLICY MANAGEMENT ========= //

    
    Policy[] public activePolicies;

    
    mapping(Policy => uint256) public getPolicyIndex;

    //============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    //============================================================================================//

    constructor() {
        executor = msg.sender;
    }

    
    modifier onlyExecutor() {
        if (msg.sender != executor) revert Kernel_OnlyExecutor(msg.sender);
        _;
    }

    function isPolicyActive(Policy policy_) public view returns (bool) {
        return activePolicies.length > 0 && activePolicies[getPolicyIndex[policy_]] == policy_;
    }

    
    function executeAction(Actions action_, address target_) external onlyExecutor {
        if (action_ == Actions.InstallModule) {
            ensureContract(target_);
            ensureValidKeycode(Module(target_).KEYCODE());
            _installModule(Module(target_));
        } else if (action_ == Actions.UpgradeModule) {
            ensureContract(target_);
            ensureValidKeycode(Module(target_).KEYCODE());
            _upgradeModule(Module(target_));
        } else if (action_ == Actions.ActivatePolicy) {
            ensureContract(target_);
            _activatePolicy(Policy(target_));
        } else if (action_ == Actions.DeactivatePolicy) {
            ensureContract(target_);
            _deactivatePolicy(Policy(target_));
        } else if (action_ == Actions.ChangeExecutor) {
            executor = target_;
        } else if (action_ == Actions.MigrateKernel) {
            ensureContract(target_);
            _migrateKernel(Kernel(target_));
        }

        emit ActionExecuted(action_, target_);
    }

    function _installModule(Module newModule_) internal {
        Keycode keycode = newModule_.KEYCODE();

        if (address(getModuleForKeycode[keycode]) != address(0))
            revert Kernel_ModuleAlreadyInstalled(keycode);

        getModuleForKeycode[keycode] = newModule_;
        getKeycodeForModule[newModule_] = keycode;
        allKeycodes.push(keycode);

        newModule_.INIT();
    }

    function _upgradeModule(Module newModule_) internal {
        Keycode keycode = newModule_.KEYCODE();
        Module oldModule = getModuleForKeycode[keycode];

        if (address(oldModule) == address(0) || oldModule == newModule_)
            revert Kernel_InvalidModuleUpgrade(keycode);

        getKeycodeForModule[oldModule] = Keycode.wrap(bytes5(0));
        getKeycodeForModule[newModule_] = keycode;
        getModuleForKeycode[keycode] = newModule_;

        newModule_.INIT();

        _reconfigurePolicies(keycode);
    }

    function _activatePolicy(Policy policy_) internal {
        if (isPolicyActive(policy_)) revert Kernel_PolicyAlreadyActivated(address(policy_));

        // Add policy to list of active policies
        activePolicies.push(policy_);
        getPolicyIndex[policy_] = activePolicies.length - 1;

        // Record module dependencies
        Keycode[] memory dependencies = policy_.configureDependencies();
        uint256 depLength = dependencies.length;

        for (uint256 i; i < depLength; ) {
            Keycode keycode = dependencies[i];

            moduleDependents[keycode].push(policy_);
            getDependentIndex[keycode][policy_] = moduleDependents[keycode].length - 1;

            unchecked {
                ++i;
            }
        }

        // Grant permissions for policy to access restricted module functions
        Permissions[] memory requests = policy_.requestPermissions();
        _setPolicyPermissions(policy_, requests, true);
    }

    function _deactivatePolicy(Policy policy_) internal {
        if (!isPolicyActive(policy_)) revert Kernel_PolicyNotActivated(address(policy_));

        // Revoke permissions
        Permissions[] memory requests = policy_.requestPermissions();
        _setPolicyPermissions(policy_, requests, false);

        // Remove policy from all policy data structures
        uint256 idx = getPolicyIndex[policy_];
        Policy lastPolicy = activePolicies[activePolicies.length - 1];

        activePolicies[idx] = lastPolicy;
        activePolicies.pop();
        getPolicyIndex[lastPolicy] = idx;
        delete getPolicyIndex[policy_];

        // Remove policy from module dependents
        _pruneFromDependents(policy_);
    }

    
    
    
    function _migrateKernel(Kernel newKernel_) internal {
        uint256 keycodeLen = allKeycodes.length;
        for (uint256 i; i < keycodeLen; ) {
            Module module = Module(getModuleForKeycode[allKeycodes[i]]);
            module.changeKernel(newKernel_);
            unchecked {
                ++i;
            }
        }

        uint256 policiesLen = activePolicies.length;
        for (uint256 j; j < policiesLen; ) {
            Policy policy = activePolicies[j];

            // Deactivate before changing kernel
            policy.changeKernel(newKernel_);
            unchecked {
                ++j;
            }
        }
    }

    function _reconfigurePolicies(Keycode keycode_) internal {
        Policy[] memory dependents = moduleDependents[keycode_];
        uint256 depLength = dependents.length;

        for (uint256 i; i < depLength; ) {
            dependents[i].configureDependencies();

            unchecked {
                ++i;
            }
        }
    }

    function _setPolicyPermissions(
        Policy policy_,
        Permissions[] memory requests_,
        bool grant_
    ) internal {
        uint256 reqLength = requests_.length;
        for (uint256 i = 0; i < reqLength; ) {
            Permissions memory request = requests_[i];
            modulePermissions[request.keycode][policy_][request.funcSelector] = grant_;

            emit PermissionsUpdated(request.keycode, policy_, request.funcSelector, grant_);

            unchecked {
                ++i;
            }
        }
    }

    function _pruneFromDependents(Policy policy_) internal {
        Keycode[] memory dependencies = policy_.configureDependencies();
        uint256 depcLength = dependencies.length;

        for (uint256 i; i < depcLength; ) {
            Keycode keycode = dependencies[i];
            Policy[] storage dependents = moduleDependents[keycode];

            uint256 origIndex = getDependentIndex[keycode][policy_];
            Policy lastPolicy = dependents[dependents.length - 1];

            // Swap with last and pop
            dependents[origIndex] = lastPolicy;
            dependents.pop();

            // Record new index and delete deactivated policy index
            getDependentIndex[keycode][lastPolicy] = origIndex;
            delete getDependentIndex[keycode][policy_];

            unchecked {
                ++i;
            }
        }
    }
}

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

// 
pragma solidity >=0.8.0;





interface IBondAggregator {
    
    
    
    
    function registerAuctioneer(IBondAuctioneer auctioneer_) external;

    
    
    
    
    
    function registerMarket(ERC20 payoutToken_, ERC20 quoteToken_)
        external
        returns (uint256 marketId);

    
    
    function getAuctioneer(uint256 id_) external view returns (IBondAuctioneer);

    
    
    
    
    //
    // if price is below minimum price, minimum price is returned
    // this is enforced on deposits by manipulating total debt (see _decay())
    function marketPrice(uint256 id_) external view returns (uint256);

    
    
    
    function marketScale(uint256 id_) external view returns (uint256);

    
    
    
    
    
    ///                     Inputting the zero address will take into account just the protocol fee.
    
    function payoutFor(
        uint256 amount_,
        uint256 id_,
        address referrer_
    ) external view returns (uint256);

    
    
    
    ///                     Inputting the zero address will take into account just the protocol fee.
    function maxAmountAccepted(uint256 id_, address referrer_) external view returns (uint256);

    
    
    function isInstantSwap(uint256 id_) external view returns (bool);

    
    
    function isLive(uint256 id_) external view returns (bool);

    
    
    function liveMarketsBetween(uint256 firstIndex_, uint256 lastIndex_)
        external
        view
        returns (uint256[] memory);

    
    
    
    function liveMarketsFor(address token_, bool isPayout_)
        external
        view
        returns (uint256[] memory);

    
    
    
    
    function liveMarketsBy(
        address owner_,
        uint256 firstIndex_,
        uint256 lastIndex_
    ) external view returns (uint256[] memory);

    
    
    
    function marketsFor(address payout_, address quote_) external view returns (uint256[] memory);

    
    
    
    
    
    
    ///                         Inputting the zero address will take into account just the protocol fee.
    function findMarketFor(
        address payout_,
        address quote_,
        uint256 amountIn_,
        uint256 minAmountOut_,
        uint256 maxExpiry_
    ) external view returns (uint256 id);

    
    function getTeller(uint256 id_) external view returns (IBondTeller);

    
    function currentCapacity(uint256 id_) external view returns (uint256);
}

// 
pragma solidity >=0.8.0;



interface IBondCallback {
    
    
    
    
    
    
    
    function callback(
        uint256 id_,
        uint256 inputAmount_,
        uint256 outputAmount_
    ) external;

    
    
    
    
    function amountsForMarket(uint256 id_) external view returns (uint256 in_, uint256 out_);

    
    
    
    
    function whitelist(address teller_, uint256 id_) external;

    
    
    
    
    function blacklist(address teller_, uint256 id_) external;
}

// 
pragma solidity >=0.8.0;




interface IBondSDA is IBondAuctioneer {
    
    struct BondMarket {
        address owner; // market owner. sends payout tokens, receives quote tokens (defaults to creator)
        ERC20 payoutToken; // token to pay depositors with
        ERC20 quoteToken; // token to accept as payment
        address callbackAddr; // address to call for any operations on bond purchase. Must inherit to IBondCallback.
        bool capacityInQuote; // capacity limit is in payment token (true) or in payout (false, default)
        uint256 capacity; // capacity remaining
        uint256 totalDebt; // total payout token debt from market
        uint256 minPrice; // minimum price (hard floor for the market)
        uint256 maxPayout; // max payout tokens out in one order
        uint256 sold; // payout tokens out
        uint256 purchased; // quote tokens in
        uint256 scale; // scaling factor for the market (see MarketParams struct)
    }

    
    struct BondTerms {
        uint256 controlVariable; // scaling variable for price
        uint256 maxDebt; // max payout token debt accrued
        uint48 vesting; // length of time from deposit to expiry if fixed-term, vesting timestamp if fixed-expiry
        uint48 conclusion; // timestamp when market no longer offered
    }

    
    
    struct BondMetadata {
        uint48 lastTune; // last timestamp when control variable was tuned
        uint48 lastDecay; // last timestamp when market was created and debt was decayed
        uint32 length; // time from creation to conclusion.
        uint32 depositInterval; // target frequency of deposits
        uint32 tuneInterval; // frequency of tuning
        uint32 tuneAdjustmentDelay; // time to implement downward tuning adjustments
        uint32 debtDecayInterval; // interval over which debt should decay completely
        uint256 tuneIntervalCapacity; // capacity expected to be used during a tuning interval
        uint256 tuneBelowCapacity; // capacity that the next tuning will occur at
        uint256 lastTuneDebt; // target debt calculated at last tuning
    }

    
    struct Adjustment {
        uint256 change;
        uint48 lastAdjustment;
        uint48 timeToAdjusted; // how long until adjustment happens
        bool active;
    }

    
    
    ///                     formatted price = (payoutPriceCoefficient / quotePriceCoefficient)
    ///                             * 10**(36 + scaleAdjustment + quoteDecimals - payoutDecimals + payoutPriceDecimals - quotePriceDecimals)
    ///                     where:
    ///                         payoutDecimals - Number of decimals defined for the payoutToken in its ERC20 contract
    ///                         quoteDecimals - Number of decimals defined for the quoteToken in its ERC20 contract
    ///                         payoutPriceCoefficient - The coefficient of the payoutToken price in scientific notation (also known as the significant digits)
    ///                         payoutPriceDecimals - The significand of the payoutToken price in scientific notation (also known as the base ten exponent)
    ///                         quotePriceCoefficient - The coefficient of the quoteToken price in scientific notation (also known as the significant digits)
    ///                         quotePriceDecimals - The significand of the quoteToken price in scientific notation (also known as the base ten exponent)
    ///                         scaleAdjustment - see below
    ///                         * In the above definitions, the "prices" need to have the same unit of account (i.e. both in OHM, $, ETH, etc.)
    ///                         If price is not provided in this format, the market will not behave as intended.
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    struct MarketParams {
        ERC20 payoutToken;
        ERC20 quoteToken;
        address callbackAddr;
        bool capacityInQuote;
        uint256 capacity;
        uint256 formattedInitialPrice;
        uint256 formattedMinimumPrice;
        uint32 debtBuffer;
        uint48 vesting;
        uint48 conclusion;
        uint32 depositInterval;
        int8 scaleAdjustment;
    }

    /* ========== VIEW FUNCTIONS ========== */

    
    
    
    
    //
    // price is derived from the equation
    //
    // p = c * d
    //
    // where
    // p = price
    // c = control variable
    // d = debt
    //
    // d -= ( d * (dt / l) )
    //
    // where
    // dt = change in time
    // l = length of program
    //
    // if price is below minimum price, minimum price is returned
    // this is enforced on deposits by manipulating total debt (see _decay())
    function marketPrice(uint256 id_) external view override returns (uint256);

    
    
    
    
    function currentDebt(uint256 id_) external view returns (uint256);

    
    
    
    
    function currentControlVariable(uint256 id_) external view returns (uint256);
}

// 
pragma solidity >=0.8.0;



interface IBondTeller {
    
    
    
    ///                         Direct calls can use the zero address for no referrer fee.
    
    
    
    
    
    function purchase(
        address recipient_,
        address referrer_,
        uint256 id_,
        uint256 amount_,
        uint256 minAmountOut_
    ) external returns (uint256, uint48);

    
    
    
    function getFee(address referrer_) external view returns (uint48);

    
    
    
    function setProtocolFee(uint48 fee_) external;

    
    
    ///                  when using create() to mint bond tokens without using an Auctioneer
    
    function setCreateFeeDiscount(uint48 discount_) external;

    
    
    
    function setReferrerFee(uint48 fee_) external;

    
    
    
    function claimFees(ERC20[] memory tokens_, address to_) external;
}

// 
pragma solidity >=0.8.0;





library TransferHelper {
    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(ERC20.transferFrom.selector, from, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(ERC20.transfer.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(ERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }
}

// 
pragma solidity 0.8.15;






///         It also implements a moving average price calculation (same as a TWAP) on the price feed data over a configured
///         duration and observation frequency. The data provided by this contract is used by the Olympus Range Operator to
///         perform market operations. The Olympus Price Oracle is updated each epoch by the Olympus Heart contract.
abstract contract PRICEv1 is Module {
    // =========  EVENTS ========= //

    event NewObservation(uint256 timestamp_, uint256 price_, uint256 movingAverage_);
    event MovingAverageDurationChanged(uint48 movingAverageDuration_);
    event ObservationFrequencyChanged(uint48 observationFrequency_);
    event UpdateThresholdsChanged(uint48 ohmEthUpdateThreshold_, uint48 reserveEthUpdateThreshold_);
    event MinimumTargetPriceChanged(uint256 minimumTargetPrice_);

    // =========  ERRORS ========= //

    error Price_InvalidParams();
    error Price_NotInitialized();
    error Price_AlreadyInitialized();
    error Price_BadFeed(address priceFeed);

    // =========  STATE ========= //

    
    

    
    AggregatorV2V3Interface public ohmEthPriceFeed;

    
    uint48 public ohmEthUpdateThreshold;

    
    AggregatorV2V3Interface public reserveEthPriceFeed;

    
    uint48 public reserveEthUpdateThreshold;

    
    
    uint256 public cumulativeObs;

    
    
    ///         Observations can be cleared by changing the movingAverageDuration or observationFrequency and must be re-initialized.
    uint256[] public observations;

    
    uint32 public nextObsIndex;

    
    uint32 public numObservations;

    
    uint48 public observationFrequency;

    
    uint48 public movingAverageDuration;

    
    uint48 public lastObservationTime;

    
    bool public initialized;

    
    uint8 public constant decimals = 18;

    
    uint256 public minimumTargetPrice;

    // =========  FUNCTIONS ========= //

    
    
    ///         The Heart beat frequency should be set to the same value as the observationFrequency.
    function updateMovingAverage() external virtual;

    
    
    
    
    
    ///         or movingAverageDuration (in certain cases) in order for the Price module to function properly.
    function initialize(uint256[] memory startObservations_, uint48 lastObservationTime_)
        external
        virtual;

    
    
    
    ///         and require the initialize function to be called again. Ensure that you have saved
    ///         the existing data and can re-populate before calling this function.
    function changeMovingAverageDuration(uint48 movingAverageDuration_) external virtual;

    
    
    
    ///           Ensure that you have saved the existing data and/or can re-populate before calling this function.
    function changeObservationFrequency(uint48 observationFrequency_) external virtual;

    
    
    
    
    function changeUpdateThresholds(
        uint48 ohmEthUpdateThreshold_,
        uint48 reserveEthUpdateThreshold_
    ) external virtual;

    
    
    
    function changeMinimumTargetPrice(uint256 minimumTargetPrice_) external virtual;

    
    function getCurrentPrice() external view virtual returns (uint256);

    
    function getLastPrice() external view virtual returns (uint256);

    
    function getMovingAverage() external view virtual returns (uint256);

    
    
    function getTargetPrice() external view virtual returns (uint256);
}


contract OlympusRoles is ROLESv1 {
    //============================================================================================//
    //                                        MODULE SETUP                                        //
    //============================================================================================//

    constructor(Kernel kernel_) Module(kernel_) {}

    
    function KEYCODE() public pure override returns (Keycode) {
        return toKeycode("ROLES");
    }

    
    function VERSION() external pure override returns (uint8 major, uint8 minor) {
        major = 1;
        minor = 0;
    }

    //============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    //============================================================================================//

    
    function saveRole(bytes32 role_, address addr_) external override permissioned {
        if (hasRole[addr_][role_]) revert ROLES_AddressAlreadyHasRole(addr_, role_);

        ensureValidRole(role_);

        // Grant role to the address
        hasRole[addr_][role_] = true;

        emit RoleGranted(role_, addr_);
    }

    
    function removeRole(bytes32 role_, address addr_) external override permissioned {
        if (!hasRole[addr_][role_]) revert ROLES_AddressDoesNotHaveRole(addr_, role_);

        hasRole[addr_][role_] = false;

        emit RoleRevoked(role_, addr_);
    }

    //============================================================================================//
    //                                       VIEW FUNCTIONS                                       //
    //============================================================================================//

    
    function requireRole(bytes32 role_, address caller_) external view override {
        if (!hasRole[caller_][role_]) revert ROLES_RequireRole(role_);
    }

    
    function ensureValidRole(bytes32 role_) public pure override {
        for (uint256 i = 0; i < 32; ) {
            bytes1 char = role_[i];
            if ((char < 0x61 || char > 0x7A) && char != 0x5f && char != 0x00) {
                revert ROLES_InvalidRole(role_); // a-z only
            }
            unchecked {
                i++;
            }
        }
    }
}

// 
pragma solidity 0.8.15;


















///         Olympus market operations. The Heart orchestrates state updates in the correct order to ensure
///         market operations use up to date information.
contract OlympusHeart is IHeart, Policy, RolesConsumer, ReentrancyGuard {
    using TransferHelper for ERC20;

    // =========  STATE ========= //

    
    bool public active;

    
    uint256 public lastBeat;

    
    uint256 public reward;

    
    ERC20 public rewardToken;

    // Modules
    PRICEv1 internal PRICE;

    // Policies
    IOperator public operator;

    //============================================================================================//
    //                                      POLICY SETUP                                          //
    //============================================================================================//

    constructor(
        Kernel kernel_,
        IOperator operator_,
        ERC20 rewardToken_,
        uint256 reward_
    ) Policy(kernel_) {
        operator = operator_;

        active = true;
        lastBeat = block.timestamp;
        rewardToken = rewardToken_;
        reward = reward_;
    }

    
    function configureDependencies() external override returns (Keycode[] memory dependencies) {
        dependencies = new Keycode[](2);
        dependencies[0] = toKeycode("PRICE");
        dependencies[1] = toKeycode("ROLES");

        PRICE = PRICEv1(getModuleAddress(dependencies[0]));
        ROLES = ROLESv1(getModuleAddress(dependencies[1]));
    }

    
    function requestPermissions()
        external
        view
        override
        returns (Permissions[] memory permissions)
    {
        permissions = new Permissions[](1);
        permissions[0] = Permissions(PRICE.KEYCODE(), PRICE.updateMovingAverage.selector);
    }

    //============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    //============================================================================================//

    
    function beat() external nonReentrant {
        if (!active) revert Heart_BeatStopped();
        if (block.timestamp < lastBeat + frequency()) revert Heart_OutOfCycle();

        // Update the moving average on the Price module
        PRICE.updateMovingAverage();

        // Trigger price range update and market operations
        operator.operate();

        // Update the last beat timestamp
        // Ensure that update frequency doesn't change, but do not allow multiple beats if one is skipped
        lastBeat = block.timestamp - ((block.timestamp - lastBeat) % frequency());

        // Issue reward to sender
        _issueReward(msg.sender);

        emit Beat(block.timestamp);
    }

    function _issueReward(address to_) internal {
        uint256 amount = reward > rewardToken.balanceOf(address(this))
            ? rewardToken.balanceOf(address(this))
            : reward;
        rewardToken.safeTransfer(to_, amount);
        emit RewardIssued(to_, amount);
    }

    //============================================================================================//
    //                                      ADMIN FUNCTIONS                                       //
    //============================================================================================//

    function _resetBeat() internal {
        lastBeat = block.timestamp - frequency();
    }

    
    function resetBeat() external onlyRole("heart_admin") {
        _resetBeat();
    }

    
    function activate() external onlyRole("heart_admin") {
        active = true;
        _resetBeat();
    }

    
    function deactivate() external onlyRole("heart_admin") {
        active = false;
    }

    
    function setOperator(address operator_) external onlyRole("heart_admin") {
        operator = IOperator(operator_);
    }

    modifier notWhileBeatAvailable() {
        // Prevent calling if a beat is available to avoid front-running a keeper
        if (block.timestamp >= lastBeat + frequency()) revert Heart_BeatAvailable();
        _;
    }

    
    function setRewardTokenAndAmount(ERC20 token_, uint256 reward_)
        external
        onlyRole("heart_admin")
        notWhileBeatAvailable
    {
        rewardToken = token_;
        reward = reward_;
        emit RewardUpdated(token_, reward_);
    }

    
    function withdrawUnspentRewards(ERC20 token_)
        external
        onlyRole("heart_admin")
        notWhileBeatAvailable
    {
        token_.safeTransfer(msg.sender, token_.balanceOf(address(this)));
    }

    //============================================================================================//
    //                                       VIEW FUNCTIONS                                       //
    //============================================================================================//

    
    function frequency() public view returns (uint256) {
        return uint256(PRICE.observationFrequency());
    }
}

// 
pragma solidity >=0.8.0;





interface IOperator {
    // =========  EVENTS ========= //

    event Swap(
        ERC20 indexed tokenIn_,
        ERC20 indexed tokenOut_,
        uint256 amountIn_,
        uint256 amountOut_
    );
    event CushionFactorChanged(uint32 cushionFactor_);
    event CushionParamsChanged(uint32 duration_, uint32 debtBuffer_, uint32 depositInterval_);
    event ReserveFactorChanged(uint32 reserveFactor_);
    event RegenParamsChanged(uint32 wait_, uint32 threshold_, uint32 observe_);

    // =========  ERRORS ========= //

    error Operator_InvalidParams();
    error Operator_InsufficientCapacity();
    error Operator_AmountLessThanMinimum(uint256 amountOut, uint256 minAmountOut);
    error Operator_WallDown();
    error Operator_AlreadyInitialized();
    error Operator_NotInitialized();
    error Operator_Inactive();

    // =========  STRUCTS ========== //

    
    struct Config {
        uint32 cushionFactor; // percent of capacity to be used for a single cushion deployment, assumes 2 decimals (i.e. 1000 = 10%)
        uint32 cushionDuration; // duration of a single cushion deployment in seconds
        uint32 cushionDebtBuffer; // Percentage over the initial debt to allow the market to accumulate at any one time. Percent with 3 decimals, e.g. 1_000 = 1 %. See IBondSDA for more info.
        uint32 cushionDepositInterval; // Target frequency of deposits. Determines max payout of the bond market. See IBondSDA for more info.
        uint32 reserveFactor; // percent of reserves in treasury to be used for a single wall, assumes 2 decimals (i.e. 1000 = 10%)
        uint32 regenWait; // minimum duration to wait to reinstate a wall in seconds
        uint32 regenThreshold; // number of price points on other side of moving average to reinstate a wall
        uint32 regenObserve; // number of price points to observe to determine regeneration
    }

    
    struct Status {
        Regen low; // regeneration status for the low side of the range
        Regen high; // regeneration status for the high side of the range
    }

    
    struct Regen {
        uint32 count; // current number of price points that count towards regeneration
        uint48 lastRegen; // timestamp of the last regeneration
        uint32 nextObservation; // index of the next observation in the observations array
        bool[] observations; // individual observations: true = price on other side of average, false = price on same side of average
    }

    // =========  CORE FUNCTIONS ========= //

    
    
    
    function operate() external;

    // =========  OPEN MARKET OPERATIONS (WALL) ========= //

    
    
    ///         - OHM: swap at the low wall price for Reserve
    ///         - Reserve: swap at the high wall price for OHM
    
    
    
    function swap(
        ERC20 tokenIn_,
        uint256 amountIn_,
        uint256 minAmountOut_
    ) external returns (uint256 amountOut);

    
    
    ///         - If OHM: swap at the low wall price for Reserve
    ///         - If Reserve: swap at the high wall price for OHM
    
    
    function getAmountOut(ERC20 tokenIn_, uint256 amountIn_) external view returns (uint256);

    // =========  ADMIN FUNCTIONS ========= //

    
    
    
    
    
    function setSpreads(uint256 cushionSpread_, uint256 wallSpread_) external;

    
    
    
    
    function setThresholdFactor(uint256 thresholdFactor_) external;

    
    
    
    function setCushionFactor(uint32 cushionFactor_) external;

    
    
    
    
    
    function setCushionParams(
        uint32 duration_,
        uint32 debtBuffer_,
        uint32 depositInterval_
    ) external;

    
    
    
    function setReserveFactor(uint32 reserveFactor_) external;

    
    
    
    
    
    
    function setRegenParams(
        uint32 wait_,
        uint32 threshold_,
        uint32 observe_
    ) external;

    
    
    
    
    function setBondContracts(IBondSDA auctioneer_, IBondCallback callback_) external;

    
    
    
    
    function initialize() external;

    
    
    
    
    function regenerate(bool high_) external;

    
    
    
    function deactivate() external;

    
    
    
    function activate() external;

    
    
    
    
    function deactivateCushion(bool high_) external;

    // =========  VIEW FUNCTIONS ========= //

    
    
    
    function fullCapacity(bool high_) external view returns (uint256);

    
    function status() external view returns (Status memory);

    
    function config() external view returns (Config memory);
}