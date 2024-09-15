
pragma solidity ^0.4.18;


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




///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token


/// CHANGE LOG: Will Harborne (Ethfinex)  - 07/10/2017
/// `transferFrom` edited to allow infinite approvals
/// New function `pledgeFees` for Controller to update balance owned by token holders
/// New getter functions `totalPledgedFeesAt` and `totalPledgedFees`
/// New Checkpoint[] totalPledgedFeesHistory;
/// Addition of onBurn function to Controller, called when user tries to burn tokens
/// Version 'MMT_0.2' bumped to 'EFX_0.1'


contract TokenController {
    
    
    
    function proxyPayment(address _owner) public payable returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);

    
    
    
    
    function onBurn(address _owner, uint _amount) public returns(bool);
}

contract Controlled {
    
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

    
    
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}


///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'EFX_0.1'; //An arbitrary versioning scheme


    
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint public parentSnapShotBlock;

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

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // Tracks the history of the `pledgedFees` belonging to token holders
    Checkpoint[] totalPledgedFeesHistory; // in wei

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

////////////////
// Constructor
////////////////

    
    
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    
    ///  new token
    
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    
    
    
    
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


///////////////////
// ERC20 Methods
///////////////////

    uint constant MAX_UINT = 2**256 - 1;

    
    
    
    
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
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
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            if (allowed[_from][msg.sender] < MAX_UINT) {
                require(allowed[_from][msg.sender] >= _amount);
                allowed[_from][msg.sender] -= _amount;
            }
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

    
    ///  only be called by other functions in this contract.
    
    
    
    
    function doTransfer(address _from, address _to, uint _amount
    ) internal {

           if (_amount == 0) {
               Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0
               return;
           }

           require(parentSnapShotBlock < block.number);

           // Do not allow transfer to 0x0 or the token contract itself
           require((_to != 0) && (_to != address(this)));

           // If the amount being transfered is more than the balance of the
           //  account the transfer throws
           var previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

           // Alerts the token controller of the transfer
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           var previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           Transfer(_from, _to, _amount);

    }

    
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    
    
    
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    
    
    
    
    ///  to spend
    function allowance(address _owner, address _spender
    ) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    
    
    
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    
    
    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    
    
    
    
    function balanceOfAt(address _owner, uint _blockNumber) public constant
        returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // Has no parent
                return 0;
            }

        // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    
    
    
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

////////////////
// Query pledgedFees // in wei
////////////////

   
   
   function totalPledgedFees() public constant returns (uint) {
       return totalPledgedFeesAt(block.number);
   }

   
   
   
   function totalPledgedFeesAt(uint _blockNumber) public constant returns(uint) {

       // These next few lines are used when the totalPledgedFees of the token is
       //  requested before a check point was ever created for this token, it
       //  requires that the `parentToken.totalPledgedFeesAt` be queried at the
       //  genesis block for this token as that contains totalPledgedFees of this
       //  token at this block number.
       if ((totalPledgedFeesHistory.length == 0)
           || (totalPledgedFeesHistory[0].fromBlock > _blockNumber)) {
           if (address(parentToken) != 0) {
               return parentToken.totalPledgedFeesAt(min(_blockNumber, parentSnapShotBlock));
           } else {
               return 0;
           }

       // This will return the expected totalPledgedFees during normal situations
       } else {
           return getValueAt(totalPledgedFeesHistory, _blockNumber);
       }
   }

////////////////
// Pledge Fees To Token Holders or Reduce Pledged Fees // in wei
////////////////

   
   
   function pledgeFees(uint _value) public onlyController returns (bool) {
       uint curTotalFees = totalPledgedFees();
       require(curTotalFees + _value >= curTotalFees); // Check for overflow
       updateValueAtNow(totalPledgedFeesHistory, curTotalFees + _value);
       return true;
   }

   
   
   function reducePledgedFees(uint _value) public onlyController returns (bool) {
       uint curTotalFees = totalPledgedFees();
       require(curTotalFees >= _value);
       updateValueAtNow(totalPledgedFeesHistory, curTotalFees - _value);
       return true;
   }

////////////////
// Clone Token Method
////////////////

    
    ///  this token at `_snapshotBlock`
    
    
    
    
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    
    
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

////////////////
// Generate and destroy tokens
////////////////

    
    
    
    
    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

////////////////
// Enable tokens transfers
////////////////


    
    
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    
    
    
    
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    
    ///  `totalSupplyHistory`
    
    
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    
    
    
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function () public payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

//////////
// Safety Methods
//////////

    
    ///  sent tokens to this contract.
    
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

////////////////
// Events
////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}


////////////////
// MiniMeTokenFactory
////////////////


///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    
    ///  the msg.sender becomes the controller of this clone token
    
    
    ///  determine the initial distribution of the clone token
    
    
    
    
    
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}


/*
    Copyright 2017, Will Harborne (Ethfinex)
*/

contract NEC is MiniMeToken {

  function NEC(
    address _tokenFactory,
    address efxVaultWallet
  ) public MiniMeToken(
    _tokenFactory,
    0x0,                    // no parent token
    0,                      // no snapshot block number from parent
    "Ethfinex Nectar Token", // Token name
    18,                     // Decimals
    "NEC",                  // Symbol
    true                    // Enable transfers
    ) {
        generateTokens(efxVaultWallet, 1000000000000000000000000000);
        enableBurning(false);
    }

    // Flag that determines if the token can be burned for rewards or not
    bool public burningEnabled;


////////////////
// Enable token burning by users
////////////////

    function enableBurning(bool _burningEnabled) public onlyController {
        burningEnabled = _burningEnabled;
    }

    function burnAndRetrieve(uint256 _tokensToBurn) public returns (bool success) {
        require(burningEnabled);

        var previousBalanceFrom = balanceOfAt(msg.sender, block.number);
        if (previousBalanceFrom < _tokensToBurn) {
            return false;
        }

        // Alerts the token controller of the burn function call
        // If enabled, controller will distribute fees and destroy tokens
        // Or any other logic chosen by controller
        if (isContract(controller)) {
            require(TokenController(controller).onBurn(msg.sender, _tokensToBurn));
        }

        Burned(msg.sender, _tokensToBurn);
        return true;
    }

    event Burned(address indexed who, uint256 _amount);

}



///  later changed
contract Owned {
    
    /// modifier
    modifier onlyOwner { require (msg.sender == owner); _; }

    address public owner;

    
    function Owned() public { owner = msg.sender;}

    
    
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

/*
    Copyright 2017, Will Harborne (Ethfinex)
*/



contract Whitelist is Owned {

  function Whitelist() {
    admins[msg.sender] = true;
  }

  bool public listActive = true;

  // Only users who are on the whitelist
  function isRegistered(address _user) public constant returns (bool) {
    if (!listActive) {
      return true;
    } else {
      return isOnList[_user];
    }
  }

  // Can add people to the whitelist
  function isAdmin(address _admin) public view returns(bool) {
    return admins[_admin];
  }

  
  
  function addAdmin(address _newAdmin) public onlyOwner {
    admins[_newAdmin] = true;
  }

  
  
  function removeAdmin(address _admin) public onlyOwner {
    admins[_admin] = false;
  }

  // Only authorised sources/contracts can contribute fees on behalf of makers to earn tokens
  modifier authorised () {
    require(isAuthorisedMaker[msg.sender]);
    _;
  }

  modifier onlyAdmins() {
    require(isAdmin(msg.sender));
    _;
  }

  // These admins are able to add new users to the whitelist
  mapping (address => bool) public admins;

  // This is the whitelist of users who are registered to be able to own the tokens
  mapping (address => bool) public isOnList;

  // This is a more select list of a few contracts or addresses which can contribute fees on behalf of makers, to generate tokens
  mapping (address => bool) public isAuthorisedMaker;


  
  
  function register(address[] newUsers) public onlyAdmins {
    for (uint i = 0; i < newUsers.length; i++) {
      isOnList[newUsers[i]] = true;
    }
  }

  
  
  function deregister(address[] bannedUsers) public onlyAdmins {
    for (uint i = 0; i < bannedUsers.length; i++) {
      isOnList[bannedUsers[i]] = false;
    }
  }

  
  
  function authoriseMaker(address maker) public onlyOwner {
      isAuthorisedMaker[maker] = true;
      // Also add any authorised Maker to the whitelist
      address[] memory makers = new address[](1);
      makers[0] = maker;
      register(makers);
  }

  
  
  function deauthoriseMaker(address maker) public onlyOwner {
      isAuthorisedMaker[maker] = false;
  }

  function activateWhitelist(bool newSetting) public onlyOwner {
      listActive = newSetting;
  }

  /////// Getters to allow the same whitelist to be used also by other contracts (including upgraded Controllers) ///////

  function getRegistrationStatus(address _user) constant external returns (bool) {
    return isOnList[_user];
  }

  function getAuthorisationStatus(address _maker) constant external returns (bool) {
    return isAuthorisedMaker[_maker];
  }

  function getOwner() external constant returns (address) {
    return owner;
  }


}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/*
    Copyright 2018, Will Harborne (Ethfinex)
    v2.0.0
*/

contract NectarController is TokenController, Whitelist {
    using SafeMath for uint256;

    NEC public tokenContract;   // The new token for this Campaign
    address public vaultAddress;        // The address to hold the funds donated

    uint public periodLength = 30;       // Contribution windows length in days
    uint public startTime = 1518523865;  // Time of window 1 opening

    mapping (uint => uint) public windowFinalBlock;  // Final block before initialisation of new window


    
    
    

    function NectarController(
        address _vaultAddress,
        address _tokenAddress
    ) public {
        require(_vaultAddress != 0);                // To prevent burning ETH
        tokenContract = NEC(_tokenAddress); // The Deployed Token Contract
        vaultAddress = _vaultAddress;
        windowFinalBlock[0] = 5082733;
        windowFinalBlock[1] = 5260326;
    }

    
    /// simply calls `doTakerPayment()` . No tokens are created when takers contribute.
    /// `_owner`. Payable is a required solidity modifier for functions to receive
    /// ether, without this modifier functions will throw if ether is sent to them

    function ()  public payable {
        doTakerPayment();
    }

    function contributeForMakers(address _owner) public payable authorised {
        doMakerPayment(_owner);
    }

/////////////////
// TokenController interface
/////////////////

    
    /// but does not create tokens. This functions the same as the fallback function.
    
    function proxyPayment(address _owner) public payable returns(bool) {
        doTakerPayment();
        return true;
    }

    
    /// Creates tokens, pledging an amount of eth to token holders but not sending it through the contract to the vault
    
    function proxyAccountingCreation(address _owner, uint _pledgedAmount, uint _tokensToCreate) public onlyOwner returns(bool) {
        // Ethfinex is a hybrid decentralised exchange
        // This function is only for use to create tokens on behalf of users of the centralised side of Ethfinex
        // Because there are several different fee tiers (depending on trading volume) token creation rates may not always be proportional to fees contributed.
        // For example if a user is trading with a 0.025% fee as opposed to the standard 0.1% the tokensToCreate the pledged fees will be lower than through using the standard contributeForMakers function
        // Tokens to create must be calculated off-chain using the issuance equation and current parameters of this contract, multiplied depending on user's fee tier
        doProxyAccounting(_owner, _pledgedAmount, _tokensToCreate);
        return true;
    }


    
    /// Transfers can only happen to whitelisted addresses
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool) {
        if (isRegistered(_to) && isRegistered(_from)) {
          return true;
        } else {
          return false;
        }
    }

    
    ///  approvals are allowed by default and no extra notifications are needed
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool)
    {
        if (isRegistered(_owner)) {
          return true;
        } else {
          return false;
        }
    }

    
    /// Upgraded Controllers in the future will allow token holders to claim the pledged ETH
    
    
    
    function onBurn(address _owner, uint _tokensToBurn) public
        returns(bool)
    {
        // This plugin can only be called by the token contract
        require(msg.sender == address(tokenContract));

        uint256 feeTotal = tokenContract.totalPledgedFees();
        uint256 totalTokens = tokenContract.totalSupply();
        uint256 feeValueOfTokens = (feeTotal.mul(_tokensToBurn)).div(totalTokens);

        // Destroy the owners tokens prior to sending them the associated fees
        require (tokenContract.destroyTokens(_owner, _tokensToBurn));
        require (address(this).balance >= feeValueOfTokens);
        require (_owner.send(feeValueOfTokens));

        emit LogClaim(_owner, feeValueOfTokens);
        return true;
    }

/////////////////
// Maker and taker fee payments handling
/////////////////


    
    ///  contract receives to the `vault` and creates tokens in the address of the
    ///  `_owner`who the fee contribution was sent by
    
    function doMakerPayment(address _owner) internal {

        require ((tokenContract.controller() != 0) && (msg.value != 0) );
        tokenContract.pledgeFees(msg.value);
        require (vaultAddress.send(msg.value));

        // Set the block number which will be used to calculate issuance rate during
        // this window if it has not already been set
        if(windowFinalBlock[currentWindow()-1] == 0) {
            windowFinalBlock[currentWindow()-1] = block.number -1;
        }

        uint256 newIssuance = getFeeToTokenConversion(msg.value);
        require (tokenContract.generateTokens(_owner, newIssuance));

        emit LogContributions (_owner, msg.value, true);
        return;
    }

    
    ///  contract receives to the `vault`, creating no tokens
    function doTakerPayment() internal {

        require ((tokenContract.controller() != 0) && (msg.value != 0) );
        tokenContract.pledgeFees(msg.value);
        require (vaultAddress.send(msg.value));

        emit LogContributions (msg.sender, msg.value, false);
        return;
    }

    
    /// for fees pledged by the owner
    function doProxyAccounting(address _owner, uint _pledgedAmount, uint _tokensToCreate) internal {

        require ((tokenContract.controller() != 0));
        if(windowFinalBlock[currentWindow()-1] == 0) {
            windowFinalBlock[currentWindow()-1] = block.number -1;
        }
        tokenContract.pledgeFees(_pledgedAmount);

        if(_tokensToCreate > 0) {
            uint256 newIssuance = getFeeToTokenConversion(_pledgedAmount);
            require (tokenContract.generateTokens(_owner, _tokensToCreate));
        }

        emit LogContributions (msg.sender, _pledgedAmount, true);
        return;
    }

    
    
    function setVault(address _newVaultAddress) public onlyOwner {
        vaultAddress = _newVaultAddress;
    }

    
    
    function upgradeController(address _newControllerAddress) public onlyOwner {
        tokenContract.changeController(_newControllerAddress);
        emit UpgradedController(_newControllerAddress);
    }

/////////////////
// Issuance reward related functions - upgraded by changing controller
/////////////////

    
    
    function getFeeToTokenConversion(uint256 _contributed) public view returns (uint256) {

        uint calculationBlock = windowFinalBlock[currentWindow()-1];
        uint256 previousSupply = tokenContract.totalSupplyAt(calculationBlock);
        uint256 initialSupply = tokenContract.totalSupplyAt(windowFinalBlock[0]);
        // Rate = 1000 * (2-totalSupply/InitialSupply)^2
        // This imposes a max possible supply of 2 billion
        if (previousSupply >= 2 * initialSupply) {
            return 0;
        }
        uint256 newTokens = _contributed.mul(1000).mul(bigInt(2)-(bigInt(previousSupply).div(initialSupply))).mul(bigInt(2)-(bigInt(previousSupply).div(initialSupply))).div(bigInt(1).mul(bigInt(1)));
        return newTokens;
    }

    function bigInt(uint256 input) internal pure returns (uint256) {
      return input.mul(10 ** 10);
    }

    function currentWindow() public constant returns (uint) {
       return windowAt(block.timestamp);
    }

    function windowAt(uint timestamp) public constant returns (uint) {
      return timestamp < startTime
          ? 0
          : timestamp.sub(startTime).div(periodLength * 1 days) + 1;
    }

    
    function topUpBalance() public payable {
        // Pledged fees could be sent here and used to payout users who burn their tokens
        emit LogFeeTopUp(msg.value);
    }

    
    function evacuateToVault() public onlyOwner{
        vaultAddress.transfer(address(this).balance);
        emit LogFeeEvacuation(address(this).balance);
    }

    
    function enableBurning(bool _burningEnabled) public onlyOwner{
        tokenContract.enableBurning(_burningEnabled);
    }


//////////
// Safety Methods
//////////

    
    ///  sent tokens to this contract.
    
    function claimTokens(address _token) public onlyOwner {

        NEC token = NEC(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);
        emit ClaimedTokens(_token, owner, balance);
    }

////////////////
// Events
////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);

    event LogFeeTopUp(uint _amount);
    event LogFeeEvacuation(uint _amount);
    event LogContributions (address _user, uint _amount, bool _maker);
    event LogClaim (address _user, uint _amount);

    event UpgradedController (address newAddress);

}