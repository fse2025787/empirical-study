  pragma abicoder v2;
 pragma experimental ABIEncoderV2;
 pragma solidity 0.7.6;
 contract ReentrancyGuard {
 uint256 private constant _NOT_ENTERED = 1;
 uint256 private constant _ENTERED = 2;
 uint256 private _status;
 constructor () {
 _status = _NOT_ENTERED;
 }
 modifier nonReentrant() {
 require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
 _status = _ENTERED;
 _;
 _status = _NOT_ENTERED;
 }
 }
 pragma solidity 0.7.6;
 contract LiquidationAuction02 is ReentrancyGuard {
 using SafeMath for uint;
 IVault public immutable vault;
 IVaultManagerParameters public immutable vaultManagerParameters;
 ICDPRegistry public immutable cdpRegistry;
 IForceTransferAssetStore public immutable forceTransferAssetStore;
 uint public constant DENOMINATOR_1E2 = 1e2;
 uint public constant WRAPPED_TO_UNDERLYING_ORACLE_TYPE = 11;
 event Buyout(address indexed asset, address indexed owner, address indexed buyer, uint amount, uint price, uint penalty);
 modifier checkpoint(address asset, address owner) {
 _;
 cdpRegistry.checkpoint(asset, owner);
 }
 constructor(address _vaultManagerParameters, address _cdpRegistry, address _forceTransferAssetStore) {
 require( _vaultManagerParameters != address(0) && _forceTransferAssetStore != (address(0)), "Unit Protocol: INVALID_ARGS" );
 vaultManagerParameters = IVaultManagerParameters(_vaultManagerParameters);
 vault = IVault(IVaultParameters(IVaultManagerParameters(_vaultManagerParameters).vaultParameters()).vault());
 cdpRegistry = ICDPRegistry(_cdpRegistry);
 forceTransferAssetStore = IForceTransferAssetStore(_forceTransferAssetStore);
 }
 function buyout(address asset, address owner) public nonReentrant checkpoint(asset, owner) {
 require(vault.liquidationBlock(asset, owner) != 0, "Unit Protocol: LIQUIDATION_NOT_TRIGGERED");
 uint startingPrice = vault.liquidationPrice(asset, owner);
 uint blocksPast = block.number.sub(vault.liquidationBlock(asset, owner));
 uint depreciationPeriod = vaultManagerParameters.devaluationPeriod(asset);
 uint debt = vault.getTotalDebt(asset, owner);
 uint penalty = debt.mul(vault.liquidationFee(asset, owner)).div(DENOMINATOR_1E2);
 uint collateralInPosition = vault.collaterals(asset, owner);
 uint collateralToLiquidator;
 uint collateralToOwner;
 uint repayment;
 (collateralToLiquidator, collateralToOwner, repayment) = _calcLiquidationParams( depreciationPeriod, blocksPast, startingPrice, debt.add(penalty), collateralInPosition );
 if (collateralToOwner == 0 && forceTransferAssetStore.shouldForceTransfer(asset)) {
 collateralToOwner = 1;
 collateralToLiquidator = collateralToLiquidator.sub(1);
 }
 _liquidate( asset, owner, collateralToLiquidator, collateralToOwner, repayment, penalty );
 }
 function _liquidate( address asset, address user, uint collateralToBuyer, uint collateralToOwner, uint repayment, uint penalty ) private {
 vault.liquidate( asset, user, collateralToBuyer, 0, collateralToOwner, 0, repayment, penalty, msg.sender );
 uint fee = repayment > penalty ? penalty : repayment;
 IFoundation(IVaultParameters(vaultManagerParameters.vaultParameters()).foundation()).submitLiquidationFee(fee);
 emit Buyout(asset, user, msg.sender, collateralToBuyer, repayment, penalty);
 }
 function _calcLiquidationParams( uint depreciationPeriod, uint blocksPast, uint startingPrice, uint debtWithPenalty, uint collateralInPosition ) internal pure returns( uint collateralToBuyer, uint collateralToOwner, uint price ) {
 if (depreciationPeriod > blocksPast) {
 uint valuation = depreciationPeriod.sub(blocksPast);
 uint collateralPrice = startingPrice.mul(valuation).div(depreciationPeriod);
 if (collateralPrice > debtWithPenalty) {
 collateralToBuyer = collateralInPosition.mul(debtWithPenalty).div(collateralPrice);
 collateralToOwner = collateralInPosition.sub(collateralToBuyer);
 price = debtWithPenalty;
 }
 else {
 collateralToBuyer = collateralInPosition;
 price = collateralPrice;
 }
 }
 else {
 collateralToBuyer = collateralInPosition;
 }
 }
 }
 pragma solidity 0.7.6;
 library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
 if (a == 0) {
 return 0;
 }
 c = a * b;
 assert(c / a == b);
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b != 0, "SafeMath: division by zero");
 return a / b;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 assert(b <= a);
 return a - b;
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
 c = a + b;
 assert(c >= a);
 return c;
 }
 }
 pragma solidity ^0.7.6;
 interface IFoundation {
 function submitLiquidationFee(uint fee) external;
 }
 pragma solidity ^0.7.6;
 interface IForceTransferAssetStore {
 function shouldForceTransfer ( address ) external view returns ( bool );
 function add ( address asset ) external;
 }
 pragma solidity ^0.7.6;
 interface IWrappedToUnderlyingOracle {
 function assetToUnderlying(address) external view returns (address);
 }
 pragma solidity ^0.7.6;
 interface IVaultParameters {
 function canModifyVault ( address ) external view returns ( bool );
 function foundation ( ) external view returns ( address );
 function isManager ( address ) external view returns ( bool );
 function isOracleTypeEnabled ( uint256, address ) external view returns ( bool );
 function liquidationFee ( address ) external view returns ( uint256 );
 function setCollateral ( address asset, uint256 stabilityFeeValue, uint256 liquidationFeeValue, uint256 usdpLimit, uint256[] calldata oracles ) external;
 function setFoundation ( address newFoundation ) external;
 function setLiquidationFee ( address asset, uint256 newValue ) external;
 function setManager ( address who, bool permit ) external;
 function setOracleType ( uint256 _type, address asset, bool enabled ) external;
 function setStabilityFee ( address asset, uint256 newValue ) external;
 function setTokenDebtLimit ( address asset, uint256 limit ) external;
 function setVaultAccess ( address who, bool permit ) external;
 function stabilityFee ( address ) external view returns ( uint256 );
 function tokenDebtLimit ( address ) external view returns ( uint256 );
 function vault ( ) external view returns ( address );
 function vaultParameters ( ) external view returns ( address );
 }
 pragma solidity ^0.7.6;
 interface IVaultManagerParameters {
 function devaluationPeriod ( address ) external view returns ( uint256 );
 function initialCollateralRatio ( address ) external view returns ( uint256 );
 function liquidationDiscount ( address ) external view returns ( uint256 );
 function liquidationRatio ( address ) external view returns ( uint256 );
 function maxColPercent ( address ) external view returns ( uint256 );
 function minColPercent ( address ) external view returns ( uint256 );
 function setColPartRange ( address asset, uint256 min, uint256 max ) external;
 function setCollateral ( address asset, uint256 stabilityFeeValue, uint256 liquidationFeeValue, uint256 initialCollateralRatioValue, uint256 liquidationRatioValue, uint256 liquidationDiscountValue, uint256 devaluationPeriodValue, uint256 usdpLimit, uint256[] calldata oracles, uint256 minColP, uint256 maxColP ) external;
 function setDevaluationPeriod ( address asset, uint256 newValue ) external;
 function setInitialCollateralRatio ( address asset, uint256 newValue ) external;
 function setLiquidationDiscount ( address asset, uint256 newValue ) external;
 function setLiquidationRatio ( address asset, uint256 newValue ) external;
 function vaultParameters ( ) external view returns ( address );
 }
 pragma solidity ^0.7.6;
 interface ICDPRegistry {
 struct CDP {
 address asset;
 address owner;
 }
 function batchCheckpoint ( address[] calldata assets, address[] calldata owners ) external;
 function batchCheckpointForAsset ( address asset, address[] calldata owners ) external;
 function checkpoint ( address asset, address owner ) external;
 function cr ( ) external view returns ( address );
 function getAllCdps ( ) external view returns ( CDP[] memory r );
 function getCdpsByCollateral ( address asset ) external view returns ( CDP[] memory cdps );
 function getCdpsByOwner ( address owner ) external view returns ( CDP[] memory r );
 function getCdpsCount ( ) external view returns ( uint256 totalCdpCount );
 function getCdpsCountForCollateral ( address asset ) external view returns ( uint256 );
 function isAlive ( address asset, address owner ) external view returns ( bool );
 function isListed ( address asset, address owner ) external view returns ( bool );
 function vault ( ) external view returns ( address );
 }
 pragma solidity ^0.7.6;
 interface IVault {
 function DENOMINATOR_1E2 ( ) external view returns ( uint256 );
 function DENOMINATOR_1E5 ( ) external view returns ( uint256 );
 function borrow ( address asset, address user, uint256 amount ) external returns ( uint256 );
 function calculateFee ( address asset, address user, uint256 amount ) external view returns ( uint256 );
 function changeOracleType ( address asset, address user, uint256 newOracleType ) external;
 function chargeFee ( address asset, address user, uint256 amount ) external;
 function col ( ) external view returns ( address );
 function colToken ( address, address ) external view returns ( uint256 );
 function collaterals ( address, address ) external view returns ( uint256 );
 function debts ( address, address ) external view returns ( uint256 );
 function depositCol ( address asset, address user, uint256 amount ) external;
 function depositEth ( address user ) external payable;
 function depositMain ( address asset, address user, uint256 amount ) external;
 function destroy ( address asset, address user ) external;
 function getTotalDebt ( address asset, address user ) external view returns ( uint256 );
 function lastUpdate ( address, address ) external view returns ( uint256 );
 function liquidate ( address asset, address positionOwner, uint256 mainAssetToLiquidator, uint256 colToLiquidator, uint256 mainAssetToPositionOwner, uint256 colToPositionOwner, uint256 repayment, uint256 penalty, address liquidator ) external;
 function liquidationBlock ( address, address ) external view returns ( uint256 );
 function liquidationFee ( address, address ) external view returns ( uint256 );
 function liquidationPrice ( address, address ) external view returns ( uint256 );
 function oracleType ( address, address ) external view returns ( uint256 );
 function repay ( address asset, address user, uint256 amount ) external returns ( uint256 );
 function spawn ( address asset, address user, uint256 _oracleType ) external;
 function stabilityFee ( address, address ) external view returns ( uint256 );
 function tokenDebts ( address ) external view returns ( uint256 );
 function triggerLiquidation ( address asset, address positionOwner, uint256 initialPrice ) external;
 function update ( address asset, address user ) external;
 function usdp ( ) external view returns ( address );
 function vaultParameters ( ) external view returns ( address );
 function weth ( ) external view returns ( address payable );
 function withdrawCol ( address asset, address user, uint256 amount ) external;
 function withdrawEth ( address user, uint256 amount ) external;
 function withdrawMain ( address asset, address user, uint256 amount ) external;
 }
 pragma solidity ^0.7.6;
 interface IOracleRegistry {
 struct Oracle {
 uint oracleType;
 address oracleAddress;
 }
 function WETH ( ) external view returns ( address );
 function getKeydonixOracleTypes ( ) external view returns ( uint256[] memory );
 function getOracles ( ) external view returns ( Oracle[] memory foundOracles );
 function keydonixOracleTypes ( uint256 ) external view returns ( uint256 );
 function maxOracleType ( ) external view returns ( uint256 );
 function oracleByAsset ( address asset ) external view returns ( address );
 function oracleByType ( uint256 ) external view returns ( address );
 function oracleTypeByAsset ( address ) external view returns ( uint256 );
 function oracleTypeByOracle ( address ) external view returns ( uint256 );
 function setKeydonixOracleTypes ( uint256[] memory _keydonixOracleTypes ) external;
 function setOracle ( uint256 oracleType, address oracle ) external;
 function setOracleTypeForAsset ( address asset, uint256 oracleType ) external;
 function setOracleTypeForAssets ( address[] memory assets, uint256 oracleType ) external;
 function unsetOracle ( uint256 oracleType ) external;
 function unsetOracleForAsset ( address asset ) external;
 function unsetOracleForAssets ( address[] memory assets ) external;
 function vaultParameters ( ) external view returns ( address );
 }
