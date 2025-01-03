  pragma abicoder v2;
 pragma solidity 0.7.6;
 contract RouterETH {
 address public immutable stargateEthVault;
 IStargateRouter public immutable stargateRouter;
 uint16 public immutable poolId;
 constructor(address _stargateEthVault, address _stargateRouter, uint16 _poolId){
 require(_stargateEthVault != address(0x0), "RouterETH: _stargateEthVault cant be 0x0");
 require(_stargateRouter != address(0x0), "RouterETH: _stargateRouter cant be 0x0");
 stargateEthVault = _stargateEthVault;
 stargateRouter = IStargateRouter(_stargateRouter);
 poolId = _poolId;
 }
 function addLiquidityETH() external payable {
 require(msg.value > 0, "Stargate: msg.value is 0");
 uint256 amountLD = msg.value;
 IStargateEthVault(stargateEthVault).deposit{
 value: amountLD}
 ();
 IStargateEthVault(stargateEthVault).approve(address(stargateRouter), amountLD);
 stargateRouter.addLiquidity( poolId, amountLD, msg.sender );
 }
 function swapETH( uint16 _dstChainId, address payable _refundAddress, bytes calldata _toAddress, uint256 _amountLD, uint256 _minAmountLD ) external payable {
 require(msg.value > _amountLD, "Stargate: msg.value must be > _amountLD");
 IStargateEthVault(stargateEthVault).deposit{
 value: _amountLD}
 ();
 IStargateEthVault(stargateEthVault).approve(address(stargateRouter), _amountLD);
 uint256 messageFee = msg.value - _amountLD;
 stargateRouter.swap{
 value: messageFee}
 ( _dstChainId, poolId, poolId, _refundAddress, _amountLD, _minAmountLD, IStargateRouter.lzTxObj(0, 0, "0x"), _toAddress, bytes("") );
 }
 receive() external payable {
 }
 }
 pragma solidity 0.7.6;
 interface IStargateRouter {
 struct lzTxObj {
 uint256 dstGasForCall;
 uint256 dstNativeAmount;
 bytes dstNativeAddr;
 }
 function addLiquidity( uint256 _poolId, uint256 _amountLD, address _to ) external;
 function swap( uint16 _dstChainId, uint256 _srcPoolId, uint256 _dstPoolId, address payable _refundAddress, uint256 _amountLD, uint256 _minAmountLD, lzTxObj memory _lzTxParams, bytes calldata _to, bytes calldata _payload ) external payable;
 function redeemRemote( uint16 _dstChainId, uint256 _srcPoolId, uint256 _dstPoolId, address payable _refundAddress, uint256 _amountLP, uint256 _minAmountLD, bytes calldata _to, lzTxObj memory _lzTxParams ) external payable;
 function instantRedeemLocal( uint16 _srcPoolId, uint256 _amountLP, address _to ) external returns (uint256);
 function redeemLocal( uint16 _dstChainId, uint256 _srcPoolId, uint256 _dstPoolId, address payable _refundAddress, uint256 _amountLP, bytes calldata _to, lzTxObj memory _lzTxParams ) external payable;
 function sendCredits( uint16 _dstChainId, uint256 _srcPoolId, uint256 _dstPoolId, address payable _refundAddress ) external payable;
 function quoteLayerZeroFee( uint16 _dstChainId, uint8 _functionType, bytes calldata _toAddress, bytes calldata _transferAndCallPayload, lzTxObj memory _lzTxParams ) external view returns (uint256, uint256);
 }
 pragma solidity 0.7.6;
 interface IStargateEthVault {
 function deposit() external payable;
 function transfer(address to, uint value) external returns (bool);
 function withdraw(uint) external;
 function approve(address guy, uint wad) external returns (bool);
 function transferFrom(address src, address dst, uint wad) external returns (bool);
 }
