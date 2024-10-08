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
 event Approval( address indexed owner, address indexed spender, uint256 value );
 }
 library SafeERC20 {
 function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
 require(token.transfer(to, value));
 }
 function safeTransferFrom( ERC20 token, address from, address to, uint256 value ) internal {
 require(token.transferFrom(from, to, value));
 }
 function safeApprove(ERC20 token, address spender, uint256 value) internal {
 require(token.approve(spender, value));
 }
 }
 contract Crowdsale {
 using SafeMath for uint256;
 using SafeERC20 for ERC20;
 ERC20 public token;
 address public wallet;
 uint256 public rate;
 uint256 public weiRaised;
 event TokenPurchase( address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount );
 constructor(uint256 _rate, address _wallet, ERC20 _token) public {
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
 function _preValidatePurchase( address _beneficiary, uint256 _weiAmount ) internal {
 require(_beneficiary != address(0));
 require(_weiAmount != 0);
 }
 function _postValidatePurchase( address _beneficiary, uint256 _weiAmount ) internal {
 }
 function _deliverTokens( address _beneficiary, uint256 _tokenAmount ) internal {
 token.safeTransfer(_beneficiary, _tokenAmount);
 }
 function _processPurchase( address _beneficiary, uint256 _tokenAmount ) internal {
 _deliverTokens(_beneficiary, _tokenAmount);
 }
 function _updatePurchasingState( address _beneficiary, uint256 _weiAmount ) internal {
 }
 function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
 return _weiAmount.mul(rate);
 }
 function _forwardFunds() internal {
 wallet.transfer(msg.value);
 }
 }
 contract Ownable {
 address public owner;
 event OwnershipRenounced(address indexed previousOwner);
 event OwnershipTransferred( address indexed previousOwner, address indexed newOwner );
 constructor() public {
 owner = msg.sender;
 }
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function renounceOwnership() public onlyOwner {
 emit OwnershipRenounced(owner);
 owner = address(0);
 }
 function transferOwnership(address _newOwner) public onlyOwner {
 _transferOwnership(_newOwner);
 }
 function _transferOwnership(address _newOwner) internal {
 require(_newOwner != address(0));
 emit OwnershipTransferred(owner, _newOwner);
 owner = _newOwner;
 }
 }
 library Roles {
 struct Role {
 mapping (address => bool) bearer;
 }
 function add(Role storage role, address addr) internal {
 role.bearer[addr] = true;
 }
 function remove(Role storage role, address addr) internal {
 role.bearer[addr] = false;
 }
 function check(Role storage role, address addr) view internal {
 require(has(role, addr));
 }
 function has(Role storage role, address addr) view internal returns (bool) {
 return role.bearer[addr];
 }
 }
 contract RBAC {
 using Roles for Roles.Role;
 mapping (string => Roles.Role) private roles;
 event RoleAdded(address indexed operator, string role);
 event RoleRemoved(address indexed operator, string role);
 function checkRole(address _operator, string _role) view public {
 roles[_role].check(_operator);
 }
 function hasRole(address _operator, string _role) view public returns (bool) {
 return roles[_role].has(_operator);
 }
 function addRole(address _operator, string _role) internal {
 roles[_role].add(_operator);
 emit RoleAdded(_operator, _role);
 }
 function removeRole(address _operator, string _role) internal {
 roles[_role].remove(_operator);
 emit RoleRemoved(_operator, _role);
 }
 modifier onlyRole(string _role) {
 checkRole(msg.sender, _role);
 _;
 }
 }
 contract Superuser is Ownable, RBAC {
 string public constant ROLE_SUPERUSER = "superuser";
 constructor () public {
 addRole(msg.sender, ROLE_SUPERUSER);
 }
 modifier onlySuperuser() {
 checkRole(msg.sender, ROLE_SUPERUSER);
 _;
 }
 modifier onlyOwnerOrSuperuser() {
 require(msg.sender == owner || isSuperuser(msg.sender));
 _;
 }
 function isSuperuser(address _addr) public view returns (bool) {
 return hasRole(_addr, ROLE_SUPERUSER);
 }
 function transferSuperuser(address _newSuperuser) public onlySuperuser {
 require(_newSuperuser != address(0));
 removeRole(msg.sender, ROLE_SUPERUSER);
 addRole(_newSuperuser, ROLE_SUPERUSER);
 }
 function transferOwnership(address _newOwner) public onlyOwnerOrSuperuser {
 _transferOwnership(_newOwner);
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
 constructor(uint256 _openingTime, uint256 _closingTime) public {
 require(_openingTime >= block.timestamp);
 require(_closingTime >= _openingTime);
 openingTime = _openingTime;
 closingTime = _closingTime;
 }
 function hasClosed() public view returns (bool) {
 return block.timestamp > closingTime;
 }
 function _preValidatePurchase( address _beneficiary, uint256 _weiAmount ) internal onlyWhileOpen {
 super._preValidatePurchase(_beneficiary, _weiAmount);
 }
 }
 contract Whitelist is Ownable, RBAC {
 string public constant ROLE_WHITELISTED = "whitelist";
 modifier onlyIfWhitelisted(address _operator) {
 checkRole(_operator, ROLE_WHITELISTED);
 _;
 }
 function addAddressToWhitelist(address _operator) onlyOwner public {
 addRole(_operator, ROLE_WHITELISTED);
 }
 function whitelist(address _operator) public view returns (bool) {
 return hasRole(_operator, ROLE_WHITELISTED);
 }
 function addAddressesToWhitelist(address[] _operators) onlyOwner public {
 for (uint256 i = 0; i < _operators.length; i++) {
 addAddressToWhitelist(_operators[i]);
 }
 }
 function removeAddressFromWhitelist(address _operator) onlyOwner public {
 removeRole(_operator, ROLE_WHITELISTED);
 }
 function removeAddressesFromWhitelist(address[] _operators) onlyOwner public {
 for (uint256 i = 0; i < _operators.length; i++) {
 removeAddressFromWhitelist(_operators[i]);
 }
 }
 }
 contract WhitelistedCrowdsale is Whitelist, Crowdsale {
 function _preValidatePurchase( address _beneficiary, uint256 _weiAmount ) onlyIfWhitelisted(_beneficiary) internal {
 super._preValidatePurchase(_beneficiary, _weiAmount);
 }
 }
 contract CappedCrowdsale is Crowdsale {
 using SafeMath for uint256;
 uint256 public cap;
 constructor(uint256 _cap) public {
 require(_cap > 0);
 cap = _cap;
 }
 function capReached() public view returns (bool) {
 return weiRaised >= cap;
 }
 function _preValidatePurchase( address _beneficiary, uint256 _weiAmount ) internal {
 super._preValidatePurchase(_beneficiary, _weiAmount);
 require(weiRaised.add(_weiAmount) <= cap);
 }
 }
 contract BasicToken is ERC20Basic {
 using SafeMath for uint256;
 mapping(address => uint256) balances;
 uint256 totalSupply_;
 function totalSupply() public view returns (uint256) {
 return totalSupply_;
 }
 function transfer(address _to, uint256 _value) public returns (bool) {
 require(_to != address(0));
 require(_value <= balances[msg.sender]);
 balances[msg.sender] = balances[msg.sender].sub(_value);
 balances[_to] = balances[_to].add(_value);
 emit Transfer(msg.sender, _to, _value);
 return true;
 }
 function balanceOf(address _owner) public view returns (uint256) {
 return balances[_owner];
 }
 }
 contract StandardToken is ERC20, BasicToken {
 mapping (address => mapping (address => uint256)) internal allowed;
 function transferFrom( address _from, address _to, uint256 _value ) public returns (bool) {
 require(_to != address(0));
 require(_value <= balances[_from]);
 require(_value <= allowed[_from][msg.sender]);
 balances[_from] = balances[_from].sub(_value);
 balances[_to] = balances[_to].add(_value);
 allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
 emit Transfer(_from, _to, _value);
 return true;
 }
 function approve(address _spender, uint256 _value) public returns (bool) {
 allowed[msg.sender][_spender] = _value;
 emit Approval(msg.sender, _spender, _value);
 return true;
 }
 function allowance( address _owner, address _spender ) public view returns (uint256) {
 return allowed[_owner][_spender];
 }
 function increaseApproval( address _spender, uint256 _addedValue ) public returns (bool) {
 allowed[msg.sender][_spender] = ( allowed[msg.sender][_spender].add(_addedValue));
 emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
 return true;
 }
 function decreaseApproval( address _spender, uint256 _subtractedValue ) public returns (bool) {
 uint256 oldValue = allowed[msg.sender][_spender];
 if (_subtractedValue > oldValue) {
 allowed[msg.sender][_spender] = 0;
 }
 else {
 allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
 }
 emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
 return true;
 }
 }
 contract MintableToken is StandardToken, Ownable {
 event Mint(address indexed to, uint256 amount);
 event MintFinished();
 bool public mintingFinished = false;
 modifier canMint() {
 require(!mintingFinished);
 _;
 }
 modifier hasMintPermission() {
 require(msg.sender == owner);
 _;
 }
 function mint( address _to, uint256 _amount ) hasMintPermission canMint public returns (bool) {
 totalSupply_ = totalSupply_.add(_amount);
 balances[_to] = balances[_to].add(_amount);
 emit Mint(_to, _amount);
 emit Transfer(address(0), _to, _amount);
 return true;
 }
 function finishMinting() onlyOwner canMint public returns (bool) {
 mintingFinished = true;
 emit MintFinished();
 return true;
 }
 }
 contract MintedCrowdsale is Crowdsale {
 function _deliverTokens( address _beneficiary, uint256 _tokenAmount ) internal {
 require(MintableToken(token).mint(_beneficiary, _tokenAmount));
 }
 }
 contract CoinSmarttICO is TimedCrowdsale, WhitelistedCrowdsale, MintedCrowdsale, Superuser {
 uint256 public round;
 uint256 public lastRound;
 function CoinSmarttICO(uint256 _rate, address _wallet, ERC20 _token, uint256 _openingTime, uint256 _closingTime) TimedCrowdsale(_openingTime, _closingTime) Crowdsale(_rate, _wallet, _token) {
 round = 1;
 lastRound = 0;
 }
 function changeRound(uint256 deadline, uint256 cap, uint256 _rate, uint256 _newAmount) internal {
 if (now >= deadline || (_newAmount.sub(lastRound) >= cap)) {
 round += 1;
 lastRound = token.totalSupply();
 rate = _rate;
 }
 }
 function getRate(uint256 _newAmount) internal {
 if(round == 4) {
 }
 else if (round == 3) {
 changeRound(1547596800, 666666667 ether, 32481, _newAmount);
 }
 else if (round == 2) {
 changeRound(1543622400, 333333333 ether, 38977, _newAmount);
 }
 else if (round == 1) {
 changeRound(1539648000, 250000000 ether, 48721, _newAmount);
 }
 }
 function _preValidatePurchase( address _beneficiary, uint256 _weiAmount ) internal {
 require(_getTokenAmount(_weiAmount).add(token.totalSupply()) < 3138888888 ether);
 getRate(_getTokenAmount(_weiAmount).add(token.totalSupply()));
 super._preValidatePurchase(_beneficiary, _weiAmount);
 }
 function bumpRound(uint256 _rate) onlyOwner {
 round += 1;
 lastRound = token.totalSupply();
 rate = _rate;
 }
 }
