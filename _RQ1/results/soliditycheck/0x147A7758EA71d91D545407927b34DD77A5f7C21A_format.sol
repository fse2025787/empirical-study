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
 pragma solidity >=0.6.0 <0.8.0;
 interface IERC20Upgradeable {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 }
 pragma solidity ^0.7.6;
 interface ICuration {
 function setDefaultReserveRatio(uint32 _defaultReserveRatio) external;
 function setMinimumCurationDeposit(uint256 _minimumCurationDeposit) external;
 function setCurationTaxPercentage(uint32 _percentage) external;
 function setCurationTokenMaster(address _curationTokenMaster) external;
 function mint( bytes32 _subgraphDeploymentID, uint256 _tokensIn, uint256 _signalOutMin ) external returns (uint256, uint256);
 function burn( bytes32 _subgraphDeploymentID, uint256 _signalIn, uint256 _tokensOutMin ) external returns (uint256);
 function collect(bytes32 _subgraphDeploymentID, uint256 _tokens) external;
 function isCurated(bytes32 _subgraphDeploymentID) external view returns (bool);
 function getCuratorSignal(address _curator, bytes32 _subgraphDeploymentID) external view returns (uint256);
 function getCurationPoolSignal(bytes32 _subgraphDeploymentID) external view returns (uint256);
 function getCurationPoolTokens(bytes32 _subgraphDeploymentID) external view returns (uint256);
 function tokensToSignal(bytes32 _subgraphDeploymentID, uint256 _tokensIn) external view returns (uint256, uint256);
 function signalToTokens(bytes32 _subgraphDeploymentID, uint256 _signalIn) external view returns (uint256);
 function curationTaxPercentage() external view returns (uint32);
 }
 pragma solidity ^0.7.6;
 contract Managed {
 IController public controller;
 mapping(bytes32 => address) private addressCache;
 uint256[10] private __gap;
 event ParameterUpdated(string param);
 event SetController(address controller);
 event ContractSynced(bytes32 indexed nameHash, address contractAddress);
 function _notPartialPaused() internal view {
 require(!controller.paused(), "Paused");
 require(!controller.partialPaused(), "Partial-paused");
 }
 function _notPaused() internal view {
 require(!controller.paused(), "Paused");
 }
 function _onlyGovernor() internal view {
 require(msg.sender == controller.getGovernor(), "Caller must be Controller governor");
 }
 function _onlyController() internal view {
 require(msg.sender == address(controller), "Caller must be Controller");
 }
 modifier notPartialPaused() {
 _notPartialPaused();
 _;
 }
 modifier notPaused() {
 _notPaused();
 _;
 }
 modifier onlyController() {
 _onlyController();
 _;
 }
 modifier onlyGovernor() {
 _onlyGovernor();
 _;
 }
 function _initialize(address _controller) internal {
 _setController(_controller);
 }
 function setController(address _controller) external onlyController {
 _setController(_controller);
 }
 function _setController(address _controller) internal {
 require(_controller != address(0), "Controller must be set");
 controller = IController(_controller);
 emit SetController(_controller);
 }
 function curation() internal view returns (ICuration) {
 return ICuration(_resolveContract(keccak256("Curation")));
 }
 function epochManager() internal view returns (IEpochManager) {
 return IEpochManager(_resolveContract(keccak256("EpochManager")));
 }
 function rewardsManager() internal view returns (IRewardsManager) {
 return IRewardsManager(_resolveContract(keccak256("RewardsManager")));
 }
 function staking() internal view returns (IStaking) {
 return IStaking(_resolveContract(keccak256("Staking")));
 }
 function graphToken() internal view returns (IGraphToken) {
 return IGraphToken(_resolveContract(keccak256("GraphToken")));
 }
 function _resolveContract(bytes32 _nameHash) internal view returns (address) {
 address contractAddress = addressCache[_nameHash];
 if (contractAddress == address(0)) {
 contractAddress = controller.getContractProxy(_nameHash);
 }
 return contractAddress;
 }
 function _syncContract(string memory _name) internal {
 bytes32 nameHash = keccak256(abi.encodePacked(_name));
 address contractAddress = controller.getContractProxy(nameHash);
 if (addressCache[nameHash] != contractAddress) {
 addressCache[nameHash] = contractAddress;
 emit ContractSynced(nameHash, contractAddress);
 }
 }
 function syncAllContracts() external {
 _syncContract("Curation");
 _syncContract("EpochManager");
 _syncContract("RewardsManager");
 _syncContract("Staking");
 _syncContract("GraphToken");
 }
 }
 pragma solidity >=0.6.0 <0.8.0;
 abstract contract ContextUpgradeable is Initializable {
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
 pragma solidity ^0.7.6;
 contract GraphUpgradeable {
 bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 modifier onlyProxyAdmin(IGraphProxy _proxy) {
 require(msg.sender == _proxy.admin(), "Caller must be the proxy admin");
 _;
 }
 modifier onlyImpl() {
 require(msg.sender == _implementation(), "Caller must be the implementation");
 _;
 }
 function _implementation() internal view returns (address impl) {
 bytes32 slot = IMPLEMENTATION_SLOT;
 assembly {
 impl := sload(slot) }
 }
 function acceptProxy(IGraphProxy _proxy) external onlyProxyAdmin(_proxy) {
 _proxy.acceptUpgrade();
 }
 function acceptProxyAndCall(IGraphProxy _proxy, bytes calldata _data) external onlyProxyAdmin(_proxy) {
 _proxy.acceptUpgradeAndCall(_data);
 }
 }
 pragma solidity ^0.7.6;
 abstract contract CurationV1Storage is Managed, ICuration {
 struct CurationPool {
 uint256 tokens;
 uint32 reserveRatio;
 IGraphCurationToken gcs;
 }
 uint32 public override curationTaxPercentage;
 uint32 public defaultReserveRatio;
 address public curationTokenMaster;
 uint256 public minimumCurationDeposit;
 address public bondingCurve;
 mapping(bytes32 => CurationPool) public pools;
 }
 pragma solidity >=0.6.0 <0.8.0;
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
 pragma solidity >=0.6.12 <0.8.0;
 interface IStakingData {
 struct Allocation {
 address indexer;
 bytes32 subgraphDeploymentID;
 uint256 tokens;
 uint256 createdAtEpoch;
 uint256 closedAtEpoch;
 uint256 collectedFees;
 uint256 effectiveAllocation;
 uint256 accRewardsPerAllocatedToken;
 }
 struct CloseAllocationRequest {
 address allocationID;
 bytes32 poi;
 }
 struct DelegationPool {
 uint32 cooldownBlocks;
 uint32 indexingRewardCut;
 uint32 queryFeeCut;
 uint256 updatedAtBlock;
 uint256 tokens;
 uint256 shares;
 mapping(address => Delegation) delegators;
 }
 struct Delegation {
 uint256 shares;
 uint256 tokensLocked;
 uint256 tokensLockedUntil;
 }
 }
 pragma solidity >=0.6.0 <0.8.0;
 contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
 using SafeMathUpgradeable for uint256;
 mapping (address => uint256) private _balances;
 mapping (address => mapping (address => uint256)) private _allowances;
 uint256 private _totalSupply;
 string private _name;
 string private _symbol;
 uint8 private _decimals;
 function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
 __Context_init_unchained();
 __ERC20_init_unchained(name_, symbol_);
 }
 function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
 _name = name_;
 _symbol = symbol_;
 _decimals = 18;
 }
 function name() public view virtual returns (string memory) {
 return _name;
 }
 function symbol() public view virtual returns (string memory) {
 return _symbol;
 }
 function decimals() public view virtual returns (uint8) {
 return _decimals;
 }
 function totalSupply() public view virtual override returns (uint256) {
 return _totalSupply;
 }
 function balanceOf(address account) public view virtual override returns (uint256) {
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
 function _setupDecimals(uint8 decimals_) internal virtual {
 _decimals = decimals_;
 }
 function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
 }
 uint256[44] private __gap;
 }
 pragma solidity ^0.7.6;
 contract Governed {
 address public governor;
 address public pendingGovernor;
 event NewPendingOwnership(address indexed from, address indexed to);
 event NewOwnership(address indexed from, address indexed to);
 modifier onlyGovernor() {
 require(msg.sender == governor, "Only Governor can call");
 _;
 }
 function _initialize(address _initGovernor) internal {
 governor = _initGovernor;
 }
 function transferOwnership(address _newGovernor) external onlyGovernor {
 require(_newGovernor != address(0), "Governor must be set");
 address oldPendingGovernor = pendingGovernor;
 pendingGovernor = _newGovernor;
 emit NewPendingOwnership(oldPendingGovernor, pendingGovernor);
 }
 function acceptOwnership() external {
 require( pendingGovernor != address(0) && msg.sender == pendingGovernor, "Caller must be pending governor" );
 address oldGovernor = governor;
 address oldPendingGovernor = pendingGovernor;
 governor = pendingGovernor;
 pendingGovernor = address(0);
 emit NewOwnership(oldGovernor, governor);
 emit NewPendingOwnership(oldPendingGovernor, pendingGovernor);
 }
 }
 pragma solidity ^0.7.6;
 contract Curation is CurationV1Storage, GraphUpgradeable {
 using SafeMath for uint256;
 uint32 private constant MAX_PPM = 1000000;
 uint256 private constant SIGNAL_PER_MINIMUM_DEPOSIT = 1e18;
 event Signalled( address indexed curator, bytes32 indexed subgraphDeploymentID, uint256 tokens, uint256 signal, uint256 curationTax );
 event Burned( address indexed curator, bytes32 indexed subgraphDeploymentID, uint256 tokens, uint256 signal );
 event Collected(bytes32 indexed subgraphDeploymentID, uint256 tokens);
 function initialize( address _controller, address _bondingCurve, address _curationTokenMaster, uint32 _defaultReserveRatio, uint32 _curationTaxPercentage, uint256 _minimumCurationDeposit ) external onlyImpl {
 Managed._initialize(_controller);
 require(_bondingCurve != address(0), "Bonding curve must be set");
 bondingCurve = _bondingCurve;
 _setDefaultReserveRatio(_defaultReserveRatio);
 _setCurationTaxPercentage(_curationTaxPercentage);
 _setMinimumCurationDeposit(_minimumCurationDeposit);
 _setCurationTokenMaster(_curationTokenMaster);
 }
 function setDefaultReserveRatio(uint32 _defaultReserveRatio) external override onlyGovernor {
 _setDefaultReserveRatio(_defaultReserveRatio);
 }
 function _setDefaultReserveRatio(uint32 _defaultReserveRatio) private {
 require(_defaultReserveRatio > 0, "Default reserve ratio must be > 0");
 require( _defaultReserveRatio <= MAX_PPM, "Default reserve ratio cannot be higher than MAX_PPM" );
 defaultReserveRatio = _defaultReserveRatio;
 emit ParameterUpdated("defaultReserveRatio");
 }
 function setMinimumCurationDeposit(uint256 _minimumCurationDeposit) external override onlyGovernor {
 _setMinimumCurationDeposit(_minimumCurationDeposit);
 }
 function _setMinimumCurationDeposit(uint256 _minimumCurationDeposit) private {
 require(_minimumCurationDeposit > 0, "Minimum curation deposit cannot be 0");
 minimumCurationDeposit = _minimumCurationDeposit;
 emit ParameterUpdated("minimumCurationDeposit");
 }
 function setCurationTaxPercentage(uint32 _percentage) external override onlyGovernor {
 _setCurationTaxPercentage(_percentage);
 }
 function _setCurationTaxPercentage(uint32 _percentage) private {
 require( _percentage <= MAX_PPM, "Curation tax percentage must be below or equal to MAX_PPM" );
 curationTaxPercentage = _percentage;
 emit ParameterUpdated("curationTaxPercentage");
 }
 function setCurationTokenMaster(address _curationTokenMaster) external override onlyGovernor {
 _setCurationTokenMaster(_curationTokenMaster);
 }
 function _setCurationTokenMaster(address _curationTokenMaster) private {
 require(_curationTokenMaster != address(0), "Token master must be non-empty");
 require(Address.isContract(_curationTokenMaster), "Token master must be a contract");
 curationTokenMaster = _curationTokenMaster;
 emit ParameterUpdated("curationTokenMaster");
 }
 function collect(bytes32 _subgraphDeploymentID, uint256 _tokens) external override {
 require(msg.sender == address(staking()), "Caller must be the staking contract");
 require( isCurated(_subgraphDeploymentID), "Subgraph deployment must be curated to collect fees" );
 CurationPool storage curationPool = pools[_subgraphDeploymentID];
 curationPool.tokens = curationPool.tokens.add(_tokens);
 emit Collected(_subgraphDeploymentID, _tokens);
 }
 function mint( bytes32 _subgraphDeploymentID, uint256 _tokensIn, uint256 _signalOutMin ) external override notPartialPaused returns (uint256, uint256) {
 require(_tokensIn > 0, "Cannot deposit zero tokens");
 (uint256 signalOut, uint256 curationTax) = tokensToSignal(_subgraphDeploymentID, _tokensIn);
 require(signalOut >= _signalOutMin, "Slippage protection");
 address curator = msg.sender;
 CurationPool storage curationPool = pools[_subgraphDeploymentID];
 if (!isCurated(_subgraphDeploymentID)) {
 curationPool.reserveRatio = defaultReserveRatio;
 if (address(curationPool.gcs) == address(0)) {
 IGraphCurationToken gcs = IGraphCurationToken(Clones.clone(curationTokenMaster));
 gcs.initialize(address(this));
 curationPool.gcs = gcs;
 }
 }
 _updateRewards(_subgraphDeploymentID);
 IGraphToken _graphToken = graphToken();
 TokenUtils.pullTokens(_graphToken, curator, _tokensIn);
 TokenUtils.burnTokens(_graphToken, curationTax);
 curationPool.tokens = curationPool.tokens.add(_tokensIn.sub(curationTax));
 curationPool.gcs.mint(curator, signalOut);
 emit Signalled(curator, _subgraphDeploymentID, _tokensIn, signalOut, curationTax);
 return (signalOut, curationTax);
 }
 function burn( bytes32 _subgraphDeploymentID, uint256 _signalIn, uint256 _tokensOutMin ) external override notPartialPaused returns (uint256) {
 address curator = msg.sender;
 require(_signalIn > 0, "Cannot burn zero signal");
 require( getCuratorSignal(curator, _subgraphDeploymentID) >= _signalIn, "Cannot burn more signal than you own" );
 uint256 tokensOut = signalToTokens(_subgraphDeploymentID, _signalIn);
 require(tokensOut >= _tokensOutMin, "Slippage protection");
 _updateRewards(_subgraphDeploymentID);
 CurationPool storage curationPool = pools[_subgraphDeploymentID];
 curationPool.tokens = curationPool.tokens.sub(tokensOut);
 curationPool.gcs.burnFrom(curator, _signalIn);
 if (getCurationPoolSignal(_subgraphDeploymentID) == 0) {
 curationPool.tokens = 0;
 curationPool.reserveRatio = 0;
 }
 TokenUtils.pushTokens(graphToken(), curator, tokensOut);
 emit Burned(curator, _subgraphDeploymentID, tokensOut, _signalIn);
 return tokensOut;
 }
 function isCurated(bytes32 _subgraphDeploymentID) public view override returns (bool) {
 return pools[_subgraphDeploymentID].tokens > 0;
 }
 function getCuratorSignal(address _curator, bytes32 _subgraphDeploymentID) public view override returns (uint256) {
 IGraphCurationToken gcs = pools[_subgraphDeploymentID].gcs;
 return (address(gcs) == address(0)) ? 0 : gcs.balanceOf(_curator);
 }
 function getCurationPoolSignal(bytes32 _subgraphDeploymentID) public view override returns (uint256) {
 IGraphCurationToken gcs = pools[_subgraphDeploymentID].gcs;
 return (address(gcs) == address(0)) ? 0 : gcs.totalSupply();
 }
 function getCurationPoolTokens(bytes32 _subgraphDeploymentID) external view override returns (uint256) {
 return pools[_subgraphDeploymentID].tokens;
 }
 function tokensToSignal(bytes32 _subgraphDeploymentID, uint256 _tokensIn) public view override returns (uint256, uint256) {
 uint256 curationTax = _tokensIn.mul(uint256(curationTaxPercentage)).div(MAX_PPM);
 uint256 signalOut = _tokensToSignal(_subgraphDeploymentID, _tokensIn.sub(curationTax));
 return (signalOut, curationTax);
 }
 function _tokensToSignal(bytes32 _subgraphDeploymentID, uint256 _tokensIn) private view returns (uint256) {
 CurationPool memory curationPool = pools[_subgraphDeploymentID];
 if (curationPool.tokens == 0) {
 require( _tokensIn >= minimumCurationDeposit, "Curation deposit is below minimum required" );
 return BancorFormula(bondingCurve) .calculatePurchaseReturn( SIGNAL_PER_MINIMUM_DEPOSIT, minimumCurationDeposit, defaultReserveRatio, _tokensIn.sub(minimumCurationDeposit) ) .add(SIGNAL_PER_MINIMUM_DEPOSIT);
 }
 return BancorFormula(bondingCurve).calculatePurchaseReturn( getCurationPoolSignal(_subgraphDeploymentID), curationPool.tokens, curationPool.reserveRatio, _tokensIn );
 }
 function signalToTokens(bytes32 _subgraphDeploymentID, uint256 _signalIn) public view override returns (uint256) {
 CurationPool memory curationPool = pools[_subgraphDeploymentID];
 uint256 curationPoolSignal = getCurationPoolSignal(_subgraphDeploymentID);
 require( curationPool.tokens > 0, "Subgraph deployment must be curated to perform calculations" );
 require( curationPoolSignal >= _signalIn, "Signal must be above or equal to signal issued in the curation pool" );
 return BancorFormula(bondingCurve).calculateSaleReturn( curationPoolSignal, curationPool.tokens, curationPool.reserveRatio, _signalIn );
 }
 function _updateRewards(bytes32 _subgraphDeploymentID) private {
 IRewardsManager rewardsManager = rewardsManager();
 if (address(rewardsManager) != address(0)) {
 rewardsManager.onSubgraphSignalUpdate(_subgraphDeploymentID);
 }
 }
 }
 pragma solidity >=0.6.2 <0.8.0;
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
 function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionDelegateCall(target, data, "Address: low-level delegate call failed");
 }
 function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
 require(isContract(target), "Address: delegate call to non-contract");
 (bool success, bytes memory returndata) = target.delegatecall(data);
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
 pragma solidity >=0.6.0 <0.8.0;
 library SafeMath {
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
 pragma solidity >=0.6.0 <0.8.0;
 library Clones {
 function clone(address master) internal returns (address instance) {
 assembly {
 let ptr := mload(0x40) mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000) mstore(add(ptr, 0x14), shl(0x60, master)) mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000) instance := create(0, ptr, 0x37) }
 require(instance != address(0), "ERC1167: create failed");
 }
 function cloneDeterministic(address master, bytes32 salt) internal returns (address instance) {
 assembly {
 let ptr := mload(0x40) mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000) mstore(add(ptr, 0x14), shl(0x60, master)) mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000) instance := create2(0, ptr, 0x37, salt) }
 require(instance != address(0), "ERC1167: create2 failed");
 }
 function predictDeterministicAddress(address master, bytes32 salt, address deployer) internal pure returns (address predicted) {
 assembly {
 let ptr := mload(0x40) mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000) mstore(add(ptr, 0x14), shl(0x60, master)) mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000) mstore(add(ptr, 0x38), shl(0x60, deployer)) mstore(add(ptr, 0x4c), salt) mstore(add(ptr, 0x6c), keccak256(ptr, 0x37)) predicted := keccak256(add(ptr, 0x37), 0x55) }
 }
 function predictDeterministicAddress(address master, bytes32 salt) internal view returns (address predicted) {
 return predictDeterministicAddress(master, salt, address(this));
 }
 }
 pragma solidity ^0.7.6;
 contract BancorFormula {
 using SafeMath for uint256;
 uint16 public constant version = 6;
 uint256 private constant ONE = 1;
 uint32 private constant MAX_RATIO = 1000000;
 uint8 private constant MIN_PRECISION = 32;
 uint8 private constant MAX_PRECISION = 127;
 uint256 private constant FIXED_1 = 0x080000000000000000000000000000000;
 uint256 private constant FIXED_2 = 0x100000000000000000000000000000000;
 uint256 private constant MAX_NUM = 0x200000000000000000000000000000000;
 uint256 private constant LN2_NUMERATOR = 0x3f80fe03f80fe03f80fe03f80fe03f8;
 uint256 private constant LN2_DENOMINATOR = 0x5b9de1d10bf4103d647b0955897ba80;
 uint256 private constant OPT_LOG_MAX_VAL = 0x15bf0a8b1457695355fb8ac404e7a79e3;
 uint256 private constant OPT_EXP_MAX_VAL = 0x800000000000000000000000000000000;
 uint256[128] private maxExpArray;
 constructor() {
 maxExpArray[32] = 0x1c35fedd14ffffffffffffffffffffffff;
 maxExpArray[33] = 0x1b0ce43b323fffffffffffffffffffffff;
 maxExpArray[34] = 0x19f0028ec1ffffffffffffffffffffffff;
 maxExpArray[35] = 0x18ded91f0e7fffffffffffffffffffffff;
 maxExpArray[36] = 0x17d8ec7f0417ffffffffffffffffffffff;
 maxExpArray[37] = 0x16ddc6556cdbffffffffffffffffffffff;
 maxExpArray[38] = 0x15ecf52776a1ffffffffffffffffffffff;
 maxExpArray[39] = 0x15060c256cb2ffffffffffffffffffffff;
 maxExpArray[40] = 0x1428a2f98d72ffffffffffffffffffffff;
 maxExpArray[41] = 0x13545598e5c23fffffffffffffffffffff;
 maxExpArray[42] = 0x1288c4161ce1dfffffffffffffffffffff;
 maxExpArray[43] = 0x11c592761c666fffffffffffffffffffff;
 maxExpArray[44] = 0x110a688680a757ffffffffffffffffffff;
 maxExpArray[45] = 0x1056f1b5bedf77ffffffffffffffffffff;
 maxExpArray[46] = 0x0faadceceeff8bffffffffffffffffffff;
 maxExpArray[47] = 0x0f05dc6b27edadffffffffffffffffffff;
 maxExpArray[48] = 0x0e67a5a25da4107fffffffffffffffffff;
 maxExpArray[49] = 0x0dcff115b14eedffffffffffffffffffff;
 maxExpArray[50] = 0x0d3e7a392431239fffffffffffffffffff;
 maxExpArray[51] = 0x0cb2ff529eb71e4fffffffffffffffffff;
 maxExpArray[52] = 0x0c2d415c3db974afffffffffffffffffff;
 maxExpArray[53] = 0x0bad03e7d883f69bffffffffffffffffff;
 maxExpArray[54] = 0x0b320d03b2c343d5ffffffffffffffffff;
 maxExpArray[55] = 0x0abc25204e02828dffffffffffffffffff;
 maxExpArray[56] = 0x0a4b16f74ee4bb207fffffffffffffffff;
 maxExpArray[57] = 0x09deaf736ac1f569ffffffffffffffffff;
 maxExpArray[58] = 0x0976bd9952c7aa957fffffffffffffffff;
 maxExpArray[59] = 0x09131271922eaa606fffffffffffffffff;
 maxExpArray[60] = 0x08b380f3558668c46fffffffffffffffff;
 maxExpArray[61] = 0x0857ddf0117efa215bffffffffffffffff;
 maxExpArray[62] = 0x07ffffffffffffffffffffffffffffffff;
 maxExpArray[63] = 0x07abbf6f6abb9d087fffffffffffffffff;
 maxExpArray[64] = 0x075af62cbac95f7dfa7fffffffffffffff;
 maxExpArray[65] = 0x070d7fb7452e187ac13fffffffffffffff;
 maxExpArray[66] = 0x06c3390ecc8af379295fffffffffffffff;
 maxExpArray[67] = 0x067c00a3b07ffc01fd6fffffffffffffff;
 maxExpArray[68] = 0x0637b647c39cbb9d3d27ffffffffffffff;
 maxExpArray[69] = 0x05f63b1fc104dbd39587ffffffffffffff;
 maxExpArray[70] = 0x05b771955b36e12f7235ffffffffffffff;
 maxExpArray[71] = 0x057b3d49dda84556d6f6ffffffffffffff;
 maxExpArray[72] = 0x054183095b2c8ececf30ffffffffffffff;
 maxExpArray[73] = 0x050a28be635ca2b888f77fffffffffffff;
 maxExpArray[74] = 0x04d5156639708c9db33c3fffffffffffff;
 maxExpArray[75] = 0x04a23105873875bd52dfdfffffffffffff;
 maxExpArray[76] = 0x0471649d87199aa990756fffffffffffff;
 maxExpArray[77] = 0x04429a21a029d4c1457cfbffffffffffff;
 maxExpArray[78] = 0x0415bc6d6fb7dd71af2cb3ffffffffffff;
 maxExpArray[79] = 0x03eab73b3bbfe282243ce1ffffffffffff;
 maxExpArray[80] = 0x03c1771ac9fb6b4c18e229ffffffffffff;
 maxExpArray[81] = 0x0399e96897690418f785257fffffffffff;
 maxExpArray[82] = 0x0373fc456c53bb779bf0ea9fffffffffff;
 maxExpArray[83] = 0x034f9e8e490c48e67e6ab8bfffffffffff;
 maxExpArray[84] = 0x032cbfd4a7adc790560b3337ffffffffff;
 maxExpArray[85] = 0x030b50570f6e5d2acca94613ffffffffff;
 maxExpArray[86] = 0x02eb40f9f620fda6b56c2861ffffffffff;
 maxExpArray[87] = 0x02cc8340ecb0d0f520a6af58ffffffffff;
 maxExpArray[88] = 0x02af09481380a0a35cf1ba02ffffffffff;
 maxExpArray[89] = 0x0292c5bdd3b92ec810287b1b3fffffffff;
 maxExpArray[90] = 0x0277abdcdab07d5a77ac6d6b9fffffffff;
 maxExpArray[91] = 0x025daf6654b1eaa55fd64df5efffffffff;
 maxExpArray[92] = 0x0244c49c648baa98192dce88b7ffffffff;
 maxExpArray[93] = 0x022ce03cd5619a311b2471268bffffffff;
 maxExpArray[94] = 0x0215f77c045fbe885654a44a0fffffffff;
 maxExpArray[95] = 0x01ffffffffffffffffffffffffffffffff;
 maxExpArray[96] = 0x01eaefdbdaaee7421fc4d3ede5ffffffff;
 maxExpArray[97] = 0x01d6bd8b2eb257df7e8ca57b09bfffffff;
 maxExpArray[98] = 0x01c35fedd14b861eb0443f7f133fffffff;
 maxExpArray[99] = 0x01b0ce43b322bcde4a56e8ada5afffffff;
 maxExpArray[100] = 0x019f0028ec1fff007f5a195a39dfffffff;
 maxExpArray[101] = 0x018ded91f0e72ee74f49b15ba527ffffff;
 maxExpArray[102] = 0x017d8ec7f04136f4e5615fd41a63ffffff;
 maxExpArray[103] = 0x016ddc6556cdb84bdc8d12d22e6fffffff;
 maxExpArray[104] = 0x015ecf52776a1155b5bd8395814f7fffff;
 maxExpArray[105] = 0x015060c256cb23b3b3cc3754cf40ffffff;
 maxExpArray[106] = 0x01428a2f98d728ae223ddab715be3fffff;
 maxExpArray[107] = 0x013545598e5c23276ccf0ede68034fffff;
 maxExpArray[108] = 0x01288c4161ce1d6f54b7f61081194fffff;
 maxExpArray[109] = 0x011c592761c666aa641d5a01a40f17ffff;
 maxExpArray[110] = 0x0110a688680a7530515f3e6e6cfdcdffff;
 maxExpArray[111] = 0x01056f1b5bedf75c6bcb2ce8aed428ffff;
 maxExpArray[112] = 0x00faadceceeff8a0890f3875f008277fff;
 maxExpArray[113] = 0x00f05dc6b27edad306388a600f6ba0bfff;
 maxExpArray[114] = 0x00e67a5a25da41063de1495d5b18cdbfff;
 maxExpArray[115] = 0x00dcff115b14eedde6fc3aa5353f2e4fff;
 maxExpArray[116] = 0x00d3e7a3924312399f9aae2e0f868f8fff;
 maxExpArray[117] = 0x00cb2ff529eb71e41582cccd5a1ee26fff;
 maxExpArray[118] = 0x00c2d415c3db974ab32a51840c0b67edff;
 maxExpArray[119] = 0x00bad03e7d883f69ad5b0a186184e06bff;
 maxExpArray[120] = 0x00b320d03b2c343d4829abd6075f0cc5ff;
 maxExpArray[121] = 0x00abc25204e02828d73c6e80bcdb1a95bf;
 maxExpArray[122] = 0x00a4b16f74ee4bb2040a1ec6c15fbbf2df;
 maxExpArray[123] = 0x009deaf736ac1f569deb1b5ae3f36c130f;
 maxExpArray[124] = 0x00976bd9952c7aa957f5937d790ef65037;
 maxExpArray[125] = 0x009131271922eaa6064b73a22d0bd4f2bf;
 maxExpArray[126] = 0x008b380f3558668c46c91c49a2f8e967b9;
 maxExpArray[127] = 0x00857ddf0117efa215952912839f6473e6;
 }
 function calculatePurchaseReturn( uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount ) public view returns (uint256) {
 require( _supply > 0 && _reserveBalance > 0 && _reserveRatio > 0 && _reserveRatio <= MAX_RATIO, "invalid parameters" );
 if (_depositAmount == 0) return 0;
 if (_reserveRatio == MAX_RATIO) return _supply.mul(_depositAmount) / _reserveBalance;
 uint256 result;
 uint8 precision;
 uint256 baseN = _depositAmount.add(_reserveBalance);
 (result, precision) = power(baseN, _reserveBalance, _reserveRatio, MAX_RATIO);
 uint256 temp = _supply.mul(result) >> precision;
 return temp - _supply;
 }
 function calculateSaleReturn( uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount ) public view returns (uint256) {
 require( _supply > 0 && _reserveBalance > 0 && _reserveRatio > 0 && _reserveRatio <= MAX_RATIO && _sellAmount <= _supply, "invalid parameters" );
 if (_sellAmount == 0) return 0;
 if (_sellAmount == _supply) return _reserveBalance;
 if (_reserveRatio == MAX_RATIO) return _reserveBalance.mul(_sellAmount) / _supply;
 uint256 result;
 uint8 precision;
 uint256 baseD = _supply - _sellAmount;
 (result, precision) = power(_supply, baseD, MAX_RATIO, _reserveRatio);
 uint256 temp1 = _reserveBalance.mul(result);
 uint256 temp2 = _reserveBalance << precision;
 return (temp1 - temp2) / result;
 }
 function calculateCrossReserveReturn( uint256 _fromReserveBalance, uint32 _fromReserveRatio, uint256 _toReserveBalance, uint32 _toReserveRatio, uint256 _amount ) public view returns (uint256) {
 require( _fromReserveBalance > 0 && _fromReserveRatio > 0 && _fromReserveRatio <= MAX_RATIO && _toReserveBalance > 0 && _toReserveRatio > 0 && _toReserveRatio <= MAX_RATIO );
 if (_fromReserveRatio == _toReserveRatio) return _toReserveBalance.mul(_amount) / _fromReserveBalance.add(_amount);
 uint256 result;
 uint8 precision;
 uint256 baseN = _fromReserveBalance.add(_amount);
 (result, precision) = power(baseN, _fromReserveBalance, _fromReserveRatio, _toReserveRatio);
 uint256 temp1 = _toReserveBalance.mul(result);
 uint256 temp2 = _toReserveBalance << precision;
 return (temp1 - temp2) / result;
 }
 function calculateFundCost( uint256 _supply, uint256 _reserveBalance, uint32 _totalRatio, uint256 _amount ) public view returns (uint256) {
 require( _supply > 0 && _reserveBalance > 0 && _totalRatio > 1 && _totalRatio <= MAX_RATIO * 2 );
 if (_amount == 0) return 0;
 if (_totalRatio == MAX_RATIO) return (_amount.mul(_reserveBalance) - 1) / _supply + 1;
 uint256 result;
 uint8 precision;
 uint256 baseN = _supply.add(_amount);
 (result, precision) = power(baseN, _supply, MAX_RATIO, _totalRatio);
 uint256 temp = ((_reserveBalance.mul(result) - 1) >> precision) + 1;
 return temp - _reserveBalance;
 }
 function calculateLiquidateReturn( uint256 _supply, uint256 _reserveBalance, uint32 _totalRatio, uint256 _amount ) public view returns (uint256) {
 require( _supply > 0 && _reserveBalance > 0 && _totalRatio > 1 && _totalRatio <= MAX_RATIO * 2 && _amount <= _supply );
 if (_amount == 0) return 0;
 if (_amount == _supply) return _reserveBalance;
 if (_totalRatio == MAX_RATIO) return _amount.mul(_reserveBalance) / _supply;
 uint256 result;
 uint8 precision;
 uint256 baseD = _supply - _amount;
 (result, precision) = power(_supply, baseD, MAX_RATIO, _totalRatio);
 uint256 temp1 = _reserveBalance.mul(result);
 uint256 temp2 = _reserveBalance << precision;
 return (temp1 - temp2) / result;
 }
 function power( uint256 _baseN, uint256 _baseD, uint32 _expN, uint32 _expD ) internal view returns (uint256, uint8) {
 require(_baseN < MAX_NUM);
 uint256 baseLog;
 uint256 base = (_baseN * FIXED_1) / _baseD;
 if (base < OPT_LOG_MAX_VAL) {
 baseLog = optimalLog(base);
 }
 else {
 baseLog = generalLog(base);
 }
 uint256 baseLogTimesExp = (baseLog * _expN) / _expD;
 if (baseLogTimesExp < OPT_EXP_MAX_VAL) {
 return (optimalExp(baseLogTimesExp), MAX_PRECISION);
 }
 else {
 uint8 precision = findPositionInMaxExpArray(baseLogTimesExp);
 return ( generalExp(baseLogTimesExp >> (MAX_PRECISION - precision), precision), precision );
 }
 }
 function generalLog(uint256 x) internal pure returns (uint256) {
 uint256 res = 0;
 if (x >= FIXED_2) {
 uint8 count = floorLog2(x / FIXED_1);
 x >>= count;
 res = count * FIXED_1;
 }
 if (x > FIXED_1) {
 for (uint8 i = MAX_PRECISION; i > 0; --i) {
 x = (x * x) / FIXED_1;
 if (x >= FIXED_2) {
 x >>= 1;
 res += ONE << (i - 1);
 }
 }
 }
 return (res * LN2_NUMERATOR) / LN2_DENOMINATOR;
 }
 function floorLog2(uint256 _n) internal pure returns (uint8) {
 uint8 res = 0;
 if (_n < 256) {
 while (_n > 1) {
 _n >>= 1;
 res += 1;
 }
 }
 else {
 for (uint8 s = 128; s > 0; s >>= 1) {
 if (_n >= (ONE << s)) {
 _n >>= s;
 res |= s;
 }
 }
 }
 return res;
 }
 function findPositionInMaxExpArray(uint256 _x) internal view returns (uint8) {
 uint8 lo = MIN_PRECISION;
 uint8 hi = MAX_PRECISION;
 while (lo + 1 < hi) {
 uint8 mid = (lo + hi) / 2;
 if (maxExpArray[mid] >= _x) lo = mid;
 else hi = mid;
 }
 if (maxExpArray[hi] >= _x) return hi;
 if (maxExpArray[lo] >= _x) return lo;
 require(false);
 return 0;
 }
 function generalExp(uint256 _x, uint8 _precision) internal pure returns (uint256) {
 uint256 xi = _x;
 uint256 res = 0;
 xi = (xi * _x) >> _precision;
 res += xi * 0x3442c4e6074a82f1797f72ac0000000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x116b96f757c380fb287fd0e40000000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x045ae5bdd5f0e03eca1ff4390000000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00defabf91302cd95b9ffda50000000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x002529ca9832b22439efff9b8000000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00054f1cf12bd04e516b6da88000000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000a9e39e257a09ca2d6db51000000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x000012e066e7b839fa050c309000000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x000001e33d7d926c329a1ad1a800000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000002bee513bdb4a6b19b5f800000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00000003a9316fa79b88eccf2a00000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000048177ebe1fa812375200000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000005263fe90242dcbacf00000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x000000000057e22099c030d94100000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000000057e22099c030d9410000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00000000000052b6b54569976310000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00000000000004985f67696bf748000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x000000000000003dea12ea99e498000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00000000000000031880f2214b6e000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x000000000000000025bcff56eb36000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x000000000000000001b722e10ab1000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000000000000001317c70077000;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00000000000000000000cba84aafa00;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00000000000000000000082573a0a00;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00000000000000000000005035ad900;
 xi = (xi * _x) >> _precision;
 res += xi * 0x000000000000000000000002f881b00;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000000000000000000001b29340;
 xi = (xi * _x) >> _precision;
 res += xi * 0x00000000000000000000000000efc40;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000000000000000000000007fe0;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000000000000000000000000420;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000000000000000000000000021;
 xi = (xi * _x) >> _precision;
 res += xi * 0x0000000000000000000000000000001;
 return res / 0x688589cc0e9505e2f2fee5580000000 + _x + (ONE << _precision);
 }
 function optimalLog(uint256 x) internal pure returns (uint256) {
 uint256 res = 0;
 uint256 y;
 uint256 z;
 uint256 w;
 if (x >= 0xd3094c70f034de4b96ff7d5b6f99fcd8) {
 res += 0x40000000000000000000000000000000;
 x = (x * FIXED_1) / 0xd3094c70f034de4b96ff7d5b6f99fcd8;
 }
 if (x >= 0xa45af1e1f40c333b3de1db4dd55f29a7) {
 res += 0x20000000000000000000000000000000;
 x = (x * FIXED_1) / 0xa45af1e1f40c333b3de1db4dd55f29a7;
 }
 if (x >= 0x910b022db7ae67ce76b441c27035c6a1) {
 res += 0x10000000000000000000000000000000;
 x = (x * FIXED_1) / 0x910b022db7ae67ce76b441c27035c6a1;
 }
 if (x >= 0x88415abbe9a76bead8d00cf112e4d4a8) {
 res += 0x08000000000000000000000000000000;
 x = (x * FIXED_1) / 0x88415abbe9a76bead8d00cf112e4d4a8;
 }
 if (x >= 0x84102b00893f64c705e841d5d4064bd3) {
 res += 0x04000000000000000000000000000000;
 x = (x * FIXED_1) / 0x84102b00893f64c705e841d5d4064bd3;
 }
 if (x >= 0x8204055aaef1c8bd5c3259f4822735a2) {
 res += 0x02000000000000000000000000000000;
 x = (x * FIXED_1) / 0x8204055aaef1c8bd5c3259f4822735a2;
 }
 if (x >= 0x810100ab00222d861931c15e39b44e99) {
 res += 0x01000000000000000000000000000000;
 x = (x * FIXED_1) / 0x810100ab00222d861931c15e39b44e99;
 }
 if (x >= 0x808040155aabbbe9451521693554f733) {
 res += 0x00800000000000000000000000000000;
 x = (x * FIXED_1) / 0x808040155aabbbe9451521693554f733;
 }
 z = y = x - FIXED_1;
 w = (y * y) / FIXED_1;
 res += (z * (0x100000000000000000000000000000000 - y)) / 0x100000000000000000000000000000000;
 z = (z * w) / FIXED_1;
 res += (z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y)) / 0x200000000000000000000000000000000;
 z = (z * w) / FIXED_1;
 res += (z * (0x099999999999999999999999999999999 - y)) / 0x300000000000000000000000000000000;
 z = (z * w) / FIXED_1;
 res += (z * (0x092492492492492492492492492492492 - y)) / 0x400000000000000000000000000000000;
 z = (z * w) / FIXED_1;
 res += (z * (0x08e38e38e38e38e38e38e38e38e38e38e - y)) / 0x500000000000000000000000000000000;
 z = (z * w) / FIXED_1;
 res += (z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b - y)) / 0x600000000000000000000000000000000;
 z = (z * w) / FIXED_1;
 res += (z * (0x089d89d89d89d89d89d89d89d89d89d89 - y)) / 0x700000000000000000000000000000000;
 z = (z * w) / FIXED_1;
 res += (z * (0x088888888888888888888888888888888 - y)) / 0x800000000000000000000000000000000;
 return res;
 }
 function optimalExp(uint256 x) internal pure returns (uint256) {
 uint256 res = 0;
 uint256 y;
 uint256 z;
 z = y = x % 0x10000000000000000000000000000000;
 z = (z * y) / FIXED_1;
 res += z * 0x10e1b3be415a0000;
 z = (z * y) / FIXED_1;
 res += z * 0x05a0913f6b1e0000;
 z = (z * y) / FIXED_1;
 res += z * 0x0168244fdac78000;
 z = (z * y) / FIXED_1;
 res += z * 0x004807432bc18000;
 z = (z * y) / FIXED_1;
 res += z * 0x000c0135dca04000;
 z = (z * y) / FIXED_1;
 res += z * 0x0001b707b1cdc000;
 z = (z * y) / FIXED_1;
 res += z * 0x000036e0f639b800;
 z = (z * y) / FIXED_1;
 res += z * 0x00000618fee9f800;
 z = (z * y) / FIXED_1;
 res += z * 0x0000009c197dcc00;
 z = (z * y) / FIXED_1;
 res += z * 0x0000000e30dce400;
 z = (z * y) / FIXED_1;
 res += z * 0x000000012ebd1300;
 z = (z * y) / FIXED_1;
 res += z * 0x0000000017499f00;
 z = (z * y) / FIXED_1;
 res += z * 0x0000000001a9d480;
 z = (z * y) / FIXED_1;
 res += z * 0x00000000001c6380;
 z = (z * y) / FIXED_1;
 res += z * 0x000000000001c638;
 z = (z * y) / FIXED_1;
 res += z * 0x0000000000001ab8;
 z = (z * y) / FIXED_1;
 res += z * 0x000000000000017c;
 z = (z * y) / FIXED_1;
 res += z * 0x0000000000000014;
 z = (z * y) / FIXED_1;
 res += z * 0x0000000000000001;
 res = res / 0x21c3677c82b40000 + y + FIXED_1;
 if ((x & 0x010000000000000000000000000000000) != 0) res = (res * 0x1c3d6a24ed82218787d624d3e5eba95f9) / 0x18ebef9eac820ae8682b9793ac6d1e776;
 if ((x & 0x020000000000000000000000000000000) != 0) res = (res * 0x18ebef9eac820ae8682b9793ac6d1e778) / 0x1368b2fc6f9609fe7aceb46aa619baed4;
 if ((x & 0x040000000000000000000000000000000) != 0) res = (res * 0x1368b2fc6f9609fe7aceb46aa619baed5) / 0x0bc5ab1b16779be3575bd8f0520a9f21f;
 if ((x & 0x080000000000000000000000000000000) != 0) res = (res * 0x0bc5ab1b16779be3575bd8f0520a9f21e) / 0x0454aaa8efe072e7f6ddbab84b40a55c9;
 if ((x & 0x100000000000000000000000000000000) != 0) res = (res * 0x0454aaa8efe072e7f6ddbab84b40a55c5) / 0x00960aadc109e7a3bf4578099615711ea;
 if ((x & 0x200000000000000000000000000000000) != 0) res = (res * 0x00960aadc109e7a3bf4578099615711d7) / 0x0002bf84208204f5977f9a8cf01fdce3d;
 if ((x & 0x400000000000000000000000000000000) != 0) res = (res * 0x0002bf84208204f5977f9a8cf01fdc307) / 0x0000003c6ab775dd0b95b4cbee7e65d11;
 return res;
 }
 function calculateCrossConnectorReturn( uint256 _fromConnectorBalance, uint32 _fromConnectorWeight, uint256 _toConnectorBalance, uint32 _toConnectorWeight, uint256 _amount ) public view returns (uint256) {
 return calculateCrossReserveReturn( _fromConnectorBalance, _fromConnectorWeight, _toConnectorBalance, _toConnectorWeight, _amount );
 }
 }
 pragma solidity ^0.7.6;
 library TokenUtils {
 function pullTokens( IGraphToken _graphToken, address _from, uint256 _amount ) internal {
 if (_amount > 0) {
 require(_graphToken.transferFrom(_from, address(this), _amount), "!transfer");
 }
 }
 function pushTokens( IGraphToken _graphToken, address _to, uint256 _amount ) internal {
 if (_amount > 0) {
 require(_graphToken.transfer(_to, _amount), "!transfer");
 }
 }
 function burnTokens(IGraphToken _graphToken, uint256 _amount) internal {
 if (_amount > 0) {
 _graphToken.burn(_amount);
 }
 }
 }
 pragma solidity ^0.7.6;
 contract GraphCurationToken is ERC20Upgradeable, Governed {
 function initialize(address _owner) external initializer {
 Governed._initialize(_owner);
 ERC20Upgradeable.__ERC20_init("Graph Curation Share", "GCS");
 }
 function mint(address _to, uint256 _amount) public onlyGovernor {
 _mint(_to, _amount);
 }
 function burnFrom(address _account, uint256 _amount) public onlyGovernor {
 _burn(_account, _amount);
 }
 }
 pragma solidity ^0.7.6;
 interface IGraphProxy {
 function admin() external returns (address);
 function setAdmin(address _newAdmin) external;
 function implementation() external returns (address);
 function pendingImplementation() external returns (address);
 function upgradeTo(address _newImplementation) external;
 function acceptUpgrade() external;
 function acceptUpgradeAndCall(bytes calldata data) external;
 }
 pragma solidity ^0.7.6;
 interface IGraphToken is IERC20 {
 function burn(uint256 amount) external;
 function mint(address _to, uint256 _amount) external;
 function addMinter(address _account) external;
 function removeMinter(address _account) external;
 function renounceMinter() external;
 function isMinter(address _account) external view returns (bool);
 function permit( address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s ) external;
 }
 pragma solidity >=0.6.12 <0.8.0;
 interface IController {
 function getGovernor() external view returns (address);
 function setContractProxy(bytes32 _id, address _contractAddress) external;
 function unsetContractProxy(bytes32 _id) external;
 function updateController(bytes32 _id, address _controller) external;
 function getContractProxy(bytes32 _id) external view returns (address);
 function setPartialPaused(bool _partialPaused) external;
 function setPaused(bool _paused) external;
 function setPauseGuardian(address _newPauseGuardian) external;
 function paused() external view returns (bool);
 function partialPaused() external view returns (bool);
 }
 pragma solidity ^0.7.6;
 interface IEpochManager {
 function setEpochLength(uint256 _epochLength) external;
 function runEpoch() external;
 function isCurrentEpochRun() external view returns (bool);
 function blockNum() external view returns (uint256);
 function blockHash(uint256 _block) external view returns (bytes32);
 function currentEpoch() external view returns (uint256);
 function currentEpochBlock() external view returns (uint256);
 function currentEpochBlockSinceStart() external view returns (uint256);
 function epochsSince(uint256 _epoch) external view returns (uint256);
 function epochsSinceUpdate() external view returns (uint256);
 }
 pragma solidity ^0.7.6;
 interface IRewardsManager {
 struct Subgraph {
 uint256 accRewardsForSubgraph;
 uint256 accRewardsForSubgraphSnapshot;
 uint256 accRewardsPerSignalSnapshot;
 uint256 accRewardsPerAllocatedToken;
 }
 function setIssuanceRate(uint256 _issuanceRate) external;
 function setSubgraphAvailabilityOracle(address _subgraphAvailabilityOracle) external;
 function setDenied(bytes32 _subgraphDeploymentID, bool _deny) external;
 function setDeniedMany(bytes32[] calldata _subgraphDeploymentID, bool[] calldata _deny) external;
 function isDenied(bytes32 _subgraphDeploymentID) external view returns (bool);
 function getNewRewardsPerSignal() external view returns (uint256);
 function getAccRewardsPerSignal() external view returns (uint256);
 function getAccRewardsForSubgraph(bytes32 _subgraphDeploymentID) external view returns (uint256);
 function getAccRewardsPerAllocatedToken(bytes32 _subgraphDeploymentID) external view returns (uint256, uint256);
 function getRewards(address _allocationID) external view returns (uint256);
 function updateAccRewardsPerSignal() external returns (uint256);
 function takeRewards(address _allocationID) external returns (uint256);
 function onSubgraphSignalUpdate(bytes32 _subgraphDeploymentID) external returns (uint256);
 function onSubgraphAllocationUpdate(bytes32 _subgraphDeploymentID) external returns (uint256);
 }
 pragma solidity >=0.6.12 <0.8.0;
 interface IStaking is IStakingData {
 enum AllocationState {
 Null, Active, Closed, Finalized, Claimed }
 function setMinimumIndexerStake(uint256 _minimumIndexerStake) external;
 function setThawingPeriod(uint32 _thawingPeriod) external;
 function setCurationPercentage(uint32 _percentage) external;
 function setProtocolPercentage(uint32 _percentage) external;
 function setChannelDisputeEpochs(uint32 _channelDisputeEpochs) external;
 function setMaxAllocationEpochs(uint32 _maxAllocationEpochs) external;
 function setRebateRatio(uint32 _alphaNumerator, uint32 _alphaDenominator) external;
 function setDelegationRatio(uint32 _delegationRatio) external;
 function setDelegationParameters( uint32 _indexingRewardCut, uint32 _queryFeeCut, uint32 _cooldownBlocks ) external;
 function setDelegationParametersCooldown(uint32 _blocks) external;
 function setDelegationUnbondingPeriod(uint32 _delegationUnbondingPeriod) external;
 function setDelegationTaxPercentage(uint32 _percentage) external;
 function setSlasher(address _slasher, bool _allowed) external;
 function setAssetHolder(address _assetHolder, bool _allowed) external;
 function setOperator(address _operator, bool _allowed) external;
 function isOperator(address _operator, address _indexer) external view returns (bool);
 function stake(uint256 _tokens) external;
 function stakeTo(address _indexer, uint256 _tokens) external;
 function unstake(uint256 _tokens) external;
 function slash( address _indexer, uint256 _tokens, uint256 _reward, address _beneficiary ) external;
 function withdraw() external;
 function setRewardsDestination(address _destination) external;
 function delegate(address _indexer, uint256 _tokens) external returns (uint256);
 function undelegate(address _indexer, uint256 _shares) external returns (uint256);
 function withdrawDelegated(address _indexer, address _newIndexer) external returns (uint256);
 function allocate( bytes32 _subgraphDeploymentID, uint256 _tokens, address _allocationID, bytes32 _metadata, bytes calldata _proof ) external;
 function allocateFrom( address _indexer, bytes32 _subgraphDeploymentID, uint256 _tokens, address _allocationID, bytes32 _metadata, bytes calldata _proof ) external;
 function closeAllocation(address _allocationID, bytes32 _poi) external;
 function closeAllocationMany(CloseAllocationRequest[] calldata _requests) external;
 function closeAndAllocate( address _oldAllocationID, bytes32 _poi, address _indexer, bytes32 _subgraphDeploymentID, uint256 _tokens, address _allocationID, bytes32 _metadata, bytes calldata _proof ) external;
 function collect(uint256 _tokens, address _allocationID) external;
 function claim(address _allocationID, bool _restake) external;
 function claimMany(address[] calldata _allocationID, bool _restake) external;
 function hasStake(address _indexer) external view returns (bool);
 function getIndexerStakedTokens(address _indexer) external view returns (uint256);
 function getIndexerCapacity(address _indexer) external view returns (uint256);
 function getAllocation(address _allocationID) external view returns (Allocation memory);
 function getAllocationState(address _allocationID) external view returns (AllocationState);
 function isAllocation(address _allocationID) external view returns (bool);
 function getSubgraphAllocatedTokens(bytes32 _subgraphDeploymentID) external view returns (uint256);
 function getDelegation(address _indexer, address _delegator) external view returns (Delegation memory);
 function isDelegator(address _indexer, address _delegator) external view returns (bool);
 }
 pragma solidity ^0.7.6;
 interface IGraphCurationToken is IERC20Upgradeable {
 function initialize(address _owner) external;
 function burnFrom(address _account, uint256 _amount) external;
 function mint(address _to, uint256 _amount) external;
 }
 pragma solidity >=0.6.0 <0.8.0;
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
 pragma solidity >=0.6.2 <0.8.0;
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
