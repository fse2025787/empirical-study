
/**
 *Submitted for verification at Etherscan.io on 2022-03-01
*/

// File contracts/SwapAndPay.sol

pragma solidity 0.8.10;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IRouter {
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
}



contract SwapAndPay {

    ///STATE VARIABLES///

    
    uint public ethPayed;

    
    address immutable public owner;

    
    address immutable public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    
    mapping(address => uint) public addressToPaid;

    
    mapping(address => uint) public tokensSwaped;

    /// CONSTRUCTOR ///
    
    
    constructor (address _owner) {
        owner = _owner;
    }

    /// OWNER FUNCTION ///

    
    
    
    
    
    
    function swapAndPay(
        address payable _payee,
        address _router,
        address _token,
        uint _amount,
        uint _minETH
    ) external {
        require(msg.sender == owner, "not owner");

        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = WETH;

        IERC20(_token).approve(_router, _amount);

        IRouter(_router).swapExactTokensForETH(_amount, _minETH, path, address(this), block.timestamp + 10);
        
        ethPayed += address(this).balance;
        addressToPaid[_payee] += address(this).balance;
        tokensSwaped[_token] += _amount;

        _payee.transfer(address(this).balance);
    }
}