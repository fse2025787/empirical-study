 pragma experimental ABIEncoderV2;
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
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, "Address: low-level call failed");
 }
 function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
 return _functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
 return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 }
 function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
 require(address(this).balance >= value, "Address: insufficient balance for call");
 return _functionCallWithValue(target, data, value, errorMessage);
 }
 function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
 value: weiValue }
 (data);
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
 abstract contract Context {
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
 }
 }
 interface IERC165 {
 function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
 interface IERC721Receiver {
 function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
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
 contract ERC20 is Context, IERC20 {
 using SafeMath for uint256;
 using Address for address;
 mapping (address => uint256) private _balances;
 mapping (address => mapping (address => uint256)) private _allowances;
 uint256 private _totalSupply;
 string private _name;
 string private _symbol;
 uint8 private _decimals;
 constructor (string memory name, string memory symbol) public {
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
 }
 interface IERC721 is IERC165 {
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
 bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
 if (returndata.length > 0) {
 require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
 }
 }
 }
 struct StrategyParams {
 uint256 performanceFee;
 uint256 activation;
 uint256 debtRatio;
 uint256 minDebtPerHarvest;
 uint256 maxDebtPerHarvest;
 uint256 lastReport;
 uint256 totalDebt;
 uint256 totalGain;
 uint256 totalLoss;
 }
 interface VaultAPI is IERC20 {
 function name() external view returns (string calldata);
 function symbol() external view returns (string calldata);
 function decimals() external view returns (uint256);
 function apiVersion() external pure returns (string memory);
 function permit( address owner, address spender, uint256 amount, uint256 expiry, bytes calldata signature ) external returns (bool);
 function deposit() external returns (uint256);
 function deposit(uint256 amount) external returns (uint256);
 function deposit(uint256 amount, address recipient) external returns (uint256);
 function withdraw() external returns (uint256);
 function withdraw(uint256 maxShares) external returns (uint256);
 function withdraw(uint256 maxShares, address recipient) external returns (uint256);
 function token() external view returns (address);
 function strategies(address _strategy) external view returns (StrategyParams memory);
 function pricePerShare() external view returns (uint256);
 function totalAssets() external view returns (uint256);
 function depositLimit() external view returns (uint256);
 function maxAvailableShares() external view returns (uint256);
 function creditAvailable() external view returns (uint256);
 function debtOutstanding() external view returns (uint256);
 function expectedReturn() external view returns (uint256);
 function report( uint256 _gain, uint256 _loss, uint256 _debtPayment ) external returns (uint256);
 function revokeStrategy() external;
 function governance() external view returns (address);
 function management() external view returns (address);
 function guardian() external view returns (address);
 }
 interface StrategyAPI {
 function name() external view returns (string memory);
 function vault() external view returns (address);
 function want() external view returns (address);
 function apiVersion() external pure returns (string memory);
 function keeper() external view returns (address);
 function isActive() external view returns (bool);
 function delegatedAssets() external view returns (uint256);
 function estimatedTotalAssets() external view returns (uint256);
 function tendTrigger(uint256 callCost) external view returns (bool);
 function tend() external;
 function harvestTrigger(uint256 callCost) external view returns (bool);
 function harvest() external;
 event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);
 }
 interface HealthCheck {
 function check( uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding, uint256 totalDebt ) external view returns (bool);
 }
 abstract contract BaseStrategy {
 using SafeMath for uint256;
 using SafeERC20 for IERC20;
 string public metadataURI;
 bool public doHealthCheck;
 address public healthCheck;
 function apiVersion() public pure returns (string memory) {
 return "0.4.3";
 }
 function name() external view virtual returns (string memory);
 function delegatedAssets() external view virtual returns (uint256) {
 return 0;
 }
 VaultAPI public vault;
 address public strategist;
 address public rewards;
 address public keeper;
 IERC20 public want;
 event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);
 event UpdatedStrategist(address newStrategist);
 event UpdatedKeeper(address newKeeper);
 event UpdatedRewards(address rewards);
 event UpdatedMinReportDelay(uint256 delay);
 event UpdatedMaxReportDelay(uint256 delay);
 event UpdatedProfitFactor(uint256 profitFactor);
 event UpdatedDebtThreshold(uint256 debtThreshold);
 event EmergencyExitEnabled();
 event UpdatedMetadataURI(string metadataURI);
 uint256 public minReportDelay;
 uint256 public maxReportDelay;
 uint256 public profitFactor;
 uint256 public debtThreshold;
 bool public emergencyExit;
 modifier onlyAuthorized() {
 require(msg.sender == strategist || msg.sender == governance(), "!authorized");
 _;
 }
 modifier onlyEmergencyAuthorized() {
 require( msg.sender == strategist || msg.sender == governance() || msg.sender == vault.guardian() || msg.sender == vault.management(), "!authorized" );
 _;
 }
 modifier onlyStrategist() {
 require(msg.sender == strategist, "!strategist");
 _;
 }
 modifier onlyGovernance() {
 require(msg.sender == governance(), "!authorized");
 _;
 }
 modifier onlyKeepers() {
 require( msg.sender == keeper || msg.sender == strategist || msg.sender == governance() || msg.sender == vault.guardian() || msg.sender == vault.management(), "!authorized" );
 _;
 }
 modifier onlyVaultManagers() {
 require(msg.sender == vault.management() || msg.sender == governance(), "!authorized");
 _;
 }
 constructor(address _vault) public {
 _initialize(_vault, msg.sender, msg.sender, msg.sender);
 }
 function _initialize( address _vault, address _strategist, address _rewards, address _keeper ) internal {
 require(address(want) == address(0), "Strategy already initialized");
 vault = VaultAPI(_vault);
 want = IERC20(vault.token());
 want.safeApprove(_vault, uint256(-1));
 strategist = _strategist;
 rewards = _rewards;
 keeper = _keeper;
 minReportDelay = 0;
 maxReportDelay = 86400;
 profitFactor = 100;
 debtThreshold = 0;
 vault.approve(rewards, uint256(-1));
 }
 function setHealthCheck(address _healthCheck) external onlyVaultManagers {
 healthCheck = _healthCheck;
 }
 function setDoHealthCheck(bool _doHealthCheck) external onlyVaultManagers {
 doHealthCheck = _doHealthCheck;
 }
 function setStrategist(address _strategist) external onlyAuthorized {
 require(_strategist != address(0));
 strategist = _strategist;
 emit UpdatedStrategist(_strategist);
 }
 function setKeeper(address _keeper) external onlyAuthorized {
 require(_keeper != address(0));
 keeper = _keeper;
 emit UpdatedKeeper(_keeper);
 }
 function setRewards(address _rewards) external onlyStrategist {
 require(_rewards != address(0));
 vault.approve(rewards, 0);
 rewards = _rewards;
 vault.approve(rewards, uint256(-1));
 emit UpdatedRewards(_rewards);
 }
 function setMinReportDelay(uint256 _delay) external onlyAuthorized {
 minReportDelay = _delay;
 emit UpdatedMinReportDelay(_delay);
 }
 function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
 maxReportDelay = _delay;
 emit UpdatedMaxReportDelay(_delay);
 }
 function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
 profitFactor = _profitFactor;
 emit UpdatedProfitFactor(_profitFactor);
 }
 function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
 debtThreshold = _debtThreshold;
 emit UpdatedDebtThreshold(_debtThreshold);
 }
 function setMetadataURI(string calldata _metadataURI) external onlyAuthorized {
 metadataURI = _metadataURI;
 emit UpdatedMetadataURI(_metadataURI);
 }
 function governance() internal view returns (address) {
 return vault.governance();
 }
 function ethToWant(uint256 _amtInWei) public view virtual returns (uint256);
 function estimatedTotalAssets() public view virtual returns (uint256);
 function isActive() public view returns (bool) {
 return vault.strategies(address(this)).debtRatio > 0 || estimatedTotalAssets() > 0;
 }
 function prepareReturn(uint256 _debtOutstanding) internal virtual returns ( uint256 _profit, uint256 _loss, uint256 _debtPayment );
 function adjustPosition(uint256 _debtOutstanding) internal virtual;
 function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);
 function liquidateAllPositions() internal virtual returns (uint256 _amountFreed);
 function tendTrigger(uint256 callCostInWei) public view virtual returns (bool) {
 return false;
 }
 function tend() external onlyKeepers {
 adjustPosition(vault.debtOutstanding());
 }
 function harvestTrigger(uint256 callCostInWei) public view virtual returns (bool) {
 uint256 callCost = ethToWant(callCostInWei);
 StrategyParams memory params = vault.strategies(address(this));
 if (params.activation == 0) return false;
 if (block.timestamp.sub(params.lastReport) < minReportDelay) return false;
 if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;
 uint256 outstanding = vault.debtOutstanding();
 if (outstanding > debtThreshold) return true;
 uint256 total = estimatedTotalAssets();
 if (total.add(debtThreshold) < params.totalDebt) return true;
 uint256 profit = 0;
 if (total > params.totalDebt) profit = total.sub(params.totalDebt);
 uint256 credit = vault.creditAvailable();
 return (profitFactor.mul(callCost) < credit.add(profit));
 }
 function harvest() external onlyKeepers {
 uint256 profit = 0;
 uint256 loss = 0;
 uint256 debtOutstanding = vault.debtOutstanding();
 uint256 debtPayment = 0;
 if (emergencyExit) {
 uint256 amountFreed = liquidateAllPositions();
 if (amountFreed < debtOutstanding) {
 loss = debtOutstanding.sub(amountFreed);
 }
 else if (amountFreed > debtOutstanding) {
 profit = amountFreed.sub(debtOutstanding);
 }
 debtPayment = debtOutstanding.sub(loss);
 }
 else {
 (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
 }
 uint256 totalDebt = vault.strategies(address(this)).totalDebt;
 debtOutstanding = vault.report(profit, loss, debtPayment);
 adjustPosition(debtOutstanding);
 if (doHealthCheck && healthCheck != address(0)) {
 require(HealthCheck(healthCheck).check(profit, loss, debtPayment, debtOutstanding, totalDebt), "!healthcheck");
 }
 else {
 doHealthCheck = true;
 }
 emit Harvested(profit, loss, debtPayment, debtOutstanding);
 }
 function withdraw(uint256 _amountNeeded) external returns (uint256 _loss) {
 require(msg.sender == address(vault), "!vault");
 uint256 amountFreed;
 (amountFreed, _loss) = liquidatePosition(_amountNeeded);
 want.safeTransfer(msg.sender, amountFreed);
 }
 function prepareMigration(address _newStrategy) internal virtual;
 function migrate(address _newStrategy) external {
 require(msg.sender == address(vault));
 require(BaseStrategy(_newStrategy).vault() == vault);
 prepareMigration(_newStrategy);
 want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
 }
 function setEmergencyExit() external onlyEmergencyAuthorized {
 emergencyExit = true;
 vault.revokeStrategy();
 emit EmergencyExitEnabled();
 }
 function protectedTokens() internal view virtual returns (address[] memory);
 function sweep(address _token) external onlyGovernance {
 require(_token != address(want), "!want");
 require(_token != address(vault), "!shares");
 address[] memory _protectedTokens = protectedTokens();
 for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");
 IERC20(_token).safeTransfer(governance(), IERC20(_token).balanceOf(address(this)));
 }
 }
 abstract contract BaseStrategyInitializable is BaseStrategy {
 bool public isOriginal = true;
 event Cloned(address indexed clone);
 constructor(address _vault) public BaseStrategy(_vault) {
 }
 function initialize( address _vault, address _strategist, address _rewards, address _keeper ) external virtual {
 _initialize(_vault, _strategist, _rewards, _keeper);
 }
 function clone(address _vault) external returns (address) {
 require(isOriginal, "!clone");
 return this.clone(_vault, msg.sender, msg.sender, msg.sender);
 }
 function clone( address _vault, address _strategist, address _rewards, address _keeper ) external returns (address newStrategy) {
 bytes20 addressBytes = bytes20(address(this));
 assembly {
 let clone_code := mload(0x40) mstore(clone_code, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000) mstore(add(clone_code, 0x14), addressBytes) mstore(add(clone_code, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000) newStrategy := create(0, clone_code, 0x37) }
 BaseStrategyInitializable(newStrategy).initialize(_vault, _strategist, _rewards, _keeper);
 emit Cloned(newStrategy);
 }
 }
 interface IVesting {
 struct Vest {
 address pool;
 uint64 depositID;
 uint64 lastUpdateTimestamp;
 uint256 accumulatedAmount;
 uint256 withdrawnAmount;
 uint256 vestAmountPerStablecoinPerSecond;
 }
 function safeTransferFrom( address from, address to, uint256 tokenId, bytes memory _data ) external;
 function depositIDToVestID(address _owner, uint64 _depositId) external view returns (uint64 _vestId);
 function getVestWithdrawableAmount(uint64 vestID) external view returns (uint256);
 function getVest(uint64 vestID) external view returns (Vest memory);
 function withdraw(uint64 vestID) external returns (uint256 withdrawnAmount);
 function token() external view returns (address);
 function ownerOf(uint256 vestId) external view returns (address);
 }
 interface IMphMinter {
 function vesting02() external view returns (address);
 }
 interface IDInterest {
 struct Deposit {
 uint256 virtualTokenTotalSupply;
 uint256 interestRate;
 uint256 feeRate;
 uint256 averageRecordedIncomeIndex;
 uint64 maturationTimestamp;
 uint64 fundingID;
 }
 function feeModel() external view returns (address);
 function mphMinter() external view returns (address);
 function stablecoin() external view returns (address);
 function depositNFT() external view returns (address);
 function deposit(uint256 depositAmount, uint64 maturationTimestamp) external returns (uint64 depositID, uint256 interestAmount);
 function deposit( uint256 depositAmount, uint64 maturationTimestamp, uint256 minimumInterestAmount, string calldata uri ) external returns (uint64 depositID, uint256 interestAmount);
 function topupDeposit(uint64 depositID, uint256 depositAmount) external returns (uint256 interestAmount);
 function topupDeposit( uint64 depositID, uint256 depositAmount, uint256 minimumInterestAmount ) external returns (uint256 interestAmount);
 function rolloverDeposit(uint64 depositID, uint64 maturationTimestamp) external returns (uint256 newDepositID, uint256 interestAmount);
 function rolloverDeposit( uint64 depositID, uint64 maturationTimestamp, uint256 minimumInterestAmount, string calldata uri ) external returns (uint256 newDepositID, uint256 interestAmount);
 function withdraw( uint64 depositID, uint256 virtualTokenAmount, bool early ) external returns (uint256 withdrawnStablecoinAmount);
 function getDeposit(uint64 depositID) external view returns (Deposit memory);
 function calculateInterestAmount( uint256 depositAmount, uint256 depositPeriodInSeconds ) external returns (uint256 interestAmount);
 }
 interface IStake is IERC20 {
 function deposit(uint256 _mphAmount) external returns (uint256 shareAmount);
 function withdraw(uint256 _shareAmount) external returns (uint256 mphAmount);
 function getPricePerFullShare() external view returns (uint256);
 }
 interface INft {
 function safeTransferFrom( address from, address to, uint256 tokenId ) external;
 function safeTransferFrom( address from, address to, uint256 tokenId, bytes memory _data ) external;
 function contractURI() external view returns (string memory);
 function setTokenURI(uint256 tokenId, string calldata newURI) external;
 }
 interface INftDescriptor {
 struct URIParams {
 uint256 tokenId;
 address owner;
 string name;
 string symbol;
 }
 function constructTokenURI(URIParams memory params) external pure returns (string memory);
 }
 interface ITradeFactory {
 function enable(address, address) external;
 function disable(address, address) external;
 }
 interface IPercentageFeeModel {
 function getEarlyWithdrawFeeAmount( address pool, uint64 depositID, uint256 withdrawnDepositAmount ) external view returns (uint256 feeAmount);
 }
 contract Strategy is BaseStrategy, IERC721Receiver {
 string internal strategyName;
 INft public depositNft;
 IDInterest public pool;
 IVesting public vestNft;
 bytes internal constant DEPOSIT = "deposit";
 bytes internal constant VEST = "vest";
 uint64 public depositId;
 uint64 public maturationPeriod;
 address public oldStrategy;
 uint256 public minWithdraw;
 bool public allowEarlyWithdrawFee;
 uint256 internal constant basisMax = 10000;
 IERC20 public reward;
 uint256 private constant max = type(uint256).max;
 address public keep;
 uint256 public keepBips;
 ITradeFactory public tradeFactory;
 constructor( address _vault, address _pool, string memory _strategyName ) public BaseStrategy(_vault) {
 _initializeStrat(_vault, _pool, _strategyName);
 }
 function initialize( address _vault, address _strategist, address _rewards, address _keeper, address _pool, string memory _strategyName ) external {
 _initialize(_vault, _strategist, _rewards, _keeper);
 _initializeStrat(_vault, _pool, _strategyName);
 }
 function _initializeStrat( address _vault, address _pool, string memory _strategyName ) internal {
 strategyName = _strategyName;
 pool = IDInterest(_pool);
 require(address(want) == pool.stablecoin(), "Wrong pool!");
 vestNft = IVesting(IMphMinter(pool.mphMinter()).vesting02());
 reward = IERC20(vestNft.token());
 depositNft = INft(pool.depositNFT());
 healthCheck = address(0xDDCea799fF1699e98EDF118e0629A974Df7DF012);
 maturationPeriod = 5 * 24 * 60 * 60;
 want.safeApprove(address(pool), max);
 keep = governance();
 keepBips = 0;
 }
 function name() external view override returns (string memory) {
 return strategyName;
 }
 function estimatedTotalAssets() public view override returns (uint256) {
 return balanceOfWant().add(balanceOfPooled());
 }
 function prepareReturn(uint256 _debtOutstanding) internal override returns ( uint256 _profit, uint256 _loss, uint256 _debtPayment ) {
 uint256 totalDebt = vault.strategies(address(this)).totalDebt;
 uint256 totalAssets = estimatedTotalAssets();
 _profit = totalAssets > totalDebt ? totalAssets.sub(totalDebt) : 0;
 uint256 freed;
 if (hasMatured()) {
 freed = liquidateAllPositions();
 _loss = _debtOutstanding > freed ? _debtOutstanding.sub(freed) : 0;
 }
 else {
 uint256 toLiquidate = _debtOutstanding.add(_profit);
 if (toLiquidate > 0) {
 (freed, _loss) = liquidatePosition(toLiquidate);
 }
 }
 _debtPayment = Math.min(_debtOutstanding, freed);
 if (_profit > _loss) {
 _profit = _profit.sub(_loss);
 _loss = 0;
 }
 else {
 _loss = _loss.sub(_profit);
 _profit = 0;
 }
 if (hasMatured()) {
 depositId = 0;
 }
 }
 function adjustPosition(uint256 _debtOutstanding) internal override {
 _claim();
 _invest();
 }
 function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _liquidatedAmount, uint256 _loss) {
 if (_amountNeeded > 0) {
 uint256 loose = balanceOfWant();
 if (_amountNeeded > loose) {
 uint256 toExitAmount = _amountNeeded.sub(loose);
 IDInterest.Deposit memory depositInfo = getDepositInfo();
 uint256 toExitVirtualAmount = toExitAmount.mul(depositInfo.interestRate.add(1e18)).div( 1e18 );
 _poolWithdraw(toExitVirtualAmount);
 _liquidatedAmount = Math.min(balanceOfWant(), _amountNeeded);
 _loss = _amountNeeded.sub(_liquidatedAmount);
 }
 else {
 _liquidatedAmount = _amountNeeded;
 _loss = 0;
 }
 }
 }
 function liquidateAllPositions() internal override returns (uint256) {
 IDInterest.Deposit memory depositInfo = getDepositInfo();
 _poolWithdraw(depositInfo.virtualTokenTotalSupply);
 return balanceOfWant();
 }
 function prepareMigration(address _newStrategy) internal override {
 depositNft.safeTransferFrom( address(this), _newStrategy, depositId, DEPOSIT );
 vestNft.safeTransferFrom(address(this), _newStrategy, vestId(), VEST);
 }
 function protectedTokens() internal view override returns (address[] memory) {
 }
 function ethToWant(uint256 _amtInWei) public view virtual override returns (uint256) {
 return 0;
 }
 function closeEpoch() external onlyEmergencyAuthorized {
 _closeEpoch();
 }
 function _closeEpoch() internal {
 liquidateAllPositions();
 }
 function invest() external onlyVaultManagers {
 _invest();
 }
 function _invest() internal {
 uint256 loose = balanceOfWant();
 if (depositId != 0) {
 if (loose > 0 && !hasMatured()) {
 uint256 timeLeft = uint256(getDepositInfo().maturationTimestamp).sub(now);
 uint256 futureInterest = pool.calculateInterestAmount(loose, timeLeft);
 if (futureInterest > 0) {
 pool.topupDeposit(depositId, loose);
 }
 }
 }
 else {
 uint256 futureInterest = pool.calculateInterestAmount(loose, maturationPeriod);
 if (loose > 0 && futureInterest > 0) {
 (depositId,) = pool.deposit( loose, uint64(now + maturationPeriod) );
 }
 }
 }
 function claim() external onlyVaultManagers {
 _claim();
 }
 function _claim() internal {
 uint256 _rewardBalanceBeforeClaim = balanceOfReward();
 if (depositId != 0 && balanceOfClaimableReward() > 0) {
 vestNft.withdraw(vestId());
 uint256 _rewardAmountToKeep = balanceOfReward() .sub(_rewardBalanceBeforeClaim) .mul(keepBips) .div(basisMax);
 if (_rewardAmountToKeep > 0) {
 reward.safeTransfer(keep, _rewardAmountToKeep);
 }
 }
 }
 function poolWithdraw(uint256 _virtualAmount) external onlyVaultManagers {
 _poolWithdraw(_virtualAmount);
 }
 function _poolWithdraw(uint256 _virtualAmount) internal {
 if (!hasMatured() && !allowEarlyWithdrawFee) {
 require(getEarlyWithdrawFee() == 0, "!free");
 }
 if (_virtualAmount > minWithdraw) {
 _virtualAmount = Math.min(_virtualAmount.add(1), getDepositInfo().virtualTokenTotalSupply);
 pool.withdraw(depositId, _virtualAmount, !hasMatured());
 }
 }
 function overrideDepositId(uint64 _id) external onlyVaultManagers {
 depositId = _id;
 }
 function balanceOfPooled() public view returns (uint256 _amount) {
 if (depositId != 0) {
 uint256 depositWithInterest = getDepositInfo().virtualTokenTotalSupply;
 uint256 interestRate = getDepositInfo().interestRate;
 uint256 depositWithoutInterest = depositWithInterest.mul(1e18).div(interestRate.add(1e18));
 return hasMatured() ? depositWithInterest : depositWithoutInterest;
 }
 }
 function balanceOfWant() public view returns (uint256 _amount) {
 return want.balanceOf(address(this));
 }
 function balanceOfReward() public view returns (uint256 _amount) {
 return reward.balanceOf(address(this));
 }
 function balanceOfClaimableReward() public view returns (uint256 _amount) {
 return vestNft.getVestWithdrawableAmount(vestId());
 }
 function getDepositInfo() public view returns (IDInterest.Deposit memory _deposit) {
 return pool.getDeposit(depositId);
 }
 function getVest() public view returns (IVesting.Vest memory _vest) {
 return vestNft.getVest(vestId());
 }
 function hasMatured() public view returns (bool) {
 return depositId != 0 ? now > getDepositInfo().maturationTimestamp : false;
 }
 function vestId() public view returns (uint64 _vestId) {
 return vestNft.depositIDToVestID(address(pool), depositId);
 }
 function getEarlyWithdrawFee() public view returns (uint256 _feeAmount) {
 return IPercentageFeeModel(pool.feeModel()).getEarlyWithdrawFeeAmount( address(pool), depositId, estimatedTotalAssets() );
 }
 function setTradeFactory(address _tradeFactory) public onlyGovernance {
 _setTradeFactory(_tradeFactory);
 }
 function _setTradeFactory(address _tradeFactory) internal {
 tradeFactory = ITradeFactory(_tradeFactory);
 reward.safeApprove(address(tradeFactory), max);
 tradeFactory.enable(address(reward), address(want));
 }
 function disableTradeFactory() public onlyVaultManagers {
 _disableTradeFactory();
 }
 function _disableTradeFactory() internal {
 delete tradeFactory;
 reward.safeApprove(address(tradeFactory), 0);
 tradeFactory.disable(address(reward), address(want));
 }
 function setMaturationPeriod(uint64 _maturationUnix) public onlyVaultManagers {
 require(_maturationUnix > 24 * 60 * 60);
 maturationPeriod = _maturationUnix;
 }
 function setOldStrategy(address _oldStrategy) public onlyVaultManagers {
 oldStrategy = _oldStrategy;
 }
 function setMinWithdraw(uint256 _minWithdraw) public onlyVaultManagers {
 minWithdraw = _minWithdraw;
 }
 function setAllowWithdrawFee(bool _allow) public onlyVaultManagers {
 allowEarlyWithdrawFee = _allow;
 }
 function setKeepParams(address _keep, uint256 _keepBips) external onlyGovernance {
 require(keepBips <= basisMax);
 keep = _keep;
 keepBips = _keepBips;
 }
 function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) external override returns (bytes4) {
 if ( msg.sender == address(depositNft) && from == oldStrategy && keccak256(data) == keccak256(DEPOSIT) ) {
 depositId = uint64(tokenId);
 }
 return IERC721Receiver.onERC721Received.selector;
 }
 receive() external payable {
 }
 }
