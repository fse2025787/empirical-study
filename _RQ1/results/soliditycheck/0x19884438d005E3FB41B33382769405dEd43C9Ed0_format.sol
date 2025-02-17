         pragma solidity >=0.6.0 <0.8.0;
 interface IERC165 {
 function supportsInterface(bytes4 interfaceId) external view returns (bool);
 }
 pragma solidity >=0.6.2 <0.8.0;
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
 pragma solidity >=0.6.2 <0.8.0;
 interface IERC1155MetadataURI is IERC1155 {
 function uri(uint256 id) external view returns (string memory);
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
 pragma solidity >=0.6.0 <0.8.0;
 abstract contract ERC165 is IERC165 {
 bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
 mapping(bytes4 => bool) private _supportedInterfaces;
 constructor () internal {
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
 pragma solidity >=0.6.0 <0.8.0;
 contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
 using SafeMath for uint256;
 using Address for address;
 mapping (uint256 => mapping(address => uint256)) private _balances;
 mapping (address => mapping(address => bool)) private _operatorApprovals;
 string private _uri;
 bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
 bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;
 constructor (string memory uri_) public {
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
 pragma solidity >=0.6.0 <0.8.0;
 abstract contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor () internal {
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
 pragma solidity 0.7.6;
 interface IStarNFT is IERC1155 {
 function isOwnerOf(address, uint256) external view returns (bool);
 function getNumMinted() external view returns (uint256);
 function mint(address account, uint256 powah) external returns (uint256);
 function mintBatch(address account, uint256 amount, uint256[] calldata powahArr) external returns (uint256[] memory);
 function burn(address account, uint256 id) external;
 function burnBatch(address account, uint256[] calldata ids) external;
 }
 pragma solidity 0.7.6;
 contract StarNFTV1 is ERC1155, IStarNFT, Ownable {
 using SafeMath for uint256;
 event EventMinterAdded(address indexed newMinter);
 event EventMinterRemoved(address indexed oldMinter);
 modifier onlyMinter() {
 require(minters[msg.sender], "must be minter");
 _;
 }
 string public baseURI;
 mapping(address => bool) public minters;
 uint256 public starCount;
 constructor () ERC1155("") {
 }
 function mint(address account, uint256 powah) external onlyMinter override returns (uint256) {
 starCount++;
 uint256 sID = starCount;
 _mint(account, sID, 1, "");
 return sID;
 }
 function mintBatch(address account, uint256 amount, uint256[] calldata powahArr) external onlyMinter override returns (uint256[] memory) {
 uint256[] memory ids = new uint256[](amount);
 uint256[] memory amounts = new uint256[](amount);
 for (uint i = 0; i < ids.length; i++) {
 starCount++;
 ids[i] = starCount;
 amounts[i] = 1;
 }
 _mintBatch(account, ids, amounts, "");
 return ids;
 }
 function burn(address account, uint256 id) external onlyMinter override {
 require(isApprovedForAll(account, _msgSender()), "ERC1155: caller is not approved");
 _burn(account, id, 1);
 }
 function burnBatch(address account, uint256[] calldata ids) external onlyMinter override {
 require(isApprovedForAll(account, _msgSender()), "ERC1155: caller is not approved");
 uint256[] memory amounts = new uint256[](ids.length);
 for (uint i = 0; i < ids.length; i++) {
 amounts[i] = 1;
 }
 _burnBatch(account, ids, amounts);
 }
 function setURI(string memory newURI) external onlyOwner {
 baseURI = newURI;
 }
 function addMinter(address minter) external onlyOwner {
 require(minter != address(0), "Minter must not be null address");
 require(!minters[minter], "Minter already added");
 minters[minter] = true;
 emit EventMinterAdded(minter);
 }
 function removeMinter(address minter) external onlyOwner {
 require(minters[minter], "Minter does not exist");
 delete minters[minter];
 emit EventMinterRemoved(minter);
 }
 function uri(uint256 id) external view override returns (string memory) {
 require(id <= starCount, "NFT does not exist");
 if (bytes(baseURI).length == 0) {
 return "";
 }
 else {
 return string(abi.encodePacked(baseURI, uint2str(id), ".json"));
 }
 }
 function isOwnerOf(address account, uint256 id) public view override returns (bool) {
 return balanceOf(account, id) == 1;
 }
 function getNumMinted() external view override returns (uint256) {
 return starCount;
 }
 function uint2str(uint _i) internal pure returns (string memory) {
 if (_i == 0) {
 return "0";
 }
 uint j = _i;
 uint len;
 while (j != 0) {
 len++;
 j /= 10;
 }
 bytes memory bStr = new bytes(len);
 uint k = len;
 while (_i != 0) {
 k = k - 1;
 uint8 temp = (48 + uint8(_i - _i / 10 * 10));
 bytes1 b1 = bytes1(temp);
 bStr[k] = b1;
 _i /= 10;
 }
 return string(bStr);
 }
 }
 pragma solidity >=0.6.0 <0.8.0;
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
 pragma solidity >=0.6.2 <0.8.0;
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
 pragma solidity >=0.6.0 <0.8.0;
 interface IERC1155Receiver is IERC165 {
 function onERC1155Received( address operator, address from, uint256 id, uint256 value, bytes calldata data ) external returns(bytes4);
 function onERC1155BatchReceived( address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data ) external returns(bytes4);
 }
