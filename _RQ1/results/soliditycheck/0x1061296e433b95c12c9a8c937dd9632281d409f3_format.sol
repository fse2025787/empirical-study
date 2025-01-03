           pragma solidity ^0.8.0;
 library SafeMath {
 function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 uint256 c = a + b;
 if (c < a) return (false, 0);
 return (true, c);
 }
 }
 function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 if (b > a) return (false, 0);
 return (true, a - b);
 }
 }
 function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 if (a == 0) return (true, 0);
 uint256 c = a * b;
 if (c / a != b) return (false, 0);
 return (true, c);
 }
 }
 function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 if (b == 0) return (false, 0);
 return (true, a / b);
 }
 }
 function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 unchecked {
 if (b == 0) return (false, 0);
 return (true, a % b);
 }
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 return a + b;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 return a - b;
 }
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 return a * b;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 return a / b;
 }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 return a % b;
 }
 function sub( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 unchecked {
 require(b <= a, errorMessage);
 return a - b;
 }
 }
 function div( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 unchecked {
 require(b > 0, errorMessage);
 return a / b;
 }
 }
 function mod( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 unchecked {
 require(b > 0, errorMessage);
 return a % b;
 }
 }
 }
 pragma solidity ^0.8.0;
 library Strings {
 bytes16 private constant alphabet = '0123456789abcdef';
 function toString(uint256 value) internal pure returns (string memory) {
 if (value == 0) {
 return '0';
 }
 uint256 temp = value;
 uint256 digits;
 while (temp != 0) {
 digits++;
 temp /= 10;
 }
 bytes memory buffer = new bytes(digits);
 while (value != 0) {
 digits -= 1;
 buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
 value /= 10;
 }
 return string(buffer);
 }
 function toHexString(uint256 value) internal pure returns (string memory) {
 if (value == 0) {
 return '0x00';
 }
 uint256 temp = value;
 uint256 length = 0;
 while (temp != 0) {
 length++;
 temp >>= 8;
 }
 return toHexString(value, length);
 }
 function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
 bytes memory buffer = new bytes(2 * length + 2);
 buffer[0] = '0';
 buffer[1] = 'x';
 for (uint256 i = 2 * length + 1; i > 1; --i) {
 buffer[i] = alphabet[value & 0xf];
 value >>= 4;
 }
 require(value == 0, 'Strings: hex length insufficient');
 return string(buffer);
 }
 }
 pragma solidity ^0.8.0;
 library Address {
 function isContract(address account) internal view returns (bool) {
 uint256 size;
 assembly {
 size := extcodesize(account) }
 return size > 0;
 }
 function sendValue(address payable recipient, uint256 amount) internal {
 require(address(this).balance >= amount, 'Address: insufficient balance');
 (bool success, ) = recipient.call{
 value: amount}
 ('');
 require(success, 'Address: unable to send value, recipient may have reverted');
 }
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, 'Address: low-level call failed');
 }
 function functionCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 return functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value ) internal returns (bytes memory) {
 return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value, string memory errorMessage ) internal returns (bytes memory) {
 require(address(this).balance >= value, 'Address: insufficient balance for call');
 require(isContract(target), 'Address: call to non-contract');
 (bool success, bytes memory returndata) = target.call{
 value: value}
 (data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
 return functionStaticCall(target, data, 'Address: low-level static call failed');
 }
 function functionStaticCall( address target, bytes memory data, string memory errorMessage ) internal view returns (bytes memory) {
 require(isContract(target), 'Address: static call to non-contract');
 (bool success, bytes memory returndata) = target.staticcall(data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionDelegateCall(target, data, 'Address: low-level delegate call failed');
 }
 function functionDelegateCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 require(isContract(target), 'Address: delegate call to non-contract');
 (bool success, bytes memory returndata) = target.delegatecall(data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function _verifyCallResult( bool success, bytes memory returndata, string memory errorMessage ) private pure returns (bytes memory) {
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
 interface IERC721Receiver {
 function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) external returns (bytes4);
 }
 pragma solidity ^0.8.0;
 interface IERC165 {
 function supportsInterface(bytes4 interfaceId) external view returns (bool);
 }
 pragma solidity ^0.8.0;
 abstract contract ERC165 is IERC165 {
 function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 return interfaceId == type(IERC165).interfaceId;
 }
 }
 pragma solidity ^0.8.0;
 interface IERC721 is IERC165 {
 event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
 event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
 event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
 function balanceOf(address owner) external view returns (uint256 balance);
 function ownerOf(uint256 tokenId) external view returns (address owner);
 function safeTransferFrom( address from, address to, uint256 tokenId ) external;
 function transferFrom( address from, address to, uint256 tokenId ) external;
 function approve(address to, uint256 tokenId) external;
 function getApproved(uint256 tokenId) external view returns (address operator);
 function setApprovalForAll(address operator, bool _approved) external;
 function isApprovedForAll(address owner, address operator) external view returns (bool);
 function safeTransferFrom( address from, address to, uint256 tokenId, bytes calldata data ) external;
 }
 pragma solidity ^0.8.0;
 interface IERC721Enumerable is IERC721 {
 function totalSupply() external view returns (uint256);
 function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
 function tokenByIndex(uint256 index) external view returns (uint256);
 }
 pragma solidity ^0.8.0;
 interface IERC721Metadata is IERC721 {
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function tokenURI(uint256 tokenId) external view returns (string memory);
 }
 pragma solidity ^0.8.0;
 abstract contract Context {
 function _msgSender() internal view virtual returns (address) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes calldata) {
 this;
 return msg.data;
 }
 }
 pragma solidity ^0.8.0;
 abstract contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor() {
 address msgSender = _msgSender();
 _owner = msgSender;
 emit OwnershipTransferred(address(0), msgSender);
 }
 function owner() public view virtual returns (address) {
 return _owner;
 }
 modifier onlyOwner() {
 require(owner() == _msgSender(), 'Ownable: caller is not the owner');
 _;
 }
 function renounceOwnership() public virtual onlyOwner {
 emit OwnershipTransferred(_owner, address(0));
 _owner = address(0);
 }
 function transferOwnership(address newOwner) public virtual onlyOwner {
 require(newOwner != address(0), 'Ownable: new owner is the zero address');
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;
 }
 }
 pragma solidity ^0.8.0;
 contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
 using Address for address;
 using Strings for uint256;
 string private _name;
 string private _symbol;
 mapping(uint256 => address) private _owners;
 mapping(address => uint256) private _balances;
 mapping(uint256 => address) private _tokenApprovals;
 mapping(address => mapping(address => bool)) private _operatorApprovals;
 constructor(string memory name_, string memory symbol_) {
 _name = name_;
 _symbol = symbol_;
 }
 function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
 return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId || super.supportsInterface(interfaceId);
 }
 function balanceOf(address owner) public view virtual override returns (uint256) {
 require(owner != address(0), 'ERC721: balance query for the zero address');
 return _balances[owner];
 }
 function ownerOf(uint256 tokenId) public view virtual override returns (address) {
 address owner = _owners[tokenId];
 require(owner != address(0), 'ERC721: owner query for nonexistent token');
 return owner;
 }
 function name() public view virtual override returns (string memory) {
 return _name;
 }
 function symbol() public view virtual override returns (string memory) {
 return _symbol;
 }
 function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
 require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');
 string memory baseURI = _baseURI();
 return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
 }
 function _baseURI() internal view virtual returns (string memory) {
 return '';
 }
 function approve(address to, uint256 tokenId) public virtual override {
 address owner = ERC721.ownerOf(tokenId);
 require(to != owner, 'ERC721: approval to current owner');
 require( _msgSender() == owner || isApprovedForAll(owner, _msgSender()), 'ERC721: approve caller is not owner nor approved for all' );
 _approve(to, tokenId);
 }
 function getApproved(uint256 tokenId) public view virtual override returns (address) {
 require(_exists(tokenId), 'ERC721: approved query for nonexistent token');
 return _tokenApprovals[tokenId];
 }
 function setApprovalForAll(address operator, bool approved) public virtual override {
 require(operator != _msgSender(), 'ERC721: approve to caller');
 _operatorApprovals[_msgSender()][operator] = approved;
 emit ApprovalForAll(_msgSender(), operator, approved);
 }
 function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
 return _operatorApprovals[owner][operator];
 }
 function transferFrom( address from, address to, uint256 tokenId ) public virtual override {
 require(_isApprovedOrOwner(_msgSender(), tokenId), 'ERC721: transfer caller is not owner nor approved');
 _transfer(from, to, tokenId);
 }
 function safeTransferFrom( address from, address to, uint256 tokenId ) public virtual override {
 safeTransferFrom(from, to, tokenId, '');
 }
 function safeTransferFrom( address from, address to, uint256 tokenId, bytes memory _data ) public virtual override {
 require(_isApprovedOrOwner(_msgSender(), tokenId), 'ERC721: transfer caller is not owner nor approved');
 _safeTransfer(from, to, tokenId, _data);
 }
 function _safeTransfer( address from, address to, uint256 tokenId, bytes memory _data ) internal virtual {
 _transfer(from, to, tokenId);
 require(_checkOnERC721Received(from, to, tokenId, _data), 'ERC721: transfer to non ERC721Receiver implementer');
 }
 function _exists(uint256 tokenId) internal view virtual returns (bool) {
 return _owners[tokenId] != address(0);
 }
 function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
 require(_exists(tokenId), 'ERC721: operator query for nonexistent token');
 address owner = ERC721.ownerOf(tokenId);
 return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
 }
 function _safeMint(address to, uint256 tokenId) internal virtual {
 _safeMint(to, tokenId, '');
 }
 function _safeMint( address to, uint256 tokenId, bytes memory _data ) internal virtual {
 _mint(to, tokenId);
 require( _checkOnERC721Received(address(0), to, tokenId, _data), 'ERC721: transfer to non ERC721Receiver implementer' );
 }
 function _mint(address to, uint256 tokenId) internal virtual {
 require(to != address(0), 'ERC721: mint to the zero address');
 require(!_exists(tokenId), 'ERC721: token already minted');
 _beforeTokenTransfer(address(0), to, tokenId);
 _balances[to] += 1;
 _owners[tokenId] = to;
 emit Transfer(address(0), to, tokenId);
 }
 function _burn(uint256 tokenId) internal virtual {
 address owner = ERC721.ownerOf(tokenId);
 _beforeTokenTransfer(owner, address(0), tokenId);
 _approve(address(0), tokenId);
 _balances[owner] -= 1;
 delete _owners[tokenId];
 emit Transfer(owner, address(0), tokenId);
 }
 function _transfer( address from, address to, uint256 tokenId ) internal virtual {
 require(ERC721.ownerOf(tokenId) == from, 'ERC721: transfer of token that is not own');
 require(to != address(0), 'ERC721: transfer to the zero address');
 _beforeTokenTransfer(from, to, tokenId);
 _approve(address(0), tokenId);
 _balances[from] -= 1;
 _balances[to] += 1;
 _owners[tokenId] = to;
 emit Transfer(from, to, tokenId);
 }
 function _approve(address to, uint256 tokenId) internal virtual {
 _tokenApprovals[tokenId] = to;
 emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
 }
 function _checkOnERC721Received( address from, address to, uint256 tokenId, bytes memory _data ) private returns (bool) {
 if (to.isContract()) {
 try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
 return retval == IERC721Receiver(to).onERC721Received.selector;
 }
 catch (bytes memory reason) {
 if (reason.length == 0) {
 revert('ERC721: transfer to non ERC721Receiver implementer');
 }
 else {
 assembly {
 revert(add(32, reason), mload(reason)) }
 }
 }
 }
 else {
 return true;
 }
 }
 function _beforeTokenTransfer( address from, address to, uint256 tokenId ) internal virtual {
 }
 }
 pragma solidity ^0.8.0;
 abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
 mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
 mapping(uint256 => uint256) private _ownedTokensIndex;
 uint256[] private _allTokens;
 mapping(uint256 => uint256) private _allTokensIndex;
 function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
 return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
 }
 function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
 require(index < ERC721.balanceOf(owner), 'ERC721Enumerable: owner index out of bounds');
 return _ownedTokens[owner][index];
 }
 function totalSupply() public view virtual override returns (uint256) {
 return _allTokens.length;
 }
 function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
 require(index < ERC721Enumerable.totalSupply(), 'ERC721Enumerable: global index out of bounds');
 return _allTokens[index];
 }
 function _beforeTokenTransfer( address from, address to, uint256 tokenId ) internal virtual override {
 super._beforeTokenTransfer(from, to, tokenId);
 if (from == address(0)) {
 _addTokenToAllTokensEnumeration(tokenId);
 }
 else if (from != to) {
 _removeTokenFromOwnerEnumeration(from, tokenId);
 }
 if (to == address(0)) {
 _removeTokenFromAllTokensEnumeration(tokenId);
 }
 else if (to != from) {
 _addTokenToOwnerEnumeration(to, tokenId);
 }
 }
 function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
 uint256 length = ERC721.balanceOf(to);
 _ownedTokens[to][length] = tokenId;
 _ownedTokensIndex[tokenId] = length;
 }
 function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
 _allTokensIndex[tokenId] = _allTokens.length;
 _allTokens.push(tokenId);
 }
 function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
 uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
 uint256 tokenIndex = _ownedTokensIndex[tokenId];
 if (tokenIndex != lastTokenIndex) {
 uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
 _ownedTokens[from][tokenIndex] = lastTokenId;
 _ownedTokensIndex[lastTokenId] = tokenIndex;
 }
 delete _ownedTokensIndex[tokenId];
 delete _ownedTokens[from][lastTokenIndex];
 }
 function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
 uint256 lastTokenIndex = _allTokens.length - 1;
 uint256 tokenIndex = _allTokensIndex[tokenId];
 uint256 lastTokenId = _allTokens[lastTokenIndex];
 _allTokens[tokenIndex] = lastTokenId;
 _allTokensIndex[lastTokenId] = tokenIndex;
 delete _allTokensIndex[tokenId];
 _allTokens.pop();
 }
 }
 pragma solidity ^0.8.0;
 contract Plunder is ERC721Enumerable, Ownable {
 using SafeMath for uint256;
 using Address for address;
 using Strings for uint256;
 uint256 public constant NFT_PRICE = 10000000000000000;
 uint public constant MAX_NFT_PURCHASE = 11;
 uint256 public MAX_PUBLIC_SUPPLY = 4000;
 uint256 public MAX_RESERVE_SUPPLY = 100;
 bool public saleIsActive = false;
 uint public startTimestamp = 1632130200;
 address one_address = 0xe1Dad4ae4BFD1d53D234303655bfc44982D46353;
 address two_address = 0x672c36FA22029369490BB5e33e6d16a7E1309c1e;
 address three_address = 0x59cE6Be860F8E0A4d8880a0AE39Bd0bc63B82672;
 bool public publicMintPaused = false;
 string private _baseURIExtended;
 mapping(uint256 => string) _tokenURIs;
 mapping(address => bool) minted;
 mapping(address => uint256) purchased;
 receive() external payable {
 }
 modifier mintOnlyOnce() {
 require(!minted[_msgSender()], 'Can only mint once');
 minted[_msgSender()] = true;
 _;
 }
 constructor() ERC721("Plodding Pirates Plunder", "Plunder") {
 }
 function flipSaleState() public onlyOwner {
 saleIsActive = !saleIsActive;
 }
 function update_three_address(address new_three_address) public onlyOwner{
 three_address = new_three_address;
 }
 function withdraw() external {
 require( msg.sender == one_address || msg.sender == two_address || msg.sender == three_address );
 uint256 bal = address(this).balance;
 uint256 FortyFive = bal.mul(45).div(100);
 (bool sent1,) = one_address.call{
 value: FortyFive}
 ("");
 require(sent1, "Failed to send Ether");
 uint256 FortyFive1 = bal.mul(45).div(100);
 (bool sent2,) = two_address.call{
 value: FortyFive1}
 ("");
 require(sent2, "Failed to send Ether");
 uint256 Ten = bal.mul(10).div(100);
 (bool sent3,) = three_address.call{
 value: Ten}
 ("");
 require(sent3, "Failed to send Ether");
 uint256 remaining = address(this).balance;
 (bool sent4,) = one_address.call{
 value: remaining}
 ("");
 require(sent4, "Failed to send Ether");
 }
 function mintPlunder(uint numberOfTokens) public payable {
 require(purchased[msg.sender].add(numberOfTokens) <= MAX_NFT_PURCHASE, 'Can only mint up to 10 per address');
 require(block.timestamp >= startTimestamp, "publicMint: Not open yet");
 require(numberOfTokens > 0, "Number of tokens can not be less than or equal to 0");
 require(totalSupply().add(numberOfTokens) <= MAX_PUBLIC_SUPPLY, "Purchase would exceed max supply of tokens");
 require(numberOfTokens <= MAX_NFT_PURCHASE,"Can only mint up to 10 per purchase");
 require(NFT_PRICE.mul(numberOfTokens) == msg.value, "Sent ether value is incorrect");
 purchased[msg.sender] = purchased[msg.sender].add(numberOfTokens);
 for (uint i = 0; i < numberOfTokens; i++) {
 _safeMint(msg.sender, totalSupply());
 }
 }
 function mintPlunderForFree() public mintOnlyOnce {
 require(saleIsActive, 'Sale is not active at the moment');
 require(totalSupply().add(1) <= MAX_PUBLIC_SUPPLY, 'Purchase would exceed max public supply of tokens');
 _safeMint(msg.sender, totalSupply());
 }
 function reserveTokens() public onlyOwner {
 require(totalSupply().add(1) <= MAX_RESERVE_SUPPLY, 'Purchase would exceed max reserve supply of tokens');
 _safeMint(msg.sender, totalSupply());
 }
 function _baseURI() internal view virtual override returns (string memory) {
 return _baseURIExtended;
 }
 function setBaseURI(string memory baseURI_) external onlyOwner {
 _baseURIExtended = baseURI_;
 }
 function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
 require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');
 string memory _tokenURI = _tokenURIs[tokenId];
 string memory base = _baseURI();
 if (bytes(base).length == 0) {
 return _tokenURI;
 }
 if (bytes(_tokenURI).length > 0) {
 return string(abi.encodePacked(base, _tokenURI));
 }
 return string(abi.encodePacked(base, tokenId.toString()));
 }
 }
