  pragma experimental ABIEncoderV2;
 pragma solidity =0.7.6;
 abstract contract IManager {
 function last(address) virtual public returns (uint);
 function cdpCan(address, uint, address) virtual public view returns (uint);
 function ilks(uint) virtual public view returns (bytes32);
 function owns(uint) virtual public view returns (address);
 function urns(uint) virtual public view returns (address);
 function vat() virtual public view returns (address);
 function open(bytes32, address) virtual public returns (uint);
 function give(uint, address) virtual public;
 function cdpAllow(uint, address, uint) virtual public;
 function urnAllow(address, uint) virtual public;
 function frob(uint, int, int) virtual public;
 function flux(uint, address, uint) virtual public;
 function move(uint, address, uint) virtual public;
 function exit(address, uint, address, uint) virtual public;
 function quit(uint, address) virtual public;
 function enter(address, uint) virtual public;
 function shift(uint, uint) virtual public;
 }
 abstract contract IVat {
 struct Urn {
 uint256 ink;
 uint256 art;
 }
 struct Ilk {
 uint256 Art;
 uint256 rate;
 uint256 spot;
 uint256 line;
 uint256 dust;
 }
 mapping (bytes32 => mapping (address => Urn )) public urns;
 mapping (bytes32 => Ilk) public ilks;
 mapping (bytes32 => mapping (address => uint)) public gem;
 function can(address, address) virtual public view returns (uint);
 function dai(address) virtual public view returns (uint);
 function frob(bytes32, address, address, address, int, int) virtual public;
 function hope(address) virtual public;
 function nope(address) virtual public;
 function move(address, address, uint) virtual public;
 function fork(bytes32, address, address, int, int) virtual public;
 }
 abstract contract IGem {
 function dec() virtual public returns (uint);
 function gem() virtual public returns (IGem);
 function join(address, uint) virtual public payable;
 function exit(address, uint) virtual public;
 function approve(address, uint) virtual public;
 function transfer(address, uint) virtual public returns (bool);
 function transferFrom(address, address, uint) virtual public returns (bool);
 function deposit() virtual public payable;
 function withdraw(uint) virtual public;
 function allowance(address, address) virtual public returns (uint);
 }
 abstract contract IJoin {
 bytes32 public ilk;
 function dec() virtual public view returns (uint);
 function gem() virtual public view returns (IGem);
 function join(address, uint) virtual public payable;
 function exit(address, uint) virtual public;
 }
 abstract contract ICropJoin is IJoin {
 function bonus() external virtual returns (IGem);
 }
 interface ICropper {
 function proxy(address) view external returns (address);
 function getOrCreateProxy(address) external returns (address);
 function join(address, address, uint256) external;
 function exit(address, address, uint256) external;
 function flee(address, address, uint256) external;
 function frob(bytes32, address, address, address, int256, int256) external;
 function quit(bytes32, address, address) external;
 }
 abstract contract ICdpRegistry {
 function open( bytes32 ilk, address usr ) public virtual returns (uint256);
 function cdps(bytes32, address) virtual public view returns (uint256);
 function owns(uint) virtual public view returns (address);
 function ilks(uint) virtual public view returns (bytes32);
 }
 interface IERC20 {
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function decimals() external view returns (uint256 digits);
 function totalSupply() external view returns (uint256 supply);
 function balanceOf(address _owner) external view returns (uint256 balance);
 function transfer(address _to, uint256 _value) external returns (bool success);
 function transferFrom( address _from, address _to, uint256 _value ) external returns (bool success);
 function approve(address _spender, uint256 _value) external returns (bool success);
 function allowance(address _owner, address _spender) external view returns (uint256 remaining);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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
 (bool success, ) = _to.call{
 value: _amount}
 ("");
 require(success, "Eth send fail");
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
 contract MainnetAuthAddresses {
 address internal constant ADMIN_VAULT_ADDR = 0xCCf3d848e08b94478Ed8f46fFead3008faF581fD;
 address internal constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;
 address internal constant ADMIN_ADDR = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
 }
 contract AuthHelper is MainnetAuthAddresses {
 }
 contract AdminVault is AuthHelper {
 address public owner;
 address public admin;
 constructor() {
 owner = msg.sender;
 admin = ADMIN_ADDR;
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
 contract AdminAuth is AuthHelper {
 using SafeERC20 for IERC20;
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
 contract MainnetCoreAddresses {
 address internal constant DEFI_SAVER_LOGGER_ADDR = 0x5c55B921f590a89C1Ebe84dF170E655a82b62126;
 address internal constant REGISTRY_ADDR = 0xD6049E1F5F3EfF1F921f5532aF1A1632bA23929C;
 address internal constant PROXY_AUTH_ADDR = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;
 }
 contract CoreHelper is MainnetCoreAddresses {
 }
 contract DFSRegistry is AdminAuth, CoreHelper {
 DefisaverLogger public constant logger = DefisaverLogger( DEFI_SAVER_LOGGER_ADDR );
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
 contract MainnetActionsUtilAddresses {
 address internal constant DFS_REG_CONTROLLER_ADDR = 0xF8f8B3C98Cf2E63Df3041b73f80F362a4cf3A576;
 address internal constant REGISTRY_ADDR = 0xD6049E1F5F3EfF1F921f5532aF1A1632bA23929C;
 address internal constant DFS_LOGGER_ADDR = 0x5c55B921f590a89C1Ebe84dF170E655a82b62126;
 }
 contract ActionsUtilHelper is MainnetActionsUtilAddresses {
 }
 abstract contract ActionBase is AdminAuth, ActionsUtilHelper {
 DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);
 DefisaverLogger public constant logger = DefisaverLogger( DFS_LOGGER_ADDR );
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
 contract DSMath {
 function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require((z = x + y) >= x, "");
 }
 function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require((z = x - y) <= x, "");
 }
 function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require(y == 0 || (z = x * y) / y == x, "");
 }
 function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
 return x / y;
 }
 function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
 return x <= y ? x : y;
 }
 function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
 return x >= y ? x : y;
 }
 function imin(int256 x, int256 y) internal pure returns (int256 z) {
 return x <= y ? x : y;
 }
 function imax(int256 x, int256 y) internal pure returns (int256 z) {
 return x >= y ? x : y;
 }
 uint256 constant WAD = 10**18;
 uint256 constant RAY = 10**27;
 function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = add(mul(x, y), WAD / 2) / WAD;
 }
 function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = add(mul(x, y), RAY / 2) / RAY;
 }
 function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = add(mul(x, WAD), y / 2) / y;
 }
 function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = add(mul(x, RAY), y / 2) / y;
 }
 function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
 z = n % 2 != 0 ? x : RAY;
 for (n /= 2; n != 0; n /= 2) {
 x = rmul(x, x);
 if (n % 2 != 0) {
 z = rmul(z, x);
 }
 }
 }
 }
 abstract contract DSAuthority {
 function canCall( address src, address dst, bytes4 sig ) public view virtual returns (bool);
 }
 contract DSAuthEvents {
 event LogSetAuthority(address indexed authority);
 event LogSetOwner(address indexed owner);
 }
 contract DSAuth is DSAuthEvents {
 DSAuthority public authority;
 address public owner;
 constructor() {
 owner = msg.sender;
 emit LogSetOwner(msg.sender);
 }
 function setOwner(address owner_) public auth {
 owner = owner_;
 emit LogSetOwner(owner);
 }
 function setAuthority(DSAuthority authority_) public auth {
 authority = authority_;
 emit LogSetAuthority(address(authority));
 }
 modifier auth {
 require(isAuthorized(msg.sender, msg.sig), "Not authorized");
 _;
 }
 function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
 if (src == address(this)) {
 return true;
 }
 else if (src == owner) {
 return true;
 }
 else if (authority == DSAuthority(0)) {
 return false;
 }
 else {
 return authority.canCall(src, address(this), sig);
 }
 }
 }
 contract DSNote {
 event LogNote( bytes4 indexed sig, address indexed guy, bytes32 indexed foo, bytes32 indexed bar, uint256 wad, bytes fax ) anonymous;
 modifier note {
 bytes32 foo;
 bytes32 bar;
 assembly {
 foo := calldataload(4) bar := calldataload(36) }
 emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);
 _;
 }
 }
 abstract contract DSProxy is DSAuth, DSNote {
 DSProxyCache public cache;
 constructor(address _cacheAddr) {
 require(setCache(_cacheAddr), "Cache not set");
 }
 receive() external payable {
 }
 function execute(bytes memory _code, bytes memory _data) public payable virtual returns (address target, bytes32 response);
 function execute(address _target, bytes memory _data) public payable virtual returns (bytes32 response);
 function setCache(address _cacheAddr) public payable virtual returns (bool);
 }
 contract DSProxyCache {
 mapping(bytes32 => address) cache;
 function read(bytes memory _code) public view returns (address) {
 bytes32 hash = keccak256(_code);
 return cache[hash];
 }
 function write(bytes memory _code) public returns (address target) {
 assembly {
 target := create(0, add(_code, 0x20), mload(_code)) switch iszero(extcodesize(target)) case 1 {
 revert(0, 0) }
 }
 bytes32 hash = keccak256(_code);
 cache[hash] = target;
 }
 }
 contract MainnetMcdAddresses {
 address internal constant VAT_ADDR = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
 address internal constant DAI_JOIN_ADDR = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
 address internal constant DAI_ADDR = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
 address internal constant JUG_ADDRESS = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
 address internal constant SPOTTER_ADDRESS = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
 address internal constant PROXY_REGISTRY_ADDR = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;
 address internal constant CDP_REGISTRY = 0xBe0274664Ca7A68d6b5dF826FB3CcB7c620bADF3;
 address internal constant CROPPER = 0x8377CD01a5834a6EaD3b7efb482f678f2092b77e;
 }
 contract McdHelper is DSMath, MainnetMcdAddresses {
 IVat public constant vat = IVat(VAT_ADDR);
 function normalizeDrawAmount(uint _amount, uint _rate, uint _daiVatBalance) internal pure returns (int dart) {
 if (_daiVatBalance < mul(_amount, RAY)) {
 dart = toPositiveInt(sub(mul(_amount, RAY), _daiVatBalance) / _rate);
 dart = mul(uint(dart), _rate) < mul(_amount, RAY) ? dart + 1 : dart;
 }
 }
 function toRad(uint _wad) internal pure returns (uint) {
 return mul(_wad, 10 ** 27);
 }
 function convertTo18(address _joinAddr, uint256 _amount) internal view returns (uint256) {
 return mul(_amount, 10 ** sub(18 , IJoin(_joinAddr).dec()));
 }
 function toPositiveInt(uint _x) internal pure returns (int y) {
 y = int(_x);
 require(y >= 0, "int-overflow");
 }
 function normalizePaybackAmount(address _vat, uint256 _daiBalance, address _urn, bytes32 _ilk) internal view returns (int amount) {
 (, uint rate,,,) = IVat(_vat).ilks(_ilk);
 (, uint art) = IVat(_vat).urns(_ilk, _urn);
 amount = toPositiveInt(_daiBalance / rate);
 amount = uint(amount) <= art ? - amount : - toPositiveInt(art);
 }
 function getAllDebt(address _vat, address _usr, address _urn, bytes32 _ilk) internal view returns (uint daiAmount) {
 (, uint rate,,,) = IVat(_vat).ilks(_ilk);
 (, uint art) = IVat(_vat).urns(_ilk, _urn);
 uint dai = IVat(_vat).dai(_usr);
 uint rad = sub(mul(art, rate), dai);
 daiAmount = rad / RAY;
 daiAmount = mul(daiAmount, RAY) < rad ? daiAmount + 1 : daiAmount;
 }
 function isEthJoinAddr(address _joinAddr) internal view returns (bool) {
 if (_joinAddr == DAI_JOIN_ADDR) return false;
 if (address(IJoin(_joinAddr).gem()) == TokenUtils.WETH_ADDR) {
 return true;
 }
 return false;
 }
 function getTokenFromJoin(address _joinAddr) internal view returns (address) {
 if (_joinAddr == DAI_JOIN_ADDR) {
 return DAI_ADDR;
 }
 return address(IJoin(_joinAddr).gem());
 }
 function getUrnAndIlk(address _mcdManager, uint256 _vaultId) public view returns (address urn, bytes32 ilk) {
 if (_mcdManager == CROPPER) {
 address owner = ICdpRegistry(CDP_REGISTRY).owns(_vaultId);
 urn = ICropper(CROPPER).proxy(owner);
 ilk = ICdpRegistry(CDP_REGISTRY).ilks(_vaultId);
 }
 else {
 urn = IManager(_mcdManager).urns(_vaultId);
 ilk = IManager(_mcdManager).ilks(_vaultId);
 }
 }
 function getCdpInfo(IManager _manager, uint _cdpId, bytes32 _ilk) public view returns (uint, uint) {
 address urn;
 if (address(_manager) == CROPPER) {
 address owner = ICdpRegistry(CDP_REGISTRY).owns(_cdpId);
 urn = ICropper(CROPPER).proxy(owner);
 }
 else {
 urn = _manager.urns(_cdpId);
 }
 (uint collateral, uint debt) = vat.urns(_ilk, urn);
 (,uint rate,,,) = vat.ilks(_ilk);
 return (collateral, rmul(debt, rate));
 }
 function getOwner(IManager _manager, uint _cdpId) public view returns (address) {
 address owner;
 if (address(_manager) == CROPPER) {
 owner = ICdpRegistry(CDP_REGISTRY).owns(_cdpId);
 }
 else {
 owner = _manager.owns(_cdpId);
 }
 DSProxy proxy = DSProxy(uint160(owner));
 return proxy.owner();
 }
 }
 contract McdWithdraw is ActionBase, McdHelper {
 using TokenUtils for address;
 function executeAction( bytes[] memory _callData, bytes[] memory _subData, uint8[] memory _paramMapping, bytes32[] memory _returnValues ) public payable override returns (bytes32) {
 (uint256 vaultId, uint256 amount, address joinAddr, address to, address mcdManager) = parseInputs(_callData);
 vaultId = _parseParamUint(vaultId, _paramMapping[0], _subData, _returnValues);
 amount = _parseParamUint(amount, _paramMapping[1], _subData, _returnValues);
 joinAddr = _parseParamAddr(joinAddr, _paramMapping[2], _subData, _returnValues);
 to = _parseParamAddr(to, _paramMapping[3], _subData, _returnValues);
 amount = _mcdWithdraw(vaultId, amount, joinAddr, to, mcdManager);
 return bytes32(amount);
 }
 function executeActionDirect(bytes[] memory _callData) public payable override {
 (uint256 vaultId, uint256 amount, address joinAddr, address to, address mcdManager) = parseInputs(_callData);
 _mcdWithdraw(vaultId, amount, joinAddr, to, mcdManager);
 }
 function actionType() public pure override returns (uint8) {
 return uint8(ActionType.STANDARD_ACTION);
 }
 function _mcdWithdraw( uint256 _vaultId, uint256 _amount, address _joinAddr, address _to, address _mcdManager ) internal returns (uint256) {
 if (_amount == type(uint256).max) {
 _amount = getAllColl(IManager(_mcdManager), _joinAddr, _vaultId);
 }
 uint256 frobAmount = convertTo18(_joinAddr, _amount);
 if (_mcdManager == CROPPER) {
 _cropperWithdraw(_vaultId, _joinAddr, _amount, frobAmount);
 }
 else {
 _mcdManagerWithdraw(_mcdManager, _vaultId, _joinAddr, _amount, frobAmount);
 }
 getTokenFromJoin(_joinAddr).withdrawTokens(_to, _amount);
 logger.Log( address(this), msg.sender, "McdWithdraw", abi.encode(_vaultId, _amount, _joinAddr, _to, _mcdManager) );
 return _amount;
 }
 function _mcdManagerWithdraw( address _mcdManager, uint256 _vaultId, address _joinAddr, uint256 _amount, uint256 _frobAmount ) internal {
 IManager mcdManager = IManager(_mcdManager);
 mcdManager.frob(_vaultId, -toPositiveInt(_frobAmount), 0);
 mcdManager.flux(_vaultId, address(this), _frobAmount);
 IJoin(_joinAddr).exit(address(this), _amount);
 }
 function _cropperWithdraw( uint256 _vaultId, address _joinAddr, uint256 _amount, uint256 _frobAmount ) internal {
 bytes32 ilk = ICdpRegistry(CDP_REGISTRY).ilks(_vaultId);
 address owner = ICdpRegistry(CDP_REGISTRY).owns(_vaultId);
 ICropper(CROPPER).frob(ilk, owner, owner, owner, -toPositiveInt(_frobAmount), 0);
 ICropper(CROPPER).exit(_joinAddr, address(this), _amount);
 }
 function getAllColl(IManager _mcdManager, address _joinAddr, uint _vaultId) internal view returns (uint amount) {
 bytes32 ilk;
 if (address(_mcdManager) == CROPPER) {
 ilk = ICdpRegistry(CDP_REGISTRY).ilks(_vaultId);
 }
 else {
 ilk = _mcdManager.ilks(_vaultId);
 }
 (amount, ) = getCdpInfo( _mcdManager, _vaultId, ilk );
 if (IJoin(_joinAddr).dec() != 18) {
 return div(amount, 10 ** sub(18, IJoin(_joinAddr).dec()));
 }
 }
 function parseInputs(bytes[] memory _callData) internal pure returns ( uint256 vaultId, uint256 amount, address joinAddr, address to, address mcdManager ) {
 vaultId = abi.decode(_callData[0], (uint256));
 amount = abi.decode(_callData[1], (uint256));
 joinAddr = abi.decode(_callData[2], (address));
 to = abi.decode(_callData[3], (address));
 mcdManager = abi.decode(_callData[4], (address));
 }
 }
