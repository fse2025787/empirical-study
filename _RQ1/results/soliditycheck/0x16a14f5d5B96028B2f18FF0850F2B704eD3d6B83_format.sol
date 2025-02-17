 pragma experimental ABIEncoderV2;
 pragma solidity ^0.5.16;
 contract UnitrollerAdminStorage {
 address public admin;
 address public pendingAdmin;
 address public comptrollerImplementation;
 address public pendingComptrollerImplementation;
 }
 contract ComptrollerV1Storage is UnitrollerAdminStorage {
 PriceOracle public oracle;
 uint public closeFactorMantissa;
 uint public liquidationIncentiveMantissa;
 uint public maxAssets;
 mapping(address => CToken[]) public accountAssets;
 }
 contract ComptrollerV2Storage is ComptrollerV1Storage {
 enum Version {
 VANILLA, COLLATERALCAP, WRAPPEDNATIVE }
 struct Market {
 bool isListed;
 uint collateralFactorMantissa;
 mapping(address => bool) accountMembership;
 bool isComped;
 Version version;
 }
 mapping(address => Market) public markets;
 address public pauseGuardian;
 bool public _mintGuardianPaused;
 bool public _borrowGuardianPaused;
 bool public transferGuardianPaused;
 bool public seizeGuardianPaused;
 mapping(address => bool) public mintGuardianPaused;
 mapping(address => bool) public borrowGuardianPaused;
 }
 contract ComptrollerV3Storage is ComptrollerV2Storage {
 struct CompMarketState {
 uint224 index;
 uint32 block;
 }
 CToken[] public allMarkets;
 uint public compRate;
 mapping(address => uint) public compSpeeds;
 mapping(address => CompMarketState) public compSupplyState;
 mapping(address => CompMarketState) public compBorrowState;
 mapping(address => mapping(address => uint)) public compSupplierIndex;
 mapping(address => mapping(address => uint)) public compBorrowerIndex;
 mapping(address => uint) public compAccrued;
 }
 contract ComptrollerV4Storage is ComptrollerV3Storage {
 address public borrowCapGuardian;
 mapping(address => uint) public borrowCaps;
 }
 contract CErc20Storage {
 address public underlying;
 address public implementation;
 }
 pragma solidity ^0.5.16;
 contract CTokenStorage {
 bool internal _notEntered;
 string public name;
 string public symbol;
 uint8 public decimals;
 uint internal constant borrowRateMaxMantissa = 0.0005e16;
 uint internal constant reserveFactorMaxMantissa = 1e18;
 address payable public admin;
 address payable public pendingAdmin;
 ComptrollerInterface public comptroller;
 InterestRateModel public interestRateModel;
 uint internal initialExchangeRateMantissa;
 uint public reserveFactorMantissa;
 uint public accrualBlockNumber;
 uint public borrowIndex;
 uint public totalBorrows;
 uint public totalReserves;
 uint public totalSupply;
 mapping (address => uint) internal accountTokens;
 mapping (address => mapping (address => uint)) internal transferAllowances;
 struct BorrowSnapshot {
 uint principal;
 uint interestIndex;
 }
 mapping(address => BorrowSnapshot) internal accountBorrows;
 }
 contract CSupplyCapStorage {
 uint256 public internalCash;
 }
 contract CErc20Interface is CErc20Storage {
 function mint(uint mintAmount) external returns (uint);
 function redeem(uint redeemTokens) external returns (uint);
 function redeemUnderlying(uint redeemAmount) external returns (uint);
 function borrow(uint borrowAmount) external returns (uint);
 function repayBorrow(uint repayAmount) external returns (uint);
 function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
 function liquidateBorrow(address borrower, uint repayAmount, CTokenInterface cTokenCollateral) external returns (uint);
 function _addReserves(uint addAmount) external returns (uint);
 }
 pragma solidity ^0.5.16;
 contract CarefulMath {
 enum MathError {
 NO_ERROR, DIVISION_BY_ZERO, INTEGER_OVERFLOW, INTEGER_UNDERFLOW }
 function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {
 if (a == 0) {
 return (MathError.NO_ERROR, 0);
 }
 uint c = a * b;
 if (c / a != b) {
 return (MathError.INTEGER_OVERFLOW, 0);
 }
 else {
 return (MathError.NO_ERROR, c);
 }
 }
 function divUInt(uint a, uint b) internal pure returns (MathError, uint) {
 if (b == 0) {
 return (MathError.DIVISION_BY_ZERO, 0);
 }
 return (MathError.NO_ERROR, a / b);
 }
 function subUInt(uint a, uint b) internal pure returns (MathError, uint) {
 if (b <= a) {
 return (MathError.NO_ERROR, a - b);
 }
 else {
 return (MathError.INTEGER_UNDERFLOW, 0);
 }
 }
 function addUInt(uint a, uint b) internal pure returns (MathError, uint) {
 uint c = a + b;
 if (c >= a) {
 return (MathError.NO_ERROR, c);
 }
 else {
 return (MathError.INTEGER_OVERFLOW, 0);
 }
 }
 function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {
 (MathError err0, uint sum) = addUInt(a, b);
 if (err0 != MathError.NO_ERROR) {
 return (err0, 0);
 }
 return subUInt(sum, c);
 }
 }
 contract ComptrollerV5Storage is ComptrollerV4Storage {
 address public supplyCapGuardian;
 mapping(address => uint) public supplyCaps;
 }
 contract CTokenInterface is CTokenStorage {
 bool public constant isCToken = true;
 event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);
 event Mint(address minter, uint mintAmount, uint mintTokens);
 event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);
 event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);
 event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);
 event LiquidateBorrow(address liquidator, address borrower, uint repayAmount, address cTokenCollateral, uint seizeTokens);
 event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
 event NewAdmin(address oldAdmin, address newAdmin);
 event NewComptroller(ComptrollerInterface oldComptroller, ComptrollerInterface newComptroller);
 event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);
 event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);
 event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);
 event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);
 event Transfer(address indexed from, address indexed to, uint amount);
 event Approval(address indexed owner, address indexed spender, uint amount);
 event Failure(uint error, uint info, uint detail);
 function transfer(address dst, uint amount) external returns (bool);
 function transferFrom(address src, address dst, uint amount) external returns (bool);
 function approve(address spender, uint amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint);
 function balanceOf(address owner) external view returns (uint);
 function balanceOfUnderlying(address owner) external returns (uint);
 function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
 function borrowRatePerBlock() external view returns (uint);
 function supplyRatePerBlock() external view returns (uint);
 function totalBorrowsCurrent() external returns (uint);
 function borrowBalanceCurrent(address account) external returns (uint);
 function borrowBalanceStored(address account) public view returns (uint);
 function exchangeRateCurrent() public returns (uint);
 function exchangeRateStored() public view returns (uint);
 function getCash() external view returns (uint);
 function accrueInterest() public returns (uint);
 function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);
 function _setPendingAdmin(address payable newPendingAdmin) external returns (uint);
 function _acceptAdmin() external returns (uint);
 function _setComptroller(ComptrollerInterface newComptroller) public returns (uint);
 function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);
 function _reduceReserves(uint reduceAmount) external returns (uint);
 function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint);
 }
 contract TokenErrorReporter {
 enum Error {
 NO_ERROR, UNAUTHORIZED, BAD_INPUT, COMPTROLLER_REJECTION, COMPTROLLER_CALCULATION_ERROR, INTEREST_RATE_MODEL_ERROR, INVALID_ACCOUNT_PAIR, INVALID_CLOSE_AMOUNT_REQUESTED, INVALID_COLLATERAL_FACTOR, MATH_ERROR, MARKET_NOT_FRESH, MARKET_NOT_LISTED, TOKEN_INSUFFICIENT_ALLOWANCE, TOKEN_INSUFFICIENT_BALANCE, TOKEN_INSUFFICIENT_CASH, TOKEN_TRANSFER_IN_FAILED, TOKEN_TRANSFER_OUT_FAILED }
 enum FailureInfo {
 ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED, BORROW_ACCRUE_INTEREST_FAILED, BORROW_CASH_NOT_AVAILABLE, BORROW_FRESHNESS_CHECK, BORROW_MARKET_NOT_LISTED, BORROW_COMPTROLLER_REJECTION, LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED, LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED, LIQUIDATE_COLLATERAL_FRESHNESS_CHECK, LIQUIDATE_COMPTROLLER_REJECTION, LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED, LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX, LIQUIDATE_CLOSE_AMOUNT_IS_ZERO, LIQUIDATE_FRESHNESS_CHECK, LIQUIDATE_LIQUIDATOR_IS_BORROWER, LIQUIDATE_REPAY_BORROW_FRESH_FAILED, LIQUIDATE_SEIZE_COMPTROLLER_REJECTION, LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER, LIQUIDATE_SEIZE_TOO_MUCH, MINT_ACCRUE_INTEREST_FAILED, MINT_COMPTROLLER_REJECTION, MINT_FRESHNESS_CHECK, MINT_TRANSFER_IN_FAILED, MINT_TRANSFER_IN_NOT_POSSIBLE, REDEEM_ACCRUE_INTEREST_FAILED, REDEEM_COMPTROLLER_REJECTION, REDEEM_FRESHNESS_CHECK, REDEEM_TRANSFER_OUT_NOT_POSSIBLE, REDUCE_RESERVES_ACCRUE_INTEREST_FAILED, REDUCE_RESERVES_ADMIN_CHECK, REDUCE_RESERVES_CASH_NOT_AVAILABLE, REDUCE_RESERVES_FRESH_CHECK, REDUCE_RESERVES_VALIDATION, REPAY_BEHALF_ACCRUE_INTEREST_FAILED, REPAY_BORROW_ACCRUE_INTEREST_FAILED, REPAY_BORROW_COMPTROLLER_REJECTION, REPAY_BORROW_FRESHNESS_CHECK, REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_VALIDATION, SET_COMPTROLLER_OWNER_CHECK, SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED, SET_INTEREST_RATE_MODEL_FRESH_CHECK, SET_INTEREST_RATE_MODEL_OWNER_CHECK, SET_MAX_ASSETS_OWNER_CHECK, SET_ORACLE_MARKET_NOT_LISTED, SET_PENDING_ADMIN_OWNER_CHECK, SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED, SET_RESERVE_FACTOR_ADMIN_CHECK, SET_RESERVE_FACTOR_FRESH_CHECK, SET_RESERVE_FACTOR_BOUNDS_CHECK, TRANSFER_COMPTROLLER_REJECTION, TRANSFER_NOT_ALLOWED, ADD_RESERVES_ACCRUE_INTEREST_FAILED, ADD_RESERVES_FRESH_CHECK, ADD_RESERVES_TRANSFER_IN_NOT_POSSIBLE }
 event Failure(uint error, uint info, uint detail);
 function fail(Error err, FailureInfo info) internal returns (uint) {
 emit Failure(uint(err), uint(info), 0);
 return uint(err);
 }
 function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
 emit Failure(uint(err), uint(info), opaqueError);
 return uint(err);
 }
 }
 pragma solidity ^0.5.16;
 contract Exponential is CarefulMath {
 uint constant expScale = 1e18;
 uint constant doubleScale = 1e36;
 uint constant halfExpScale = expScale/2;
 uint constant mantissaOne = expScale;
 struct Exp {
 uint mantissa;
 }
 struct Double {
 uint mantissa;
 }
 function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {
 (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
 if (err0 != MathError.NO_ERROR) {
 return (err0, Exp({
 mantissa: 0}
 ));
 }
 (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
 if (err1 != MathError.NO_ERROR) {
 return (err1, Exp({
 mantissa: 0}
 ));
 }
 return (MathError.NO_ERROR, Exp({
 mantissa: rational}
 ));
 }
 function addExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
 (MathError error, uint result) = addUInt(a.mantissa, b.mantissa);
 return (error, Exp({
 mantissa: result}
 ));
 }
 function subExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
 (MathError error, uint result) = subUInt(a.mantissa, b.mantissa);
 return (error, Exp({
 mantissa: result}
 ));
 }
 function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
 (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
 if (err0 != MathError.NO_ERROR) {
 return (err0, Exp({
 mantissa: 0}
 ));
 }
 return (MathError.NO_ERROR, Exp({
 mantissa: scaledMantissa}
 ));
 }
 function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {
 (MathError err, Exp memory product) = mulScalar(a, scalar);
 if (err != MathError.NO_ERROR) {
 return (err, 0);
 }
 return (MathError.NO_ERROR, truncate(product));
 }
 function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (MathError, uint) {
 (MathError err, Exp memory product) = mulScalar(a, scalar);
 if (err != MathError.NO_ERROR) {
 return (err, 0);
 }
 return addUInt(truncate(product), addend);
 }
 function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {
 Exp memory product = mul_(a, scalar);
 return truncate(product);
 }
 function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {
 Exp memory product = mul_(a, scalar);
 return add_(truncate(product), addend);
 }
 function divScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
 (MathError err0, uint descaledMantissa) = divUInt(a.mantissa, scalar);
 if (err0 != MathError.NO_ERROR) {
 return (err0, Exp({
 mantissa: 0}
 ));
 }
 return (MathError.NO_ERROR, Exp({
 mantissa: descaledMantissa}
 ));
 }
 function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {
 (MathError err0, uint numerator) = mulUInt(expScale, scalar);
 if (err0 != MathError.NO_ERROR) {
 return (err0, Exp({
 mantissa: 0}
 ));
 }
 return getExp(numerator, divisor.mantissa);
 }
 function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (MathError, uint) {
 (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
 if (err != MathError.NO_ERROR) {
 return (err, 0);
 }
 return (MathError.NO_ERROR, truncate(fraction));
 }
 function div_ScalarByExp(uint scalar, Exp memory divisor) pure internal returns (Exp memory) {
 uint numerator = mul_(expScale, scalar);
 return Exp({
 mantissa: div_(numerator, divisor)}
 );
 }
 function div_ScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (uint) {
 Exp memory fraction = div_ScalarByExp(scalar, divisor);
 return truncate(fraction);
 }
 function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
 (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
 if (err0 != MathError.NO_ERROR) {
 return (err0, Exp({
 mantissa: 0}
 ));
 }
 (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
 if (err1 != MathError.NO_ERROR) {
 return (err1, Exp({
 mantissa: 0}
 ));
 }
 (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
 assert(err2 == MathError.NO_ERROR);
 return (MathError.NO_ERROR, Exp({
 mantissa: product}
 ));
 }
 function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {
 return mulExp(Exp({
 mantissa: a}
 ), Exp({
 mantissa: b}
 ));
 }
 function mulExp3(Exp memory a, Exp memory b, Exp memory c) pure internal returns (MathError, Exp memory) {
 (MathError err, Exp memory ab) = mulExp(a, b);
 if (err != MathError.NO_ERROR) {
 return (err, ab);
 }
 return mulExp(ab, c);
 }
 function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
 return getExp(a.mantissa, b.mantissa);
 }
 function truncate(Exp memory exp) pure internal returns (uint) {
 return exp.mantissa / expScale;
 }
 function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
 return left.mantissa < right.mantissa;
 }
 function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
 return left.mantissa <= right.mantissa;
 }
 function isZeroExp(Exp memory value) pure internal returns (bool) {
 return value.mantissa == 0;
 }
 function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
 require(n < 2**224, errorMessage);
 return uint224(n);
 }
 function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
 require(n < 2**32, errorMessage);
 return uint32(n);
 }
 function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
 return Exp({
 mantissa: add_(a.mantissa, b.mantissa)}
 );
 }
 function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
 return Double({
 mantissa: add_(a.mantissa, b.mantissa)}
 );
 }
 function add_(uint a, uint b) pure internal returns (uint) {
 return add_(a, b, "addition overflow");
 }
 function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
 uint c = a + b;
 require(c >= a, errorMessage);
 return c;
 }
 function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
 return Exp({
 mantissa: sub_(a.mantissa, b.mantissa)}
 );
 }
 function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
 return Double({
 mantissa: sub_(a.mantissa, b.mantissa)}
 );
 }
 function sub_(uint a, uint b) pure internal returns (uint) {
 return sub_(a, b, "subtraction underflow");
 }
 function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
 require(b <= a, errorMessage);
 return a - b;
 }
 function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
 return Exp({
 mantissa: mul_(a.mantissa, b.mantissa) / expScale}
 );
 }
 function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
 return Exp({
 mantissa: mul_(a.mantissa, b)}
 );
 }
 function mul_(uint a, Exp memory b) pure internal returns (uint) {
 return mul_(a, b.mantissa) / expScale;
 }
 function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
 return Double({
 mantissa: mul_(a.mantissa, b.mantissa) / doubleScale}
 );
 }
 function mul_(Double memory a, uint b) pure internal returns (Double memory) {
 return Double({
 mantissa: mul_(a.mantissa, b)}
 );
 }
 function mul_(uint a, Double memory b) pure internal returns (uint) {
 return mul_(a, b.mantissa) / doubleScale;
 }
 function mul_(uint a, uint b) pure internal returns (uint) {
 return mul_(a, b, "multiplication overflow");
 }
 function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
 if (a == 0 || b == 0) {
 return 0;
 }
 uint c = a * b;
 require(c / a == b, errorMessage);
 return c;
 }
 function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
 return Exp({
 mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)}
 );
 }
 function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
 return Exp({
 mantissa: div_(a.mantissa, b)}
 );
 }
 function div_(uint a, Exp memory b) pure internal returns (uint) {
 return div_(mul_(a, expScale), b.mantissa);
 }
 function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
 return Double({
 mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)}
 );
 }
 function div_(Double memory a, uint b) pure internal returns (Double memory) {
 return Double({
 mantissa: div_(a.mantissa, b)}
 );
 }
 function div_(uint a, Double memory b) pure internal returns (uint) {
 return div_(mul_(a, doubleScale), b.mantissa);
 }
 function div_(uint a, uint b) pure internal returns (uint) {
 return div_(a, b, "divide by zero");
 }
 function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
 require(b > 0, errorMessage);
 return a / b;
 }
 function fraction(uint a, uint b) pure internal returns (Double memory) {
 return Double({
 mantissa: div_(mul_(a, doubleScale), b)}
 );
 }
 function sqrt(uint x) pure internal returns (uint) {
 if (x == 0) return 0;
 uint xx = x;
 uint r = 1;
 if (xx >= 0x100000000000000000000000000000000) {
 xx >>= 128;
 r <<= 64;
 }
 if (xx >= 0x10000000000000000) {
 xx >>= 64;
 r <<= 32;
 }
 if (xx >= 0x100000000) {
 xx >>= 32;
 r <<= 16;
 }
 if (xx >= 0x10000) {
 xx >>= 16;
 r <<= 8;
 }
 if (xx >= 0x100) {
 xx >>= 8;
 r <<= 4;
 }
 if (xx >= 0x10) {
 xx >>= 4;
 r <<= 2;
 }
 if (xx >= 0x8) {
 r <<= 1;
 }
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 uint r1 = x / r;
 return (r < r1 ? r : r1);
 }
 }
 pragma solidity ^0.5.16;
 contract CToken is CTokenInterface, Exponential, TokenErrorReporter {
 function initialize(ComptrollerInterface comptroller_, InterestRateModel interestRateModel_, uint initialExchangeRateMantissa_, string memory name_, string memory symbol_, uint8 decimals_) public {
 require(msg.sender == admin, "only admin may initialize the market");
 require(accrualBlockNumber == 0 && borrowIndex == 0, "market may only be initialized once");
 initialExchangeRateMantissa = initialExchangeRateMantissa_;
 require(initialExchangeRateMantissa > 0, "initial exchange rate must be greater than zero.");
 uint err = _setComptroller(comptroller_);
 require(err == uint(Error.NO_ERROR), "setting comptroller failed");
 accrualBlockNumber = getBlockNumber();
 borrowIndex = mantissaOne;
 err = _setInterestRateModelFresh(interestRateModel_);
 require(err == uint(Error.NO_ERROR), "setting interest rate model failed");
 name = name_;
 symbol = symbol_;
 decimals = decimals_;
 _notEntered = true;
 }
 function transfer(address dst, uint256 amount) external nonReentrant returns (bool) {
 return transferTokens(msg.sender, msg.sender, dst, amount) == uint(Error.NO_ERROR);
 }
 function transferFrom(address src, address dst, uint256 amount) external nonReentrant returns (bool) {
 return transferTokens(msg.sender, src, dst, amount) == uint(Error.NO_ERROR);
 }
 function approve(address spender, uint256 amount) external returns (bool) {
 address src = msg.sender;
 transferAllowances[src][spender] = amount;
 emit Approval(src, spender, amount);
 return true;
 }
 function allowance(address owner, address spender) external view returns (uint256) {
 return transferAllowances[owner][spender];
 }
 function balanceOf(address owner) external view returns (uint256) {
 return accountTokens[owner];
 }
 function balanceOfUnderlying(address owner) external returns (uint) {
 Exp memory exchangeRate = Exp({
 mantissa: exchangeRateCurrent()}
 );
 return mul_ScalarTruncate(exchangeRate, accountTokens[owner]);
 }
 function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint) {
 uint cTokenBalance = getCTokenBalanceInternal(account);
 uint borrowBalance = borrowBalanceStoredInternal(account);
 uint exchangeRateMantissa = exchangeRateStoredInternal();
 return (uint(Error.NO_ERROR), cTokenBalance, borrowBalance, exchangeRateMantissa);
 }
 function getBlockNumber() internal view returns (uint) {
 return block.number;
 }
 function borrowRatePerBlock() external view returns (uint) {
 return interestRateModel.getBorrowRate(getCashPrior(), totalBorrows, totalReserves);
 }
 function supplyRatePerBlock() external view returns (uint) {
 return interestRateModel.getSupplyRate(getCashPrior(), totalBorrows, totalReserves, reserveFactorMantissa);
 }
 function estimateBorrowRatePerBlockAfterChange(uint256 change, bool repay) external view returns (uint) {
 uint256 cashPriorNew;
 uint256 totalBorrowsNew;
 if (repay) {
 cashPriorNew = add_(getCashPrior(), change);
 totalBorrowsNew = sub_(totalBorrows, change);
 }
 else {
 cashPriorNew = sub_(getCashPrior(), change);
 totalBorrowsNew = add_(totalBorrows, change);
 }
 return interestRateModel.getBorrowRate(cashPriorNew, totalBorrowsNew, totalReserves);
 }
 function estimateSupplyRatePerBlockAfterChange(uint256 change, bool repay) external view returns (uint) {
 uint256 cashPriorNew;
 uint256 totalBorrowsNew;
 if (repay) {
 cashPriorNew = add_(getCashPrior(), change);
 totalBorrowsNew = sub_(totalBorrows, change);
 }
 else {
 cashPriorNew = sub_(getCashPrior(), change);
 totalBorrowsNew = add_(totalBorrows, change);
 }
 return interestRateModel.getSupplyRate(cashPriorNew, totalBorrowsNew, totalReserves, reserveFactorMantissa);
 }
 function totalBorrowsCurrent() external nonReentrant returns (uint) {
 require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
 return totalBorrows;
 }
 function borrowBalanceCurrent(address account) external nonReentrant returns (uint) {
 require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
 return borrowBalanceStored(account);
 }
 function borrowBalanceStored(address account) public view returns (uint) {
 return borrowBalanceStoredInternal(account);
 }
 function borrowBalanceStoredInternal(address account) internal view returns (uint) {
 BorrowSnapshot storage borrowSnapshot = accountBorrows[account];
 if (borrowSnapshot.principal == 0) {
 return 0;
 }
 uint principalTimesIndex = mul_(borrowSnapshot.principal, borrowIndex);
 uint result = div_(principalTimesIndex, borrowSnapshot.interestIndex);
 return result;
 }
 function exchangeRateCurrent() public nonReentrant returns (uint) {
 require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
 return exchangeRateStored();
 }
 function exchangeRateStored() public view returns (uint) {
 return exchangeRateStoredInternal();
 }
 function exchangeRateStoredInternal() internal view returns (uint) {
 uint _totalSupply = totalSupply;
 if (_totalSupply == 0) {
 return initialExchangeRateMantissa;
 }
 else {
 uint totalCash = getCashPrior();
 uint cashPlusBorrowsMinusReserves = sub_(add_(totalCash, totalBorrows), totalReserves);
 uint exchangeRate = div_(cashPlusBorrowsMinusReserves, Exp({
 mantissa: _totalSupply}
 ));
 return exchangeRate;
 }
 }
 function getCash() external view returns (uint) {
 return getCashPrior();
 }
 function accrueInterest() public returns (uint) {
 uint currentBlockNumber = getBlockNumber();
 uint accrualBlockNumberPrior = accrualBlockNumber;
 if (accrualBlockNumberPrior == currentBlockNumber) {
 return uint(Error.NO_ERROR);
 }
 uint cashPrior = getCashPrior();
 uint borrowsPrior = totalBorrows;
 uint reservesPrior = totalReserves;
 uint borrowIndexPrior = borrowIndex;
 uint borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, borrowsPrior, reservesPrior);
 require(borrowRateMantissa <= borrowRateMaxMantissa, "borrow rate is absurdly high");
 uint blockDelta = sub_(currentBlockNumber, accrualBlockNumberPrior);
 Exp memory simpleInterestFactor = mul_(Exp({
 mantissa: borrowRateMantissa}
 ), blockDelta);
 uint interestAccumulated = mul_ScalarTruncate(simpleInterestFactor, borrowsPrior);
 uint totalBorrowsNew = add_(interestAccumulated, borrowsPrior);
 uint totalReservesNew = mul_ScalarTruncateAddUInt(Exp({
 mantissa: reserveFactorMantissa}
 ), interestAccumulated, reservesPrior);
 uint borrowIndexNew = mul_ScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);
 accrualBlockNumber = currentBlockNumber;
 borrowIndex = borrowIndexNew;
 totalBorrows = totalBorrowsNew;
 totalReserves = totalReservesNew;
 emit AccrueInterest(cashPrior, interestAccumulated, borrowIndexNew, totalBorrowsNew);
 return uint(Error.NO_ERROR);
 }
 function mintInternal(uint mintAmount, bool isNative) internal nonReentrant returns (uint, uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return (fail(Error(error), FailureInfo.MINT_ACCRUE_INTEREST_FAILED), 0);
 }
 return mintFresh(msg.sender, mintAmount, isNative);
 }
 function redeemInternal(uint redeemTokens, bool isNative) internal nonReentrant returns (uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
 }
 return redeemFresh(msg.sender, redeemTokens, 0, isNative);
 }
 function redeemUnderlyingInternal(uint redeemAmount, bool isNative) internal nonReentrant returns (uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
 }
 return redeemFresh(msg.sender, 0, redeemAmount, isNative);
 }
 function borrowInternal(uint borrowAmount, bool isNative) internal nonReentrant returns (uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return fail(Error(error), FailureInfo.BORROW_ACCRUE_INTEREST_FAILED);
 }
 return borrowFresh(msg.sender, borrowAmount, isNative);
 }
 struct BorrowLocalVars {
 MathError mathErr;
 uint accountBorrows;
 uint accountBorrowsNew;
 uint totalBorrowsNew;
 }
 function borrowFresh(address payable borrower, uint borrowAmount, bool isNative) internal returns (uint) {
 uint allowed = comptroller.borrowAllowed(address(this), borrower, borrowAmount);
 if (allowed != 0) {
 return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.BORROW_COMPTROLLER_REJECTION, allowed);
 }
 if (borrowAmount == 0) {
 accountBorrows[borrower].interestIndex = borrowIndex;
 return uint(Error.NO_ERROR);
 }
 if (accrualBlockNumber != getBlockNumber()) {
 return fail(Error.MARKET_NOT_FRESH, FailureInfo.BORROW_FRESHNESS_CHECK);
 }
 if (getCashPrior() < borrowAmount) {
 return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.BORROW_CASH_NOT_AVAILABLE);
 }
 BorrowLocalVars memory vars;
 vars.accountBorrows = borrowBalanceStoredInternal(borrower);
 vars.accountBorrowsNew = add_(vars.accountBorrows, borrowAmount);
 vars.totalBorrowsNew = add_(totalBorrows, borrowAmount);
 doTransferOut(borrower, borrowAmount, isNative);
 accountBorrows[borrower].principal = vars.accountBorrowsNew;
 accountBorrows[borrower].interestIndex = borrowIndex;
 totalBorrows = vars.totalBorrowsNew;
 emit Borrow(borrower, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);
 return uint(Error.NO_ERROR);
 }
 function repayBorrowInternal(uint repayAmount, bool isNative) internal nonReentrant returns (uint, uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return (fail(Error(error), FailureInfo.REPAY_BORROW_ACCRUE_INTEREST_FAILED), 0);
 }
 return repayBorrowFresh(msg.sender, msg.sender, repayAmount, isNative);
 }
 function repayBorrowBehalfInternal(address borrower, uint repayAmount, bool isNative) internal nonReentrant returns (uint, uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return (fail(Error(error), FailureInfo.REPAY_BEHALF_ACCRUE_INTEREST_FAILED), 0);
 }
 return repayBorrowFresh(msg.sender, borrower, repayAmount, isNative);
 }
 struct RepayBorrowLocalVars {
 Error err;
 MathError mathErr;
 uint repayAmount;
 uint borrowerIndex;
 uint accountBorrows;
 uint accountBorrowsNew;
 uint totalBorrowsNew;
 uint actualRepayAmount;
 }
 function repayBorrowFresh(address payer, address borrower, uint repayAmount, bool isNative) internal returns (uint, uint) {
 uint allowed = comptroller.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
 if (allowed != 0) {
 return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REPAY_BORROW_COMPTROLLER_REJECTION, allowed), 0);
 }
 if (repayAmount == 0) {
 accountBorrows[borrower].interestIndex = borrowIndex;
 return (uint(Error.NO_ERROR), 0);
 }
 if (accrualBlockNumber != getBlockNumber()) {
 return (fail(Error.MARKET_NOT_FRESH, FailureInfo.REPAY_BORROW_FRESHNESS_CHECK), 0);
 }
 RepayBorrowLocalVars memory vars;
 vars.borrowerIndex = accountBorrows[borrower].interestIndex;
 vars.accountBorrows = borrowBalanceStoredInternal(borrower);
 if (repayAmount == uint(-1)) {
 vars.repayAmount = vars.accountBorrows;
 }
 else {
 vars.repayAmount = repayAmount;
 }
 vars.actualRepayAmount = doTransferIn(payer, vars.repayAmount, isNative);
 vars.accountBorrowsNew = sub_(vars.accountBorrows, vars.actualRepayAmount);
 vars.totalBorrowsNew = sub_(totalBorrows, vars.actualRepayAmount);
 accountBorrows[borrower].principal = vars.accountBorrowsNew;
 accountBorrows[borrower].interestIndex = borrowIndex;
 totalBorrows = vars.totalBorrowsNew;
 emit RepayBorrow(payer, borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);
 return (uint(Error.NO_ERROR), vars.actualRepayAmount);
 }
 function liquidateBorrowInternal(address borrower, uint repayAmount, CTokenInterface cTokenCollateral, bool isNative) internal nonReentrant returns (uint, uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED), 0);
 }
 error = cTokenCollateral.accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED), 0);
 }
 return liquidateBorrowFresh(msg.sender, borrower, repayAmount, cTokenCollateral, isNative);
 }
 function liquidateBorrowFresh(address liquidator, address borrower, uint repayAmount, CTokenInterface cTokenCollateral, bool isNative) internal returns (uint, uint) {
 uint allowed = comptroller.liquidateBorrowAllowed(address(this), address(cTokenCollateral), liquidator, borrower, repayAmount);
 if (allowed != 0) {
 return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_COMPTROLLER_REJECTION, allowed), 0);
 }
 if (accrualBlockNumber != getBlockNumber()) {
 return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_FRESHNESS_CHECK), 0);
 }
 if (cTokenCollateral.accrualBlockNumber() != getBlockNumber()) {
 return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_COLLATERAL_FRESHNESS_CHECK), 0);
 }
 if (borrower == liquidator) {
 return (fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_LIQUIDATOR_IS_BORROWER), 0);
 }
 if (repayAmount == 0) {
 return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_ZERO), 0);
 }
 if (repayAmount == uint(-1)) {
 return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX), 0);
 }
 (uint repayBorrowError, uint actualRepayAmount) = repayBorrowFresh(liquidator, borrower, repayAmount, isNative);
 if (repayBorrowError != uint(Error.NO_ERROR)) {
 return (fail(Error(repayBorrowError), FailureInfo.LIQUIDATE_REPAY_BORROW_FRESH_FAILED), 0);
 }
 (uint amountSeizeError, uint seizeTokens) = comptroller.liquidateCalculateSeizeTokens(address(this), address(cTokenCollateral), actualRepayAmount);
 require(amountSeizeError == uint(Error.NO_ERROR), "LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED");
 require(cTokenCollateral.balanceOf(borrower) >= seizeTokens, "LIQUIDATE_SEIZE_TOO_MUCH");
 uint seizeError;
 if (address(cTokenCollateral) == address(this)) {
 seizeError = seizeInternal(address(this), liquidator, borrower, seizeTokens);
 }
 else {
 seizeError = cTokenCollateral.seize(liquidator, borrower, seizeTokens);
 }
 require(seizeError == uint(Error.NO_ERROR), "token seizure failed");
 emit LiquidateBorrow(liquidator, borrower, actualRepayAmount, address(cTokenCollateral), seizeTokens);
 return (uint(Error.NO_ERROR), actualRepayAmount);
 }
 function seize(address liquidator, address borrower, uint seizeTokens) external nonReentrant returns (uint) {
 return seizeInternal(msg.sender, liquidator, borrower, seizeTokens);
 }
 function _setPendingAdmin(address payable newPendingAdmin) external returns (uint) {
 if (msg.sender != admin) {
 return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
 }
 address oldPendingAdmin = pendingAdmin;
 pendingAdmin = newPendingAdmin;
 emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
 return uint(Error.NO_ERROR);
 }
 function _acceptAdmin() external returns (uint) {
 if (msg.sender != pendingAdmin || msg.sender == address(0)) {
 return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
 }
 address oldAdmin = admin;
 address oldPendingAdmin = pendingAdmin;
 admin = pendingAdmin;
 pendingAdmin = address(0);
 emit NewAdmin(oldAdmin, admin);
 emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
 return uint(Error.NO_ERROR);
 }
 function _setComptroller(ComptrollerInterface newComptroller) public returns (uint) {
 if (msg.sender != admin) {
 return fail(Error.UNAUTHORIZED, FailureInfo.SET_COMPTROLLER_OWNER_CHECK);
 }
 ComptrollerInterface oldComptroller = comptroller;
 require(newComptroller.isComptroller(), "marker method returned false");
 comptroller = newComptroller;
 emit NewComptroller(oldComptroller, newComptroller);
 return uint(Error.NO_ERROR);
 }
 function _setReserveFactor(uint newReserveFactorMantissa) external nonReentrant returns (uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return fail(Error(error), FailureInfo.SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED);
 }
 return _setReserveFactorFresh(newReserveFactorMantissa);
 }
 function _setReserveFactorFresh(uint newReserveFactorMantissa) internal returns (uint) {
 if (msg.sender != admin) {
 return fail(Error.UNAUTHORIZED, FailureInfo.SET_RESERVE_FACTOR_ADMIN_CHECK);
 }
 if (accrualBlockNumber != getBlockNumber()) {
 return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_RESERVE_FACTOR_FRESH_CHECK);
 }
 if (newReserveFactorMantissa > reserveFactorMaxMantissa) {
 return fail(Error.BAD_INPUT, FailureInfo.SET_RESERVE_FACTOR_BOUNDS_CHECK);
 }
 uint oldReserveFactorMantissa = reserveFactorMantissa;
 reserveFactorMantissa = newReserveFactorMantissa;
 emit NewReserveFactor(oldReserveFactorMantissa, newReserveFactorMantissa);
 return uint(Error.NO_ERROR);
 }
 function _addReservesInternal(uint addAmount, bool isNative) internal nonReentrant returns (uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return fail(Error(error), FailureInfo.ADD_RESERVES_ACCRUE_INTEREST_FAILED);
 }
 (error, ) = _addReservesFresh(addAmount, isNative);
 return error;
 }
 function _addReservesFresh(uint addAmount, bool isNative) internal returns (uint, uint) {
 uint totalReservesNew;
 uint actualAddAmount;
 if (accrualBlockNumber != getBlockNumber()) {
 return (fail(Error.MARKET_NOT_FRESH, FailureInfo.ADD_RESERVES_FRESH_CHECK), actualAddAmount);
 }
 actualAddAmount = doTransferIn(msg.sender, addAmount, isNative);
 totalReservesNew = add_(totalReserves, actualAddAmount);
 totalReserves = totalReservesNew;
 emit ReservesAdded(msg.sender, actualAddAmount, totalReservesNew);
 return (uint(Error.NO_ERROR), actualAddAmount);
 }
 function _reduceReserves(uint reduceAmount) external nonReentrant returns (uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return fail(Error(error), FailureInfo.REDUCE_RESERVES_ACCRUE_INTEREST_FAILED);
 }
 return _reduceReservesFresh(reduceAmount);
 }
 function _reduceReservesFresh(uint reduceAmount) internal returns (uint) {
 uint totalReservesNew;
 if (msg.sender != admin) {
 return fail(Error.UNAUTHORIZED, FailureInfo.REDUCE_RESERVES_ADMIN_CHECK);
 }
 if (accrualBlockNumber != getBlockNumber()) {
 return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDUCE_RESERVES_FRESH_CHECK);
 }
 if (getCashPrior() < reduceAmount) {
 return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDUCE_RESERVES_CASH_NOT_AVAILABLE);
 }
 if (reduceAmount > totalReserves) {
 return fail(Error.BAD_INPUT, FailureInfo.REDUCE_RESERVES_VALIDATION);
 }
 totalReservesNew = sub_(totalReserves, reduceAmount);
 totalReserves = totalReservesNew;
 doTransferOut(admin, reduceAmount, true);
 emit ReservesReduced(admin, reduceAmount, totalReservesNew);
 return uint(Error.NO_ERROR);
 }
 function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint) {
 uint error = accrueInterest();
 if (error != uint(Error.NO_ERROR)) {
 return fail(Error(error), FailureInfo.SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED);
 }
 return _setInterestRateModelFresh(newInterestRateModel);
 }
 function _setInterestRateModelFresh(InterestRateModel newInterestRateModel) internal returns (uint) {
 InterestRateModel oldInterestRateModel;
 if (msg.sender != admin) {
 return fail(Error.UNAUTHORIZED, FailureInfo.SET_INTEREST_RATE_MODEL_OWNER_CHECK);
 }
 if (accrualBlockNumber != getBlockNumber()) {
 return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_INTEREST_RATE_MODEL_FRESH_CHECK);
 }
 oldInterestRateModel = interestRateModel;
 require(newInterestRateModel.isInterestRateModel(), "marker method returned false");
 interestRateModel = newInterestRateModel;
 emit NewMarketInterestRateModel(oldInterestRateModel, newInterestRateModel);
 return uint(Error.NO_ERROR);
 }
 function getCashPrior() internal view returns (uint);
 function doTransferIn(address from, uint amount, bool isNative) internal returns (uint);
 function doTransferOut(address payable to, uint amount, bool isNative) internal;
 function transferTokens(address spender, address src, address dst, uint tokens) internal returns (uint);
 function getCTokenBalanceInternal(address account) internal view returns (uint);
 function mintFresh(address minter, uint mintAmount, bool isNative) internal returns (uint, uint);
 function redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn, bool isNative) internal returns (uint);
 function seizeInternal(address seizerToken, address liquidator, address borrower, uint seizeTokens) internal returns (uint);
 modifier nonReentrant() {
 require(_notEntered, "re-entered");
 _notEntered = false;
 _;
 _notEntered = true;
 }
 }
 contract CCollateralCapStorage {
 uint256 public totalCollateralTokens;
 mapping (address => uint) public accountCollateralTokens;
 mapping (address => bool) public isCollateralTokenInit;
 uint256 public collateralCap;
 }
 contract CCapableErc20Interface is CErc20Interface, CSupplyCapStorage {
 uint public constant flashFeeBips = 3;
 event Flashloan(address indexed receiver, uint amount, uint totalFee, uint reservesFee);
 function gulp() external;
 function flashLoan(address receiver, uint amount, bytes calldata params) external;
 }
 contract ComptrollerV6Storage is ComptrollerV5Storage {
 mapping(address => bool) public flashloanGuardianPaused;
 }
 pragma solidity ^0.5.16;
 contract CErc20 is CToken, CErc20Interface {
 function initialize(address underlying_, ComptrollerInterface comptroller_, InterestRateModel interestRateModel_, uint initialExchangeRateMantissa_, string memory name_, string memory symbol_, uint8 decimals_) public {
 super.initialize(comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);
 underlying = underlying_;
 EIP20Interface(underlying).totalSupply();
 }
 function mint(uint mintAmount) external returns (uint) {
 (uint err,) = mintInternal(mintAmount, false);
 return err;
 }
 function redeem(uint redeemTokens) external returns (uint) {
 return redeemInternal(redeemTokens, false);
 }
 function redeemUnderlying(uint redeemAmount) external returns (uint) {
 return redeemUnderlyingInternal(redeemAmount, false);
 }
 function borrow(uint borrowAmount) external returns (uint) {
 return borrowInternal(borrowAmount, false);
 }
 function repayBorrow(uint repayAmount) external returns (uint) {
 (uint err,) = repayBorrowInternal(repayAmount, false);
 return err;
 }
 function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint) {
 (uint err,) = repayBorrowBehalfInternal(borrower, repayAmount, false);
 return err;
 }
 function liquidateBorrow(address borrower, uint repayAmount, CTokenInterface cTokenCollateral) external returns (uint) {
 (uint err,) = liquidateBorrowInternal(borrower, repayAmount, cTokenCollateral, false);
 return err;
 }
 function _addReserves(uint addAmount) external returns (uint) {
 return _addReservesInternal(addAmount, false);
 }
 function getCashPrior() internal view returns (uint) {
 EIP20Interface token = EIP20Interface(underlying);
 return token.balanceOf(address(this));
 }
 function doTransferIn(address from, uint amount, bool isNative) internal returns (uint) {
 isNative;
 EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
 uint balanceBefore = EIP20Interface(underlying).balanceOf(address(this));
 token.transferFrom(from, address(this), amount);
 bool success;
 assembly {
 switch returndatasize() case 0 {
 success := not(0) }
 case 32 {
 returndatacopy(0, 0, 32) success := mload(0) }
 default {
 revert(0, 0) }
 }
 require(success, "TOKEN_TRANSFER_IN_FAILED");
 uint balanceAfter = EIP20Interface(underlying).balanceOf(address(this));
 return sub_(balanceAfter, balanceBefore);
 }
 function doTransferOut(address payable to, uint amount, bool isNative) internal {
 isNative;
 EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
 token.transfer(to, amount);
 bool success;
 assembly {
 switch returndatasize() case 0 {
 success := not(0) }
 case 32 {
 returndatacopy(0, 0, 32) success := mload(0) }
 default {
 revert(0, 0) }
 }
 require(success, "TOKEN_TRANSFER_OUT_FAILED");
 }
 function transferTokens(address spender, address src, address dst, uint tokens) internal returns (uint) {
 uint allowed = comptroller.transferAllowed(address(this), src, dst, tokens);
 if (allowed != 0) {
 return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.TRANSFER_COMPTROLLER_REJECTION, allowed);
 }
 if (src == dst) {
 return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
 }
 uint startingAllowance = 0;
 if (spender == src) {
 startingAllowance = uint(-1);
 }
 else {
 startingAllowance = transferAllowances[src][spender];
 }
 accountTokens[src] = sub_(accountTokens[src], tokens);
 accountTokens[dst] = add_(accountTokens[dst], tokens);
 if (startingAllowance != uint(-1)) {
 transferAllowances[src][spender] = sub_(startingAllowance, tokens);
 }
 emit Transfer(src, dst, tokens);
 return uint(Error.NO_ERROR);
 }
 function getCTokenBalanceInternal(address account) internal view returns (uint) {
 return accountTokens[account];
 }
 struct MintLocalVars {
 uint exchangeRateMantissa;
 uint mintTokens;
 uint actualMintAmount;
 }
 function mintFresh(address minter, uint mintAmount, bool isNative) internal returns (uint, uint) {
 uint allowed = comptroller.mintAllowed(address(this), minter, mintAmount);
 if (allowed != 0) {
 return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.MINT_COMPTROLLER_REJECTION, allowed), 0);
 }
 if (mintAmount == 0) {
 return (uint(Error.NO_ERROR), 0);
 }
 if (accrualBlockNumber != getBlockNumber()) {
 return (fail(Error.MARKET_NOT_FRESH, FailureInfo.MINT_FRESHNESS_CHECK), 0);
 }
 MintLocalVars memory vars;
 vars.exchangeRateMantissa = exchangeRateStoredInternal();
 vars.actualMintAmount = doTransferIn(minter, mintAmount, isNative);
 vars.mintTokens = div_ScalarByExpTruncate(vars.actualMintAmount, Exp({
 mantissa: vars.exchangeRateMantissa}
 ));
 totalSupply = add_(totalSupply, vars.mintTokens);
 accountTokens[minter] = add_(accountTokens[minter], vars.mintTokens);
 emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
 emit Transfer(address(this), minter, vars.mintTokens);
 return (uint(Error.NO_ERROR), vars.actualMintAmount);
 }
 struct RedeemLocalVars {
 uint exchangeRateMantissa;
 uint redeemTokens;
 uint redeemAmount;
 uint totalSupplyNew;
 uint accountTokensNew;
 }
 function redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn, bool isNative) internal returns (uint) {
 require(redeemTokensIn == 0 || redeemAmountIn == 0, "one of redeemTokensIn or redeemAmountIn must be zero");
 RedeemLocalVars memory vars;
 vars.exchangeRateMantissa = exchangeRateStoredInternal();
 if (redeemTokensIn > 0) {
 vars.redeemTokens = redeemTokensIn;
 vars.redeemAmount = mul_ScalarTruncate(Exp({
 mantissa: vars.exchangeRateMantissa}
 ), redeemTokensIn);
 }
 else {
 vars.redeemTokens = div_ScalarByExpTruncate(redeemAmountIn, Exp({
 mantissa: vars.exchangeRateMantissa}
 ));
 vars.redeemAmount = redeemAmountIn;
 }
 uint allowed = comptroller.redeemAllowed(address(this), redeemer, vars.redeemTokens);
 if (allowed != 0) {
 return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REDEEM_COMPTROLLER_REJECTION, allowed);
 }
 if (redeemTokensIn == 0 && redeemAmountIn == 0) {
 return uint(Error.NO_ERROR);
 }
 if (accrualBlockNumber != getBlockNumber()) {
 return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDEEM_FRESHNESS_CHECK);
 }
 vars.totalSupplyNew = sub_(totalSupply, vars.redeemTokens);
 vars.accountTokensNew = sub_(accountTokens[redeemer], vars.redeemTokens);
 if (getCashPrior() < vars.redeemAmount) {
 return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDEEM_TRANSFER_OUT_NOT_POSSIBLE);
 }
 doTransferOut(redeemer, vars.redeemAmount, isNative);
 totalSupply = vars.totalSupplyNew;
 accountTokens[redeemer] = vars.accountTokensNew;
 emit Transfer(redeemer, address(this), vars.redeemTokens);
 emit Redeem(redeemer, vars.redeemAmount, vars.redeemTokens);
 comptroller.redeemVerify(address(this), redeemer, vars.redeemAmount, vars.redeemTokens);
 return uint(Error.NO_ERROR);
 }
 function seizeInternal(address seizerToken, address liquidator, address borrower, uint seizeTokens) internal returns (uint) {
 uint allowed = comptroller.seizeAllowed(address(this), seizerToken, liquidator, borrower, seizeTokens);
 if (allowed != 0) {
 return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_SEIZE_COMPTROLLER_REJECTION, allowed);
 }
 if (seizeTokens == 0) {
 return uint(Error.NO_ERROR);
 }
 if (borrower == liquidator) {
 return fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER);
 }
 accountTokens[borrower] = sub_(accountTokens[borrower], seizeTokens);
 accountTokens[liquidator] = add_(accountTokens[liquidator], seizeTokens);
 emit Transfer(borrower, liquidator, seizeTokens);
 return uint(Error.NO_ERROR);
 }
 }
 contract CWrappedNativeInterface is CErc20Interface {
 uint public constant flashFeeBips = 3;
 event Flashloan(address indexed receiver, uint amount, uint totalFee, uint reservesFee);
 function mintNative() external payable returns (uint);
 function redeemNative(uint redeemTokens) external returns (uint);
 function redeemUnderlyingNative(uint redeemAmount) external returns (uint);
 function borrowNative(uint borrowAmount) external returns (uint);
 function repayBorrowNative() external payable returns (uint);
 function repayBorrowBehalfNative(address borrower) external payable returns (uint);
 function liquidateBorrowNative(address borrower, CTokenInterface cTokenCollateral) external payable returns (uint);
 function flashLoan(address payable receiver, uint amount, bytes calldata params) external;
 function _addReservesNative() external payable returns (uint);
 }
 contract CCollateralCapErc20Interface is CCapableErc20Interface, CCollateralCapStorage {
 event NewCollateralCap(address token, uint newCap);
 event UserCollateralChanged(address account, uint newCollateralTokens);
 function registerCollateral(address account) external returns (uint);
 function unregisterCollateral(address account) external;
 function _setCollateralCap(uint newCollateralCap) external;
 }
 contract CDelegatorInterface {
 event NewImplementation(address oldImplementation, address newImplementation);
 function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public;
 }
 contract CDelegateInterface {
 function _becomeImplementation(bytes memory data) public;
 function _resignImplementation() public;
 }
 interface IFlashloanReceiver {
 function executeOperation(address sender, address underlying, uint amount, uint fee, bytes calldata params) external;
 }
 pragma solidity ^0.5.16;
 contract ComptrollerInterface {
 bool public constant isComptroller = true;
 function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
 function exitMarket(address cToken) external returns (uint);
 function mintAllowed(address cToken, address minter, uint mintAmount) external returns (uint);
 function mintVerify(address cToken, address minter, uint mintAmount, uint mintTokens) external;
 function redeemAllowed(address cToken, address redeemer, uint redeemTokens) external returns (uint);
 function redeemVerify(address cToken, address redeemer, uint redeemAmount, uint redeemTokens) external;
 function borrowAllowed(address cToken, address borrower, uint borrowAmount) external returns (uint);
 function borrowVerify(address cToken, address borrower, uint borrowAmount) external;
 function repayBorrowAllowed( address cToken, address payer, address borrower, uint repayAmount) external returns (uint);
 function repayBorrowVerify( address cToken, address payer, address borrower, uint repayAmount, uint borrowerIndex) external;
 function liquidateBorrowAllowed( address cTokenBorrowed, address cTokenCollateral, address liquidator, address borrower, uint repayAmount) external returns (uint);
 function liquidateBorrowVerify( address cTokenBorrowed, address cTokenCollateral, address liquidator, address borrower, uint repayAmount, uint seizeTokens) external;
 function seizeAllowed( address cTokenCollateral, address cTokenBorrowed, address liquidator, address borrower, uint seizeTokens) external returns (uint);
 function seizeVerify( address cTokenCollateral, address cTokenBorrowed, address liquidator, address borrower, uint seizeTokens) external;
 function transferAllowed(address cToken, address src, address dst, uint transferTokens) external returns (uint);
 function transferVerify(address cToken, address src, address dst, uint transferTokens) external;
 function liquidateCalculateSeizeTokens( address cTokenBorrowed, address cTokenCollateral, uint repayAmount) external view returns (uint, uint);
 }
 interface ComptrollerInterfaceExtension {
 function checkMembership(address account, CToken cToken) external view returns (bool);
 function updateCTokenVersion(address cToken, ComptrollerV2Storage.Version version) external;
 function flashloanAllowed(address cToken, address receiver, uint amount, bytes calldata params) external;
 }
 contract ComptrollerV7Storage is ComptrollerV6Storage {
 address public liquidityMining;
 }
 pragma solidity ^0.5.16;
 interface EIP20Interface {
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function decimals() external view returns (uint8);
 function totalSupply() external view returns (uint256);
 function balanceOf(address owner) external view returns (uint256 balance);
 function transfer(address dst, uint256 amount) external returns (bool success);
 function transferFrom(address src, address dst, uint256 amount) external returns (bool success);
 function approve(address spender, uint256 amount) external returns (bool success);
 function allowance(address owner, address spender) external view returns (uint256 remaining);
 event Transfer(address indexed from, address indexed to, uint256 amount);
 event Approval(address indexed owner, address indexed spender, uint256 amount);
 }
 pragma solidity ^0.5.16;
 interface EIP20NonStandardInterface {
 function totalSupply() external view returns (uint256);
 function balanceOf(address owner) external view returns (uint256 balance);
 function transfer(address dst, uint256 amount) external;
 function transferFrom(address src, address dst, uint256 amount) external;
 function approve(address spender, uint256 amount) external returns (bool success);
 function allowance(address owner, address spender) external view returns (uint256 remaining);
 event Transfer(address indexed from, address indexed to, uint256 amount);
 event Approval(address indexed owner, address indexed spender, uint256 amount);
 }
 pragma solidity ^0.5.16;
 contract ComptrollerErrorReporter {
 enum Error {
 NO_ERROR, UNAUTHORIZED, COMPTROLLER_MISMATCH, INSUFFICIENT_SHORTFALL, INSUFFICIENT_LIQUIDITY, INVALID_CLOSE_FACTOR, INVALID_COLLATERAL_FACTOR, INVALID_LIQUIDATION_INCENTIVE, MARKET_NOT_ENTERED, MARKET_NOT_LISTED, MARKET_ALREADY_LISTED, MATH_ERROR, NONZERO_BORROW_BALANCE, PRICE_ERROR, REJECTION, SNAPSHOT_ERROR, TOO_MANY_ASSETS, TOO_MUCH_REPAY }
 enum FailureInfo {
 ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK, EXIT_MARKET_BALANCE_OWED, EXIT_MARKET_REJECTION, SET_CLOSE_FACTOR_OWNER_CHECK, SET_CLOSE_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_NO_EXISTS, SET_COLLATERAL_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_WITHOUT_PRICE, SET_IMPLEMENTATION_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_VALIDATION, SET_MAX_ASSETS_OWNER_CHECK, SET_PENDING_ADMIN_OWNER_CHECK, SET_PENDING_IMPLEMENTATION_OWNER_CHECK, SET_PRICE_ORACLE_OWNER_CHECK, SUPPORT_MARKET_EXISTS, SUPPORT_MARKET_OWNER_CHECK, SET_PAUSE_GUARDIAN_OWNER_CHECK }
 event Failure(uint error, uint info, uint detail);
 function fail(Error err, FailureInfo info) internal returns (uint) {
 emit Failure(uint(err), uint(info), 0);
 return uint(err);
 }
 function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
 emit Failure(uint(err), uint(info), opaqueError);
 return uint(err);
 }
 }
 pragma solidity ^0.5.16;
 contract Comp {
 string public constant name = "Cream";
 string public constant symbol = "CREAM";
 uint8 public constant decimals = 18;
 uint public constant totalSupply = 9000000e18;
 mapping (address => mapping (address => uint96)) internal allowances;
 mapping (address => uint96) internal balances;
 mapping (address => address) public delegates;
 struct Checkpoint {
 uint32 fromBlock;
 uint96 votes;
 }
 mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;
 mapping (address => uint32) public numCheckpoints;
 bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
 bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
 mapping (address => uint) public nonces;
 event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
 event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
 event Transfer(address indexed from, address indexed to, uint256 amount);
 event Approval(address indexed owner, address indexed spender, uint256 amount);
 constructor(address account) public {
 balances[account] = uint96(totalSupply);
 emit Transfer(address(0), account, totalSupply);
 }
 function allowance(address account, address spender) external view returns (uint) {
 return allowances[account][spender];
 }
 function approve(address spender, uint rawAmount) external returns (bool) {
 uint96 amount;
 if (rawAmount == uint(-1)) {
 amount = uint96(-1);
 }
 else {
 amount = safe96(rawAmount, "Comp::approve: amount exceeds 96 bits");
 }
 allowances[msg.sender][spender] = amount;
 emit Approval(msg.sender, spender, amount);
 return true;
 }
 function balanceOf(address account) external view returns (uint) {
 return balances[account];
 }
 function transfer(address dst, uint rawAmount) external returns (bool) {
 uint96 amount = safe96(rawAmount, "Comp::transfer: amount exceeds 96 bits");
 _transferTokens(msg.sender, dst, amount);
 return true;
 }
 function transferFrom(address src, address dst, uint rawAmount) external returns (bool) {
 address spender = msg.sender;
 uint96 spenderAllowance = allowances[src][spender];
 uint96 amount = safe96(rawAmount, "Comp::approve: amount exceeds 96 bits");
 if (spender != src && spenderAllowance != uint96(-1)) {
 uint96 newAllowance = sub96(spenderAllowance, amount, "Comp::transferFrom: transfer amount exceeds spender allowance");
 allowances[src][spender] = newAllowance;
 emit Approval(src, spender, newAllowance);
 }
 _transferTokens(src, dst, amount);
 return true;
 }
 function delegate(address delegatee) public {
 return _delegate(msg.sender, delegatee);
 }
 function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {
 bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
 bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
 bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
 address signatory = ecrecover(digest, v, r, s);
 require(signatory != address(0), "Comp::delegateBySig: invalid signature");
 require(nonce == nonces[signatory]++, "Comp::delegateBySig: invalid nonce");
 require(now <= expiry, "Comp::delegateBySig: signature expired");
 return _delegate(signatory, delegatee);
 }
 function getCurrentVotes(address account) external view returns (uint96) {
 uint32 nCheckpoints = numCheckpoints[account];
 return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
 }
 function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {
 require(blockNumber < block.number, "Comp::getPriorVotes: not yet determined");
 uint32 nCheckpoints = numCheckpoints[account];
 if (nCheckpoints == 0) {
 return 0;
 }
 if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
 return checkpoints[account][nCheckpoints - 1].votes;
 }
 if (checkpoints[account][0].fromBlock > blockNumber) {
 return 0;
 }
 uint32 lower = 0;
 uint32 upper = nCheckpoints - 1;
 while (upper > lower) {
 uint32 center = upper - (upper - lower) / 2;
 Checkpoint memory cp = checkpoints[account][center];
 if (cp.fromBlock == blockNumber) {
 return cp.votes;
 }
 else if (cp.fromBlock < blockNumber) {
 lower = center;
 }
 else {
 upper = center - 1;
 }
 }
 return checkpoints[account][lower].votes;
 }
 function _delegate(address delegator, address delegatee) internal {
 address currentDelegate = delegates[delegator];
 uint96 delegatorBalance = balances[delegator];
 delegates[delegator] = delegatee;
 emit DelegateChanged(delegator, currentDelegate, delegatee);
 _moveDelegates(currentDelegate, delegatee, delegatorBalance);
 }
 function _transferTokens(address src, address dst, uint96 amount) internal {
 require(src != address(0), "Comp::_transferTokens: cannot transfer from the zero address");
 require(dst != address(0), "Comp::_transferTokens: cannot transfer to the zero address");
 balances[src] = sub96(balances[src], amount, "Comp::_transferTokens: transfer amount exceeds balance");
 balances[dst] = add96(balances[dst], amount, "Comp::_transferTokens: transfer amount overflows");
 emit Transfer(src, dst, amount);
 _moveDelegates(delegates[src], delegates[dst], amount);
 }
 function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {
 if (srcRep != dstRep && amount > 0) {
 if (srcRep != address(0)) {
 uint32 srcRepNum = numCheckpoints[srcRep];
 uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
 uint96 srcRepNew = sub96(srcRepOld, amount, "Comp::_moveVotes: vote amount underflows");
 _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
 }
 if (dstRep != address(0)) {
 uint32 dstRepNum = numCheckpoints[dstRep];
 uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
 uint96 dstRepNew = add96(dstRepOld, amount, "Comp::_moveVotes: vote amount overflows");
 _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
 }
 }
 }
 function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {
 uint32 blockNumber = safe32(block.number, "Comp::_writeCheckpoint: block number exceeds 32 bits");
 if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
 checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
 }
 else {
 checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
 numCheckpoints[delegatee] = nCheckpoints + 1;
 }
 emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
 }
 function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
 require(n < 2**32, errorMessage);
 return uint32(n);
 }
 function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {
 require(n < 2**96, errorMessage);
 return uint96(n);
 }
 function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
 uint96 c = a + b;
 require(c >= a, errorMessage);
 return c;
 }
 function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
 require(b <= a, errorMessage);
 return a - b;
 }
 function getChainId() internal pure returns (uint) {
 uint256 chainId;
 assembly {
 chainId := chainid() }
 return chainId;
 }
 }
 pragma solidity ^0.5.16;
 contract InterestRateModel {
 bool public constant isInterestRateModel = true;
 function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);
 function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);
 }
 pragma solidity ^0.5.16;
 interface ComptrollerLensInterface {
 function markets(address) external view returns (bool, uint, bool, uint);
 function oracle() external view returns (PriceOracle);
 function getAccountLiquidity(address) external view returns (uint, uint, uint);
 function getAssetsIn(address) external view returns (CToken[] memory);
 function checkMembership(address account, CToken cToken) external view returns (bool);
 function claimComp(address) external;
 function compAccrued(address) external view returns (uint);
 }
 interface CSLPInterface {
 function claimSushi(address) external returns (uint);
 }
 interface CCTokenInterface {
 function claimComp(address) external returns (uint);
 }
 contract CompoundLens {
 struct CTokenMetadata {
 address cToken;
 uint exchangeRateCurrent;
 uint supplyRatePerBlock;
 uint borrowRatePerBlock;
 uint reserveFactorMantissa;
 uint totalBorrows;
 uint totalReserves;
 uint totalSupply;
 uint totalCash;
 uint totalCollateralTokens;
 bool isListed;
 uint collateralFactorMantissa;
 address underlyingAssetAddress;
 uint cTokenDecimals;
 uint underlyingDecimals;
 uint version;
 uint collateralCap;
 uint underlyingPrice;
 }
 function cTokenMetadataInternal(CToken cToken, ComptrollerLensInterface comptroller, PriceOracle priceOracle) internal returns (CTokenMetadata memory) {
 uint exchangeRateCurrent = cToken.exchangeRateCurrent();
 (bool isListed, uint collateralFactorMantissa, , uint version) = comptroller.markets(address(cToken));
 address underlyingAssetAddress;
 uint underlyingDecimals;
 uint collateralCap;
 uint totalCollateralTokens;
 if (compareStrings(cToken.symbol(), "crETH")) {
 underlyingAssetAddress = address(0);
 underlyingDecimals = 18;
 }
 else {
 CErc20 cErc20 = CErc20(address(cToken));
 underlyingAssetAddress = cErc20.underlying();
 underlyingDecimals = EIP20Interface(cErc20.underlying()).decimals();
 }
 if (version == 1) {
 collateralCap = CCollateralCapErc20Interface(address(cToken)).collateralCap();
 totalCollateralTokens = CCollateralCapErc20Interface(address(cToken)).totalCollateralTokens();
 }
 return CTokenMetadata({
 cToken: address(cToken), exchangeRateCurrent: exchangeRateCurrent, supplyRatePerBlock: cToken.supplyRatePerBlock(), borrowRatePerBlock: cToken.borrowRatePerBlock(), reserveFactorMantissa: cToken.reserveFactorMantissa(), totalBorrows: cToken.totalBorrows(), totalReserves: cToken.totalReserves(), totalSupply: cToken.totalSupply(), totalCash: cToken.getCash(), totalCollateralTokens: totalCollateralTokens, isListed: isListed, collateralFactorMantissa: collateralFactorMantissa, underlyingAssetAddress: underlyingAssetAddress, cTokenDecimals: cToken.decimals(), underlyingDecimals: underlyingDecimals, version: version, collateralCap: collateralCap, underlyingPrice: priceOracle.getUnderlyingPrice(cToken) }
 );
 }
 function cTokenMetadata(CToken cToken) public returns (CTokenMetadata memory) {
 ComptrollerLensInterface comptroller = ComptrollerLensInterface(address(cToken.comptroller()));
 PriceOracle priceOracle = comptroller.oracle();
 return cTokenMetadataInternal(cToken, comptroller, priceOracle);
 }
 function cTokenMetadataAll(CToken[] calldata cTokens) external returns (CTokenMetadata[] memory) {
 uint cTokenCount = cTokens.length;
 require(cTokenCount > 0, "invalid input");
 CTokenMetadata[] memory res = new CTokenMetadata[](cTokenCount);
 ComptrollerLensInterface comptroller = ComptrollerLensInterface(address(cTokens[0].comptroller()));
 PriceOracle priceOracle = comptroller.oracle();
 for (uint i = 0; i < cTokenCount; i++) {
 require(address(comptroller) == address(cTokens[i].comptroller()), "mismatch comptroller");
 res[i] = cTokenMetadataInternal(cTokens[i], comptroller, priceOracle);
 }
 return res;
 }
 struct CTokenBalances {
 address cToken;
 uint balanceOf;
 uint borrowBalanceCurrent;
 uint balanceOfUnderlying;
 uint tokenBalance;
 uint tokenAllowance;
 uint collateralBalance;
 uint nativeTokenBalance;
 }
 function cTokenBalances(CToken cToken, address payable account) public returns (CTokenBalances memory) {
 uint balanceOf = cToken.balanceOf(account);
 uint borrowBalanceCurrent = cToken.borrowBalanceCurrent(account);
 uint balanceOfUnderlying = cToken.balanceOfUnderlying(account);
 address comptroller = address(cToken.comptroller());
 uint tokenBalance;
 uint tokenAllowance;
 uint collateralBalance;
 uint nativeTokenBalance = account.balance;
 if (compareStrings(cToken.symbol(), "crETH")) {
 tokenBalance = nativeTokenBalance;
 tokenAllowance = nativeTokenBalance;
 }
 else {
 CErc20 cErc20 = CErc20(address(cToken));
 EIP20Interface underlying = EIP20Interface(cErc20.underlying());
 tokenBalance = underlying.balanceOf(account);
 tokenAllowance = underlying.allowance(account, address(cToken));
 }
 if (ComptrollerLensInterface(comptroller).checkMembership(account, cToken)) {
 (, collateralBalance, , ) = cToken.getAccountSnapshot(account);
 }
 return CTokenBalances({
 cToken: address(cToken), balanceOf: balanceOf, borrowBalanceCurrent: borrowBalanceCurrent, balanceOfUnderlying: balanceOfUnderlying, tokenBalance: tokenBalance, tokenAllowance: tokenAllowance, collateralBalance: collateralBalance, nativeTokenBalance: nativeTokenBalance }
 );
 }
 function cTokenBalancesAll(CToken[] calldata cTokens, address payable account) external returns (CTokenBalances[] memory) {
 uint cTokenCount = cTokens.length;
 CTokenBalances[] memory res = new CTokenBalances[](cTokenCount);
 for (uint i = 0; i < cTokenCount; i++) {
 res[i] = cTokenBalances(cTokens[i], account);
 }
 return res;
 }
 struct CTokenUnderlyingPrice {
 address cToken;
 uint underlyingPrice;
 }
 function cTokenUnderlyingPrice(CToken cToken) public returns (CTokenUnderlyingPrice memory) {
 ComptrollerLensInterface comptroller = ComptrollerLensInterface(address(cToken.comptroller()));
 PriceOracle priceOracle = comptroller.oracle();
 return CTokenUnderlyingPrice({
 cToken: address(cToken), underlyingPrice: priceOracle.getUnderlyingPrice(cToken) }
 );
 }
 function cTokenUnderlyingPriceAll(CToken[] calldata cTokens) external returns (CTokenUnderlyingPrice[] memory) {
 uint cTokenCount = cTokens.length;
 CTokenUnderlyingPrice[] memory res = new CTokenUnderlyingPrice[](cTokenCount);
 for (uint i = 0; i < cTokenCount; i++) {
 res[i] = cTokenUnderlyingPrice(cTokens[i]);
 }
 return res;
 }
 struct AccountLimits {
 CToken[] markets;
 uint liquidity;
 uint shortfall;
 }
 function getAccountLimits(ComptrollerLensInterface comptroller, address account) public returns (AccountLimits memory) {
 (uint errorCode, uint liquidity, uint shortfall) = comptroller.getAccountLiquidity(account);
 require(errorCode == 0);
 return AccountLimits({
 markets: comptroller.getAssetsIn(account), liquidity: liquidity, shortfall: shortfall }
 );
 }
 struct CompBalanceMetadata {
 uint balance;
 uint votes;
 address delegate;
 }
 function getCompBalanceMetadata(Comp comp, address account) external view returns (CompBalanceMetadata memory) {
 return CompBalanceMetadata({
 balance: comp.balanceOf(account), votes: uint256(comp.getCurrentVotes(account)), delegate: comp.delegates(account) }
 );
 }
 struct CompBalanceMetadataExt {
 uint balance;
 uint votes;
 address delegate;
 uint allocated;
 }
 function getCompBalanceMetadataExt(Comp comp, ComptrollerLensInterface comptroller, address account) external returns (CompBalanceMetadataExt memory) {
 uint balance = comp.balanceOf(account);
 comptroller.claimComp(account);
 uint newBalance = comp.balanceOf(account);
 uint accrued = comptroller.compAccrued(account);
 uint total = add(accrued, newBalance, "sum comp total");
 uint allocated = sub(total, balance, "sub allocated");
 return CompBalanceMetadataExt({
 balance: balance, votes: uint256(comp.getCurrentVotes(account)), delegate: comp.delegates(account), allocated: allocated }
 );
 }
 struct CompVotes {
 uint blockNumber;
 uint votes;
 }
 function getCompVotes(Comp comp, address account, uint32[] calldata blockNumbers) external view returns (CompVotes[] memory) {
 CompVotes[] memory res = new CompVotes[](blockNumbers.length);
 for (uint i = 0; i < blockNumbers.length; i++) {
 res[i] = CompVotes({
 blockNumber: uint256(blockNumbers[i]), votes: uint256(comp.getPriorVotes(account, blockNumbers[i])) }
 );
 }
 return res;
 }
 function getClaimableSushiRewards(CSLPInterface[] calldata cTokens, address sushi, address account) external returns (uint[] memory) {
 uint cTokenCount = cTokens.length;
 uint[] memory rewards = new uint[](cTokenCount);
 for (uint i = 0; i < cTokenCount; i++) {
 uint balanceBefore = EIP20Interface(sushi).balanceOf(account);
 cTokens[i].claimSushi(account);
 uint balanceAfter = EIP20Interface(sushi).balanceOf(account);
 rewards[i] = sub(balanceAfter, balanceBefore, "subtraction underflow");
 }
 return rewards;
 }
 function getClaimableCompRewards(CCTokenInterface[] calldata cTokens, address comp, address account) external returns (uint[] memory) {
 uint cTokenCount = cTokens.length;
 uint[] memory rewards = new uint[](cTokenCount);
 for (uint i = 0; i < cTokenCount; i++) {
 uint balanceBefore = EIP20Interface(comp).balanceOf(account);
 cTokens[i].claimComp(account);
 uint balanceAfter = EIP20Interface(comp).balanceOf(account);
 rewards[i] = sub(balanceAfter, balanceBefore, "subtraction underflow");
 }
 return rewards;
 }
 function compareStrings(string memory a, string memory b) internal pure returns (bool) {
 return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
 }
 function add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
 uint c = a + b;
 require(c >= a, errorMessage);
 return c;
 }
 function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
 require(b <= a, errorMessage);
 uint c = a - b;
 return c;
 }
 }
 pragma solidity ^0.5.16;
 contract PriceOracle {
 bool public constant isPriceOracle = true;
 function getUnderlyingPrice(CToken cToken) external view returns (uint);
 }
