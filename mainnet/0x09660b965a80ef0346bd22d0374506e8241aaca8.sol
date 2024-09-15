
/**
 *Submitted for verification at Etherscan.io on 2021-12-29
*/

// File: contracts/Token.sol


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
pragma solidity ^0.6.0;


abstract contract Token {
    /*
     *  Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     *  Public functions
     */
    function transfer(address to, uint value) public virtual returns (bool);
    function transferFrom(address from, address to, uint value) public virtual returns (bool);
    function approve(address spender, uint value) public virtual returns (bool);
    function balanceOf(address owner) public virtual view returns (uint);
    function allowance(address owner, address spender) public virtual view returns (uint);
    function totalSupply() public virtual view returns (uint);
}


// File: contracts/disbursement.sol

//pragma solidity ^0.6.0;





contract Disbursement {

    /*
     *  Storage
     */
    address public receiver;
    address public wallet;
    uint public disbursementPeriod;
    uint public startDate;
    uint public withdrawnTokens;
    Token public token;

    /*
     *  Modifiers
     */
    modifier isReceiver() {
        if (msg.sender != receiver)
            revert("Only receiver is allowed to proceed");
        _;
    }

    modifier isWallet() {
        if (msg.sender != wallet)
            revert("Only wallet is allowed to proceed");
        _;
    }

    /*
     *  Public functions
     */
    
    
    
    
    
    
    constructor(address _receiver, address _wallet, uint _disbursementPeriod, uint _startDate, Token _token)
        public
    {
        if (_receiver == address(0) || _wallet == address(0) || _disbursementPeriod == 0 || address(_token) == address(0))
            revert("Arguments are null");
        receiver = _receiver;
        wallet = _wallet;
        disbursementPeriod = _disbursementPeriod;
        startDate = _startDate;
        token = _token;
        if (startDate == 0){
          startDate = now;
        }
    }

    
    
    
    function withdraw(address _to, uint256 _value)
        public
        isReceiver
    {
        uint maxTokens = calcMaxWithdraw();
        if (_value > maxTokens){
          revert("Withdraw amount exceeds allowed tokens");
        }
        withdrawnTokens += _value;
        token.transfer(_to, _value);
    }

    
    function walletWithdraw()
        public
        isWallet
    {
        uint balance = token.balanceOf(address(this));
        withdrawnTokens += balance;
        token.transfer(wallet, balance);
    }

    
    
    function calcMaxWithdraw()
        public
        view
        returns (uint)
    {
        uint maxTokens = (token.balanceOf(address(this)) + withdrawnTokens) * (now - startDate) / disbursementPeriod;
        if (withdrawnTokens >= maxTokens || startDate > now){
          return 0;
        }
        return maxTokens - withdrawnTokens;
    }
}