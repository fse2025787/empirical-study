           pragma solidity ^0.8.4;
 interface IERC721A {
 error ApprovalCallerNotOwnerNorApproved();
 error ApprovalQueryForNonexistentToken();
 error ApproveToCaller();
 error BalanceQueryForZeroAddress();
 error MintToZeroAddress();
 error MintZeroQuantity();
 error OwnerQueryForNonexistentToken();
 error TransferCallerNotOwnerNorApproved();
 error TransferFromIncorrectOwner();
 error TransferToNonERC721ReceiverImplementer();
 error TransferToZeroAddress();
 error URIQueryForNonexistentToken();
 error MintERC2309QuantityExceedsLimit();
 error OwnershipNotInitializedForExtraData();
 struct TokenOwnership {
 address addr;
 uint64 startTimestamp;
 bool burned;
 uint24 extraData;
 }
 function totalSupply() external view returns (uint256);
 function supportsInterface(bytes4 interfaceId) external view returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
 event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
 event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
 function balanceOf(address owner) external view returns (uint256 balance);
 function ownerOf(uint256 tokenId) external view returns (address owner);
 function safeTransferFrom( address from, address to, uint256 tokenId, bytes calldata data ) external;
 function safeTransferFrom( address from, address to, uint256 tokenId ) external;
 function transferFrom( address from, address to, uint256 tokenId ) external;
 function approve(address to, uint256 tokenId) external;
 function setApprovalForAll(address operator, bool _approved) external;
 function getApproved(uint256 tokenId) external view returns (address operator);
 function isApprovedForAll(address owner, address operator) external view returns (bool);
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function tokenURI(uint256 tokenId) external view returns (string memory);
 event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
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
 modifier onlyOwner() {
 _checkOwner();
 _;
 }
 function owner() public view virtual returns (address) {
 return _owner;
 }
 function _checkOwner() internal view virtual {
 require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
 contract ERC721A is IERC721A {
 uint256 private constant BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;
 uint256 private constant BITPOS_NUMBER_MINTED = 64;
 uint256 private constant BITPOS_NUMBER_BURNED = 128;
 uint256 private constant BITPOS_AUX = 192;
 uint256 private constant BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;
 uint256 private constant BITPOS_START_TIMESTAMP = 160;
 uint256 private constant BITMASK_BURNED = 1 << 224;
 uint256 private constant BITPOS_NEXT_INITIALIZED = 225;
 uint256 private constant BITMASK_NEXT_INITIALIZED = 1 << 225;
 uint256 private constant BITPOS_EXTRA_DATA = 232;
 uint256 private constant BITMASK_EXTRA_DATA_COMPLEMENT = (1 << 232) - 1;
 uint256 private constant BITMASK_ADDRESS = (1 << 160) - 1;
 uint256 private constant MAX_MINT_ERC2309_QUANTITY_LIMIT = 5000;
 uint256 private _currentIndex;
 uint256 private _burnCounter;
 string private _name;
 string private _symbol;
 mapping(uint256 => uint256) private _packedOwnerships;
 mapping(address => uint256) private _packedAddressData;
 mapping(uint256 => address) private _tokenApprovals;
 mapping(address => mapping(address => bool)) private _operatorApprovals;
 constructor(string memory name_, string memory symbol_) {
 _name = name_;
 _symbol = symbol_;
 _currentIndex = _startTokenId();
 }
 function _startTokenId() internal view virtual returns (uint256) {
 return 0;
 }
 function _nextTokenId() internal view returns (uint256) {
 return _currentIndex;
 }
 function totalSupply() public view override returns (uint256) {
 unchecked {
 return _currentIndex - _burnCounter - _startTokenId();
 }
 }
 function _totalMinted() internal view returns (uint256) {
 unchecked {
 return _currentIndex - _startTokenId();
 }
 }
 function _totalBurned() internal view returns (uint256) {
 return _burnCounter;
 }
 function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 return interfaceId == 0x01ffc9a7 || interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f;
 }
 function balanceOf(address owner) public view override returns (uint256) {
 if (owner == address(0)) revert BalanceQueryForZeroAddress();
 return _packedAddressData[owner] & BITMASK_ADDRESS_DATA_ENTRY;
 }
 function _numberMinted(address owner) internal view returns (uint256) {
 return (_packedAddressData[owner] >> BITPOS_NUMBER_MINTED) & BITMASK_ADDRESS_DATA_ENTRY;
 }
 function _numberBurned(address owner) internal view returns (uint256) {
 return (_packedAddressData[owner] >> BITPOS_NUMBER_BURNED) & BITMASK_ADDRESS_DATA_ENTRY;
 }
 function _getAux(address owner) internal view returns (uint64) {
 return uint64(_packedAddressData[owner] >> BITPOS_AUX);
 }
 function _setAux(address owner, uint64 aux) internal {
 uint256 packed = _packedAddressData[owner];
 uint256 auxCasted;
 assembly {
 auxCasted := aux }
 packed = (packed & BITMASK_AUX_COMPLEMENT) | (auxCasted << BITPOS_AUX);
 _packedAddressData[owner] = packed;
 }
 function _packedOwnershipOf(uint256 tokenId) private view returns (uint256) {
 uint256 curr = tokenId;
 unchecked {
 if (_startTokenId() <= curr) if (curr < _currentIndex) {
 uint256 packed = _packedOwnerships[curr];
 if (packed & BITMASK_BURNED == 0) {
 while (packed == 0) {
 packed = _packedOwnerships[--curr];
 }
 return packed;
 }
 }
 }
 revert OwnerQueryForNonexistentToken();
 }
 function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership) {
 ownership.addr = address(uint160(packed));
 ownership.startTimestamp = uint64(packed >> BITPOS_START_TIMESTAMP);
 ownership.burned = packed & BITMASK_BURNED != 0;
 ownership.extraData = uint24(packed >> BITPOS_EXTRA_DATA);
 }
 function _ownershipAt(uint256 index) internal view returns (TokenOwnership memory) {
 return _unpackedOwnership(_packedOwnerships[index]);
 }
 function _initializeOwnershipAt(uint256 index) internal {
 if (_packedOwnerships[index] == 0) {
 _packedOwnerships[index] = _packedOwnershipOf(index);
 }
 }
 function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
 return _unpackedOwnership(_packedOwnershipOf(tokenId));
 }
 function _packOwnershipData(address owner, uint256 flags) private view returns (uint256 result) {
 assembly {
 owner := and(owner, BITMASK_ADDRESS) result := or(owner, or(shl(BITPOS_START_TIMESTAMP, timestamp()), flags)) }
 }
 function ownerOf(uint256 tokenId) public view override returns (address) {
 return address(uint160(_packedOwnershipOf(tokenId)));
 }
 function name() public view virtual override returns (string memory) {
 return _name;
 }
 function symbol() public view virtual override returns (string memory) {
 return _symbol;
 }
 function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
 if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
 string memory baseURI = _baseURI();
 return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
 }
 function _baseURI() internal view virtual returns (string memory) {
 return '';
 }
 function _nextInitializedFlag(uint256 quantity) private pure returns (uint256 result) {
 assembly {
 result := shl(BITPOS_NEXT_INITIALIZED, eq(quantity, 1)) }
 }
 function approve(address to, uint256 tokenId) public override {
 address owner = ownerOf(tokenId);
 if (_msgSenderERC721A() != owner) if (!isApprovedForAll(owner, _msgSenderERC721A())) {
 revert ApprovalCallerNotOwnerNorApproved();
 }
 _tokenApprovals[tokenId] = to;
 emit Approval(owner, to, tokenId);
 }
 function getApproved(uint256 tokenId) public view override returns (address) {
 if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();
 return _tokenApprovals[tokenId];
 }
 function setApprovalForAll(address operator, bool approved) public virtual override {
 if (operator == _msgSenderERC721A()) revert ApproveToCaller();
 _operatorApprovals[_msgSenderERC721A()][operator] = approved;
 emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
 }
 function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
 return _operatorApprovals[owner][operator];
 }
 function safeTransferFrom( address from, address to, uint256 tokenId ) public virtual override {
 safeTransferFrom(from, to, tokenId, '');
 }
 function safeTransferFrom( address from, address to, uint256 tokenId, bytes memory _data ) public virtual override {
 transferFrom(from, to, tokenId);
 if (to.code.length != 0) if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
 revert TransferToNonERC721ReceiverImplementer();
 }
 }
 function _exists(uint256 tokenId) internal view returns (bool) {
 return _startTokenId() <= tokenId && tokenId < _currentIndex && _packedOwnerships[tokenId] & BITMASK_BURNED == 0;
 }
 function _safeMint(address to, uint256 quantity) internal {
 _safeMint(to, quantity, '');
 }
 function _safeMint( address to, uint256 quantity, bytes memory _data ) internal {
 _mint(to, quantity);
 unchecked {
 if (to.code.length != 0) {
 uint256 end = _currentIndex;
 uint256 index = end - quantity;
 do {
 if (!_checkContractOnERC721Received(address(0), to, index++, _data)) {
 revert TransferToNonERC721ReceiverImplementer();
 }
 }
 while (index < end);
 if (_currentIndex != end) revert();
 }
 }
 }
 function _mint(address to, uint256 quantity) internal {
 uint256 startTokenId = _currentIndex;
 if (to == address(0)) revert MintToZeroAddress();
 if (quantity == 0) revert MintZeroQuantity();
 _beforeTokenTransfers(address(0), to, startTokenId, quantity);
 unchecked {
 _packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);
 _packedOwnerships[startTokenId] = _packOwnershipData( to, _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0) );
 uint256 tokenId = startTokenId;
 uint256 end = startTokenId + quantity;
 do {
 emit Transfer(address(0), to, tokenId++);
 }
 while (tokenId < end);
 _currentIndex = end;
 }
 _afterTokenTransfers(address(0), to, startTokenId, quantity);
 }
 function _mintERC2309(address to, uint256 quantity) internal {
 uint256 startTokenId = _currentIndex;
 if (to == address(0)) revert MintToZeroAddress();
 if (quantity == 0) revert MintZeroQuantity();
 if (quantity > MAX_MINT_ERC2309_QUANTITY_LIMIT) revert MintERC2309QuantityExceedsLimit();
 _beforeTokenTransfers(address(0), to, startTokenId, quantity);
 unchecked {
 _packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);
 _packedOwnerships[startTokenId] = _packOwnershipData( to, _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0) );
 emit ConsecutiveTransfer(startTokenId, startTokenId + quantity - 1, address(0), to);
 _currentIndex = startTokenId + quantity;
 }
 _afterTokenTransfers(address(0), to, startTokenId, quantity);
 }
 function _getApprovedAddress(uint256 tokenId) private view returns (uint256 approvedAddressSlot, address approvedAddress) {
 mapping(uint256 => address) storage tokenApprovalsPtr = _tokenApprovals;
 assembly {
 mstore(0x00, tokenId) mstore(0x20, tokenApprovalsPtr.slot) approvedAddressSlot := keccak256(0x00, 0x40) approvedAddress := sload(approvedAddressSlot) }
 }
 function _isOwnerOrApproved( address approvedAddress, address from, address msgSender ) private pure returns (bool result) {
 assembly {
 from := and(from, BITMASK_ADDRESS) msgSender := and(msgSender, BITMASK_ADDRESS) result := or(eq(msgSender, from), eq(msgSender, approvedAddress)) }
 }
 function transferFrom( address from, address to, uint256 tokenId ) public virtual override {
 uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);
 if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();
 (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedAddress(tokenId);
 if (!_isOwnerOrApproved(approvedAddress, from, _msgSenderERC721A())) if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();
 if (to == address(0)) revert TransferToZeroAddress();
 _beforeTokenTransfers(from, to, tokenId, 1);
 assembly {
 if approvedAddress {
 sstore(approvedAddressSlot, 0) }
 }
 unchecked {
 --_packedAddressData[from];
 ++_packedAddressData[to];
 _packedOwnerships[tokenId] = _packOwnershipData( to, BITMASK_NEXT_INITIALIZED | _nextExtraData(from, to, prevOwnershipPacked) );
 if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
 uint256 nextTokenId = tokenId + 1;
 if (_packedOwnerships[nextTokenId] == 0) {
 if (nextTokenId != _currentIndex) {
 _packedOwnerships[nextTokenId] = prevOwnershipPacked;
 }
 }
 }
 }
 emit Transfer(from, to, tokenId);
 _afterTokenTransfers(from, to, tokenId, 1);
 }
 function _burn(uint256 tokenId) internal virtual {
 _burn(tokenId, false);
 }
 function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
 uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);
 address from = address(uint160(prevOwnershipPacked));
 (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedAddress(tokenId);
 if (approvalCheck) {
 if (!_isOwnerOrApproved(approvedAddress, from, _msgSenderERC721A())) if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();
 }
 _beforeTokenTransfers(from, address(0), tokenId, 1);
 assembly {
 if approvedAddress {
 sstore(approvedAddressSlot, 0) }
 }
 unchecked {
 _packedAddressData[from] += (1 << BITPOS_NUMBER_BURNED) - 1;
 _packedOwnerships[tokenId] = _packOwnershipData( from, (BITMASK_BURNED | BITMASK_NEXT_INITIALIZED) | _nextExtraData(from, address(0), prevOwnershipPacked) );
 if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
 uint256 nextTokenId = tokenId + 1;
 if (_packedOwnerships[nextTokenId] == 0) {
 if (nextTokenId != _currentIndex) {
 _packedOwnerships[nextTokenId] = prevOwnershipPacked;
 }
 }
 }
 }
 emit Transfer(from, address(0), tokenId);
 _afterTokenTransfers(from, address(0), tokenId, 1);
 unchecked {
 _burnCounter++;
 }
 }
 function _checkContractOnERC721Received( address from, address to, uint256 tokenId, bytes memory _data ) private returns (bool) {
 try ERC721A__IERC721Receiver(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data) returns ( bytes4 retval ) {
 return retval == ERC721A__IERC721Receiver(to).onERC721Received.selector;
 }
 catch (bytes memory reason) {
 if (reason.length == 0) {
 revert TransferToNonERC721ReceiverImplementer();
 }
 else {
 assembly {
 revert(add(32, reason), mload(reason)) }
 }
 }
 }
 function _setExtraDataAt(uint256 index, uint24 extraData) internal {
 uint256 packed = _packedOwnerships[index];
 if (packed == 0) revert OwnershipNotInitializedForExtraData();
 uint256 extraDataCasted;
 assembly {
 extraDataCasted := extraData }
 packed = (packed & BITMASK_EXTRA_DATA_COMPLEMENT) | (extraDataCasted << BITPOS_EXTRA_DATA);
 _packedOwnerships[index] = packed;
 }
 function _nextExtraData( address from, address to, uint256 prevOwnershipPacked ) private view returns (uint256) {
 uint24 extraData = uint24(prevOwnershipPacked >> BITPOS_EXTRA_DATA);
 return uint256(_extraData(from, to, extraData)) << BITPOS_EXTRA_DATA;
 }
 function _extraData( address from, address to, uint24 previousExtraData ) internal view virtual returns (uint24) {
 }
 function _beforeTokenTransfers( address from, address to, uint256 startTokenId, uint256 quantity ) internal virtual {
 }
 function _afterTokenTransfers( address from, address to, uint256 startTokenId, uint256 quantity ) internal virtual {
 }
 function _msgSenderERC721A() internal view virtual returns (address) {
 return msg.sender;
 }
 function _toString(uint256 value) internal pure returns (string memory ptr) {
 assembly {
 ptr := add(mload(0x40), 128) mstore(0x40, ptr) let end := ptr for {
 let temp := value ptr := sub(ptr, 1) mstore8(ptr, add(48, mod(temp, 10))) temp := div(temp, 10) }
 temp {
 temp := div(temp, 10) }
 {
 ptr := sub(ptr, 1) mstore8(ptr, add(48, mod(temp, 10))) }
 let length := sub(end, ptr) ptr := sub(ptr, 32) mstore(ptr, length) }
 }
 }
 pragma solidity ^0.8.0;
 error HadClaimed();
 error OutofMaxSupply();
 contract mooners is ERC721A, Ownable {
 using Strings for uint256;
 mapping(address => bool) public claimed;
 bool freeMintActive = false;
 uint256 public constant MAX_SUPPLY = 5000;
 uint256 public cost = 0.009 ether;
 string public baseUrl = "ipfs: constructor() ERC721A("mooners", "moon") {
 }
 function freeMint(uint256 _amount) external payable {
 require(freeMintActive, "Free mint closed");
 if(totalSupply() + _amount > MAX_SUPPLY) revert OutofMaxSupply();
 if(claimed[msg.sender]) {
 require(msg.value >= _amount * cost, "Insufficient funds");
 }
 else {
 require(msg.value >= (_amount - 1) * cost, "Insufficient funds");
 }
 claimed[msg.sender] = true;
 _safeMint(msg.sender, _amount);
 }
 function revive() external payable {
 require(!freeMintActive, "Free mint is open");
 require(msg.value >= cost, "Insufficient funds");
 if(totalSupply() + 1 > MAX_SUPPLY) revert OutofMaxSupply();
 _safeMint(msg.sender, 1);
 }
 function ownerBatchMint(uint256 amount) external onlyOwner {
 if(totalSupply() + amount > MAX_SUPPLY) revert OutofMaxSupply();
 _safeMint(msg.sender, amount);
 }
 function batchBurn(uint256[] memory tokenids) external onlyOwner {
 uint256 len = tokenids.length;
 for (uint256 i; i < len; i++) {
 _burn(tokenids[i]);
 }
 }
 function toggleFreeMint(bool _state) external onlyOwner {
 freeMintActive = _state;
 }
 function withdraw() external onlyOwner {
 (bool os, ) = payable(owner()).call{
 value: address(this).balance}
 ('');
 require(os);
 }
 function setBaseURI(string memory url) external onlyOwner {
 baseUrl = url;
 }
 function setCost(uint256 _cost) external onlyOwner {
 cost = _cost;
 }
 function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
 string memory currentBaseURI = _baseURI();
 return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), ".json")) : '';
 }
 function _baseURI() internal view virtual override returns (string memory) {
 return baseUrl;
 }
 function _startTokenId() internal view virtual override returns (uint256) {
 return 1;
 }
 }
 pragma solidity ^0.8.0;
 library Strings {
 bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
 uint8 private constant _ADDRESS_LENGTH = 20;
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
 function toHexString(address addr) internal pure returns (string memory) {
 return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
 }
 }
 pragma solidity ^0.8.4;
 interface ERC721A__IERC721Receiver {
 function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) external returns (bytes4);
 }
