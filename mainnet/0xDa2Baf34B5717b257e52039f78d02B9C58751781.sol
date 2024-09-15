// SPDX-License-Identifier: Apache-2.0


// 
pragma solidity >=0.7.0;

contract Authorizable {
    // This contract allows a flexible authorization scheme

    // The owner who can change authorization status
    address public owner;
    // A mapping from an address to its authorization status
    mapping(address => bool) public authorized;

    
    constructor() {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender not owner");
        _;
    }

    
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    
    
    
    function isAuthorized(address who) public view returns (bool) {
        return authorized[who];
    }

    
    
    function authorize(address who) external onlyOwner() {
        _authorize(who);
    }

    
    
    function deauthorize(address who) external onlyOwner() {
        authorized[who] = false;
    }

    
    
    function setOwner(address who) public onlyOwner() {
        owner = who;
    }

    
    
    function _authorize(address who) internal {
        authorized[who] = true;
    }
}
// 
pragma solidity ^0.8.3;




// Has governance tokens provided by the treasury, can execute calls to spend them
// Three separate functions which all spending different amounts. We enforce
// spending limit by block so that no governance proposal can execute a bundle
// of small spend transactions with low quorum.

contract Spender is Authorizable {
    // Mapping storing how much is spent in each block
    // Note - There's minor stability and griefing considerations around tracking the expenditure
    //        per block for all spend limits. Namely two proposals may try to get executed in the same block and have one
    //        fail on accident or on purpose. These are for semi-rare non contentious spending so
    //        we do not consider either a major concern.
    mapping(uint256 => uint256) public blockExpenditure;
    // The low, medium and high spending barriers
    uint256 public smallSpendLimit;
    uint256 public mediumSpendLimit;
    uint256 public highSpendLimit;
    // The immutable token contract
    IERC20 public immutable token;

    
    
    
    
    
    
    
    constructor(
        address _owner,
        address _spender,
        IERC20 _token,
        uint256 _smallSpendLimit,
        uint256 _mediumSpendLimit,
        uint256 _highSpendLimit
    ) {
        // Configure access controls, by authorizing the spender and setting the owner.
        _authorize(_spender);
        setOwner(_owner);
        // Set state and immutable variables
        token = _token;
        smallSpendLimit = _smallSpendLimit;
        mediumSpendLimit = _mediumSpendLimit;
        highSpendLimit = _highSpendLimit;
    }

    
    
    
    function smallSpend(uint256 amount, address destination)
        external
        onlyAuthorized
    {
        _spend(amount, destination, smallSpendLimit);
    }

    
    
    
    function mediumSpend(uint256 amount, address destination)
        external
        onlyAuthorized
    {
        _spend(amount, destination, mediumSpendLimit);
    }

    
    
    
    function highSpend(uint256 amount, address destination)
        external
        onlyAuthorized
    {
        _spend(amount, destination, highSpendLimit);
    }

    
    
    
    
    function _spend(
        uint256 amount,
        address destination,
        uint256 limit
    ) internal {
        // Check that after processing this we will not have spent more than the block limit
        uint256 spentThisBlock = blockExpenditure[block.number];
        require(amount + spentThisBlock <= limit, "Spend Limit Exceeded");
        // Reentrancy is very unlikely in this context, but we still change state first
        blockExpenditure[block.number] = amount + spentThisBlock;
        // Transfer tokens
        token.transfer(destination, amount);
    }

    
    
    
    ///      of the other two must be provided to this call.
    function setLimits(uint256[] memory limits) external onlyOwner {
        // Set the spend limits
        smallSpendLimit = limits[0];
        mediumSpendLimit = limits[1];
        highSpendLimit = limits[2];
    }

    
    ///         out of this contract.
    
    
    function removeToken(uint256 amount, address destination)
        external
        onlyOwner
    {
        // If they use max then we just transfer out the balance
        if (amount == type(uint256).max) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(destination, amount);
    }
}

// 
pragma solidity ^0.8.3;

interface IERC20 {
    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    // Note this is non standard but nearly all ERC20 have exposed decimal functions
    function decimals() external view returns (uint8);

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}