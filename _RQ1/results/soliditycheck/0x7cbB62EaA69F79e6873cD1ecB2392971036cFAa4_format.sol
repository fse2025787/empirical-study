     pragma solidity >=0.7.0 <0.9.0;
 contract CreateCall {
 event ContractCreation(address newContract);
 function performCreate2( uint256 value, bytes memory deploymentData, bytes32 salt ) public returns (address newContract) {
 assembly {
 newContract := create2(value, add(0x20, deploymentData), mload(deploymentData), salt) }
 require(newContract != address(0), "Could not deploy contract");
 emit ContractCreation(newContract);
 }
 function performCreate(uint256 value, bytes memory deploymentData) public returns (address newContract) {
 assembly {
 newContract := create(value, add(deploymentData, 0x20), mload(deploymentData)) }
 require(newContract != address(0), "Could not deploy contract");
 emit ContractCreation(newContract);
 }
 }
