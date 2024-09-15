// SPDX-License-Identifier: MIT


//
pragma solidity >=0.8.0;







interface ILockGTON {
    
    function owner() external view returns (address);

    
    
    function setOwner(address _owner) external;

    
    function canLock() external view returns (bool);

    
    function setCanLock(bool _canLock) external;

    
    function governanceToken() external view returns (IERC20);

    
    function migrate(address newLock) external;

    
    function lock(address receiver, uint256 amount) external;

    
    
    
    event SetOwner(address indexed ownerOld, address indexed ownerNew);

    
    
    /// from the lp-token locking event when parsed by the oracle parser
    
    
    /// as the lp-token locking event when parsed by the oracle parser
    
    
    
    event LockGTON(
        address indexed governanceToken,
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );

    
    
    
    event SetCanLock(
        address indexed owner,
        bool indexed newBool
    );

    
    
    
    event Migrate(address indexed newLock, uint amount);
}
//
pragma solidity >=0.8.0;






contract LockGTON is ILockGTON {

    
    address public override owner;

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    
    IERC20 public override governanceToken;

    
    bool public override canLock;

    constructor(IERC20 _governanceToken) {
        owner = msg.sender;
        governanceToken = _governanceToken;
    }

    
    function setOwner(address _owner) external override isOwner {
        address ownerOld = owner;
        owner = _owner;
        emit SetOwner(ownerOld, _owner);
    }

    
    function setCanLock(bool _canLock) external override isOwner {
        canLock = _canLock;
        emit SetCanLock(owner, _canLock);
    }

    
    function migrate(address newLock)
        external
        override
        isOwner
    {
        uint amount = governanceToken.balanceOf(address(this));
        governanceToken.transfer(newLock, amount);
        emit Migrate(newLock, amount);
    }

    
    function lock(address receiver, uint256 amount) external override {
        require(canLock, "lock is not allowed");
        governanceToken.transferFrom(msg.sender, address(this), amount);
        emit LockGTON(address(governanceToken), msg.sender, receiver, amount);
    }
}

// 
pragma solidity >=0.8.0;

interface IERC20 {
    function mint(address _to, uint256 _value) external;

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function balanceOf(address _owner) external view returns (uint256 balance);
}
