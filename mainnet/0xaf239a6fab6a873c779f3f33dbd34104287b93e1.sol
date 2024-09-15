// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 
pragma solidity 0.8.9;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
// 
pragma solidity 0.8.9;



interface ITokenDelegator {
  function _setImplementation(address implementation_) external;

  function _setOwner(address owner_) external;

  fallback() external payable;

  receive() external payable;
}


interface TokenEvents {
  
  event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

  
  event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

  
  event MinterChanged(address indexed oldMinter, address indexed newMinter);

  
  event Transfer(address indexed from, address indexed to, uint256 amount);

  
  event Approval(address indexed owner, address indexed spender, uint256 amount);

  
  event NewImplementation(address oldImplementation, address newImplementation);

  
  event ChangedSymbol(string oldSybmol, string newSybmol);

  
  event ChangedName(string oldName, string newName);
}

// 
pragma solidity 0.8.9;




contract TokenDelegatorStorage is Context {
  
  address public implementation;

  
  string public name = "Interest Protocol";

  
  string public symbol = "IPT";

  
  uint256 public totalSupply;

  
  uint8 public constant decimals = 18;

  address public owner;
  
  modifier onlyOwner() {
    require(owner == _msgSender(), "onlyOwner: sender not owner");
    _;
  }
}
// 
pragma solidity 0.8.9;





contract InterestProtocolToken is TokenDelegatorStorage, TokenEvents, ITokenDelegator {
  constructor(
    address account_,
    address owner_,
    address implementation_,
    uint256 initialSupply_
  ) {
    require(implementation_ != address(0), "TokenDelegator: invalid address");
    owner = owner_;
    delegateTo(implementation_, abi.encodeWithSignature("initialize(address,uint256)", account_, initialSupply_));

    implementation = implementation_;

    emit NewImplementation(address(0), implementation);
  }

  /**
   * @notice Called by the admin to update the implementation of the delegator
   * @param implementation_ The address of the new implementation for delegation
   */
  function _setImplementation(address implementation_) external override onlyOwner {
    require(implementation_ != address(0), "_setImplementation: invalid addr");

    address oldImplementation = implementation;
    implementation = implementation_;

    emit NewImplementation(oldImplementation, implementation);
  }

  /**
   * @notice Called by the admin to update the owner of the delegator
   * @param owner_ The address of the new owner
   */
  function _setOwner(address owner_) external override onlyOwner {
    owner = owner_;
  }

  /**
   * @notice Internal method to delegate execution to another contract
   * @dev It returns to the external caller whatever the implementation returns or forwards reverts
   * @param callee The contract to delegatecall
   * @param data The raw data to delegatecall
   */
  function delegateTo(address callee, bytes memory data) internal {
    //solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returnData) = callee.delegatecall(data);
    //solhint-disable-next-line no-inline-assembly
    assembly {
      if eq(success, 0) {
        revert(add(returnData, 0x20), returndatasize())
      }
    }
  }

  /**
   * @dev Delegates execution to an implementation contract.
   * It returns to the external caller whatever the implementation returns
   * or forwards reverts.
   */
  // solhint-disable-next-line no-complex-fallback
  fallback() external payable override {
    // delegate all other functions to current implementation
    //solhint-disable-next-line avoid-low-level-calls
    (bool success, ) = implementation.delegatecall(msg.data);
    //solhint-disable-next-line no-inline-assembly
    assembly {
      let free_mem_ptr := mload(0x40)
      returndatacopy(free_mem_ptr, 0, returndatasize())
      switch success
      case 0 {
        revert(free_mem_ptr, returndatasize())
      }
      default {
        return(free_mem_ptr, returndatasize())
      }
    }
  }

  receive() external payable override {}
}


interface ITokenDelegate {
  function initialize(address account_, uint256 initialSupply_) external;

  function changeName(string calldata name_) external;

  function changeSymbol(string calldata symbol_) external;

  function allowance(address account, address spender) external view returns (uint256);

  function approve(address spender, uint256 rawAmount) external returns (bool);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address dst, uint256 rawAmount) external returns (bool);

  function transferFrom(
    address src,
    address dst,
    uint256 rawAmount
  ) external returns (bool);

  function mint(address dst, uint256 rawAmount) external;

  function permit(
    address owner,
    address spender,
    uint256 rawAmount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function delegate(address delegatee) external;

  function delegateBySig(
    address delegatee,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function getCurrentVotes(address account) external view returns (uint96);

  function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);
}

/**
 * @title Storage for Token Delegate
 * @notice For future upgrades, do not change TokenDelegateStorageV1. Create a new
 * contract which implements TokenDelegateStorageV1 and following the naming convention
 * TokenDelegateStorageVX.
 */
contract TokenDelegateStorageV1 is TokenDelegatorStorage {
  // Allowance amounts on behalf of others
  mapping(address => mapping(address => uint96)) internal allowances;

  // Official record of token balances for each account
  mapping(address => uint96) internal balances;

  
  mapping(address => address) public delegates;

  
  struct Checkpoint {
    uint32 fromBlock;
    uint96 votes;
  }
  
  mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

  
  mapping(address => uint32) public numCheckpoints;

  
  mapping(address => uint256) public nonces;
}
