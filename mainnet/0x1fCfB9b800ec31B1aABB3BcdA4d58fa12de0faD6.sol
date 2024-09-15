// SPDX-License-Identifier: GPL-2.0-or-later


// 

pragma solidity >=0.8.13;



interface IIndexRouter {
    struct MintParams {
        address index;
        uint amountInBase;
        address recipient;
    }

    struct MintSwapParams {
        address index;
        address inputToken;
        uint amountInInputToken;
        address recipient;
        uint[] buyAssetMinAmounts;
        address[][] paths;
        address[] swapFactories;
    }

    struct MintSwapValueParams {
        address index;
        address recipient;
        uint[] buyAssetMinAmounts;
        address[][] paths;
        address[] swapFactories;
    }

    struct BurnParams {
        address index;
        uint amount;
        address recipient;
    }

    struct BurnSwapParams {
        address index;
        uint amount;
        address recipient;
        address[][] paths;
        address[] swapFactories;
        uint[] buyAssetMinAmounts;
    }

    
    receive() external payable;

    
    
    function mint(MintParams calldata _params) external;

    
    
    function mintSwap(MintSwapParams calldata _params) external;

    
    
    
    
    
    
    function mintSwapWithPermit(
        MintSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    
    
    function mintSwapValue(MintSwapValueParams calldata _params) external payable;

    
    
    function burn(BurnParams calldata _params) external;

    
    
    
    
    
    
    function burnWithPermit(
        BurnParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    
    
    function burnSwap(BurnSwapParams calldata _params) external;

    
    
    
    
    
    
    function burnSwapWithPermit(
        BurnSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    
    
    function burnSwapValue(BurnSwapParams calldata _params) external;

    
    
    
    
    
    
    function burnSwapValueWithPermit(
        BurnSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    
    
    function registry() external view returns (address);

    
    
    function WETH() external view returns (address);

    
    
    function mintSwapIndexAmount(MintSwapParams calldata _params) external view returns (uint);

    
    
    
    function burnTokensAmount(address _index, uint _amount) external view returns (uint[] memory amounts);

    
    
    function burnTokenValue(BurnSwapParams calldata _params) external view returns (uint);
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// 

pragma solidity >=0.8.13;



interface IIndexLayout {
    
    
    function factory() external view returns (address);

    
    
    function vTokenFactory() external view returns (address);

    
    
    function registry() external view returns (address);
}

// 

pragma solidity >=0.8.13;



interface IAnatomyUpdater {
    event UpdateAnatomy(address asset, uint8 weight);
    event AssetRemoved(address asset);
}

// 

pragma solidity >=0.8.13;



interface IPriceOracle {
    
    
    function refreshedAssetPerBaseInUQ(address _asset) external returns (uint);

    
    
    function lastAssetPerBaseInUQ(address _asset) external view returns (uint);
}// 

pragma solidity 0.8.13;























contract IndexRouter is IIndexRouter {
    using FullMath for uint;
    using SafeERC20 for IERC20;
    using IndexLibrary for uint;
    using ERC165Checker for address;
    using UniswapV2Library for address;

    struct MintDetails {
        uint minAmountInBase;
        uint[] amountsInBase;
        uint[] inputAmountInToken;
        IvTokenFactory vTokenFactory;
    }

    
    bytes32 internal immutable INDEX_ROLE;
    
    bytes32 internal immutable ASSET_ROLE;
    
    bytes32 internal immutable SKIPPED_ASSET_ROLE;
    
    bytes32 internal immutable EXCHANGE_FACTORY_ROLE;

    
    address public immutable override WETH;
    
    address public immutable override registry;

    
    
    modifier isValidIndex(address _index) {
        require(IAccessControl(registry).hasRole(INDEX_ROLE, _index), "IndexRouter: INVALID");
        _;
    }

    constructor(address _WETH, address _registry) {
        require(_WETH != address(0), "IndexRouter: ZERO");

        bytes4[] memory interfaceIds = new bytes4[](2);
        interfaceIds[0] = type(IAccessControl).interfaceId;
        interfaceIds[1] = type(IIndexRegistry).interfaceId;
        require(_registry.supportsAllInterfaces(interfaceIds), "IndexRouter: INTERFACE");

        INDEX_ROLE = keccak256("INDEX_ROLE");
        ASSET_ROLE = keccak256("ASSET_ROLE");
        SKIPPED_ASSET_ROLE = keccak256("SKIPPED_ASSET_ROLE");
        EXCHANGE_FACTORY_ROLE = keccak256("EXCHANGE_FACTORY_ROLE");

        WETH = _WETH;
        registry = _registry;
    }

    
    
    receive() external payable override {
        require(msg.sender == WETH);
    }

    
    function mintSwapIndexAmount(MintSwapParams calldata _params)
        external
        view
        override
        isValidIndex(_params.index)
        returns (uint val)
    {
        (address[] memory _assets, uint8[] memory _weights) = IIndex(_params.index).anatomy();

        uint assetBalanceInBase;
        uint minAmountInBase = type(uint).max;

        for (uint i; i < _weights.length; ) {
            if (_weights[i] != 0) {
                uint _amount = (_params.amountInInputToken * _weights[i]) / IndexLibrary.MAX_WEIGHT;
                if (_assets[i] != _params.inputToken) {
                    uint[] memory a = UniswapV2Library.getAmountsOut(
                        _params.swapFactories[i],
                        _amount,
                        _params.paths[i]
                    );
                    _amount = a[a.length - 1];
                }

                uint assetPerBaseInUQ = IPhuturePriceOracle(IIndexRegistry(registry).priceOracle())
                    .lastAssetPerBaseInUQ(_assets[i]);
                IvToken vToken = IvToken(IvTokenFactory(IIndex(_params.index).vTokenFactory()).vTokenOf(_assets[i]));
                {
                    uint weightedPrice = assetPerBaseInUQ * _weights[i];
                    uint _minAmountInBase = _amount.mulDiv(FixedPoint112.Q112 * IndexLibrary.MAX_WEIGHT, weightedPrice);
                    if (_minAmountInBase < minAmountInBase) {
                        minAmountInBase = _minAmountInBase;
                    }
                }

                if (address(vToken) != address(0)) {
                    assetBalanceInBase += vToken.lastAssetBalanceOf(_params.index).mulDiv(
                        FixedPoint112.Q112,
                        assetPerBaseInUQ
                    );
                }
            }

            unchecked {
                i = i + 1;
            }
        }

        IPhuturePriceOracle priceOracle = IPhuturePriceOracle(IIndexRegistry(registry).priceOracle());

        {
            address[] memory inactiveAssets = IIndex(_params.index).inactiveAnatomy();

            uint inactiveAssetsCount = inactiveAssets.length;
            for (uint i; i < inactiveAssetsCount; ) {
                address inactiveAsset = inactiveAssets[i];
                if (!IAccessControl(registry).hasRole(SKIPPED_ASSET_ROLE, inactiveAsset)) {
                    uint balanceInAsset = IvToken(
                        IvTokenFactory((IIndex(_params.index).vTokenFactory())).vTokenOf(inactiveAsset)
                    ).lastAssetBalanceOf(_params.index);

                    assetBalanceInBase += balanceInAsset.mulDiv(
                        FixedPoint112.Q112,
                        priceOracle.lastAssetPerBaseInUQ(inactiveAsset)
                    );
                }
                unchecked {
                    i = i + 1;
                }
            }
        }

        assert(minAmountInBase != type(uint).max);

        uint8 _indexDecimals = IERC20Metadata(_params.index).decimals();
        if (IERC20(_params.index).totalSupply() != 0) {
            require(assetBalanceInBase > 0, "Index: INSUFFICIENT_AMOUNT");

            val =
                (priceOracle.convertToIndex(minAmountInBase, _indexDecimals) * IERC20(_params.index).totalSupply()) /
                priceOracle.convertToIndex(assetBalanceInBase, _indexDecimals);
        } else {
            val = priceOracle.convertToIndex(minAmountInBase, _indexDecimals) - IndexLibrary.INITIAL_QUANTITY;
        }

        uint256 fee = (val * IFeePool(IIndexRegistry(registry).feePool()).mintingFeeInBPOf(_params.index)) /
            BP.DECIMAL_FACTOR;
        val -= fee;
    }

    
    function burnTokensAmount(address _index, uint _amount)
        public
        view
        override
        isValidIndex(_index)
        returns (uint[] memory amounts)
    {
        (address[] memory _assets, uint8[] memory _weights) = IIndex(_index).anatomy();
        address[] memory inactiveAssets = IIndex(_index).inactiveAnatomy();
        amounts = new uint[](_weights.length + inactiveAssets.length);

        uint assetsCount = _assets.length;

        bool containsBlacklistedAssets;
        for (uint i; i < assetsCount; ) {
            if (!IAccessControl(registry).hasRole(ASSET_ROLE, _assets[i])) {
                containsBlacklistedAssets = true;
                break;
            }

            unchecked {
                i = i + 1;
            }
        }

        if (!containsBlacklistedAssets) {
            _amount -=
                (_amount * IFeePool(IIndexRegistry(registry).feePool()).burningFeeInBPOf(_index)) /
                BP.DECIMAL_FACTOR;
        }

        uint totalAssetsCount = assetsCount + inactiveAssets.length;
        for (uint i; i < totalAssetsCount; ) {
            address asset = i < assetsCount ? _assets[i] : inactiveAssets[i - assetsCount];
            if (!(containsBlacklistedAssets && IAccessControl(registry).hasRole(SKIPPED_ASSET_ROLE, asset))) {
                uint indexAssetBalance = IvToken(IvTokenFactory(IIndex(_index).vTokenFactory()).vTokenOf(asset))
                    .balanceOf(_index);

                amounts[i] = (_amount * indexAssetBalance) / IERC20(_index).totalSupply();
            }

            unchecked {
                i = i + 1;
            }
        }
    }

    
    function burnTokenValue(BurnSwapParams calldata _params)
        external
        view
        override
        isValidIndex(_params.index)
        returns (uint value)
    {
        uint[] memory amounts = burnTokensAmount(_params.index, _params.amount);

        uint amountsCount = amounts.length;
        for (uint i; i < amountsCount; ) {
            uint amount = amounts[i];
            if (_params.paths[i][0] == _params.paths[i][_params.paths[i].length - 1]) {
                value += amount;
            } else {
                uint[] memory a = _params.swapFactories[i].getAmountsOut(amount, _params.paths[i]);
                value += a[a.length - 1];
            }

            unchecked {
                i = i + 1;
            }
        }
    }

    
    function mint(MintParams calldata _params) external override isValidIndex(_params.index) {
        IIndex index = IIndex(_params.index);
        (address[] memory _assets, uint8[] memory _weights) = index.anatomy();

        IvTokenFactory vTokenFactory = IvTokenFactory(index.vTokenFactory());
        IPriceOracle oracle = IPriceOracle(IIndexRegistry(registry).priceOracle());

        uint assetsCount = _assets.length;
        for (uint i; i < assetsCount; ) {
            if (_weights[i] > 0) {
                address asset = _assets[i];
                IERC20(asset).safeTransferFrom(
                    msg.sender,
                    vTokenFactory.createdVTokenOf(_assets[i]),
                    oracle.refreshedAssetPerBaseInUQ(asset).amountInAsset(_weights[i], _params.amountInBase)
                );
            }

            unchecked {
                i = i + 1;
            }
        }

        index.mint(_params.recipient);
    }

    
    function mintSwapWithPermit(
        MintSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isValidIndex(_params.index) {
        IERC20Permit(_params.inputToken).permit(
            msg.sender,
            address(this),
            _params.amountInInputToken,
            _deadline,
            _v,
            _r,
            _s
        );
        mintSwap(_params);
    }

    
    function mintSwapValue(MintSwapValueParams calldata _params) external payable override isValidIndex(_params.index) {
        IWETH(WETH).deposit{ value: msg.value }();

        _mint(_params, WETH, msg.value, address(this));

        uint change = IERC20(WETH).balanceOf(address(this));
        if (change != 0) {
            IWETH(WETH).withdraw(change);
            TransferHelper.safeTransferETH(_params.recipient, change);
        }
    }

    
    function burnWithPermit(
        BurnParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isValidIndex(_params.index) {
        IERC20Permit(_params.index).permit(msg.sender, address(this), _params.amount, _deadline, _v, _r, _s);
        burn(_params);
    }

    
    function burnSwapWithPermit(
        BurnSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isValidIndex(_params.index) {
        IERC20Permit(_params.index).permit(msg.sender, address(this), _params.amount, _deadline, _v, _r, _s);
        burnSwap(_params);
    }

    
    function burnSwapValueWithPermit(
        BurnSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override isValidIndex(_params.index) {
        IERC20Permit(_params.index).permit(msg.sender, address(this), _params.amount, _deadline, _v, _r, _s);
        burnSwapValue(_params);
    }

    
    function mintSwap(MintSwapParams calldata _params) public override isValidIndex(_params.index) {
        _mint(
            MintSwapValueParams({
                index: _params.index,
                recipient: _params.recipient,
                buyAssetMinAmounts: _params.buyAssetMinAmounts,
                paths: _params.paths,
                swapFactories: _params.swapFactories
            }),
            _params.inputToken,
            _params.amountInInputToken,
            msg.sender
        );
    }

    
    function burn(BurnParams calldata _params) public override isValidIndex(_params.index) {
        IERC20(_params.index).safeTransferFrom(msg.sender, _params.index, _params.amount);
        IIndex(_params.index).burn(_params.recipient);
    }

    
    function burnSwap(BurnSwapParams calldata _params) public override isValidIndex(_params.index) {
        IERC20(_params.index).safeTransferFrom(msg.sender, _params.index, _params.amount);
        IIndex(_params.index).burn(address(this));

        (address[] memory assets, ) = IIndex(_params.index).anatomy();
        address[] memory inactiveAssets = IIndex(_params.index).inactiveAnatomy();

        uint assetsCount = assets.length;
        uint totalAssetsCount = assetsCount + inactiveAssets.length;
        for (uint i; i < totalAssetsCount; ) {
            IERC20 asset = IERC20(i < assetsCount ? assets[i] : inactiveAssets[i - assetsCount]);
            uint balance = asset.balanceOf(address(this));
            if (balance > 0) {
                if (_params.paths[i][0] == _params.paths[i][_params.paths[i].length - 1]) {
                    asset.safeTransfer(_params.recipient, balance);
                } else {
                    require(
                        IAccessControl(registry).hasRole(EXCHANGE_FACTORY_ROLE, _params.swapFactories[i]),
                        "IndexRouter: INVALID_FACTORY"
                    );

                    _swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        address(this),
                        balance,
                        _params.buyAssetMinAmounts[i],
                        _params.paths[i],
                        _params.swapFactories[i],
                        _params.recipient
                    );
                }
            }

            unchecked {
                i = i + 1;
            }
        }
    }

    
    function burnSwapValue(BurnSwapParams calldata _params) public override isValidIndex(_params.index) {
        IERC20(_params.index).safeTransferFrom(msg.sender, _params.index, _params.amount);

        IIndex(_params.index).burn(address(this));

        (address[] memory assets, ) = IIndex(_params.index).anatomy();
        address[] memory inactiveAssets = IIndex(_params.index).inactiveAnatomy();

        uint assetsCount = assets.length;
        uint totalAssetsCount = assetsCount + inactiveAssets.length;
        for (uint i; i < totalAssetsCount; ) {
            uint balance = IERC20(i < assetsCount ? assets[i] : inactiveAssets[i - assetsCount]).balanceOf(
                address(this)
            );
            if (balance > 0) {
                address outputAsset = _params.paths[i][_params.paths[i].length - 1];
                require(outputAsset == WETH, "IndexRouter: OUTPUT");

                if (_params.paths[i][0] == outputAsset) {
                    IWETH(WETH).withdraw(balance);
                    TransferHelper.safeTransferETH(_params.recipient, balance);
                } else {
                    require(
                        IAccessControl(registry).hasRole(EXCHANGE_FACTORY_ROLE, _params.swapFactories[i]),
                        "IndexRouter: INVALID_FACTORY"
                    );

                    _swapExactTokensForETHSupportingFeeOnTransferTokens(
                        balance,
                        _params.buyAssetMinAmounts[i],
                        _params.paths[i],
                        _params.swapFactories[i],
                        _params.recipient
                    );
                }
            }

            unchecked {
                i = i + 1;
            }
        }
    }

    
    
    
    
    
    function _mint(
        MintSwapValueParams memory _params,
        address _inputToken,
        uint _amountInInputToken,
        address _sender
    ) internal {
        (address[] memory _assets, uint8[] memory _weights) = IIndex(_params.index).anatomy();

        uint assetsCount = _assets.length;

        MintDetails memory _details = MintDetails(
            type(uint).max,
            new uint[](assetsCount),
            new uint[](assetsCount),
            IvTokenFactory(IIndex(_params.index).vTokenFactory())
        );
        {
            IPriceOracle priceOracle = IPhuturePriceOracle(IIndexRegistry(registry).priceOracle());
            for (uint i; i < assetsCount; ) {
                if (_weights[i] != 0) {
                    require(_inputToken == _params.paths[i][0], "IndexRouter: INVALID_PATH");

                    address asset = _params.paths[i][_params.paths[i].length - 1];
                    require(asset == _assets[i], "IndexRouter: INVALID_PATH");

                    _details.inputAmountInToken[i] = (_amountInInputToken * _weights[i]) / IndexLibrary.MAX_WEIGHT;

                    uint amountOut;
                    if (asset == _inputToken) {
                        amountOut = _details.inputAmountInToken[i];
                    } else {
                        uint[] memory amountsOut = UniswapV2Library.getAmountsOut(
                            _params.swapFactories[i],
                            _details.inputAmountInToken[i],
                            _params.paths[i]
                        );
                        amountOut = amountsOut[amountsOut.length - 1];
                    }

                    uint amountOutInBase = amountOut.mulDiv(
                        FixedPoint112.Q112 * IndexLibrary.MAX_WEIGHT,
                        priceOracle.refreshedAssetPerBaseInUQ(asset) * _weights[i]
                    );
                    _details.amountsInBase[i] = amountOutInBase;
                    if (amountOutInBase < _details.minAmountInBase) {
                        _details.minAmountInBase = amountOutInBase;
                    }
                }

                unchecked {
                    i = i + 1;
                }
            }
        }

        for (uint i; i < assetsCount; ) {
            if (_weights[i] != 0) {
                address asset = _params.paths[i][_params.paths[i].length - 1];
                uint _amount = (_details.inputAmountInToken[i] * _details.minAmountInBase) / _details.amountsInBase[i];
                if (asset == _inputToken) {
                    IERC20(asset).safeTransferFrom(_sender, _details.vTokenFactory.createdVTokenOf(asset), _amount);
                } else {
                    require(
                        IAccessControl(registry).hasRole(EXCHANGE_FACTORY_ROLE, _params.swapFactories[i]),
                        "IndexRouter: INVALID_FACTORY"
                    );

                    _swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        _sender,
                        _amount,
                        (_params.buyAssetMinAmounts[i] * _details.minAmountInBase) / _details.amountsInBase[i],
                        _params.paths[i],
                        _params.swapFactories[i],
                        _details.vTokenFactory.createdVTokenOf(asset)
                    );
                }
            }

            unchecked {
                i = i + 1;
            }
        }

        IIndex(_params.index).mint(_params.recipient);
    }

    /**
     * @notice Swaps an exact amount of input tokens for as many output tokens as possible,
     * along the route determined by the path. The first element of path is the input token,
     * the last is the output token, and any intermediate elements represent intermediate
     * pairs to trade through (if, for example, a direct pair does not exist).
     */
    
    
    
    
    
    
    function _swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address sender,
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address swapFactory,
        address to
    ) internal {
        if (sender == address(this)) {
            IERC20(path[0]).safeTransfer(UniswapV2Library.pairFor(swapFactory, path[0], path[1]), amountIn);
        } else {
            IERC20(path[0]).safeTransferFrom(sender, UniswapV2Library.pairFor(swapFactory, path[0], path[1]), amountIn);
        }
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, swapFactory, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    /**
     * @notice Swaps an exact amount of tokens for as much ETH as possible, along
     * the route determined by the path. The first element of path is the input token,
     * the last must be WETH, and any intermediate elements represent intermediate pairs
     * to trade through (if, for example, a direct pair does not exist).
     */
    
    
    
    
    
    function _swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address swapFactory,
        address to
    ) internal {
        require(path[path.length - 1] == WETH, "UniswapV2Router: INVALID_PATH");
        IERC20(path[0]).safeTransfer(UniswapV2Library.pairFor(swapFactory, path[0], path[1]), amountIn);
        _swapSupportingFeeOnTransferTokens(path, swapFactory, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    function _swapSupportingFeeOnTransferTokens(
        address[] memory path,
        address swapFactory,
        address _to
    ) internal {
        for (uint i; i < path.length - 1; ) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = UniswapV2Library.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(swapFactory, input, output));
            uint amountInput;
            uint amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1, ) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
                amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(swapFactory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));

            unchecked {
                i = i + 1;
            }
        }
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;



/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// 

pragma solidity 0.8.13;



library BP {
    
    
    uint16 constant DECIMAL_FACTOR = 10_000;
}

// 

pragma solidity 0.8.13;






library IndexLibrary {
    using FullMath for uint;

    
    uint constant INITIAL_QUANTITY = 10000;

    
    uint8 constant MAX_WEIGHT = type(uint8).max;

    
    
    
    
    
    function amountInAsset(
        uint _assetPerBaseInUQ,
        uint8 _weight,
        uint _amountInBase
    ) internal pure returns (uint) {
        require(_assetPerBaseInUQ != 0, "IndexLibrary: ORACLE");

        return ((_amountInBase * _weight) / MAX_WEIGHT).mulDiv(_assetPerBaseInUQ, FixedPoint112.Q112);
    }
}

// 

pragma solidity 0.8.13;






library UniswapV2Library {
    
    
    
    
    
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    
    
    
    
    
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (address pair) {
        pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
    }

    
    
    
    
    
    
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint reserveA, uint reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    
    
    
    
    
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) internal pure returns (uint amountB) {
        require(amountA != 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA != 0 && reserveB != 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
    }

    
    
    
    
    
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountOut) {
        require(amountIn != 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn != 0 && reserveOut != 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    
    
    
    
    
    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountIn) {
        require(amountOut != 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn != 0 && reserveOut != 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn * amountOut * 1000;
        uint denominator = (reserveOut - amountOut) * 997;
        amountIn = numerator / denominator + 1;
    }

    
    
    
    
    
    function getAmountsOut(
        address factory,
        uint amountIn,
        address[] memory path
    ) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; ) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);

            unchecked {
                i = i + 1;
            }
        }
    }

    
    
    
    
    
    function getAmountsIn(
        address factory,
        uint amountOut,
        address[] memory path
    ) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// 

pragma solidity >=0.8.13;






interface IIndex is IIndexLayout, IAnatomyUpdater {
    
    
    function mint(address _recipient) external;

    
    
    function burn(address _recipient) external;

    
    
    
    function anatomy() external view returns (address[] memory _assets, uint8[] memory _weights);

    
    
    function inactiveAnatomy() external view returns (address[] memory);
}

// 

pragma solidity >=0.8.13;



interface IvToken {
    struct AssetData {
        uint maxShares;
        uint amountInAsset;
    }

    event UpdateDeposit(address indexed account, uint depositedAmount);
    event SetVaultController(address vaultController);
    event VTokenTransfer(address indexed from, address indexed to, uint amount);

    
    
    
    function initialize(address _asset, address _registry) external;

    
    
    function setController(address _vaultController) external;

    
    function deposit() external;

    
    function withdraw() external;

    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint _shares
    ) external;

    
    
    
    
    function transferAsset(address _recipient, uint _amount) external;

    
    
    function mint() external returns (uint shares);

    
    
    
    function burn(address _recipient) external returns (uint amount);

    
    
    
    function transfer(address _recipient, uint _amount) external;

    
    function sync() external;

    
    
    
    function mintFor(address _recipient) external returns (uint);

    
    
    
    function burnFor(address _recipient) external returns (uint);

    
    
    function virtualTotalAssetSupply() external view returns (uint);

    
    
    function totalAssetSupply() external view returns (uint);

    
    
    function deposited() external view returns (uint);

    
    
    
    function mintableShares(uint _amount) external view returns (uint);

    
    
    function assetDataOf(address _account, uint _shares) external view returns (AssetData memory);

    
    
    
    function assetBalanceOf(address _account) external view returns (uint);

    
    
    
    function lastAssetBalanceOf(address _account) external view returns (uint);

    
    
    function lastAssetBalance() external view returns (uint);

    
    
    function totalSupply() external view returns (uint);

    
    
    
    function balanceOf(address _account) external view returns (uint);

    
    
    
    
    
    function shareChange(address _account, uint _amountInAsset) external view returns (uint newShares, uint oldShares);

    
    
    function vaultController() external view returns (address);

    
    
    function asset() external view returns (address);

    
    
    function registry() external view returns (address);

    
    
    function currentDepositedPercentageInBP() external view returns (uint);
}

// 

pragma solidity >=0.8.13;



interface IFeePool {
    struct MintBurnInfo {
        address recipient;
        uint share;
    }

    event Mint(address indexed index, address indexed recipient, uint share);
    event Burn(address indexed index, address indexed recipient, uint share);
    event SetMintingFeeInBP(address indexed account, address indexed index, uint16 mintingFeeInBP);
    event SetBurningFeeInBP(address indexed account, address indexed index, uint16 burningFeeInPB);
    event SetAUMScaledPerSecondsRate(address indexed account, address indexed index, uint AUMScaledPerSecondsRate);

    event Withdraw(address indexed index, address indexed recipient, uint amount);

    
    
    function initialize(address _registry) external;

    
    
    
    
    
    
    function initializeIndex(
        address _index,
        uint16 _mintingFeeInBP,
        uint16 _burningFeeInBP,
        uint _AUMScaledPerSecondsRate,
        MintBurnInfo[] calldata _mintInfo
    ) external;

    
    
    
    function mint(address _index, MintBurnInfo calldata _mintInfo) external;

    
    
    
    function burn(address _index, MintBurnInfo calldata _burnInfo) external;

    
    
    
    function mintMultiple(address _index, MintBurnInfo[] calldata _mintInfo) external;

    
    
    
    function burnMultiple(address _index, MintBurnInfo[] calldata _burnInfo) external;

    
    
    
    function setMintingFeeInBP(address _index, uint16 _mintingFeeInBP) external;

    
    
    
    function setBurningFeeInBP(address _index, uint16 _burningFeeInBP) external;

    
    
    
    function setAUMScaledPerSecondsRate(address _index, uint _AUMScaledPerSecondsRate) external;

    
    
    function withdraw(address _index) external;

    
    
    
    function withdrawPlatformFeeOf(address _index, address _recipient) external;

    
    
    function totalSharesOf(address _index) external view returns (uint);

    
    
    function shareOf(address _index, address _account) external view returns (uint);

    
    
    function mintingFeeInBPOf(address _index) external view returns (uint16);

    
    
    function burningFeeInBPOf(address _index) external view returns (uint16);

    
    
    function AUMScaledPerSecondsRateOf(address _index) external view returns (uint);

    
    
    
    function withdrawableAmountOf(address _index, address _account) external view returns (uint);
}

// 

pragma solidity >=0.8.13;



interface IvTokenFactory {
    event VTokenCreated(address vToken, address asset);

    
    
    
    function initialize(address _registry, address _vTokenImpl) external;

    
    
    function upgradeBeaconTo(address _vTokenImpl) external;

    
    
    function createVToken(address _asset) external;

    
    
    function createdVTokenOf(address _asset) external returns (address);

    
    
    function beacon() external view returns (address);

    
    
    
    function vTokenOf(address _asset) external view returns (address);
}

// 

pragma solidity >=0.8.13;





interface IIndexRegistry {
    event SetIndexLogic(address indexed account, address indexLogic);
    event SetMaxComponents(address indexed account, uint maxComponents);
    event UpdateAsset(address indexed asset, uint marketCap);
    event SetOrderer(address indexed account, address orderer);
    event SetFeePool(address indexed account, address feePool);
    event SetPriceOracle(address indexed account, address priceOracle);

    
    
    
    function initialize(address _indexLogic, uint _maxComponents) external;

    
    
    function setMaxComponents(uint _maxComponents) external;

    
    
    function indexLogic() external returns (address);

    
    
    function setIndexLogic(address _indexLogic) external;

    
    
    
    function setRoleAdmin(bytes32 _role, bytes32 _adminRole) external;

    
    
    
    function registerIndex(address _index, IIndexFactory.NameDetails calldata _nameDetails) external;

    
    
    
    function addAsset(address _asset, uint _marketCap) external;

    
    
    function removeAsset(address _asset) external;

    
    
    
    function updateAssetMarketCap(address _asset, uint _marketCap) external;

    
    
    function setPriceOracle(address _priceOracle) external;

    
    
    function setOrderer(address _orderer) external;

    
    
    function setFeePool(address _feePool) external;

    
    
    function maxComponents() external view returns (uint);

    
    
    function marketCapOf(address _asset) external view returns (uint);

    
    
    
    
    function marketCapsOf(address[] calldata _assets)
        external
        view
        returns (uint[] memory _marketCaps, uint _totalMarketCap);

    
    
    function totalMarketCap() external view returns (uint);

    
    
    function priceOracle() external view returns (address);

    
    
    function orderer() external view returns (address);

    
    
    function feePool() external view returns (address);
}

// 

pragma solidity >=0.8.13;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;
}

// 

pragma solidity >=0.8.13;





interface IPhuturePriceOracle is IPriceOracle {
    
    
    
    function initialize(address _registry, address _base) external;

    
    
    
    function setOracleOf(address _asset, address _oracle) external;

    
    
    function removeOracleOf(address _asset) external;

    
    
    
    
    function convertToIndex(uint _baseAmount, uint8 _indexDecimals) external view returns (uint);

    
    
    
    function containsOracleOf(address _asset) external view returns (bool);

    
    
    
    function priceOracleOf(address _asset) external view returns (address);
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
pragma solidity 0.8.13;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            uint256 twos = (~denominator + 1) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    
    
    
    
    
}

// 

pragma solidity 0.8.13;



library FixedPoint112 {
    uint8 internal constant RESOLUTION = 112;
    
    uint256 internal constant Q112 = 0x10000000000000000000000000000;
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// 

pragma solidity >=0.8.13;



interface IIndexFactory {
    struct NameDetails {
        string name;
        string symbol;
    }

    event SetVTokenFactory(address vTokenFactory);
    event SetDefaultMintingFeeInBP(address indexed account, uint16 mintingFeeInBP);
    event SetDefaultBurningFeeInBP(address indexed account, uint16 burningFeeInBP);
    event SetDefaultAUMScaledPerSecondsRate(address indexed account, uint AUMScaledPerSecondsRate);

    
    
    
    function setDefaultMintingFeeInBP(uint16 _mintingFeeInBP) external;

    
    
    
    function setDefaultBurningFeeInBP(uint16 _burningFeeInBP) external;

    
    
    function setReweightingLogic(address _reweightingLogic) external;

    
    /**
        @dev Will be set in FeePool on index creation.
        Effective management fee rate (annual, in percent, after dilution) is calculated by the given formula:
        fee = (rpow(scaledPerSecondRate, numberOfSeconds, 10*27) - 10**27) * totalSupply / 10**27, where:

        totalSupply - total index supply;
        numberOfSeconds - delta time for calculation period;
        scaledPerSecondRate - scaled rate, calculated off chain by the given formula:

        scaledPerSecondRate = ((1 + k) ** (1 / 365 days)) * AUMCalculationLibrary.RATE_SCALE_BASE, where:
        k = (aumFeeInBP / BP) / (1 - aumFeeInBP / BP);

        Note: rpow and RATE_SCALE_BASE are provided by AUMCalculationLibrary
        More info: https://docs.enzyme.finance/fee-formulas/management-fee

        After value calculated off chain, scaledPerSecondRate is set to setDefaultAUMScaledPerSecondsRate
    */
    
    function setDefaultAUMScaledPerSecondsRate(uint _AUMScaledPerSecondsRate) external;

    
    
    function withdrawToFeePool(address _index) external;

    
    
    function registry() external view returns (address);

    
    
    function vTokenFactory() external view returns (address);

    
    
    function defaultMintingFeeInBP() external view returns (uint16);

    
    
    function defaultBurningFeeInBP() external view returns (uint16);

    
    ///         See setDefaultAUMScaledPerSecondsRate method description for more details.
    
    function defaultAUMScaledPerSecondsRate() external view returns (uint);

    
    
    function reweightingLogic() external view returns (address);
}
