// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2022-03-14
*/

// 

pragma solidity =0.7.6;






interface ICurveStethPool {
    function add_liquidity(uint256[2] memory, uint256) external payable returns (uint256);
    function remove_liquidity(uint256, uint256[2] memory) external returns (uint256[2] memory);
    function remove_liquidity_imbalance(uint256[2] memory, uint256) external returns (uint256);
}




interface IAddressProvider {
    function admin() external view returns (address);
    function get_registry() external view returns (address);
    function get_address(uint256 _id) external view returns (address);
}




interface ISwaps {

    
    
    ///        this contract to transfer `_amount` coins from `_from`
    ///        Does NOT check rates in factory-deployed pools
    
    
    
    
    ///        in order for the transaction to succeed
    
    
    function exchange_with_best_rate(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _expected,
        address _receiver
    ) external payable returns (uint256);


    
    
    ///        this contract to transfer `_amount` coins from `_from`
    ///        Works for both regular and factory-deployed pools
    
    
    
    
    
    ///        in order for the transaction to succeed
    
    
    function exchange(
        address _pool,
        address _from,
        address _to,
        uint256 _amount,
        uint256 _expected,
        address _receiver
    ) external payable returns (uint256);



    
    
    
    
    
    
    
    function get_best_rate(
        address _from,
        address _to,
        uint256 _amount,
        address[8] memory _exclude_pools
    ) external view returns (address, uint256);


    
    
    
    
    
    
    
    function get_exchange_amount(
        address _pool,
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (uint256);


    
    
    
    
    
    
    function get_input_amount(
        address _pool,
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (uint256);


    
    
    
    
    
    
    function get_exchange_amounts(
        address _pool,
        address _from,
        address _to,
        uint256[] memory _amounts
    ) external view returns (uint256[] memory);


    
    
    
    
    function get_calculator(address _pool) external view returns (address);
}




interface IRegistry {
    function get_lp_token(address) external view returns (address);
    function get_pool_from_lp_token(address) external view returns (address);
    function get_pool_name(address) external view returns(string memory);
    function get_coins(address) external view returns (address[8] memory);
    function get_underlying_coins(address) external view returns (address[8] memory);
    function get_decimals(address) external view returns (uint256[8] memory);
    function get_underlying_decimals(address) external view returns (uint256[8] memory);
    function get_balances(address) external view returns (uint256[8] memory);
    function get_underlying_balances(address) external view returns (uint256[8] memory);
    function get_virtual_price_from_lp_token(address) external view returns (uint256);
    function get_gauges(address) external view returns (address[10] memory, int128[10] memory);
    function pool_count() external view returns (uint256);
    function pool_list(uint256) external view returns (address);
}




interface IMinter {
    function mint(address _gaugeAddr) external;
    function mint_many(address[8] memory _gaugeAddrs) external;
}




interface IVotingEscrow {
    function create_lock(uint256 _amount, uint256 _unlockTime) external;
    function increase_amount(uint256 _amount) external;
    function increase_unlock_time(uint256 _unlockTime) external;
    function withdraw() external;
}




interface IFeeDistributor {
    function claim(address) external returns (uint256);
}





contract MainnetCurveAddresses {
    address internal constant CRV_TOKEN_ADDR = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address internal constant CRV_3CRV_TOKEN_ADDR = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;

    address internal constant ADDRESS_PROVIDER_ADDR = 0x0000000022D53366457F9d5E68Ec105046FC4383;
    address internal constant MINTER_ADDR = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
    address internal constant VOTING_ESCROW_ADDR = 0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2;
    address internal constant FEE_DISTRIBUTOR_ADDR = 0xA464e6DCda8AC41e03616F95f4BC98a13b8922Dc;
}










contract CurveHelper is MainnetCurveAddresses {
    IAddressProvider public constant AddressProvider = IAddressProvider(ADDRESS_PROVIDER_ADDR);
    IMinter public constant Minter = IMinter(MINTER_ADDR);
    IVotingEscrow public constant VotingEscrow = IVotingEscrow(VOTING_ESCROW_ADDR);
    IFeeDistributor public constant FeeDistributor = IFeeDistributor(FEE_DISTRIBUTOR_ADDR);

    function getSwaps() internal view returns (ISwaps) {
        return ISwaps(AddressProvider.get_address(2));
    }

    function getRegistry() internal view returns (IRegistry) {
        return IRegistry(AddressProvider.get_registry());
    }
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





abstract contract IWETH {
    function allowance(address, address) public virtual view returns (uint256);

    function balanceOf(address) public virtual view returns (uint256);

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;
}





library Address {
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

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






library TokenUtils {
    using SafeERC20 for IERC20;

    address public constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function approveToken(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) internal {
        if (_tokenAddr == ETH_ADDR) return;

        if (IERC20(_tokenAddr).allowance(address(this), _to) < _amount) {
            IERC20(_tokenAddr).safeApprove(_to, _amount);
        }
    }

    function pullTokensIfNeeded(
        address _token,
        address _from,
        uint256 _amount
    ) internal returns (uint256) {
        // handle max uint amount
        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, _from);
        }

        if (_from != address(0) && _from != address(this) && _token != ETH_ADDR && _amount != 0) {
            IERC20(_token).safeTransferFrom(_from, address(this), _amount);
        }

        return _amount;
    }

    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (uint256) {
        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, address(this));
        }

        if (_to != address(0) && _to != address(this) && _amount != 0) {
            if (_token != ETH_ADDR) {
                IERC20(_token).safeTransfer(_to, _amount);
            } else {
                (bool success, ) = _to.call{value: _amount}("");
                require(success, "Eth send fail");
            }
        }

        return _amount;
    }

    function depositWeth(uint256 _amount) internal {
        IWETH(WETH_ADDR).deposit{value: _amount}();
    }

    function withdrawWeth(uint256 _amount) internal {
        IWETH(WETH_ADDR).withdraw(_amount);
    }

    function getBalance(address _tokenAddr, address _acc) internal view returns (uint256) {
        if (_tokenAddr == ETH_ADDR) {
            return _acc.balance;
        } else {
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
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    
    function kill() public onlyAdmin {
        selfdestruct(payable(msg.sender));
    }
}





contract DefisaverLogger {
    event LogEvent(
        address indexed contractAddress,
        address indexed caller,
        string indexed logName,
        bytes data
    );

    // solhint-disable-next-line func-name-mixedcase
    function Log(
        address _contract,
        address _caller,
        string memory _logName,
        bytes memory _data
    ) public {
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
    DefisaverLogger public constant logger = DefisaverLogger(
        DEFI_SAVER_LOGGER_ADDR
    );

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

    /////////////////////////// OWNER ONLY FUNCTIONS ///////////////////////////

    
    
    
    
    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public onlyOwner {
        require(!entries[_id].exists, ERR_ENTRY_ALREADY_EXISTS);

        entries[_id] = Entry({
            contractAddr: _contractAddr,
            waitPeriod: _waitPeriod,
            changeStartTime: 0,
            inContractChange: false,
            inWaitPeriodChange: false,
            exists: true
        });

        // Remember tha address so we can revert back to old addr if needed
        previousAddresses[_id] = _contractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "AddNewContract",
            abi.encode(_id, _contractAddr, _waitPeriod)
        );
    }

    
    
    
    function revertToPreviousAddress(bytes32 _id) public onlyOwner {
        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(previousAddresses[_id] != address(0), ERR_EMPTY_PREV_ADDR);

        address currentAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = previousAddresses[_id];

        logger.Log(
            address(this),
            msg.sender,
            "RevertToPreviousAddress",
            abi.encode(_id, currentAddr, previousAddresses[_id])
        );
    }

    
    
    
    
    function startContractChange(bytes32 _id, address _newContractAddr) public onlyOwner {
        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(!entries[_id].inWaitPeriodChange, ERR_ALREADY_IN_WAIT_PERIOD_CHANGE);

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inContractChange = true;

        pendingAddresses[_id] = _newContractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "StartContractChange",
            abi.encode(_id, entries[_id].contractAddr, _newContractAddr)
        );
    }

    
    
    function approveContractChange(bytes32 _id) public onlyOwner {
        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inContractChange, ERR_ENTRY_NOT_IN_CHANGE);
        require(
            block.timestamp >= (entries[_id].changeStartTime + entries[_id].waitPeriod), // solhint-disable-line
            ERR_CHANGE_NOT_READY
        );

        address oldContractAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = pendingAddresses[_id];
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        pendingAddresses[_id] = address(0);
        previousAddresses[_id] = oldContractAddr;

        logger.Log(
            address(this),
            msg.sender,
            "ApproveContractChange",
            abi.encode(_id, oldContractAddr, entries[_id].contractAddr)
        );
    }

    
    
    function cancelContractChange(bytes32 _id) public onlyOwner {
        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inContractChange, ERR_ENTRY_NOT_IN_CHANGE);

        address oldContractAddr = pendingAddresses[_id];

        pendingAddresses[_id] = address(0);
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        logger.Log(
            address(this),
            msg.sender,
            "CancelContractChange",
            abi.encode(_id, oldContractAddr, entries[_id].contractAddr)
        );
    }

    
    
    
    function startWaitPeriodChange(bytes32 _id, uint256 _newWaitPeriod) public onlyOwner {
        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(!entries[_id].inContractChange, ERR_ALREADY_IN_CONTRACT_CHANGE);

        pendingWaitTimes[_id] = _newWaitPeriod;

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inWaitPeriodChange = true;

        logger.Log(
            address(this),
            msg.sender,
            "StartWaitPeriodChange",
            abi.encode(_id, _newWaitPeriod)
        );
    }

    
    
    function approveWaitPeriodChange(bytes32 _id) public onlyOwner {
        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inWaitPeriodChange, ERR_ENTRY_NOT_IN_CHANGE);
        require(
            block.timestamp >= (entries[_id].changeStartTime + entries[_id].waitPeriod), // solhint-disable-line
            ERR_CHANGE_NOT_READY
        );

        uint256 oldWaitTime = entries[_id].waitPeriod;
        entries[_id].waitPeriod = pendingWaitTimes[_id];
        
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        pendingWaitTimes[_id] = 0;

        logger.Log(
            address(this),
            msg.sender,
            "ApproveWaitPeriodChange",
            abi.encode(_id, oldWaitTime, entries[_id].waitPeriod)
        );
    }

    
    
    function cancelWaitPeriodChange(bytes32 _id) public onlyOwner {
        require(entries[_id].exists, ERR_ENTRY_NON_EXISTENT);
        require(entries[_id].inWaitPeriodChange, ERR_ENTRY_NOT_IN_CHANGE);

        uint256 oldWaitPeriod = pendingWaitTimes[_id];

        pendingWaitTimes[_id] = 0;
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        logger.Log(
            address(this),
            msg.sender,
            "CancelWaitPeriodChange",
            abi.encode(_id, oldWaitPeriod, entries[_id].waitPeriod)
        );
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

    DefisaverLogger public constant logger = DefisaverLogger(
        DFS_LOGGER_ADDR
    );

    string public constant ERR_SUB_INDEX_VALUE = "Wrong sub index value";
    string public constant ERR_RETURN_INDEX_VALUE = "Wrong return index value";

    
    uint8 public constant SUB_MIN_INDEX_VALUE = 128;
    uint8 public constant SUB_MAX_INDEX_VALUE = 255;

    
    uint8 public constant RETURN_MIN_INDEX_VALUE = 1;
    uint8 public constant RETURN_MAX_INDEX_VALUE = 127;

    
    uint8 public constant NO_PARAM_MAPPING = 0;

    
    enum ActionType { FL_ACTION, STANDARD_ACTION, CUSTOM_ACTION }

    
    
    
    
    
    
    
    function executeAction(
        bytes[] memory _callData,
        bytes[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable virtual returns (bytes32);

    
    
    function executeActionDirect(bytes[] memory _callData) public virtual payable;

    
    function actionType() public pure virtual returns (uint8);


    //////////////////////////// HELPER METHODS ////////////////////////////

    
    
    
    
    
    function _parseParamUint(
        uint _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (uint) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = uint(_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = abi.decode(_subData[getSubIndex(_mapType)], (uint));
            }
        }

        return _param;
    }


    
    
    
    
    
    function _parseParamAddr(
        address _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (address) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = address(bytes20((_returnValues[getReturnIndex(_mapType)])));
            } else {
                _param = abi.decode(_subData[getSubIndex(_mapType)], (address));
            }
        }

        return _param;
    }

    
    
    
    
    
    function _parseParamABytes32(
        bytes32 _param,
        uint8 _mapType,
        bytes[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (bytes32) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = (_returnValues[getReturnIndex(_mapType)]);
            } else {
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









contract CurveStethPoolWithdraw is ActionBase {
    using TokenUtils for address;
    using SafeMath for uint256;

    address constant internal CURVE_STETH_POOL_ADDR = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
    address constant internal STE_CRV_ADDR = 0x06325440D014e39736583c165C2963BA99fAf14E;
    address constant internal STETH_ADDR = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;

    struct Params {
        address from;           // address where to pull lp tokens from
        address to;             // address that will receive withdrawn tokens
        uint256[2] amounts;     // amount of each token to withdraw
        uint256 maxBurnAmount;  // max amount of LP tokens to burn
    }

    function executeAction(
        bytes[] memory _callData,
        bytes[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable virtual override returns (bytes32) {
        Params memory params = parseInputs(_callData);
        params.from = _parseParamAddr(params.from, _paramMapping[0], _subData, _returnValues);
        params.to = _parseParamAddr(params.to, _paramMapping[1], _subData, _returnValues);
        params.amounts[0] = _parseParamUint(params.amounts[0], _paramMapping[2], _subData, _returnValues);
        params.amounts[1] = _parseParamUint(params.amounts[1], _paramMapping[3], _subData, _returnValues);
        params.maxBurnAmount = _parseParamUint(params.maxBurnAmount, _paramMapping[4], _subData, _returnValues);

        uint256 burnedLp = _curveWithdraw(params);
        return bytes32(burnedLp);
    }

    
    function executeActionDirect(bytes[] memory _callData) public payable virtual override {
        Params memory params = parseInputs(_callData);
        _curveWithdraw(params);
    }

    
    function actionType() public pure virtual override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    
    function _curveWithdraw(Params memory _params) internal returns (uint256 burnedLp) {
        require(_params.to != address(0), "to cant be 0x0");

        STE_CRV_ADDR.pullTokensIfNeeded(_params.from, _params.maxBurnAmount);
        STE_CRV_ADDR.approveToken(CURVE_STETH_POOL_ADDR, _params.maxBurnAmount);

        burnedLp = ICurveStethPool(CURVE_STETH_POOL_ADDR).remove_liquidity_imbalance(
            _params.amounts,
            _params.maxBurnAmount
        );

        if (_params.amounts[0] != 0) {
            TokenUtils.depositWeth(_params.amounts[0]);
            TokenUtils.WETH_ADDR.withdrawTokens(_params.to, _params.amounts[0]);
        }
        
        STETH_ADDR.withdrawTokens(_params.to, _params.amounts[1]);
        // return unburned lp tokens to from
        STE_CRV_ADDR.withdrawTokens(_params.from, _params.maxBurnAmount.sub(burnedLp));

        logger.Log(
            address(this),
            msg.sender,
            "CurveStethPoolWithdraw",
            abi.encode(burnedLp)
        );
    }

    function parseInputs(bytes[] memory _callData) internal pure returns (Params memory params) {
        params = abi.decode(_callData[0], (Params));
    }
}