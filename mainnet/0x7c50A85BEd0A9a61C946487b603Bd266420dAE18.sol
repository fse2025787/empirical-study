// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-07-17
*/

// Sources flattened with hardhat v2.3.3 https://hardhat.org

// File contracts/core/ArmorToken.sol

// 

pragma solidity 0.8.4;

/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// This minime token contract adjusted by ArmorFi to remove all functionality of
// inheriting from a parent and only keep functionality related to keeping track of
// balances through different checkpoints.




///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token




///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract ArmorToken {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = '69_420'; //An arbitrary versioning scheme

    
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }

    // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    // Shield that is allowed to mint tokens to peeps.
    address public arShield;
    // ShieldController--can just withdraw tokens.
    address public controller;

////////////////
// Constructor
////////////////

    
    
    
    constructor(
        address _arShield,
        string memory _tokenName,
        string memory _tokenSymbol
    ) 
    {
        require(arShield == address(0), "Contract already initialized.");
        arShield = _arShield;
        name = _tokenName;                                 // Set the name
        decimals = 18;                                     // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        creationBlock = block.number;
        controller = msg.sender;
    }

    modifier onlyController
    {
        require(msg.sender == controller, "Sender must be controller.");
        _;
    }
    
    modifier onlyShield
    {
        require(msg.sender == arShield, "Sender must be shield.");
        _;
    }

///////////////////
// ERC20 Methods
///////////////////

    
    
    
    
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    
    ///  is approved by `_from`
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0

        // The standard ERC 20 transferFrom functionality
        require(allowed[_from][msg.sender] >= _amount);
        allowed[_from][msg.sender] -= _amount;

        doTransfer(_from, _to, _amount);
        return true;
    }

    
    ///  only be called by other functions in this contract.
    
    
    
    function doTransfer(address _from, address _to, uint _amount
    ) internal {

           if (_amount == 0) {
               emit Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0
               return;
           }

           // Do not allow transfer to 0x0 or the token contract itself
           require(_to != address(this));

           // If the amount being transfered is more than the balance of the
           //  account the transfer throws
           uint256 previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           uint256 previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           emit Transfer(_from, _to, _amount);

    }

    
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    
    
    
    function approve(address _spender, uint256 _amount) public returns (bool success) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        
        // Armor is removing this cause frankly it's a bit annoying and so unlikely.
        //require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    
    
    
    
    ///  to spend
    function allowance(address _owner, address _spender
    ) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    
    function totalSupply() public view returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    
    
    
    
    function balanceOfAt(address _owner, uint _blockNumber) public view
        returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
                return 0;
        // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    
    
    
    function totalSupplyAt(uint _blockNumber) public view returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
                return 0;
        // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

////////////////
// Generate and destroy tokens
////////////////

    
    
    
    
    function mint(address _owner, uint _amount
    ) public onlyShield returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        emit Transfer(address(0), _owner, _amount);
        return true;
    }


    
    
    
    function burn(uint _amount
    )  public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(msg.sender);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[msg.sender], previousBalanceFrom - _amount);
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    
    
    
    
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) view internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint minimum = 0;
        uint max = checkpoints.length-1;
        while (max > minimum) {
            uint mid = (max + minimum + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                minimum = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[minimum].value;
    }

    
    ///  `totalSupplyHistory`
    
    
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               //Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               checkpoints.push( Checkpoint( uint128(block.number), uint128(_value) ) );
               //newCheckPoint.fromBlock =  uint128(block.number);
               //newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

//////////
// Safety Methods
//////////

    
    ///  sent tokens to this contract.
    
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyController {
        if (_token == address(0)) {
            payable(controller).transfer(address(this).balance);
            return;
        }

        ArmorToken token = ArmorToken(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(controller, balance);
        emit ClaimedTokens(_token, controller, balance);
    }

////////////////
// Events
////////////////

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}