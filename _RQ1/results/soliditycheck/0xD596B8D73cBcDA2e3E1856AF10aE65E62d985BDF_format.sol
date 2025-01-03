  pragma abicoder v2;
 pragma solidity >=0.4.24 <0.8.0;
 abstract contract Initializable {
 bool private _initialized;
 bool private _initializing;
 modifier initializer() {
 require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");
 bool isTopLevelCall = !_initializing;
 if (isTopLevelCall) {
 _initializing = true;
 _initialized = true;
 }
 _;
 if (isTopLevelCall) {
 _initializing = false;
 }
 }
 function _isConstructor() private view returns (bool) {
 return !AddressUpgradeable.isContract(address(this));
 }
 }
 pragma solidity ^0.7.0;
 abstract contract ReentrancyGuardUpgradeable is Initializable {
 uint256 private constant _NOT_ENTERED = 1;
 uint256 private constant _ENTERED = 2;
 uint256 private _status;
 function __ReentrancyGuard_init() internal initializer {
 __ReentrancyGuard_init_unchained();
 }
 function __ReentrancyGuard_init_unchained() internal initializer {
 _status = _NOT_ENTERED;
 }
 modifier nonReentrant() {
 require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
 _status = _ENTERED;
 _;
 _status = _NOT_ENTERED;
 }
 uint256[49] private __gap;
 }
 pragma solidity ^0.7.0;
 abstract contract FoundationTreasuryNode is Initializable {
 using AddressUpgradeable for address payable;
 address payable private treasury;
 function _initializeFoundationTreasuryNode(address payable _treasury) internal initializer {
 require(_treasury.isContract(), "FoundationTreasuryNode: Address is not a contract");
 treasury = _treasury;
 }
 function getFoundationTreasury() public view returns (address payable) {
 return treasury;
 }
 uint256[2000] private __gap;
 }
 pragma solidity ^0.7.0;
 abstract contract NFTMarketCore {
 function _getSellerFor(address nftContract, uint256 tokenId) internal view virtual returns (address) {
 return IERC721Upgradeable(nftContract).ownerOf(tokenId);
 }
 uint256[950] private ______gap;
 }
 pragma solidity ^0.7.0;
 abstract contract SendValueWithFallbackWithdraw is ReentrancyGuardUpgradeable {
 using AddressUpgradeable for address payable;
 using SafeMathUpgradeable for uint256;
 mapping(address => uint256) private pendingWithdrawals;
 event WithdrawPending(address indexed user, uint256 amount);
 event Withdrawal(address indexed user, uint256 amount);
 function getPendingWithdrawal(address user) public view returns (uint256) {
 return pendingWithdrawals[user];
 }
 function withdraw() public nonReentrant {
 uint256 amount = pendingWithdrawals[msg.sender];
 require(amount > 0, "No funds are pending withdrawal");
 pendingWithdrawals[msg.sender] = 0;
 msg.sender.sendValue(amount);
 emit Withdrawal(msg.sender, amount);
 }
 function _sendValueWithFallbackWithdraw(address payable user, uint256 amount) internal {
 if (amount == 0) {
 return;
 }
 (bool success, ) = user.call{
 value: amount, gas: 20000 }
 ("");
 if (!success) {
 pendingWithdrawals[user] = pendingWithdrawals[user].add(amount);
 emit WithdrawPending(user, amount);
 }
 }
 uint256[499] private ______gap;
 }
 pragma solidity ^0.7.0;
 abstract contract NFTMarketCreators is ReentrancyGuardUpgradeable {
 function getCreator(address nftContract, uint256 tokenId) internal view returns (address payable) {
 try IFNDNFT721(nftContract).tokenCreator(tokenId) returns (address payable creator) {
 return creator;
 }
 catch {
 return address(0);
 }
 }
 uint256[500] private ______gap;
 }
 pragma solidity ^0.7.0;
 abstract contract Constants {
 uint256 internal constant BASIS_POINTS = 10000;
 }
 pragma solidity ^0.7.0;
 abstract contract FoundationAdminRole is FoundationTreasuryNode {
 modifier onlyFoundationAdmin() {
 require( IAdminRole(getFoundationTreasury()).isAdmin(msg.sender), "FoundationAdminRole: caller does not have the Admin role" );
 _;
 }
 }
 pragma solidity ^0.7.0;
 abstract contract NFTMarketFees is Constants, Initializable, FoundationTreasuryNode, NFTMarketCore, NFTMarketCreators, SendValueWithFallbackWithdraw {
 using SafeMathUpgradeable for uint256;
 event MarketFeesUpdated( uint256 primaryFoundationFeeBasisPoints, uint256 secondaryFoundationFeeBasisPoints, uint256 secondaryCreatorFeeBasisPoints );
 uint256 private _primaryFoundationFeeBasisPoints;
 uint256 private _secondaryFoundationFeeBasisPoints;
 uint256 private _secondaryCreatorFeeBasisPoints;
 mapping(address => mapping(uint256 => bool)) private nftContractToTokenIdToFirstSaleCompleted;
 function getIsPrimary(address nftContract, uint256 tokenId) public view returns (bool) {
 return _getIsPrimary(nftContract, tokenId, _getSellerFor(nftContract, tokenId));
 }
 function _getIsPrimary( address nftContract, uint256 tokenId, address seller ) private view returns (bool) {
 return !nftContractToTokenIdToFirstSaleCompleted[nftContract][tokenId] && getCreator(nftContract, tokenId) == seller;
 }
 function getFeeConfig() public view returns ( uint256 primaryFoundationFeeBasisPoints, uint256 secondaryFoundationFeeBasisPoints, uint256 secondaryCreatorFeeBasisPoints ) {
 return (_primaryFoundationFeeBasisPoints, _secondaryFoundationFeeBasisPoints, _secondaryCreatorFeeBasisPoints);
 }
 function getFees( address nftContract, uint256 tokenId, uint256 price ) public view returns ( uint256 foundationFee, uint256 creatorSecondaryFee, uint256 ownerRev ) {
 return _getFees(nftContract, tokenId, _getSellerFor(nftContract, tokenId), price);
 }
 function _getFees( address nftContract, uint256 tokenId, address seller, uint256 price ) public view returns ( uint256 foundationFee, uint256 creatorSecondaryFee, uint256 ownerRev ) {
 uint256 foundationFeeBasisPoints;
 if (_getIsPrimary(nftContract, tokenId, seller)) {
 foundationFeeBasisPoints = _primaryFoundationFeeBasisPoints;
 }
 else {
 foundationFeeBasisPoints = _secondaryFoundationFeeBasisPoints;
 creatorSecondaryFee = price.mul(_secondaryCreatorFeeBasisPoints) / BASIS_POINTS;
 }
 foundationFee = price.mul(foundationFeeBasisPoints) / BASIS_POINTS;
 ownerRev = price.sub(foundationFee).sub(creatorSecondaryFee);
 }
 function _distributeFunds( address nftContract, uint256 tokenId, address payable seller, uint256 price ) internal returns ( uint256 foundationFee, uint256 creatorFee, uint256 ownerRev ) {
 (foundationFee, creatorFee, ownerRev) = _getFees(nftContract, tokenId, seller, price);
 nftContractToTokenIdToFirstSaleCompleted[nftContract][tokenId] = true;
 _sendValueWithFallbackWithdraw(getFoundationTreasury(), foundationFee);
 if (creatorFee > 0) {
 address payable creator = getCreator(nftContract, tokenId);
 if (creator == address(0)) {
 ownerRev = ownerRev.add(creatorFee);
 creatorFee = 0;
 }
 else {
 _sendValueWithFallbackWithdraw(creator, creatorFee);
 }
 }
 _sendValueWithFallbackWithdraw(seller, ownerRev);
 }
 function _updateMarketFees( uint256 primaryFoundationFeeBasisPoints, uint256 secondaryFoundationFeeBasisPoints, uint256 secondaryCreatorFeeBasisPoints ) internal {
 require(primaryFoundationFeeBasisPoints < BASIS_POINTS, "NFTMarketFees: Fees >= 100%");
 require( secondaryFoundationFeeBasisPoints.add(secondaryCreatorFeeBasisPoints) < BASIS_POINTS, "NFTMarketFees: Fees >= 100%" );
 _primaryFoundationFeeBasisPoints = primaryFoundationFeeBasisPoints;
 _secondaryFoundationFeeBasisPoints = secondaryFoundationFeeBasisPoints;
 _secondaryCreatorFeeBasisPoints = secondaryCreatorFeeBasisPoints;
 emit MarketFeesUpdated( primaryFoundationFeeBasisPoints, secondaryFoundationFeeBasisPoints, secondaryCreatorFeeBasisPoints );
 }
 uint256[1000] private ______gap;
 }
 pragma solidity ^0.7.0;
 abstract contract NFTMarketAuction {
 uint256 private nextAuctionId;
 function _initializeNFTMarketAuction() internal {
 nextAuctionId = 1;
 }
 function _getNextAndIncrementAuctionId() internal returns (uint256) {
 return nextAuctionId++;
 }
 uint256[1000] private ______gap;
 }
 pragma solidity ^0.7.0;
 abstract contract NFTMarketReserveAuction is Constants, FoundationAdminRole, NFTMarketCore, ReentrancyGuardUpgradeable, SendValueWithFallbackWithdraw, NFTMarketFees, NFTMarketAuction {
 using SafeMathUpgradeable for uint256;
 struct ReserveAuction {
 address nftContract;
 uint256 tokenId;
 address payable seller;
 uint256 duration;
 uint256 extensionDuration;
 uint256 endTime;
 address payable bidder;
 uint256 amount;
 }
 mapping(address => mapping(uint256 => uint256)) private nftContractToTokenIdToAuctionId;
 mapping(uint256 => ReserveAuction) private auctionIdToAuction;
 uint256 private _minPercentIncrementInBasisPoints;
 uint256 private ______gap_was_maxBidIncrementRequirement;
 uint256 private _duration;
 uint256 private ______gap_was_extensionDuration;
 uint256 private ______gap_was_goLiveDate;
 uint256 private constant MAX_MAX_DURATION = 1000 days;
 uint256 private constant EXTENSION_DURATION = 15 minutes;
 event ReserveAuctionConfigUpdated( uint256 minPercentIncrementInBasisPoints, uint256 maxBidIncrementRequirement, uint256 duration, uint256 extensionDuration, uint256 goLiveDate );
 event ReserveAuctionCreated( address indexed seller, address indexed nftContract, uint256 indexed tokenId, uint256 duration, uint256 extensionDuration, uint256 reservePrice, uint256 auctionId );
 event ReserveAuctionUpdated(uint256 indexed auctionId, uint256 reservePrice);
 event ReserveAuctionCanceled(uint256 indexed auctionId);
 event ReserveAuctionBidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount, uint256 endTime);
 event ReserveAuctionFinalized( uint256 indexed auctionId, address indexed seller, address indexed bidder, uint256 f8nFee, uint256 creatorFee, uint256 ownerRev );
 event ReserveAuctionCanceledByAdmin(uint256 indexed auctionId, string reason);
 modifier onlyValidAuctionConfig(uint256 reservePrice) {
 require(reservePrice > 0, "NFTMarketReserveAuction: Reserve price must be at least 1 wei");
 _;
 }
 function getReserveAuction(uint256 auctionId) public view returns (ReserveAuction memory) {
 return auctionIdToAuction[auctionId];
 }
 function getReserveAuctionIdFor(address nftContract, uint256 tokenId) public view returns (uint256) {
 return nftContractToTokenIdToAuctionId[nftContract][tokenId];
 }
 function _getSellerFor(address nftContract, uint256 tokenId) internal view virtual override returns (address) {
 address seller = auctionIdToAuction[nftContractToTokenIdToAuctionId[nftContract][tokenId]].seller;
 if (seller == address(0)) {
 return super._getSellerFor(nftContract, tokenId);
 }
 return seller;
 }
 function getReserveAuctionConfig() public view returns (uint256 minPercentIncrementInBasisPoints, uint256 duration) {
 minPercentIncrementInBasisPoints = _minPercentIncrementInBasisPoints;
 duration = _duration;
 }
 function _initializeNFTMarketReserveAuction() internal {
 _duration = 24 hours;
 }
 function _updateReserveAuctionConfig(uint256 minPercentIncrementInBasisPoints, uint256 duration) internal {
 require(minPercentIncrementInBasisPoints <= BASIS_POINTS, "NFTMarketReserveAuction: Min increment must be <= 100%");
 require(duration <= MAX_MAX_DURATION, "NFTMarketReserveAuction: Duration must be <= 1000 days");
 require(duration >= EXTENSION_DURATION, "NFTMarketReserveAuction: Duration must be >= EXTENSION_DURATION");
 _minPercentIncrementInBasisPoints = minPercentIncrementInBasisPoints;
 _duration = duration;
 emit ReserveAuctionConfigUpdated(minPercentIncrementInBasisPoints, 0, duration, EXTENSION_DURATION, 0);
 }
 function createReserveAuction( address nftContract, uint256 tokenId, uint256 reservePrice ) public onlyValidAuctionConfig(reservePrice) nonReentrant {
 uint256 auctionId = _getNextAndIncrementAuctionId();
 nftContractToTokenIdToAuctionId[nftContract][tokenId] = auctionId;
 auctionIdToAuction[auctionId] = ReserveAuction( nftContract, tokenId, msg.sender, _duration, EXTENSION_DURATION, 0, address(0), reservePrice );
 IERC721Upgradeable(nftContract).transferFrom(msg.sender, address(this), tokenId);
 emit ReserveAuctionCreated( msg.sender, nftContract, tokenId, _duration, EXTENSION_DURATION, reservePrice, auctionId );
 }
 function updateReserveAuction(uint256 auctionId, uint256 reservePrice) public onlyValidAuctionConfig(reservePrice) {
 ReserveAuction storage auction = auctionIdToAuction[auctionId];
 require(auction.seller == msg.sender, "NFTMarketReserveAuction: Not your auction");
 require(auction.endTime == 0, "NFTMarketReserveAuction: Auction in progress");
 auction.amount = reservePrice;
 emit ReserveAuctionUpdated(auctionId, reservePrice);
 }
 function cancelReserveAuction(uint256 auctionId) public nonReentrant {
 ReserveAuction memory auction = auctionIdToAuction[auctionId];
 require(auction.seller == msg.sender, "NFTMarketReserveAuction: Not your auction");
 require(auction.endTime == 0, "NFTMarketReserveAuction: Auction in progress");
 delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
 delete auctionIdToAuction[auctionId];
 IERC721Upgradeable(auction.nftContract).transferFrom(address(this), auction.seller, auction.tokenId);
 emit ReserveAuctionCanceled(auctionId);
 }
 function placeBid(uint256 auctionId) public payable nonReentrant {
 ReserveAuction storage auction = auctionIdToAuction[auctionId];
 require(auction.amount != 0, "NFTMarketReserveAuction: Auction not found");
 if (auction.endTime == 0) {
 require(auction.amount <= msg.value, "NFTMarketReserveAuction: Bid must be at least the reserve price");
 }
 else {
 require(auction.endTime >= block.timestamp, "NFTMarketReserveAuction: Auction is over");
 require(auction.bidder != msg.sender, "NFTMarketReserveAuction: You already have an outstanding bid");
 uint256 minAmount = _getMinBidAmountForReserveAuction(auction.amount);
 require(msg.value >= minAmount, "NFTMarketReserveAuction: Bid amount too low");
 }
 if (auction.endTime == 0) {
 auction.amount = msg.value;
 auction.bidder = msg.sender;
 auction.endTime = block.timestamp + auction.duration;
 }
 else {
 uint256 originalAmount = auction.amount;
 address payable originalBidder = auction.bidder;
 auction.amount = msg.value;
 auction.bidder = msg.sender;
 if (auction.endTime - block.timestamp < auction.extensionDuration) {
 auction.endTime = block.timestamp + auction.extensionDuration;
 }
 _sendValueWithFallbackWithdraw(originalBidder, originalAmount);
 }
 emit ReserveAuctionBidPlaced(auctionId, msg.sender, msg.value, auction.endTime);
 }
 function finalizeReserveAuction(uint256 auctionId) public nonReentrant {
 ReserveAuction memory auction = auctionIdToAuction[auctionId];
 require(auction.endTime > 0, "NFTMarketReserveAuction: Auction has not started");
 require(auction.endTime < block.timestamp, "NFTMarketReserveAuction: Auction still in progress");
 delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
 delete auctionIdToAuction[auctionId];
 IERC721Upgradeable(auction.nftContract).transferFrom(address(this), auction.bidder, auction.tokenId);
 (uint256 f8nFee, uint256 creatorFee, uint256 ownerRev) = _distributeFunds(auction.nftContract, auction.tokenId, auction.seller, auction.amount);
 emit ReserveAuctionFinalized(auctionId, auction.seller, auction.bidder, f8nFee, creatorFee, ownerRev);
 }
 function getMinBidAmount(uint256 auctionId) public view returns (uint256) {
 ReserveAuction storage auction = auctionIdToAuction[auctionId];
 if (auction.endTime == 0) {
 return auction.amount;
 }
 return _getMinBidAmountForReserveAuction(auction.amount);
 }
 function _getMinBidAmountForReserveAuction(uint256 currentBidAmount) private view returns (uint256) {
 uint256 minIncrement = currentBidAmount.mul(_minPercentIncrementInBasisPoints) / BASIS_POINTS;
 if (minIncrement == 0) {
 return currentBidAmount.add(1);
 }
 return minIncrement.add(currentBidAmount);
 }
 function adminCancelReserveAuction(uint256 auctionId, string memory reason) public onlyFoundationAdmin {
 require(bytes(reason).length > 0, "NFTMarketReserveAuction: Include a reason for this cancellation");
 ReserveAuction memory auction = auctionIdToAuction[auctionId];
 require(auction.amount > 0, "NFTMarketReserveAuction: Auction not found");
 delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
 delete auctionIdToAuction[auctionId];
 IERC721Upgradeable(auction.nftContract).transferFrom(address(this), auction.seller, auction.tokenId);
 if (auction.bidder != address(0)) {
 _sendValueWithFallbackWithdraw(auction.bidder, auction.amount);
 }
 emit ReserveAuctionCanceledByAdmin(auctionId, reason);
 }
 uint256[1000] private ______gap;
 }
 pragma solidity ^0.7.0;
 interface IERC165Upgradeable {
 function supportsInterface(bytes4 interfaceId) external view returns (bool);
 }
 pragma solidity ^0.7.0;
 contract FNDNFTMarket is FoundationTreasuryNode, FoundationAdminRole, NFTMarketCore, ReentrancyGuardUpgradeable, NFTMarketCreators, SendValueWithFallbackWithdraw, NFTMarketFees, NFTMarketAuction, NFTMarketReserveAuction {
 function initialize(address payable treasury) public initializer {
 FoundationTreasuryNode._initializeFoundationTreasuryNode(treasury);
 NFTMarketAuction._initializeNFTMarketAuction();
 NFTMarketReserveAuction._initializeNFTMarketReserveAuction();
 }
 function adminUpdateConfig( uint256 minPercentIncrementInBasisPoints, uint256 duration, uint256 primaryF8nFeeBasisPoints, uint256 secondaryF8nFeeBasisPoints, uint256 secondaryCreatorFeeBasisPoints ) public onlyFoundationAdmin {
 _updateReserveAuctionConfig(minPercentIncrementInBasisPoints, duration);
 _updateMarketFees(primaryF8nFeeBasisPoints, secondaryF8nFeeBasisPoints, secondaryCreatorFeeBasisPoints);
 }
 function _getSellerFor(address nftContract, uint256 tokenId) internal view virtual override(NFTMarketCore, NFTMarketReserveAuction) returns (address) {
 return super._getSellerFor(nftContract, tokenId);
 }
 }
 pragma solidity ^0.7.0;
 library AddressUpgradeable {
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
 interface IAdminRole {
 function isAdmin(address account) external view returns (bool);
 }
 pragma solidity ^0.7.0;
 interface IERC721Upgradeable is IERC165Upgradeable {
 event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
 event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
 event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
 function balanceOf(address owner) external view returns (uint256 balance);
 function ownerOf(uint256 tokenId) external view returns (address owner);
 function safeTransferFrom(address from, address to, uint256 tokenId) external;
 function transferFrom(address from, address to, uint256 tokenId) external;
 function approve(address to, uint256 tokenId) external;
 function getApproved(uint256 tokenId) external view returns (address operator);
 function setApprovalForAll(address operator, bool _approved) external;
 function isApprovedForAll(address owner, address operator) external view returns (bool);
 function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
 }
 pragma solidity ^0.7.0;
 library SafeMathUpgradeable {
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
 interface IFNDNFT721 {
 function tokenCreator(uint256 tokenId) external view returns (address payable);
 }
