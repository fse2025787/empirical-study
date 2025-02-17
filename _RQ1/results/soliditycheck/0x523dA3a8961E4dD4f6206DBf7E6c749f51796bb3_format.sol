         pragma solidity >=0.6.0 <0.8.0;
 abstract contract Context {
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
 }
 }
 pragma solidity >=0.6.0 <0.8.0;
 abstract contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor () internal {
 address msgSender = _msgSender();
 _owner = msgSender;
 emit OwnershipTransferred(address(0), msgSender);
 }
 function owner() public view virtual returns (address) {
 return _owner;
 }
 modifier onlyOwner() {
 require(owner() == _msgSender(), "Ownable: caller is not the owner");
 _;
 }
 function renounceOwnership() public virtual onlyOwner {
 emit OwnershipTransferred(_owner, address(0));
 _owner = address(0);
 }
 function transferOwnership(address newOwner) public virtual onlyOwner {
 require(newOwner != address(0), "Ownable: new owner is the zero address");
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;
 }
 }
 pragma solidity ^0.7.4;
 contract ACL is Ownable {
 mapping(address => bool) public pausableAdminSet;
 mapping(address => bool) public unpausableAdminSet;
 uint256 public constant version = 1;
 event PausableAdminAdded(address indexed newAdmin);
 event PausableAdminRemoved(address indexed admin);
 event UnpausableAdminAdded(address indexed newAdmin);
 event UnpausableAdminRemoved(address indexed admin);
 function addPausableAdmin(address newAdmin) external onlyOwner {
 pausableAdminSet[newAdmin] = true;
 emit PausableAdminAdded(newAdmin);
 }
 function removePausableAdmin(address admin) external onlyOwner {
 pausableAdminSet[admin] = false;
 emit PausableAdminRemoved(admin);
 }
 function isPausableAdmin(address addr) external view returns (bool) {
 return pausableAdminSet[addr];
 }
 function addUnpausableAdmin(address newAdmin) external onlyOwner {
 unpausableAdminSet[newAdmin] = true;
 emit UnpausableAdminAdded(newAdmin);
 }
 function removeUnpausableAdmin(address admin) external onlyOwner {
 unpausableAdminSet[admin] = false;
 emit UnpausableAdminRemoved(admin);
 }
 function isUnpausableAdmin(address addr) external view returns (bool) {
 return unpausableAdminSet[addr];
 }
 function isConfigurator(address account) external view returns (bool) {
 return account == owner();
 }
 }
 pragma solidity ^0.7.4;
 library Errors {
 string public constant ZERO_ADDRESS_IS_NOT_ALLOWED = "Z0";
 string public constant NOT_IMPLEMENTED = "NI";
 string public constant INCORRECT_PATH_LENGTH = "PL";
 string public constant INCORRECT_ARRAY_LENGTH = "CR";
 string public constant REGISTERED_CREDIT_ACCOUNT_MANAGERS_ONLY = "CP";
 string public constant REGISTERED_POOLS_ONLY = "RP";
 string public constant INCORRECT_PARAMETER = "IP";
 string public constant MATH_MULTIPLICATION_OVERFLOW = "M1";
 string public constant MATH_ADDITION_OVERFLOW = "M2";
 string public constant MATH_DIVISION_BY_ZERO = "M3";
 string public constant POOL_CONNECTED_CREDIT_MANAGERS_ONLY = "PS0";
 string public constant POOL_INCOMPATIBLE_CREDIT_ACCOUNT_MANAGER = "PS1";
 string public constant POOL_MORE_THAN_EXPECTED_LIQUIDITY_LIMIT = "PS2";
 string public constant POOL_INCORRECT_WITHDRAW_FEE = "SP3";
 string public constant POOL_CANT_ADD_CREDIT_MANAGER_TWICE = "PS4";
 string public constant CM_NO_OPEN_ACCOUNT = "CM1";
 string public constant CM_ZERO_ADDRESS_OR_USER_HAVE_ALREADY_OPEN_CREDIT_ACCOUNT = "CM2";
 string public constant CM_INCORRECT_AMOUNT = "CM3";
 string public constant CM_CAN_LIQUIDATE_WITH_SUCH_HEALTH_FACTOR = "CM4";
 string public constant CM_CAN_UPDATE_WITH_SUCH_HEALTH_FACTOR = "CM5";
 string public constant CM_WETH_GATEWAY_ONLY = "CM6";
 string public constant CM_INCORRECT_PARAMS = "CM7";
 string public constant CM_INCORRECT_FEES = "CM8";
 string public constant CM_MAX_LEVERAGE_IS_TOO_HIGH = "CM9";
 string public constant CM_CANT_CLOSE_WITH_LOSS = "CMA";
 string public constant CM_TARGET_CONTRACT_iS_NOT_ALLOWED = "CMB";
 string public constant CM_TRANSFER_FAILED = "CMC";
 string public constant CM_INCORRECT_NEW_OWNER = "CME";
 string public constant AF_CANT_CLOSE_CREDIT_ACCOUNT_IN_THE_SAME_BLOCK = "AF1";
 string public constant AF_MINING_IS_FINISHED = "AF2";
 string public constant AF_CREDIT_ACCOUNT_NOT_IN_STOCK = "AF3";
 string public constant AF_EXTERNAL_ACCOUNTS_ARE_FORBIDDEN = "AF4";
 string public constant AS_ADDRESS_NOT_FOUND = "AP1";
 string public constant CR_POOL_ALREADY_ADDED = "CR1";
 string public constant CR_CREDIT_MANAGER_ALREADY_ADDED = "CR2";
 string public constant CF_UNDERLYING_TOKEN_FILTER_CONFLICT = "CF0";
 string public constant CF_INCORRECT_LIQUIDATION_THRESHOLD = "CF1";
 string public constant CF_TOKEN_IS_NOT_ALLOWED = "CF2";
 string public constant CF_CREDIT_MANAGERS_ONLY = "CF3";
 string public constant CF_ADAPTERS_ONLY = "CF4";
 string public constant CF_OPERATION_LOW_HEALTH_FACTOR = "CF5";
 string public constant CF_TOO_MUCH_ALLOWED_TOKENS = "CF6";
 string public constant CF_INCORRECT_CHI_THRESHOLD = "CF7";
 string public constant CF_INCORRECT_FAST_CHECK = "CF8";
 string public constant CF_NON_TOKEN_CONTRACT = "CF9";
 string public constant CF_CONTRACT_IS_NOT_IN_ALLOWED_LIST = "CFA";
 string public constant CF_FAST_CHECK_NOT_COVERED_COLLATERAL_DROP = "CFB";
 string public constant CF_SOME_LIQUIDATION_THRESHOLD_MORE_THAN_NEW_ONE = "CFC";
 string public constant CF_ADAPTER_CAN_BE_USED_ONLY_ONCE = "CFD";
 string public constant CF_INCORRECT_PRICEFEED = "CFE";
 string public constant CF_TRANSFER_IS_NOT_ALLOWED = "CFF";
 string public constant CF_CREDIT_MANAGER_IS_ALREADY_SET = "CFG";
 string public constant CA_CONNECTED_CREDIT_MANAGER_ONLY = "CA1";
 string public constant CA_FACTORY_ONLY = "CA2";
 string public constant PO_PRICE_FEED_DOESNT_EXIST = "PO0";
 string public constant PO_TOKENS_WITH_DECIMALS_MORE_18_ISNT_ALLOWED = "PO1";
 string public constant PO_AGGREGATOR_DECIMALS_SHOULD_BE_18 = "PO2";
 string public constant ACL_CALLER_NOT_PAUSABLE_ADMIN = "ACL1";
 string public constant ACL_CALLER_NOT_CONFIGURATOR = "ACL2";
 string public constant WG_DESTINATION_IS_NOT_WETH_COMPATIBLE = "WG1";
 string public constant WG_RECEIVE_IS_NOT_ALLOWED = "WG2";
 string public constant WG_NOT_ENOUGH_FUNDS = "WG3";
 string public constant LA_INCORRECT_VALUE = "LA1";
 string public constant LA_HAS_VALUE_WITH_TOKEN_TRANSFER = "LA2";
 string public constant LA_UNKNOWN_SWAP_INTERFACE = "LA3";
 string public constant LA_UNKNOWN_LP_INTERFACE = "LA4";
 string public constant LA_LOWER_THAN_AMOUNT_MIN = "LA5";
 string public constant LA_TOKEN_OUT_IS_NOT_COLLATERAL = "LA6";
 string public constant YPF_PRICE_PER_SHARE_OUT_OF_RANGE = "YP1";
 string public constant YPF_INCORRECT_LIMITER_PARAMETERS = "YP2";
 string public constant TD_WALLET_IS_ALREADY_CONNECTED_TO_VC = "TD1";
 string public constant TD_INCORRECT_WEIGHTS = "TD2";
 string public constant TD_NON_ZERO_BALANCE_AFTER_DISTRIBUTION = "TD3";
 string public constant TD_CONTRIBUTOR_IS_NOT_REGISTERED = "TD4";
 }
