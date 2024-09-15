
pragma solidity ^0.4.15;

/*
  Copyright 2017 Mothership Foundation https://mothership.cx

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
*/




contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Token is ERC20Basic{
  
  
  
  
  function balanceOfAt(address _owner, uint _blockNumber) constant returns (uint);
}



/// functions, this simplifies the implementation of "user permissions".
///
/// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
contract Ownable {
  address public owner;

  
  /// account.
  function Ownable() {
    owner = msg.sender;
  }

  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  
  
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

contract Voting is Ownable {
  // Number of candidates. NOTE Candidates IDs sequience starts at 1.
  uint8 public candidates;
  // An interface to a token contract to check the balance
  Token public msp;
  // The last block that the voting period is active
  uint public endBlock;

  // A map to store voting candidate for each user address
  mapping(address => uint8) public votes;
  // A list of all voters
  address[] public voters;

  
  
  
  
  function Voting(uint8 _candidatesCount, address _msp, uint _endBlock) {
    candidates = _candidatesCount;
    msp = Token(_msp);
    endBlock = _endBlock;
  }

  
  
  function vote(uint8 _candidate) {
    require(_candidate > 0 && _candidate <= candidates);
    assert(endBlock == 0 || getBlockNumber() <= endBlock);
    if (votes[msg.sender] == 0) {
      voters.push(msg.sender);
    }
    votes[msg.sender] = _candidate;
    Vote(msg.sender, _candidate);
  }

  
  function votersCount()
    constant
    returns(uint) {
    return voters.length;
  }

  
  ///  choosen and MSP amount at the current block
  
  
  
  function getVoters(uint _offset, uint _limit)
    constant
    returns(address[] _voters, uint8[] _candidates, uint[] _amounts) {
    return getVotersAt(_offset, _limit, getBlockNumber());
  }

  
  ///  choosen and MSP amount at a specific `_blockNumber`
  
  
  
  
  function getVotersAt(uint _offset, uint _limit, uint _blockNumber)
    constant
    returns(address[] _voters, uint8[] _candidates, uint[] _amounts) {

    if (_offset < voters.length) {
      uint count = 0;
      uint resultLength = voters.length - _offset > _limit ? _limit : voters.length - _offset;
      uint _block = _blockNumber > endBlock ? endBlock : _blockNumber;
      _voters = new address[](resultLength);
      _candidates = new uint8[](resultLength);
      _amounts = new uint[](resultLength);
      for(uint i = _offset; (i < voters.length) && (count < _limit); i++) {
        _voters[count] = voters[i];
        _candidates[count] = votes[voters[i]];
        _amounts[count] = msp.balanceOfAt(voters[i], _block);
        count++;
      }

      return(_voters, _candidates, _amounts);
    }
  }

  function getSummary() constant returns (uint8[] _candidates, uint[] _summary) {
    uint _block = getBlockNumber() > endBlock ? endBlock : getBlockNumber();

    // Fill the candidates IDs list
    _candidates = new uint8[](candidates);
    for(uint8 c = 1; c <= candidates; c++) {
      _candidates[c - 1] = c;
    }

    // Get MSP impact map for each candidate
    _summary = new uint[](candidates);
    uint8 _candidateIndex;
    for(uint i = 0; i < voters.length; i++) {
      _candidateIndex = votes[voters[i]] - 1;
      _summary[_candidateIndex] = _summary[_candidateIndex] + msp.balanceOfAt(voters[i], _block);
    }

    return (_candidates, _summary);
  }

  
  ///  sent tokens to this contract.
  
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) onlyOwner {
    if (_token == 0x0) {
      owner.transfer(this.balance);
      return;
    }

    ERC20Basic token = ERC20Basic(_token);
    uint balance = token.balanceOf(this);
    token.transfer(owner, balance);
    ClaimedTokens(_token, owner, balance);
  }

  
  function getBlockNumber() internal constant returns (uint) {
    return block.number;
  }

  event Vote(address indexed _voter, uint indexed _candidate);
  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}