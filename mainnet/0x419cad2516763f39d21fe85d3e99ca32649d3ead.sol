
/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity ^0.4.11;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

contract Token {

    
    function totalSupply() constant returns (uint supply) {}

    
    
    function balanceOf(address _owner) constant returns (uint balance) {}

    
    
    
    
    function transfer(address _to, uint _value) returns (bool success) {}

    
    
    
    
    
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint _value) returns (bool success) {}

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}

    /// Event for a successful transfer.
    event Transfer(address indexed _from, address indexed _to, uint _value);

    /// Event for a successful Approval.
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}




/// For more information, please visit https://loopring.org.
contract LRCMidTermHoldingContract {
    using SafeMath for uint;

    address public lrcTokenAddress  = 0x0;
    address public owner            = 0x0;
    uint    public rate             = 7500; 

    // Some stats
    uint public lrcReceived         = 0;
    uint public lrcSent             = 0;
    uint public ethReceived         = 0;
    uint public ethSent             = 0;

    mapping (address => uint) lrcBalances; // each user's lrc balance
    
    /* 
     * EVENTS
     */
    /// Emitted for each sucuessful deposit.
    uint public depositId = 0;
    event Deposit(uint _depositId, address _addr, uint _ethAmount, uint _lrcAmount);

    /// Emitted for each sucuessful withdrawal.
    uint public withdrawId = 0;
    event Withdrawal(uint _withdrawId, address _addr, uint _ethAmount, uint _lrcAmount);

    /// Emitted when ETH are drained and LRC are drained by owner.
    event Drained(uint _ethAmount, uint _lrcAmount);

    /// Emitted when rate changed by owner.
    event RateChanged(uint _oldRate, uint _newRate);

    /// CONSTRUCTOR 
    
    
    
    function LRCMidTermHoldingContract(address _lrcTokenAddress, address _owner) {
        require(_lrcTokenAddress != 0x0);
        require(_owner != 0x0);

        lrcTokenAddress = _lrcTokenAddress;
        owner = _owner;
    }

    /*
     * PUBLIC FUNCTIONS
     */
    
    
    function setRate(uint _rate) public  {
        require(msg.sender == owner);
        require(rate > 0);
        
        RateChanged(rate, _rate);
        rate = _rate;
    }

    
    
    function drain(uint _ethAmount) public payable {
        require(msg.sender == owner);
        require(_ethAmount >= 0);
        
        uint ethAmount = _ethAmount.min256(this.balance);
        if (ethAmount > 0){
            require(owner.send(ethAmount));
        }

        var lrcToken = Token(lrcTokenAddress);
        uint lrcAmount = lrcToken.balanceOf(address(this)) - lrcReceived + lrcSent;
        if (lrcAmount > 0){
            require(lrcToken.transfer(owner, lrcAmount));
        }

        Drained(ethAmount, lrcAmount);
    }

    
    function () payable {
        if (msg.sender != owner) {
            if (msg.value == 0) depositLRC();
            else withdrawLRC();
        }
    }

  
    
    /// If user send x ETH, this method will try to transfer `x * 100 * 6500` LRC from
    /// the user's address and send `x * 100` ETH to the user.
    function depositLRC() payable {
        require(msg.sender != owner);
        require(msg.value == 0);

        var lrcToken = Token(lrcTokenAddress);

        uint lrcAmount = this.balance.mul(rate)
            .min256(lrcToken.balanceOf(msg.sender))
            .min256(lrcToken.allowance(msg.sender, address(this)));

        uint ethAmount = lrcAmount.div(rate);

        require(lrcAmount > 0 && ethAmount > 0);
        require(ethAmount.mul(rate) <= lrcAmount);

        lrcBalances[msg.sender] += lrcAmount;

        lrcReceived += lrcAmount;
        ethSent += ethAmount;

        require(lrcToken.transferFrom(msg.sender, address(this), lrcAmount));
        require(msg.sender.send(ethAmount));

        Deposit(
             depositId++,
             msg.sender,
             ethAmount,
             lrcAmount
        );      
    }

    
    function withdrawLRC() payable {
        require(msg.sender != owner);
        require(msg.value > 0);

        uint lrcAmount = msg.value.mul(rate)
            .min256(lrcBalances[msg.sender]);

        uint ethAmount = lrcAmount.div(rate);

        require(lrcAmount > 0 && ethAmount > 0);

        lrcBalances[msg.sender] -= lrcAmount;

        lrcSent += lrcAmount;
        ethReceived += ethAmount;

        require(Token(lrcTokenAddress).transfer(msg.sender, lrcAmount));

        uint ethRefund = msg.value - ethAmount;
        if (ethRefund > 0) {
            require(msg.sender.send(ethRefund));
        }

        Withdrawal(
             withdrawId++,
             msg.sender,
             ethAmount,
             lrcAmount
        ); 
    }
}