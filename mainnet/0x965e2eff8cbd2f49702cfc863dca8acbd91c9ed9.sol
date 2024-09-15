// SPDX-License-Identifier: Unlicense

// 
pragma solidity 0.8.13;








///      -> safe.execTransactionFromModule()
///      -> RainbowRouter.withdrawX() (called by our Gnosis safe instance)
contract FeeCollector {

    /// the gnosis safe we execute withdrawals from
    GnosisSafe public immutable safe;

    
    address public caller;

    
    address public receiver;

    
    address public router;

    
    uint256 public minExpectedBalance;

    
    modifier onlySafe() {
        require(msg.sender == address(safe), "FC: CALLER_NOT_SAFE");
        _;
    }

    
    modifier onlyCaller() {
        require(msg.sender == address(caller), "FC: CALLER_NOT_ALLOWED");
        _;
    }

    
    
    
    constructor(address _caller, address _receiver, address _router, address _safe, uint256 _threshold) {
        caller = _caller;
        receiver = _receiver;
        router = _router;
        safe = GnosisSafe(_safe);
        minExpectedBalance = _threshold;
    }

    
    
    
    function collectETHFees(uint256 amount) external onlyCaller {

        // if our bot's ETH balance is below the threshold, we have to top it up again using funds from the safe
        uint256 initialCallerBalance = caller.balance;

        // amount we top up the bot with, 0 unless minExpectedBalance > initialCallerBalance
        uint256 topUpAmount = 0;

        if (minExpectedBalance > initialCallerBalance) {
            uint256 delta = minExpectedBalance - initialCallerBalance;
            topUpAmount = amount <= delta ? amount : delta;

            require(
                safe.execTransactionFromModule(
                    router,
                    0,
                    abi.encodeWithSelector(
                        RainbowRouter.withdrawEth.selector,
                        caller,
                        topUpAmount
                    ),
                    GnosisSafe.Operation.CALL
                ),
                "FC: EW_FAILED"
            );
        }

        // if topUpAmount == amount, then amount - topUpAmount == 0
        // a transfer of 0 tokens would just waste gas so let's avoid it
        uint256 amountLeftToWithdraw = amount - topUpAmount;
        if (amountLeftToWithdraw > 0) {
            require(
                safe.execTransactionFromModule(
                    router,
                    0,
                    abi.encodeWithSelector(
                        RainbowRouter.withdrawEth.selector,
                        receiver,
                        amountLeftToWithdraw
                    ),
                    GnosisSafe.Operation.CALL
                ),
                "FC: EW_FAILED"
            );
        }

    }

    
    
    
    
    function collectTokenFees(address token, uint256 amount) external onlyCaller {
        require(
            safe.execTransactionFromModule(
                router,
                0,
                abi.encodeWithSelector(
                    RainbowRouter.withdrawToken.selector,
                    token,
                    receiver,
                    amount
                ),
                GnosisSafe.Operation.CALL
            ),
            "FC: TW_FAILED"
        );
    }

    
    ///      This update can only be performed by the safe, via a safe transaction
    
    function updateCaller(address newCaller) external onlySafe {
        caller = newCaller;
    }

    
    ///      This update can only be performed by the safe, via a safe transaction
    
    function updateReceiver(address newReceiver) external onlySafe {
        receiver = newReceiver;
    }

    
    ///      This update can only be performed by the safe, via a safe transaction
    
    function updateRouter(address newRouter) external onlySafe {
        router = newRouter;
    }

    
    ///      This update can only be performed by the safe
    
    function updateMinBalance(uint256 newMinBalance) external onlySafe {
        minExpectedBalance = newMinBalance;
    }

    
    
    
    function multicall(bytes[] calldata data) public payable returns (bytes[] memory results) {
        uint256 length = data.length;
        results = new bytes[](length);
        bytes calldata call;
        bytes memory result;
        for (uint256 i = 0; i < length;) {
            bool success;
            call = data[i];
            (success, results[i]) = address(this).delegatecall(data[i]);
            result = results[i];
            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }
            unchecked { ++i; }
        }
    }
}

// 
pragma solidity 0.8.13;

interface GnosisSafe {
    enum Operation {
        CALL,
        DELEGATECALL
    }

    
    ///      This can only be done via a Safe transaction.
    
    
    function enableModule(address module) external;

    
    
    
    
    
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Operation operation
    ) external returns (bool);

    
    
    
    
    
    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Operation operation
    ) external returns (bool, bytes memory);
}

// 
pragma solidity 0.8.13;


interface RainbowRouter {

    
    
    
    function withdrawEth(
        address to, 
        uint256 amount
    ) external;

    
    
    
    
    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external;
}