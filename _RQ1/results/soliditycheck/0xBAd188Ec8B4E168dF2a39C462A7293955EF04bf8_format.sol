         pragma solidity ^0.7.0;
 interface IERC165 {
 function supportsInterface(bytes4 interfaceId) external view returns (bool);
 }
 pragma solidity ^0.7.0;
 interface IERC1155 is IERC165 {
 event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
 event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
 event ApprovalForAll(address indexed account, address indexed operator, bool approved);
 event URI(string value, uint256 indexed id);
 function balanceOf(address account, uint256 id) external view returns (uint256);
 function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
 function setApprovalForAll(address operator, bool approved) external;
 function isApprovedForAll(address account, address operator) external view returns (bool);
 function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
 function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
 }
 pragma solidity >=0.6.0 <0.8.0;
 abstract contract Context {
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
 }
 }
 pragma solidity ^0.7.0;
 abstract contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor () {
 address msgSender = _msgSender();
 _owner = msgSender;
 emit OwnershipTransferred(address(0), msgSender);
 }
 function owner() public view virtual returns (address) {
 return _owner;
 }
 modifier onlyOwner() {
 require(owner() == _msgSender(), "Ownable: caller is not the owner");
 _;
 }
 function renounceOwnership() public virtual onlyOwner {
 emit OwnershipTransferred(_owner, address(0));
 _owner = address(0);
 }
 function transferOwnership(address newOwner) public virtual onlyOwner {
 require(newOwner != address(0), "Ownable: new owner is the zero address");
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;
 }
 }
 pragma solidity ^0.7.0;
 interface IERC1155MetadataURI is IERC1155 {
 function uri(uint256 id) external view returns (string memory);
 }
 pragma solidity ^0.7.0;
 abstract contract ERC165 is IERC165 {
 bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
 mapping(bytes4 => bool) private _supportedInterfaces;
 constructor () {
 _registerInterface(_INTERFACE_ID_ERC165);
 }
 function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 return _supportedInterfaces[interfaceId];
 }
 function _registerInterface(bytes4 interfaceId) internal virtual {
 require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
 _supportedInterfaces[interfaceId] = true;
 }
 }
 pragma solidity ^0.7.0;
 contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
 using SafeMath for uint256;
 using Address for address;
 mapping (uint256 => mapping(address => uint256)) private _balances;
 mapping (address => mapping(address => bool)) private _operatorApprovals;
 string private _uri;
 bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
 bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;
 constructor (string memory uri_) {
 _setURI(uri_);
 _registerInterface(_INTERFACE_ID_ERC1155);
 _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
 }
 function uri(uint256) external view virtual override returns (string memory) {
 return _uri;
 }
 function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
 require(account != address(0), "ERC1155: balance query for the zero address");
 return _balances[id][account];
 }
 function balanceOfBatch( address[] memory accounts, uint256[] memory ids ) public view virtual override returns (uint256[] memory) {
 require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");
 uint256[] memory batchBalances = new uint256[](accounts.length);
 for (uint256 i = 0; i < accounts.length; ++i) {
 batchBalances[i] = balanceOf(accounts[i], ids[i]);
 }
 return batchBalances;
 }
 function setApprovalForAll(address operator, bool approved) public virtual override {
 require(_msgSender() != operator, "ERC1155: setting approval status for self");
 _operatorApprovals[_msgSender()][operator] = approved;
 emit ApprovalForAll(_msgSender(), operator, approved);
 }
 function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
 return _operatorApprovals[account][operator];
 }
 function safeTransferFrom( address from, address to, uint256 id, uint256 amount, bytes memory data ) public virtual override {
 require(to != address(0), "ERC1155: transfer to the zero address");
 require( from == _msgSender() || isApprovedForAll(from, _msgSender()), "ERC1155: caller is not owner nor approved" );
 address operator = _msgSender();
 _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);
 _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
 _balances[id][to] = _balances[id][to].add(amount);
 emit TransferSingle(operator, from, to, id, amount);
 _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
 }
 function safeBatchTransferFrom( address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data ) public virtual override {
 require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
 require(to != address(0), "ERC1155: transfer to the zero address");
 require( from == _msgSender() || isApprovedForAll(from, _msgSender()), "ERC1155: transfer caller is not owner nor approved" );
 address operator = _msgSender();
 _beforeTokenTransfer(operator, from, to, ids, amounts, data);
 for (uint256 i = 0; i < ids.length; ++i) {
 uint256 id = ids[i];
 uint256 amount = amounts[i];
 _balances[id][from] = _balances[id][from].sub( amount, "ERC1155: insufficient balance for transfer" );
 _balances[id][to] = _balances[id][to].add(amount);
 }
 emit TransferBatch(operator, from, to, ids, amounts);
 _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
 }
 function _setURI(string memory newuri) internal virtual {
 _uri = newuri;
 }
 function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
 require(account != address(0), "ERC1155: mint to the zero address");
 address operator = _msgSender();
 _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);
 _balances[id][account] = _balances[id][account].add(amount);
 emit TransferSingle(operator, address(0), account, id, amount);
 _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
 }
 function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
 require(to != address(0), "ERC1155: mint to the zero address");
 require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
 address operator = _msgSender();
 _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);
 for (uint i = 0; i < ids.length; i++) {
 _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
 }
 emit TransferBatch(operator, address(0), to, ids, amounts);
 _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
 }
 function _burn(address account, uint256 id, uint256 amount) internal virtual {
 require(account != address(0), "ERC1155: burn from the zero address");
 address operator = _msgSender();
 _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");
 _balances[id][account] = _balances[id][account].sub( amount, "ERC1155: burn amount exceeds balance" );
 emit TransferSingle(operator, account, address(0), id, amount);
 }
 function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
 require(account != address(0), "ERC1155: burn from the zero address");
 require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
 address operator = _msgSender();
 _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");
 for (uint i = 0; i < ids.length; i++) {
 _balances[ids[i]][account] = _balances[ids[i]][account].sub( amounts[i], "ERC1155: burn amount exceeds balance" );
 }
 emit TransferBatch(operator, account, address(0), ids, amounts);
 }
 function _beforeTokenTransfer( address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data ) internal virtual {
 }
 function _doSafeTransferAcceptanceCheck( address operator, address from, address to, uint256 id, uint256 amount, bytes memory data ) private {
 if (to.isContract()) {
 try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
 if (response != IERC1155Receiver(to).onERC1155Received.selector) {
 revert("ERC1155: ERC1155Receiver rejected tokens");
 }
 }
 catch Error(string memory reason) {
 revert(reason);
 }
 catch {
 revert("ERC1155: transfer to non ERC1155Receiver implementer");
 }
 }
 }
 function _doSafeBatchTransferAcceptanceCheck( address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data ) private {
 if (to.isContract()) {
 try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
 if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
 revert("ERC1155: ERC1155Receiver rejected tokens");
 }
 }
 catch Error(string memory reason) {
 revert(reason);
 }
 catch {
 revert("ERC1155: transfer to non ERC1155Receiver implementer");
 }
 }
 }
 function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
 uint256[] memory array = new uint256[](1);
 array[0] = element;
 return array;
 }
 }
 pragma solidity ^0.7.0;
 abstract contract Pausable is Context {
 event Paused(address account);
 event Unpaused(address account);
 bool private _paused;
 constructor () {
 _paused = false;
 }
 function paused() public view virtual returns (bool) {
 return _paused;
 }
 modifier whenNotPaused() {
 require(!paused(), "Pausable: paused");
 _;
 }
 modifier whenPaused() {
 require(paused(), "Pausable: not paused");
 _;
 }
 function _pause() internal virtual whenNotPaused {
 _paused = true;
 emit Paused(_msgSender());
 }
 function _unpause() internal virtual whenPaused {
 _paused = false;
 emit Unpaused(_msgSender());
 }
 }
 pragma solidity ^0.7.0;
 abstract contract ERC1155Pausable is ERC1155, Pausable {
 function _beforeTokenTransfer( address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data ) internal virtual override {
 super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
 require(!paused(), "ERC1155Pausable: token transfer while paused");
 }
 }
 pragma solidity 0.7.6;
 interface IERC1155NonTransferable {
 function mint( address _to, uint256 _tokenId, uint256 _value, bytes calldata _data ) external;
 function burn( address _account, uint256 _tokenId, uint256 _value ) external;
 function pause() external;
 function unpause() external;
 }
 pragma solidity 0.7.6;
 contract MetaTransactionReceiver is Ownable {
 using ECDSA for bytes32;
 mapping(uint256 => bool) private usedNonce;
 event ExecutedMetaTransaction(bytes _data, bytes _returnData);
 event UsedNonce(uint256 _nonce);
 modifier onlyOwnerOrSelf() {
 require(msg.sender == owner() || msg.sender == address(this), "UNAUTHORIZED_O_SELF");
 _;
 }
 function executeMetaTransaction( uint256 _nonce, bytes calldata _data, bytes calldata _signature ) external {
 require(!usedNonce[_nonce], "METATX_NONCE");
 uint256 id;
 assembly {
 id := chainid() }
 bytes32 dataHash = keccak256(abi.encodePacked("boson:", id, address(this), _nonce, _data)).toEthSignedMessageHash();
 isValidOwnerSignature(dataHash, _signature);
 usedNonce[_nonce] = true;
 emit UsedNonce(_nonce);
 (bool success, bytes memory returnData) = address(this).call(_data);
 require(success, string(returnData));
 emit ExecutedMetaTransaction(_data, returnData);
 }
 function isUsedNonce(uint256 _nonce) external view returns(bool) {
 return usedNonce[_nonce];
 }
 function isValidOwnerSignature(bytes32 _hashedData, bytes memory _signature) public view {
 address from = _hashedData.recover(_signature);
 require(owner() == from, "METATX_UNAUTHORIZED");
 }
 }
 pragma solidity 0.7.6;
 contract ERC1155NonTransferable is IERC1155NonTransferable, ERC1155Pausable, Ownable, MetaTransactionReceiver {
 event LogUriSet(string _newUri, address _triggeredBy);
 constructor(string memory _uri) ERC1155(_uri) Ownable() {
 }
 function mint( address _to, uint256 _tokenId, uint256 _value, bytes memory _data ) external override onlyOwnerOrSelf {
 _mint(_to, _tokenId, _value, _data);
 }
 function mintBatch( address _to, uint256[] memory _tokenIds, uint256[] memory _values, bytes memory _data ) external onlyOwnerOrSelf {
 _mintBatch(_to, _tokenIds, _values, _data);
 }
 function burn( address _account, uint256 _tokenId, uint256 _value ) external override onlyOwnerOrSelf {
 _burn(_account, _tokenId, _value);
 }
 function burnBatch( address _account, uint256[] memory _tokenIds, uint256[] memory _values ) external onlyOwnerOrSelf {
 _burnBatch(_account, _tokenIds, _values);
 }
 function _beforeTokenTransfer( address _operator, address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data ) internal virtual override onlyOwner {
 require( _from == address(0) || _to == address(0), "ERC1155NonTransferable: Tokens are non transferable" );
 super._beforeTokenTransfer(_operator, _from, _to, _ids, _amounts, _data);
 }
 function pause() external override onlyOwnerOrSelf {
 _pause();
 }
 function unpause() external override onlyOwnerOrSelf {
 _unpause();
 }
 function setUri(string memory _newUri) external onlyOwnerOrSelf {
 require(bytes(_newUri).length != 0, "INVALID_VALUE");
 _setURI(_newUri);
 emit LogUriSet(_newUri, _msgSender());
 }
 function _msgSender() internal view virtual override returns (address payable) {
 return msg.sender == address(this) ? payable(owner()) : msg.sender;
 }
 }
 pragma solidity ^0.7.0;
 interface IERC1155Receiver is IERC165 {
 function onERC1155Received( address operator, address from, uint256 id, uint256 value, bytes calldata data ) external returns(bytes4);
 function onERC1155BatchReceived( address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data ) external returns(bytes4);
 }
 pragma solidity ^0.7.0;
 library SafeMath {
 function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 uint256 c = a + b;
 if (c < a) return (false, 0);
 return (true, c);
 }
 function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 if (b > a) return (false, 0);
 return (true, a - b);
 }
 function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 if (a == 0) return (true, 0);
 uint256 c = a * b;
 if (c / a != b) return (false, 0);
 return (true, c);
 }
 function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 if (b == 0) return (false, 0);
 return (true, a / b);
 }
 function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 if (b == 0) return (false, 0);
 return (true, a % b);
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b <= a, "SafeMath: subtraction overflow");
 return a - b;
 }
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) return 0;
 uint256 c = a * b;
 require(c / a == b, "SafeMath: multiplication overflow");
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b > 0, "SafeMath: division by zero");
 return a / b;
 }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b > 0, "SafeMath: modulo by zero");
 return a % b;
 }
 function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b <= a, errorMessage);
 return a - b;
 }
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 return a / b;
 }
 function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 return a % b;
 }
 }
 pragma solidity ^0.7.0;
 library Address {
 function isContract(address account) internal view returns (bool) {
 uint256 size;
 assembly {
 size := extcodesize(account) }
 return size > 0;
 }
 function sendValue(address payable recipient, uint256 amount) internal {
 require(address(this).balance >= amount, "Address: insufficient balance");
 (bool success, ) = recipient.call{
 value: amount }
 ("");
 require(success, "Address: unable to send value, recipient may have reverted");
 }
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, "Address: low-level call failed");
 }
 function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
 return functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
 return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 }
 function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
 require(address(this).balance >= value, "Address: insufficient balance for call");
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
 value: value }
 (data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
 return functionStaticCall(target, data, "Address: low-level static call failed");
 }
 function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
 require(isContract(target), "Address: static call to non-contract");
 (bool success, bytes memory returndata) = target.staticcall(data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionDelegateCall(target, data, "Address: low-level delegate call failed");
 }
 function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
 require(isContract(target), "Address: delegate call to non-contract");
 (bool success, bytes memory returndata) = target.delegatecall(data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
 pragma solidity ^0.7.0;
 library ECDSA {
 function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
 if (signature.length != 65) {
 revert("ECDSA: invalid signature length");
 }
 bytes32 r;
 bytes32 s;
 uint8 v;
 assembly {
 r := mload(add(signature, 0x20)) s := mload(add(signature, 0x40)) v := byte(0, mload(add(signature, 0x60))) }
 return recover(hash, v, r, s);
 }
 function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
 require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
 require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");
 address signer = ecrecover(hash, v, r, s);
 require(signer != address(0), "ECDSA: invalid signature");
 return signer;
 }
 function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
 return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
 }
 }
