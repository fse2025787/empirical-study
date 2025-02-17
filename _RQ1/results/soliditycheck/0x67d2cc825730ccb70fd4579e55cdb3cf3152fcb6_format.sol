  pragma experimental ABIEncoderV2;
 pragma solidity =0.7.6;
 abstract contract IComptroller {
 struct CompMarketState {
 uint224 index;
 uint32 block;
 }
 function claimComp(address holder) public virtual;
 function claimComp(address holder, address[] memory cTokens) public virtual;
 function claimComp(address[] memory holders, address[] memory cTokens, bool borrowers, bool suppliers) public virtual;
 function compSupplyState(address) public view virtual returns (CompMarketState memory);
 function compSupplierIndex(address,address) public view virtual returns (uint);
 function compAccrued(address) public view virtual returns (uint);
 function compBorrowState(address) public view virtual returns (CompMarketState memory);
 function compBorrowerIndex(address,address) public view virtual returns (uint);
 function enterMarkets(address[] calldata cTokens) external virtual returns (uint256[] memory);
 function exitMarket(address cToken) external virtual returns (uint256);
 function getAssetsIn(address account) external virtual view returns (address[] memory);
 function markets(address account) public virtual view returns (bool, uint256);
 function getAccountLiquidity(address account) external virtual view returns (uint256, uint256, uint256);
 function oracle() public virtual view returns (address);
 }
 interface IERC20 {
 function totalSupply() external view returns (uint256 supply);
 function balanceOf(address _owner) external view returns (uint256 balance);
 function transfer(address _to, uint256 _value) external returns (bool success);
 function transferFrom( address _from, address _to, uint256 _value ) external returns (bool success);
 function approve(address _spender, uint256 _value) external returns (bool success);
 function allowance(address _owner, address _spender) external view returns (uint256 remaining);
 function decimals() external view returns (uint256 digits);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 }
 abstract contract ICToken is IERC20 {
 function mint(uint256 mintAmount) external virtual returns (uint256);
 function mint() external virtual payable;
 function accrueInterest() public virtual returns (uint);
 function redeem(uint256 redeemTokens) external virtual returns (uint256);
 function redeemUnderlying(uint256 redeemAmount) external virtual returns (uint256);
 function borrow(uint256 borrowAmount) external virtual returns (uint256);
 function borrowIndex() public view virtual returns (uint);
 function borrowBalanceStored(address) public view virtual returns(uint);
 function repayBorrow(uint256 repayAmount) external virtual returns (uint256);
 function repayBorrow() external virtual payable;
 function repayBorrowBehalf(address borrower, uint256 repayAmount) external virtual returns (uint256);
 function repayBorrowBehalf(address borrower) external virtual payable;
 function liquidateBorrow(address borrower, uint256 repayAmount, address cTokenCollateral) external virtual returns (uint256);
 function liquidateBorrow(address borrower, address cTokenCollateral) external virtual payable;
 function exchangeRateCurrent() external virtual returns (uint256);
 function supplyRatePerBlock() external virtual returns (uint256);
 function borrowRatePerBlock() external virtual returns (uint256);
 function totalReserves() external virtual returns (uint256);
 function reserveFactorMantissa() external virtual returns (uint256);
 function borrowBalanceCurrent(address account) external virtual returns (uint256);
 function totalBorrowsCurrent() external virtual returns (uint256);
 function getCash() external virtual returns (uint256);
 function balanceOfUnderlying(address owner) external virtual returns (uint256);
 function underlying() external virtual returns (address);
 function getAccountSnapshot(address account) external virtual view returns (uint, uint, uint, uint);
 }
 abstract contract IWETH {
 function allowance(address, address) public virtual view returns (uint256);
 function balanceOf(address) public virtual view returns (uint256);
 function approve(address, uint256) public virtual;
 function transfer(address, uint256) public virtual returns (bool);
 function transferFrom( address, address, uint256 ) public virtual returns (bool);
 function deposit() public payable virtual;
 function withdraw(uint256) public virtual;
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
 value: amount}
 ("");
 require(success, "Address: unable to send value, recipient may have reverted");
 }
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, "Address: low-level call failed");
 }
 function functionCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 return _functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value ) internal returns (bytes memory) {
 return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value, string memory errorMessage ) internal returns (bytes memory) {
 require(address(this).balance >= value, "Address: insufficient balance for call");
 return _functionCallWithValue(target, data, value, errorMessage);
 }
 function _functionCallWithValue( address target, bytes memory data, uint256 weiValue, string memory errorMessage ) private returns (bytes memory) {
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
 value: weiValue}
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
 library SafeMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 return sub(a, b, "SafeMath: subtraction overflow");
 }
 function sub( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
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
 function div( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 uint256 c = a / b;
 return c;
 }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 return mod(a, b, "SafeMath: modulo by zero");
 }
 function mod( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 require(b != 0, errorMessage);
 return a % b;
 }
 }
 library SafeERC20 {
 using SafeMath for uint256;
 using Address for address;
 function safeTransfer( IERC20 token, address to, uint256 value ) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
 }
 function safeTransferFrom( IERC20 token, address from, address to, uint256 value ) internal {
 _callOptionalReturn( token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value) );
 }
 function safeApprove( IERC20 token, address spender, uint256 value ) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
 }
 function safeIncreaseAllowance( IERC20 token, address spender, uint256 value ) internal {
 uint256 newAllowance = token.allowance(address(this), spender).add(value);
 _callOptionalReturn( token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance) );
 }
 function safeDecreaseAllowance( IERC20 token, address spender, uint256 value ) internal {
 uint256 newAllowance = token.allowance(address(this), spender).sub( value, "SafeERC20: decreased allowance below zero" );
 _callOptionalReturn( token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance) );
 }
 function _callOptionalReturn(IERC20 token, bytes memory data) private {
 bytes memory returndata = address(token).functionCall( data, "SafeERC20: low-level call failed" );
 if (returndata.length > 0) {
 require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
 }
 }
 }
 library TokenUtils {
 using SafeERC20 for IERC20;
 address public constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
 address public constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
 function approveToken( address _tokenAddr, address _to, uint256 _amount ) internal {
 if (_tokenAddr == ETH_ADDR) return;
 if (IERC20(_tokenAddr).allowance(address(this), _to) < _amount) {
 IERC20(_tokenAddr).safeApprove(_to, _amount);
 }
 }
 function pullTokensIfNeeded( address _token, address _from, uint256 _amount ) internal returns (uint256) {
 if (_amount == type(uint256).max) {
 _amount = getBalance(_token, _from);
 }
 if (_from != address(0) && _from != address(this) && _token != ETH_ADDR && _amount != 0) {
 IERC20(_token).safeTransferFrom(_from, address(this), _amount);
 }
 return _amount;
 }
 function withdrawTokens( address _token, address _to, uint256 _amount ) internal returns (uint256) {
 if (_amount == type(uint256).max) {
 _amount = getBalance(_token, address(this));
 }
 if (_to != address(0) && _to != address(this) && _amount != 0) {
 if (_token != ETH_ADDR) {
 IERC20(_token).safeTransfer(_to, _amount);
 }
 else {
 payable(_to).transfer(_amount);
 }
 }
 return _amount;
 }
 function depositWeth(uint256 _amount) internal {
 IWETH(WETH_ADDR).deposit{
 value: _amount}
 ();
 }
 function withdrawWeth(uint256 _amount) internal {
 IWETH(WETH_ADDR).withdraw(_amount);
 }
 function getBalance(address _tokenAddr, address _acc) internal view returns (uint256) {
 if (_tokenAddr == ETH_ADDR) {
 return _acc.balance;
 }
 else {
 return IERC20(_tokenAddr).balanceOf(_acc);
 }
 }
 function getTokenDecimals(address _token) internal view returns (uint256) {
 if (_token == ETH_ADDR) return 18;
 return IERC20(_token).decimals();
 }
 }
 abstract contract IDFSRegistry {
 function getAddr(bytes32 _id) public view virtual returns (address);
 function addNewContract( bytes32 _id, address _contractAddr, uint256 _waitPeriod ) public virtual;
 function startContractChange(bytes32 _id, address _newContractAddr) public virtual;
 function approveContractChange(bytes32 _id) public virtual;
 function cancelContractChange(bytes32 _id) public virtual;
 function changeWaitPeriod(bytes32 _id, uint256 _newWaitPeriod) public virtual;
 }
 contract AdminVault {
 address public owner;
 address public admin;
 constructor() {
 owner = msg.sender;
 admin = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
 }
 function changeOwner(address _owner) public {
 require(admin == msg.sender, "msg.sender not admin");
 owner = _owner;
 }
 function changeAdmin(address _admin) public {
 require(admin == msg.sender, "msg.sender not admin");
 admin = _admin;
 }
 }
 contract AdminAuth {
 using SafeERC20 for IERC20;
 address public constant ADMIN_VAULT_ADDR = 0xCCf3d848e08b94478Ed8f46fFead3008faF581fD;
 AdminVault public constant adminVault = AdminVault(ADMIN_VAULT_ADDR);
 modifier onlyOwner() {
 require(adminVault.owner() == msg.sender, "msg.sender not owner");
 _;
 }
 modifier onlyAdmin() {
 require(adminVault.admin() == msg.sender, "msg.sender not admin");
 _;
 }
 function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {
 if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
 payable(_receiver).transfer(_amount);
 }
 else {
 IERC20(_token).safeTransfer(_receiver, _amount);
 }
 }
 function kill() public onlyAdmin {
 selfdestruct(payable(msg.sender));
 }
 }
 contract DefisaverLogger {
 event LogEvent( address indexed contractAddress, address indexed caller, string indexed logName, bytes data );
 function Log( address _contract, address _caller, string memory _logName, bytes memory _data ) public {
 emit LogEvent(_contract, _caller, _logName, _data);
 }
 }
 contract DFSRegistry is AdminAuth {
 DefisaverLogger public constant logger = DefisaverLogger( 0x5c55B921f590a89C1Ebe84dF170E655a82b62126 );
 string public constant ERR_ENTRY_ALREADY_EXISTS = "Entry id already exists";
 string public constant ERR_ENTRY_NON_EXISTENT = "Entry id doesn't exists";
 string public constant ERR_ENTRY_NOT_IN_CHANGE = "Entry not in change process";
 string public constant ERR_WAIT_PERIOD_SHORTER = "New wait period must be bigger";
 string public constant ERR_CHANGE_NOT_READY = "Change not ready yet";
 string public constant ERR_EMPTY_PREV_ADDR = "Previous addr is 0";
 string public constant ERR_ALREADY_IN_CONTRACT_CHANGE = "Already in contract change";
 string public constant ERR_ALREADY_IN_WAIT_PERIOD_CHANGE = "Already in wait period change";
 struct Entry {
 address contractAddr;
 uint256 waitPeriod;
 uint256 changeStartTime;
 bool inContractChange;
 bool inWaitPeriodChange;
 bool exists;
 }
 mapping(bytes32 => Entry) public entries;
 mapping(bytes32 => address) public previousAddresses;
 mapping(bytes32 => address) public pendingAddresses;
 mapping(bytes32 => uint256) public pendingWaitTimes;
 function getAddr(bytes32 _id) public view returns (address) {
 return entries[_id].contractAddr;
 }
 function isRegistered(bytes32 _id) public view returns (bool) {
 return entries[_id].exists;
 }
 function addNewContract( bytes32 _id, address _contractAddr, uint256 _waitPeriod ) public onlyOwner {
 require(!entries[_id].exists, ERR_ENTRY_ALREADY_EXISTS);
 entries[_id] = Entry({
 contractAddr: _contractAddr, waitPeriod: _waitPeriod, changeStartTime: 0, inContractChange: false, inWaitPeriodChange: false, exists: true }
 );
 previousAddresses[_id] = _contractAddr;
 logger.Log( address(this), msg.sender, "AddNewContract", abi.encode(_id, _contractAddr, _waitPeriod) );
 }
 function revertToPreviousAddress(bytes32 _id) public onlyOwner {
 require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
 require(previousAddresses[_id] != address(0), ERR_EMPTY_PREV_ADDR);
 address currentAddr = entries[_id].contractAddr;
 entries[_id].contractAddr = previousAddresses[_id];
 logger.Log( address(this), msg.sender, "RevertToPreviousAddress", abi.encode(_id, currentAddr, previousAddresses[_id]) );
 }
 function startContractChange(bytes32 _id, address _newContractAddr) public onlyOwner {
 require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
 require(!entries[_id].inWaitPeriodChange, ERR_ALREADY_IN_WAIT_PERIOD_CHANGE);
 entries[_id].changeStartTime = block.timestamp;
 entries[_id].inContractChange = true;
 pendingAddresses[_id] = _newContractAddr;
 logger.Log( address(this), msg.sender, "StartContractChange", abi.encode(_id, entries[_id].contractAddr, _newContractAddr) );
 }
 function approveContractChange(bytes32 _id) public onlyOwner {
 require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
 require(entries[_id].inContractChange, ERR_ENTRY_NOT_IN_CHANGE);
 require( block.timestamp >= (entries[_id].changeStartTime + entries[_id].waitPeriod), ERR_CHANGE_NOT_READY );
 address oldContractAddr = entries[_id].contractAddr;
 entries[_id].contractAddr = pendingAddresses[_id];
 entries[_id].inContractChange = false;
 entries[_id].changeStartTime = 0;
 pendingAddresses[_id] = address(0);
 previousAddresses[_id] = oldContractAddr;
 logger.Log( address(this), msg.sender, "ApproveContractChange", abi.encode(_id, oldContractAddr, entries[_id].contractAddr) );
 }
 function cancelContractChange(bytes32 _id) public onlyOwner {
 require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
 require(entries[_id].inContractChange, ERR_ENTRY_NOT_IN_CHANGE);
 address oldContractAddr = pendingAddresses[_id];
 pendingAddresses[_id] = address(0);
 entries[_id].inContractChange = false;
 entries[_id].changeStartTime = 0;
 logger.Log( address(this), msg.sender, "CancelContractChange", abi.encode(_id, oldContractAddr, entries[_id].contractAddr) );
 }
 function startWaitPeriodChange(bytes32 _id, uint256 _newWaitPeriod) public onlyOwner {
 require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
 require(!entries[_id].inContractChange, ERR_ALREADY_IN_CONTRACT_CHANGE);
 pendingWaitTimes[_id] = _newWaitPeriod;
 entries[_id].changeStartTime = block.timestamp;
 entries[_id].inWaitPeriodChange = true;
 logger.Log( address(this), msg.sender, "StartWaitPeriodChange", abi.encode(_id, _newWaitPeriod) );
 }
 function approveWaitPeriodChange(bytes32 _id) public onlyOwner {
 require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
 require(entries[_id].inWaitPeriodChange, ERR_ENTRY_NOT_IN_CHANGE);
 require( block.timestamp >= (entries[_id].changeStartTime + entries[_id].waitPeriod), ERR_CHANGE_NOT_READY );
 uint256 oldWaitTime = entries[_id].waitPeriod;
 entries[_id].waitPeriod = pendingWaitTimes[_id];
 entries[_id].inWaitPeriodChange = false;
 entries[_id].changeStartTime = 0;
 pendingWaitTimes[_id] = 0;
 logger.Log( address(this), msg.sender, "ApproveWaitPeriodChange", abi.encode(_id, oldWaitTime, entries[_id].waitPeriod) );
 }
 function cancelWaitPeriodChange(bytes32 _id) public onlyOwner {
 require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
 require(entries[_id].inWaitPeriodChange, ERR_ENTRY_NOT_IN_CHANGE);
 uint256 oldWaitPeriod = pendingWaitTimes[_id];
 pendingWaitTimes[_id] = 0;
 entries[_id].inWaitPeriodChange = false;
 entries[_id].changeStartTime = 0;
 logger.Log( address(this), msg.sender, "CancelWaitPeriodChange", abi.encode(_id, oldWaitPeriod, entries[_id].waitPeriod) );
 }
 }
 abstract contract ActionBase is AdminAuth {
 address public constant REGISTRY_ADDR = 0xD6049E1F5F3EfF1F921f5532aF1A1632bA23929C;
 DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);
 DefisaverLogger public constant logger = DefisaverLogger( 0x5c55B921f590a89C1Ebe84dF170E655a82b62126 );
 string public constant ERR_SUB_INDEX_VALUE = "Wrong sub index value";
 string public constant ERR_RETURN_INDEX_VALUE = "Wrong return index value";
 uint8 public constant SUB_MIN_INDEX_VALUE = 128;
 uint8 public constant SUB_MAX_INDEX_VALUE = 255;
 uint8 public constant RETURN_MIN_INDEX_VALUE = 1;
 uint8 public constant RETURN_MAX_INDEX_VALUE = 127;
 uint8 public constant NO_PARAM_MAPPING = 0;
 enum ActionType {
 FL_ACTION, STANDARD_ACTION, CUSTOM_ACTION }
 function executeAction( bytes[] memory _callData, bytes[] memory _subData, uint8[] memory _paramMapping, bytes32[] memory _returnValues ) public payable virtual returns (bytes32);
 function executeActionDirect(bytes[] memory _callData) public virtual payable;
 function actionType() public pure virtual returns (uint8);
 function _parseParamUint( uint _param, uint8 _mapType, bytes[] memory _subData, bytes32[] memory _returnValues ) internal pure returns (uint) {
 if (isReplaceable(_mapType)) {
 if (isReturnInjection(_mapType)) {
 _param = uint(_returnValues[getReturnIndex(_mapType)]);
 }
 else {
 _param = abi.decode(_subData[getSubIndex(_mapType)], (uint));
 }
 }
 return _param;
 }
 function _parseParamAddr( address _param, uint8 _mapType, bytes[] memory _subData, bytes32[] memory _returnValues ) internal pure returns (address) {
 if (isReplaceable(_mapType)) {
 if (isReturnInjection(_mapType)) {
 _param = address(bytes20((_returnValues[getReturnIndex(_mapType)])));
 }
 else {
 _param = abi.decode(_subData[getSubIndex(_mapType)], (address));
 }
 }
 return _param;
 }
 function _parseParamABytes32( bytes32 _param, uint8 _mapType, bytes[] memory _subData, bytes32[] memory _returnValues ) internal pure returns (bytes32) {
 if (isReplaceable(_mapType)) {
 if (isReturnInjection(_mapType)) {
 _param = (_returnValues[getReturnIndex(_mapType)]);
 }
 else {
 _param = abi.decode(_subData[getSubIndex(_mapType)], (bytes32));
 }
 }
 return _param;
 }
 function isReplaceable(uint8 _type) internal pure returns (bool) {
 return _type != NO_PARAM_MAPPING;
 }
 function isReturnInjection(uint8 _type) internal pure returns (bool) {
 return (_type >= RETURN_MIN_INDEX_VALUE) && (_type <= RETURN_MAX_INDEX_VALUE);
 }
 function getReturnIndex(uint8 _type) internal pure returns (uint8) {
 require(isReturnInjection(_type), ERR_SUB_INDEX_VALUE);
 return (_type - RETURN_MIN_INDEX_VALUE);
 }
 function getSubIndex(uint8 _type) internal pure returns (uint8) {
 require(_type >= SUB_MIN_INDEX_VALUE, ERR_RETURN_INDEX_VALUE);
 return (_type - SUB_MIN_INDEX_VALUE);
 }
 }
 contract CompHelper {
 uint256 constant NO_ERROR = 0;
 string public constant ERR_COMP_ENTER_MARKET = "Comp failed to enter market";
 string public constant ERR_COMP_EXIT_MARKET = "Comp failed to exit market";
 address public constant C_ETH_ADDR = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
 address public constant COMPTROLLER_ADDR = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
 function getUnderlyingAddr(address _cTokenAddr) internal returns (address tokenAddr) {
 if (_cTokenAddr == C_ETH_ADDR) return TokenUtils.WETH_ADDR;
 tokenAddr = ICToken(_cTokenAddr).underlying();
 }
 function enterMarket(address _cTokenAddr) public {
 address[] memory markets = new address[](1);
 markets[0] = _cTokenAddr;
 uint256[] memory errCodes = IComptroller(COMPTROLLER_ADDR).enterMarkets(markets);
 require(errCodes[0] == NO_ERROR, ERR_COMP_ENTER_MARKET);
 }
 function exitMarket(address _cTokenAddr) public {
 require(IComptroller(COMPTROLLER_ADDR).exitMarket(_cTokenAddr) == NO_ERROR, ERR_COMP_EXIT_MARKET);
 }
 }
 contract CompPayback is ActionBase, CompHelper {
 using TokenUtils for address;
 string public constant ERR_COMP_PAYBACK_FAILED = "Compound payback failed";
 function executeAction( bytes[] memory _callData, bytes[] memory _subData, uint8[] memory _paramMapping, bytes32[] memory _returnValues ) public payable virtual override returns (bytes32) {
 ( address cTokenAddr, uint256 amount, address from, address onBehalf ) = parseInputs(_callData);
 cTokenAddr = _parseParamAddr(cTokenAddr, _paramMapping[0], _subData, _returnValues);
 amount = _parseParamUint(amount, _paramMapping[1], _subData, _returnValues);
 from = _parseParamAddr(from, _paramMapping[2], _subData, _returnValues);
 uint256 withdrawAmount = _payback(cTokenAddr, amount, from, onBehalf);
 return bytes32(withdrawAmount);
 }
 function executeActionDirect(bytes[] memory _callData) public payable override {
 ( address cTokenAddr, uint256 amount, address from, address onBehalf ) = parseInputs(_callData);
 _payback(cTokenAddr, amount, from, onBehalf);
 }
 function actionType() public pure virtual override returns (uint8) {
 return uint8(ActionType.STANDARD_ACTION);
 }
 function _payback( address _cTokenAddr, uint256 _amount, address _from, address _onBehalf ) internal returns (uint256) {
 address tokenAddr = getUnderlyingAddr(_cTokenAddr);
 if (_onBehalf == address(0)) {
 _onBehalf = address(this);
 }
 uint256 maxDebt = ICToken(_cTokenAddr).borrowBalanceCurrent(_onBehalf);
 _amount = _amount > maxDebt ? maxDebt : _amount;
 tokenAddr.pullTokensIfNeeded(_from, _amount);
 if (tokenAddr != TokenUtils.WETH_ADDR) {
 tokenAddr.approveToken(_cTokenAddr, _amount);
 require(ICToken(_cTokenAddr).repayBorrowBehalf(_onBehalf ,_amount) == NO_ERROR, ERR_COMP_PAYBACK_FAILED);
 }
 else {
 TokenUtils.withdrawWeth(_amount);
 ICToken(_cTokenAddr).repayBorrowBehalf{
 value: _amount}
 (_onBehalf);
 }
 logger.Log(address(this), msg.sender, "CompPayback", abi.encode(tokenAddr, _amount, _from, _onBehalf));
 return _amount;
 }
 function parseInputs(bytes[] memory _callData) internal pure returns ( address cTokenAddr, uint256 amount, address from, address onBehalf ) {
 cTokenAddr = abi.decode(_callData[0], (address));
 amount = abi.decode(_callData[1], (uint256));
 from = abi.decode(_callData[2], (address));
 onBehalf = abi.decode(_callData[3], (address));
 }
 }
