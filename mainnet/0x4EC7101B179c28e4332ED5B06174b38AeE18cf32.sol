// SPDX-License-Identifier: Unlicense


// 
pragma solidity >=0.8.4;




/// account (an owner) that can be granted exclusive access to specific functions.
///
/// By default, the owner account will be the one that deploys the contract. This can later be
/// changed with {transfer}.
///
/// This module is used through inheritance. It will make available the modifier `onlyOwner`,
/// which can be applied to your functions to restrict their use to the owner.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol
interface IOwnable {
    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function _renounceOwnership() external;

    
    /// called by the current owner.
    
    function _transferOwnership(address newOwner) external;

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);
}

// 
pragma solidity >=0.8.4;




///
/// We have followed general OpenZeppelin guidelines: functions revert instead of returning
/// `false` on failure. This behavior is nonetheless conventional and does not conflict with
/// the with the expectations of Erc20 applications.
///
/// Additionally, an {Approval} event is emitted on calls to {transferFrom}. This allows
/// applications to reconstruct the allowance for all accounts just by listening to said
/// events. Other implementations of the Erc may not emit these events, as it isn't
/// required by the specification.
///
/// Finally, the non-standard {decreaseAllowance} and {increaseAllowance} functions have been
/// added to mitigate the well-known issues around setting allowances.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol
interface IErc20 {
    /// EVENTS ///

    
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// CONSTANT FUNCTIONS ///

    
    /// on behalf of `owner` through {transferFrom}. This is zero by default.
    ///
    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);

    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function totalSupply() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// IMPORTANT: Beware that changing an allowance with this method brings the risk that someone may
    /// use both the old and the new allowance by unfortunate transaction ordering. One possible solution
    /// to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired
    /// value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    ///
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    ///
    
    ///
    /// This is an alternative to {approve} that can be used as a mitigation for problems described
    /// in {Erc20Interface-approve}.
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    /// - `spender` must have allowance for the caller of at least `subtractedAmount`.
    function decreaseAllowance(address spender, uint256 subtractedAmount) external returns (bool);

    
    ///
    
    ///
    /// This is an alternative to {approve} that can be used as a mitigation for the problems described above.
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    function increaseAllowance(address spender, uint256 addedAmount) external returns (bool);

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - `recipient` cannot be the zero address.
    /// - The caller must have a balance of at least `amount`.
    ///
    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    /// `is then deducted from the caller's allowance.
    ///
    
    /// not required by the Erc. See the note at the beginning of {Erc20}.
    ///
    /// Requirements:
    ///
    /// - `sender` and `recipient` cannot be the zero address.
    /// - `sender` must have a balance of at least `amount`.
    /// - The caller must have approed `sender` to spent at least `amount` tokens.
    ///
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// 
pragma solidity >=0.8.4;




error Ownable__NotOwner(address owner, address caller);


error Ownable__OwnerZeroAddress();



contract Ownable is IOwnable {
    /// PUBLIC STORAGE ///

    
    address public override owner;

    /// MODIFIERS ///

    
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Ownable__NotOwner(owner, msg.sender);
        }
        _;
    }

    /// CONSTRUCTOR ///

    
    constructor() {
        address msgSender = msg.sender;
        owner = msgSender;
        emit TransferOwnership(address(0), msgSender);
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function _renounceOwnership() public virtual override onlyOwner {
        emit TransferOwnership(owner, address(0));
        owner = address(0);
    }

    
    function _transferOwnership(address newOwner) public virtual override onlyOwner {
        if (newOwner == address(0)) {
            revert Ownable__OwnerZeroAddress();
        }
        emit TransferOwnership(owner, newOwner);
        owner = newOwner;
    }
}

// 
pragma solidity >=0.8.4;




error Erc20__ApproveOwnerZeroAddress();


error Erc20__ApproveSpenderZeroAddress();


error Erc20__BurnUnderflow(uint256 accountBalance, uint256 burnAmount);


error Erc20__BurnZeroAddress();


error Erc20__InsufficientAllowance(uint256 allowance, uint256 amount);


error Erc20__InsufficientBalance(uint256 senderBalance, uint256 amount);


error Erc20__MintZeroAddress();


error Erc20__TransferSenderZeroAddress();


error Erc20__TransferRecipientZeroAddress();



contract Erc20 is IErc20 {
    /// PUBLIC STORAGE ///

    
    string public override name;

    
    string public override symbol;

    
    uint8 public immutable override decimals;

    
    uint256 public override totalSupply;

    /// INTERNAL STORAGE ///

    
    mapping(address => uint256) internal balances;

    
    mapping(address => mapping(address => uint256)) internal allowances;

    /// CONSTRUCTOR ///

    
    
    
    
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return balances[account];
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        approveInternal(msg.sender, spender, amount);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedAmount) public virtual override returns (bool) {
        uint256 newAllowance = allowances[msg.sender][spender] - subtractedAmount;
        approveInternal(msg.sender, spender, newAllowance);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedAmount) public virtual override returns (bool) {
        uint256 newAllowance = allowances[msg.sender][spender] + addedAmount;
        approveInternal(msg.sender, spender, newAllowance);
        return true;
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        transferInternal(msg.sender, recipient, amount);
        return true;
    }

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        transferInternal(sender, recipient, amount);

        uint256 currentAllowance = allowances[sender][msg.sender];
        if (currentAllowance < amount) {
            revert Erc20__InsufficientAllowance(currentAllowance, amount);
        }
        unchecked {
            approveInternal(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    /// INTERNAL NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - `owner` cannot be the zero address.
    /// - `spender` cannot be the zero address.
    function approveInternal(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        if (owner == address(0)) {
            revert Erc20__ApproveOwnerZeroAddress();
        }
        if (spender == address(0)) {
            revert Erc20__ApproveSpenderZeroAddress();
        }

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - `holder` must have at least `amount` tokens.
    function burnInternal(address holder, uint256 burnAmount) internal {
        if (holder == address(0)) {
            revert Erc20__BurnZeroAddress();
        }

        // Burn the tokens.
        balances[holder] -= burnAmount;

        // Reduce the total supply.
        totalSupply -= burnAmount;

        emit Transfer(holder, address(0), burnAmount);
    }

    
    /// total supply.
    ///
    
    ///
    /// Requirements:
    ///
    /// - The beneficiary's balance and the total supply cannot overflow.
    function mintInternal(address beneficiary, uint256 mintAmount) internal {
        if (beneficiary == address(0)) {
            revert Erc20__MintZeroAddress();
        }

        /// Mint the new tokens.
        balances[beneficiary] += mintAmount;

        /// Increase the total supply.
        totalSupply += mintAmount;

        emit Transfer(address(0), beneficiary, mintAmount);
    }

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - `sender` cannot be the zero address.
    /// - `recipient` cannot be the zero address.
    /// - `sender` must have a balance of at least `amount`.
    function transferInternal(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        if (sender == address(0)) {
            revert Erc20__TransferSenderZeroAddress();
        }
        if (recipient == address(0)) {
            revert Erc20__TransferRecipientZeroAddress();
        }

        uint256 senderBalance = balances[sender];
        if (senderBalance < amount) {
            revert Erc20__InsufficientBalance(senderBalance, amount);
        }
        unchecked {
            balances[sender] = senderBalance - amount;
        }

        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
}

// 
// solhint-disable func-name-mixedcase
pragma solidity >=0.8.4;






/// transactions by setting the allowance with a signature using the `permit` method, and then spend
/// them via `transferFrom`.

interface IErc20Permit is IErc20 {
    /// NON-CONSTANT FUNCTIONS ///

    
    /// signed approval.
    ///
    
    ///
    /// IMPORTANT: The same issues Erc20 `approve` has related to transaction
    /// ordering also apply here.
    ///
    /// Requirements:
    ///
    /// - `owner` cannot be the zero address.
    /// - `spender` cannot be the zero address.
    /// - `deadline` must be a timestamp in the future.
    /// - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner` over the Eip712-formatted
    /// function arguments.
    /// - The signature must use `owner`'s current nonce.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /// CONSTANT FUNCTIONS ///

    
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    
    function nonces(address account) external view returns (uint256);

    
    function PERMIT_TYPEHASH() external view returns (bytes32);

    
    function version() external view returns (string memory);
}

// 
// solhint-disable var-name-mixedcase
pragma solidity >=0.8.4;







/// (accidentally, or not) to the contract.
interface IErc20Recover is IOwnable {
    /// EVENTS ///

    
    
    
    
    event Recover(address indexed owner, IErc20 token, uint256 recoverAmount);

    
    
    
    event SetNonRecoverableTokens(address indexed owner, IErc20[] nonRecoverableTokens);

    /// NON-CONSTANT FUNCTIONS ///

    
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The contract must be initialized.
    /// - The amount to recover cannot be zero.
    /// - The token to recover cannot be among the non-recoverable tokens.
    ///
    
    
    function _recover(IErc20 token, uint256 recoverAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The contract cannot be already initialized.
    ///
    
    function _setNonRecoverableTokens(IErc20[] calldata tokens) external;

    /// CONSTANT FUNCTIONS ///

    
    function nonRecoverableTokens(uint256 index) external view returns (IErc20);
}

// 
// solhint-disable var-name-mixedcase
pragma solidity >=0.8.4;





error Erc20Permit__InvalidSignature(uint8 v, bytes32 r, bytes32 s);


error Erc20Permit__OwnerZeroAddress();


error Erc20Permit__PermitExpired(uint256 deadline);


error Erc20Permit__RecoveredOwnerZeroAddress();


error Erc20Permit__SpenderZeroAddress();



contract Erc20Permit is
    IErc20Permit, // one dependency
    Erc20 // one dependency
{
    /// PUBLIC STORAGE ///

    
    bytes32 public immutable override DOMAIN_SEPARATOR;

    
    bytes32 public constant override PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    
    mapping(address => uint256) public override nonces;

    
    string public constant override version = "1";

    /// CONSTRUCTOR ///

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) Erc20(_name, _symbol, _decimals) {
        uint256 chainId;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                address(this)
            )
        );
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        if (owner == address(0)) {
            revert Erc20Permit__OwnerZeroAddress();
        }
        if (spender == address(0)) {
            revert Erc20Permit__SpenderZeroAddress();
        }
        if (deadline < block.timestamp) {
            revert Erc20Permit__PermitExpired(deadline);
        }

        // It's safe to use unchecked here because the nonce cannot realistically overflow, ever.
        bytes32 hashStruct;
        unchecked {
            hashStruct = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline));
        }
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct));
        address recoveredOwner = ecrecover(digest, v, r, s);

        if (recoveredOwner == address(0)) {
            revert Erc20Permit__RecoveredOwnerZeroAddress();
        }
        if (recoveredOwner != owner) {
            revert Erc20Permit__InvalidSignature(v, r, s);
        }

        approveInternal(owner, spender, value);
    }
}

// 
pragma solidity >=0.8.4;







error Initialized();


error NotInitialized();


error NonRecoverableToken(address token);


error RecoverZero();



abstract contract Erc20Recover is
    Ownable, // one dependency
    IErc20Recover // two dependencies
{
    using SafeErc20 for IErc20;

    /// PUBLIC STORAGE ///

    
    IErc20[] public override nonRecoverableTokens;

    
    bool internal isRecoverInitialized;

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function _setNonRecoverableTokens(IErc20[] memory tokens) public override onlyOwner {
        // Checks
        if (isRecoverInitialized) {
            revert Initialized();
        }

        // Iterate over the token list, sanity check each and update the mapping.
        uint256 length = tokens.length;
        for (uint256 i = 0; i < length; i += 1) {
            tokens[i].symbol();
            nonRecoverableTokens.push(tokens[i]);
        }

        // Effects: prevent this function from ever being called again.
        isRecoverInitialized = true;

        emit SetNonRecoverableTokens(owner, tokens);
    }

    
    function _recover(IErc20 token, uint256 recoverAmount) public override onlyOwner {
        // Checks
        if (!isRecoverInitialized) {
            revert NotInitialized();
        }

        if (recoverAmount == 0) {
            revert RecoverZero();
        }

        bytes32 tokenSymbolHash = keccak256(bytes(token.symbol()));
        uint256 length = nonRecoverableTokens.length;

        // We iterate over the non-recoverable token array and check that:
        //
        //   1. The addresses of the tokens are not the same.
        //   2. The symbols of the tokens are not the same.
        //
        // It is true that the second check may lead to a false positive, but there is no better way
        // to fend off against proxied tokens.
        for (uint256 i = 0; i < length; i += 1) {
            if (
                address(token) == address(nonRecoverableTokens[i]) ||
                tokenSymbolHash == keccak256(bytes(nonRecoverableTokens[i].symbol()))
            ) {
                revert NonRecoverableToken(address(token));
            }
        }

        // Interactions
        token.safeTransfer(owner, recoverAmount);

        emit Recover(owner, token, recoverAmount);
    }
}

// 
pragma solidity >=0.8.4;












interface IHToken is
    IOwnable, // no dependency
    IErc20Permit, // one dependency
    IErc20Recover // one dependency
{
    /// CUSTOM ERRORS ///

    
    error HToken__BondMatured(uint256 now, uint256 maturity);

    
    error HToken__BondNotMatured(uint256 now, uint256 maturity);

    
    error HToken__BurnNotAuthorized(address caller);

    
    error HToken__DepositUnderlyingNotAllowed();

    
    error HToken__DepositUnderlyingZero();

    
    error HToken__MaturityPassed(uint256 now, uint256 maturity);

    
    error HToken__MintNotAuthorized(address caller);

    
    error HToken__RedeemInsufficientLiquidity(uint256 underlyingAmount, uint256 totalUnderlyingReserve);

    
    error HToken__RedeemZero();

    
    error HToken__UnderlyingDecimalsOverflow(uint256 decimals);

    
    error HToken__UnderlyingDecimalsZero();

    
    error HToken__WithdrawUnderlyingUnderflow(address depositor, uint256 availableAmount, uint256 underlyingAmount);

    
    error HToken__WithdrawUnderlyingZero();

    /// EVENTS ///

    
    
    
    event Burn(address indexed holder, uint256 burnAmount);

    
    
    
    
    event DepositUnderlying(address indexed depositor, uint256 depositUnderlyingAmount, uint256 hTokenAmount);

    
    
    
    event Mint(address indexed beneficiary, uint256 mintAmount);

    
    
    
    
    event Redeem(address indexed account, uint256 underlyingAmount, uint256 hTokenAmount);

    
    
    
    
    event SetBalanceSheet(address indexed owner, IBalanceSheetV2 oldBalanceSheet, IBalanceSheetV2 newBalanceSheet);

    
    
    
    
    event WithdrawUnderlying(address indexed depositor, uint256 underlyingAmount, uint256 hTokenAmount);

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function balanceSheet() external view returns (IBalanceSheetV2);

    
    function getDepositorBalance(address depositor) external view returns (uint256 amount);

    
    function fintroller() external view returns (IFintroller);

    
    
    function isMatured() external view returns (bool);

    
    function maturity() external view returns (uint256);

    
    function totalUnderlyingReserve() external view returns (uint256);

    
    function underlying() external view returns (IErc20);

    
    function underlyingPrecisionScalar() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    /// - Can only be called by the BalanceSheet contract.
    ///
    
    
    function burn(address holder, uint256 burnAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The underlying amount to deposit cannot be zero.
    /// - The caller must have allowed this contract to spend `underlyingAmount` tokens.
    ///
    
    function depositUnderlying(uint256 underlyingAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - Can only be called by the BalanceSheet contract.
    ///
    
    
    function mint(address beneficiary, uint256 mintAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - Can only be called after maturation.
    /// - The amount of underlying to redeem cannot be zero.
    /// - There must be enough liquidity in the contract.
    ///
    
    function redeem(uint256 underlyingAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function _setBalanceSheet(IBalanceSheetV2 newBalanceSheet) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The underlying amount to withdraw cannot be zero.
    /// - Can only be called before maturation.
    ///
    
    function withdrawUnderlying(uint256 underlyingAmount) external;
}

// 
pragma solidity >=0.8.4;



interface IOwnableUpgradeable {
    /// CUSTOM ERRORS ///

    
    error OwnableUpgradeable__NotOwner(address owner, address caller);

    
    error OwnableUpgradeable__OwnerZeroAddress();

    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function _renounceOwnership() external;

    
    /// called by the current owner.
    
    function _transferOwnership(address newOwner) external;
}
// 
pragma solidity ^0.8.4;













contract HToken is
    Ownable, // one dependency
    Erc20, // one dependency
    Erc20Permit, // four dependencies
    IHToken, // five dependencies
    Erc20Recover // five dependencies
{
    using SafeErc20 for IErc20;

    /// PUBLIC STORAGE ///

    
    IBalanceSheetV2 public override balanceSheet;

    
    IFintroller public override fintroller;

    
    uint256 public override maturity;

    
    uint256 public override totalUnderlyingReserve;

    
    IErc20 public override underlying;

    
    uint256 public override underlyingPrecisionScalar;

    /// INTERNAL STORAGE ///

    
    mapping(address => uint256) internal depositorBalances;

    /// CONSTRUCTOR ///

    
    
    
    
    
    
    
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maturity_,
        IBalanceSheetV2 balanceSheet_,
        IFintroller fintroller_,
        IErc20 underlying_
    ) Erc20Permit(name_, symbol_, 18) Ownable() {
        // Set the maturity.
        if (maturity_ <= block.timestamp) {
            revert HToken__MaturityPassed(block.timestamp, maturity_);
        }
        maturity = maturity_;

        // Set the BalanceSheet contract.
        balanceSheet = balanceSheet_;

        // Set the Fintroller contract.
        fintroller = fintroller_;

        // Set the underlying contract and calculate the precision scalar.
        uint256 underlyingDecimals = underlying_.decimals();
        if (underlyingDecimals == 0) {
            revert HToken__UnderlyingDecimalsZero();
        }
        if (underlyingDecimals > 18) {
            revert HToken__UnderlyingDecimalsOverflow(underlyingDecimals);
        }
        underlyingPrecisionScalar = 10**(18 - underlyingDecimals);
        underlying = underlying_;

        // Set the list of non-recoverable tokens.
        nonRecoverableTokens.push(underlying);
        isRecoverInitialized = true;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    function getDepositorBalance(address depositor) external view override returns (uint256 amount) {
        return depositorBalances[depositor];
    }

    
    function isMatured() public view override returns (bool) {
        return block.timestamp >= maturity;
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function burn(address holder, uint256 burnAmount) external override {
        // Checks: the caller is the BalanceSheet.
        if (msg.sender != address(balanceSheet)) {
            revert HToken__BurnNotAuthorized(msg.sender);
        }

        // Effects: burns the hTokens.
        burnInternal(holder, burnAmount);

        // Emit a Burn and a Transfer event.
        emit Burn(holder, burnAmount);
    }

    
    function depositUnderlying(uint256 underlyingAmount) external override {
        // Checks: the Fintroller allows this action to be performed.
        if (!fintroller.getDepositUnderlyingAllowed(this)) {
            revert HToken__DepositUnderlyingNotAllowed();
        }

        // Checks: the zero edge case.
        if (underlyingAmount == 0) {
            revert HToken__DepositUnderlyingZero();
        }

        // Effects: update storage.
        totalUnderlyingReserve += underlyingAmount;

        // Effects: update the balance of the depositor.
        depositorBalances[msg.sender] += underlyingAmount;

        // Normalize the underlying amount to 18 decimals.
        uint256 hTokenAmount = normalize(underlyingAmount);

        // Effects: mint the hTokens.
        mintInternal(msg.sender, hTokenAmount);

        // Interactions: perform the Erc20 transfer.
        underlying.safeTransferFrom(msg.sender, address(this), underlyingAmount);

        emit DepositUnderlying(msg.sender, underlyingAmount, hTokenAmount);
    }

    
    function mint(address beneficiary, uint256 mintAmount) external override {
        // Checks: the caller is the BalanceSheet.
        if (msg.sender != address(balanceSheet)) {
            revert HToken__MintNotAuthorized(msg.sender);
        }

        // Effects: print the new hTokens into existence.
        mintInternal(beneficiary, mintAmount);

        // Emit a Mint event.
        emit Mint(beneficiary, mintAmount);
    }

    
    function redeem(uint256 underlyingAmount) external override {
        // Checks: before maturation.
        if (!isMatured()) {
            revert HToken__BondNotMatured(block.timestamp, maturity);
        }

        // Checks: the zero edge case.
        if (underlyingAmount == 0) {
            revert HToken__RedeemZero();
        }

        // Checks: there is enough liquidity.
        if (underlyingAmount > totalUnderlyingReserve) {
            revert HToken__RedeemInsufficientLiquidity(underlyingAmount, totalUnderlyingReserve);
        }

        // Effects: decrease the reserves of underlying.
        totalUnderlyingReserve -= underlyingAmount;

        // Normalize the underlying amount to 18 decimals.
        uint256 hTokenAmount = normalize(underlyingAmount);

        // Effects: burn the hTokens.
        burnInternal(msg.sender, hTokenAmount);

        // Interactions: perform the Erc20 transfer.
        underlying.safeTransfer(msg.sender, underlyingAmount);

        emit Redeem(msg.sender, underlyingAmount, hTokenAmount);
    }

    
    function withdrawUnderlying(uint256 underlyingAmount) external override {
        // Checks: after maturation, depositors should call the `redeem` function instead.
        if (isMatured()) {
            revert HToken__BondMatured(block.timestamp, maturity);
        }

        // Checks: the zero edge case.
        if (underlyingAmount == 0) {
            revert HToken__WithdrawUnderlyingZero();
        }

        // Checks: the depositor has enough underlying.
        uint256 availableAmount = depositorBalances[msg.sender];
        if (availableAmount < underlyingAmount) {
            revert HToken__WithdrawUnderlyingUnderflow(msg.sender, availableAmount, underlyingAmount);
        }

        // Effects: update storage.
        totalUnderlyingReserve -= underlyingAmount;

        // Effects: update the balance of the depositor.
        depositorBalances[msg.sender] -= underlyingAmount;

        // Normalize the underlying amount to 18 decimals.
        uint256 hTokenAmount = normalize(underlyingAmount);

        // Effects: burn the hTokens.
        burnInternal(msg.sender, hTokenAmount);

        // Interactions: perform the Erc20 transfer.
        underlying.safeTransfer(msg.sender, underlyingAmount);

        emit WithdrawUnderlying(msg.sender, underlyingAmount, hTokenAmount);
    }

    
    function _setBalanceSheet(IBalanceSheetV2 newBalanceSheet) external override onlyOwner {
        // Effects: update storage.
        IBalanceSheetV2 oldBalanceSheet = balanceSheet;
        balanceSheet = newBalanceSheet;

        emit SetBalanceSheet(owner, oldBalanceSheet, newBalanceSheet);
    }

    /// INTERNAL CONSTANT FUNCTIONS ///

    
    
    
    function normalize(uint256 underlyingAmount) internal view returns (uint256 normalizedUnderlyingAmount) {
        normalizedUnderlyingAmount = underlyingPrecisionScalar != 1
            ? underlyingAmount * underlyingPrecisionScalar
            : underlyingAmount;
    }
}

// 
pragma solidity >=0.8.4;





error SafeErc20__CallToNonContract(address target);


error SafeErc20__NoReturnData();




/// returns false). Tokens that return no value (and instead revert or throw
/// on failure) are also supported, non-reverting calls are assumed to be successful.
///
/// To use this library you can add a `using SafeErc20 for IErc20;` statement to your contract,
/// which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Address.sol
library SafeErc20 {
    using Address for address;

    /// INTERNAL FUNCTIONS ///

    function safeTransfer(
        IErc20 token,
        address to,
        uint256 amount
    ) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, amount));
    }

    function safeTransferFrom(
        IErc20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, amount));
    }

    /// PRIVATE FUNCTIONS ///

    
    /// on the return value: the return value is optional (but if data is returned, it cannot be false).
    
    
    function callOptionalReturn(IErc20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.
        bytes memory returndata = functionCall(address(token), data, "SafeErc20LowLevelCall");
        if (returndata.length > 0) {
            // Return data is optional.
            if (!abi.decode(returndata, (bool))) {
                revert SafeErc20__NoReturnData();
            }
        }
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) private returns (bytes memory) {
        if (!target.isContract()) {
            revert SafeErc20__CallToNonContract(target);
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present.
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly.
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

// 
pragma solidity >=0.8.4;











interface IBalanceSheetV2 is IOwnableUpgradeable {
    /// CUSTOM ERRORS ///

    
    error BalanceSheet__BondMatured(IHToken bond);

    
    error BalanceSheet__BorrowMaxBonds(IHToken bond, uint256 newBondListLength, uint256 maxBonds);

    
    error BalanceSheet__DepositMaxCollaterals(
        IErc20 collateral,
        uint256 newCollateralListLength,
        uint256 maxCollaterals
    );

    
    error BalanceSheet__BorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__BorrowZero();

    
    error BalanceSheet__CollateralCeilingOverflow(uint256 newTotalSupply, uint256 debtCeiling);

    
    error BalanceSheet__DebtCeilingOverflow(uint256 newCollateralAmount, uint256 debtCeiling);

    
    error BalanceSheet__DepositCollateralNotAllowed(IErc20 collateral);

    
    error BalanceSheet__DepositCollateralZero();

    
    error BalanceSheet__FintrollerZeroAddress();

    
    error BalanceSheet__LiquidateBorrowInsufficientCollateral(
        address account,
        uint256 vaultCollateralAmount,
        uint256 seizableAmount
    );

    
    error BalanceSheet__LiquidateBorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__LiquidateBorrowSelf(address account);

    
    error BalanceSheet__LiquidityShortfall(address account, uint256 shortfallLiquidity);

    
    error BalanceSheet__NoLiquidityShortfall(address account);

    
    error BalanceSheet__OracleZeroAddress();

    
    error BalanceSheet__RepayBorrowInsufficientBalance(IHToken bond, uint256 repayAmount, uint256 hTokenBalance);

    
    error BalanceSheet__RepayBorrowInsufficientDebt(IHToken bond, uint256 repayAmount, uint256 debtAmount);

    
    error BalanceSheet__RepayBorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__RepayBorrowZero();

    
    error BalanceSheet__WithdrawCollateralUnderflow(
        address account,
        uint256 vaultCollateralAmount,
        uint256 withdrawAmount
    );

    
    error BalanceSheet__WithdrawCollateralZero();

    /// EVENTS ///

    
    
    
    
    event Borrow(address indexed account, IHToken indexed bond, uint256 borrowAmount);

    
    
    
    
    event DepositCollateral(address indexed account, IErc20 indexed collateral, uint256 collateralAmount);

    
    
    
    
    
    
    
    event LiquidateBorrow(
        address indexed liquidator,
        address indexed borrower,
        IHToken indexed bond,
        uint256 repayAmount,
        IErc20 collateral,
        uint256 seizedCollateralAmount
    );

    
    
    
    
    
    
    event RepayBorrow(
        address indexed payer,
        address indexed borrower,
        IHToken indexed bond,
        uint256 repayAmount,
        uint256 newDebtAmount
    );

    
    
    
    
    event SetFintroller(address indexed owner, address oldFintroller, address newFintroller);

    
    
    
    
    event SetOracle(address indexed owner, address oldOracle, address newOracle);

    
    
    
    
    event WithdrawCollateral(address indexed account, IErc20 indexed collateral, uint256 collateralAmount);

    /// CONSTANT FUNCTIONS ///

    
    
    
    function getBondList(address account) external view returns (IHToken[] memory);

    
    
    
    
    function getCollateralAmount(address account, IErc20 collateral) external view returns (uint256 collateralAmount);

    
    
    
    function getCollateralList(address account) external view returns (IErc20[] memory);

    
    
    
    
    function getCurrentAccountLiquidity(address account)
        external
        view
        returns (uint256 excessLiquidity, uint256 shortfallLiquidity);

    
    
    
    
    function getDebtAmount(address account, IHToken bond) external view returns (uint256 debtAmount);

    
    /// using the current prices provided by the oracle.
    ///
    
    /// respective collateral ratio, then dividing the sum by the total amount of debt drawn by the user.
    ///
    /// Caveats:
    /// - This function expects that the "collateralList" and the "bondList" are each modified in advance to include
    /// the collateral and bond due to be modified.
    ///
    
    
    
    
    
    
    
    function getHypotheticalAccountLiquidity(
        address account,
        IErc20 collateralModify,
        uint256 collateralAmountModify,
        IHToken bondModify,
        uint256 debtAmountModify
    ) external view returns (uint256 excessLiquidity, uint256 shortfallLiquidity);

    
    /// Note that this is for informational purposes only, it doesn't say anything about whether the user can be
    /// liquidated.
    
    /// repayAmount = (seizableCollateralAmount * collateralPriceUsd) / (liquidationIncentive * underlyingPriceUsd)
    
    
    
    
    function getRepayAmount(
        IErc20 collateral,
        uint256 seizableCollateralAmount,
        IHToken bond
    ) external view returns (uint256 repayAmount);

    
    /// is for informational purposes only, it doesn't say anything about whether the user can be liquidated.
    
    /// seizableCollateralAmount = repayAmount * liquidationIncentive * underlyingPriceUsd / collateralPriceUsd
    
    
    
    
    function getSeizableCollateralAmount(
        IHToken bond,
        uint256 repayAmount,
        IErc20 collateral
    ) external view returns (uint256 seizableCollateralAmount);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The maturity of the bond must be in the future.
    /// - The amount to borrow cannot be zero.
    /// - The new length of the bond list must be below the max bonds limit.
    /// - The new total amount of debt cannot exceed the debt ceiling.
    /// - The caller must not end up having a shortfall of liquidity.
    ///
    
    
    function borrow(IHToken bond, uint256 borrowAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The amount to deposit cannot be zero.
    /// - The caller must have allowed this contract to spend `collateralAmount` tokens.
    /// - The new collateral amount cannot exceed the collateral ceiling.
    ///
    
    
    function depositCollateral(IErc20 collateral, uint256 depositAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - All from "repayBorrow".
    /// - The caller cannot be the same with the borrower.
    /// - The Fintroller must allow this action to be performed.
    /// - The borrower must have a shortfall of liquidity if the bond didn't mature.
    /// - The amount of seized collateral cannot be more than what the borrower has in the vault.
    ///
    
    
    
    
    function liquidateBorrow(
        address borrower,
        IHToken bond,
        uint256 repayAmount,
        IErc20 collateral
    ) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The amount to repay cannot be zero.
    /// - The Fintroller must allow this action to be performed.
    /// - The caller must have at least `repayAmount` hTokens.
    /// - The caller must have at least `repayAmount` debt.
    ///
    
    
    function repayBorrow(IHToken bond, uint256 repayAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - Same as the `repayBorrow` function, but here `borrower` is the account that must have at least
    /// `repayAmount` hTokens to repay the borrow.
    ///
    
    
    
    function repayBorrowBehalf(
        address borrower,
        IHToken bond,
        uint256 repayAmount
    ) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The new address cannot be the zero address.
    ///
    
    function setFintroller(IFintroller newFintroller) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The new address cannot be the zero address.
    ///
    
    function setOracle(IChainlinkOperator newOracle) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The amount to withdraw cannot be zero.
    /// - There must be enough collateral in the vault.
    /// - The caller's account cannot fall below the collateral ratio.
    ///
    
    
    function withdrawCollateral(IErc20 collateral, uint256 withdrawAmount) external;
}

// 
pragma solidity >=0.8.4;









interface IFintroller is IOwnable {
    /// CUSTOM ERRORS ///

    
    error Fintroller__BondNotListed(IHToken bond);

    
    error Fintroller__BondBorrowAllowedWithLiquidateBorrowDisallowed();

    
    error Fintroller__BondLiquidateBorrowAllowedWithRepayBorrowDisallowed();

    
    error Fintroller__BondLiquidateBorrowDisallowedWithBorrowAllowed();

    
    error Fintroller__BondRepayBorrowDisallowedWithLiquidateBorrowAllowed();

    
    error Fintroller__CollateralDecimalsOverflow(uint256 decimals);

    
    error Fintroller__CollateralDecimalsZero();

    
    error Fintroller__CollateralNotListed(IErc20 collateral);

    
    error Fintroller__CollateralRatioBelowLiquidationIncentive(uint256 newCollateralRatio);

    
    error Fintroller__CollateralRatioOverflow(uint256 newCollateralRatio);

    
    error Fintroller__CollateralRatioUnderflow(uint256 newCollateralRatio);

    
    error Fintroller__DebtCeilingUnderflow(uint256 newDebtCeiling, uint256 totalSupply);

    
    error Fintroller__LiquidationIncentiveAboveCollateralRatio(uint256 newLiquidationIncentive);

    
    error Fintroller__LiquidationIncentiveOverflow(uint256 newLiquidationIncentive);

    
    error Fintroller__LiquidationIncentiveUnderflow(uint256 newLiquidationIncentive);

    /// EVENTS ///

    
    
    
    event ListBond(address indexed owner, IHToken indexed bond);

    
    
    
    event ListCollateral(address indexed owner, IErc20 indexed collateral);

    
    
    
    
    event SetBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    
    event SetCollateralCeiling(
        address indexed owner,
        IErc20 indexed collateral,
        uint256 oldCollateralCeiling,
        uint256 newCollateralCeiling
    );

    
    
    
    
    
    event SetCollateralRatio(
        address indexed owner,
        IErc20 indexed collateral,
        uint256 oldCollateralRatio,
        uint256 newCollateralRatio
    );

    
    
    
    
    
    event SetDebtCeiling(address indexed owner, IHToken indexed bond, uint256 oldDebtCeiling, uint256 newDebtCeiling);

    
    
    
    event SetDepositCollateralAllowed(address indexed owner, IErc20 indexed collateral, bool state);

    
    
    
    
    event SetDepositUnderlyingAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    event SetLiquidateBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    
    event SetLiquidationIncentive(
        address indexed owner,
        IErc20 collateral,
        uint256 oldLiquidationIncentive,
        uint256 newLiquidationIncentive
    );

    
    
    
    
    event SetMaxBonds(address indexed owner, uint256 oldMaxBonds, uint256 newMaxBonds);

    
    
    
    
    event SetMaxCollaterals(address indexed owner, uint256 oldMaxCollaterals, uint256 newMaxCollaterals);

    
    
    
    
    event SetRepayBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    /// STRUCTS ///

    struct Bond {
        uint256 debtCeiling;
        bool isBorrowAllowed;
        bool isDepositUnderlyingAllowed;
        bool isLiquidateBorrowAllowed;
        bool isListed;
        bool isRepayBorrowAllowed;
    }

    struct Collateral {
        uint256 ceiling;
        uint256 ratio;
        uint256 liquidationIncentive;
        bool isDepositCollateralAllowed;
        bool isListed;
    }

    /// CONSTANT FUNCTIONS ///

    
    
    
    
    function getBond(IHToken bond) external view returns (Bond memory);

    
    
    
    
    function getBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getCollateral(IErc20 collateral) external view returns (Collateral memory);

    
    
    
    
    function getCollateralCeiling(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getCollateralRatio(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getDebtCeiling(IHToken bond) external view returns (uint256);

    
    
    
    
    function getDepositCollateralAllowed(IErc20 collateral) external view returns (bool);

    
    
    
    
    function getDepositUnderlyingAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getLiquidationIncentive(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getLiquidateBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getRepayBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    function isBondListed(IHToken bond) external view returns (bool);

    
    
    
    function isCollateralListed(IErc20 collateral) external view returns (bool);

    
    function maxBonds() external view returns (uint256);

    
    function maxCollaterals() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function listBond(IHToken bond) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must have between 1 and 18 decimals.
    ///
    
    function listCollateral(IErc20 collateral) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setBorrowAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    ///
    
    
    function setCollateralCeiling(IHToken collateral, uint256 newCollateralCeiling) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    /// - The new collateral ratio cannot be higher than the maximum collateral ratio.
    /// - The new collateral ratio cannot be lower than the minimum collateral ratio.
    ///
    
    
    function setCollateralRatio(IErc20 collateral, uint256 newCollateralRatio) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    /// - The debt ceiling cannot fall below the current total supply of hTokens.
    ///
    
    
    function setDebtCeiling(IHToken bond, uint256 newDebtCeiling) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    
    function setDepositCollateralAllowed(IErc20 collateral, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    
    function setDepositUnderlyingAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    /// - The new liquidation incentive cannot be higher than the maximum liquidation incentive.
    /// - The new liquidation incentive cannot be lower than the minimum liquidation incentive.
    ///
    
    
    function setLiquidationIncentive(IErc20 collateral, uint256 newLiquidationIncentive) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setLiquidateBorrowAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function setMaxBonds(uint256 newMaxBonds) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function setMaxCollaterals(uint256 newMaxCollaterals) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setRepayBorrowAllowed(IHToken bond, bool state) external;
}

// 
pragma solidity >=0.8.4;





/// https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v3.4.0/contracts/utils/Address.sol
library Address {
    
    ///
    /// IMPORTANT: It is unsafe to assume that an address for which this function returns false is an
    /// externally-owned account (EOA) and not a contract.
    ///
    /// Among others, `isContract` will return false for the following types of addresses:
    ///
    /// - An externally-owned account
    /// - A contract in construction
    /// - An address where a contract will be created
    /// - An address where a contract lived, but was destroyed
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`.
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
}

// 
pragma solidity >=0.8.4;









interface IChainlinkOperator {
    /// CUSTOM ERRORS ///

    
    error ChainlinkOperator__DecimalsMismatch(string symbol, uint256 decimals);

    
    error ChainlinkOperator__FeedNotSet(string symbol);

    
    error ChainlinkOperator__PriceLessThanOrEqualToZero(string symbol);

    
    error ChainlinkOperator__PriceStale(string symbol);

    /// EVENTS ///

    
    
    
    event DeleteFeed(IErc20 indexed asset, IAggregatorV3 indexed feed);

    
    
    
    event SetFeed(IErc20 indexed asset, IAggregatorV3 indexed feed);

    
    
    
    event SetPriceStalenessThreshold(uint256 oldPriceStalenessThreshold, uint256 newPriceStalenessThreshold);

    /// STRUCTS ///

    struct Feed {
        IErc20 asset;
        IAggregatorV3 id;
        bool isSet;
    }

    /// CONSTANT FUNCTIONS ///

    
    
    
    function getFeed(string memory symbol)
        external
        view
        returns (
            IErc20,
            IAggregatorV3,
            bool
        );

    
    /// format used by Chainlink, which has 8 decimals.
    ///
    
    /// - The normalized price cannot overflow.
    ///
    
    
    function getNormalizedPrice(string memory symbol) external view returns (uint256);

    
    /// has 8 decimals.
    ///
    
    ///
    /// - The feed must be set.
    /// - The price returned by the oracle cannot be zero.
    ///
    
    
    function getPrice(string memory symbol) external view returns (uint256);

    
    function pricePrecision() external view returns (uint256);

    
    function pricePrecisionScalar() external view returns (uint256);

    
    function priceStalenessThreshold() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The feed must be set already.
    ///
    
    function deleteFeed(string memory symbol) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The number of decimals of the feed must be 8.
    ///
    
    
    function setFeed(IErc20 asset, IAggregatorV3 feed) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    ///
    
    function setPriceStalenessThreshold(uint256 newPriceStalenessThreshold) external;
}

// 
pragma solidity >=0.8.4;




/// github.com/smartcontractkit/chainlink/blob/v1.2.0/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    /// getRoundData and latestRoundData should both raise "No data present" if they do not have
    /// data to report, instead of returning unset values which could be misinterpreted as
    /// actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}