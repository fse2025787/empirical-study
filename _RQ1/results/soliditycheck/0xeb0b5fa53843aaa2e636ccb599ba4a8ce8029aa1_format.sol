   pragma solidity ^0.4.20;
 contract H4D {
 modifier onlyBagholders() {
 require(myTokens() > 0);
 _;
 }
 modifier onlyStronghands() {
 require(myDividends(true) > 0);
 _;
 }
 modifier onlyAdministrator(){
 address _customerAddress = msg.sender;
 require(administrators[(_customerAddress)]);
 _;
 }
 modifier antiEarlyWhale(uint256 _amountOfEthereum){
 address _customerAddress = msg.sender;
 if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
 require( ambassadors_[_customerAddress] == true && (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_ );
 ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
 _;
 }
 else {
 onlyAmbassadors = false;
 _;
 }
 }
 event onTokenPurchase( address indexed customerAddress, uint256 incomingEthereum, uint256 tokensMinted, address indexed referredBy );
 event onTokenSell( address indexed customerAddress, uint256 tokensBurned, uint256 ethereumEarned );
 event onReinvestment( address indexed customerAddress, uint256 ethereumReinvested, uint256 tokensMinted );
 event onWithdraw( address indexed customerAddress, uint256 ethereumWithdrawn );
 event Transfer( address indexed from, address indexed to, uint256 tokens );
 string public name = "HoDL4D";
 string public symbol = "H4D";
 uint8 constant public decimals = 18;
 uint8 constant internal dividendFee_ = 5;
 uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
 uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
 uint256 constant internal magnitude = 2**64;
 uint256 public stakingRequirement = 1;
 mapping(address => bool) internal ambassadors_;
 uint256 constant internal ambassadorMaxPurchase_ = .25 ether;
 uint256 constant internal ambassadorQuota_ = 4 ether;
 mapping(address => uint256) internal tokenBalanceLedger_;
 mapping(address => uint256) internal referralBalance_;
 mapping(address => int256) internal payoutsTo_;
 mapping(address => uint256) internal ambassadorAccumulatedQuota_;
 uint256 internal tokenSupply_ = 0;
 uint256 internal profitPerShare_;
 mapping(address => bool) public administrators;
 bool public onlyAmbassadors = true;
 function H4D() public {
 administrators[msg.sender] = true;
 ambassadors_[0x8d35c3edFc1A8f2564fd00561Fb0A8423D5B8b44] = true;
 ambassadors_[0xd22edB04447636Fb490a5C4B79DbF95a9be662CC] = true;
 ambassadors_[0xFB84cb9eF433264bb4a9a8CeB81873C08ce2dB3d] = true;
 ambassadors_[0x05f2c11996d73288AbE8a31d8b593a693FF2E5D8] = true;
 ambassadors_[0x008ca4f1ba79d1a265617c6206d7884ee8108a78] = true;
 ambassadors_[0xc7F15d0238d207e19cce6bd6C0B85f343896F046] = true;
 ambassadors_[0x6629c7199ecc6764383dfb98b229ac8c540fc76f] = true;
 ambassadors_[0x4ffe17a2a72bc7422cb176bc71c04ee6d87ce329] = true;
 ambassadors_[0x41a21b264F9ebF6cF571D4543a5b3AB1c6bEd98C] = true;
 ambassadors_[0xE436cBD3892C6dC3D6c8A3580153e6e0fa613cfC ] = true;
 ambassadors_[0xBac5E4ccB84fe2869b598996031d1a158ae4779b] = true;
 ambassadors_[0x4da6fc68499fb3753e77dd6871f2a0e4dc02febe] = true;
 ambassadors_[0x71f35825a3B1528859dFa1A64b24242BC0d12990] = true;
 }
 function buy(address _referredBy) public payable returns(uint256) {
 purchaseTokens(msg.value, _referredBy);
 }
 function() payable public {
 purchaseTokens(msg.value, 0x0);
 }
 function reinvest() onlyStronghands() public {
 uint256 _dividends = myDividends(false);
 address _customerAddress = msg.sender;
 payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
 _dividends += referralBalance_[_customerAddress];
 referralBalance_[_customerAddress] = 0;
 uint256 _tokens = purchaseTokens(_dividends, 0x0);
 onReinvestment(_customerAddress, _dividends, _tokens);
 }
 function exit() public {
 address _customerAddress = msg.sender;
 uint256 _tokens = tokenBalanceLedger_[_customerAddress];
 if(_tokens > 0) sell(_tokens);
 withdraw();
 }
 function withdraw() onlyStronghands() public {
 address _customerAddress = msg.sender;
 uint256 _dividends = myDividends(false);
 payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
 _dividends += referralBalance_[_customerAddress];
 referralBalance_[_customerAddress] = 0;
 _customerAddress.transfer(_dividends);
 onWithdraw(_customerAddress, _dividends);
 }
 function sell(uint256 _amountOfTokens) onlyBagholders() public {
 address _customerAddress = msg.sender;
 require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
 uint256 _tokens = _amountOfTokens;
 uint256 _ethereum = tokensToEthereum_(_tokens);
 uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
 uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
 tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
 tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
 int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
 payoutsTo_[_customerAddress] -= _updatedPayouts;
 if (tokenSupply_ > 0) {
 profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
 }
 onTokenSell(_customerAddress, _tokens, _taxedEthereum);
 }
 function transfer(address _toAddress, uint256 _amountOfTokens) onlyBagholders() public returns(bool) {
 address _customerAddress = msg.sender;
 require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
 if(myDividends(true) > 0) withdraw();
 uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);
 uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
 uint256 _dividends = tokensToEthereum_(_tokenFee);
 tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);
 tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
 tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
 payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
 payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);
 profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
 Transfer(_customerAddress, _toAddress, _taxedTokens);
 return true;
 }
 function disableInitialStage() onlyAdministrator() public {
 onlyAmbassadors = false;
 }
 function setAdministrator(address _identifier, bool _status) onlyAdministrator() public {
 administrators[_identifier] = _status;
 }
 function setStakingRequirement(uint256 _amountOfTokens) onlyAdministrator() public {
 stakingRequirement = _amountOfTokens;
 }
 function setName(string _name) onlyAdministrator() public {
 name = _name;
 }
 function setSymbol(string _symbol) onlyAdministrator() public {
 symbol = _symbol;
 }
 function totalEthereumBalance() public view returns(uint) {
 return this.balance;
 }
 function totalSupply() public view returns(uint256) {
 return tokenSupply_;
 }
 function myTokens() public view returns(uint256) {
 address _customerAddress = msg.sender;
 return balanceOf(_customerAddress);
 }
 function myDividends(bool _includeReferralBonus) public view returns(uint256) {
 address _customerAddress = msg.sender;
 return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
 }
 function balanceOf(address _customerAddress) view public returns(uint256) {
 return tokenBalanceLedger_[_customerAddress];
 }
 function dividendsOf(address _customerAddress) view public returns(uint256) {
 return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
 }
 function sellPrice() public view returns(uint256) {
 if(tokenSupply_ == 0){
 return tokenPriceInitial_ - tokenPriceIncremental_;
 }
 else {
 uint256 _ethereum = tokensToEthereum_(1e18);
 uint256 _dividends = SafeMath.div(_ethereum, dividendFee_ );
 uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
 return _taxedEthereum;
 }
 }
 function buyPrice() public view returns(uint256) {
 if(tokenSupply_ == 0){
 return tokenPriceInitial_ + tokenPriceIncremental_;
 }
 else {
 uint256 _ethereum = tokensToEthereum_(1e18);
 uint256 _dividends = SafeMath.div(_ethereum, dividendFee_ );
 uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
 return _taxedEthereum;
 }
 }
 function calculateTokensReceived(uint256 _ethereumToSpend) public view returns(uint256) {
 uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
 uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
 uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
 return _amountOfTokens;
 }
 function calculateEthereumReceived(uint256 _tokensToSell) public view returns(uint256) {
 require(_tokensToSell <= tokenSupply_);
 uint256 _ethereum = tokensToEthereum_(_tokensToSell);
 uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
 uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
 return _taxedEthereum;
 }
 function purchaseTokens(uint256 _incomingEthereum, address _referredBy) antiEarlyWhale(_incomingEthereum) internal returns(uint256) {
 address _customerAddress = msg.sender;
 uint256 _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);
 uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
 uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
 uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
 uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
 uint256 _fee = _dividends * magnitude;
 require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
 if( _referredBy != 0x0000000000000000000000000000000000000000 && _referredBy != _customerAddress && tokenBalanceLedger_[_referredBy] >= stakingRequirement ){
 referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
 }
 else {
 _dividends = SafeMath.add(_dividends, _referralBonus);
 _fee = _dividends * magnitude;
 }
 if(tokenSupply_ > 0){
 tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
 profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
 _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
 }
 else {
 tokenSupply_ = _amountOfTokens;
 }
 tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
 int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
 payoutsTo_[_customerAddress] += _updatedPayouts;
 onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);
 return _amountOfTokens;
 }
 function ethereumToTokens_(uint256 _ethereum) internal view returns(uint256) {
 uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
 uint256 _tokensReceived = ( ( SafeMath.sub( (sqrt ( (_tokenPriceInitial**2) + (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18)) + (((tokenPriceIncremental_)**2)*(tokenSupply_**2)) + (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_) ) ), _tokenPriceInitial ) )/(tokenPriceIncremental_) )-(tokenSupply_) ;
 return _tokensReceived;
 }
 function tokensToEthereum_(uint256 _tokens) internal view returns(uint256) {
 uint256 tokens_ = (_tokens + 1e18);
 uint256 _tokenSupply = (tokenSupply_ + 1e18);
 uint256 _etherReceived = ( SafeMath.sub( ( ( ( tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18)) )-tokenPriceIncremental_ )*(tokens_ - 1e18) ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2 ) /1e18);
 return _etherReceived;
 }
 function sqrt(uint x) internal pure returns (uint y) {
 uint z = (x + 1) / 2;
 y = x;
 while (z < y) {
 y = z;
 z = (x / z + z) / 2;
 }
 }
 }
 library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) {
 return 0;
 }
 uint256 c = a * b;
 assert(c / a == b);
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a / b;
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 assert(b <= a);
 return a - b;
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 assert(c >= a);
 return c;
 }
 }
