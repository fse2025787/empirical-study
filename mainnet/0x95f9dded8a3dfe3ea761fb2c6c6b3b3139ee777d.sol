
/**
 *Submitted for verification at Etherscan.io on 2022-08-17
*/

// File: @0x/contracts-erc20/contracts/src/interfaces/IERC20Token.sol

/*

  Copyright 2019 ZeroEx Intl.

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

pragma solidity ^0.5.9;


contract IERC20Token {

    // solhint-disable no-simple-event-func-name
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    
    
    
    
    function transfer(address _to, uint256 _value)
        external
        returns (bool);

    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool);

    
    
    
    
    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    
    
    function totalSupply()
        external
        view
        returns (uint256);

    
    
    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    
    
    
    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}

// File: @0x/contracts-erc20/contracts/src/ERC20Token.sol

/*

  Copyright 2019 ZeroEx Intl.

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

pragma solidity ^0.5.9;



contract ERC20Token is
    IERC20Token
{
    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 internal _totalSupply;

    
    
    
    
    function transfer(address _to, uint256 _value)
        external
        returns (bool)
    {
        require(
            balances[msg.sender] >= _value,
            "ERC20_INSUFFICIENT_BALANCE"
        );
        require(
            balances[_to] + _value >= balances[_to],
            "UINT256_OVERFLOW"
        );

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(
            msg.sender,
            _to,
            _value
        );

        return true;
    }

    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool)
    {
        require(
            balances[_from] >= _value,
            "ERC20_INSUFFICIENT_BALANCE"
        );
        require(
            allowed[_from][msg.sender] >= _value,
            "ERC20_INSUFFICIENT_ALLOWANCE"
        );
        require(
            balances[_to] + _value >= balances[_to],
            "UINT256_OVERFLOW"
        );

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;

        emit Transfer(
            _from,
            _to,
            _value
        );

        return true;
    }

    
    
    
    
    function approve(address _spender, uint256 _value)
        external
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(
            msg.sender,
            _spender,
            _value
        );
        return true;
    }

    
    
    function totalSupply()
        external
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    
    
    
    function balanceOf(address _owner)
        external
        view
        returns (uint256)
    {
        return balances[_owner];
    }

    
    
    
    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
}

// File: contracts/BiZouH+ERC20.sol



pragma solidity ^0.5.9;



/**
 * @title BiZouH + ERC20
 * @dev Create an ERC20 standard token
 */
contract BiZouH_ERC20 is ERC20Token {

    string public name;
    string public symbol;
    uint256 public decimals;

    constructor (
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        uint256 _totalSupply
    )
        public
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
    }
}