   pragma solidity ^0.4.21;
 contract Ownable {
 address public owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 function Ownable() public {
 owner = msg.sender;
 }
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function transferOwnership(address newOwner) public onlyOwner {
 require(newOwner != address(0));
 emit OwnershipTransferred(owner, newOwner);
 owner = newOwner;
 }
 }
 contract ERC20Basic {
 function totalSupply() public view returns (uint256);
 function balanceOf(address who) public view returns (uint256);
 function transfer(address to, uint256 value) public returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 }
 contract ERC20 is ERC20Basic {
 function allowance(address owner, address spender) public view returns (uint256);
 function transferFrom(address from, address to, uint256 value) public returns (bool);
 function approve(address spender, uint256 value) public returns (bool);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 }
 library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
 if (a == 0) {
 return 0;
 }
 c = a * b;
 assert(c / a == b);
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 return a / b;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 assert(b <= a);
 return a - b;
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
 c = a + b;
 assert(c >= a);
 return c;
 }
 }
 contract Crowdsale {
 using SafeMath for uint256;
 ERC20 public token;
 address public wallet;
 uint256 public rate;
 uint256 public weiRaised;
 event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
 function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
 require(_rate > 0);
 require(_wallet != address(0));
 require(_token != address(0));
 rate = _rate;
 wallet = _wallet;
 token = _token;
 }
 function () external payable {
 buyTokens(msg.sender);
 }
 function buyTokens(address _beneficiary) public payable {
 uint256 weiAmount = msg.value;
 _preValidatePurchase(_beneficiary, weiAmount);
 uint256 tokens = _getTokenAmount(weiAmount);
 weiRaised = weiRaised.add(weiAmount);
 _processPurchase(_beneficiary, tokens);
 emit TokenPurchase( msg.sender, _beneficiary, weiAmount, tokens );
 _updatePurchasingState(_beneficiary, weiAmount);
 _forwardFunds();
 _postValidatePurchase(_beneficiary, weiAmount);
 }
 function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
 require(_beneficiary != address(0));
 require(_weiAmount != 0);
 }
 function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
 }
 function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
 token.transfer(_beneficiary, _tokenAmount);
 }
 function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
 _deliverTokens(_beneficiary, _tokenAmount);
 }
 function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
 }
 function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
 return _weiAmount.mul(rate);
 }
 function _forwardFunds() internal {
 wallet.transfer(msg.value);
 }
 }
 contract AllowanceCrowdsale is Crowdsale {
 using SafeMath for uint256;
 address public tokenWallet;
 function AllowanceCrowdsale(address _tokenWallet) public {
 require(_tokenWallet != address(0));
 tokenWallet = _tokenWallet;
 }
 function remainingTokens() public view returns (uint256) {
 return token.allowance(tokenWallet, this);
 }
 function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
 token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);
 }
 }
 contract IndividuallyCappedCrowdsale is Crowdsale, Ownable {
 using SafeMath for uint256;
 mapping(address => uint256) public contributions;
 mapping(address => uint256) public caps;
 function setUserCap(address _beneficiary, uint256 _cap) external onlyOwner {
 caps[_beneficiary] = _cap;
 }
 function setGroupCap(address[] _beneficiaries, uint256 _cap) external onlyOwner {
 for (uint256 i = 0; i < _beneficiaries.length; i++) {
 caps[_beneficiaries[i]] = _cap;
 }
 }
 function getUserCap(address _beneficiary) public view returns (uint256) {
 return caps[_beneficiary];
 }
 function getUserContribution(address _beneficiary) public view returns (uint256) {
 return contributions[_beneficiary];
 }
 function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
 super._preValidatePurchase(_beneficiary, _weiAmount);
 require(contributions[_beneficiary].add(_weiAmount) <= caps[_beneficiary]);
 }
 function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
 super._updatePurchasingState(_beneficiary, _weiAmount);
 contributions[_beneficiary] = contributions[_beneficiary].add(_weiAmount);
 }
 }
 contract WhitelistedCrowdsale is Crowdsale, Ownable {
 mapping(address => bool) public whitelist;
 modifier isWhitelisted(address _beneficiary) {
 require(whitelist[_beneficiary]);
 _;
 }
 function addToWhitelist(address _beneficiary) external onlyOwner {
 whitelist[_beneficiary] = true;
 }
 function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
 for (uint256 i = 0; i < _beneficiaries.length; i++) {
 whitelist[_beneficiaries[i]] = true;
 }
 }
 function removeFromWhitelist(address _beneficiary) external onlyOwner {
 whitelist[_beneficiary] = false;
 }
 function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal isWhitelisted(_beneficiary) {
 super._preValidatePurchase(_beneficiary, _weiAmount);
 }
 }
 contract TimedCrowdsale is Crowdsale {
 using SafeMath for uint256;
 uint256 public openingTime;
 uint256 public closingTime;
 modifier onlyWhileOpen {
 require(block.timestamp >= openingTime && block.timestamp <= closingTime);
 _;
 }
 function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
 require(_openingTime >= block.timestamp);
 require(_closingTime >= _openingTime);
 openingTime = _openingTime;
 closingTime = _closingTime;
 }
 function hasClosed() public view returns (bool) {
 return block.timestamp > closingTime;
 }
 function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
 super._preValidatePurchase(_beneficiary, _weiAmount);
 }
 }
 contract Membership {
 function removeMember(address _user) external;
 function setMemberTier(address _user, uint _tier);
 }
 contract PreSquirrelICO is Crowdsale, TimedCrowdsale, WhitelistedCrowdsale, IndividuallyCappedCrowdsale, AllowanceCrowdsale {
 using SafeMath for uint;
 uint constant public MIN_PURCHASE = 1 * 1 ether;
 uint constant public MAX_PURCHASE = 15 * 1 ether;
 uint public totalNtsSold;
 uint public totalNtsSoldWithBonus;
 uint public totalEthRcvd;
 Membership public membership;
 constructor( uint _startTime, uint _endTime, uint _rate, address _ethWallet, ERC20 _token, address _tokenWallet, Membership _membership ) public Crowdsale(_rate, _ethWallet, _token) TimedCrowdsale(_startTime, _endTime) AllowanceCrowdsale(_tokenWallet) {
 membership = Membership(_membership);
 }
 function _preValidatePurchase(address _beneficiary, uint _weiAmount) internal {
 super._preValidatePurchase(_beneficiary, _weiAmount);
 require(_weiAmount >= MIN_PURCHASE);
 totalEthRcvd = totalEthRcvd.add(_weiAmount);
 }
 function _processPurchase(address _beneficiary, uint _tokenAmount) internal {
 uint tokenAmountWithBonus_ = _tokenAmount.add(_tokenAmount.div(100).mul(30));
 totalNtsSold = totalNtsSold.add(_tokenAmount);
 totalNtsSoldWithBonus = totalNtsSoldWithBonus.add(tokenAmountWithBonus_);
 _deliverTokens(_beneficiary, tokenAmountWithBonus_);
 }
 function addToWhitelist(address _beneficiary) external onlyOwner {
 whitelist[_beneficiary] = true;
 caps[_beneficiary] = MAX_PURCHASE;
 membership.setMemberTier(_beneficiary, 1);
 }
 function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
 for (uint i = 0; i < _beneficiaries.length; i++) {
 whitelist[_beneficiaries[i]] = true;
 caps[_beneficiaries[i]] = MAX_PURCHASE;
 membership.setMemberTier(_beneficiaries[i], 1);
 }
 }
 function removeFromWhitelist(address _beneficiary) external onlyOwner {
 whitelist[_beneficiary] = false;
 membership.removeMember(_beneficiary);
 }
 function hasStarted() external view returns (bool) {
 return block.timestamp >= openingTime;
 }
 function userAlreadyBoughtEth(address _user) public view returns (uint) {
 return contributions[_user];
 }
 function userCanStillBuyEth(address _user) external view returns (uint) {
 return MAX_PURCHASE.sub(userAlreadyBoughtEth(_user));
 }
 function userIsWhitelisted(address _user) external view returns (bool) {
 return whitelist[_user];
 }
 function getStats() external view returns (uint, uint, uint) {
 return (totalNtsSold, totalNtsSoldWithBonus, totalEthRcvd);
 }
 }
