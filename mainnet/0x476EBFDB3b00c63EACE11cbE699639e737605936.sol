// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 

pragma solidity >=0.6.0 <0.8.0;

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
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;


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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity >=0.6.0 <0.8.0;


/// 








contract HelperImpl is Ownable {
    address public constant bZxProtocol = 0xD8Ee69652E4e4838f2531732a46d1f7F584F0b7f; // mainnet
    //address public constant bZxProtocol = 0x5cfba2639a3db0D9Cc264Aa27B2E6d134EeA486a; // kovan
    // address public constant bZxProtocol = 0xD154eE4982b83a87b0649E5a7DDA1514812aFE1f; // bsc
    // address public constant bZxProtocol = 0x059D60a9CEfBc70b9Ea9FFBb9a041581B1dFA6a8; // polygon
    // address public constant bZxProtocol = 0x37407F3178ffE07a6cF5C847F8f680FEcf319FAB; // arbitrum
    //address public constant bZxProtocol = 0xf2FBaD7E59f0DeeE0ec2E724d2b6827Ea1cCf35f; // evmos
    // address public constant bZxProtocol = 0xAcedbFd5Bc1fb0dDC948579d4195616c05E74Fd1; // optimism

    address public constant wethToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // mainnet
    // address public constant wethToken = 0xd0A1E359811322d97991E03f863a0C30C2cF029C; // kovan
    // address public constant wethToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // bsc
    // address public constant wethToken = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270; // polygon
    // address public constant wethToken = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1; // arbitrum
    // address public constant wethToken = 0xD4949664cD82660AaE99bEdc034a0deA8A0bd517; // evmos
    // address public constant wethToken = 0x4200000000000000000000000000000000000006; // optimism

    uint256 internal constant WEI_PRECISION = 10**18;
    uint256 internal constant WEI_PERCENT_PRECISION = 10**20;

    function balanceOf(IERC20[] calldata tokens, address wallet) public view returns (uint256[] memory balances) {
        balances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            balances[i] = tokens[i].balanceOf(wallet);
        }
    }

    function totalSupply(IERC20[] calldata tokens) public view returns (uint256[] memory totalSupply) {
        totalSupply = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            totalSupply[i] = tokens[i].totalSupply();
        }
    }

    function allowance(
        IERC20[] calldata tokens,
        address owner,
        address spender
    ) public view returns (uint256[] memory allowances) {
        allowances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            allowances[i] = tokens[i].allowance(owner, spender);
        }
    }

    function tokenPrice(IToken[] calldata tokens) public view returns (uint256[] memory prices) {
        prices = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            prices[i] = tokens[i].tokenPrice();
        }
    }

    function supplyInterestRate(IToken[] calldata tokens) public view returns (uint256[] memory rates) {
        rates = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            rates[i] = tokens[i].supplyInterestRate();
        }
    }

    function borrowInterestRate(IToken[] calldata tokens) public view returns (uint256[] memory rates) {
        rates = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            rates[i] = tokens[i].borrowInterestRate();
        }
    }

    function assetBalanceOf(IToken[] calldata tokens, address wallet) public view returns (uint256[] memory balances) {
        balances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            balances[i] = tokens[i].assetBalanceOf(wallet);
        }
    }

    function profitOf(IToken[] calldata tokens, address wallet) public view returns (int256[] memory profits) {
        profits = new int256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            profits[i] = tokens[i].profitOf(wallet);
        }
    }

    function marketLiquidity(IToken[] calldata tokens) public view returns (uint256[] memory liquidity) {
        liquidity = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            liquidity[i] = IERC20(tokens[i].loanTokenAddress()).balanceOf(address(tokens[i]));
        }
    }

    struct ReserveDetail {
        address iToken;
        uint256 totalAssetSupply;
        uint256 totalAssetBorrow;
        uint256 supplyInterestRate;
        uint256 borrowInterestRate;
        uint256 torqueBorrowInterestRate;
        uint256 vaultBalance;
    }

    function reserveDetails(IToken[] calldata tokens) public view returns (ReserveDetail[] memory reserveDetails) {
        reserveDetails = new ReserveDetail[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            reserveDetails[i].iToken = address(tokens[i]);
            reserveDetails[i].totalAssetSupply = tokens[i].totalAssetSupply();
            reserveDetails[i].totalAssetBorrow = tokens[i].totalAssetBorrow();
            reserveDetails[i].supplyInterestRate = tokens[i].supplyInterestRate();
            reserveDetails[i].borrowInterestRate = tokens[i].borrowInterestRate();
            reserveDetails[i].torqueBorrowInterestRate = tokens[i].nextBorrowInterestRate(0);
            reserveDetails[i].vaultBalance = IERC20(tokens[i].loanTokenAddress()).balanceOf(bZxProtocol);
        }
    }

    struct AssetRates {
        uint256 rate;
        uint256 precision;
        uint256 destAmount;
    }

    function assetRates(
        address usdTokenAddress,
        address[] memory tokens,
        uint256[] memory sourceAmounts
    ) public view returns (AssetRates[] memory assetRates) {
        IPriceFeeds feeds = IPriceFeeds(IBZx(bZxProtocol).priceFeeds());
        assetRates = new AssetRates[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            (assetRates[i].rate, assetRates[i].precision) = feeds.queryRate(tokens[i], usdTokenAddress);

            if (sourceAmounts[i] != 0) {
                assetRates[i].destAmount = sourceAmounts[i] * assetRates[i].rate;
                require(assetRates[i].destAmount / sourceAmounts[i] == assetRates[i].rate, "overflow");
                assetRates[i].destAmount = assetRates[i].destAmount / assetRates[i].precision;
            }
        }
    }

    function getDepositAmountForBorrow(
        uint256 borrowAmount,
        address loanTokenAddress,
        address collateralTokenAddress // address(0) means ETH
    )
        external
        view
        returns (
            uint256 // depositAmount
        )
    {
        IToken iToken = IToken(IBZx(bZxProtocol).underlyingToLoanPool(loanTokenAddress));
        if (borrowAmount != 0) {
            if (borrowAmount <= IERC20(loanTokenAddress).balanceOf(address(iToken))) {
                if (collateralTokenAddress == address(0)) {
                    collateralTokenAddress = wethToken;
                }
                (IBZx.LoanParams memory loanParam, ) = IBZx(bZxProtocol).getDefaultLoanParams(loanTokenAddress, collateralTokenAddress, true);
                return
                    getRequiredCollateralByParams(
                        // iToken.loanParamsIds(uint256(keccak256(abi.encodePacked(
                        //     collateralTokenAddress,
                        //     true
                        // )))),
                        loanParam,
                        borrowAmount
                    ) + 10; // some dust to compensate for rounding errors
            }
        }
    }

    function getBorrowAmountForDeposit(
        uint256 depositAmount,
        address loanTokenAddress,
        address collateralTokenAddress // address(0) means ETH
    ) external view returns (uint256 borrowAmount) {
        IToken iToken = IToken(IBZx(bZxProtocol).underlyingToLoanPool(loanTokenAddress));
        if (depositAmount != 0) {
            if (collateralTokenAddress == address(0)) {
                collateralTokenAddress = wethToken;
            }
            (IBZx.LoanParams memory loanParam, ) = IBZx(bZxProtocol).getDefaultLoanParams(loanTokenAddress, collateralTokenAddress, true);
            borrowAmount = getBorrowAmountByParams(
                // iToken.loanParamsIds(uint256(keccak256(abi.encodePacked(
                //     collateralTokenAddress,
                //     true
                // )))),
                loanParam,
                depositAmount
            );
            if (borrowAmount > IERC20(loanTokenAddress).balanceOf(address(iToken))) {
                borrowAmount = 0;
            }
        }
    }

    function getRequiredCollateralByParams(IBZx.LoanParams memory loanParamsLocal, uint256 newPrincipal) public view returns (uint256 collateralAmountRequired) {
        // IBZx.LoanParams memory loanParamsLocal = IBZx(bZxProtocol).loanParams(loanParamsId);
        return
            IBZx(bZxProtocol).getRequiredCollateral(
                loanParamsLocal.loanToken,
                loanParamsLocal.collateralToken,
                newPrincipal,
                loanParamsLocal.minInitialMargin, // marginAmount
                loanParamsLocal.maxLoanTerm == 0 // isTorqueLoan
                    ? true
                    : false
            );
    }

    function getBorrowAmountByParams(IBZx.LoanParams memory loanParamsLocal, uint256 collateralTokenAmount) internal view returns (uint256 borrowAmount) {
        // IBZx.LoanParams memory loanParamsLocal = IBZx(bZxProtocol).loanParams(loanParamsId);
        return
            getBorrowAmount(
                loanParamsLocal.loanToken,
                loanParamsLocal.collateralToken,
                collateralTokenAmount,
                loanParamsLocal.minInitialMargin, // marginAmount
                loanParamsLocal.maxLoanTerm == 0 // isTorqueLoan
                    ? true
                    : false
            );
    }

    function getBorrowAmount(
        address loanToken,
        address collateralToken,
        uint256 collateralTokenAmount,
        uint256 marginAmount,
        bool isTorqueLoan
    ) internal view returns (uint256 borrowAmount) {
        if (marginAmount != 0) {
            if (isTorqueLoan) {
                marginAmount = marginAmount + (WEI_PERCENT_PRECISION); // adjust for over-collateralized loan
            }

            if (loanToken == collateralToken) {
                borrowAmount = (collateralTokenAmount * (WEI_PERCENT_PRECISION)) / (marginAmount);
            } else {
                (uint256 sourceToDestRate, uint256 sourceToDestPrecision) = IPriceFeeds(IBZx(bZxProtocol).priceFeeds()).queryRate(collateralToken, loanToken);
                if (sourceToDestPrecision != 0) {
                    borrowAmount = (collateralTokenAmount * (WEI_PERCENT_PRECISION) * (sourceToDestRate)) / (marginAmount) / (sourceToDestPrecision);
                }
            }

            uint256 feePercent = isTorqueLoan ? IBZx(bZxProtocol).borrowingFeePercent() : IBZx(bZxProtocol).tradingFeePercent();
            if (borrowAmount != 0 && feePercent != 0) {
                borrowAmount =
                    (borrowAmount * (WEI_PERCENT_PRECISION - feePercent)) / // never will overflow
                    (WEI_PERCENT_PRECISION);
            }
        }
    }

}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity >=0.5.0 <0.9.0;


interface IPriceFeeds {

    function pricesFeeds(address token)
        external
        view
        returns(address pricefeed);

    function queryRate(
        address sourceToken,
        address destToken)
        external
        view
        returns (uint256 rate, uint256 precision);

    function queryPrecision(
        address sourceToken,
        address destToken)
        external
        view
        returns (uint256 precision);

    function queryReturn(
        address sourceToken,
        address destToken,
        uint256 sourceAmount)
        external
        view
        returns (uint256 destAmount);

    function checkPriceDisagreement(
        address sourceToken,
        address destToken,
        uint256 sourceAmount,
        uint256 destAmount,
        uint256 maxSlippage)
        external
        view
        returns (uint256 sourceToDestSwapRate);

    function amountInEth(
        address Token,
        uint256 amount)
        external
        view
        returns (uint256 ethAmount);

    function getMaxDrawdown(
        address loanToken,
        address collateralToken,
        uint256 loanAmount,
        uint256 collateralAmount,
        uint256 maintenanceMargin)
        external
        view
        returns (uint256);

    function getCurrentMarginAndCollateralSize(
        address loanToken,
        address collateralToken,
        uint256 loanAmount,
        uint256 collateralAmount)
        external
        view
        returns (uint256 currentMargin, uint256 collateralInEthAmount);

    function getCurrentMargin(
        address loanToken,
        address collateralToken,
        uint256 loanAmount,
        uint256 collateralAmount)
        external
        view
        returns (uint256 currentMargin, uint256 collateralToLoanRate);

    function shouldLiquidate(
        address loanToken,
        address collateralToken,
        uint256 loanAmount,
        uint256 collateralAmount,
        uint256 maintenanceMargin)
        external
        view
        returns (bool);
}

/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache-2.0
 */

pragma solidity >=0.5.0 <0.9.0;

// import "IERC20.sol";

// import "IERC20.sol";
// 

interface IToken {

    // IERC20 specification. hard including it to avoid compatibility of openzeppelin with different libraries
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed minter,uint256 tokenAmount,uint256 assetAmount,uint256 price);
    event Burn(address indexed burner,uint256 tokenAmount,uint256 assetAmount,uint256 price);
    event FlashBorrow(address borrower,address target,address loanToken,uint256 loanAmount);

    function tokenPrice() external view returns (uint256);

    function mint(address receiver, uint256 depositAmount)
        external
        returns (uint256);

    function burn(address receiver, uint256 burnAmount)
        external
        returns (uint256 loanAmountPaid);

    function flashBorrow(
        uint256 borrowAmount,
        address borrower,
        address target,
        string calldata signature,
        bytes calldata data
    ) external payable returns (bytes memory);

    function borrow(
        bytes32 loanId, // 0 if new loan
        uint256 withdrawAmount,
        uint256 initialLoanDuration, // duration in seconds
        uint256 collateralTokenSent, // if 0, loanId must be provided; any ETH sent must equal this value
        address collateralTokenAddress, // if address(0), this means ETH and ETH must be sent with the call or loanId must be provided
        address borrower,
        address receiver,
        bytes calldata loanDataBytes // arbitrary order data
    ) external payable returns (LoanOpenData memory);

    function marginTrade(
        bytes32 loanId, // 0 if new loan
        uint256 leverageAmount,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        address collateralTokenAddress,
        address trader,
        bytes calldata loanDataBytes // arbitrary order data
    ) external payable returns (LoanOpenData memory);

    function profitOf(address user) external view returns (int256);

    function checkpointPrice(address _user) external view returns (uint256);

    function borrowInterestRate() external view returns (uint256);

    function nextBorrowInterestRate(uint256 borrowAmount)
        external
        view
        returns (uint256);

    function supplyInterestRate() external view returns (uint256);

    function nextSupplyInterestRate(int256 supplyAmount)
        external
        view
        returns (uint256);

    function totalSupplyInterestRate(uint256 assetSupply)
        external
        view
        returns (uint256);

    function totalAssetBorrow() external view returns (uint256);

    function totalAssetSupply() external view returns (uint256);

    function assetBalanceOf(address _owner) external view returns (uint256);

    function loanTokenAddress() external view returns (address);

    function initialPrice() external view returns (uint256);

    function loanParamsIds(uint256) external view returns (bytes32);


    /// Guardian interface

    function _isPaused(bytes4 sig) external view returns (bool isPaused);

    function toggleFunctionPause(bytes4 sig) external;

    function toggleFunctionUnPause(bytes4 sig) external;

    function changeGuardian(address newGuardian) external;

    function getGuardian() external view returns (address guardian);
    
    function revokeApproval(address _loanTokenAddress) external;

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function DOMAIN_SEPARATOR() external view returns(bytes32);
    function PERMIT_TYPEHASH() external view returns(bytes32);
    function nonces(address) external view returns (uint);
    /// Admin functions
    function setTarget(address _newTarget) external;
    
    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;

    function initializeDomainSeparator() external;

    struct LoanOpenData {
        bytes32 loanId;
        uint256 principal;
        uint256 collateral;
    }
	
    //flash borrow fees
    function updateFlashBorrowFeePercent(uint256 newFeePercent) external;

    function setDemandCurve(address _rateHelper) external; 

    function getPoolUtilization()
        external
        view
    returns (uint256);

    function name() external view returns (string memory);
 
    function symbol() external view  returns (string memory);

    function mintWithEther(address receiver) external payable;

    function burnToEther(address payable receiver,uint256 burnAmount) external returns (uint256 loanAmountPaid);
}

/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache-2.0
 */
// 
pragma solidity >=0.5.0 <0.9.0;






interface IBZx {
    ////// Protocol //////

    
    
    function replaceContract(address target) external;

    
    /// sigsArr and targetsArr should be of equal length
    
    
    function setTargets(
        string[] calldata sigsArr,
        address[] calldata targetsArr
    ) external;

    
    
    function getTarget(string calldata sig) external view returns (address);

    ////// Protocol Settings //////

    
    
    function setPriceFeedContract(address newContract) external;

    
    
    function setSwapsImplContract(address newContract) external;

    
    
    
    function setLoanPool(address[] calldata pools, address[] calldata assets)
        external;

    
    
    
    
    function setSupportedTokens(
        address[] calldata addrs,
        bool[] calldata toggles,
        bool withApprovals
    ) external;

    
    
    
    function setApprovals(address[] calldata tokens, uint256[] calldata dexIDs) external;

    
    
    function setLendingFeePercent(uint256 newValue) external;

    
    
    function setTradingFeePercent(uint256 newValue) external;

    
    
    function setBorrowingFeePercent(uint256 newValue) external;

    
    
    function setAffiliateFeePercent(uint256 newValue) external;

    
    /// that liquidator gets in the process of liquidating.
    
    
    
    function setLiquidationIncentivePercent(
        address[] calldata loanTokens,
        address[] calldata collateralTokens,
        uint256[] calldata amounts
    ) external;

    
    
    function setMaxDisagreement(uint256 newAmount) external;

    /// TODO
    function setSourceBufferPercent(uint256 newAmount) external;

    
    
    function setMaxSwapSize(uint256 newAmount) external;

    
    
    function setFeesController(address newController) external;

    
    
    
    
    function withdrawFees(
        address[] calldata tokens,
        address receiver,
        FeeClaimType feeType
    ) external returns (uint256[] memory amounts);

    /*
    Targets still exist, but functions are decommissioned:

    
    
    
    
    
    function withdrawProtocolToken(address receiver, uint256 amount)
        external
        returns (address rewardToken, uint256 withdrawAmount);

    
    
    function depositProtocolToken(uint256 amount) external;

    function grantRewards(address[] calldata users, uint256[] calldata amounts)
        external
        returns (uint256 totalAmount);*/

    // NOTE: this doesn't sanitize inputs -> inaccurate values may be returned if there are duplicate token inputs
    function queryFees(address[] calldata tokens, FeeClaimType feeType)
        external
        view
        returns (uint256[] memory amountsHeld, uint256[] memory amountsPaid);

    function priceFeeds() external view returns (address);

    function swapsImpl() external view returns (address);

    function logicTargets(bytes4) external view returns (address);

    function loans(bytes32) external view returns (Loan memory);

    function loanParams(bytes32) external view returns (LoanParams memory);

    // we don't use this yet
    // function lenderOrders(address, bytes32) external returns (Order memory);
    // function borrowerOrders(address, bytes32) external returns (Order memory);

    function delegatedManagers(bytes32, address) external view returns (bool);

    function lenderInterest(address, address)
        external
        view
        returns (LenderInterest memory);

    function loanInterest(bytes32) external view returns (LoanInterest memory);

    function feesController() external view returns (address);

    function lendingFeePercent() external view returns (uint256);

    function lendingFeeTokensHeld(address) external view returns (uint256);

    function lendingFeeTokensPaid(address) external view returns (uint256);

    function borrowingFeePercent() external view returns (uint256);

    function borrowingFeeTokensHeld(address) external view returns (uint256);

    function borrowingFeeTokensPaid(address) external view returns (uint256);

    function tradingFeeTokensHeld(address) external view returns (uint256);

    function tradingFeeTokensPaid(address) external view returns (uint256);

    function tradingFeePercent() external view returns (uint256);

    function protocolTokenHeld() external view returns (uint256);

    function protocolTokenPaid() external view returns (uint256);

    function affiliateFeePercent() external view returns (uint256);

    function liquidationIncentivePercent(address, address)
        external
        view
        returns (uint256);

    function loanPoolToUnderlying(address) external view returns (address);

    function underlyingToLoanPool(address) external view returns (address);

    function supportedTokens(address) external view returns (bool);

    function maxDisagreement() external view returns (uint256);

    function sourceBufferPercent() external view returns (uint256);

    function maxSwapSize() external view returns (uint256);

    
    
    
    
    function getLoanPoolsList(uint256 start, uint256 count)
        external
        view
        returns (address[] memory loanPoolsList);

    
    
    function isLoanPool(address loanPool) external view returns (bool);

    ////// Loan Settings //////

    
    
    
    function setupLoanParams(LoanParams[] calldata loanParamsList)
        external
        returns (bytes32[] memory loanParamsIdList);

    function setupLoanPoolTWAI(address pool) external;

    function setTWAISettings(uint32 delta, uint32 secondsAgo) external;

    
    
    function disableLoanParams(bytes32[] calldata loanParamsIdList) external;

    
    
    function modifyLoanParams(LoanParams[] calldata loanParamsList) external;

    
    
    
    function getLoanParams(bytes32[] calldata loanParamsIdList)
        external
        view
        returns (LoanParams[] memory loanParamsList);

    
    
    
    
    
    function getLoanParamsList(
        address owner,
        uint256 start,
        uint256 count
    ) external view returns (bytes32[] memory loanParamsList);

    
    
    
    
    function getTotalPrincipal(address lender, address loanToken)
        external
        view
        returns (uint256);

    
    
    
    function getPoolPrincipalStored(address pool)
        external
        view
        returns (uint256);

    
    
    
    function getPoolLastInterestRate(address pool)
        external
        view
        returns (uint256);
    
    function migrateLoanParamsList(
        address owner,
        uint256 start,
        uint256 count)
        external;

    ////// Loan Openings //////

    
    
    
    
    
    
    ///         lender: must match loan if loanId provided
    ///         borrower: must match loan if loanId provided
    ///         receiver: receiver of funds (address(0) assumes borrower address)
    ///         manager: delegated manager of loan unless address(0)
    
    ///         newRate: new loan interest rate
    ///         newPrincipal: new loan size (borrowAmount + any borrowed interest)
    ///         torqueInterest: new amount of interest to escrow for Torque loan (determines initial loan length)
    ///         loanTokenReceived: total loanToken deposit (amount not sent to borrower in the case of Torque loans)
    ///         collateralTokenReceived: total collateralToken deposit
    
    
    function borrowOrTradeFromPool(
        address collateralTokenAddress,
        bytes32 loanId,
        bool isTorqueLoan,
        uint256 initialMargin,
        address[4] calldata sentAddresses,
        uint256[5] calldata sentValues,
        bytes calldata loanDataBytes
    ) external payable returns (LoanOpenData memory);

    function swapLoanCollateral(
        bytes32 loanId,
        address newCollateralToken,
        bytes calldata loanDataBytes
    ) external;

    
    
    
    
    function setDelegatedManager(
        bytes32 loanId,
        address delegated,
        bool toggle
    ) external;

    
    
    
    
    
    
    
    function getRequiredCollateral(
        address loanToken,
        address collateralToken,
        uint256 newPrincipal,
        uint256 marginAmount,
        bool isTorqueLoan
    ) external view returns (uint256 collateralAmountRequired);
    
    function getDefaultLoanParams(
        address loanToken,
        address collateralToken,
        bool isTorqueLoan)
        external
        view
        returns(LoanParams memory loanParamsLocal, bool isDefault);

    function generateLoanParamId(
        address loanToken,
        address collateralToken,
        bool isTorqueLoan
    ) external pure returns (bytes32);


    ////// Loan Closings //////

    
    
    
    
    
    
    
    function liquidate(
        bytes32 loanId,
        address receiver,
        uint256 closeAmount
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 seizedAmount,
            address seizedToken
        );

    
    
    
    
    
    
    
    
    function closeWithDeposit(
        bytes32 loanId,
        address receiver,
        uint256 depositAmount, // denominated in loanToken
        bytes calldata loanDataBytes
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );

    
    
    
    
    
    
    
    
    
    function closeWithSwap(
        bytes32 loanId,
        address receiver,
        uint256 swapAmount, // denominated in collateralToken
        bool returnTokenIsCollateral, // true: withdraws collateralToken, false: withdraws loanToken
        bytes calldata loanDataBytes
    )
        external
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );

    ////// Loan Closings With Gas Token //////

    ////// Loan Maintenance //////

    
    
    
    function depositCollateral(bytes32 loanId, uint256 depositAmount)
        external
        payable;

    
    
    
    
    
    function withdrawCollateral(
        bytes32 loanId,
        address receiver,
        uint256 withdrawAmount
    ) external returns (uint256 actualWithdrawAmount);

    
    
    function settleInterest(bytes32 loanId) external;

    function setDepositAmount(
        bytes32 loanId,
        uint256 depositValueAsLoanToken,
        uint256 depositValueAsCollateralToken
    ) external;

    function transferLoan(bytes32 loanId, address newOwner) external;

    // Decommissioned function, but leave interface to allow remaining claims
    function claimRewards(address receiver)
        external
        returns (uint256 claimAmount);

    // Decommissioned function, but leave interface to allow remaining claims
    function rewardsBalanceOf(address user)
        external
        view
        returns (uint256 rewardsBalance);

    function getInterestModelValues(
        address pool,
        bytes32 loanId)
        external
        view
        returns (
        uint256 _poolLastUpdateTime,
        uint256 _poolPrincipalTotal,
        uint256 _poolInterestTotal,
        uint256 _poolRatePerTokenStored,
        uint256 _poolLastInterestRate,
        uint256 _loanPrincipalTotal,
        uint256 _loanInterestTotal,
        uint256 _loanRatePerTokenPaid
        );
    
    function getTWAI(
        address pool)
        external
        view returns (
            uint256 benchmarkRate
        );

    
    
    
    
    
    
    
    
    function getUserLoans(
        address user,
        uint256 start,
        uint256 count,
        LoanType loanType,
        bool isLender,
        bool unsafeOnly
    ) external view returns (LoanReturnData[] memory loansData);

    function getUserLoansCount(address user, bool isLender)
        external
        view
        returns (uint256);

    
    
    
    function getLoan(bytes32 loanId)
        external
        view
        returns (LoanReturnData memory loanData);

    
    
    
    function getLoanPrincipal(bytes32 loanId)
        external
        view
        returns (uint256 principal);

    
    
    
    function getLoanInterestOutstanding(bytes32 loanId)
        external
        view
        returns (uint256 interest);


    
    
    
    
    function getActiveLoans(
        uint256 start,
        uint256 count,
        bool unsafeOnly
    ) external view returns (LoanReturnData[] memory loansData);

    
    
    
    
    
    function getActiveLoansAdvanced(
        uint256 start,
        uint256 count,
        bool unsafeOnly,
        bool isLiquidatable
    ) external view returns (LoanReturnData[] memory loansData);

    function getActiveLoansCount() external view returns (uint256);

    ////// Swap External //////

    
    
    
    
    
    
    
    
    
    
    function swapExternal(
        address sourceToken,
        address destToken,
        address receiver,
        address returnToSender,
        uint256 sourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes calldata swapData
    )
        external
        payable
        returns (
            uint256 destTokenAmountReceived,
            uint256 sourceTokenAmountUsed
        );

    
    
    
    
    
    // TODO remove as soon as deployed on all chains
    function getSwapExpectedReturn(
        address sourceToken,
        address destToken,
        uint256 sourceTokenAmount,
        bytes calldata swapData
    ) external view returns (uint256);

    
    
    
    
    
    
    
    function getSwapExpectedReturn(
        address trader,
        address sourceToken,
        address destToken,
        uint256 sourceTokenAmount,
        bytes calldata payload)
        external
        returns (uint256);

    
    
    
    
    
    
    
    
    function getSwapExpectedReturn(
        address trader,
        address sourceToken,
        address destToken,
        uint256 tokenAmount,
        bytes calldata payload,
        bool isAmountIn)
        external
        returns (uint256);

    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;


    /// Guardian Interface

    function _isPaused(bytes4 sig) external view returns (bool isPaused);

    function toggleFunctionPause(bytes4 sig) external;

    function toggleFunctionUnPause(bytes4 sig) external;

    function pause(bytes4 [] calldata sig) external;

    function unpause(bytes4 [] calldata sig) external;

    function changeGuardian(address newGuardian) external;

    function getGuardian() external view returns (address guardian);

    /// Loan Cleanup Interface

    function cleanupLoans(
        address loanToken,
        bytes32[] calldata loanIds)
        external
        payable
        returns (uint256 totalPrincipalIn);

    struct LoanParams {
        bytes32 id;
        bool active;
        address owner;
        address loanToken;
        address collateralToken;
        uint256 minInitialMargin;
        uint256 maintenanceMargin;
        uint256 maxLoanTerm;
    }

    struct LoanOpenData {
        bytes32 loanId;
        uint256 principal;
        uint256 collateral;
    }

    enum LoanType {
        All,
        Margin,
        NonMargin
    }

    struct LoanReturnData {
        bytes32 loanId;
        uint96 endTimestamp;
        address loanToken;
        address collateralToken;
        uint256 principal;
        uint256 collateral;
        uint256 interestOwedPerDay;
        uint256 interestDepositRemaining;
        uint256 startRate;
        uint256 startMargin;
        uint256 maintenanceMargin;
        uint256 currentMargin;
        uint256 maxLoanTerm;
        uint256 maxLiquidatable;
        uint256 maxSeizable;
        uint256 depositValueAsLoanToken;
        uint256 depositValueAsCollateralToken;
    }

    enum FeeClaimType {
        All,
        Lending,
        Trading,
        Borrowing
    }

    struct Loan {
        bytes32 id; // id of the loan
        bytes32 loanParamsId; // the linked loan params id
        bytes32 pendingTradesId; // the linked pending trades id
        uint256 principal; // total borrowed amount outstanding
        uint256 collateral; // total collateral escrowed for the loan
        uint256 startTimestamp; // loan start time
        uint256 endTimestamp; // for active loans, this is the expected loan end time, for in-active loans, is the actual (past) end time
        uint256 startMargin; // initial margin when the loan opened
        uint256 startRate; // reference rate when the loan opened for converting collateralToken to loanToken
        address borrower; // borrower of this loan
        address lender; // lender of this loan
        bool active; // if false, the loan has been fully closed
    }

    struct LenderInterest {
        uint256 principalTotal; // total borrowed amount outstanding of asset
        uint256 owedPerDay; // interest owed per day for all loans of asset
        uint256 owedTotal; // total interest owed for all loans of asset (assuming they go to full term)
        uint256 paidTotal; // total interest paid so far for asset
        uint256 updatedTimestamp; // last update
    }

    struct LoanInterest {
        uint256 owedPerDay; // interest owed per day for loan
        uint256 depositTotal; // total escrowed interest for loan
        uint256 updatedTimestamp; // last update
    }
	
	////// Flash Borrow Fees //////
    function payFlashBorrowFees(
        address user,
        uint256 borrowAmount,
        uint256 flashBorrowFeePercent)
        external;
}