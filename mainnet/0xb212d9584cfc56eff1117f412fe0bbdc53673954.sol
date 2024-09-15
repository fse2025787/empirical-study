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
pragma solidity 0.8.15;




abstract contract RANGEv1 is Module {
    // =========  EVENTS ========= //

    event WallUp(bool high_, uint256 timestamp_, uint256 capacity_);
    event WallDown(bool high_, uint256 timestamp_, uint256 capacity_);
    event CushionUp(bool high_, uint256 timestamp_, uint256 capacity_);
    event CushionDown(bool high_, uint256 timestamp_);
    event PricesChanged(
        uint256 wallLowPrice_,
        uint256 cushionLowPrice_,
        uint256 cushionHighPrice_,
        uint256 wallHighPrice_
    );
    event SpreadsChanged(uint256 cushionSpread_, uint256 wallSpread_);
    event ThresholdFactorChanged(uint256 thresholdFactor_);

    // =========  ERRORS ========= //

    error RANGE_InvalidParams();

    // =========  STATE ========= //

    struct Line {
        uint256 price; // Price for the specified level
    }

    struct Band {
        Line high; // Price of the high side of the band
        Line low; // Price of the low side of the band
        uint256 spread; // Spread of the band (increase/decrease from the moving average to set the band prices), percent with 2 decimal places (i.e. 1000 = 10% spread)
    }

    struct Side {
        bool active; // Whether or not the side is active (i.e. the Operator is performing market operations on this side, true = active, false = inactive)
        uint48 lastActive; // Unix timestamp when the side was last active (in seconds)
        uint256 capacity; // Amount of tokens that can be used to defend the side of the range. Specified in OHM tokens on the high side and Reserve tokens on the low side.
        uint256 threshold; // Minimum number of tokens required in capacity to maintain an active side. Specified in OHM tokens on the high side and Reserve tokens on the low side.
        uint256 market; // Market ID of the cushion bond market for the side. If no market is active, the market ID is set to max uint256 value.
    }

    struct Range {
        Side low; // Data specific to the low side of the range
        Side high; // Data specific to the high side of the range
        Band cushion; // Data relevant to cushions on both sides of the range
        Band wall; // Data relevant to walls on both sides of the range
    }

    // Range data singleton. See range().
    Range internal _range;

    
    
    uint256 public thresholdFactor;

    
    ERC20 public ohm;

    
    ERC20 public reserve;

    // =========  FUNCTIONS ========= //

    
    
    
    
    function updateCapacity(bool high_, uint256 capacity_) external virtual;

    
    
    
    function updatePrices(uint256 movingAverage_) external virtual;

    
    
    
    
    function regenerate(bool high_, uint256 capacity_) external virtual;

    
    
    
    
    
    function updateMarket(
        bool high_,
        uint256 market_,
        uint256 marketCapacity_
    ) external virtual;

    
    
    
    
    
    function setSpreads(uint256 cushionSpread_, uint256 wallSpread_) external virtual;

    
    
    
    
    function setThresholdFactor(uint256 thresholdFactor_) external virtual;

    
    function range() external view virtual returns (Range memory);

    
    
    function capacity(bool high_) external view virtual returns (uint256);

    
    
    function active(bool high_) external view virtual returns (bool);

    
    
    
    function price(bool wall_, bool high_) external view virtual returns (uint256);

    
    
    function spread(bool wall_) external view virtual returns (uint256);

    
    
    function market(bool high_) external view virtual returns (uint256);

    
    
    function lastActive(bool high_) external view virtual returns (uint256);
}// 
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

// 
pragma solidity 0.8.15;







///         It provides a standard interface for Range data, including range prices and capacities of each range side.
///         The data provided by this contract is used by the Olympus Range Operator to perform market operations.
///         The Olympus Range Data is updated each epoch by the Olympus Range Operator contract.
contract OlympusRange is RANGEv1 {
    uint256 public constant ONE_HUNDRED_PERCENT = 100e2;
    uint256 public constant ONE_PERCENT = 1e2;

    //============================================================================================//
    //                                        MODULE SETUP                                        //
    //============================================================================================//

    constructor(
        Kernel kernel_,
        ERC20 ohm_,
        ERC20 reserve_,
        uint256 thresholdFactor_,
        uint256 cushionSpread_,
        uint256 wallSpread_
    ) Module(kernel_) {
        // Validate parameters
        if (
            wallSpread_ >= ONE_HUNDRED_PERCENT ||
            wallSpread_ < ONE_PERCENT ||
            cushionSpread_ >= ONE_HUNDRED_PERCENT ||
            cushionSpread_ < ONE_PERCENT ||
            cushionSpread_ > wallSpread_ ||
            thresholdFactor_ >= ONE_HUNDRED_PERCENT ||
            thresholdFactor_ < ONE_PERCENT
        ) revert RANGE_InvalidParams();

        _range = Range({
            low: Side({
                active: false,
                lastActive: uint48(block.timestamp),
                capacity: 0,
                threshold: 0,
                market: type(uint256).max
            }),
            high: Side({
                active: false,
                lastActive: uint48(block.timestamp),
                capacity: 0,
                threshold: 0,
                market: type(uint256).max
            }),
            cushion: Band({low: Line({price: 0}), high: Line({price: 0}), spread: cushionSpread_}),
            wall: Band({low: Line({price: 0}), high: Line({price: 0}), spread: wallSpread_})
        });

        thresholdFactor = thresholdFactor_;
        ohm = ohm_;
        reserve = reserve_;

        emit SpreadsChanged(cushionSpread_, wallSpread_);
        emit ThresholdFactorChanged(thresholdFactor_);
    }

    
    function KEYCODE() public pure override returns (Keycode) {
        return toKeycode("RANGE");
    }

    
    function VERSION() external pure override returns (uint8 major, uint8 minor) {
        major = 1;
        minor = 0;
    }

    //============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    //============================================================================================//

    
    function updateCapacity(bool high_, uint256 capacity_) external override permissioned {
        if (high_) {
            // Update capacity
            _range.high.capacity = capacity_;

            // If the new capacity is below the threshold, deactivate the wall if they are currently active
            if (capacity_ < _range.high.threshold && _range.high.active) {
                // Set wall to inactive
                _range.high.active = false;
                _range.high.lastActive = uint48(block.timestamp);

                emit WallDown(true, block.timestamp, capacity_);
            }
        } else {
            // Update capacity
            _range.low.capacity = capacity_;

            // If the new capacity is below the threshold, deactivate the wall if they are currently active
            if (capacity_ < _range.low.threshold && _range.low.active) {
                // Set wall to inactive
                _range.low.active = false;
                _range.low.lastActive = uint48(block.timestamp);

                emit WallDown(false, block.timestamp, capacity_);
            }
        }
    }

    
    function updatePrices(uint256 movingAverage_) external override permissioned {
        // Cache the spreads
        uint256 wallSpread = _range.wall.spread;
        uint256 cushionSpread = _range.cushion.spread;

        // Calculate new wall and cushion values from moving average and spread
        _range.wall.low.price =
            (movingAverage_ * (ONE_HUNDRED_PERCENT - wallSpread)) /
            ONE_HUNDRED_PERCENT;
        _range.wall.high.price =
            (movingAverage_ * (ONE_HUNDRED_PERCENT + wallSpread)) /
            ONE_HUNDRED_PERCENT;

        _range.cushion.low.price =
            (movingAverage_ * (ONE_HUNDRED_PERCENT - cushionSpread)) /
            ONE_HUNDRED_PERCENT;
        _range.cushion.high.price =
            (movingAverage_ * (ONE_HUNDRED_PERCENT + cushionSpread)) /
            ONE_HUNDRED_PERCENT;

        emit PricesChanged(
            _range.wall.low.price,
            _range.cushion.low.price,
            _range.cushion.high.price,
            _range.wall.high.price
        );
    }

    
    function regenerate(bool high_, uint256 capacity_) external override permissioned {
        uint256 threshold = (capacity_ * thresholdFactor) / ONE_HUNDRED_PERCENT;

        if (high_) {
            // Re-initialize the high side
            _range.high = Side({
                active: true,
                lastActive: uint48(block.timestamp),
                capacity: capacity_,
                threshold: threshold,
                market: _range.high.market
            });
        } else {
            // Reinitialize the low side
            _range.low = Side({
                active: true,
                lastActive: uint48(block.timestamp),
                capacity: capacity_,
                threshold: threshold,
                market: _range.low.market
            });
        }

        emit WallUp(high_, block.timestamp, capacity_);
    }

    
    function updateMarket(
        bool high_,
        uint256 market_,
        uint256 marketCapacity_
    ) public override permissioned {
        // If market id is max uint256, then marketCapacity must be 0
        if (market_ == type(uint256).max && marketCapacity_ != 0) revert RANGE_InvalidParams();

        // Store updated state
        if (high_) {
            _range.high.market = market_;
        } else {
            _range.low.market = market_;
        }

        if (market_ == type(uint256).max) {
            emit CushionDown(high_, block.timestamp);
        } else {
            emit CushionUp(high_, block.timestamp, marketCapacity_);
        }
    }

    
    function setSpreads(uint256 cushionSpread_, uint256 wallSpread_)
        external
        override
        permissioned
    {
        // Confirm spreads are within allowed values
        if (
            wallSpread_ >= ONE_HUNDRED_PERCENT ||
            wallSpread_ < ONE_PERCENT ||
            cushionSpread_ >= ONE_HUNDRED_PERCENT ||
            cushionSpread_ < ONE_PERCENT ||
            cushionSpread_ > wallSpread_
        ) revert RANGE_InvalidParams();

        // Set spreads
        _range.wall.spread = wallSpread_;
        _range.cushion.spread = cushionSpread_;

        emit SpreadsChanged(cushionSpread_, wallSpread_);
    }

    
    function setThresholdFactor(uint256 thresholdFactor_) external override permissioned {
        if (thresholdFactor_ >= ONE_HUNDRED_PERCENT || thresholdFactor_ < ONE_PERCENT)
            revert RANGE_InvalidParams();
        thresholdFactor = thresholdFactor_;

        emit ThresholdFactorChanged(thresholdFactor_);
    }

    //============================================================================================//
    //                                      VIEW FUNCTIONS                                        //
    //============================================================================================//

    
    function range() external view override returns (Range memory) {
        return _range;
    }

    
    function capacity(bool high_) external view override returns (uint256) {
        if (high_) {
            return _range.high.capacity;
        } else {
            return _range.low.capacity;
        }
    }

    
    function active(bool high_) external view override returns (bool) {
        if (high_) {
            return _range.high.active;
        } else {
            return _range.low.active;
        }
    }

    
    function price(bool wall_, bool high_) external view override returns (uint256) {
        if (wall_) {
            if (high_) {
                return _range.wall.high.price;
            } else {
                return _range.wall.low.price;
            }
        } else {
            if (high_) {
                return _range.cushion.high.price;
            } else {
                return _range.cushion.low.price;
            }
        }
    }

    
    function spread(bool wall_) external view override returns (uint256) {
        if (wall_) {
            return _range.wall.spread;
        } else {
            return _range.cushion.spread;
        }
    }

    
    function market(bool high_) external view override returns (uint256) {
        if (high_) {
            return _range.high.market;
        } else {
            return _range.low.market;
        }
    }

    
    function lastActive(bool high_) external view override returns (uint256) {
        if (high_) {
            return _range.high.lastActive;
        } else {
            return _range.low.lastActive;
        }
    }
}
