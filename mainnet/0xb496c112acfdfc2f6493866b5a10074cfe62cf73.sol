// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * 
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// 
pragma solidity ^0.8.0;










abstract contract LensStorage is Initializable {
    /// STORAGE ///

    uint256 public constant MAX_BASIS_POINTS = 10_000; // 100% (in basis points).
    uint256 public constant WAD = 1e18;

    IMorpho public morpho;
    IComptroller public comptroller;
    IRewardsManager public rewardsManager;

    /// CONSTRUCTOR ///

    
    
    constructor() initializer {}
}

// 
pragma solidity ^0.8.0;










abstract contract IndexesLens is LensStorage {
    using CompoundMath for uint256;

    /// PUBLIC ///

    
    
    
    function getCurrentP2PSupplyIndex(address _poolTokenAddress)
        public
        view
        returns (uint256 currentP2PSupplyIndex)
    {
        (currentP2PSupplyIndex, , ) = _getCurrentP2PSupplyIndex(_poolTokenAddress);
    }

    
    
    
    function getCurrentP2PBorrowIndex(address _poolTokenAddress)
        public
        view
        returns (uint256 currentP2PBorrowIndex)
    {
        (currentP2PBorrowIndex, , ) = _getCurrentP2PBorrowIndex(_poolTokenAddress);
    }

    
    
    
    
    
    
    
    function getIndexes(address _poolTokenAddress, bool _getUpdatedIndexes)
        public
        view
        returns (
            uint256 newP2PSupplyIndex,
            uint256 newP2PBorrowIndex,
            uint256 newPoolSupplyIndex,
            uint256 newPoolBorrowIndex
        )
    {
        if (!_getUpdatedIndexes) {
            ICToken cToken = ICToken(_poolTokenAddress);

            newPoolSupplyIndex = cToken.exchangeRateStored();
            newPoolBorrowIndex = cToken.borrowIndex();
        } else {
            (newPoolSupplyIndex, newPoolBorrowIndex) = getCurrentPoolIndexes(_poolTokenAddress);
        }

        Types.LastPoolIndexes memory lastPoolIndexes = morpho.lastPoolIndexes(_poolTokenAddress);
        if (!_getUpdatedIndexes || block.number == lastPoolIndexes.lastUpdateBlockNumber) {
            newP2PSupplyIndex = morpho.p2pSupplyIndex(_poolTokenAddress);
            newP2PBorrowIndex = morpho.p2pBorrowIndex(_poolTokenAddress);
        } else {
            Types.Delta memory delta = morpho.deltas(_poolTokenAddress);
            Types.MarketParameters memory marketParams = morpho.marketParameters(_poolTokenAddress);

            InterestRatesModel.GrowthFactors memory growthFactors = InterestRatesModel
            .computeGrowthFactors(
                newPoolSupplyIndex,
                newPoolBorrowIndex,
                lastPoolIndexes,
                marketParams.p2pIndexCursor
            );

            newP2PSupplyIndex = InterestRatesModel.computeP2PSupplyIndex(
                InterestRatesModel.P2PIndexComputeParams({
                    poolGrowthFactor: growthFactors.poolSupplyGrowthFactor,
                    p2pGrowthFactor: growthFactors.p2pGrowthFactor,
                    lastPoolIndex: lastPoolIndexes.lastSupplyPoolIndex,
                    lastP2PIndex: morpho.p2pSupplyIndex(_poolTokenAddress),
                    p2pDelta: delta.p2pSupplyDelta,
                    p2pAmount: delta.p2pSupplyAmount,
                    reserveFactor: marketParams.reserveFactor
                })
            );
            newP2PBorrowIndex = InterestRatesModel.computeP2PBorrowIndex(
                InterestRatesModel.P2PIndexComputeParams({
                    poolGrowthFactor: growthFactors.poolBorrowGrowthFactor,
                    p2pGrowthFactor: growthFactors.p2pGrowthFactor,
                    lastPoolIndex: lastPoolIndexes.lastBorrowPoolIndex,
                    lastP2PIndex: morpho.p2pBorrowIndex(_poolTokenAddress),
                    p2pDelta: delta.p2pBorrowDelta,
                    p2pAmount: delta.p2pBorrowAmount,
                    reserveFactor: marketParams.reserveFactor
                })
            );
        }
    }

    
    
    
    
    function getCurrentPoolIndexes(address _poolTokenAddress)
        public
        view
        returns (uint256 currentPoolSupplyIndex, uint256 currentPoolBorrowIndex)
    {
        ICToken cToken = ICToken(_poolTokenAddress);

        uint256 accrualBlockNumberPrior = cToken.accrualBlockNumber();
        if (block.number == accrualBlockNumberPrior)
            return (cToken.exchangeRateStored(), cToken.borrowIndex());

        // Read the previous values out of storage
        uint256 cashPrior = cToken.getCash();
        uint256 totalSupply = cToken.totalSupply();
        uint256 borrowsPrior = cToken.totalBorrows();
        uint256 reservesPrior = cToken.totalReserves();
        uint256 borrowIndexPrior = cToken.borrowIndex();

        // Calculate the current borrow interest rate
        uint256 borrowRateMantissa = cToken.borrowRatePerBlock();
        require(borrowRateMantissa <= 0.0005e16, "borrow rate is absurdly high");

        uint256 blockDelta = block.number - accrualBlockNumberPrior;

        // Calculate the interest accumulated into borrows and reserves and the current index.
        uint256 simpleInterestFactor = borrowRateMantissa * blockDelta;
        uint256 interestAccumulated = simpleInterestFactor.mul(borrowsPrior);
        uint256 totalBorrowsNew = interestAccumulated + borrowsPrior;
        uint256 totalReservesNew = cToken.reserveFactorMantissa().mul(interestAccumulated) +
            reservesPrior;

        currentPoolSupplyIndex = totalSupply > 0
            ? (cashPrior + totalBorrowsNew - totalReservesNew).div(totalSupply)
            : cToken.initialExchangeRateMantissa();
        currentPoolBorrowIndex = simpleInterestFactor.mul(borrowIndexPrior) + borrowIndexPrior;
    }

    /// INTERNAL ///

    
    
    
    
    
    function _getCurrentP2PSupplyIndex(address _poolTokenAddress)
        internal
        view
        returns (
            uint256 currentP2PSupplyIndex,
            uint256 currentPoolSupplyIndex,
            uint256 currentPoolBorrowIndex
        )
    {
        (currentPoolSupplyIndex, currentPoolBorrowIndex) = getCurrentPoolIndexes(_poolTokenAddress);

        Types.LastPoolIndexes memory lastPoolIndexes = morpho.lastPoolIndexes(_poolTokenAddress);
        if (block.number == lastPoolIndexes.lastUpdateBlockNumber)
            currentP2PSupplyIndex = morpho.p2pSupplyIndex(_poolTokenAddress);
        else {
            Types.Delta memory delta = morpho.deltas(_poolTokenAddress);
            Types.MarketParameters memory marketParams = morpho.marketParameters(_poolTokenAddress);

            InterestRatesModel.GrowthFactors memory growthFactors = InterestRatesModel
            .computeGrowthFactors(
                currentPoolSupplyIndex,
                currentPoolBorrowIndex,
                lastPoolIndexes,
                marketParams.p2pIndexCursor
            );

            currentP2PSupplyIndex = InterestRatesModel.computeP2PSupplyIndex(
                InterestRatesModel.P2PIndexComputeParams({
                    poolGrowthFactor: growthFactors.poolSupplyGrowthFactor,
                    p2pGrowthFactor: growthFactors.p2pGrowthFactor,
                    lastPoolIndex: lastPoolIndexes.lastSupplyPoolIndex,
                    lastP2PIndex: morpho.p2pSupplyIndex(_poolTokenAddress),
                    p2pDelta: delta.p2pSupplyDelta,
                    p2pAmount: delta.p2pSupplyAmount,
                    reserveFactor: marketParams.reserveFactor
                })
            );
        }
    }

    
    
    
    
    
    function _getCurrentP2PBorrowIndex(address _poolTokenAddress)
        internal
        view
        returns (
            uint256 currentP2PBorrowIndex,
            uint256 currentPoolSupplyIndex,
            uint256 currentPoolBorrowIndex
        )
    {
        (currentPoolSupplyIndex, currentPoolBorrowIndex) = getCurrentPoolIndexes(_poolTokenAddress);

        Types.LastPoolIndexes memory lastPoolIndexes = morpho.lastPoolIndexes(_poolTokenAddress);
        if (block.number == lastPoolIndexes.lastUpdateBlockNumber)
            currentP2PBorrowIndex = morpho.p2pBorrowIndex(_poolTokenAddress);
        else {
            Types.Delta memory delta = morpho.deltas(_poolTokenAddress);
            Types.MarketParameters memory marketParams = morpho.marketParameters(_poolTokenAddress);

            InterestRatesModel.GrowthFactors memory growthFactors = InterestRatesModel
            .computeGrowthFactors(
                currentPoolSupplyIndex,
                currentPoolBorrowIndex,
                lastPoolIndexes,
                marketParams.p2pIndexCursor
            );

            currentP2PBorrowIndex = InterestRatesModel.computeP2PBorrowIndex(
                InterestRatesModel.P2PIndexComputeParams({
                    poolGrowthFactor: growthFactors.poolBorrowGrowthFactor,
                    p2pGrowthFactor: growthFactors.p2pGrowthFactor,
                    lastPoolIndex: lastPoolIndexes.lastBorrowPoolIndex,
                    lastP2PIndex: morpho.p2pBorrowIndex(_poolTokenAddress),
                    p2pDelta: delta.p2pBorrowDelta,
                    p2pAmount: delta.p2pBorrowAmount,
                    reserveFactor: marketParams.reserveFactor
                })
            );
        }
    }
}

// 
pragma solidity ^0.8.0;












abstract contract UsersLens is IndexesLens {
    using CompoundMath for uint256;

    /// ERRORS ///

    
    error CompoundOracleFailed();

    /// EXTERNAL ///

    
    
    
    function getEnteredMarkets(address _user)
        external
        view
        returns (address[] memory enteredMarkets)
    {
        return morpho.getEnteredMarkets(_user);
    }

    
    
    
    
    
    
    function getUserMaxCapacitiesForAsset(address _user, address _poolTokenAddress)
        external
        view
        returns (uint256 withdrawable, uint256 borrowable)
    {
        Types.LiquidityData memory data;
        Types.AssetLiquidityData memory assetData;
        ICompoundOracle oracle = ICompoundOracle(comptroller.oracle());
        address[] memory enteredMarkets = morpho.getEnteredMarkets(_user);

        uint256 nbEnteredMarkets = enteredMarkets.length;
        for (uint256 i; i < nbEnteredMarkets; ) {
            address poolTokenEntered = enteredMarkets[i];

            if (_poolTokenAddress != poolTokenEntered) {
                assetData = getUserLiquidityDataForAsset(_user, poolTokenEntered, false, oracle);

                data.maxDebtValue += assetData.maxDebtValue;
                data.debtValue += assetData.debtValue;
            }

            unchecked {
                ++i;
            }
        }

        assetData = getUserLiquidityDataForAsset(_user, _poolTokenAddress, true, oracle);

        data.maxDebtValue += assetData.maxDebtValue;
        data.debtValue += assetData.debtValue;

        // Not possible to withdraw nor borrow.
        if (data.maxDebtValue < data.debtValue) return (0, 0);

        uint256 differenceInUnderlying = (data.maxDebtValue - data.debtValue).div(
            assetData.underlyingPrice
        );

        withdrawable = assetData.collateralValue.div(assetData.underlyingPrice);
        if (assetData.collateralFactor != 0) {
            withdrawable = CompoundMath.min(
                withdrawable,
                differenceInUnderlying.div(assetData.collateralFactor)
            );
        }

        borrowable = differenceInUnderlying;
    }

    
    
    
    
    
    function computeLiquidationRepayAmount(
        address _user,
        address _poolTokenBorrowedAddress,
        address _poolTokenCollateralAddress,
        address[] calldata _updatedMarkets
    ) external view returns (uint256 toRepay) {
        address[] memory updatedMarkets = new address[](_updatedMarkets.length + 2);

        uint256 nbUpdatedMarkets = _updatedMarkets.length;
        for (uint256 i; i < nbUpdatedMarkets; ) {
            updatedMarkets[i] = _updatedMarkets[i];

            unchecked {
                ++i;
            }
        }

        updatedMarkets[updatedMarkets.length - 2] = _poolTokenBorrowedAddress;
        updatedMarkets[updatedMarkets.length - 1] = _poolTokenCollateralAddress;
        if (!isLiquidatable(_user, updatedMarkets)) return 0;

        ICompoundOracle compoundOracle = ICompoundOracle(comptroller.oracle());

        (, , uint256 totalCollateralBalance) = getCurrentSupplyBalanceInOf(
            _poolTokenCollateralAddress,
            _user
        );
        (, , uint256 totalBorrowBalance) = getCurrentBorrowBalanceInOf(
            _poolTokenBorrowedAddress,
            _user
        );

        uint256 borrowedPrice = compoundOracle.getUnderlyingPrice(_poolTokenBorrowedAddress);
        uint256 collateralPrice = compoundOracle.getUnderlyingPrice(_poolTokenCollateralAddress);
        if (borrowedPrice == 0 || collateralPrice == 0) revert CompoundOracleFailed();

        uint256 maxROIRepay = totalCollateralBalance.mul(collateralPrice).div(borrowedPrice).div(
            comptroller.liquidationIncentiveMantissa()
        );

        uint256 maxRepayable = totalBorrowBalance.mul(comptroller.closeFactorMantissa());

        toRepay = maxROIRepay > maxRepayable ? maxRepayable : maxROIRepay;
    }

    
    
    
    
    function getUserHealthFactor(address _user, address[] calldata _updatedMarkets)
        external
        view
        returns (uint256)
    {
        (, uint256 debtValue, uint256 maxDebtValue) = getUserBalanceStates(_user, _updatedMarkets);
        if (debtValue == 0) return type(uint256).max;

        return maxDebtValue.div(debtValue);
    }

    /// PUBLIC ///

    
    
    
    
    
    
    function getUserBalanceStates(address _user, address[] calldata _updatedMarkets)
        public
        view
        returns (
            uint256 collateralValue,
            uint256 debtValue,
            uint256 maxDebtValue
        )
    {
        ICompoundOracle oracle = ICompoundOracle(comptroller.oracle());
        address[] memory enteredMarkets = morpho.getEnteredMarkets(_user);

        uint256 nbEnteredMarkets = enteredMarkets.length;
        uint256 nbUpdatedMarkets = _updatedMarkets.length;
        for (uint256 i; i < nbEnteredMarkets; ) {
            address poolTokenEntered = enteredMarkets[i];

            bool shouldUpdateIndexes;
            for (uint256 j; j < nbUpdatedMarkets; ) {
                if (_updatedMarkets[j] == poolTokenEntered) {
                    shouldUpdateIndexes = true;
                    break;
                }

                unchecked {
                    ++j;
                }
            }

            Types.AssetLiquidityData memory assetData = getUserLiquidityDataForAsset(
                _user,
                poolTokenEntered,
                shouldUpdateIndexes,
                oracle
            );

            collateralValue += assetData.collateralValue;
            maxDebtValue += assetData.maxDebtValue;
            debtValue += assetData.debtValue;

            unchecked {
                ++i;
            }
        }
    }

    
    
    
    
    
    
    function getCurrentSupplyBalanceInOf(address _poolTokenAddress, address _user)
        public
        view
        returns (
            uint256 balanceOnPool,
            uint256 balanceInP2P,
            uint256 totalBalance
        )
    {
        (uint256 p2pSupplyIndex, uint256 poolSupplyIndex, ) = _getCurrentP2PSupplyIndex(
            _poolTokenAddress
        );

        balanceOnPool = morpho.supplyBalanceInOf(_poolTokenAddress, _user).onPool.mul(
            poolSupplyIndex
        );
        balanceInP2P = morpho.supplyBalanceInOf(_poolTokenAddress, _user).inP2P.mul(p2pSupplyIndex);

        totalBalance = balanceOnPool + balanceInP2P;
    }

    
    
    
    
    
    
    function getCurrentBorrowBalanceInOf(address _poolTokenAddress, address _user)
        public
        view
        returns (
            uint256 balanceOnPool,
            uint256 balanceInP2P,
            uint256 totalBalance
        )
    {
        (uint256 p2pBorrowIndex, , uint256 poolBorrowIndex) = _getCurrentP2PBorrowIndex(
            _poolTokenAddress
        );

        balanceOnPool = morpho.borrowBalanceInOf(_poolTokenAddress, _user).onPool.mul(
            poolBorrowIndex
        );
        balanceInP2P = morpho.borrowBalanceInOf(_poolTokenAddress, _user).inP2P.mul(p2pBorrowIndex);

        totalBalance = balanceOnPool + balanceInP2P;
    }

    
    
    
    
    
    
    
    function getUserHypotheticalBalanceStates(
        address _user,
        address _poolTokenAddress,
        uint256 _withdrawnAmount,
        uint256 _borrowedAmount
    ) public view returns (uint256 debtValue, uint256 maxDebtValue) {
        ICompoundOracle oracle = ICompoundOracle(comptroller.oracle());
        address[] memory enteredMarkets = morpho.getEnteredMarkets(_user);

        uint256 nbEnteredMarkets = enteredMarkets.length;
        for (uint256 i; i < nbEnteredMarkets; ) {
            address poolTokenEntered = enteredMarkets[i];

            Types.AssetLiquidityData memory assetData = getUserLiquidityDataForAsset(
                _user,
                poolTokenEntered,
                true,
                oracle
            );

            maxDebtValue += assetData.maxDebtValue;
            debtValue += assetData.debtValue;
            unchecked {
                ++i;
            }

            if (_poolTokenAddress == poolTokenEntered) {
                if (_borrowedAmount > 0)
                    debtValue += _borrowedAmount.mul(assetData.underlyingPrice);

                if (_withdrawnAmount > 0)
                    maxDebtValue -= _withdrawnAmount.mul(assetData.underlyingPrice).mul(
                        assetData.collateralFactor
                    );
            }
        }
    }

    
    
    
    
    
    
    function getUserLiquidityDataForAsset(
        address _user,
        address _poolTokenAddress,
        bool _getUpdatedIndexes,
        ICompoundOracle _oracle
    ) public view returns (Types.AssetLiquidityData memory assetData) {
        assetData.underlyingPrice = _oracle.getUnderlyingPrice(_poolTokenAddress);
        if (assetData.underlyingPrice == 0) revert CompoundOracleFailed();

        (, assetData.collateralFactor, ) = comptroller.markets(_poolTokenAddress);

        (
            uint256 p2pSupplyIndex,
            uint256 p2pBorrowIndex,
            uint256 poolSupplyIndex,
            uint256 poolBorrowIndex
        ) = getIndexes(_poolTokenAddress, _getUpdatedIndexes);

        assetData.collateralValue = _getUserSupplyBalanceInOf(
            _poolTokenAddress,
            _user,
            p2pSupplyIndex,
            poolSupplyIndex
        ).mul(assetData.underlyingPrice);

        assetData.debtValue = _getUserBorrowBalanceInOf(
            _poolTokenAddress,
            _user,
            p2pBorrowIndex,
            poolBorrowIndex
        ).mul(assetData.underlyingPrice);

        assetData.maxDebtValue = assetData.collateralValue.mul(assetData.collateralFactor);
    }

    
    
    
    
    function isLiquidatable(address _user, address[] memory _updatedMarkets)
        public
        view
        returns (bool)
    {
        ICompoundOracle oracle = ICompoundOracle(comptroller.oracle());
        address[] memory enteredMarkets = morpho.getEnteredMarkets(_user);

        uint256 maxDebtValue;
        uint256 debtValue;

        uint256 nbEnteredMarkets = enteredMarkets.length;
        uint256 nbUpdatedMarkets = _updatedMarkets.length;
        for (uint256 i; i < nbEnteredMarkets; ) {
            address poolTokenEntered = enteredMarkets[i];

            bool shouldUpdateIndexes;
            for (uint256 j; j < nbUpdatedMarkets; ) {
                if (_updatedMarkets[j] == poolTokenEntered) {
                    shouldUpdateIndexes = true;
                    break;
                }

                unchecked {
                    ++j;
                }
            }

            Types.AssetLiquidityData memory assetData = getUserLiquidityDataForAsset(
                _user,
                poolTokenEntered,
                shouldUpdateIndexes,
                oracle
            );

            maxDebtValue += assetData.maxDebtValue;
            debtValue += assetData.debtValue;

            unchecked {
                ++i;
            }
        }

        return debtValue > maxDebtValue;
    }

    /// INTERNAL ///

    
    
    
    
    
    function _getUserSupplyBalanceInOf(
        address _poolTokenAddress,
        address _user,
        uint256 _p2pSupplyIndex,
        uint256 _poolSupplyIndex
    ) internal view returns (uint256) {
        Types.SupplyBalance memory supplyBalance = morpho.supplyBalanceInOf(
            _poolTokenAddress,
            _user
        );

        return
            supplyBalance.inP2P.mul(_p2pSupplyIndex) + supplyBalance.onPool.mul(_poolSupplyIndex);
    }

    
    
    
    
    function _getUserBorrowBalanceInOf(
        address _poolTokenAddress,
        address _user,
        uint256 _p2pBorrowIndex,
        uint256 _poolBorrowIndex
    ) internal view returns (uint256) {
        Types.BorrowBalance memory borrowBalance = morpho.borrowBalanceInOf(
            _poolTokenAddress,
            _user
        );

        return
            borrowBalance.inP2P.mul(_p2pBorrowIndex) + borrowBalance.onPool.mul(_poolBorrowIndex);
    }
}

// 
pragma solidity ^0.8.0;












abstract contract RatesLens is UsersLens {
    using CompoundMath for uint256;

    /// STRUCTS ///

    struct Indexes {
        uint256 p2pSupplyIndex;
        uint256 p2pBorrowIndex;
        uint256 poolSupplyIndex;
        uint256 poolBorrowIndex;
    }

    /// EXTERNAL ///

    
    
    /// a supplier could be matched more than once instantly or later and thus benefit from a higher supply rate.
    
    
    
    
    
    
    
    function getNextUserSupplyRatePerBlock(
        address _poolTokenAddress,
        address _user,
        uint256 _amount
    )
        external
        view
        returns (
            uint256 nextSupplyRatePerBlock,
            uint256 balanceOnPool,
            uint256 balanceInP2P,
            uint256 totalBalance
        )
    {
        Types.SupplyBalance memory supplyBalance = morpho.supplyBalanceInOf(
            _poolTokenAddress,
            _user
        );

        Indexes memory indexes;
        (
            indexes.p2pSupplyIndex,
            indexes.poolSupplyIndex,
            indexes.poolBorrowIndex
        ) = _getCurrentP2PSupplyIndex(_poolTokenAddress);

        if (_amount > 0) {
            Types.Delta memory delta = morpho.deltas(_poolTokenAddress);
            if (delta.p2pBorrowDelta > 0) {
                uint256 deltaInUnderlying = delta.p2pBorrowDelta.mul(indexes.poolBorrowIndex);
                uint256 matchedDelta = CompoundMath.min(deltaInUnderlying, _amount);

                supplyBalance.inP2P += matchedDelta.div(indexes.p2pSupplyIndex);
                _amount -= matchedDelta;
            }
        }

        if (_amount > 0 && !morpho.p2pDisabled(_poolTokenAddress)) {
            uint256 firstPoolBorrowerBalance = morpho
            .borrowBalanceInOf(
                _poolTokenAddress,
                morpho.getHead(_poolTokenAddress, Types.PositionType.BORROWERS_ON_POOL)
            ).onPool;

            if (firstPoolBorrowerBalance > 0) {
                uint256 borrowerBalanceInUnderlying = firstPoolBorrowerBalance.mul(
                    indexes.poolBorrowIndex
                );
                uint256 matchedP2P = CompoundMath.min(borrowerBalanceInUnderlying, _amount);

                supplyBalance.inP2P += matchedP2P.div(indexes.p2pSupplyIndex);
                _amount -= matchedP2P;
            }
        }

        if (_amount > 0) supplyBalance.onPool += _amount.div(indexes.poolSupplyIndex);

        balanceOnPool = supplyBalance.onPool.mul(indexes.poolSupplyIndex);
        balanceInP2P = supplyBalance.inP2P.mul(indexes.p2pSupplyIndex);
        totalBalance = balanceOnPool + balanceInP2P;

        nextSupplyRatePerBlock = _getUserSupplyRatePerBlock(
            _poolTokenAddress,
            balanceOnPool,
            balanceInP2P,
            totalBalance
        );
    }

    
    
    /// a borrower could be matched more than once instantly or later and thus benefit from a lower borrow rate.
    
    
    
    
    
    
    
    function getNextUserBorrowRatePerBlock(
        address _poolTokenAddress,
        address _user,
        uint256 _amount
    )
        external
        view
        returns (
            uint256 nextBorrowRatePerBlock,
            uint256 balanceOnPool,
            uint256 balanceInP2P,
            uint256 totalBalance
        )
    {
        Types.BorrowBalance memory borrowBalance = morpho.borrowBalanceInOf(
            _poolTokenAddress,
            _user
        );

        Indexes memory indexes;
        (
            indexes.p2pBorrowIndex,
            indexes.poolSupplyIndex,
            indexes.poolBorrowIndex
        ) = _getCurrentP2PBorrowIndex(_poolTokenAddress);

        if (_amount > 0) {
            Types.Delta memory delta = morpho.deltas(_poolTokenAddress);
            if (delta.p2pSupplyDelta > 0) {
                uint256 deltaInUnderlying = delta.p2pSupplyDelta.mul(indexes.poolSupplyIndex);
                uint256 matchedDelta = CompoundMath.min(deltaInUnderlying, _amount);

                borrowBalance.inP2P += matchedDelta.div(indexes.p2pBorrowIndex);
                _amount -= matchedDelta;
            }
        }

        if (_amount > 0 && !morpho.p2pDisabled(_poolTokenAddress)) {
            uint256 firstPoolSupplierBalance = morpho
            .supplyBalanceInOf(
                _poolTokenAddress,
                morpho.getHead(_poolTokenAddress, Types.PositionType.SUPPLIERS_ON_POOL)
            ).onPool;

            if (firstPoolSupplierBalance > 0) {
                uint256 supplierBalanceInUnderlying = firstPoolSupplierBalance.mul(
                    indexes.poolSupplyIndex
                );
                uint256 matchedP2P = CompoundMath.min(supplierBalanceInUnderlying, _amount);

                borrowBalance.inP2P += matchedP2P.div(indexes.p2pBorrowIndex);
                _amount -= matchedP2P;
            }
        }

        if (_amount > 0) borrowBalance.onPool += _amount.div(indexes.poolBorrowIndex);

        balanceOnPool = borrowBalance.onPool.mul(indexes.poolBorrowIndex);
        balanceInP2P = borrowBalance.inP2P.mul(indexes.p2pBorrowIndex);
        totalBalance = balanceOnPool + balanceInP2P;

        nextBorrowRatePerBlock = _getUserBorrowRatePerBlock(
            _poolTokenAddress,
            balanceOnPool,
            balanceInP2P,
            totalBalance
        );
    }

    /// PUBLIC ///

    
    
    
    
    
    function getAverageSupplyRatePerBlock(address _poolTokenAddress)
        public
        view
        returns (
            uint256 avgSupplyRatePerBlock,
            uint256 p2pSupplyAmount,
            uint256 poolSupplyAmount
        )
    {
        ICToken cToken = ICToken(_poolTokenAddress);

        uint256 poolSupplyRate = cToken.supplyRatePerBlock();
        uint256 poolBorrowRate = cToken.borrowRatePerBlock();

        (uint256 p2pSupplyIndex, uint256 poolSupplyIndex, ) = _getCurrentP2PSupplyIndex(
            _poolTokenAddress
        );

        Types.MarketParameters memory marketParams = morpho.marketParameters(_poolTokenAddress);
        // do not take delta into account as it's already taken into account in p2pSupplyAmount & poolSupplyAmount
        uint256 p2pSupplyRate = InterestRatesModel.computeP2PSupplyRatePerBlock(
            InterestRatesModel.P2PRateComputeParams({
                p2pRate: InterestRatesModel.computeRawP2PRatePerBlock(
                    poolSupplyRate,
                    poolBorrowRate,
                    marketParams.p2pIndexCursor
                ),
                poolRate: poolSupplyRate,
                poolIndex: poolSupplyIndex,
                p2pIndex: p2pSupplyIndex,
                p2pDelta: 0,
                p2pAmount: 0,
                reserveFactor: marketParams.reserveFactor
            })
        );

        (p2pSupplyAmount, poolSupplyAmount) = _getMarketSupply(
            _poolTokenAddress,
            p2pSupplyIndex,
            poolSupplyIndex
        );

        uint256 totalSupply = p2pSupplyAmount + poolSupplyAmount;
        if (p2pSupplyAmount > 0)
            avgSupplyRatePerBlock += p2pSupplyRate.mul(p2pSupplyAmount.div(totalSupply));
        if (poolSupplyAmount > 0)
            avgSupplyRatePerBlock += poolSupplyRate.mul(poolSupplyAmount.div(totalSupply));
    }

    
    
    
    
    
    function getAverageBorrowRatePerBlock(address _poolTokenAddress)
        public
        view
        returns (
            uint256 avgBorrowRatePerBlock,
            uint256 p2pBorrowAmount,
            uint256 poolBorrowAmount
        )
    {
        ICToken cToken = ICToken(_poolTokenAddress);

        uint256 poolSupplyRate = cToken.supplyRatePerBlock();
        uint256 poolBorrowRate = cToken.borrowRatePerBlock();

        (uint256 p2pBorrowIndex, , uint256 poolBorrowIndex) = _getCurrentP2PBorrowIndex(
            _poolTokenAddress
        );

        Types.MarketParameters memory marketParams = morpho.marketParameters(_poolTokenAddress);
        // do not take delta into account as it's already taken into account in p2pBorrowAmount & poolBorrowAmount
        uint256 p2pBorrowRate = InterestRatesModel.computeP2PBorrowRatePerBlock(
            InterestRatesModel.P2PRateComputeParams({
                p2pRate: InterestRatesModel.computeRawP2PRatePerBlock(
                    poolSupplyRate,
                    poolBorrowRate,
                    marketParams.p2pIndexCursor
                ),
                poolRate: poolBorrowRate,
                poolIndex: poolBorrowIndex,
                p2pIndex: p2pBorrowIndex,
                p2pDelta: 0,
                p2pAmount: 0,
                reserveFactor: marketParams.reserveFactor
            })
        );

        (p2pBorrowAmount, poolBorrowAmount) = _getMarketBorrow(
            _poolTokenAddress,
            p2pBorrowIndex,
            poolBorrowIndex
        );

        uint256 totalBorrow = p2pBorrowAmount + poolBorrowAmount;
        if (p2pBorrowAmount > 0)
            avgBorrowRatePerBlock += p2pBorrowRate.mul(p2pBorrowAmount.div(totalBorrow));
        if (poolBorrowAmount > 0)
            avgBorrowRatePerBlock += poolBorrowRate.mul(poolBorrowAmount.div(totalBorrow));
    }

    
    
    
    
    
    
    
    function getRatesPerBlock(address _poolTokenAddress)
        public
        view
        returns (
            uint256 p2pSupplyRate,
            uint256 p2pBorrowRate,
            uint256 poolSupplyRate,
            uint256 poolBorrowRate
        )
    {
        ICToken cToken = ICToken(_poolTokenAddress);

        poolSupplyRate = cToken.supplyRatePerBlock();
        poolBorrowRate = cToken.borrowRatePerBlock();

        Types.MarketParameters memory marketParams = morpho.marketParameters(_poolTokenAddress);
        uint256 p2pRate = ((MAX_BASIS_POINTS - marketParams.p2pIndexCursor) *
            poolSupplyRate +
            marketParams.p2pIndexCursor *
            poolBorrowRate) / MAX_BASIS_POINTS;

        Types.Delta memory delta = morpho.deltas(_poolTokenAddress);
        (
            uint256 p2pSupplyIndex,
            uint256 p2pBorrowIndex,
            uint256 poolSupplyIndex,
            uint256 poolBorrowIndex
        ) = getIndexes(_poolTokenAddress, false);

        p2pSupplyRate = InterestRatesModel.computeP2PSupplyRatePerBlock(
            InterestRatesModel.P2PRateComputeParams({
                p2pRate: p2pRate,
                poolRate: poolSupplyRate,
                poolIndex: poolSupplyIndex,
                p2pIndex: p2pSupplyIndex,
                p2pDelta: delta.p2pSupplyDelta,
                p2pAmount: delta.p2pSupplyAmount,
                reserveFactor: marketParams.reserveFactor
            })
        );

        p2pBorrowRate = InterestRatesModel.computeP2PBorrowRatePerBlock(
            InterestRatesModel.P2PRateComputeParams({
                p2pRate: p2pRate,
                poolRate: poolBorrowRate,
                poolIndex: poolBorrowIndex,
                p2pIndex: p2pBorrowIndex,
                p2pDelta: delta.p2pBorrowDelta,
                p2pAmount: delta.p2pBorrowAmount,
                reserveFactor: marketParams.reserveFactor
            })
        );
    }

    
    
    
    
    function getCurrentUserSupplyRatePerBlock(address _poolTokenAddress, address _user)
        public
        view
        returns (uint256)
    {
        (
            uint256 balanceOnPool,
            uint256 balanceInP2P,
            uint256 totalBalance
        ) = getCurrentSupplyBalanceInOf(_poolTokenAddress, _user);

        return
            _getUserSupplyRatePerBlock(
                _poolTokenAddress,
                balanceOnPool,
                balanceInP2P,
                totalBalance
            );
    }

    
    
    
    
    function getCurrentUserBorrowRatePerBlock(address _poolTokenAddress, address _user)
        public
        view
        returns (uint256)
    {
        (
            uint256 balanceOnPool,
            uint256 balanceInP2P,
            uint256 totalBalance
        ) = getCurrentBorrowBalanceInOf(_poolTokenAddress, _user);

        return
            _getUserBorrowRatePerBlock(
                _poolTokenAddress,
                balanceOnPool,
                balanceInP2P,
                totalBalance
            );
    }

    /// INTERNAL ///

    
    
    
    
    
    
    function _getMarketSupply(
        address _poolTokenAddress,
        uint256 _p2pSupplyIndex,
        uint256 _poolSupplyIndex
    ) internal view returns (uint256 p2pSupplyAmount, uint256 poolSupplyAmount) {
        ICToken poolToken = ICToken(_poolTokenAddress);
        Types.Delta memory delta = morpho.deltas(_poolTokenAddress);

        p2pSupplyAmount =
            delta.p2pSupplyAmount.mul(_p2pSupplyIndex) -
            delta.p2pSupplyDelta.mul(_poolSupplyIndex);
        poolSupplyAmount = poolToken.balanceOf(address(morpho)).mul(_poolSupplyIndex);
    }

    
    
    
    
    
    
    function _getMarketBorrow(
        address _poolTokenAddress,
        uint256 _p2pBorrowIndex,
        uint256 _poolBorrowIndex
    ) internal view returns (uint256 p2pBorrowAmount, uint256 poolBorrowAmount) {
        ICToken poolToken = ICToken(_poolTokenAddress);
        Types.Delta memory delta = morpho.deltas(_poolTokenAddress);

        p2pBorrowAmount =
            delta.p2pBorrowAmount.mul(_p2pBorrowIndex) -
            delta.p2pBorrowDelta.mul(_poolBorrowIndex);
        poolBorrowAmount = poolToken
        .borrowBalanceStored(address(morpho))
        .div(poolToken.borrowIndex())
        .mul(_poolBorrowIndex);
    }

    
    
    
    
    
    
    function _getUserSupplyRatePerBlock(
        address _poolTokenAddress,
        uint256 _balanceOnPool,
        uint256 _balanceInP2P,
        uint256 _totalBalance
    ) internal view returns (uint256 supplyRatePerBlock_) {
        if (_totalBalance == 0) return 0;

        (uint256 p2pSupplyRate, , uint256 poolSupplyRate, ) = getRatesPerBlock(_poolTokenAddress);

        if (_balanceOnPool > 0)
            supplyRatePerBlock_ += poolSupplyRate.mul(_balanceOnPool.div(_totalBalance));
        if (_balanceInP2P > 0)
            supplyRatePerBlock_ += p2pSupplyRate.mul(_balanceInP2P.div(_totalBalance));
    }

    
    
    
    
    
    
    function _getUserBorrowRatePerBlock(
        address _poolTokenAddress,
        uint256 _balanceOnPool,
        uint256 _balanceInP2P,
        uint256 _totalBalance
    ) internal view returns (uint256 borrowRatePerBlock_) {
        if (_totalBalance == 0) return 0;

        (, uint256 p2pBorrowRate, , uint256 poolBorrowRate) = getRatesPerBlock(_poolTokenAddress);

        if (_balanceOnPool > 0)
            borrowRatePerBlock_ += poolBorrowRate.mul(_balanceOnPool.div(_totalBalance));
        if (_balanceInP2P > 0)
            borrowRatePerBlock_ += p2pBorrowRate.mul(_balanceInP2P.div(_totalBalance));
    }
}

// 
pragma solidity ^0.8.0;







abstract contract MarketsLens is RatesLens {
    using CompoundMath for uint256;

    /// EXTERNAL ///

    
    
    
    function isMarketCreated(address _poolTokenAddress) external view returns (bool) {
        return morpho.marketStatus(_poolTokenAddress).isCreated;
    }

    
    
    
    function isMarketCreatedAndNotPaused(address _poolTokenAddress) external view returns (bool) {
        Types.MarketStatus memory marketStatus = morpho.marketStatus(_poolTokenAddress);
        return marketStatus.isCreated && !marketStatus.isPaused;
    }

    
    
    
    function isMarketCreatedAndNotPausedNorPartiallyPaused(address _poolTokenAddress)
        external
        view
        returns (bool)
    {
        Types.MarketStatus memory marketStatus = morpho.marketStatus(_poolTokenAddress);
        return marketStatus.isCreated && !marketStatus.isPaused && !marketStatus.isPartiallyPaused;
    }

    
    
    function getAllMarkets() external view returns (address[] memory marketsCreated) {
        return morpho.getAllMarkets();
    }

    
    
    
    
    
    
    
    
    
    function getMainMarketData(address _poolTokenAddress)
        external
        view
        returns (
            uint256 avgSupplyRatePerBlock,
            uint256 avgBorrowRatePerBlock,
            uint256 p2pSupplyAmount,
            uint256 p2pBorrowAmount,
            uint256 poolSupplyAmount,
            uint256 poolBorrowAmount
        )
    {
        (avgSupplyRatePerBlock, p2pSupplyAmount, poolSupplyAmount) = getAverageSupplyRatePerBlock(
            _poolTokenAddress
        );
        (avgBorrowRatePerBlock, p2pBorrowAmount, poolBorrowAmount) = getAverageBorrowRatePerBlock(
            _poolTokenAddress
        );
    }

    
    
    
    
    
    
    
    
    
    function getAdvancedMarketData(address _poolTokenAddress)
        external
        view
        returns (
            uint256 p2pSupplyIndex,
            uint256 p2pBorrowIndex,
            uint256 poolSupplyIndex,
            uint256 poolBorrowIndex,
            uint32 lastUpdateBlockNumber,
            uint256 p2pSupplyDelta,
            uint256 p2pBorrowDelta
        )
    {
        (p2pSupplyIndex, p2pBorrowIndex, poolSupplyIndex, poolBorrowIndex) = getIndexes(
            _poolTokenAddress,
            false
        );

        Types.Delta memory delta = morpho.deltas(_poolTokenAddress);
        p2pSupplyDelta = delta.p2pSupplyDelta.mul(poolSupplyIndex);
        p2pBorrowDelta = delta.p2pBorrowDelta.mul(poolBorrowIndex);

        Types.LastPoolIndexes memory lastPoolIndexes = morpho.lastPoolIndexes(_poolTokenAddress);
        lastUpdateBlockNumber = lastPoolIndexes.lastUpdateBlockNumber;
    }

    
    
    
    
    
    
    
    
    
    function getMarketConfiguration(address _poolTokenAddress)
        external
        view
        returns (
            address underlying,
            bool isCreated,
            bool p2pDisabled,
            bool isPaused,
            bool isPartiallyPaused,
            uint16 reserveFactor,
            uint16 p2pIndexCursor,
            uint256 collateralFactor
        )
    {
        underlying = _poolTokenAddress == morpho.cEth()
            ? morpho.wEth()
            : ICToken(_poolTokenAddress).underlying();

        Types.MarketStatus memory marketStatus = morpho.marketStatus(_poolTokenAddress);
        isCreated = marketStatus.isCreated;
        p2pDisabled = morpho.p2pDisabled(_poolTokenAddress);
        isPaused = marketStatus.isPaused;
        isPartiallyPaused = marketStatus.isPartiallyPaused;

        Types.MarketParameters memory marketParams = morpho.marketParameters(_poolTokenAddress);
        reserveFactor = marketParams.reserveFactor;
        p2pIndexCursor = marketParams.p2pIndexCursor;

        (, collateralFactor, ) = comptroller.markets(_poolTokenAddress);
    }

    /// PUBLIC ///

    
    
    
    
    function getTotalMarketSupply(address _poolTokenAddress)
        public
        view
        returns (uint256 p2pSupplyAmount, uint256 poolSupplyAmount)
    {
        (uint256 p2pSupplyIndex, uint256 poolSupplyIndex, ) = _getCurrentP2PSupplyIndex(
            _poolTokenAddress
        );

        (p2pSupplyAmount, poolSupplyAmount) = _getMarketSupply(
            _poolTokenAddress,
            p2pSupplyIndex,
            poolSupplyIndex
        );
    }

    
    
    
    
    function getTotalMarketBorrow(address _poolTokenAddress)
        public
        view
        returns (uint256 p2pBorrowAmount, uint256 poolBorrowAmount)
    {
        (uint256 p2pBorrowIndex, , uint256 poolBorrowIndex) = _getCurrentP2PBorrowIndex(
            _poolTokenAddress
        );

        (p2pBorrowAmount, poolBorrowAmount) = _getMarketBorrow(
            _poolTokenAddress,
            p2pBorrowIndex,
            poolBorrowIndex
        );
    }
}

// 
pragma solidity ^0.8.0;









abstract contract RewardsLens is MarketsLens {
    using CompoundMath for uint256;

    /// ERRORS ///

    
    error InvalidPoolToken();

    /// EXTERNAL ///

    
    
    
    function getUserUnclaimedRewards(address[] calldata _poolTokenAddresses, address _user)
        external
        view
        returns (uint256 unclaimedRewards)
    {
        unclaimedRewards = rewardsManager.userUnclaimedCompRewards(_user);

        for (uint256 i; i < _poolTokenAddresses.length; ) {
            address cTokenAddress = _poolTokenAddresses[i];

            (bool isListed, , ) = comptroller.markets(cTokenAddress);
            if (!isListed) revert InvalidPoolToken();

            unclaimedRewards += getAccruedSupplierComp(
                _user,
                cTokenAddress,
                morpho.supplyBalanceInOf(cTokenAddress, _user).onPool
            );
            unclaimedRewards += getAccruedBorrowerComp(
                _user,
                cTokenAddress,
                morpho.borrowBalanceInOf(cTokenAddress, _user).onPool
            );

            unchecked {
                ++i;
            }
        }
    }

    /// PUBLIC ///

    
    
    
    
    
    function getAccruedSupplierComp(
        address _supplier,
        address _poolTokenAddress,
        uint256 _balance
    ) public view returns (uint256) {
        uint256 supplyIndex = getCurrentCompSupplyIndex(_poolTokenAddress);
        uint256 supplierIndex = rewardsManager.compSupplierIndex(_poolTokenAddress, _supplier);

        if (supplierIndex == 0) return 0;
        return (_balance * (supplyIndex - supplierIndex)) / 1e36;
    }

    
    
    
    
    
    function getAccruedBorrowerComp(
        address _borrower,
        address _poolTokenAddress,
        uint256 _balance
    ) public view returns (uint256) {
        uint256 borrowIndex = getCurrentCompBorrowIndex(_poolTokenAddress);
        uint256 borrowerIndex = rewardsManager.compBorrowerIndex(_poolTokenAddress, _borrower);

        if (borrowerIndex == 0) return 0;
        return (_balance * (borrowIndex - borrowerIndex)) / 1e36;
    }

    
    
    
    function getCurrentCompSupplyIndex(address _poolTokenAddress) public view returns (uint256) {
        IComptroller.CompMarketState memory localSupplyState = rewardsManager
        .getLocalCompSupplyState(_poolTokenAddress);

        if (localSupplyState.block == block.number) return localSupplyState.index;
        else {
            IComptroller.CompMarketState memory supplyState = comptroller.compSupplyState(
                _poolTokenAddress
            );

            uint256 deltaBlocks = block.number - supplyState.block;
            uint256 supplySpeed = comptroller.compSupplySpeeds(_poolTokenAddress);

            if (deltaBlocks > 0 && supplySpeed > 0) {
                uint256 supplyTokens = ICToken(_poolTokenAddress).totalSupply();
                uint256 compAccrued = deltaBlocks * supplySpeed;
                uint256 ratio = supplyTokens > 0 ? (compAccrued * 1e36) / supplyTokens : 0;

                return supplyState.index + ratio;
            }

            return supplyState.index;
        }
    }

    
    
    
    function getCurrentCompBorrowIndex(address _poolTokenAddress) public view returns (uint256) {
        IComptroller.CompMarketState memory localBorrowState = rewardsManager
        .getLocalCompBorrowState(_poolTokenAddress);

        if (localBorrowState.block == block.number) return localBorrowState.index;
        else {
            IComptroller.CompMarketState memory borrowState = comptroller.compBorrowState(
                _poolTokenAddress
            );
            uint256 deltaBlocks = block.number - borrowState.block;
            uint256 borrowSpeed = comptroller.compBorrowSpeeds(_poolTokenAddress);

            if (deltaBlocks > 0 && borrowSpeed > 0) {
                ICToken cToken = ICToken(_poolTokenAddress);

                uint256 borrowAmount = cToken.totalBorrows().div(cToken.borrowIndex());
                uint256 compAccrued = deltaBlocks * borrowSpeed;
                uint256 ratio = borrowAmount > 0 ? (compAccrued * 1e36) / borrowAmount : 0;

                return borrowState.index + ratio;
            }

            return borrowState.index;
        }
    }
}

interface ICToken {
    function isCToken() external returns (bool);

    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function borrowRatePerBlock() external view returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account) external view returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function getCash() external view returns (uint256);

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function borrowRate() external returns (uint256);

    function borrowIndex() external view returns (uint256);

    function borrow(uint256) external returns (uint256);

    function repayBorrow(uint256) external returns (uint256);

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (uint256);

    function underlying() external view returns (address);

    function mint(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function accrueInterest() external returns (uint256);

    function totalSupply() external view returns (uint256);

    function totalBorrows() external view returns (uint256);

    function accrualBlockNumber() external view returns (uint256);

    function totalReserves() external view returns (uint256);

    function interestRateModel() external view returns (IInterestRateModel);

    function reserveFactorMantissa() external view returns (uint256);

    function initialExchangeRateMantissa() external view returns (uint256);

    /*** Admin Functions ***/

    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint256);

    function _acceptAdmin() external returns (uint256);

    function _setComptroller(IComptroller newComptroller) external returns (uint256);

    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);

    function _reduceReserves(uint256 reduceAmount) external returns (uint256);

    function _setInterestRateModel(IInterestRateModel newInterestRateModel)
        external
        returns (uint256);
}
// 
pragma solidity ^0.8.0;







contract Lens is RewardsLens {
    using CompoundMath for uint256;

    function initialize(address _morphoAddress) external initializer {
        morpho = IMorpho(_morphoAddress);
        comptroller = IComptroller(morpho.comptroller());
        rewardsManager = IRewardsManager(morpho.rewardsManager());
    }

    
    
    
    
    function getTotalSupply()
        external
        view
        returns (
            uint256 p2pSupplyAmount,
            uint256 poolSupplyAmount,
            uint256 totalSupplyAmount
        )
    {
        address[] memory markets = morpho.getAllMarkets();
        ICompoundOracle oracle = ICompoundOracle(comptroller.oracle());

        uint256 nbMarkets = markets.length;
        for (uint256 i; i < nbMarkets; ) {
            address _poolTokenAddress = markets[i];

            (uint256 marketP2PSupplyAmount, uint256 marketPoolSupplyAmount) = getTotalMarketSupply(
                _poolTokenAddress
            );

            uint256 underlyingPrice = oracle.getUnderlyingPrice(_poolTokenAddress);
            if (underlyingPrice == 0) revert CompoundOracleFailed();

            p2pSupplyAmount += marketP2PSupplyAmount.mul(underlyingPrice);
            poolSupplyAmount += marketPoolSupplyAmount.mul(underlyingPrice);

            unchecked {
                ++i;
            }
        }

        totalSupplyAmount = p2pSupplyAmount + poolSupplyAmount;
    }

    
    
    
    
    function getTotalBorrow()
        external
        view
        returns (
            uint256 p2pBorrowAmount,
            uint256 poolBorrowAmount,
            uint256 totalBorrowAmount
        )
    {
        address[] memory markets = morpho.getAllMarkets();
        ICompoundOracle oracle = ICompoundOracle(comptroller.oracle());

        uint256 nbMarkets = markets.length;
        for (uint256 i; i < nbMarkets; ) {
            address _poolTokenAddress = markets[i];

            (uint256 marketP2PBorrowAmount, uint256 marketPoolBorrowAmount) = getTotalMarketBorrow(
                _poolTokenAddress
            );

            uint256 underlyingPrice = oracle.getUnderlyingPrice(_poolTokenAddress);
            if (underlyingPrice == 0) revert CompoundOracleFailed();

            p2pBorrowAmount += marketP2PBorrowAmount.mul(underlyingPrice);
            poolBorrowAmount += marketPoolBorrowAmount.mul(underlyingPrice);

            unchecked {
                ++i;
            }
        }

        totalBorrowAmount = p2pBorrowAmount + poolBorrowAmount;
    }
}

// 
pragma solidity ^0.8.0;





library CompoundMath {
    /// ERRORS ///

    
    error NumberExceeds224Bits();

    
    error NumberExceeds32Bits();

    /// INTERNAL ///

    function mul(uint256 x, uint256 y) internal pure returns (uint256) {
        return (x * y) / 1e18;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((1e18 * x * 1e18) / y) / 1e18;
    }

    function safe224(uint256 n) internal pure returns (uint224) {
        if (n >= 2**224) revert NumberExceeds224Bits();
        return uint224(n);
    }

    function safe32(uint256 n) internal pure returns (uint32) {
        if (n >= 2**32) revert NumberExceeds32Bits();
        return uint32(n);
    }

    function min(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256) {
        return a < b ? a < c ? a : c : b < c ? b : c;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a - b : 0;
    }
}

// 
pragma solidity ^0.8.0;

interface ICEth {
    function accrueInterest() external returns (uint256);

    function borrowRate() external returns (uint256);

    function borrowIndex() external returns (uint256);

    function borrowBalanceStored(address) external returns (uint256);

    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function transfer(address dst, uint256 amount) external returns (bool);

    function balanceOf(address) external returns (uint256);

    function balanceOfUnderlying(address account) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function repayBorrow() external payable;

    function borrowBalanceCurrent(address) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);
}

interface IComptroller {
    struct CompMarketState {
        
        uint224 index;
        
        uint32 block;
    }

    function liquidationIncentiveMantissa() external view returns (uint256);

    function closeFactorMantissa() external view returns (uint256);

    function admin() external view returns (address);

    function oracle() external view returns (address);

    function borrowCaps(address) external view returns (uint256);

    function markets(address)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isComped
        );

    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);

    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);

    function mintVerify(
        address cToken,
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    ) external;

    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);

    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;

    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 borrowerIndex
    ) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    ) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;

    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);

    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 repayAmount
    ) external view returns (uint256, uint256);

    function getAccountLiquidity(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getHypotheticalAccountLiquidity(
        address,
        address,
        uint256,
        uint256
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        );

    function checkMembership(address, address) external view returns (bool);

    function claimComp(address holder) external;

    function claimComp(address holder, address[] memory cTokens) external;

    function compSpeeds(address) external view returns (uint256);

    function compSupplySpeeds(address) external view returns (uint256);

    function compBorrowSpeeds(address) external view returns (uint256);

    function compSupplyState(address) external view returns (CompMarketState memory);

    function compBorrowState(address) external view returns (CompMarketState memory);

    function getCompAddress() external view returns (address);

    function _setPriceOracle(address newOracle) external returns (uint256);

    function _setMintPaused(ICToken cToken, bool state) external returns (bool);

    function _setBorrowPaused(ICToken cToken, bool state) external returns (bool);

    function _setCollateralFactor(ICToken cToken, uint256 newCollateralFactorMantissa)
        external
        returns (uint256);

    function _setCompSpeeds(
        ICToken[] memory cTokens,
        uint256[] memory supplySpeeds,
        uint256[] memory borrowSpeeds
    ) external;
}

interface IInterestRateModel {
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);

    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);
}

interface ICEther is ICToken {
    function mint() external payable;

    function repayBorrow() external payable;
}

interface ICompoundOracle {
    function getUnderlyingPrice(address) external view returns (uint256);
}

// 
pragma solidity ^0.8.0;








// prettier-ignore
interface IMorpho {

    /// STORAGE ///

    function defaultMaxGasForMatching() external view returns (Types.MaxGasForMatching memory);
    function maxSortedUsers() external view returns (uint256);
    function dustThreshold() external view returns (uint256);
    function supplyBalanceInOf(address, address) external view returns (Types.SupplyBalance memory);
    function borrowBalanceInOf(address, address) external view returns (Types.BorrowBalance memory);
    function enteredMarkets(address) external view returns (address);
    function deltas(address) external view returns (Types.Delta memory);
    function marketsCreated() external view returns (address[] memory);
    function marketParameters(address) external view returns (Types.MarketParameters memory);
    function p2pDisabled(address) external view returns (bool);
    function p2pSupplyIndex(address) external view returns (uint256);
    function p2pBorrowIndex(address) external view returns (uint256);
    function lastPoolIndexes(address) external view returns (Types.LastPoolIndexes memory);
    function marketStatus(address) external view returns (Types.MarketStatus memory);
    function comptroller() external view returns (IComptroller);
    function interestRatesManager() external view returns (IInterestRatesManager);
    function rewardsManager() external view returns (IRewardsManager);
    function positionsManager() external view returns (IPositionsManager);
    function incentiveVault() external view returns (IIncentivesVault);
    function treasuryVault() external view returns (address);
    function cEth() external view returns (address);
    function wEth() external view returns (address);

    /// GETTERS ///

    function updateP2PIndexes(address _poolTokenAddress) external;
    function getEnteredMarkets(address _user) external view returns (address[] memory enteredMarkets_);
    function getAllMarkets() external view returns (address[] memory marketsCreated_);
    function getHead(address _poolTokenAddress, Types.PositionType _positionType) external view returns (address head);
    function getNext(address _poolTokenAddress, Types.PositionType _positionType, address _user) external view returns (address next);

    /// GOVERNANCE ///

    function setMaxSortedUsers(uint256 _newMaxSortedUsers) external;
    function setDefaultMaxGasForMatching(Types.MaxGasForMatching memory _maxGasForMatching) external;
    function setTreasuryVault(address _newTreasuryVaultAddress) external;
    function setIncentivesVault(address _newIncentivesVault) external;
    function setRewardsManager(address _rewardsManagerAddress) external;
    function setDustThreshold(uint256 _dustThreshold) external;
    function setP2PDisable(address _poolTokenAddress, bool _p2pDisabled) external;
    function setReserveFactor(address _poolTokenAddress, uint256 _newReserveFactor) external;
    function setP2PIndexCursor(address _poolTokenAddress, uint16 _p2pIndexCursor) external;
    function setPauseStatusForAllMarkets(bool _newStatus) external;
    function setPauseStatus(address _poolTokenAddress, bool _newStatus) external;
    function setPartialPauseStatus(address _poolTokenAddress, bool _newStatus) external;
    function setPauseStatus(address _poolTokenAddress) external;
    function setPartialPauseStatus(address _poolTokenAddress) external;
    function claimToTreasury(address _poolTokenAddress, uint256 _amount) external;
    function createMarket(address _poolTokenAddress, Types.MarketParameters calldata _params) external;

    /// USERS ///

    function supply(address _poolTokenAddress, address _onBehalf, uint256 _amount) external;
    function supply(address _poolTokenAddress, address _onBehalf, uint256 _amount, uint256 _maxGasForMatching) external;
    function borrow(address _poolTokenAddress, uint256 _amount) external;
    function borrow(address _poolTokenAddress, uint256 _amount, uint256 _maxGasForMatching) external;
    function withdraw(address _poolTokenAddress, uint256 _amount) external;
    function repay(address _poolTokenAddress, address _onBehalf, uint256 _amount) external;
    function liquidate(address _poolTokenBorrowedAddress, address _poolTokenCollateralAddress, address _borrower, uint256 _amount) external;
    function claimRewards(address[] calldata _cTokenAddresses, bool _tradeForMorphoToken) external returns (uint256 claimedAmount);
}

// 
pragma solidity ^0.8.0;

interface IInterestRatesManager {
    function updateP2PIndexes(address _marketAddress) external;
}

// 
pragma solidity ^0.8.0;



interface IRewardsManager {
    function initialize(address _morpho) external;

    function claimRewards(address[] calldata, address) external returns (uint256);

    function userUnclaimedCompRewards(address) external view returns (uint256);

    function compSupplierIndex(address, address) external view returns (uint256);

    function compBorrowerIndex(address, address) external view returns (uint256);

    function getLocalCompSupplyState(address _cTokenAddress)
        external
        view
        returns (IComptroller.CompMarketState memory);

    function getLocalCompBorrowState(address _cTokenAddress)
        external
        view
        returns (IComptroller.CompMarketState memory);

    function accrueUserSupplyUnclaimedRewards(
        address,
        address,
        uint256
    ) external;

    function accrueUserBorrowUnclaimedRewards(
        address,
        address,
        uint256
    ) external;
}

// 
pragma solidity ^0.8.0;

interface IPositionsManager {
    function supplyLogic(
        address _poolTokenAddress,
        address _supplier,
        address _onBehalf,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external;

    function borrowLogic(
        address _poolTokenAddress,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external;

    function withdrawLogic(
        address _poolTokenAddress,
        uint256 _amount,
        address _supplier,
        address _receiver,
        uint256 _maxGasForMatching
    ) external;

    function repayLogic(
        address _poolTokenAddress,
        address _repayer,
        address _onBehalf,
        uint256 _amount,
        uint256 _maxGasForMatching
    ) external;

    function liquidateLogic(
        address _poolTokenBorrowedAddress,
        address _poolTokenCollateralAddress,
        address _borrower,
        uint256 _amount
    ) external;
}

// 
pragma solidity ^0.8.0;



interface IIncentivesVault {
    function setOracle(IOracle _newOracle) external;

    function setMorphoDao(address _newMorphoDao) external;

    function setBonus(uint256 _newBonus) external;

    function setPauseStatus(bool _newStatus) external;

    function transferMorphoTokensToDao(uint256 _amount) external;

    function tradeCompForMorphoTokens(address _to, uint256 _amount) external;
}

// 
pragma solidity ^0.8.0;





library Types {
    /// ENUMS ///

    enum PositionType {
        SUPPLIERS_IN_P2P,
        SUPPLIERS_ON_POOL,
        BORROWERS_IN_P2P,
        BORROWERS_ON_POOL
    }

    /// STRUCTS ///

    struct SupplyBalance {
        uint256 inP2P; // In supplier's peer-to-peer unit, a unit that grows in underlying value, to keep track of the interests earned by suppliers in peer-to-peer. Multiply by the peer-to-peer supply index to get the underlying amount.
        uint256 onPool; // In cToken. Multiply by the pool supply index to get the underlying amount.
    }

    struct BorrowBalance {
        uint256 inP2P; // In borrower's peer-to-peer unit, a unit that grows in underlying value, to keep track of the interests paid by borrowers in peer-to-peer. Multiply by the peer-to-peer borrow index to get the underlying amount.
        uint256 onPool; // In cdUnit, a unit that grows in value, to keep track of the debt increase when borrowers are on Compound. Multiply by the pool borrow index to get the underlying amount.
    }

    // Max gas to consume during the matching process for supply, borrow, withdraw and repay functions.
    struct MaxGasForMatching {
        uint64 supply;
        uint64 borrow;
        uint64 withdraw;
        uint64 repay;
    }

    struct Delta {
        uint256 p2pSupplyDelta; // Difference between the stored peer-to-peer supply amount and the real peer-to-peer supply amount (in pool supply unit).
        uint256 p2pBorrowDelta; // Difference between the stored peer-to-peer borrow amount and the real peer-to-peer borrow amount (in pool borrow unit).
        uint256 p2pSupplyAmount; // Sum of all stored peer-to-peer supply (in peer-to-peer supply unit).
        uint256 p2pBorrowAmount; // Sum of all stored peer-to-peer borrow (in peer-to-peer borrow unit).
    }

    struct AssetLiquidityData {
        uint256 collateralValue; // The collateral value of the asset.
        uint256 maxDebtValue; // The maximum possible debt value of the asset.
        uint256 debtValue; // The debt value of the asset.
        uint256 underlyingPrice; // The price of the token.
        uint256 collateralFactor; // The liquidation threshold applied on this token.
    }

    struct LiquidityData {
        uint256 collateralValue; // The collateral value.
        uint256 maxDebtValue; // The maximum debt value possible.
        uint256 debtValue; // The debt value.
    }

    // Variables are packed together to save gas (will not exceed their limit during Morpho's lifetime).
    struct LastPoolIndexes {
        uint32 lastUpdateBlockNumber; // The last time the peer-to-peer indexes were updated.
        uint112 lastSupplyPoolIndex; // Last pool supply index.
        uint112 lastBorrowPoolIndex; // Last pool borrow index.
    }

    struct MarketParameters {
        uint16 reserveFactor; // Proportion of the interest earned by users sent to the DAO for each market, in basis point (100% = 10 000). The value is set at market creation.
        uint16 p2pIndexCursor; // Position of the peer-to-peer rate in the pool's spread. Determine the weights of the weighted arithmetic average in the indexes computations ((1 - p2pIndexCursor) * r^S + p2pIndexCursor * r^B) (in basis point).
    }

    struct MarketStatus {
        bool isCreated; // Whether or not this market is created.
        bool isPaused; // Whether the market is paused or not (all entry points on Morpho are frozen; supply, borrow, withdraw, repay and liquidate).
        bool isPartiallyPaused; // Whether the market is partially paused or not (only supply and borrow are frozen).
    }
}

// 
pragma solidity ^0.8.0;

interface IOracle {
    function consult(uint256 _amountIn) external returns (uint256);
}

// 
pragma solidity ^0.8.0;




library InterestRatesModel {
    using CompoundMath for uint256;

    uint256 public constant MAX_BASIS_POINTS = 10_000; // 100% (in basis points).
    uint256 public constant WAD = 1e18;

    /// STRUCTS ///

    struct GrowthFactors {
        uint256 poolSupplyGrowthFactor; // The pool's supply index growth factor (in wad).
        uint256 poolBorrowGrowthFactor; // The pool's borrow index growth factor (in wad).
        uint256 p2pGrowthFactor; // Morpho peer-to-peer's median index growth factor (in wad).
    }

    struct P2PIndexComputeParams {
        uint256 poolGrowthFactor; // The pool's index growth factor (in wad).
        uint256 p2pGrowthFactor; // Morpho peer-to-peer's median index growth factor (in wad).
        uint112 lastPoolIndex; // The pool's last stored index.
        uint256 lastP2PIndex; // Morpho's last stored peer-to-peer index.
        uint256 p2pDelta; // The peer-to-peer delta for the given market (in pool unit).
        uint256 p2pAmount; // The peer-to-peer amount for the given market (in peer-to-peer unit).
        uint16 reserveFactor; // The reserve factor of the given market (in bps).
    }

    struct P2PRateComputeParams {
        uint256 poolRate; // The pool's index growth factor (in wad).
        uint256 p2pRate; // Morpho peer-to-peer's median index growth factor (in wad).
        uint256 poolIndex; // The pool's last stored index.
        uint256 p2pIndex; // Morpho's last stored peer-to-peer index.
        uint256 p2pDelta; // The peer-to-peer delta for the given market (in pool unit).
        uint256 p2pAmount; // The peer-to-peer amount for the given market (in peer-to-peer unit).
        uint16 reserveFactor; // The reserve factor of the given market (in bps).
    }

    
    
    
    
    
    
    function computeGrowthFactors(
        uint256 _newPoolSupplyIndex,
        uint256 _newPoolBorrowIndex,
        Types.LastPoolIndexes memory _lastPoolIndexes,
        uint16 _p2pIndexCursor
    ) internal pure returns (GrowthFactors memory growthFactors_) {
        growthFactors_.poolSupplyGrowthFactor = _newPoolSupplyIndex.div(
            _lastPoolIndexes.lastSupplyPoolIndex
        );
        growthFactors_.poolBorrowGrowthFactor = _newPoolBorrowIndex.div(
            _lastPoolIndexes.lastBorrowPoolIndex
        );
        growthFactors_.p2pGrowthFactor =
            ((MAX_BASIS_POINTS - _p2pIndexCursor) *
                growthFactors_.poolSupplyGrowthFactor +
                _p2pIndexCursor *
                growthFactors_.poolBorrowGrowthFactor) /
            MAX_BASIS_POINTS;
    }

    
    
    
    function computeP2PSupplyIndex(P2PIndexComputeParams memory _params)
        internal
        pure
        returns (uint256 newP2PSupplyIndex_)
    {
        uint256 p2pSupplyGrowthFactor = _params.p2pGrowthFactor -
            (_params.reserveFactor * (_params.p2pGrowthFactor - _params.poolGrowthFactor)) /
            MAX_BASIS_POINTS;

        if (_params.p2pAmount == 0 || _params.p2pDelta == 0) {
            newP2PSupplyIndex_ = _params.lastP2PIndex.mul(p2pSupplyGrowthFactor);
        } else {
            uint256 shareOfTheDelta = CompoundMath.min(
                (_params.p2pDelta.mul(_params.lastPoolIndex)).div(
                    (_params.p2pAmount).mul(_params.lastP2PIndex)
                ),
                WAD // To avoid shareOfTheDelta > 1 with rounding errors.
            );

            newP2PSupplyIndex_ = _params.lastP2PIndex.mul(
                (WAD - shareOfTheDelta).mul(p2pSupplyGrowthFactor) +
                    shareOfTheDelta.mul(_params.poolGrowthFactor)
            );
        }
    }

    
    
    
    function computeP2PBorrowIndex(P2PIndexComputeParams memory _params)
        internal
        pure
        returns (uint256 newP2PBorrowIndex_)
    {
        uint256 p2pBorrowGrowthFactor = _params.p2pGrowthFactor +
            (_params.reserveFactor * (_params.poolGrowthFactor - _params.p2pGrowthFactor)) /
            MAX_BASIS_POINTS;

        if (_params.p2pAmount == 0 || _params.p2pDelta == 0) {
            newP2PBorrowIndex_ = _params.lastP2PIndex.mul(p2pBorrowGrowthFactor);
        } else {
            uint256 shareOfTheDelta = CompoundMath.min(
                (_params.p2pDelta.mul(_params.lastPoolIndex)).div(
                    (_params.p2pAmount).mul(_params.lastP2PIndex)
                ),
                WAD // To avoid shareOfTheDelta > 1 with rounding errors.
            );

            newP2PBorrowIndex_ = _params.lastP2PIndex.mul(
                (WAD - shareOfTheDelta).mul(p2pBorrowGrowthFactor) +
                    shareOfTheDelta.mul(_params.poolGrowthFactor)
            );
        }
    }

    
    
    
    
    
    function computeRawP2PRatePerBlock(
        uint256 _poolSupplyRate,
        uint256 _poolBorrowRate,
        uint256 _p2pIndexCursor
    ) internal pure returns (uint256) {
        return
            ((MAX_BASIS_POINTS - _p2pIndexCursor) *
                _poolSupplyRate +
                _p2pIndexCursor *
                _poolBorrowRate) / MAX_BASIS_POINTS;
    }

    
    
    
    function computeP2PSupplyRatePerBlock(P2PRateComputeParams memory _params)
        internal
        pure
        returns (uint256 p2pSupplyRate)
    {
        p2pSupplyRate =
            _params.p2pRate -
            ((_params.p2pRate - _params.poolRate) * _params.reserveFactor) /
            MAX_BASIS_POINTS;

        if (_params.p2pDelta > 0 && _params.p2pAmount > 0) {
            uint256 shareOfTheDelta = CompoundMath.min(
                (_params.p2pDelta.mul(_params.poolIndex)).div(
                    (_params.p2pAmount).mul(_params.p2pIndex)
                ),
                WAD // To avoid shareOfTheDelta > 1 with rounding errors.
            );

            p2pSupplyRate =
                p2pSupplyRate.mul(WAD - shareOfTheDelta) +
                _params.poolRate.mul(shareOfTheDelta);
        }
    }

    
    
    
    function computeP2PBorrowRatePerBlock(P2PRateComputeParams memory _params)
        internal
        pure
        returns (uint256 p2pBorrowRate)
    {
        p2pBorrowRate =
            _params.p2pRate +
            ((_params.poolRate - _params.p2pRate) * _params.reserveFactor) /
            MAX_BASIS_POINTS;

        if (_params.p2pDelta > 0 && _params.p2pAmount > 0) {
            uint256 shareOfTheDelta = CompoundMath.min(
                (_params.p2pDelta.mul(_params.poolIndex)).div(
                    (_params.p2pAmount).mul(_params.p2pIndex)
                ),
                WAD // To avoid shareOfTheDelta > 1 with rounding errors.
            );

            p2pBorrowRate =
                p2pBorrowRate.mul(WAD - shareOfTheDelta) +
                _params.poolRate.mul(shareOfTheDelta);
        }
    }
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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