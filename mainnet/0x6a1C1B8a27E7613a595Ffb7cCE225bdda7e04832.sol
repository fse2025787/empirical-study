// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-02-09
*/

// 

pragma solidity =0.8.10;





abstract contract IDFSRegistry {
 
    function getAddr(bytes4 _id) public view virtual returns (address);

    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public virtual;

    function startContractChange(bytes32 _id, address _newContractAddr) public virtual;

    function approveContractChange(bytes32 _id) public virtual;

    function cancelContractChange(bytes32 _id) public virtual;

    function changeWaitPeriod(bytes32 _id, uint256 _newWaitPeriod) public virtual;
}





interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256 digits);
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}





library Address {
    //insufficient balance
    error InsufficientBalance(uint256 available, uint256 required);
    //unable to send value, recipient may have reverted
    error SendingValueFail();
    //insufficient balance for call
    error InsufficientBalanceForCall(uint256 available, uint256 required);
    //call to non-contract
    error NonContractCall();
    
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        uint256 balance = address(this).balance;
        if (balance < amount){
            revert InsufficientBalance(balance, amount);
        }

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        if (!(success)){
            revert SendingValueFail();
        }
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        uint256 balance = address(this).balance;
        if (balance < value){
            revert InsufficientBalanceForCall(balance, value);
        }
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        if (!(isContract(target))){
            revert NonContractCall();
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}







library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





contract MainnetAuthAddresses {
    address internal constant ADMIN_VAULT_ADDR = 0xCCf3d848e08b94478Ed8f46fFead3008faF581fD;
    address internal constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;
    address internal constant ADMIN_ADDR = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9; // USED IN ADMIN VAULT CONSTRUCTOR
}





contract AuthHelper is MainnetAuthAddresses {
}





contract AdminVault is AuthHelper {
    address public owner;
    address public admin;

    error SenderNotAdmin();

    constructor() {
        owner = msg.sender;
        admin = ADMIN_ADDR;
    }

    
    
    function changeOwner(address _owner) public {
        if (admin != msg.sender){
            revert SenderNotAdmin();
        }
        owner = _owner;
    }

    
    
    function changeAdmin(address _admin) public {
        if (admin != msg.sender){
            revert SenderNotAdmin();
        }
        admin = _admin;
    }

}








contract AdminAuth is AuthHelper {
    using SafeERC20 for IERC20;

    AdminVault public constant adminVault = AdminVault(ADMIN_VAULT_ADDR);

    error SenderNotOwner();
    error SenderNotAdmin();

    modifier onlyOwner() {
        if (adminVault.owner() != msg.sender){
            revert SenderNotOwner();
        }
        _;
    }

    modifier onlyAdmin() {
        if (adminVault.admin() != msg.sender){
            revert SenderNotAdmin();
        }
        _;
    }

    
    function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {
        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(_receiver).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    
    function kill() public onlyAdmin {
        selfdestruct(payable(msg.sender));
    }
}





contract DFSRegistry is AdminAuth {
    error EntryAlreadyExistsError(bytes4);
    error EntryNonExistentError(bytes4);
    error EntryNotInChangeError(bytes4);
    error ChangeNotReadyError(uint256,uint256);
    error EmptyPrevAddrError(bytes4);
    error AlreadyInContractChangeError(bytes4);
    error AlreadyInWaitPeriodChangeError(bytes4);

    event AddNewContract(address,bytes4,address,uint256);
    event RevertToPreviousAddress(address,bytes4,address,address);
    event StartContractChange(address,bytes4,address,address);
    event ApproveContractChange(address,bytes4,address,address);
    event CancelContractChange(address,bytes4,address,address);
    event StartWaitPeriodChange(address,bytes4,uint256);
    event ApproveWaitPeriodChange(address,bytes4,uint256,uint256);
    event CancelWaitPeriodChange(address,bytes4,uint256,uint256);

    struct Entry {
        address contractAddr;
        uint256 waitPeriod;
        uint256 changeStartTime;
        bool inContractChange;
        bool inWaitPeriodChange;
        bool exists;
    }

    mapping(bytes4 => Entry) public entries;
    mapping(bytes4 => address) public previousAddresses;

    mapping(bytes4 => address) public pendingAddresses;
    mapping(bytes4 => uint256) public pendingWaitTimes;

    
    
    
    function getAddr(bytes4 _id) public view returns (address) {
        return entries[_id].contractAddr;
    }

    
    
    function isRegistered(bytes4 _id) public view returns (bool) {
        return entries[_id].exists;
    }

    /////////////////////////// OWNER ONLY FUNCTIONS ///////////////////////////

    
    
    
    
    function addNewContract(
        bytes4 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public onlyOwner {
        if (entries[_id].exists){
            revert EntryAlreadyExistsError(_id);
        }

        entries[_id] = Entry({
            contractAddr: _contractAddr,
            waitPeriod: _waitPeriod,
            changeStartTime: 0,
            inContractChange: false,
            inWaitPeriodChange: false,
            exists: true
        });

        emit AddNewContract(msg.sender, _id, _contractAddr, _waitPeriod);
    }

    
    
    
    function revertToPreviousAddress(bytes4 _id) public onlyOwner {
        if (!(entries[_id].exists)){
            revert EntryNonExistentError(_id);
        }
        if (previousAddresses[_id] == address(0)){
            revert EmptyPrevAddrError(_id);
        }

        address currentAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = previousAddresses[_id];

        emit RevertToPreviousAddress(msg.sender, _id, currentAddr, previousAddresses[_id]);
    }

    
    
    
    
    function startContractChange(bytes4 _id, address _newContractAddr) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (entries[_id].inWaitPeriodChange){
            revert AlreadyInWaitPeriodChangeError(_id);
        }

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inContractChange = true;

        pendingAddresses[_id] = _newContractAddr;

        emit StartContractChange(msg.sender, _id, entries[_id].contractAddr, _newContractAddr);
    }

    
    
    function approveContractChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inContractChange){
            revert EntryNotInChangeError(_id);
        }
        if (block.timestamp < (entries[_id].changeStartTime + entries[_id].waitPeriod)){// solhint-disable-line
            revert ChangeNotReadyError(block.timestamp, (entries[_id].changeStartTime + entries[_id].waitPeriod));
        }

        address oldContractAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = pendingAddresses[_id];
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        pendingAddresses[_id] = address(0);
        previousAddresses[_id] = oldContractAddr;

        emit ApproveContractChange(msg.sender, _id, oldContractAddr, entries[_id].contractAddr);
    }

    
    
    function cancelContractChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inContractChange){
            revert EntryNotInChangeError(_id);
        }

        address oldContractAddr = pendingAddresses[_id];

        pendingAddresses[_id] = address(0);
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        emit CancelContractChange(msg.sender, _id, oldContractAddr, entries[_id].contractAddr);
    }

    
    
    
    function startWaitPeriodChange(bytes4 _id, uint256 _newWaitPeriod) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (entries[_id].inContractChange){
            revert AlreadyInContractChangeError(_id);
        }

        pendingWaitTimes[_id] = _newWaitPeriod;

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inWaitPeriodChange = true;

        emit StartWaitPeriodChange(msg.sender, _id, _newWaitPeriod);
    }

    
    
    function approveWaitPeriodChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inWaitPeriodChange){
            revert EntryNotInChangeError(_id);
        }
        if (block.timestamp < (entries[_id].changeStartTime + entries[_id].waitPeriod)){ // solhint-disable-line
            revert ChangeNotReadyError(block.timestamp, (entries[_id].changeStartTime + entries[_id].waitPeriod));
        }

        uint256 oldWaitTime = entries[_id].waitPeriod;
        entries[_id].waitPeriod = pendingWaitTimes[_id];
        
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        pendingWaitTimes[_id] = 0;

        emit ApproveWaitPeriodChange(msg.sender, _id, oldWaitTime, entries[_id].waitPeriod);
    }

    
    
    function cancelWaitPeriodChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inWaitPeriodChange){
            revert EntryNotInChangeError(_id);
        }

        uint256 oldWaitPeriod = pendingWaitTimes[_id];

        pendingWaitTimes[_id] = 0;
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        emit CancelWaitPeriodChange(msg.sender, _id, oldWaitPeriod, entries[_id].waitPeriod);
    }
}





contract StrategyModel {

    bytes4 constant STRATEGY_STORAGE_ID = bytes4(keccak256("StrategyStorage"));
    bytes4 constant SUB_STORAGE_ID = bytes4(keccak256("SubStorage"));
    bytes4 constant BUNDLE_STORAGE_ID = bytes4(keccak256("BundleStorage"));
        
    
    
    
    struct StrategyBundle {
        address creator;
        uint64[] strategyIds;
    }

    
    
    
    
    
    
    
    struct Strategy {
        string name;
        address creator;
        bytes4[] triggerIds;
        bytes4[] actionIds;
        uint8[][] paramMapping;
        bool continuous;
    }

    
    
    
    
    
    
    struct Recipe {
        string name;
        bytes[] callData;
        bytes32[] subData;
        bytes4[] actionIds;
        uint8[][] paramMapping;
    }

    
    
    
    
    
    struct StoredSubData {
        bytes20 userProxy; // address but put in bytes20 for gas savings
        bool isEnabled;
        bytes32 strategySubHash;
    }

    
    
    
    
    
    struct StrategySub {
        uint64 strategyOrBundleId;
        bool isBundle;
        bytes[] triggerData;
        bytes32[] subData;
    }
}





contract BotAuth is AdminAuth {
    mapping(address => bool) public approvedCallers;

    
    
    
    
    function isApproved(uint256, address _caller) public view returns (bool) {
        return approvedCallers[_caller];
    }

    
    
    function addCaller(address _caller) public onlyOwner {
        approvedCallers[_caller] = true;
    }

    
    
    function removeCaller(address _caller) public onlyOwner {
        approvedCallers[_caller] = false;
    }
}





abstract contract IDSProxy {
    // function execute(bytes memory _code, bytes memory _data)
    //     public
    //     payable
    //     virtual
    //     returns (address, bytes32);

    function execute(address _target, bytes memory _data) public payable virtual returns (bytes32);

    function setCache(address _cacheAddr) public payable virtual returns (bool);

    function owner() public view virtual returns (address);
}





contract MainnetCoreAddresses {
    address internal constant REGISTRY_ADDR = 0x287778F121F134C66212FB16c9b53eC991D32f5b;
    address internal constant PROXY_AUTH_ADDR = 0xD489FfAEEB46b2d7E377850d45E1F8cA3350fc82;
    address internal constant DEFISAVER_LOGGER = 0xcE7a977Cac4a481bc84AC06b2Da0df614e621cf3;
}





contract CoreHelper is MainnetCoreAddresses {
}







contract ProxyAuth is AdminAuth, CoreHelper {
    IDFSRegistry public constant registry = IDFSRegistry(REGISTRY_ADDR);

    bytes4 constant STRATEGY_EXECUTOR_ID = bytes4(keccak256("StrategyExecutor"));

    error SenderNotExecutorError(address, address);

    modifier onlyExecutor {
        address executorAddr = registry.getAddr(STRATEGY_EXECUTOR_ID);

        if (msg.sender != executorAddr){
            revert SenderNotExecutorError(msg.sender, executorAddr);
        }

        _;
    }

    
    
    
    
    
    function callExecute(
        address _proxyAddr,
        address _contractAddr,
        bytes memory _callData
    ) public payable onlyExecutor {
        IDSProxy(_proxyAddr).execute{value: msg.value}(_contractAddr, _callData);
    }
}






contract StrategyStorage is StrategyModel, AdminAuth {

    Strategy[] public strategies;
    bool public openToPublic = false;

    error NoAuthToCreateStrategy(address,bool);
    event StrategyCreated(uint256 indexed);

    modifier onlyAuthCreators {
        if (adminVault.owner() != msg.sender && openToPublic == false) {
            revert NoAuthToCreateStrategy(msg.sender, openToPublic);
        }

        _;
    }

    
    
    
    
    
    
    
    function createStrategy(
        string memory _name,
        bytes4[] memory _triggerIds,
        bytes4[] memory _actionIds,
        uint8[][] memory _paramMapping,
        bool _continuous
    ) public onlyAuthCreators returns (uint256) {
        strategies.push(Strategy({
                name: _name,
                creator: msg.sender,
                triggerIds: _triggerIds,
                actionIds: _actionIds,
                paramMapping: _paramMapping,
                continuous : _continuous
        }));

        emit StrategyCreated(strategies.length - 1);

        return strategies.length - 1;
    }

    
    
    
    function changeEditPermission(bool _openToPublic) public onlyOwner {
        openToPublic = _openToPublic;
    }

    ////////////////////////////// VIEW METHODS /////////////////////////////////

    function getStrategy(uint _strategyId) public view returns (Strategy memory) {
        return strategies[_strategyId];
    }
    function getStrategyCount() public view returns (uint256) {
        return strategies.length;
    }

    function getPaginatedStrategies(uint _page, uint _perPage) public view returns (Strategy[] memory) {
        Strategy[] memory strategiesPerPage = new Strategy[](_perPage);

        uint start = _page * _perPage;
        uint end = start + _perPage;

        end = (end > strategies.length) ? strategies.length : end;

        uint count = 0;
        for (uint i = start; i < end; i++) {
            strategiesPerPage[count] = strategies[i];
            count++;
        }

        return strategiesPerPage;
    }

}









contract BundleStorage is StrategyModel, AdminAuth, CoreHelper {

    DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);

    StrategyBundle[] public bundles;
    bool public openToPublic = false;

    error NoAuthToCreateBundle(address,bool);
    error DiffTriggersInBundle(uint64[]);

    event BundleCreated(uint256);

    modifier onlyAuthCreators {
        if (adminVault.owner() != msg.sender && openToPublic == false) {
            revert NoAuthToCreateBundle(msg.sender, openToPublic);
        }

        _;
    }

    
    
    modifier sameTriggers(uint64[] memory _strategyIds) {
        if (msg.sender != adminVault.owner()) {
            address strategyStorageAddr = registry.getAddr(STRATEGY_STORAGE_ID);
            Strategy memory firstStrategy = StrategyStorage(strategyStorageAddr).getStrategy(_strategyIds[0]);

            bytes32 firstStrategyTriggerHash = keccak256(abi.encode(firstStrategy.triggerIds));

            for (uint256 i = 1; i < _strategyIds.length; ++i) {
                Strategy memory s = StrategyStorage(strategyStorageAddr).getStrategy(_strategyIds[i]);

                if (firstStrategyTriggerHash != keccak256(abi.encode(s.triggerIds))) {
                    revert DiffTriggersInBundle(_strategyIds);
                }
            }
        }

        _;
    }

    
    
    
    
    function createBundle(
        uint64[] memory _strategyIds
    ) public onlyAuthCreators sameTriggers(_strategyIds) returns (uint256) {

        bundles.push(StrategyBundle({
            creator: msg.sender,
            strategyIds: _strategyIds
        }));

        emit BundleCreated(bundles.length - 1);

        return bundles.length - 1;
    }

    
    
    
    function changeEditPermission(bool _openToPublic) public onlyOwner {
        openToPublic = _openToPublic;
    }

    ////////////////////////////// VIEW METHODS /////////////////////////////////

    function getStrategyId(uint256 _bundleId, uint256 _strategyIndex) public view returns (uint256) {
        return bundles[_bundleId].strategyIds[_strategyIndex];
    }

    function getBundle(uint _bundleId) public view returns (StrategyBundle memory) {
        return bundles[_bundleId];
    }
    function getBundleCount() public view returns (uint256) {
        return bundles.length;
    }

    function getPaginatedBundles(uint _page, uint _perPage) public view returns (StrategyBundle[] memory) {
        StrategyBundle[] memory bundlesPerPage = new StrategyBundle[](_perPage);
        uint start = _page * _perPage;
        uint end = start + _perPage;

        end = (end > bundles.length) ? bundles.length : end;

        uint count = 0;
        for (uint i = start; i < end; i++) {
            bundlesPerPage[count] = bundles[i];
            count++;
        }

        return bundlesPerPage;
    }

}









contract SubStorage is StrategyModel, AdminAuth, CoreHelper {
    error SenderNotSubOwnerError(address, uint256);
    error UserPositionsEmpty();
    error SubIdOutOfRange(uint256, bool);

    event Subscribe(uint256 indexed, address indexed, bytes32 indexed, StrategySub);
    event UpdateData(uint256 indexed, bytes32 indexed, StrategySub);
    event ActivateSub(uint256 indexed);
    event DeactivateSub(uint256 indexed);

    DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);

    StoredSubData[] public strategiesSubs;

    
    modifier onlySubOwner(uint256 _subId) {
        if (address(strategiesSubs[_subId].userProxy) != msg.sender) {
            revert SenderNotSubOwnerError(msg.sender, _subId);
        }
        _;
    }

    
    modifier isValidId(uint256 _id, bool _isBundle) {
        if (_isBundle) {
            if (_id > (BundleStorage(registry.getAddr(BUNDLE_STORAGE_ID)).getBundleCount() - 1)) {
                revert SubIdOutOfRange(_id, _isBundle);
            }
        } else {
            if (_id > (StrategyStorage(registry.getAddr(STRATEGY_STORAGE_ID)).getStrategyCount() - 1)) {
                revert SubIdOutOfRange(_id, _isBundle);
            }
        }

        _;
    }

    
    
    
    function subscribeToStrategy(
        StrategySub memory _sub
    ) public isValidId(_sub.strategyOrBundleId, _sub.isBundle) returns (uint256) {

        bytes32 subStorageHash = keccak256(abi.encode(_sub));

        strategiesSubs.push(StoredSubData(
            bytes20(msg.sender),
            true,
            subStorageHash
        ));

        uint256 currentId = strategiesSubs.length - 1;

        emit Subscribe(currentId, msg.sender, subStorageHash, _sub);

        return currentId;
    }

    
    
    
    
    function updateSubData(
        uint256 _subId,
        StrategySub calldata _sub
    ) public onlySubOwner(_subId) isValidId(_sub.strategyOrBundleId, _sub.isBundle)  {
        StoredSubData storage storedSubData = strategiesSubs[_subId];

        bytes32 subStorageHash = keccak256(abi.encode(_sub));

        storedSubData.strategySubHash = subStorageHash;

        emit UpdateData(_subId, subStorageHash, _sub);
    }

    
    
    
    function activateSub(
        uint _subId
    ) public onlySubOwner(_subId) {
        StoredSubData storage sub = strategiesSubs[_subId];

        sub.isEnabled = true;

        emit ActivateSub(_subId);
    }

    
    
    
    function deactivateSub(
        uint _subId
    ) public onlySubOwner(_subId) {
        StoredSubData storage sub = strategiesSubs[_subId];

        sub.isEnabled = false;

        emit DeactivateSub(_subId);
    }

    ///////////////////// VIEW ONLY FUNCTIONS ////////////////////////////

    function getSub(uint _subId) public view returns (StoredSubData memory) {
        return strategiesSubs[_subId];
    }

    function getSubsCount() public view returns (uint256) {
        return strategiesSubs.length;
    }
}










contract StrategyExecutor is StrategyModel, AdminAuth, CoreHelper {

    DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);

    bytes4 constant BOT_AUTH_ID = bytes4(keccak256("BotAuth"));
    bytes4 constant RECIPE_EXECUTOR_ID = bytes4(keccak256("RecipeExecutor"));

    error BotNotApproved(address, uint256);
    error SubNotEnabled(uint256);
    error SubDatHashMismatch(uint256, bytes32, bytes32);

    
    
    
    
    
    
    
    function executeStrategy(
        uint256 _subId,
        uint256 _strategyIndex,
        bytes[] calldata _triggerCallData,
        bytes[] calldata _actionsCallData,
        StrategySub memory _sub
    ) public {
        // check bot auth
        if (!checkCallerAuth(_subId)) {
            revert BotNotApproved(msg.sender, _subId);
        }

        StoredSubData memory storedSubData = SubStorage(registry.getAddr(SUB_STORAGE_ID)).getSub(_subId);

        bytes32 subDataHash = keccak256(abi.encode(_sub));

        // data sent from the caller must match the stored hash of the data
        if (subDataHash != storedSubData.strategySubHash) {
            revert SubDatHashMismatch(_subId, subDataHash, storedSubData.strategySubHash);
        }

        // subscription must be enabled
        if (!storedSubData.isEnabled) {
            revert SubNotEnabled(_subId);
        }

        // execute actions
        callActions(_subId, _actionsCallData, _triggerCallData, _strategyIndex, _sub, address(storedSubData.userProxy));
    }

    
    
    function checkCallerAuth(uint256 _subId) internal view returns (bool) {
        return BotAuth(registry.getAddr(BOT_AUTH_ID)).isApproved(_subId, msg.sender);
    }


    
    
    
    
    
    
    
    function callActions(
        uint256 _subId,
        bytes[] calldata _actionsCallData,
        bytes[] calldata _triggerCallData,
        uint256 _strategyIndex,
        StrategySub memory _sub,
        address _userProxy
    ) internal {
        address recipeExecutorAddr = registry.getAddr(RECIPE_EXECUTOR_ID);

        ProxyAuth(PROXY_AUTH_ADDR).callExecute{value: msg.value}(
            _userProxy,
            recipeExecutorAddr,
            abi.encodeWithSignature(
                "executeRecipeFromStrategy(uint256,bytes[],bytes[],uint256,(uint64,bool,bytes[],bytes32[]))",
                _subId,
                _actionsCallData,
                _triggerCallData,
                _strategyIndex,
                _sub
            )
        );
    }
}