  pragma abicoder v2;
 pragma solidity ^0.7.6;
 struct FixedInflationEntryConfiguration {
 bool add;
 bool remove;
 FixedInflationEntry data;
 }
 struct FixedInflationEntry {
 uint256 lastBlock;
 bytes32 id;
 string name;
 uint256 blockInterval;
 uint256 callerRewardPercentage;
 }
 struct FixedInflationOperation {
 address inputTokenAddress;
 uint256 inputTokenAmount;
 bool inputTokenAmountIsPercentage;
 bool inputTokenAmountIsByMint;
 address ammPlugin;
 address[] liquidityPoolAddresses;
 address[] swapPath;
 bool enterInETH;
 bool exitInETH;
 address[] receivers;
 uint256[] receiversPercentages;
 }
 pragma solidity ^0.7.6;
 interface IFixedInflationExtension {
 function init(address host) external;
 function setHost(address host) external;
 function data() external view returns(address fixedInflationContract, address host);
 function receiveTokens(address[] memory tokenAddresses, uint256[] memory transferAmounts, uint256[] memory amountsToMint) external;
 function setEntries(FixedInflationEntryConfiguration[] memory newEntries, FixedInflationOperation[][] memory operationSets) external;
 }
 pragma solidity ^0.7.6;
 interface IERC20 {
 function totalSupply() external view returns(uint256);
 function balanceOf(address account) external view returns (uint256);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 function decimals() external view returns (uint8);
 }
 pragma solidity ^0.7.6;
 interface IERC20Mintable {
 function mint(address wallet, uint256 amount) external returns (bool);
 function burn(address wallet, uint256 amount) external returns (bool);
 }
 pragma solidity ^0.7.6;
 interface IFixedInflation {
 function setEntries(FixedInflationEntryConfiguration[] memory newEntries, FixedInflationOperation[][] memory operationSets) external;
 }
 pragma solidity ^0.7.6;
 contract FixedInflationExtension is IFixedInflationExtension {
 address private _host;
 address private _fixedInflationContract;
 modifier fixedInflationOnly() {
 require(_fixedInflationContract == msg.sender, "Unauthorized");
 _;
 }
 modifier hostOnly() {
 require(_host == msg.sender, "Unauthorized");
 _;
 }
 receive() external payable {
 }
 function init(address host) override public {
 require(_host == address(0), "Already init");
 _host = host;
 _fixedInflationContract = msg.sender;
 }
 function setHost(address host) public virtual override hostOnly {
 _host = host;
 }
 function data() view public override returns(address fixedInflationContract, address host) {
 return(_fixedInflationContract, _host);
 }
 function receiveTokens(address[] memory tokenAddresses, uint256[] memory transferAmounts, uint256[] memory amountsToMint) public override fixedInflationOnly {
 for(uint256 i = 0; i < tokenAddresses.length; i++) {
 if(transferAmounts[i] > 0) {
 if(tokenAddresses[i] == address(0)) {
 payable(msg.sender).transfer(transferAmounts[i]);
 continue;
 }
 _safeTransfer(tokenAddresses[i], msg.sender, transferAmounts[i]);
 }
 if(amountsToMint[i] > 0) {
 _mintAndTransfer(tokenAddresses[i], msg.sender, amountsToMint[i]);
 }
 }
 }
 function setEntries(FixedInflationEntryConfiguration[] memory newEntries, FixedInflationOperation[][] memory operationSets) public override hostOnly {
 IFixedInflation(_fixedInflationContract).setEntries(newEntries, operationSets);
 }
 function _mintAndTransfer(address erc20TokenAddress, address recipient, uint256 value) internal virtual {
 IERC20Mintable(erc20TokenAddress).mint(recipient, value);
 }
 function _safeTransfer(address erc20TokenAddress, address to, uint256 value) internal virtual {
 bytes memory returnData = _call(erc20TokenAddress, abi.encodeWithSelector(IERC20(erc20TokenAddress).transfer.selector, to, value));
 require(returnData.length == 0 || abi.decode(returnData, (bool)), 'TRANSFER_FAILED');
 }
 function _call(address location, bytes memory payload) private returns(bytes memory returnData) {
 assembly {
 let result := call(gas(), location, 0, add(payload, 0x20), mload(payload), 0, 0) let size := returndatasize() returnData := mload(0x40) mstore(returnData, size) let returnDataPayloadStart := add(returnData, 0x20) returndatacopy(returnDataPayloadStart, 0, size) mstore(0x40, add(returnDataPayloadStart, size)) switch result case 0 {
 revert(returnDataPayloadStart, size)}
 }
 }
 }
