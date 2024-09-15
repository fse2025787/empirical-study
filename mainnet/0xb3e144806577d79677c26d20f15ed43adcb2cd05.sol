// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-01-03
*/

// 
pragma solidity ^0.8.2;




abstract contract Proxy {

  
  
  function __implementation() public virtual view returns (address impl);

  
  /// any return data is forwarded to the caller.
  fallback() external payable {
    address _impl = __implementation();
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0x0, calldatasize())
      let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0x0, 0x0)
      let size := returndatasize()
      returndatacopy(ptr, 0x0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }

  
  receive() external payable {}
}



contract UpgradableProxy is Proxy {

  // storage address of the implementation delegate contract address
  bytes32 private constant implStorageAddress = keccak256("network.provide.proxy.implementation");

  
  
  event Upgraded(address indexed implementation);

  
  
  function __implementation() public override view returns (address impl) {
    bytes32 _saddr = implStorageAddress;
    assembly {
      impl := sload(_saddr)
    }
  }

  
  
  function __setImplementation(address _implementation) internal {
    address _current = __implementation();
    require(_current != _implementation, 'given implementation contract address is already set');

    bytes32 _saddr = implStorageAddress;
    assembly {
      sstore(_saddr, _implementation)
    }

    emit Upgraded(_implementation);
  }
}



contract UpgradableNetwork is UpgradableProxy {

  // storage address of the contract owner
  bytes32 private constant ownerStorageAddress = keccak256("network.provide.proxy.owner");

  
  
  
  event OwnershipTransferred(address from, address to);

  /// initialize the contract owner to the sender
  constructor() {
    __setOwner(msg.sender);
  }

  
  modifier onlyOwner() {
    require(msg.sender == __owner());
    _;
  }

  
  
  function __owner() public view returns (address owner_) {
    bytes32 _position = ownerStorageAddress;
    assembly {
      owner_ := sload(_position)
    }
  }

  
  
  function __setOwner(address _owner) internal {
    bytes32 _position = ownerStorageAddress;
    assembly {
      sstore(_position, _owner)
    }
  }

  
  
  function __transferOwnership(address _owner) public onlyOwner {
    require(_owner != address(0), 'ownership cannot be transferred to 0x');
    emit OwnershipTransferred(__owner(), _owner);
    __setOwner(_owner);
  }

  
  
  function __upgrade(address _implementation) public onlyOwner {
    __setImplementation(_implementation);
  }

  
  /// and passing calldata to the new implementation for initialization
  
  
  /// signature of the implementation to be called with the needed payload
  function __upgradeInit(address _implementation, bytes calldata _data) public payable onlyOwner {
    __upgrade(_implementation);
    (bool _success,  ) = address(this).call{value: msg.value}(_data);
    require(_success, 'failed to upgrade implementation contract');
  }
}



contract Provide is UpgradableNetwork {

  
  /// the initial network implementation contract
  constructor(address _network) {
    __setOwner(msg.sender);

    if (_network != address(0)) {
      __upgrade(_network);
    }
  }
}