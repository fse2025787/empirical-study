// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.0;

// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol + Claimable.sol
// Simplified by BoringCrypto

contract BoringOwnableData {
    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    
    /// Can only be invoked by the current `owner`.
    
    
    
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

// 
pragma solidity ^0.8.0;

interface IERC20 {
    // transfer and tranferFrom have been removed, because they don't work on all tokens (some aren't ERC20 complaint).
    // By removing them you can't accidentally use them.
    // name, symbol and decimals have been removed, because they are optional and sometimes wrongly implemented (MKR).
    // Use BoringERC20 with `using BoringERC20 for IERC20` and call `safeTransfer`, `safeTransferFrom`, etc instead.
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IStrictERC20 {
    // This is the strict ERC20 interface. Don't use this, certainly not if you don't control the ERC20 token you're calling.
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// 
pragma solidity ^0.8.0;


// solhint-disable avoid-low-level-calls

library BoringERC20 {
    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_BALANCE_OF = 0x70a08231; // balanceOf(address)
    bytes4 private constant SIG_TOTALSUPPLY = 0x18160ddd; // balanceOf(address)
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    function returnDataToString(bytes memory data) internal pure returns (string memory) {
        if (data.length >= 64) {
            return abi.decode(data, (string));
        } else if (data.length == 32) {
            uint8 i = 0;
            while (i < 32 && data[i] != 0) {
                i++;
            }
            bytes memory bytesArray = new bytes(i);
            for (i = 0; i < 32 && data[i] != 0; i++) {
                bytesArray[i] = data[i];
            }
            return string(bytesArray);
        } else {
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

    
    
    
    
    function safeBalanceOf(IERC20 token, address to) internal view returns (uint256 amount) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_BALANCE_OF, to));
        require(success && data.length >= 32, "BoringERC20: BalanceOf failed");
        amount = abi.decode(data, (uint256));
    }

    
    
    
    function safeTotalSupply(IERC20 token) internal view returns (uint256 totalSupply) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_TOTALSUPPLY));
        require(success && data.length >= 32, "BoringERC20: totalSupply failed");
        totalSupply = abi.decode(data, (uint256));
    }

    
    /// Reverts on a failed transfer.
    
    
    
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
    }

    
    /// Reverts on a failed transfer.
    
    
    
    
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
    }
}

// 
pragma solidity ^0.8.0;

struct Rebase {
    uint128 elastic;
    uint128 base;
}


library RebaseLibrary {
    
    function toBase(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (uint256 base) {
        if (total.elastic == 0) {
            base = elastic;
        } else {
            base = (elastic * total.base) / total.elastic;
            if (roundUp && (base * total.elastic) / total.base < elastic) {
                base++;
            }
        }
    }

    
    function toElastic(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (uint256 elastic) {
        if (total.base == 0) {
            elastic = base;
        } else {
            elastic = (base * total.elastic) / total.base;
            if (roundUp && (elastic * total.base) / total.elastic < base) {
                elastic++;
            }
        }
    }

    
    
    
    function add(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 base) {
        base = toBase(total, elastic, roundUp);
        total.elastic += uint128(elastic);
        total.base += uint128(base);
        return (total, base);
    }

    
    
    
    function sub(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 elastic) {
        elastic = toElastic(total, base, roundUp);
        total.elastic -= uint128(elastic);
        total.base -= uint128(base);
        return (total, elastic);
    }

    
    function add(
        Rebase memory total,
        uint256 elastic,
        uint256 base
    ) internal pure returns (Rebase memory) {
        total.elastic += uint128(elastic);
        total.base += uint128(base);
        return total;
    }

    
    function sub(
        Rebase memory total,
        uint256 elastic,
        uint256 base
    ) internal pure returns (Rebase memory) {
        total.elastic -= uint128(elastic);
        total.base -= uint128(base);
        return total;
    }

    
    
    function addElastic(Rebase storage total, uint256 elastic) internal returns (uint256 newElastic) {
        newElastic = total.elastic += uint128(elastic);
    }

    
    
    function subElastic(Rebase storage total, uint256 elastic) internal returns (uint256 newElastic) {
        newElastic = total.elastic -= uint128(elastic);
    }
}

// 
pragma solidity >=0.8.0;





interface IFlashBorrower {
    
    
    
    
    
    
    function onFlashLoan(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external;
}

interface IBatchFlashBorrower {
    
    
    
    
    
    
    function onBatchFlashLoan(
        address sender,
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        uint256[] calldata fees,
        bytes calldata data
    ) external;
}

interface IBentoBoxV1 {
    function balanceOf(IERC20, address) external view returns (uint256);

    function batch(bytes[] calldata calls, bool revertOnFail) external payable returns (bool[] memory successes, bytes[] memory results);

    function batchFlashLoan(
        IBatchFlashBorrower borrower,
        address[] calldata receivers,
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function claimOwnership() external;

    function flashLoan(
        IFlashBorrower borrower,
        address receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;

    function deploy(
        address masterContract,
        bytes calldata data,
        bool useCreate2
    ) external payable returns (address);

    function deposit(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);

    function harvest(
        IERC20 token,
        bool balance,
        uint256 maxChangeAmount
    ) external;

    function masterContractApproved(address, address) external view returns (bool);

    function masterContractOf(address) external view returns (address);

    function nonces(address) external view returns (uint256);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function pendingStrategy(IERC20) external view returns (IStrategy);

    function permitToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function registerProtocol() external;

    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function setStrategy(IERC20 token, IStrategy newStrategy) external;

    function setStrategyTargetPercentage(IERC20 token, uint64 targetPercentage_) external;

    function strategy(IERC20) external view returns (IStrategy);

    function strategyData(IERC20)
        external
        view
        returns (
            uint64 strategyStartDate,
            uint64 targetPercentage,
            uint128 balance
        );

    function toAmount(
        IERC20 token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);

    function toShare(
        IERC20 token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);

    function totals(IERC20) external view returns (Rebase memory totals_);

    function transfer(
        IERC20 token,
        address from,
        address to,
        uint256 share
    ) external;

    function transferMultiple(
        IERC20 token,
        address from,
        address[] calldata tos,
        uint256[] calldata shares
    ) external;

    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) external;

    function whitelistMasterContract(address masterContract, bool approved) external;

    function whitelistedMasterContracts(address) external view returns (bool);

    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);
}

// 
pragma solidity >=0.8.0;

interface IStrategy {
    
    
    function skim(uint256 amount) external;

    
    
    
    
    function harvest(uint256 balance, address sender) external returns (int256 amountAdded);

    
    
    /// The difference should NOT be used to report a loss. That's what harvest is for.
    
    
    function withdraw(uint256 amount) external returns (uint256 actualAmount);

    
    
    
    function exit(uint256 balance) external returns (int256 amountAdded);
}

// 
pragma solidity >=0.8.0;

interface IUniswapV2Pair {
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function skim(address to) external;

    function sync() external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external pure returns (address);

    function token1() external pure returns (address);
}

// 

pragma solidity >=0.8.0;








abstract contract BaseStrategy is IStrategy, BoringOwnable {
    using BoringERC20 for IERC20;

    IERC20 public immutable strategyToken;
    IBentoBoxV1 public immutable bentoBox;

    bool public exited; 
    uint256 public maxBentoBoxBalance; 
    mapping(address => bool) public strategyExecutors; 
    event LogSetStrategyExecutor(address indexed executor, bool allowed);

    /** @param _strategyToken Address of the underlying token the strategy invests.
        @param _bentoBox BentoBox address.
    */
    constructor(
        IERC20 _strategyToken,
        IBentoBoxV1 _bentoBox
    ) {
        strategyToken = _strategyToken;
        bentoBox = _bentoBox;
    }

    //** Strategy implementation: override the following functions: */

    
    
    
    function _skim(uint256 amount) internal virtual {}

    
    
    
    
    /// amountAdded should not reflect any rewards or tokens the strategy received.
    /// Calcualte the amount added based on what the current deposit is worth.
    /// (The Base Strategy harvest function accounts for rewards).
    function _harvest(uint256 balance) internal virtual returns (int256 amountAdded) {}

    
    
    function _withdraw(uint256 amount) internal virtual {}

    
    
    function _exit() internal virtual {}

    
    
    function _harvestRewards() internal virtual {}

    //** End strategy implementation */

    modifier isActive() {
        require(!exited, "BentoBox Strategy: exited");
        _;
    }

    modifier onlyBentoBox() {
        require(msg.sender == address(bentoBox), "BentoBox Strategy: only BentoBox");
        _;
    }

    modifier onlyExecutor() {
        require(strategyExecutors[msg.sender], "BentoBox Strategy: only Executors");
        _;
    }

    function setStrategyExecutor(address executor, bool value) external onlyOwner {
        strategyExecutors[executor] = value;
        emit LogSetStrategyExecutor(executor, value);
    }

    
    function skim(uint256 amount) virtual external override {
        _skim(amount);
    }

    
    
    
    
    
    
    
    function safeHarvest(
        uint256 maxBalance,
        bool rebalance,
        uint256 maxChangeAmount,
        bool harvestRewards
    ) external onlyExecutor {
        if (harvestRewards) {
            _harvestRewards();
        }

        if (maxBalance > 0) {
            maxBentoBoxBalance = maxBalance;
        }

        IBentoBoxV1(bentoBox).harvest(strategyToken, rebalance, maxChangeAmount);
    }

    /** @inheritdoc IStrategy
    @dev Only BentoBox can call harvest on this strategy.
    @dev Ensures that (1) the caller was this contract (called through the safeHarvest function)
        and (2) that we are not being frontrun by a large BentoBox deposit when harvesting profits. */
    function harvest(uint256 balance, address sender) virtual external override isActive onlyBentoBox returns (int256) {
        /** @dev Don't revert if conditions aren't met in order to allow
            BentoBox to continiue execution as it might need to do a rebalance. */

        if (sender == address(this) && IBentoBoxV1(bentoBox).totals(strategyToken).elastic <= maxBentoBoxBalance && balance > 0) {
            int256 amount = _harvest(balance);

            /** @dev Since harvesting of rewards is accounted for seperately we might also have
            some underlying tokens in the contract that the _harvest call doesn't report. 
            E.g. reward tokens that have been sold into the underlying tokens which are now sitting in the contract.
            Meaning the amount returned by the internal _harvest function isn't necessary the final profit/loss amount */

            uint256 contractBalance = strategyToken.balanceOf(address(this));

            if (amount >= 0) {
                // _harvest reported a profit

                if (contractBalance > 0) {
                    strategyToken.safeTransfer(address(bentoBox), contractBalance);
                }

                return int256(contractBalance);
            } else if (contractBalance > 0) {
                // _harvest reported a loss but we have some tokens sitting in the contract

                int256 diff = amount + int256(contractBalance);

                if (diff > 0) {
                    // we still made some profit

                    
                    strategyToken.safeTransfer(address(bentoBox), uint256(diff));
                    _skim(uint256(-amount));
                } else {
                    // we made a loss but we have some tokens we can reinvest

                    _skim(contractBalance);
                }

                return diff;
            } else {
                // we made a loss

                return amount;
            }
        }

        return int256(0);
    }

    
    function withdraw(uint256 amount) virtual external override isActive onlyBentoBox returns (uint256 actualAmount) {
        _withdraw(amount);
        
        actualAmount = strategyToken.balanceOf(address(this));
        strategyToken.safeTransfer(address(bentoBox), actualAmount);
    }

    
    
    function exit(uint256 balance) virtual external override onlyBentoBox returns (int256 amountAdded) {
        _exit();
        
        uint256 actualBalance = strategyToken.balanceOf(address(this));
        
        amountAdded = int256(actualBalance) - int256(balance);
        
        strategyToken.safeTransfer(address(bentoBox), actualBalance);
        
        exited = true;
    }

    /** @dev After exited, the owner can perform ANY call. This is to rescue any funds that didn't
        get released during exit or got earned afterwards due to vesting or airdrops, etc. */
    function afterExit(
        address to,
        uint256 value,
        bytes memory data
    ) public onlyOwner returns (bool success) {
        require(exited, "BentoBox Strategy: not exited");

        // solhint-disable-next-line avoid-low-level-calls
        (success, ) = to.call{value: value}(data);
    }
}

// 
pragma solidity >=0.8.0;





contract InterestStrategy is BaseStrategy {
    using BoringERC20 for IERC20;

    error InsupportedToken();
    error InvalidInterestRate();
    error SwapFailed();
    error InsufficientAmountOut();
    error InvalidFeeTo();
    error InvalidMaxInterestPerSecond();
    error InvalidLerpParameters();

    event LogAccrue(uint256 accruedAmount);
    event LogInterestChanged(uint64 interestPerSecond);
    event LogInterestWithLerpChanged(uint64 startInterestPerSecond, uint64 targetInterestPerSecond, uint64 duration);
    event FeeToChanged(address previous, address current);
    event SwapperChanged(address previous, address current);
    event Swap(uint256 amountIn, uint256 amountOut);
    event SwapTokenOutEnabled(IERC20 token, bool enabled);
    event SwapAndWithdrawFee(uint256 amountIn, uint256 amountOut, IERC20 tokenOut);
    event WithdrawFee(uint256 amount);
    event EmergencyExitEnabled(bool enabled);

    uint256 private constant WAD = 1e18;

    // Interest linear interpolation to destination in a given time
    // ex: 1% -> 13% in 30 days.
    struct InterestLerp {
        uint64 startTime;
        uint64 startInterestPerSecond;
        uint64 targetInterestPerSecond;
        uint64 duration;
    }

    // slot grouping
    uint128 public pendingFeeEarned;
    uint128 public pendingFeeEarnedAdjustement;

    // slot grouping
    uint64 public lastAccrued;
    uint64 public interestPerSecond;
    bool public emergencyExitEnabled;

    address public feeTo;
    address public swapper;
    uint256 public principal;
    mapping(IERC20 => bool) public swapTokenOutEnabled;
    InterestLerp public interestLerp;

    constructor(
        IERC20 _strategyToken,
        IERC20 _mim,
        IBentoBoxV1 _bentoBox,
        address _feeTo
    ) BaseStrategy(_strategyToken, _bentoBox) {
        feeTo = _feeTo;
        swapTokenOutEnabled[_mim] = true;

        emit FeeToChanged(address(0), _feeTo);
        emit SwapTokenOutEnabled(_mim, true);
    }

    function getYearlyInterestBips() external view returns (uint256) {
        return (interestPerSecond * 100) / 316880878;
    }

    function _updateInterestPerSecond() private {
        if (interestLerp.duration == 0) {
            return;
        }

        
        if (block.timestamp < interestLerp.startTime + interestLerp.duration) {
            uint256 t = ((block.timestamp - interestLerp.startTime) * WAD) / interestLerp.duration;
            interestPerSecond = uint64(
                (interestLerp.targetInterestPerSecond * t) /
                    WAD +
                    interestLerp.startInterestPerSecond -
                    (interestLerp.startInterestPerSecond * t) /
                    WAD
            );
        } else {
            interestPerSecond = interestLerp.targetInterestPerSecond;
            interestLerp.duration = 0;
        }
    }

    function skim(uint256) external override isActive onlyBentoBox {
        principal = availableAmount();
    }

    
    /// The interest linear interpolation used here is very basic: the more this function is called the smoother
    /// the interpolation.
    /// Meaning that if we're ramping from 1% to 13% in 30 days and that harvest is called only once on
    /// the 15th day, 1% interest will be used for these 15 days and then the next harvest will be around 7%.
    /// If we are calling it daily it will smoothly increase by steps of 0.4% (12% / 30 days)
    function harvest(uint256 balance, address sender) external virtual override isActive onlyBentoBox returns (int256) {
        if (sender == address(this) && balance > 0) {
            uint256 accrued = _accrue();

            // add the potential accrued interest collected from changing the interest rate, since
            // this didn't harvest & reported loss yet.
            accrued += pendingFeeEarnedAdjustement;
            pendingFeeEarnedAdjustement = 0;

            return -int256(accrued);
        }

        return int256(0);
    }

    function withdraw(uint256 amount) external override isActive onlyBentoBox returns (uint256 actualAmount) {
        uint256 maxAvailableAmount = availableAmount();

        if (maxAvailableAmount > 0) {
            actualAmount = amount > maxAvailableAmount ? maxAvailableAmount : amount;
            maxAvailableAmount -= actualAmount;
            strategyToken.safeTransfer(address(bentoBox), actualAmount);
        }

        principal = availableAmount();
    }

    function exit(uint256 amount) external override onlyBentoBox returns (int256 amountAdded) {
        // in case something wrong happen, we can exit and use `afterExit` once we've exited.
        if (emergencyExitEnabled) {
            exited = true;
            return int256(0);
        }

        _accrue();
        uint256 maxAvailableAmount = availableAmount();

        if (maxAvailableAmount > 0) {
            uint256 actualAmount = amount > maxAvailableAmount ? maxAvailableAmount : amount;
            amountAdded = int256(actualAmount) - int256(amount);

            if (actualAmount > 0) {
                strategyToken.safeTransfer(address(bentoBox), actualAmount);
            }
        }

        principal = 0;
        exited = true;
    }

    function availableAmount() public view returns (uint256 amount) {
        uint256 balance = strategyToken.balanceOf(address(this));

        if (balance > pendingFeeEarned) {
            amount = balance - pendingFeeEarned;
        }
    }

    function withdrawFees() external onlyExecutor returns (uint256) {
        IERC20(strategyToken).safeTransfer(feeTo, pendingFeeEarned);

        emit WithdrawFee(pendingFeeEarned);
        pendingFeeEarned = 0;

        return pendingFeeEarned;
    }

    function swapAndwithdrawFees(
        uint256 amountOutMin,
        IERC20 tokenOut,
        bytes calldata data
    ) external onlyExecutor returns (uint256) {
        if (!swapTokenOutEnabled[tokenOut]) {
            revert InsupportedToken();
        }

        uint256 amountInBefore = IERC20(strategyToken).balanceOf(address(this));
        uint256 amountOutBefore = tokenOut.balanceOf(address(this));

        (bool success, ) = swapper.call(data);
        if (!success) {
            revert SwapFailed();
        }

        uint256 amountOut = tokenOut.balanceOf(address(this)) - amountOutBefore;
        if (amountOut < amountOutMin) {
            revert InsufficientAmountOut();
        }

        uint256 amountIn = amountInBefore - IERC20(strategyToken).balanceOf(address(this));
        pendingFeeEarned -= uint128(amountIn);

        tokenOut.safeTransfer(feeTo, amountOut);
        emit SwapAndWithdrawFee(amountIn, amountOut, tokenOut);

        return amountOut;
    }

    function _accrue() private returns (uint128 interest) {
        if (lastAccrued == 0) {
            // we want to start accruing interests as soon as there's a deposited amount.
            if (principal > 0) {
                lastAccrued = uint64(block.timestamp);
            }
            return 0;
        }

        // Number of seconds since accrue was called
        uint256 elapsedTime = block.timestamp - lastAccrued;
        if (elapsedTime == 0) {
            return 0;
        }

        lastAccrued = uint64(block.timestamp);

        if (principal == 0) {
            return 0;
        }

        // Accrue interest
        interest = uint128((principal * interestPerSecond * elapsedTime) / 1e18);
        pendingFeeEarned += interest;

        _updateInterestPerSecond();
        emit LogAccrue(interest);
    }

    function setFeeTo(address _feeTo) external onlyOwner {
        if (_feeTo == address(0)) {
            revert InvalidFeeTo();
        }

        emit FeeToChanged(feeTo, _feeTo);
        feeTo = _feeTo;
    }

    function setSwapper(address _swapper) external onlyOwner {
        if (swapper != address(0)) {
            strategyToken.approve(swapper, 0);
        }

        strategyToken.approve(_swapper, type(uint256).max);
        emit SwapperChanged(swapper, _swapper);
        swapper = _swapper;
    }

    function setSwapTokenOutEnabled(IERC20 token, bool enabled) external onlyOwner {
        swapTokenOutEnabled[token] = enabled;
        emit SwapTokenOutEnabled(token, enabled);
    }

    function setInterestPerSecond(uint64 _interestPerSecond) public onlyOwner {
        pendingFeeEarnedAdjustement += _accrue();
        interestPerSecond = _interestPerSecond;
        interestLerp.duration = 0;

        emit LogInterestChanged(interestPerSecond);
    }

    function setInterestPerSecondWithLerp(
        uint64 startInterestPerSecond,
        uint64 targetInterestPerSecond,
        uint64 duration
    ) public onlyOwner {
        if (duration == 0 || duration > 365 days || targetInterestPerSecond <= startInterestPerSecond) {
            revert InvalidLerpParameters();
        }

        pendingFeeEarnedAdjustement += _accrue();
        interestPerSecond = startInterestPerSecond;
        interestLerp.duration = duration;
        interestLerp.startTime = uint64(block.timestamp);
        interestLerp.startInterestPerSecond = startInterestPerSecond;
        interestLerp.targetInterestPerSecond = targetInterestPerSecond;

        emit LogInterestWithLerpChanged(startInterestPerSecond, targetInterestPerSecond, duration);
    }

    function setEmergencyExitEnabled(bool _emergencyExitEnabled) external onlyOwner {
        emergencyExitEnabled = _emergencyExitEnabled;
        emit EmergencyExitEnabled(_emergencyExitEnabled);
    }
}