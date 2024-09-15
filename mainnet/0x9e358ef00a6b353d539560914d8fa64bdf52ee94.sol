// SPDX-License-Identifier: MIT
pragma abicoder v2;

// 

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// 

pragma solidity ^0.7.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// 

pragma solidity ^0.7.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// 
pragma solidity >=0.7.5;





interface IERC721Permit is IERC721 {
    
    
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    
    
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    
    
    
    
    
    
    
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}

// 
pragma solidity >=0.5.0;



interface IPeripheryImmutableState {
    
    function factory() external view returns (address);

    
    function WETH9() external view returns (address);
}

// 
pragma solidity >=0.7.5;



interface IPeripheryPayments {
    
    
    
    
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    
    
    /// that use ether for the input amount
    function refundETH() external payable;

    
    
    
    
    
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}

// 
pragma solidity >=0.7.5;




/// require the pool to exist.
interface IPoolInitializer {
    
    
    
    
    
    
    
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}

// 
pragma solidity >=0.7.6;

interface IUniswapFeeCollector {
    /**
     * @notice Emitted when fees are collected from the LP.
     * @param  tokenId Uniswap Non-Fungible Position Manager token ID representing LP position.
     * @param  amount0 Amount of tokens collected for first token in pool.
     * @param  amount1 Amount of tokens collected for second token in pool.
     */
    event CollectFees(uint256 tokenId, uint256 amount0, uint256 amount1);

    /**
     * @notice Emitted when liquidity is increased.
     * @param  tokenId          Uniswap Non-Fungible Position Manager token ID representing LP position.
     * @param  baseTokenBalance Balance of base token used for the liquidity increase.
     */
    event IncreaseLiquidity(uint256 tokenId, uint256 baseTokenBalance);

    /**
     * @notice Emitted when the owner of the contract is changed.
     * @param  previousOwner Previous owner the contract.
     * @param  newOwner      New owner of the contract.
     */
    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
     * @notice Emitted when the ERC721 representing the position is withdrawn from the contract.
     * @param  tokenId Uniswap Non-Fungible Position Manager token ID representing LP position.
     */
    event PositionWithdrawn(uint256 tokenId);

    /**
     * @notice Emitted when rewardCollectionAddress is changed.
     * @param  rewardCollectionAddress New rewardCollectionAddress.
     */
    event RewardCollectionAddressChanged(address rewardCollectionAddress);

    /**
     * @notice Emitted when runner address is changed.
     * @param  runnerAddress New runnerAddress.
     */
    event RunnerAddressChanged(address runnerAddress);

    /**
     * @notice Emitted when rewards are sent to the rewardCollectionAddress.
     * @param  rewardCollectionAddress Address to which tokens have been sent.
     * @param  rewardTokenAmount       Amount of tokens sent to the collection address.
     */
    event SendRewards(address rewardCollectionAddress, uint256 rewardTokenAmount);

    /**
     * @notice Collects the fees associated with provided liquidity.
     * @dev    The contract must hold the ERC721 token before it can collect fees.
     * @param  tokenId_ Uniswap Non-Fungible Position Manager token ID representing LP position.
     */
    function collectFees(uint256 tokenId_) external returns (uint256 amount0_, uint256 amount1_);

    /**
     * @notice Collect the unclaimed fees in the position and increase liquidity of the position with the calldata received from the runner script.
     * @dev    The contract must hold the ERC721 token before it can increase liquidity
     * @param  tokenId_ Uniswap Non-Fungible Position Manager token ID representing LP position.
     * @param  data_    Calldata required to execute swap. Generated by Uniswap SDK.
     */
    function collectFeesAndIncreaseLiquidity(uint256 tokenId_, bytes calldata data_) external;

    /**
     * @notice Increase liquidity of the position with the calldata received from the runner script.
     * @dev    The contract must hold the erc721 token before it can increase liquidity
     * @param  tokenId_ Uniswap Non-Fungible Position Manager token ID representing LP position.
     * @param  data_    Calldata required to execute swap. Generated by Uniswap SDK.
     */
    function increaseLiquidity(uint256 tokenId_, bytes calldata data_) external;

    /**
     * @notice Activated when an ERC721 is received through safeTransferFrom.
     */
    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4);

    /**
     * @notice Change the reward collection address that rewards are sent to. Owner protected.
     * @param  rewardCollectionAddress_ New rewardCollectionAddress.
     */
    function setRewardCollectionAddress(address rewardCollectionAddress_) external;

    /**
     * @notice Change the runner address that can collect fees and increase liquidity. Owner protected.
     * @param  runnerAddress_ New runnerAddress.
     */
    function setRunnerAddress(address runnerAddress_) external;

    /**
     * @notice Change the owner of the contract. Owner protected.
     * @param  owner_ New owner of the contract.
     */
    function transferOwnership(address owner_) external;

    /**
     * @notice Withdraw a Uniswap ERC721 LP position held by the contract to the owner address. Owner protected.
     * @param  tokenId_ Uniswap Non-Fungible Position Manager token ID representing LP position.
     */
    function withdrawPosition(uint256 tokenId_) external;
}
// 

pragma solidity ^0.7.0;

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

// 
pragma solidity >=0.7.5;













/// and authorized.
interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{
    
    
    
    
    
    
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    
    
    
    
    
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    
    
    
    
    
    
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    
    
    /// a method does not exist, i.e. the pool is assumed to be initialized.
    
    
    
    
    
    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    
    
    /// amount0Desired The desired amount of token0 to be spent,
    /// amount1Desired The desired amount of token1 to be spent,
    /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// deadline The time by which the transaction must be included to effect the change
    
    
    
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    
    
    /// amount The amount by which liquidity will be decreased,
    /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// deadline The time by which the transaction must be included to effect the change
    
    
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    
    
    /// recipient The account that should receive the tokens,
    /// amount0Max The maximum amount of token0 to collect,
    /// amount1Max The maximum amount of token1 to collect
    
    
    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    
    /// must be collected first.
    
    function burn(uint256 tokenId) external payable;
}

// 
pragma solidity >=0.5.0;


library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}

// 
pragma solidity >=0.7.6;






contract UniswapFeeCollector is IUniswapFeeCollector {
    IERC20 public immutable baseToken;
    IERC20 public immutable rewardToken;
    INonfungiblePositionManager public immutable positionManager;

    address public immutable uniswapSwapRouterAddress;
    address public owner;
    address public runner;
    address public rewardCollectionAddress;
    uint256 private locked = 1; // Used in reentrancy check.

    constructor(
        address runnerAddress_,
        address rewardCollectionAddress_,
        address rewardTokenAddress_,
        address baseTokenAddress_,
        address uniswapSwapRouterAddress_,
        address positionManagerAddress_
    ) {
        rewardToken = IERC20(rewardTokenAddress_);
        baseToken = IERC20(baseTokenAddress_);
        positionManager = INonfungiblePositionManager(positionManagerAddress_);

        runner = runnerAddress_;
        rewardCollectionAddress = rewardCollectionAddress_;
        uniswapSwapRouterAddress = uniswapSwapRouterAddress_;

        owner = msg.sender;
    }

    /*░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
    ░░░░                             Modifiers                             ░░░░
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░*/

    modifier nonReentrant() {
        require(locked == 1, "UFC:LOCKED");

        locked = 2;

        _;

        locked = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "UFC:CALLER_NOT_OWNER");
        _;
    }

    modifier onlyRunner() {
        require(msg.sender == runner, "UFC:CALLER_NOT_RUNNER");
        _;
    }

    /*░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
    ░░░░                         Public Functions                          ░░░░
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░*/

    /**
     * @inheritdoc IUniswapFeeCollector
     */
    function onERC721Received(address, address, uint256, bytes calldata) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @inheritdoc IUniswapFeeCollector
     */
    function collectFees(uint256 tokenId_)
        external
        override
        nonReentrant
        returns (uint256 amount0_, uint256 amount1_)
    {
        (amount0_, amount1_) = _collectFees(tokenId_);
        _sendRewards();
    }

    /**
     * @inheritdoc IUniswapFeeCollector
     */
    function collectFeesAndIncreaseLiquidity(uint256 tokenId_, bytes calldata data_)
        external
        override
        onlyRunner
        nonReentrant
    {
        _collectFees(tokenId_);
        _sendRewards();
        _increaseLiquidity(tokenId_, data_);
    }

    /**
     * @inheritdoc IUniswapFeeCollector
     */
    function increaseLiquidity(uint256 tokenId_, bytes calldata data_) external override onlyRunner nonReentrant {
        _increaseLiquidity(tokenId_, data_);
    }

    /**
     * @inheritdoc IUniswapFeeCollector
     */
    function withdrawPosition(uint256 tokenId_) external override onlyOwner nonReentrant {
        positionManager.transferFrom(address(this), owner, tokenId_);

        emit PositionWithdrawn(tokenId_);
    }

    /**
     * @inheritdoc IUniswapFeeCollector
     */
    function setRewardCollectionAddress(address rewardCollectionAddress_) external override onlyOwner {
        rewardCollectionAddress = rewardCollectionAddress_;

        emit RewardCollectionAddressChanged(rewardCollectionAddress);
    }

    /**
     * @inheritdoc IUniswapFeeCollector
     */
    function setRunnerAddress(address runnerAddress_) external override onlyOwner {
        runner = runnerAddress_;

        emit RunnerAddressChanged(runner);
    }

    /**
     * @inheritdoc IUniswapFeeCollector
     */
    function transferOwnership(address owner_) external override onlyOwner {
        require(owner_ != address(0), "UFC:ZERO_ADDRESS_CANNOT_BE_OWNER");
        _transferOwnership(owner_);
    }

    /*░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
    ░░░░                        Internal Functions                         ░░░░
    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░*/

    /**
     * @notice Collects accrued fees from position, leaving them on the contract.
     * @param  tokenId_ Uniswap Non-Fungible Position Manager token ID representing LP position.
     * @return amount0_ Amount of tokens collected for first token in pool.
     * @return amount1_ Amount of tokens collected for second token in pool.
     */
    function _collectFees(uint256 tokenId_) internal returns (uint256 amount0_, uint256 amount1_) {
        INonfungiblePositionManager.CollectParams memory params_ = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId_,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0_, amount1_) = positionManager.collect(params_);

        emit CollectFees(tokenId_, amount0_, amount1_);
    }

    /**
     * @notice Increses the liquidity of the position using the fees on the contract.
     * @param  tokenId_ Uniswap Non-Fungible Position Manager token ID representing LP position.
     * @param  data_ Calldata required to perform the swap & increase, generated by the Uniswap SDK.
     */
    function _increaseLiquidity(uint256 tokenId_, bytes calldata data_) internal {
        uint256 baseTokenBalance_ = baseToken.balanceOf(address(this));

        baseToken.approve(uniswapSwapRouterAddress, baseTokenBalance_);
        (bool success_,) = uniswapSwapRouterAddress.call{value: 0}(data_);
        baseToken.approve(uniswapSwapRouterAddress, 0);

        require(success_ == true, "UFC:UNISWAP_CALL_FAILED");

        emit IncreaseLiquidity(tokenId_, baseTokenBalance_ - baseToken.balanceOf(address(this)));
    }

    /**
     * @notice Transfers all reward tokens held by the contract to the rewardCollectionAddress.
     */
    function _sendRewards() internal {
        uint256 rewardTokenBalance_ = rewardToken.balanceOf(address(this));
        rewardToken.transfer(rewardCollectionAddress, rewardTokenBalance_);

        emit SendRewards(rewardCollectionAddress, rewardTokenBalance_);
    }

    /**
     * @notice Transfers ownership of the contract to a new account.
     * @param  owner_ New owner of the contract.
     */
    function _transferOwnership(address owner_) internal {
        address oldOwner_ = owner;
        owner = owner_;

        emit OwnershipTransferred(oldOwner_, owner_);
    }
}
