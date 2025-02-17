           pragma solidity ^0.6.0;
 contract Initializable {
 bool private initialized;
 bool private initializing;
 modifier initializer() {
 require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");
 bool isTopLevelCall = !initializing;
 if (isTopLevelCall) {
 initializing = true;
 initialized = true;
 }
 _;
 if (isTopLevelCall) {
 initializing = false;
 }
 }
 function isConstructor() private view returns (bool) {
 address self = address(this);
 uint256 cs;
 assembly {
 cs := extcodesize(self) }
 return cs == 0;
 }
 uint256[50] private ______gap;
 }
 contract ContextUpgradeSafe is Initializable {
 function __Context_init() internal initializer {
 __Context_init_unchained();
 }
 function __Context_init_unchained() internal initializer {
 }
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
 }
 uint256[50] private __gap;
 }
 library Math {
 function max(uint256 a, uint256 b) internal pure returns (uint256) {
 return a >= b ? a : b;
 }
 function min(uint256 a, uint256 b) internal pure returns (uint256) {
 return a < b ? a : b;
 }
 function average(uint256 a, uint256 b) internal pure returns (uint256) {
 return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
 }
 }
 library SafeMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 return sub(a, b, "SafeMath: subtraction overflow");
 }
 function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b <= a, errorMessage);
 uint256 c = a - b;
 return c;
 }
 function sub0(uint256 a, uint256 b) internal pure returns (uint256) {
 return a > b ? a - b : 0;
 }
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) {
 return 0;
 }
 uint256 c = a * b;
 require(c / a == b, "SafeMath: multiplication overflow");
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 return div(a, b, "SafeMath: division by zero");
 }
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 uint256 c = a / b;
 return c;
 }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 return mod(a, b, "SafeMath: modulo by zero");
 }
 function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b != 0, errorMessage);
 return a % b;
 }
 }
 library Address {
 function isContract(address account) internal view returns (bool) {
 bytes32 codehash;
 bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
 assembly {
 codehash := extcodehash(account) }
 return (codehash != accountHash && codehash != 0x0);
 }
 function sendValue(address payable recipient, uint256 amount) internal {
 require(address(this).balance >= amount, "Address: insufficient balance");
 (bool success, ) = recipient.call{
 value: amount }
 ("");
 require(success, "Address: unable to send value, recipient may have reverted");
 }
 }
 interface IERC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 }
 contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {
 using SafeMath for uint256;
 using Address for address;
 mapping (address => uint256) private _balances;
 mapping (address => mapping (address => uint256)) private _allowances;
 uint256 private _totalSupply;
 string private _name;
 string private _symbol;
 uint8 private _decimals;
 function __ERC20_init(string memory name, string memory symbol) internal initializer {
 __Context_init_unchained();
 __ERC20_init_unchained(name, symbol);
 }
 function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {
 _name = name;
 _symbol = symbol;
 _decimals = 18;
 }
 function name() public view returns (string memory) {
 return _name;
 }
 function symbol() public view returns (string memory) {
 return _symbol;
 }
 function decimals() public view returns (uint8) {
 return _decimals;
 }
 function totalSupply() public view override returns (uint256) {
 return _totalSupply;
 }
 function balanceOf(address account) public view override returns (uint256) {
 return _balances[account];
 }
 function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
 _transfer(_msgSender(), recipient, amount);
 return true;
 }
 function allowance(address owner, address spender) public view virtual override returns (uint256) {
 return _allowances[owner][spender];
 }
 function approve(address spender, uint256 amount) public virtual override returns (bool) {
 _approve(_msgSender(), spender, amount);
 return true;
 }
 function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
 _transfer(sender, recipient, amount);
 _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
 return true;
 }
 function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
 _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
 return true;
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
 _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
 return true;
 }
 function _transfer(address sender, address recipient, uint256 amount) internal virtual {
 require(sender != address(0), "ERC20: transfer from the zero address");
 require(recipient != address(0), "ERC20: transfer to the zero address");
 _beforeTokenTransfer(sender, recipient, amount);
 _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
 _balances[recipient] = _balances[recipient].add(amount);
 emit Transfer(sender, recipient, amount);
 }
 function _mint(address account, uint256 amount) internal virtual {
 require(account != address(0), "ERC20: mint to the zero address");
 _beforeTokenTransfer(address(0), account, amount);
 _totalSupply = _totalSupply.add(amount);
 _balances[account] = _balances[account].add(amount);
 emit Transfer(address(0), account, amount);
 }
 function _burn(address account, uint256 amount) internal virtual {
 require(account != address(0), "ERC20: burn from the zero address");
 _beforeTokenTransfer(account, address(0), amount);
 _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
 _totalSupply = _totalSupply.sub(amount);
 emit Transfer(account, address(0), amount);
 }
 function _approve(address owner, address spender, uint256 amount) internal virtual {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function _setupDecimals(uint8 decimals_) internal {
 _decimals = decimals_;
 }
 function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
 }
 uint256[44] private __gap;
 }
 abstract contract ERC20CappedUpgradeSafe is Initializable, ERC20UpgradeSafe {
 uint256 private _cap;
 function __ERC20Capped_init(uint256 cap) internal initializer {
 __Context_init_unchained();
 __ERC20Capped_init_unchained(cap);
 }
 function __ERC20Capped_init_unchained(uint256 cap) internal initializer {
 require(cap > 0, "ERC20Capped: cap is 0");
 _cap = cap;
 }
 function cap() public view returns (uint256) {
 return _cap;
 }
 function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
 super._beforeTokenTransfer(from, to, amount);
 if (from == address(0)) {
 require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
 }
 }
 uint256[49] private __gap;
 }
 library SafeERC20 {
 using SafeMath for uint256;
 using Address for address;
 function safeTransfer(IERC20 token, address to, uint256 value) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
 }
 function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
 }
 function safeApprove(IERC20 token, address spender, uint256 value) internal {
 require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance" );
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
 }
 function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
 uint256 newAllowance = token.allowance(address(this), spender).add(value);
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
 }
 function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
 uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
 }
 function _callOptionalReturn(IERC20 token, bytes memory data) private {
 require(address(token).isContract(), "SafeERC20: call to non-contract");
 (bool success, bytes memory returndata) = address(token).call(data);
 require(success, "SafeERC20: low-level call failed");
 if (returndata.length > 0) {
 require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
 }
 }
 }
 contract Governable is Initializable {
 address public governor;
 event GovernorshipTransferred(address indexed previousGovernor, address indexed newGovernor);
 function __Governable_init_unchained(address governor_) virtual public initializer {
 governor = governor_;
 emit GovernorshipTransferred(address(0), governor);
 }
 modifier governance() {
 require(msg.sender == governor);
 _;
 }
 function renounceGovernorship() public governance {
 emit GovernorshipTransferred(governor, address(0));
 governor = address(0);
 }
 function transferGovernorship(address newGovernor) public governance {
 _transferGovernorship(newGovernor);
 }
 function _transferGovernorship(address newGovernor) internal {
 require(newGovernor != address(0));
 emit GovernorshipTransferred(governor, newGovernor);
 governor = newGovernor;
 }
 }
 contract Configurable is Governable {
 mapping (bytes32 => uint) internal config;
 function getConfig(bytes32 key) public view returns (uint) {
 return config[key];
 }
 function getConfig(bytes32 key, uint index) public view returns (uint) {
 return config[bytes32(uint(key) ^ index)];
 }
 function getConfig(bytes32 key, address addr) public view returns (uint) {
 return config[bytes32(uint(key) ^ uint(addr))];
 }
 function _setConfig(bytes32 key, uint value) internal {
 if(config[key] != value) config[key] = value;
 }
 function _setConfig(bytes32 key, uint index, uint value) internal {
 _setConfig(bytes32(uint(key) ^ index), value);
 }
 function _setConfig(bytes32 key, address addr, uint value) internal {
 _setConfig(bytes32(uint(key) ^ uint(addr)), value);
 }
 function setConfig(bytes32 key, uint value) external governance {
 _setConfig(key, value);
 }
 function setConfig(bytes32 key, uint index, uint value) external governance {
 _setConfig(bytes32(uint(key) ^ index), value);
 }
 function setConfig(bytes32 key, address addr, uint value) public governance {
 _setConfig(bytes32(uint(key) ^ uint(addr)), value);
 }
 }
 contract Offering is Configurable {
 using SafeMath for uint;
 using SafeERC20 for IERC20;
 bytes32 internal constant _quota_ = 'quota';
 bytes32 internal constant _volume_ = 'volume';
 bytes32 internal constant _unlocked_ = 'unlocked';
 bytes32 internal constant _ratioUnlockFirst_= 'ratioUnlockFirst';
 bytes32 internal constant _ratio_ = 'ratio';
 bytes32 internal constant _isSeed_ = 'isSeed';
 bytes32 internal constant _public_ = 'public';
 bytes32 internal constant _recipient_ = 'recipient';
 bytes32 internal constant _time_ = 'time';
 uint internal constant _timeOfferBegin_ = 0;
 uint internal constant _timeOfferEnd_ = 1;
 uint internal constant _timeUnlockFirst_ = 2;
 uint internal constant _timeUnlockBegin_ = 3;
 uint internal constant _timeUnlockEnd_ = 4;
 IERC20 public currency;
 IERC20 public token;
 function __Offering_init(address governor_, address currency_, address token_, address public_, address recipient_, uint[5] memory times_) external initializer {
 __Governable_init_unchained(governor_);
 __Offering_init_unchained(currency_, token_, public_, recipient_, times_);
 }
 function __Offering_init_unchained(address currency_, address token_, address public_, address recipient_, uint[5] memory times_) public governance {
 currency = IERC20(currency_);
 token = IERC20(token_);
 _setConfig(_ratio_, 0, 28818181818181);
 _setConfig(_ratio_, 1, 54333333333333);
 _setConfig(_public_, uint(public_));
 _setConfig(_recipient_, uint(recipient_));
 _setConfig(_ratioUnlockFirst_, 0.25 ether);
 for(uint i=0; i<times_.length; i++) _setConfig(_time_, i, times_[i]);
 }
 function setQuota(address addr, uint amount, bool isSeed) public governance {
 uint oldVol = getConfig(_quota_, addr).mul(getConfig(_ratio_, getConfig(_isSeed_, addr)));
 _setConfig(_quota_, addr, amount);
 if(isSeed) _setConfig(_isSeed_, addr, 1);
 uint volume = amount.mul(getConfig(_ratio_, isSeed ? 1 : 0));
 uint totalVolume = getConfig(_volume_, address(0)).add(volume).sub(oldVol);
 require(totalVolume <= token.balanceOf(address(this)), 'out of quota');
 _setConfig(_volume_, address(0), totalVolume);
 }
 function setQuotas(address[] memory addrs, uint[] memory amounts, bool isSeed) public {
 for(uint i=0; i<addrs.length; i++) setQuota(addrs[i], amounts[i], isSeed);
 }
 function getQuota(address addr) public view returns (uint) {
 return getConfig(_quota_, addr);
 }
 function offer() external {
 require(now >= getConfig(_time_, _timeOfferBegin_), 'Not begin');
 if(now > getConfig(_time_, _timeOfferEnd_)) if(token.balanceOf(address(this)) > 0) token.safeTransfer(address(config[_public_]), token.balanceOf(address(this)));
 else revert('offer over');
 uint quota = getConfig(_quota_, msg.sender);
 require(quota > 0, 'no quota');
 require(currency.allowance(msg.sender, address(this)) >= quota, 'allowance not enough');
 require(currency.balanceOf(msg.sender) >= quota, 'balance not enough');
 require(getConfig(_volume_, msg.sender) == 0, 'offered already');
 currency.safeTransferFrom(msg.sender, address(config[_recipient_]), quota);
 _setConfig(_volume_, msg.sender, quota.mul(getConfig(_ratio_, getConfig(_isSeed_, msg.sender))));
 }
 function getVolume(address addr) public view returns (uint) {
 return getConfig(_volume_, addr);
 }
 function unlockCapacity(address addr) public view returns (uint c) {
 uint timeUnlockFirst = getConfig(_time_, _timeUnlockFirst_);
 if(timeUnlockFirst == 0 || now < timeUnlockFirst) return 0;
 uint timeUnlockBegin = getConfig(_time_, _timeUnlockBegin_);
 uint timeUnlockEnd = getConfig(_time_, _timeUnlockEnd_);
 uint volume = getConfig(_volume_, addr);
 uint ratioUnlockFirst = getConfig(_ratioUnlockFirst_);
 c = volume.mul(ratioUnlockFirst).div(1e18);
 if(now >= timeUnlockEnd) c = volume;
 else if(now > timeUnlockBegin) c = volume.sub(c).mul(now.sub(timeUnlockBegin)).div(timeUnlockEnd.sub(timeUnlockBegin)).add(c);
 return c.sub(getConfig(_unlocked_, addr));
 }
 function unlock() public {
 uint c = unlockCapacity(msg.sender);
 _setConfig(_unlocked_, msg.sender, getConfig(_unlocked_, msg.sender).add(c));
 _setConfig(_unlocked_, address(0), getConfig(_unlocked_, address(0)).add(c));
 token.safeTransfer(msg.sender, c);
 }
 function unlocked(address addr) public view returns (uint) {
 return getConfig(_unlocked_, addr);
 }
 fallback() external {
 unlock();
 }
 }
 contract Timelock is Configurable {
 using SafeMath for uint;
 using SafeERC20 for IERC20;
 IERC20 public token;
 address public recipient;
 uint public begin;
 uint public span;
 uint public times;
 uint public total;
 function start(address _token, address _recipient, uint _begin, uint _span, uint _times) external governance {
 require(address(token) == address(0), 'already start');
 token = IERC20(_token);
 recipient = _recipient;
 begin = _begin;
 span = _span;
 times = _times;
 total = token.balanceOf(address(this));
 }
 function unlockCapacity() public view returns (uint) {
 if(begin == 0 || now < begin) return 0;
 for(uint i=1; i<=times; i++) if(now < span.mul(i).div(times).add(begin)) return token.balanceOf(address(this)).sub(total.mul(times.sub(i)).div(times));
 return token.balanceOf(address(this));
 }
 function unlock() public {
 token.safeTransfer(recipient, unlockCapacity());
 }
 fallback() external {
 unlock();
 }
 }
 contract AuthQuota is Configurable {
 using SafeMath for uint;
 bytes32 internal constant _authQuota_ = 'authQuota';
 function authQuotaOf(address signatory) virtual public view returns (uint) {
 return getConfig(_authQuota_, signatory);
 }
 function increaseAuthQuota(address signatory, uint increment) virtual external governance returns (uint quota) {
 quota = getConfig(_authQuota_, signatory).add(increment);
 _setConfig(_authQuota_, signatory, quota);
 emit IncreaseAuthQuota(signatory, increment, quota);
 }
 event IncreaseAuthQuota(address indexed signatory, uint increment, uint quota);
 function decreaseAuthQuota(address signatory, uint decrement) virtual external governance returns (uint quota) {
 quota = getConfig(_authQuota_, signatory);
 if(quota < decrement) decrement = quota;
 return _decreaseAuthQuota(signatory, decrement);
 }
 function _decreaseAuthQuota(address signatory, uint decrement) virtual internal returns (uint quota) {
 quota = getConfig(_authQuota_, signatory).sub(decrement);
 _setConfig(_authQuota_, signatory, quota);
 emit DecreaseAuthQuota(signatory, decrement, quota);
 }
 event DecreaseAuthQuota(address indexed signatory, uint decrement, uint quota);
 }
 contract TokenMapped is ContextUpgradeSafe, AuthQuota {
 using SafeERC20 for IERC20;
 bytes32 public constant REDEEM_TYPEHASH = keccak256("Redeem(address authorizer,address to,uint256 volume,uint256 chainId,uint256 txHash)");
 bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
 bytes32 public DOMAIN_SEPARATOR;
 mapping (uint => bool) public redeemed;
 address public token;
 function __TokenMapped_init(address governor_, address token_) external initializer {
 __Context_init_unchained();
 __Governable_init_unchained(governor_);
 __TokenMapped_init_unchained(token_);
 }
 function __TokenMapped_init_unchained(address token_) public governance {
 token = token_;
 uint256 chainId;
 assembly {
 chainId := chainid() }
 DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(ERC20UpgradeSafe(token).name())), chainId, address(this)));
 }
 function totalMapped() virtual public view returns (uint) {
 return IERC20(token).balanceOf(address(this));
 }
 function stake(uint volume, uint chainId, address to) virtual external {
 IERC20(token).safeTransferFrom(_msgSender(), address(this), volume);
 emit Stake(_msgSender(), volume, chainId, to);
 }
 event Stake(address indexed from, uint volume, uint indexed chainId, address indexed to);
 function _redeem(address authorizer, address to, uint volume, uint chainId, uint txHash) virtual internal {
 require(!redeemed[chainId ^ txHash], 'redeemed already');
 redeemed[chainId ^ txHash] = true;
 _decreaseAuthQuota(authorizer, volume);
 IERC20(token).safeTransfer(to, volume);
 emit Redeem(authorizer, to, volume, chainId, txHash);
 }
 event Redeem(address indexed signatory, address indexed to, uint volume, uint chainId, uint indexed txHash);
 function redeem(address to, uint volume, uint chainId, uint txHash) virtual external {
 _redeem(_msgSender(), to, volume, chainId, txHash);
 }
 function redeem(address authorizer, address to, uint256 volume, uint256 chainId, uint256 txHash, uint8 v, bytes32 r, bytes32 s) external virtual {
 bytes32 structHash = keccak256(abi.encode(REDEEM_TYPEHASH, authorizer, to, volume, chainId, txHash));
 bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
 address signatory = ecrecover(digest, v, r, s);
 require(signatory != address(0), "invalid signature");
 require(signatory == authorizer, "unauthorized");
 _redeem(authorizer, to, volume, chainId, txHash);
 }
 uint256[50] private __gap;
 }
 interface IPermit {
 function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
 }
 contract MappableToken is ERC20UpgradeSafe, AuthQuota, IPermit {
 bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
 bytes32 public constant REDEEM_TYPEHASH = keccak256("Redeem(address authorizer,address to,uint256 volume,uint256 chainId,uint256 txHash)");
 bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
 bytes32 public DOMAIN_SEPARATOR;
 mapping (address => uint) public nonces;
 mapping (uint => bool) public redeemed;
 address public token;
 function __MappableToken_init(address governor_, string memory name_, string memory symbol_, uint8 decimals_) external initializer {
 __Context_init_unchained();
 __ERC20_init_unchained(name_, symbol_);
 _setupDecimals(decimals_);
 __Governable_init_unchained(governor_);
 __MappableToken_init_unchained();
 }
 function __MappableToken_init_unchained() public governance {
 token = address(this);
 uint256 chainId;
 assembly {
 chainId := chainid() }
 DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), chainId, address(this)));
 }
 function totalMapped() virtual public view returns (uint) {
 return balanceOf(address(this));
 }
 function stake(uint volume, uint chainId, address to) virtual external {
 _transfer(_msgSender(), address(this), volume);
 emit Stake(_msgSender(), volume, chainId, to);
 }
 event Stake(address indexed from, uint volume, uint indexed chainId, address indexed to);
 function _redeem(address authorizer, address to, uint volume, uint chainId, uint txHash) virtual internal {
 require(!redeemed[chainId ^ txHash], 'redeemed already');
 redeemed[chainId ^ txHash] = true;
 _decreaseAuthQuota(authorizer, volume);
 _transfer(address(this), to, volume);
 emit Redeem(authorizer, to, volume, chainId, txHash);
 }
 event Redeem(address indexed signatory, address indexed to, uint volume, uint chainId, uint indexed txHash);
 function redeem(address to, uint volume, uint chainId, uint txHash) virtual external {
 _redeem(_msgSender(), to, volume, chainId, txHash);
 }
 function redeem(address authorizer, address to, uint256 volume, uint256 chainId, uint256 txHash, uint8 v, bytes32 r, bytes32 s) external virtual {
 bytes32 structHash = keccak256(abi.encode(REDEEM_TYPEHASH, authorizer, to, volume, chainId, txHash));
 bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
 address signatory = ecrecover(digest, v, r, s);
 require(signatory != address(0), "invalid signature");
 require(signatory == authorizer, "unauthorized");
 _redeem(authorizer, to, volume, chainId, txHash);
 }
 function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) override external {
 require(deadline >= block.timestamp, 'permit EXPIRED');
 bytes32 digest = keccak256( abi.encodePacked( '\x19\x01', DOMAIN_SEPARATOR, keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline)) ) );
 address recoveredAddress = ecrecover(digest, v, r, s);
 require(recoveredAddress != address(0) && recoveredAddress == owner, 'permit INVALID_SIGNATURE');
 _approve(owner, spender, value);
 }
 uint256[50] private __gap;
 }
 contract MappingToken is ERC20CappedUpgradeSafe, AuthQuota, IPermit {
 bytes32 public constant MINT_TYPEHASH = keccak256("Mint(address authorizer,address to,uint256 volume,uint256 chainId,uint256 txHash)");
 bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
 bytes32 public DOMAIN_SEPARATOR;
 mapping (address => uint) public nonces;
 mapping (uint => bool) public minted;
 function __MappingToken_init(address governor_, uint cap_, string memory name_, string memory symbol_) external initializer {
 __Context_init_unchained();
 __ERC20_init_unchained(name_, symbol_);
 __ERC20Capped_init_unchained(cap_);
 __Governable_init_unchained(governor_);
 __MappingToken_init_unchained();
 }
 function __MappingToken_init_unchained() public governance {
 uint256 chainId;
 assembly {
 chainId := chainid() }
 DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), chainId, address(this)));
 }
 function _mint(address authorizer, address to, uint volume, uint chainId, uint txHash) virtual internal {
 require(!minted[chainId ^ txHash], 'minted already');
 minted[chainId ^ txHash] = true;
 _decreaseAuthQuota(authorizer, volume);
 _mint(to, volume);
 emit Mint(authorizer, to, volume, chainId, txHash);
 }
 event Mint(address indexed signatory, address indexed to, uint volume, uint chainId, uint indexed txHash);
 function mint(address to, uint volume, uint chainId, uint txHash) virtual external {
 _mint(_msgSender(), to, volume, chainId, txHash);
 }
 function mint(address authorizer, address to, uint256 volume, uint256 chainId, uint256 txHash, uint8 v, bytes32 r, bytes32 s) external virtual {
 bytes32 structHash = keccak256(abi.encode(MINT_TYPEHASH, authorizer, to, volume, chainId, txHash));
 bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
 address signatory = ecrecover(digest, v, r, s);
 require(signatory != address(0), "invalid signature");
 require(signatory == authorizer, "unauthorized");
 _mint(authorizer, to, volume, chainId, txHash);
 }
 function burn(uint volume, uint chainId, address to) virtual external {
 _burn(_msgSender(), volume);
 emit Burn(_msgSender(), volume, chainId, to);
 }
 event Burn(address indexed from, uint volume, uint indexed chainId, address indexed to);
 bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
 function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) override external {
 require(deadline >= block.timestamp, 'permit EXPIRED');
 bytes32 digest = keccak256( abi.encodePacked( '\x19\x01', DOMAIN_SEPARATOR, keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline)) ) );
 address recoveredAddress = ecrecover(digest, v, r, s);
 require(recoveredAddress != address(0) && recoveredAddress == owner, 'permit INVALID_SIGNATURE');
 _approve(owner, spender, value);
 }
 uint256[50] private __gap;
 }
 contract MappingMATTER is MappingToken {
 function __MappingMATTER_init(address governor_, uint cap_) external initializer {
 __Context_init_unchained();
 __ERC20_init_unchained("Antimatter.Finance Mapping Token", "MATTER");
 __ERC20Capped_init_unchained(cap_);
 __Governable_init_unchained(governor_);
 __MappingToken_init_unchained();
 __MappingMATTER_init_unchained();
 }
 function __MappingMATTER_init_unchained() public governance {
 }
 }
 contract MATTER is MappableToken {
 function __MATTER_init(address governor_, address offering_, address public_, address team_, address fund_, address mine_, address liquidity_) external initializer {
 __Context_init_unchained();
 __ERC20_init_unchained("Antimatter.Finance Governance Token", "MATTER");
 __Governable_init_unchained(governor_);
 __MappableToken_init_unchained();
 __MATTER_init_unchained(offering_, public_, team_, fund_, mine_, liquidity_);
 }
 function __MATTER_init_unchained(address offering_, address public_, address team_, address fund_, address mine_, address liquidity_) public initializer {
 _mint(offering_, 24_000_000 * 10 ** uint256(decimals()));
 _mint(public_, 1_000_000 * 10 ** uint256(decimals()));
 _mint(team_, 10_000_000 * 10 ** uint256(decimals()));
 _mint(fund_, 10_000_000 * 10 ** uint256(decimals()));
 _mint(mine_, 50_000_000 * 10 ** uint256(decimals()));
 _mint(liquidity_, 5_000_000 * 10 ** uint256(decimals()));
 }
 }
