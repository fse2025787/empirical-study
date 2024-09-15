
/*

  Copyright 2018 Ethfinex Inc

  This is a derivative work based on software developed by ZeroEx Intl
  This and the original are licensed under Apache License, Version 2.0

  Original attribution:

  Copyright 2017 ZeroEx Intl.

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

pragma solidity 0.4.19;

interface Token {

    
    
    
    
    function transfer(address _to, uint _value) public returns (bool);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool);

    
    
    
    
    function approve(address _spender, uint _value) public returns (bool);

    
    
    function balanceOf(address _owner) public view returns (uint);

    
    
    
    function allowance(address _owner, address _spender) public view returns (uint);

    event Transfer(address indexed _from, address indexed _to, uint _value); // solhint-disable-line
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


//solhint-disable-next-line


contract TokenTransferProxy {

    modifier onlyExchange {
        require(msg.sender == exchangeAddress);
        _;
    }

    address public exchangeAddress;


    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);

    function TokenTransferProxy() public {
        setExchange(msg.sender);
    }
    /*
     * Public functions
     */

    
    
    
    
    
    
    function transferFrom(
        address token,
        address from,
        address to,
        uint value)
        public
        onlyExchange
        returns (bool)
    {
        return Token(token).transferFrom(from, to, value);
    }

    
    
    function setExchange(address _exchange) internal {
        require(exchangeAddress == address(0));
        exchangeAddress = _exchange;
    }
}