          pragma solidity ^0.8.0;
 abstract contract Proxy {
 function _delegate(address implementation) internal virtual {
 assembly {
 calldatacopy(0, 0, calldatasize()) let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0) returndatacopy(0, 0, returndatasize()) switch result case 0 {
 revert(0, returndatasize()) }
 default {
 return(0, returndatasize()) }
 }
 }
 function _implementation() internal view virtual returns (address);
 function _fallback() internal virtual {
 _beforeFallback();
 _delegate(_implementation());
 }
 fallback() external payable virtual {
 _fallback();
 }
 receive() external payable virtual {
 _fallback();
 }
 function _beforeFallback() internal virtual {
 }
 }
 pragma solidity ^0.8.0;
 contract ERC1155Creator is Proxy {
 constructor() {
 assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
 StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = 0x142FD5b9d67721EfDA3A5E2E9be47A96c9B724A4;
 Address.functionDelegateCall( 0x142FD5b9d67721EfDA3A5E2E9be47A96c9B724A4, abi.encodeWithSignature("initialize()") );
 }
 bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 function implementation() public view returns (address) {
 return _implementation();
 }
 function _implementation() internal override view returns (address) {
 return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 }
 }
 pragma solidity ^0.8.0;
 contract ESEDS is ERC1155Creator {
 constructor() ERC1155Creator() {
 }
 }
 pragma solidity ^0.8.1;
 library Address {
 function isContract(address account) internal view returns (bool) {
 return account.code.length > 0;
 }
 function sendValue(address payable recipient, uint256 amount) internal {
 require(address(this).balance >= amount, "Address: insufficient balance");
 (bool success, ) = recipient.call{
 value: amount}
 ("");
 require(success, "Address: unable to send value, recipient may have reverted");
 }
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, "Address: low-level call failed");
 }
 function functionCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 return functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value ) internal returns (bytes memory) {
 return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value, string memory errorMessage ) internal returns (bytes memory) {
 require(address(this).balance >= value, "Address: insufficient balance for call");
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
 value: value}
 (data);
 return verifyCallResult(success, returndata, errorMessage);
 }
 function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
 return functionStaticCall(target, data, "Address: low-level static call failed");
 }
 function functionStaticCall( address target, bytes memory data, string memory errorMessage ) internal view returns (bytes memory) {
 require(isContract(target), "Address: static call to non-contract");
 (bool success, bytes memory returndata) = target.staticcall(data);
 return verifyCallResult(success, returndata, errorMessage);
 }
 function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionDelegateCall(target, data, "Address: low-level delegate call failed");
 }
 function functionDelegateCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 require(isContract(target), "Address: delegate call to non-contract");
 (bool success, bytes memory returndata) = target.delegatecall(data);
 return verifyCallResult(success, returndata, errorMessage);
 }
 function verifyCallResult( bool success, bytes memory returndata, string memory errorMessage ) internal pure returns (bytes memory) {
 if (success) {
 return returndata;
 }
 else {
 if (returndata.length > 0) {
 assembly {
 let returndata_size := mload(returndata) revert(add(32, returndata), returndata_size) }
 }
 else {
 revert(errorMessage);
 }
 }
 }
 }
 pragma solidity ^0.8.0;
 library StorageSlot {
 struct AddressSlot {
 address value;
 }
 struct BooleanSlot {
 bool value;
 }
 struct Bytes32Slot {
 bytes32 value;
 }
 struct Uint256Slot {
 uint256 value;
 }
 function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
 assembly {
 r.slot := slot }
 }
 function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
 assembly {
 r.slot := slot }
 }
 function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
 assembly {
 r.slot := slot }
 }
 function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
 assembly {
 r.slot := slot }
 }
 }
