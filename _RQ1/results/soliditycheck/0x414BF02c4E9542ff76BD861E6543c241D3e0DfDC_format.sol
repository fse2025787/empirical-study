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
 library Counters {
 struct Counter {
 uint256 _value;
 }
 function current(Counter storage counter) internal view returns (uint256) {
 return counter._value;
 }
 function increment(Counter storage counter) internal {
 unchecked {
 counter._value += 1;
 }
 }
 function decrement(Counter storage counter) internal {
 uint256 value = counter._value;
 require(value > 0, "Counter: decrement overflow");
 unchecked {
 counter._value = value - 1;
 }
 }
 function reset(Counter storage counter) internal {
 counter._value = 0;
 }
 }
 pragma solidity ^0.8.0;
 abstract contract ReentrancyGuard {
 uint256 private constant _NOT_ENTERED = 1;
 uint256 private constant _ENTERED = 2;
 uint256 private _status;
 constructor() {
 _status = _NOT_ENTERED;
 }
 modifier nonReentrant() {
 require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
 _status = _ENTERED;
 _;
 _status = _NOT_ENTERED;
 }
 }
 pragma solidity ^0.8.0;
 interface IERC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 }
 pragma solidity ^0.8.0;
 pragma solidity ^0.8.0;
 library Strings {
 bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
 function toString(uint256 value) internal pure returns (string memory) {
 if (value == 0) {
 return "0";
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
 return "0x00";
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
 buffer[0] = "0";
 buffer[1] = "x";
 for (uint256 i = 2 * length + 1; i > 1; --i) {
 buffer[i] = _HEX_SYMBOLS[value & 0xf];
 value >>= 4;
 }
 require(value == 0, "Strings: hex length insufficient");
 return string(buffer);
 }
 }
 pragma solidity ^0.8.0;
 abstract contract Context {
 function _msgSender() internal view virtual returns (address) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes calldata) {
 return msg.data;
 }
 }
 pragma solidity ^0.8.0;
 abstract contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor() {
 _transferOwnership(_msgSender());
 }
 function owner() public view virtual returns (address) {
 return _owner;
 }
 modifier onlyOwner() {
 require(owner() == _msgSender(), "Ownable: caller is not the owner");
 _;
 }
 function renounceOwnership() public virtual onlyOwner {
 _transferOwnership(address(0));
 }
 function transferOwnership(address newOwner) public virtual onlyOwner {
 require(newOwner != address(0), "Ownable: new owner is the zero address");
 _transferOwnership(newOwner);
 }
 function _transferOwnership(address newOwner) internal virtual {
 address oldOwner = _owner;
 _owner = newOwner;
 emit OwnershipTransferred(oldOwner, newOwner);
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
 interface IERC721Receiver {
 function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) external returns (bytes4);
 }
 pragma solidity ^0.8.0;
 interface IERC165 {
 function supportsInterface(bytes4 interfaceId) external view returns (bool);
 }
 pragma solidity ^0.8.0;
 pragma solidity ^0.8.0;
 interface IERC2981 is IERC165 {
 function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount);
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
 interface IERC721Metadata is IERC721 {
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function tokenURI(uint256 tokenId) external view returns (string memory);
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
 require(owner != address(0), "ERC721: balance query for the zero address");
 return _balances[owner];
 }
 function ownerOf(uint256 tokenId) public view virtual override returns (address) {
 address owner = _owners[tokenId];
 require(owner != address(0), "ERC721: owner query for nonexistent token");
 return owner;
 }
 function name() public view virtual override returns (string memory) {
 return _name;
 }
 function symbol() public view virtual override returns (string memory) {
 return _symbol;
 }
 function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
 require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
 string memory baseURI = _baseURI();
 return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
 }
 function _baseURI() internal view virtual returns (string memory) {
 return "";
 }
 function approve(address to, uint256 tokenId) public virtual override {
 address owner = ERC721.ownerOf(tokenId);
 require(to != owner, "ERC721: approval to current owner");
 require( _msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not owner nor approved for all" );
 _approve(to, tokenId);
 }
 function getApproved(uint256 tokenId) public view virtual override returns (address) {
 require(_exists(tokenId), "ERC721: approved query for nonexistent token");
 return _tokenApprovals[tokenId];
 }
 function setApprovalForAll(address operator, bool approved) public virtual override {
 _setApprovalForAll(_msgSender(), operator, approved);
 }
 function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
 return _operatorApprovals[owner][operator];
 }
 function transferFrom( address from, address to, uint256 tokenId ) public virtual override {
 require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
 _transfer(from, to, tokenId);
 }
 function safeTransferFrom( address from, address to, uint256 tokenId ) public virtual override {
 safeTransferFrom(from, to, tokenId, "");
 }
 function safeTransferFrom( address from, address to, uint256 tokenId, bytes memory _data ) public virtual override {
 require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
 _safeTransfer(from, to, tokenId, _data);
 }
 function _safeTransfer( address from, address to, uint256 tokenId, bytes memory _data ) internal virtual {
 _transfer(from, to, tokenId);
 require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
 }
 function _exists(uint256 tokenId) internal view virtual returns (bool) {
 return _owners[tokenId] != address(0);
 }
 function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
 require(_exists(tokenId), "ERC721: operator query for nonexistent token");
 address owner = ERC721.ownerOf(tokenId);
 return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
 }
 function _safeMint(address to, uint256 tokenId) internal virtual {
 _safeMint(to, tokenId, "");
 }
 function _safeMint( address to, uint256 tokenId, bytes memory _data ) internal virtual {
 _mint(to, tokenId);
 require( _checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer" );
 }
 function _mint(address to, uint256 tokenId) internal virtual {
 require(to != address(0), "ERC721: mint to the zero address");
 require(!_exists(tokenId), "ERC721: token already minted");
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
 require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
 require(to != address(0), "ERC721: transfer to the zero address");
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
 function _setApprovalForAll( address owner, address operator, bool approved ) internal virtual {
 require(owner != operator, "ERC721: approve to caller");
 _operatorApprovals[owner][operator] = approved;
 emit ApprovalForAll(owner, operator, approved);
 }
 function _checkOnERC721Received( address from, address to, uint256 tokenId, bytes memory _data ) private returns (bool) {
 if (to.isContract()) {
 try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
 return retval == IERC721Receiver.onERC721Received.selector;
 }
 catch (bytes memory reason) {
 if (reason.length == 0) {
 revert("ERC721: transfer to non ERC721Receiver implementer");
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
 contract POF is ERC721, IERC2981, Ownable, ReentrancyGuard {
 using Counters for Counters.Counter;
 using Strings for uint256;
 Counters.Counter private tokenCounter;
 string private baseURI = "https: address private openSeaProxyRegistryAddress = 0xa5409ec958C83C3f309868babACA7c86DCB077c1;
 bool private isOpenSeaProxyActive = true;
 uint256 public MAX_MINTS_PER_TX = 10;
 uint256 public PUBLIC_SALE_PRICE = 0.03 ether;
 uint256 public NUM_FREE_MINTS = 600;
 uint256 public MAX_FREE_PER_WALLET = 2;
 uint256 public maxSupply = 2100;
 uint256 public freeNFTAlreadyMinted = 0;
 bool public isPublicSaleActive = true;
 modifier publicSaleActive() {
 require(isPublicSaleActive, "Public sale is not open");
 _;
 }
 modifier canMintNFTs(uint256 numberOfTokens) {
 require( tokenCounter.current() + numberOfTokens <= maxSupply, "Not enough mints remaining to mint" );
 _;
 }
 constructor( ) ERC721("People In Their Own Fashion", "POF") {
 }
 function mint(uint256 numberOfTokens) external payable nonReentrant publicSaleActive canMintNFTs(numberOfTokens) {
 if(freeNFTAlreadyMinted + numberOfTokens > NUM_FREE_MINTS){
 require( (PUBLIC_SALE_PRICE * numberOfTokens) <= msg.value, "Incorrect ETH value sent" );
 }
 else {
 if (balanceOf(msg.sender) + numberOfTokens > MAX_FREE_PER_WALLET) {
 require( (PUBLIC_SALE_PRICE * numberOfTokens) <= msg.value, "Incorrect ETH value sent" );
 require( numberOfTokens <= MAX_MINTS_PER_TX, "Max mints per transaction exceeded" );
 }
 else {
 require( numberOfTokens <= MAX_FREE_PER_WALLET, "Max mints per transaction exceeded" );
 freeNFTAlreadyMinted += numberOfTokens;
 }
 }
 for (uint256 i = 0; i < numberOfTokens; i++) {
 _safeMint(msg.sender, nextTokenId());
 }
 }
 function getBaseURI() external view returns (string memory) {
 return baseURI;
 }
 function getLastTokenId() external view returns (uint256) {
 return tokenCounter.current();
 }
 function totalSupply() external view returns (uint256) {
 return tokenCounter.current();
 }
 function setBaseURI(string memory _baseURI) external onlyOwner {
 baseURI = _baseURI;
 }
 function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive) external onlyOwner {
 isOpenSeaProxyActive = _isOpenSeaProxyActive;
 }
 function setIsPublicSaleActive(bool _isPublicSaleActive) external onlyOwner {
 isPublicSaleActive = _isPublicSaleActive;
 }
 function setNumFreeMints(uint256 _numfreemints) external onlyOwner {
 NUM_FREE_MINTS = _numfreemints;
 }
 function setSalePrice(uint256 _price) external onlyOwner {
 PUBLIC_SALE_PRICE = _price;
 }
 function setMaxLimitPerTransaction(uint256 _limit) external onlyOwner {
 MAX_MINTS_PER_TX = _limit;
 }
 function setFreeLimitPerWallet(uint256 _limit) external onlyOwner {
 MAX_FREE_PER_WALLET = _limit;
 }
 function withdraw() public onlyOwner {
 uint256 balance = address(this).balance;
 payable(msg.sender).transfer(balance);
 }
 function withdrawTokens(IERC20 token) public onlyOwner {
 uint256 balance = token.balanceOf(address(this));
 token.transfer(msg.sender, balance);
 }
 function nextTokenId() private returns (uint256) {
 tokenCounter.increment();
 return tokenCounter.current();
 }
 function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165) returns (bool) {
 return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
 }
 function isApprovedForAll(address owner, address operator) public view override returns (bool) {
 ProxyRegistry proxyRegistry = ProxyRegistry( openSeaProxyRegistryAddress );
 if ( isOpenSeaProxyActive && address(proxyRegistry.proxies(owner)) == operator ) {
 return true;
 }
 return super.isApprovedForAll(owner, operator);
 }
 function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
 require(_exists(tokenId), "Nonexistent token");
 return string(abi.encodePacked(baseURI, "/", tokenId.toString(), ".json"));
 }
 function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
 require(_exists(tokenId), "Nonexistent token");
 return (address(this), SafeMath.div(SafeMath.mul(salePrice, 10), 100));
 }
 }
 contract OwnableDelegateProxy {
 }
 contract ProxyRegistry {
 mapping(address => OwnableDelegateProxy) public proxies;
 }
