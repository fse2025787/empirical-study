// SPDX-License-Identifier: MIT


//
pragma solidity >=0.8.0;







interface ILockUnlockLP {
    
    function owner() external view returns (address);

    
    
    function setOwner(address _owner) external;

    
    function canLock() external view returns (bool);

    
    function setCanLock(bool _canLock) external;

    
    function isAllowedToken(address token) external view returns (bool);

    
    function lockLimit(address token) external view returns (uint256);

    
    function setLockLimit(address token, uint256 _lockLimit) external;

    
    function tokenSupply(address token) external view returns (uint256);

    
    function totalSupply() external view returns (uint256);

    
    function setIsAllowedToken(address token, bool _isAllowedToken) external;

    
    function balance(address token, address depositer)
        external
        view
        returns (uint256);

    
    function lock(address token, uint256 amount) external;

    
    function unlock(address token, uint256 amount) external;

    
    
    
    event SetOwner(address indexed ownerOld, address indexed ownerNew);

    
    
    
    
    
    
    event Lock(
        address indexed token,
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );

    
    
    
    
    
    
    event Unlock(
        address indexed token,
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );

    
    
    
    
    event SetIsAllowedToken(
        address indexed owner,
        address indexed token,
        bool indexed newBool
    );

    
    
    
    
    event SetLockLimit(
        address indexed owner,
        address indexed token,
        uint256 indexed _lockLimit
    );

    
    
    
    event SetCanLock(address indexed owner, bool indexed newBool);
}
//
pragma solidity >=0.8.0;






contract LockUnlockLP is ILockUnlockLP {
    
    address public override owner;

    modifier isOwner() {
        require(msg.sender == owner, "ACW");
        _;
    }

    
    mapping(address => bool) public override isAllowedToken;
    
    mapping(address => uint256) public override lockLimit;
    mapping(address => mapping(address => uint256)) internal _balance;
    
    mapping(address => uint256) public override tokenSupply;
    
    uint256 public override totalSupply;

    
    bool public override canLock;

    constructor(address[] memory allowedTokens) {
        owner = msg.sender;
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            isAllowedToken[allowedTokens[i]] = true;
        }
    }

    
    function setOwner(address _owner) external override isOwner {
        address ownerOld = owner;
        owner = _owner;
        emit SetOwner(ownerOld, _owner);
    }

    
    function setIsAllowedToken(address token, bool _isAllowedToken)
        external
        override
        isOwner
    {
        isAllowedToken[token] = _isAllowedToken;
        emit SetIsAllowedToken(owner, token, _isAllowedToken);
    }

    
    function setLockLimit(address token, uint256 _lockLimit)
        external
        override
        isOwner
    {
        lockLimit[token] = _lockLimit;
        emit SetLockLimit(owner, token, _lockLimit);
    }

    
    function setCanLock(bool _canLock) external override isOwner {
        canLock = _canLock;
        emit SetCanLock(owner, _canLock);
    }

    
    function balance(address token, address depositer)
        external
        view
        override
        returns (uint256)
    {
        return _balance[token][depositer];
    }

    
    function lock(address token, uint256 amount) external override {
        require(canLock, "LP1");
        require(isAllowedToken[token], "LP2");
        require(amount >= lockLimit[token], "LP3");
        _balance[token][msg.sender] += amount;
        tokenSupply[token] += amount;
        totalSupply += amount;
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Lock(token, msg.sender, msg.sender, amount);
    }

    
    function unlock(address token, uint256 amount) external override {
        require(_balance[token][msg.sender] >= amount, "LP4");
        _balance[token][msg.sender] -= amount;
        tokenSupply[token] -= amount;
        totalSupply -= amount;
        IERC20(token).transfer(msg.sender, amount);
        emit Unlock(token, msg.sender, msg.sender, amount);
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
