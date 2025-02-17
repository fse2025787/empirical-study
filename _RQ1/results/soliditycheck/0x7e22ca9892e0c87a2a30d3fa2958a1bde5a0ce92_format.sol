      pragma solidity ^0.4.21;
 library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a * b;
 assert(a == 0 || c / a == b);
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a / b;
 return c;
 }
 function minus(uint256 a, uint256 b) internal pure returns (uint256) {
 assert(b <= a);
 return a - b;
 }
 function plus(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 assert(c >= a);
 return c;
 }
 }
 contract ERC20Token {
 uint256 public totalSupply;
 function balanceOf(address _owner) public view returns (uint256 balance);
 function transfer(address _to, uint256 _value) public returns (bool success);
 function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
 function approve(address _spender, uint256 _value) public returns (bool success);
 function allowance(address _owner, address _spender) public view returns (uint256 remaining);
 event Transfer(address indexed _from, address indexed _to, uint256 _value);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 }
 contract HasOwner {
 address public owner;
 address public newOwner;
 constructor(address _owner) public {
 owner = _owner;
 }
 modifier onlyOwner {
 require(msg.sender == owner);
 _;
 }
 event OwnershipTransfer(address indexed _oldOwner, address indexed _newOwner);
 function transferOwnership(address _newOwner) public onlyOwner {
 newOwner = _newOwner;
 }
 function acceptOwnership() public {
 require(msg.sender == newOwner);
 emit OwnershipTransfer(owner, newOwner);
 owner = newOwner;
 }
 }
 contract AbstractFundraiser {
 ERC20Token public token;
 event FundsReceived(address indexed _address, uint _ethers, uint _tokens);
 function initializeFundraiserToken(address _token) internal {
 token = ERC20Token(_token);
 }
 function() public payable {
 receiveFunds(msg.sender, msg.value);
 }
 function getConversionRate() public view returns (uint256);
 function hasEnded() public view returns (bool);
 function receiveFunds(address _address, uint256 _amount) internal;
 function validateTransaction() internal view;
 function handleTokens(address _address, uint256 _tokens) internal;
 function handleFunds(address _address, uint256 _ethers) internal;
 }
 contract BasicFundraiser is HasOwner, AbstractFundraiser {
 using SafeMath for uint256;
 uint8 constant DECIMALS = 18;
 uint256 constant DECIMALS_FACTOR = 10 ** uint256(DECIMALS);
 uint256 public startTime;
 uint256 public endTime;
 address public beneficiary;
 uint256 public conversionRate;
 uint256 public totalRaised;
 event ConversionRateChanged(uint _conversionRate);
 function initializeBasicFundraiser( uint256 _startTime, uint256 _endTime, uint256 _conversionRate, address _beneficiary ) internal {
 require(_endTime >= _startTime);
 require(_conversionRate > 0);
 require(_beneficiary != address(0));
 startTime = _startTime;
 endTime = _endTime;
 conversionRate = _conversionRate;
 beneficiary = _beneficiary;
 }
 function setConversionRate(uint256 _conversionRate) public onlyOwner {
 require(_conversionRate > 0);
 conversionRate = _conversionRate;
 emit ConversionRateChanged(_conversionRate);
 }
 function setBeneficiary(address _beneficiary) public onlyOwner {
 require(_beneficiary != address(0));
 beneficiary = _beneficiary;
 }
 function receiveFunds(address _address, uint256 _amount) internal {
 validateTransaction();
 uint256 tokens = calculateTokens(_amount);
 require(tokens > 0);
 totalRaised = totalRaised.plus(_amount);
 handleTokens(_address, tokens);
 handleFunds(_address, _amount);
 emit FundsReceived(_address, msg.value, tokens);
 }
 function getConversionRate() public view returns (uint256) {
 return conversionRate;
 }
 function calculateTokens(uint256 _amount) internal view returns(uint256 tokens) {
 tokens = _amount.mul(getConversionRate());
 }
 function validateTransaction() internal view {
 require(msg.value != 0);
 require(now >= startTime && now < endTime);
 }
 function hasEnded() public view returns (bool) {
 return now >= endTime;
 }
 }
 contract CappedFundraiser is BasicFundraiser {
 uint256 public hardCap;
 function initializeCappedFundraiser(uint256 _hardCap) internal {
 require(_hardCap > 0);
 hardCap = _hardCap;
 }
 function validateTransaction() internal view {
 super.validateTransaction();
 require(totalRaised < hardCap);
 }
 function hasEnded() public view returns (bool) {
 return (super.hasEnded() || totalRaised >= hardCap);
 }
 }
 contract ForwardFundsFundraiser is BasicFundraiser {
 function handleFunds(address, uint256 _ethers) internal {
 beneficiary.transfer(_ethers);
 }
 }
 contract GasPriceLimitFundraiser is HasOwner, BasicFundraiser {
 uint256 public gasPriceLimit;
 event GasPriceLimitChanged(uint256 gasPriceLimit);
 function initializeGasPriceLimitFundraiser(uint256 _gasPriceLimit) internal {
 gasPriceLimit = _gasPriceLimit;
 }
 function changeGasPriceLimit(uint256 _gasPriceLimit) onlyOwner() public {
 gasPriceLimit = _gasPriceLimit;
 emit GasPriceLimitChanged(_gasPriceLimit);
 }
 function validateTransaction() internal view {
 require(gasPriceLimit == 0 || tx.gasprice <= gasPriceLimit);
 return super.validateTransaction();
 }
 }
 contract IndividualCapsFundraiser is BasicFundraiser {
 uint256 public individualMinCap;
 uint256 public individualMaxCap;
 uint256 public individualMaxCapTokens;
 event IndividualMinCapChanged(uint256 _individualMinCap);
 event IndividualMaxCapTokensChanged(uint256 _individualMaxCapTokens);
 function initializeIndividualCapsFundraiser(uint256 _individualMinCap, uint256 _individualMaxCap) internal {
 individualMinCap = _individualMinCap;
 individualMaxCap = _individualMaxCap;
 individualMaxCapTokens = _individualMaxCap * conversionRate;
 }
 function setConversionRate(uint256 _conversionRate) public onlyOwner {
 super.setConversionRate(_conversionRate);
 if (individualMaxCap == 0) {
 return;
 }
 individualMaxCapTokens = individualMaxCap * _conversionRate;
 emit IndividualMaxCapTokensChanged(individualMaxCapTokens);
 }
 function setIndividualMinCap(uint256 _individualMinCap) public onlyOwner {
 individualMinCap = _individualMinCap;
 emit IndividualMinCapChanged(individualMinCap);
 }
 function setIndividualMaxCap(uint256 _individualMaxCap) public onlyOwner {
 individualMaxCap = _individualMaxCap;
 individualMaxCapTokens = _individualMaxCap * conversionRate;
 emit IndividualMaxCapTokensChanged(individualMaxCapTokens);
 }
 function validateTransaction() internal view {
 super.validateTransaction();
 require(msg.value >= individualMinCap);
 }
 function handleTokens(address _address, uint256 _tokens) internal {
 require(individualMaxCapTokens == 0 || token.balanceOf(_address).plus(_tokens) <= individualMaxCapTokens);
 super.handleTokens(_address, _tokens);
 }
 }
 contract StandardToken is ERC20Token {
 using SafeMath for uint256;
 string public name;
 string public symbol;
 uint8 public decimals;
 mapping (address => uint256) balances;
 mapping (address => mapping (address => uint256)) internal allowed;
 constructor(string _name, string _symbol, uint8 _decimals) internal {
 name = _name;
 symbol = _symbol;
 decimals = _decimals;
 }
 function balanceOf(address _address) public view returns (uint256 balance) {
 return balances[_address];
 }
 function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
 return allowed[_owner][_spender];
 }
 function approve(address _spender, uint256 _value) public returns (bool) {
 allowed[msg.sender][_spender] = _value;
 emit Approval(msg.sender, _spender, _value);
 return true;
 }
 function transfer(address _to, uint256 _value) public returns (bool) {
 executeTransfer(msg.sender, _to, _value);
 return true;
 }
 function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
 require(_value <= allowed[_from][msg.sender]);
 allowed[_from][msg.sender] = allowed[_from][msg.sender].minus(_value);
 executeTransfer(_from, _to, _value);
 return true;
 }
 function executeTransfer(address _from, address _to, uint256 _value) internal {
 require(_to != address(0));
 require(_value != 0 && _value <= balances[_from]);
 balances[_from] = balances[_from].minus(_value);
 balances[_to] = balances[_to].plus(_value);
 emit Transfer(_from, _to, _value);
 }
 }
 contract MintableToken is StandardToken {
 address public minter;
 bool public mintingDisabled = false;
 event MintingDisabled();
 modifier canMint() {
 require(!mintingDisabled);
 _;
 }
 modifier onlyMinter() {
 require(msg.sender == minter);
 _;
 }
 constructor(address _minter) internal {
 minter = _minter;
 }
 function mint(address _to, uint256 _value) onlyMinter canMint public {
 totalSupply = totalSupply.plus(_value);
 balances[_to] = balances[_to].plus(_value);
 emit Transfer(0x0, _to, _value);
 }
 function disableMinting() onlyMinter canMint public {
 mintingDisabled = true;
 emit MintingDisabled();
 }
 }
 contract StandardMintableToken is MintableToken {
 constructor(address _minter, string _name, string _symbol, uint8 _decimals) StandardToken(_name, _symbol, _decimals) MintableToken(_minter) public {
 }
 }
 contract MintableTokenFundraiser is BasicFundraiser {
 function initializeMintableTokenFundraiser(string _name, string _symbol, uint8 _decimals) internal {
 token = new StandardMintableToken( address(this), _name, _symbol, _decimals );
 }
 function handleTokens(address _address, uint256 _tokens) internal {
 MintableToken(token).mint(_address, _tokens);
 }
 }
 contract BurnableToken is StandardToken {
 event Burn(address indexed _from, uint256 _value);
 function burn(uint256 _value) public {
 require(_value != 0);
 address burner = msg.sender;
 require(_value <= balances[burner]);
 balances[burner] = balances[burner].minus(_value);
 totalSupply = totalSupply.minus(_value);
 emit Burn(burner, _value);
 emit Transfer(burner, address(0), _value);
 }
 }
 contract MELTToken is MintableToken, BurnableToken {
 constructor(address _minter) StandardToken( "MELT TOKEN", "MELT", 18 ) MintableToken(_minter) public {
 }
 }
 contract MELTTokenFundraiser is MintableTokenFundraiser, IndividualCapsFundraiser, CappedFundraiser, ForwardFundsFundraiser, GasPriceLimitFundraiser {
 constructor() HasOwner(msg.sender) public {
 token = new MELTToken( address(this) );
 initializeBasicFundraiser( 1530019200, 1541016000, 10000, 0x88FE3A52C66CD0158643A1C1B7572b42932133A4 );
 initializeIndividualCapsFundraiser( (0.001 ether), (50 ether) );
 initializeGasPriceLimitFundraiser( 50000000000 );
 initializeCappedFundraiser( (510 ether) );
 }
 }
