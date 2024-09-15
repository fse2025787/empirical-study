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




// This contract is designed to hold the erc20 and eth reserves of the dao
// and will likely control a large amount of funds. It is designed to be
// flexible, secure and simple
contract Treasury is Authorizable {
    // A constant which represents ether
    address internal constant _ETH_CONSTANT =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    
    
    constructor(address __governance) {
        setOwner(__governance);
    }

    
    
    /// or (2) the _ETH_CONSTANT to use transfer ETH.
    
    
    function sendFunds(
        address _token,
        uint256 _amount,
        address _recipient
    ) external onlyOwner {
        if (_token == _ETH_CONSTANT) {
            payable(_recipient).transfer(_amount);
        } else {
            // onlyGovernance should protect from reentrancy
            IERC20(_token).transfer(_recipient, _amount);
        }
    }

    
    
    
    
    function approve(
        address _token,
        address _spender,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_token).approve(_spender, _amount);
    }

    
    
    
    function genericCall(address _target, bytes calldata _callData)
        external
        onlyOwner
    {
        // We do a low level call and insist it succeeds
        (bool status, ) = _target.call(_callData);
        require(status, "Call failed");
    }

    // Receive is fine because we don't want to execute code
    receive() external payable {}
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