  pragma experimental ABIEncoderV2;
 pragma solidity 0.6.12;
 interface CurvePool {
 function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy, address receiver) external returns (uint256);
 function approve(address _spender, uint256 _value) external returns (bool);
 function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount, bool _use_underlying) external returns (uint256);
 function add_liquidity(uint256[2] memory amounts, uint256 _min_mint_amount) external returns (uint256);
 }
 pragma solidity 0.6.12;
 interface IERC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 function permit( address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s ) external;
 }
 interface YearnVault {
 function withdraw() external returns (uint256);
 function deposit(uint256 amount, address recipient) external returns (uint256);
 }
 interface TetherToken {
 function approve(address _spender, uint256 _value) external;
 }
 interface IWETH is IERC20 {
 function transfer(address _to, uint256 _value) external returns (bool success);
 function deposit() external payable;
 function withdraw(uint wad) external;
 }
 interface IThreeCrypto is CurvePool {
 function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external;
 }
 contract YVCrvStETHLevSwapper2 {
 using BoringMath for uint256;
 using BoringERC20 for IERC20;
 IBentoBoxV1 public constant degenBox = IBentoBoxV1(0xd96f48665a1410C0cd669A88898ecA36B9Fc2cce);
 CurvePool public constant MIM3POOL = CurvePool(0x5a6A4D54456819380173272A5E8E9B9904BdF41B);
 CurvePool constant public STETH = CurvePool(0x828b154032950C8ff7CF8085D841723Db2696056);
 YearnVault constant public YVSTETH = YearnVault(0x5faF6a2D186448Dfa667c51CB3D695c7A6E52d8E);
 TetherToken public constant TETHER = TetherToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);
 IERC20 public constant MIM = IERC20(0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3);
 IERC20 public constant CurveToken = IERC20(0x06325440D014e39736583c165C2963BA99fAf14E);
 IWETH public constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
 IThreeCrypto constant public threecrypto = IThreeCrypto(0xD51a44d3FaE010294C616388b506AcdA1bfAAE46);
 constructor() public {
 MIM.approve(address(MIM3POOL), type(uint256).max);
 TETHER.approve(address(threecrypto), type(uint256).max);
 WETH.approve(address(STETH), type(uint256).max);
 CurveToken.approve(address(YVSTETH), type(uint256).max);
 }
 function getAmountOut( uint256 amountIn, uint256 reserveIn, uint256 reserveOut ) internal pure returns (uint256 amountOut) {
 uint256 amountInWithFee = amountIn.mul(997);
 uint256 numerator = amountInWithFee.mul(reserveOut);
 uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
 amountOut = numerator / denominator;
 }
 function getAmountIn( uint256 amountOut, uint256 reserveIn, uint256 reserveOut ) internal pure returns (uint256 amountIn) {
 uint256 numerator = reserveIn.mul(amountOut).mul(1000);
 uint256 denominator = reserveOut.sub(amountOut).mul(997);
 amountIn = (numerator / denominator).add(1);
 }
 receive() external payable {
 }
 function swap( address recipient, uint256 shareToMin, uint256 shareFrom ) public returns (uint256 extraShare, uint256 shareReturned) {
 (uint256 amountFrom, ) = degenBox.withdraw(MIM, address(this), address(this), 0, shareFrom);
 uint256 amountThird;
 {
 uint256 amountSecond = MIM3POOL.exchange_underlying(0, 3, amountFrom, 0, address(this));
 threecrypto.exchange(0, 2, amountSecond, 0);
 amountThird = WETH.balanceOf(address(this));
 }
 uint256[2] memory amountsAdded = [amountThird,0];
 STETH.add_liquidity(amountsAdded, 0);
 uint256 amountTo = YVSTETH.deposit(type(uint256).max, address(degenBox));
 (, shareReturned) = degenBox.deposit(IERC20(address(YVSTETH)), address(degenBox), recipient, amountTo, 0);
 extraShare = shareReturned.sub(shareToMin);
 }
 }
 pragma solidity 0.6.12;
 library BoringMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
 require((c = a + b) >= b, "BoringMath: Add Overflow");
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
 require((c = a - b) <= a, "BoringMath: Underflow");
 }
 function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
 require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
 }
 function to128(uint256 a) internal pure returns (uint128 c) {
 require(a <= uint128(-1), "BoringMath: uint128 Overflow");
 c = uint128(a);
 }
 function to64(uint256 a) internal pure returns (uint64 c) {
 require(a <= uint64(-1), "BoringMath: uint64 Overflow");
 c = uint64(a);
 }
 function to32(uint256 a) internal pure returns (uint32 c) {
 require(a <= uint32(-1), "BoringMath: uint32 Overflow");
 c = uint32(a);
 }
 }
 library BoringMath128 {
 function add(uint128 a, uint128 b) internal pure returns (uint128 c) {
 require((c = a + b) >= b, "BoringMath: Add Overflow");
 }
 function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {
 require((c = a - b) <= a, "BoringMath: Underflow");
 }
 }
 library BoringMath64 {
 function add(uint64 a, uint64 b) internal pure returns (uint64 c) {
 require((c = a + b) >= b, "BoringMath: Add Overflow");
 }
 function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {
 require((c = a - b) <= a, "BoringMath: Underflow");
 }
 }
 library BoringMath32 {
 function add(uint32 a, uint32 b) internal pure returns (uint32 c) {
 require((c = a + b) >= b, "BoringMath: Add Overflow");
 }
 function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {
 require((c = a - b) <= a, "BoringMath: Underflow");
 }
 }
 pragma solidity 0.6.12;
 library BoringERC20 {
 bytes4 private constant SIG_SYMBOL = 0x95d89b41;
 bytes4 private constant SIG_NAME = 0x06fdde03;
 bytes4 private constant SIG_DECIMALS = 0x313ce567;
 bytes4 private constant SIG_TRANSFER = 0xa9059cbb;
 bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd;
 function returnDataToString(bytes memory data) internal pure returns (string memory) {
 if (data.length >= 64) {
 return abi.decode(data, (string));
 }
 else if (data.length == 32) {
 uint8 i = 0;
 while(i < 32 && data[i] != 0) {
 i++;
 }
 bytes memory bytesArray = new bytes(i);
 for (i = 0; i < 32 && data[i] != 0; i++) {
 bytesArray[i] = data[i];
 }
 return string(bytesArray);
 }
 else {
 return "???";
 }
 }
 function safeSymbol(IERC20 token) internal view returns (string memory) {
 (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_SYMBOL));
 return success ? returnDataToString(data) : "???";
 }
 function safeName(IERC20 token) internal view returns (string memory) {
 (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_NAME));
 return success ? returnDataToString(data) : "???";
 }
 function safeDecimals(IERC20 token) internal view returns (uint8) {
 (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_DECIMALS));
 return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
 }
 function safeTransfer( IERC20 token, address to, uint256 amount ) internal {
 (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
 require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
 }
 function safeTransferFrom( IERC20 token, address from, address to, uint256 amount ) internal {
 (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
 require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
 }
 }
 pragma solidity 0.6.12;
 interface IBentoBoxV1 {
 event LogDeploy(address indexed masterContract, bytes data, address indexed cloneAddress);
 event LogDeposit(address indexed token, address indexed from, address indexed to, uint256 amount, uint256 share);
 event LogFlashLoan(address indexed borrower, address indexed token, uint256 amount, uint256 feeAmount, address indexed receiver);
 event LogRegisterProtocol(address indexed protocol);
 event LogSetMasterContractApproval(address indexed masterContract, address indexed user, bool approved);
 event LogStrategyDivest(address indexed token, uint256 amount);
 event LogStrategyInvest(address indexed token, uint256 amount);
 event LogStrategyLoss(address indexed token, uint256 amount);
 event LogStrategyProfit(address indexed token, uint256 amount);
 event LogStrategyQueued(address indexed token, address indexed strategy);
 event LogStrategySet(address indexed token, address indexed strategy);
 event LogStrategyTargetPercentage(address indexed token, uint256 targetPercentage);
 event LogTransfer(address indexed token, address indexed from, address indexed to, uint256 share);
 event LogWhiteListMasterContract(address indexed masterContract, bool approved);
 event LogWithdraw(address indexed token, address indexed from, address indexed to, uint256 amount, uint256 share);
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 function balanceOf(IERC20, address) external view returns (uint256);
 function batch(bytes[] calldata calls, bool revertOnFail) external payable returns (bool[] memory successes, bytes[] memory results);
 function batchFlashLoan(IBatchFlashBorrower borrower, address[] calldata receivers, IERC20[] calldata tokens, uint256[] calldata amounts, bytes calldata data) external;
 function claimOwnership() external;
 function deploy(address masterContract, bytes calldata data, bool useCreate2) external payable;
 function deposit(IERC20 token_, address from, address to, uint256 amount, uint256 share) external payable returns (uint256 amountOut, uint256 shareOut);
 function flashLoan(IFlashBorrower borrower, address receiver, IERC20 token, uint256 amount, bytes calldata data) external;
 function harvest(IERC20 token, bool balance, uint256 maxChangeAmount) external;
 function masterContractApproved(address, address) external view returns (bool);
 function masterContractOf(address) external view returns (address);
 function nonces(address) external view returns (uint256);
 function owner() external view returns (address);
 function pendingOwner() external view returns (address);
 function pendingStrategy(IERC20) external view returns (IStrategy);
 function permitToken(IERC20 token, address from, address to, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
 function registerProtocol() external;
 function setMasterContractApproval(address user, address masterContract, bool approved, uint8 v, bytes32 r, bytes32 s) external;
 function setStrategy(IERC20 token, IStrategy newStrategy) external;
 function setStrategyTargetPercentage(IERC20 token, uint64 targetPercentage_) external;
 function strategy(IERC20) external view returns (IStrategy);
 function strategyData(IERC20) external view returns (uint64 strategyStartDate, uint64 targetPercentage, uint128 balance);
 function toAmount(IERC20 token, uint256 share, bool roundUp) external view returns (uint256 amount);
 function toShare(IERC20 token, uint256 amount, bool roundUp) external view returns (uint256 share);
 function totals(IERC20) external view returns (Rebase memory totals_);
 function transfer(IERC20 token, address from, address to, uint256 share) external;
 function transferMultiple(IERC20 token, address from, address[] calldata tos, uint256[] calldata shares) external;
 function transferOwnership(address newOwner, bool direct, bool renounce) external;
 function whitelistMasterContract(address masterContract, bool approved) external;
 function whitelistedMasterContracts(address) external view returns (bool);
 function withdraw(IERC20 token_, address from, address to, uint256 amount, uint256 share) external returns (uint256 amountOut, uint256 shareOut);
 }
 pragma solidity 0.6.12;
 struct Rebase {
 uint128 elastic;
 uint128 base;
 }
 library RebaseLibrary {
 using BoringMath for uint256;
 using BoringMath128 for uint128;
 function toBase( Rebase memory total, uint256 elastic, bool roundUp ) internal pure returns (uint256 base) {
 if (total.elastic == 0) {
 base = elastic;
 }
 else {
 base = elastic.mul(total.base) / total.elastic;
 if (roundUp && base.mul(total.elastic) / total.base < elastic) {
 base = base.add(1);
 }
 }
 }
 function toElastic( Rebase memory total, uint256 base, bool roundUp ) internal pure returns (uint256 elastic) {
 if (total.base == 0) {
 elastic = base;
 }
 else {
 elastic = base.mul(total.elastic) / total.base;
 if (roundUp && elastic.mul(total.base) / total.elastic < base) {
 elastic = elastic.add(1);
 }
 }
 }
 function add( Rebase memory total, uint256 elastic, bool roundUp ) internal pure returns (Rebase memory, uint256 base) {
 base = toBase(total, elastic, roundUp);
 total.elastic = total.elastic.add(elastic.to128());
 total.base = total.base.add(base.to128());
 return (total, base);
 }
 function sub( Rebase memory total, uint256 base, bool roundUp ) internal pure returns (Rebase memory, uint256 elastic) {
 elastic = toElastic(total, base, roundUp);
 total.elastic = total.elastic.sub(elastic.to128());
 total.base = total.base.sub(base.to128());
 return (total, elastic);
 }
 function add( Rebase memory total, uint256 elastic, uint256 base ) internal pure returns (Rebase memory) {
 total.elastic = total.elastic.add(elastic.to128());
 total.base = total.base.add(base.to128());
 return total;
 }
 function sub( Rebase memory total, uint256 elastic, uint256 base ) internal pure returns (Rebase memory) {
 total.elastic = total.elastic.sub(elastic.to128());
 total.base = total.base.sub(base.to128());
 return total;
 }
 function addElastic(Rebase storage total, uint256 elastic) internal returns (uint256 newElastic) {
 newElastic = total.elastic = total.elastic.add(elastic.to128());
 }
 function subElastic(Rebase storage total, uint256 elastic) internal returns (uint256 newElastic) {
 newElastic = total.elastic = total.elastic.sub(elastic.to128());
 }
 }
 pragma solidity 0.6.12;
 interface IBatchFlashBorrower {
 function onBatchFlashLoan( address sender, IERC20[] calldata tokens, uint256[] calldata amounts, uint256[] calldata fees, bytes calldata data ) external;
 }
 pragma solidity 0.6.12;
 interface IFlashBorrower {
 function onFlashLoan( address sender, IERC20 token, uint256 amount, uint256 fee, bytes calldata data ) external;
 }
 pragma solidity 0.6.12;
 interface IStrategy {
 function skim(uint256 amount) external;
 function harvest(uint256 balance, address sender) external returns (int256 amountAdded);
 function withdraw(uint256 amount) external returns (uint256 actualAmount);
 function exit(uint256 balance) external returns (int256 amountAdded);
 }
