// SPDX-License-Identifier: UNLICENSED"
pragma experimental ABIEncoderV2;


// "
pragma solidity >=0.6.10;




interface IGelatoProviderModule {

    
    
    
    
    
    
    function isProvided(address _userProxy, address _provider, Task calldata _task)
        external
        view
        returns(string memory);

    
    
    
    
    
    
    
    
    
    function execPayload(
        uint256 _taskReceiptId,
        address _userProxy,
        address _provider,
        Task calldata _task,
        uint256 _cycleId
    )
        external
        view
        returns(bytes memory, bool checkReturndata);

    
    
    
    function execRevertCheck(bytes calldata _proxyReturndata) external pure;
}

// "
pragma solidity >=0.6.10;





abstract contract GelatoProviderModuleStandard is IGelatoProviderModule {

    string internal constant OK = "OK";

    function isProvided(address, address, Task calldata)
        external
        view
        virtual
        override
        returns(string memory)
    {
        return OK;
    }

    function execPayload(uint256, address, address, Task calldata, uint256)
        external
        view
        virtual
        override
        returns(bytes memory payload, bool)
    {
        return (payload, false);
    }

    
    function execRevertCheck(bytes calldata) external pure override virtual {
        // By default no reverts detected => do nothing
    }
}

// 

pragma solidity >=0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
pragma solidity 0.8.0;




contract MockProviderModule is GelatoProviderModuleStandard {
    function execPayload(
        uint256,
        address,
        address,
        Task calldata _task,
        uint256
    ) external pure override returns (bytes memory payload, bool) {
        return (_task.actions[0].data, false);
    }
}

// 

pragma solidity >=0.6.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable2 is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// "
pragma solidity >=0.6.10;





interface IGelatoCondition {

    
    
    ///  "ok" selector or _taskReceiptId, since those two things are handled by GelatoCore.
    
    ///  source of Task identification.
    
    ///  Condition's specific parameters in.
    
    function ok(uint256 _taskReceiptId, bytes calldata _conditionData, uint256 _cycleId)
        external
        view
        returns(string memory);
}

// "
pragma solidity >=0.6.10;





struct Provider {
    address addr;  //  if msg.sender == provider => self-Provider
    IGelatoProviderModule module;  //  can be IGelatoProviderModule(0) for self-Providers
}

struct Condition {
    IGelatoCondition inst;  // can be AddressZero for self-conditional Actions
    bytes data;  // can be bytes32(0) for self-conditional Actions
}

enum Operation { Call, Delegatecall }

enum DataFlow { None, In, Out, InAndOut }

struct Action {
    address addr;
    bytes data;
    Operation operation;
    DataFlow dataFlow;
    uint256 value;
    bool termsOkCheck;
}

struct Task {
    Condition[] conditions;  // optional
    Action[] actions;
    uint256 selfProviderGasLimit;  // optional: 0 defaults to gelatoMaxGas
    uint256 selfProviderGasPriceCeil;  // optional: 0 defaults to NO_CEIL
}

struct TaskReceipt {
    uint256 id;
    address userProxy;
    Provider provider;
    uint256 index;
    Task[] tasks;
    uint256 expiryDate;
    uint256 cycleId;  // auto-filled by GelatoCore. 0 for non-cyclic/chained tasks
    uint256 submissionsLeft;
}

interface IGelatoCore {
    event LogTaskSubmitted(
        uint256 indexed taskReceiptId,
        bytes32 indexed taskReceiptHash,
        TaskReceipt taskReceipt
    );

    event LogExecSuccess(
        address indexed executor,
        uint256 indexed taskReceiptId,
        uint256 executorSuccessFee,
        uint256 sysAdminSuccessFee
    );
    event LogCanExecFailed(
        address indexed executor,
        uint256 indexed taskReceiptId,
        string reason
    );
    event LogExecReverted(
        address indexed executor,
        uint256 indexed taskReceiptId,
        uint256 executorRefund,
        string reason
    );

    event LogTaskCancelled(uint256 indexed taskReceiptId, address indexed cancellor);

    
    
    
    
    
    function canSubmitTask(
        address _userProxy,
        Provider calldata _provider,
        Task calldata _task,
        uint256 _expiryDate
    )
        external
        view
        returns(string memory);

    
    
    
    
    
    function submitTask(
        Provider calldata _provider,
        Task calldata _task,
        uint256 _expiryDate
    )
        external;


    
    ///  the next one, after they have been executed.
    
    
    
    
    function submitTaskCycle(
        Provider calldata _provider,
        Task[] calldata _tasks,
        uint256 _expiryDate,
        uint256 _cycles
    )
        external;


    
    ///  the next one, after they have been executed.
    
    
    ///  would be submitted, but not the second
    
    
    
    
    ///  that should have occured once the cycle is complete:
    ///  _sumOfRequestedTaskSubmits = 0 => One Task will resubmit the next Task infinitly
    ///  _sumOfRequestedTaskSubmits = 1 => One Task will resubmit no other task
    ///  _sumOfRequestedTaskSubmits = 2 => One Task will resubmit 1 other task
    ///  ...
    function submitTaskChain(
        Provider calldata _provider,
        Task[] calldata _tasks,
        uint256 _expiryDate,
        uint256 _sumOfRequestedTaskSubmits
    )
        external;

    // ================  Exec Suite =========================
    
    
    
    
    ///  Providers must use gelatoMaxGas. If the _gasLimit is used by an Executor and the
    ///  tx reverts, a refund is paid by the Provider and the TaskReceipt is annulated.
    
    ///  Gas Price Oracle. Executors can query the current gelatoGasPrice from events.
    function canExec(TaskReceipt calldata _TR, uint256 _gasLimit, uint256 _execTxGasPrice)
        external
        view
        returns(string memory);

    
    
    ///   successfully executed, or when the execution failed, despite of gelatoMaxGas usage.
    ///   In the latter case Executors are refunded by the Task Provider.
    
    function exec(TaskReceipt calldata _TR) external;

    
    
    
    function cancelTask(TaskReceipt calldata _TR) external;

    
    
    
    function multiCancelTasks(TaskReceipt[] calldata _taskReceipts) external;

    
    
    
    function hashTaskReceipt(TaskReceipt calldata _TR) external pure returns(bytes32);

    // ================  Getters =========================
    
    
    function currentTaskReceiptId() external view returns(uint256);

    
    
    
    function taskReceiptHash(uint256 _taskReceiptId) external view returns(bytes32);
}

// "
pragma solidity >=0.6.10;






// TaskSpec - Will be whitelised by providers and selected by users
struct TaskSpec {
    IGelatoCondition[] conditions;   // Address: optional AddressZero for self-conditional actions
    Action[] actions;
    uint256 gasPriceCeil;
}

interface IGelatoProviders {
    // Provider Funding
    event LogFundsProvided(
        address indexed provider,
        uint256 amount,
        uint256 newProviderFunds
    );
    event LogFundsUnprovided(
        address indexed provider,
        uint256 realWithdrawAmount,
        uint256 newProviderFunds
    );

    // Executor By Provider
    event LogProviderAssignedExecutor(
        address indexed provider,
        address indexed oldExecutor,
        address indexed newExecutor
    );
    event LogExecutorAssignedExecutor(
        address indexed provider,
        address indexed oldExecutor,
        address indexed newExecutor
    );

    // Actions
    event LogTaskSpecProvided(address indexed provider, bytes32 indexed taskSpecHash);
    event LogTaskSpecUnprovided(address indexed provider, bytes32 indexed taskSpecHash);
    event LogTaskSpecGasPriceCeilSet(
        address indexed provider,
        bytes32 taskSpecHash,
        uint256 oldTaskSpecGasPriceCeil,
        uint256 newTaskSpecGasPriceCeil
    );

    // Provider Module
    event LogProviderModuleAdded(
        address indexed provider,
        IGelatoProviderModule indexed module
    );
    event LogProviderModuleRemoved(
        address indexed provider,
        IGelatoProviderModule indexed module
    );

    // =========== GELATO PROVIDER APIs ==============

    
    
    
    
    
    function isTaskSpecProvided(address _provider, TaskSpec calldata _taskSpec)
        external
        view
        returns(string memory);

    
    
    
    
    
    
    function providerModuleChecks(
        address _userProxy,
        Provider calldata _provider,
        Task calldata _task
    )
        external
        view
        returns(string memory);


    
    
    
    
    
    
    function isTaskProvided(
        address _userProxy,
        Provider calldata _provider,
        Task calldata _task
    )
        external
        view
        returns(string memory res);


    
    
    
    
    
    
    
    function providerCanExec(
        address _userProxy,
        Provider calldata _provider,
        Task calldata _task,
        uint256 _gelatoGasPrice
    )
        external
        view
        returns(string memory res);

    // =========== PROVIDER STATE WRITE APIs ==============
    // Provider Funding
    
    
    function provideFunds(address _provider) external payable;

    
    
    
    function unprovideFunds(uint256 _withdrawAmount) external returns(uint256);

    
    
    function providerAssignsExecutor(address _executor) external;

    
    
    
    function executorAssignsExecutor(address _provider, address _newExecutor) external;

    // (Un-)provide Task Spec

    
    
    
    function provideTaskSpecs(TaskSpec[] calldata _taskSpecs) external;

    
    
    
    function unprovideTaskSpecs(TaskSpec[] calldata _taskSpecs) external;

    
    
    
    function setTaskSpecGasPriceCeil(bytes32 _taskSpecHash, uint256 _gasPriceCeil) external;

    // Provider Module
    
    
    function addProviderModules(IGelatoProviderModule[] calldata _modules) external;

    
    
    function removeProviderModules(IGelatoProviderModule[] calldata _modules) external;

    // Batch (un-)provide

    
    
    
    
    function multiProvide(
        address _executor,
        TaskSpec[] calldata _taskSpecs,
        IGelatoProviderModule[] calldata _modules
    )
        external
        payable;


    
    
    
    
    function multiUnprovide(
        uint256 _withdrawAmount,
        TaskSpec[] calldata _taskSpecs,
        IGelatoProviderModule[] calldata _modules
    )
        external;

    // =========== PROVIDER STATE READ APIs ==============
    // Provider Funding

    
    
    
    function providerFunds(address _provider) external view returns(uint256);

    
    
    
    
    function minExecProviderFunds(uint256 _gelatoMaxGas, uint256 _gelatoGasPrice)
        external
        view
        returns(uint256);

    
    
    
    
    
    function isProviderLiquid(
        address _provider,
        uint256 _gelatoMaxGas,
        uint256 _gelatoGasPrice
    )
        external
        view
        returns(bool);

    // Executor Stake

    
    
    
    function executorStake(address _executor) external view returns(uint256);

    
    
    
    function isExecutorMinStaked(address _executor) external view returns(bool);

    
    
    
    function executorByProvider(address _provider)
        external
        view
        returns(address);

    
    
    
    function executorProvidersCount(address _executor) external view returns(uint256);

    
    
    
    function isExecutorAssigned(address _executor) external view returns(bool);

    // Task Spec and Gas Price Ceil
    
    
    
    
    function taskSpecGasPriceCeil(address _provider, bytes32 _taskSpecHash)
        external
        view
        returns(uint256);

    
    
    
    
    function hashTaskSpec(TaskSpec calldata _taskSpec) external view returns(bytes32);

    
    
    
    function NO_CEIL() external pure returns(uint256);

    // Providers' Module Getters

    
    
    
    
    function isModuleProvided(address _provider, IGelatoProviderModule _module)
        external
        view
        returns(bool);

    
    
    
    function providerModules(address _provider)
        external
        view
        returns(IGelatoProviderModule[] memory);
}

// 
pragma solidity 0.8.0;









contract MockCheapTask is Ownable2, MockProviderModule {
    using Address for address payable;
    using GelatoString for string;

    // solhint-disable no-empty-blocks

    enum Log {ExecSuccess, ExecReverted, CanExecFailed}

    address public immutable gelatoCore;

    constructor(address _gelatoCore, address _executor) {
        gelatoCore = _gelatoCore;
        IGelatoProviderModule[] memory modules = new IGelatoProviderModule[](1);
        modules[0] = IGelatoProviderModule(this);
        try
            IGelatoProviders(_gelatoCore).multiProvide(
                _executor,
                new TaskSpec[](0),
                modules
            )
        {} catch {}
    }

    receive() external payable {
        require(
            msg.sender == gelatoCore,
            "MockCheapTask.receive:onlyGelatoCore"
        );
    }

    
    function withdrawContractBalance() external onlyOwner {
        payable(msg.sender).sendValue(address(this).balance);
    }

    // solhint-disable-next-line function-max-lines
    function submitTask(
        Log _log,
        uint256 _selfProviderGasLimit,
        uint256 _selfProviderGasPriceCeil
    ) external {
        Provider memory provider =
            Provider({
                addr: address(this),
                module: IGelatoProviderModule(this)
            });

        bytes memory actionData;
        if (_log == Log.ExecSuccess)
            actionData = abi.encodeWithSelector(this.tAction.selector);
        else if (_log == Log.ExecReverted)
            actionData = abi.encodeWithSelector(this.tRevert.selector);

        Action memory action =
            Action({
                addr: address(this),
                data: actionData,
                operation: Operation.Call,
                dataFlow: DataFlow.None,
                value: 0,
                termsOkCheck: _log == Log.CanExecFailed ? true : false
            });

        Action[] memory actions = new Action[](1);
        actions[0] = action;

        Task memory task =
            Task({
                conditions: new Condition[](0),
                actions: actions,
                selfProviderGasLimit: _selfProviderGasLimit,
                selfProviderGasPriceCeil: _selfProviderGasPriceCeil
            });

        try
            IGelatoCore(gelatoCore).submitTask(provider, task, 0)
        {} catch Error(string memory error) {
            revert(
                string("MockCheapTask.submitTask.submitTask:").suffix(error)
            );
        } catch {
            revert("MockCheapTask.submitTask.submitTask:undefined");
        }
    }

    
    function tAction() external {}

    
    function tRevert() external pure {
        revert("MockCheapTask.tRevert");
    }

    function multiProvide(
        address _executor,
        IGelatoProviderModule[] calldata _modules
    ) external payable onlyOwner {
        try
            IGelatoProviders(gelatoCore).multiProvide{value: msg.value}(
                _executor,
                new TaskSpec[](0),
                _modules
            )
        {} catch Error(string memory error) {
            revert(string("MockCheapTask.multiProvide:").suffix(error));
        } catch {
            revert("MockCheapTask.multiProvide:undefined");
        }
    }

    function unprovideFunds(uint256 _amount) external onlyOwner {
        try IGelatoProviders(gelatoCore).unprovideFunds(_amount) returns (
            uint256 withdrawAmount
        ) {
            payable(msg.sender).sendValue(withdrawAmount);
        } catch Error(string memory error) {
            revert(string("MockCheapTask.unprovideFunds:").suffix(error));
        } catch {
            revert("MockCheapTask.unprovideFunds:undefined");
        }
    }

    function provideFunds() public payable {
        try
            IGelatoProviders(gelatoCore).provideFunds{value: msg.value}(
                address(this)
            )
        {} catch Error(string memory error) {
            revert(string("MockCheapTask.provideFunds:").suffix(error));
        } catch {
            revert("MockCheapTask.provideFunds:undefined");
        }
    }

    function termsOk(
        uint256, // taskReceipId
        address,
        bytes calldata,
        DataFlow,
        uint256, // value
        uint256 // cycleId
    ) public view returns (string memory) {
        if (gasleft() > 700000) return "OK";
        else revert("MockCheapTask.termsOk: test revert");
    }

    function cancelTask(TaskReceipt memory _taskReceipt)
        external
        payable
        onlyOwner
    {
        try IGelatoCore(gelatoCore).cancelTask(_taskReceipt) {} catch Error(
            string memory error
        ) {
            revert(string("MockCheapTask.cancelTask:").suffix(error));
        } catch {
            revert("MockCheapTask.cancelTask:undefined");
        }
    }
}

// 
pragma solidity 0.8.0;

library GelatoString {
    function startsWithOK(string memory _str) internal pure returns (bool) {
        if (
            bytes(_str).length >= 2 &&
            bytes(_str)[0] == "O" &&
            bytes(_str)[1] == "K"
        ) return true;
        return false;
    }

    function revertWithInfo(string memory _error, string memory _tracingInfo)
        internal
        pure
    {
        revert(string(abi.encodePacked(_tracingInfo, _error)));
    }

    function prefix(string memory _second, string memory _first)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(_first, _second));
    }

    function suffix(string memory _first, string memory _second)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(_first, _second));
    }
}

// 

pragma solidity >=0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) =
            target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
