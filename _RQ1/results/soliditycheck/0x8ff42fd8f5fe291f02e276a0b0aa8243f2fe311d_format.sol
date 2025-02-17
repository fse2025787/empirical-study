 pragma experimental ABIEncoderV2;
 pragma solidity ^0.6.0;
 abstract contract Manager {
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
 abstract contract Vat {
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
 function move(address, address, uint) virtual public;
 function fork(bytes32, address, address, int, int) virtual public;
 }
 abstract contract PipInterface {
 function read() public virtual returns (bytes32);
 }
 abstract contract Spotter {
 struct Ilk {
 PipInterface pip;
 uint256 mat;
 }
 mapping (bytes32 => Ilk) public ilks;
 uint256 public par;
 }
 contract DSMath {
 function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require((z = x + y) >= x);
 }
 function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require((z = x - y) <= x);
 }
 function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require(y == 0 || (z = x * y) / y == x);
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
 interface ERC20 {
 function totalSupply() external view returns (uint256 supply);
 function balanceOf(address _owner) external view returns (uint256 balance);
 function transfer(address _to, uint256 _value) external returns (bool success);
 function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
 function approve(address _spender, uint256 _value) external returns (bool success);
 function allowance(address _owner, address _spender) external view returns (uint256 remaining);
 function decimals() external view returns (uint256 digits);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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
 library SafeERC20 {
 using SafeMath for uint256;
 using Address for address;
 function safeTransfer(ERC20 token, address to, uint256 value) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
 }
 function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
 }
 function safeApprove(ERC20 token, address spender, uint256 value) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
 }
 function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
 uint256 newAllowance = token.allowance(address(this), spender).add(value);
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
 }
 function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
 uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
 }
 function _callOptionalReturn(ERC20 token, bytes memory data) private {
 bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
 if (returndata.length > 0) {
 require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
 }
 }
 }
 contract AdminAuth {
 using SafeERC20 for ERC20;
 address public owner;
 address public admin;
 modifier onlyOwner() {
 require(owner == msg.sender);
 _;
 }
 modifier onlyAdmin() {
 require(admin == msg.sender);
 _;
 }
 constructor() public {
 owner = 0xBc841B0dE0b93205e912CFBBd1D0c160A1ec6F00;
 admin = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
 }
 function setAdminByOwner(address _admin) public {
 require(msg.sender == owner);
 require(admin == address(0));
 admin = _admin;
 }
 function setAdminByAdmin(address _admin) public {
 require(msg.sender == admin);
 admin = _admin;
 }
 function setOwnerByAdmin(address _owner) public {
 require(msg.sender == admin);
 owner = _owner;
 }
 function kill() public onlyOwner {
 selfdestruct(payable(owner));
 }
 function withdrawStuckFunds(address _token, uint _amount) public onlyOwner {
 if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
 payable(owner).transfer(_amount);
 }
 else {
 ERC20(_token).safeTransfer(owner, _amount);
 }
 }
 }
 contract DefisaverLogger {
 event LogEvent( address indexed contractAddress, address indexed caller, string indexed logName, bytes data );
 function Log(address _contract, address _caller, string memory _logName, bytes memory _data) public {
 emit LogEvent(_contract, _caller, _logName, _data);
 }
 }
 contract BotRegistry is AdminAuth {
 mapping (address => bool) public botList;
 constructor() public {
 botList[0x776B4a13093e30B05781F97F6A4565B6aa8BE330] = true;
 botList[0xAED662abcC4FA3314985E67Ea993CAD064a7F5cF] = true;
 botList[0xa5d330F6619d6bF892A5B87D80272e1607b3e34D] = true;
 botList[0x5feB4DeE5150B589a7f567EA7CADa2759794A90A] = true;
 botList[0x7ca06417c1d6f480d3bB195B80692F95A6B66158] = true;
 }
 function setBot(address _botAddr, bool _state) public onlyOwner {
 botList[_botAddr] = _state;
 }
 }
 contract DFSExchangeData {
 enum ExchangeType {
 _, OASIS, KYBER, UNISWAP, ZEROX }
 enum ActionType {
 SELL, BUY }
 struct OffchainData {
 address wrapper;
 address exchangeAddr;
 address allowanceTarget;
 uint256 price;
 uint256 protocolFee;
 bytes callData;
 }
 struct ExchangeData {
 address srcAddr;
 address destAddr;
 uint256 srcAmount;
 uint256 destAmount;
 uint256 minPrice;
 uint256 dfsFeeDivider;
 address user;
 address wrapper;
 bytes wrapperData;
 OffchainData offchainData;
 }
 function packExchangeData(ExchangeData memory _exData) public pure returns(bytes memory) {
 return abi.encode(_exData);
 }
 function unpackExchangeData(bytes memory _data) public pure returns(ExchangeData memory _exData) {
 _exData = abi.decode(_data, (ExchangeData));
 }
 }
 abstract contract StaticV2 {
 enum Method {
 Boost, Repay }
 struct CdpHolder {
 uint128 minRatio;
 uint128 maxRatio;
 uint128 optimalRatioBoost;
 uint128 optimalRatioRepay;
 address owner;
 uint cdpId;
 bool boostEnabled;
 bool nextPriceEnabled;
 }
 struct SubPosition {
 uint arrPos;
 bool subscribed;
 }
 }
 abstract contract ISubscriptionsV2 is StaticV2 {
 function getOwner(uint _cdpId) external view virtual returns(address);
 function getSubscribedInfo(uint _cdpId) public view virtual returns(bool, uint128, uint128, uint128, uint128, address, uint coll, uint debt);
 function getCdpHolder(uint _cdpId) public view virtual returns (bool subscribed, CdpHolder memory);
 }
 abstract contract DSProxyInterface {
 function execute(address _target, bytes memory _data) public virtual payable returns (bytes32);
 function setCache(address _cacheAddr) public virtual payable returns (bool);
 function owner() public virtual returns (address);
 }
 contract MCDMonitorProxyV2 is AdminAuth {
 uint public CHANGE_PERIOD;
 uint public MIN_CHANGE_PERIOD = 6 * 1 hours;
 address public monitor;
 address public newMonitor;
 address public lastMonitor;
 uint public changeRequestedTimestamp;
 event MonitorChangeInitiated(address oldMonitor, address newMonitor);
 event MonitorChangeCanceled();
 event MonitorChangeFinished(address monitor);
 event MonitorChangeReverted(address monitor);
 modifier onlyMonitor() {
 require (msg.sender == monitor);
 _;
 }
 constructor(uint _changePeriod) public {
 CHANGE_PERIOD = _changePeriod * 1 hours;
 }
 function callExecute(address _owner, address _saverProxy, bytes memory _data) public payable onlyMonitor {
 DSProxyInterface(_owner).execute{
 value: msg.value}
 (_saverProxy, _data);
 if (address(this).balance > 0) {
 msg.sender.transfer(address(this).balance);
 }
 }
 function setMonitor(address _monitor) public onlyOwner {
 require(monitor == address(0));
 monitor = _monitor;
 }
 function changeMonitor(address _newMonitor) public onlyOwner {
 require(changeRequestedTimestamp == 0);
 changeRequestedTimestamp = now;
 lastMonitor = monitor;
 newMonitor = _newMonitor;
 emit MonitorChangeInitiated(lastMonitor, newMonitor);
 }
 function cancelMonitorChange() public onlyOwner {
 require(changeRequestedTimestamp > 0);
 changeRequestedTimestamp = 0;
 newMonitor = address(0);
 emit MonitorChangeCanceled();
 }
 function confirmNewMonitor() public onlyOwner {
 require((changeRequestedTimestamp + CHANGE_PERIOD) < now);
 require(changeRequestedTimestamp != 0);
 require(newMonitor != address(0));
 monitor = newMonitor;
 newMonitor = address(0);
 changeRequestedTimestamp = 0;
 emit MonitorChangeFinished(monitor);
 }
 function revertMonitor() public onlyOwner {
 require(lastMonitor != address(0));
 monitor = lastMonitor;
 emit MonitorChangeReverted(monitor);
 }
 function setChangePeriod(uint _periodInHours) public onlyOwner {
 require(_periodInHours * 1 hours > MIN_CHANGE_PERIOD);
 CHANGE_PERIOD = _periodInHours * 1 hours;
 }
 }
 contract MCDMonitorV2 is DSMath, AdminAuth, StaticV2 {
 uint256 public MAX_GAS_PRICE = 800 gwei;
 uint256 public REPAY_GAS_COST = 1_000_000;
 uint256 public BOOST_GAS_COST = 1_000_000;
 bytes4 public REPAY_SELECTOR = 0xf360ce20;
 bytes4 public BOOST_SELECTOR = 0x8ec2ae25;
 MCDMonitorProxyV2 public monitorProxyContract = MCDMonitorProxyV2(0x1816A86C4DA59395522a42b871bf11A4E96A1C7a);
 ISubscriptionsV2 public subscriptionsContract = ISubscriptionsV2(0xC45d4f6B6bf41b6EdAA58B01c4298B8d9078269a);
 address public mcdSaverTakerAddress;
 address public constant BOT_REGISTRY_ADDRESS = 0x637726f8b08a7ABE3aE3aCaB01A80E2d8ddeF77B;
 address public constant PROXY_PERMISSION_ADDR = 0x5a4f877CA808Cca3cB7c2A194F80Ab8588FAE26B;
 Manager public manager = Manager(0x5ef30b9986345249bc32d8928B7ee64DE9435E39);
 Vat public vat = Vat(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);
 Spotter public spotter = Spotter(0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3);
 DefisaverLogger public constant logger = DefisaverLogger(0x5c55B921f590a89C1Ebe84dF170E655a82b62126);
 modifier onlyApproved() {
 require(BotRegistry(BOT_REGISTRY_ADDRESS).botList(msg.sender), "Not auth bot");
 _;
 }
 constructor( address _newMcdSaverTakerAddress ) public {
 mcdSaverTakerAddress = _newMcdSaverTakerAddress;
 }
 function repayFor( DFSExchangeData.ExchangeData memory _exchangeData, uint256 _cdpId, uint256 _nextPrice, address _joinAddr ) public payable onlyApproved {
 bool isAllowed;
 uint256 ratioBefore;
 string memory errReason;
 (isAllowed, ratioBefore, errReason) = checkPreconditions( Method.Repay, _cdpId, _nextPrice );
 require(isAllowed, errReason);
 uint256 gasCost = calcGasCost(REPAY_GAS_COST);
 address usersProxy = subscriptionsContract.getOwner(_cdpId);
 monitorProxyContract.callExecute{
 value: msg.value}
 ( usersProxy, mcdSaverTakerAddress, abi.encodeWithSelector(REPAY_SELECTOR, _exchangeData, _cdpId, gasCost, _joinAddr, 0) );
 bool isGoodRatio;
 uint256 ratioAfter;
 (isGoodRatio, ratioAfter, errReason) = ratioGoodAfter( Method.Repay, _cdpId, _nextPrice, ratioBefore );
 require(isGoodRatio, errReason);
 returnEth();
 logger.Log( address(this), usersProxy, "AutomaticMCDRepay", abi.encode(ratioBefore, ratioAfter) );
 }
 function boostFor( DFSExchangeData.ExchangeData memory _exchangeData, uint256 _cdpId, uint256 _nextPrice, address _joinAddr ) public payable onlyApproved {
 bool isAllowed;
 uint256 ratioBefore;
 string memory errReason;
 (isAllowed, ratioBefore, errReason) = checkPreconditions( Method.Boost, _cdpId, _nextPrice );
 require(isAllowed, errReason);
 uint256 gasCost = calcGasCost(BOOST_GAS_COST);
 address usersProxy = subscriptionsContract.getOwner(_cdpId);
 monitorProxyContract.callExecute{
 value: msg.value}
 ( usersProxy, mcdSaverTakerAddress, abi.encodeWithSelector(BOOST_SELECTOR, _exchangeData, _cdpId, gasCost, _joinAddr, 0) );
 bool isGoodRatio;
 uint256 ratioAfter;
 (isGoodRatio, ratioAfter, errReason) = ratioGoodAfter( Method.Boost, _cdpId, _nextPrice, ratioBefore );
 require(isGoodRatio, errReason);
 returnEth();
 logger.Log( address(this), usersProxy, "AutomaticMCDBoost", abi.encode(ratioBefore, ratioAfter) );
 }
 function returnEth() internal {
 if (address(this).balance > 0) {
 msg.sender.transfer(address(this).balance);
 }
 }
 function getOwner(uint256 _cdpId) public view returns (address) {
 return manager.owns(_cdpId);
 }
 function getCdpInfo(uint256 _cdpId, bytes32 _ilk) public view returns (uint256, uint256) {
 address urn = manager.urns(_cdpId);
 (uint256 collateral, uint256 debt) = vat.urns(_ilk, urn);
 (, uint256 rate, , , ) = vat.ilks(_ilk);
 return (collateral, rmul(debt, rate));
 }
 function getPrice(bytes32 _ilk) public view returns (uint256) {
 (, uint256 mat) = spotter.ilks(_ilk);
 (, , uint256 spot, , ) = vat.ilks(_ilk);
 return rmul(rmul(spot, spotter.par()), mat);
 }
 function getRatio(uint256 _cdpId, uint256 _nextPrice) public view returns (uint256) {
 bytes32 ilk = manager.ilks(_cdpId);
 uint256 price = (_nextPrice == 0) ? getPrice(ilk) : _nextPrice;
 (uint256 collateral, uint256 debt) = getCdpInfo(_cdpId, ilk);
 if (debt == 0) return 0;
 return rdiv(wmul(collateral, price), debt) / (10**18);
 }
 function checkPreconditions( Method _method, uint256 _cdpId, uint256 _nextPrice ) public view returns ( bool, uint256, string memory ) {
 (bool subscribed, CdpHolder memory holder) = subscriptionsContract.getCdpHolder(_cdpId);
 if (!subscribed) return (false, 0, "Cdp not sub");
 if (_nextPrice > 0 && !holder.nextPriceEnabled) return (false, 0, "Next price send but not enabled");
 if (_method == Method.Boost && !holder.boostEnabled) return (false, 0, "Boost not enabled");
 if (getOwner(_cdpId) != holder.owner) return (false, 0, "EOA not subbed owner");
 uint256 currRatio = getRatio(_cdpId, _nextPrice);
 if (_method == Method.Repay) {
 if (currRatio > holder.minRatio) return (false, 0, "Ratio is bigger than min");
 }
 else if (_method == Method.Boost) {
 if (currRatio < holder.maxRatio) return (false, 0, "Ratio is less than max");
 }
 return (true, currRatio, "");
 }
 function ratioGoodAfter( Method _method, uint256 _cdpId, uint256 _nextPrice, uint256 _beforeRatio ) public view returns ( bool, uint256, string memory ) {
 (, CdpHolder memory holder) = subscriptionsContract.getCdpHolder(_cdpId);
 uint256 currRatio = getRatio(_cdpId, _nextPrice);
 if (_method == Method.Repay) {
 if (currRatio >= holder.maxRatio) return (false, currRatio, "Repay increased ratio over max");
 if (currRatio <= _beforeRatio) return (false, currRatio, "Repay made ratio worse");
 }
 else if (_method == Method.Boost) {
 if (currRatio <= holder.minRatio) return (false, currRatio, "Boost lowered ratio over min");
 if (currRatio >= _beforeRatio) return (false, currRatio, "Boost didn't lower ratio");
 }
 return (true, currRatio, "");
 }
 function calcGasCost(uint256 _gasAmount) public view returns (uint256) {
 uint256 gasPrice = tx.gasprice <= MAX_GAS_PRICE ? tx.gasprice : MAX_GAS_PRICE;
 return mul(gasPrice, _gasAmount);
 }
 function changeBoostGasCost(uint256 _gasCost) public onlyOwner {
 require(_gasCost < 3_000_000, "Boost gas cost over limit");
 BOOST_GAS_COST = _gasCost;
 }
 function changeRepayGasCost(uint256 _gasCost) public onlyOwner {
 require(_gasCost < 3_000_000, "Repay gas cost over limit");
 REPAY_GAS_COST = _gasCost;
 }
 function changeMaxGasPrice(uint256 _maxGasPrice) public onlyOwner {
 require(_maxGasPrice < 2000 gwei, "Max gas price over the limit");
 MAX_GAS_PRICE = _maxGasPrice;
 }
 }
