// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.0;


contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor () {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    
    /// Can only be called by the current owner.
    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
// 

pragma solidity ^0.8.0;





contract Relay is Ownable() {
    using IsContract for address;

    struct Call {
        address target;
        bytes data;
    }

    
    function execute(Call[] calldata functionCalls)
        external onlyOwner returns (bytes[] memory results)
    {
        results = new bytes[](functionCalls.length);
        for (uint256 i = 0; i < functionCalls.length; i++){
            require(functionCalls[i].target.isContract(), "Call to a non-contract");
            (bool success, bytes memory result) = functionCalls[i].target.call(functionCalls[i].data);
            if (!success) revert(RevertMsgExtractor.getRevertMsg(result));
            results[i] = result;
        }
    }
}

// 
// Taken from https://github.com/sushiswap/BoringSolidity/blob/441e51c0544cf2451e6116fe00515e71d7c42e2c/contracts/BoringBatchable.sol

pragma solidity >=0.6.0;


library RevertMsgExtractor {
    
    /// If the returned data is malformed or not correctly abi encoded then this call can fail itself.
    function getRevertMsg(bytes memory returnData)
        internal pure
        returns (string memory)
    {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            returnData := add(returnData, 0x04)
        }
        return abi.decode(returnData, (string)); // All that remains is the revert string
    }
}

// 
// Taken from Address.sol from OpenZeppelin.
pragma solidity ^0.8.0;


library IsContract {
  
  function isContract(address account) internal view returns (bool) {
      // This method relies on extcodesize, which returns 0 for contracts in
      // construction, since the code is only stored at the end of the
      // constructor execution.
      return account.code.length > 0;
  }
}
