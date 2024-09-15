// SPDX-License-Identifier: Unlicense


// 
pragma solidity >=0.8.4;




interface IPRBProxy {
    /// EVENTS ///

    event Execute(address indexed target, bytes data, bytes response);

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    /// contract and function selector.
    function getPermission(
        address envoy,
        address target,
        bytes4 selector
    ) external view returns (bool);

    
    function owner() external view returns (address);

    
    
    function minGasReserve() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    /// including when the contract call reverts with a reason or custom error.
    ///
    
    /// - The caller must be either an owner or an envoy.
    /// - `target` must be a deployed contract.
    /// - The owner cannot be changed during the DELEGATECALL.
    ///
    
    
    
    function execute(address target, bytes calldata data) external payable returns (bytes memory response);

    
    /// on behalf of the owner.
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    
    
    
    function setPermission(
        address envoy,
        address target,
        bytes4 selector,
        bool permission
    ) external;

    
    
    /// - The caller must be the owner.
    
    function transferOwnership(address newOwner) external;
}

// 
pragma solidity >=0.8.4;




interface IPRBProxyFactory {
    /// EVENTS ///

    event DeployProxy(
        address indexed origin,
        address indexed deployer,
        address indexed owner,
        bytes32 seed,
        bytes32 salt,
        address proxy
    );

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    
    function getNextSeed(address eoa) external view returns (bytes32 result);

    
    
    function isProxy(address proxy) external view returns (bool result);

    
    
    function version() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    
    
    function deploy() external returns (address payable proxy);

    
    
    
    function deployFor(address owner) external returns (address payable proxy);
}
// 
pragma solidity >=0.8.4;







contract PRBProxyFactory is IPRBProxyFactory {
    /// PUBLIC STORAGE ///

    
    uint256 public constant override version = 2;

    /// INTERNAL STORAGE ///

    
    mapping(address => bool) internal proxies;

    
    mapping(address => bytes32) internal nextSeeds;

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function getNextSeed(address eoa) external view override returns (bytes32 nextSeed) {
        nextSeed = nextSeeds[eoa];
    }

    
    function isProxy(address proxy) external view override returns (bool result) {
        result = proxies[proxy];
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function deploy() external override returns (address payable proxy) {
        proxy = deployFor(msg.sender);
    }

    
    function deployFor(address owner) public override returns (address payable proxy) {
        bytes32 seed = nextSeeds[tx.origin];

        // Prevent front-running the salt by hashing the concatenation of "tx.origin" and the user-provided seed.
        bytes32 salt = keccak256(abi.encode(tx.origin, seed));

        // Deploy the proxy with CREATE2.
        proxy = payable(new PRBProxy{ salt: salt }());

        // Transfer the ownership from this factory contract to the specified owner.
        IPRBProxy(proxy).transferOwnership(owner);

        // Mark the proxy as deployed.
        proxies[proxy] = true;

        // Increment the seed.
        unchecked {
            nextSeeds[tx.origin] = bytes32(uint256(seed) + 1);
        }

        // Log the proxy via en event.
        emit DeployProxy(tx.origin, msg.sender, owner, seed, salt, address(proxy));
    }
}

// 
pragma solidity >=0.8.4;




error PRBProxy__ExecutionNotAuthorized(address owner, address caller, address target, bytes4 selector);


error PRBProxy__ExecutionReverted();


error PRBProxy__NotOwner(address owner, address caller);


error PRBProxy__OwnerChanged(address originalOwner, address newOwner);


error PRBProxy__TargetInvalid(address target);



contract PRBProxy is IPRBProxy {
    /// PUBLIC STORAGE ///

    
    address public override owner;

    
    uint256 public override minGasReserve;

    /// INTERNAL STORAGE ///

    
    mapping(address => mapping(address => mapping(bytes4 => bool))) internal permissions;

    /// CONSTRUCTOR ///

    constructor() {
        minGasReserve = 5_000;
        owner = msg.sender;
        emit TransferOwnership(address(0), msg.sender);
    }

    /// FALLBACK FUNCTION ///

    
    receive() external payable {}

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function getPermission(
        address envoy,
        address target,
        bytes4 selector
    ) external view override returns (bool) {
        return permissions[envoy][target][selector];
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function execute(address target, bytes calldata data) external payable override returns (bytes memory response) {
        // Check that the caller is either the owner or an envoy.
        if (owner != msg.sender) {
            bytes4 selector;
            assembly {
                selector := calldataload(data.offset)
            }
            if (!permissions[msg.sender][target][selector]) {
                revert PRBProxy__ExecutionNotAuthorized(owner, msg.sender, target, selector);
            }
        }

        // Check that the target is a valid contract.
        if (target.code.length == 0) {
            revert PRBProxy__TargetInvalid(target);
        }

        // Save the owner address in memory. This local variable cannot be modified during the DELEGATECALL.
        address owner_ = owner;

        // Reserve some gas to ensure that the function has enough to finish the execution.
        uint256 stipend = gasleft() - minGasReserve;

        // Delegate call to the target contract.
        bool success;
        (success, response) = target.delegatecall{ gas: stipend }(data);

        // Check that the owner has not been changed.
        if (owner_ != owner) {
            revert PRBProxy__OwnerChanged(owner_, owner);
        }

        // Log the execution.
        emit Execute(target, data, response);

        // Check if the call was successful or not.
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error.
            if (response.length > 0) {
                assembly {
                    let returndata_size := mload(response)
                    revert(add(32, response), returndata_size)
                }
            } else {
                revert PRBProxy__ExecutionReverted();
            }
        }
    }

    
    function setPermission(
        address envoy,
        address target,
        bytes4 selector,
        bool permission
    ) external override {
        if (owner != msg.sender) {
            revert PRBProxy__NotOwner(owner, msg.sender);
        }
        permissions[envoy][target][selector] = permission;
    }

    
    function transferOwnership(address newOwner) external override {
        address oldOwner = owner;
        if (oldOwner != msg.sender) {
            revert PRBProxy__NotOwner(oldOwner, msg.sender);
        }
        owner = newOwner;
        emit TransferOwnership(oldOwner, newOwner);
    }
}