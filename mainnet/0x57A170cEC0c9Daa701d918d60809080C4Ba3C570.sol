// SPDX-License-Identifier: Apache-2.0


// 
pragma solidity ^0.8.0;

interface IERC20 {
    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    // Note this is non standard but nearly all ERC20 have exposed decimal functions
    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Forked from openzepplin
// 

pragma solidity ^0.8.0;



/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit is IERC20 {
    /**
     * @dev Sets `value` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
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
     * @dev Returns the domain separator used in the encoding of the signature for `permit`, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// 
pragma solidity ^0.8.0;




interface IWrappedPosition is IERC20Permit {
    function token() external view returns (IERC20);

    function balanceOfUnderlying(address who) external view returns (uint256);

    function getSharesToUnderlying(uint256 shares)
        external
        view
        returns (uint256);

    function deposit(address sender, uint256 amount) external returns (uint256);

    function withdraw(
        address sender,
        uint256 _shares,
        uint256 _minUnderlying
    ) external returns (uint256);

    function withdrawUnderlying(
        address _destination,
        uint256 _amount,
        uint256 _minUnderlying
    ) external returns (uint256, uint256);

    function prefundedDeposit(address _destination)
        external
        returns (
            uint256,
            uint256,
            uint256
        );
}

// 

pragma solidity ^0.8.0;



// This default erc20 library is designed for max efficiency and security.
// WARNING: By default it does not include totalSupply which breaks the ERC20 standard
//          to use a fully standard compliant ERC20 use 'ERC20PermitWithSupply"
abstract contract ERC20Permit is IERC20Permit {
    // --- ERC20 Data ---
    // The name of the erc20 token
    string public name;
    // The symbol of the erc20 token
    string public override symbol;
    // The decimals of the erc20 token, should default to 18 for new tokens
    uint8 public override decimals;

    // A mapping which tracks user token balances
    mapping(address => uint256) public override balanceOf;
    // A mapping which tracks which addresses a user allows to move their tokens
    mapping(address => mapping(address => uint256)) public override allowance;
    // A mapping which tracks the permit signature nonces for users
    mapping(address => uint256) public override nonces;

    // --- EIP712 niceties ---
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public override DOMAIN_SEPARATOR;
    // bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    
    
    
    
    ///      non standard decimal values
    constructor(string memory name_, string memory symbol_) {
        // Set the state variables
        name = name_;
        symbol = symbol_;
        decimals = 18;

        // By setting these addresses to 0 attempting to execute a transfer to
        // either of them will revert. This is a gas efficient way to prevent
        // a common user mistake where they transfer to the token address.
        // These values are not considered 'real' tokens and so are not included
        // in 'total supply' which only contains minted tokens.
        balanceOf[address(0)] = type(uint256).max;
        balanceOf[address(this)] = type(uint256).max;

        // Optional extra state manipulation
        _extraConstruction();

        // Computes the EIP 712 domain separator which prevents user signed messages for
        // this contract to be replayed in other contracts.
        // https://eips.ethereum.org/EIPS/eip-712
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    
    function _extraConstruction() internal virtual {}

    // --- Token ---
    
    
    
    
    
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        // We forward this call to 'transferFrom'
        return transferFrom(msg.sender, recipient, amount);
    }

    
    
    
    
    
    
    function transferFrom(
        address spender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        // Load balance and allowance
        uint256 balance = balanceOf[spender];
        require(balance >= amount, "ERC20: insufficient-balance");
        // We potentially have to change allowances
        if (spender != msg.sender) {
            // Loading the allowance in the if block prevents vanilla transfers
            // from paying for the sload.
            uint256 allowed = allowance[spender][msg.sender];
            // If the allowance is max we do not reduce it
            // Note - This means that max allowances will be more gas efficient
            // by not requiring a sstore on 'transferFrom'
            if (allowed != type(uint256).max) {
                require(allowed >= amount, "ERC20: insufficient-allowance");
                allowance[spender][msg.sender] = allowed - amount;
            }
        }
        // Update the balances
        balanceOf[spender] = balance - amount;
        // Note - In the constructor we initialize the 'balanceOf' of address 0 and
        //        the token address to uint256.max and so in 8.0 transfers to those
        //        addresses revert on this step.
        balanceOf[recipient] = balanceOf[recipient] + amount;
        // Emit the needed event
        emit Transfer(spender, recipient, amount);
        // Return that this call succeeded
        return true;
    }

    
    ///         to mint tokens in the way they wish.
    
    
    
    ///      are reviewing this contract for security you should ensure to
    ///      check for overrides
    function _mint(address account, uint256 amount) internal virtual {
        // Add tokens to the account
        balanceOf[account] = balanceOf[account] + amount;
        // Emit an event to track the minting
        emit Transfer(address(0), account, amount);
    }

    
    ///         burn tokens in the way they see fit.
    
    
    
    ///      are reviewing this contract for security you should ensure to
    ///      check for overrides
    function _burn(address account, uint256 amount) internal virtual {
        // Reduce the balance of the account
        balanceOf[account] = balanceOf[account] - amount;
        // Emit an event tracking transfers
        emit Transfer(account, address(0), amount);
    }

    
    ///         tokens on their behalf.
    
    
    
    function approve(address account, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        // Set the senders allowance for account to amount
        allowance[msg.sender][account] = amount;
        // Emit an event to track approvals
        emit Approval(msg.sender, account, amount);
        return true;
    }

    
    
    
    
    
    
    
    
    
    ///      eth_signTypedData JSON RPC call instead of the eth_sign JSON RPC call. If using out of date
    ///      parity signing libraries the v component may need to be adjusted. Also it is very rare but possible
    ///      for v to be other values, those values are not supported.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        // The EIP 712 digest for this function
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner],
                        deadline
                    )
                )
            )
        );
        // Require that the owner is not zero
        require(owner != address(0), "ERC20: invalid-address-0");
        // Require that we have a valid signature from the owner
        require(owner == ecrecover(digest, v, r, s), "ERC20: invalid-permit");
        // Require that the signature is not expired
        require(
            deadline == 0 || block.timestamp <= deadline,
            "ERC20: permit-expired"
        );
        // Format the signature to the default format
        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ERC20: invalid signature 's' value"
        );
        // Increment the signature nonce to prevent replay
        nonces[owner]++;
        // Set the allowance to the new value
        allowance[owner][spender] = value;
        // Emit an approval event to be able to track this happening
        emit Approval(owner, spender, value);
    }

    
    
    function _setupDecimals(uint8 decimals_) internal {
        // Set the decimals
        decimals = decimals_;
    }
}

// 
pragma solidity ^0.8.0;









abstract contract WrappedPosition is ERC20Permit, IWrappedPosition {
    IERC20 public immutable override token;

    
    
    ///               This token should revert in the event of a transfer failure.
    
    
    constructor(
        IERC20 _token,
        string memory _name,
        string memory _symbol
    ) ERC20Permit(_name, _symbol) {
        token = _token;
        // We set our decimals to be the same as the underlying
        _setupDecimals(_token.decimals());
    }

    /// We expect that the following logic will be present in an integration implementation
    /// which inherits from this contract

    
    
    function _deposit() internal virtual returns (uint256, uint256);

    
    
    function _withdraw(
        uint256,
        address,
        uint256
    ) internal virtual returns (uint256);

    
    ///      and underlying tokens.
    
    function _underlying(uint256) internal view virtual returns (uint256);

    
    
    
    function balanceOfUnderlying(address _who)
        external
        view
        override
        returns (uint256)
    {
        return _underlying(balanceOf[_who]);
    }

    
    
    
    function getSharesToUnderlying(uint256 _shares)
        external
        view
        override
        returns (uint256)
    {
        return _underlying(_shares);
    }

    
    ///         Transfers tokens on behalf of caller so the caller must set
    ///         allowance on the contract prior to call.
    
    
    
    function deposit(address _destination, uint256 _amount)
        external
        override
        returns (uint256)
    {
        // Send tokens to the proxy
        token.transferFrom(msg.sender, address(this), _amount);
        // Calls our internal deposit function
        (uint256 shares, ) = _deposit();
        // Mint them internal ERC20 tokens corresponding to the deposit
        _mint(_destination, shares);
        return shares;
    }

    
    ///         Assumes the tokens were transferred before this was called
    
    
    ///                  senders WP balance before mint)
    
    //                 as the call to this method or you risk loss of funds
    function prefundedDeposit(address _destination)
        external
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        // Calls our internal deposit function
        (uint256 shares, uint256 usedUnderlying) = _deposit();

        uint256 balanceBefore = balanceOf[_destination];

        // Mint them internal ERC20 tokens corresponding to the deposit
        _mint(_destination, shares);
        return (shares, usedUnderlying, balanceBefore);
    }

    
    
    
    
    
    function withdraw(
        address _destination,
        uint256 _shares,
        uint256 _minUnderlying
    ) public override returns (uint256) {
        return _positionWithdraw(_destination, _shares, _minUnderlying, 0);
    }

    
    ///          of underlying to the _destination.
    
    
    
    
    function withdrawUnderlying(
        address _destination,
        uint256 _amount,
        uint256 _minUnderlying
    ) external override returns (uint256, uint256) {
        // First we load the number of underlying per unit of Wrapped Position token
        uint256 oneUnit = 10**decimals;
        uint256 underlyingPerShare = _underlying(oneUnit);
        // Then we calculate the number of shares we need
        uint256 shares = (_amount * oneUnit) / underlyingPerShare;
        // Using this we call the normal withdraw function
        uint256 underlyingReceived = _positionWithdraw(
            _destination,
            shares,
            _minUnderlying,
            underlyingPerShare
        );
        return (underlyingReceived, shares);
    }

    
    ///         so that we can avoid calling it again in the internal function
    
    
    
    
    
    function _positionWithdraw(
        address _destination,
        uint256 _shares,
        uint256 _minUnderlying,
        uint256 _underlyingPerShare
    ) internal returns (uint256) {
        // Burn users shares
        _burn(msg.sender, _shares);

        // Withdraw that many shares from the vault
        uint256 withdrawAmount = _withdraw(
            _shares,
            _destination,
            _underlyingPerShare
        );

        // We revert if this call doesn't produce enough underlying
        // This security feature is useful in some edge cases
        require(withdrawAmount >= _minUnderlying, "Not enough underlying");
        return withdrawAmount;
    }
}

// 
pragma solidity >=0.7.0;

contract Authorizable {
    // This contract allows a flexible authorization scheme

    // The owner who can change authorization status
    address public owner;
    // A mapping from an address to its authorization status
    mapping(address => bool) public authorized;

    
    constructor() {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender not owner");
        _;
    }

    
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    
    
    
    function isAuthorized(address who) public view returns (bool) {
        return authorized[who];
    }

    
    
    function authorize(address who) external onlyOwner {
        _authorize(who);
    }

    
    
    function deauthorize(address who) external onlyOwner {
        authorized[who] = false;
    }

    
    
    function setOwner(address who) public onlyOwner {
        owner = who;
    }

    
    
    function _authorize(address who) internal {
        authorized[who] = true;
    }
}
// 
pragma solidity ^0.8.0;






/// SECURITY - This contract has an owner address which can migrate funds to a new yearn vault [or other contract
///            with compatible interface] as well as pause deposits and withdraws. This means that any deposited funds
///            have the same security as that address.



contract YVaultAssetProxy is WrappedPosition, Authorizable {
    // The addresses of the current yearn vault
    IYearnVault public vault;
    // 18 decimal fractional form of the multiplier which is applied after
    // a vault upgrade. 0 when no upgrade has happened
    uint88 public conversionRate;
    // Bool packed into the same storage slot as vault and conversion rate
    bool public paused;
    uint8 public immutable vaultDecimals;

    
    
    
    ///               This token should revert in the event of a transfer failure.
    
    
    
    
    constructor(
        address vault_,
        IERC20 _token,
        string memory _name,
        string memory _symbol,
        address _governance,
        address _pauser
    ) WrappedPosition(_token, _name, _symbol) Authorizable() {
        // Authorize the pauser
        _authorize(_pauser);
        // set the owner
        setOwner(_governance);
        // Set the vault
        vault = IYearnVault(vault_);
        // Approve the vault so it can pull tokens from this address
        _token.approve(vault_, type(uint256).max);
        // Load the decimals and set them as an immutable
        uint8 localVaultDecimals = IERC20(vault_).decimals();
        vaultDecimals = localVaultDecimals;
        require(
            uint8(_token.decimals()) == localVaultDecimals,
            "Inconsistent decimals"
        );
    }

    
    modifier notPaused() {
        require(!paused, "Paused");
        _;
    }

    
    
    function _deposit() internal override notPaused returns (uint256, uint256) {
        // Get the amount deposited
        uint256 amount = token.balanceOf(address(this));

        // Deposit and get the shares that were minted to this
        uint256 shares = vault.deposit(amount, address(this));

        // If we have migrated our shares are no longer 1 - 1 with the vault shares
        if (conversionRate != 0) {
            // conversionRate is the fraction of yearnSharePrice1/yearnSharePrices2 at time of migration
            // and so this multiplication will convert between yearn shares in the new vault and
            // those in the old vault
            shares = (shares * conversionRate) / 1e18;
        }

        // Return the amount of shares the user has produced, and the amount used for it.
        return (shares, amount);
    }

    
    
    
    // @param _underlyingPerShare The possibly precomputed underlying per share
    
    function _withdraw(
        uint256 _shares,
        address _destination,
        uint256
    ) internal override notPaused returns (uint256) {
        // If the conversion rate is non-zero we have upgraded and so our wrapped shares are
        // not one to one with the original shares.
        if (conversionRate != 0) {
            // Then since conversion rate is yearnSharePrice1/yearnSharePrices2 we divide the
            // wrapped position shares by it because they are equivalent to the first yearn vault shares
            _shares = (_shares * 1e18) / conversionRate;
        }
        // Withdraws shares from the vault. Max loss is set at 100% as
        // the minimum output value is enforced by the calling
        // function in the WrappedPosition contract.
        uint256 amountReceived = vault.withdraw(_shares, _destination, 10000);

        // Return the amount of underlying
        return amountReceived;
    }

    
    
    
    function _underlying(uint256 _amount)
        internal
        view
        override
        returns (uint256)
    {
        // We may have to convert before using the vault price per share
        if (conversionRate != 0) {
            // Imitate the _withdraw logic and convert this amount to yearn vault2 shares
            _amount = (_amount * 1e18) / conversionRate;
        }
        return (_amount * _pricePerShare()) / (10**vaultDecimals);
    }

    
    
    function _pricePerShare() internal view returns (uint256) {
        return vault.pricePerShare();
    }

    
    function approve() external {
        token.approve(address(vault), 0);
        token.approve(address(vault), type(uint256).max);
    }

    
    
    
    function pause(bool pauseStatus) external onlyAuthorized {
        paused = pauseStatus;
    }

    
    
    
    
    ///                contract and so it should be ensured that the owner is a high quorum
    ///                governance vote through the time lock.
    function transition(IYearnVault newVault, uint256 minOutputShares)
        external
        onlyOwner
    {
        // Load the current vault's price per share
        uint256 currentPricePerShare = _pricePerShare();
        // Load the new vault's price per share
        uint256 newPricePerShare = newVault.pricePerShare();
        // Load the current conversion rate or set it to 1
        uint256 newConversionRate = conversionRate == 0 ? 1e18 : conversionRate;
        // Calculate the new conversion rate, note by multiplying by the old
        // conversion rate here we implicitly support more than 1 upgrade
        newConversionRate =
            (newConversionRate * newPricePerShare) /
            currentPricePerShare;
        // We now withdraw from the old yearn vault using max shares
        // Note - Vaults should be checked in the future that they still have this behavior
        vault.withdraw(type(uint256).max, address(this), 10000);
        // Approve the new vault
        token.approve(address(newVault), type(uint256).max);
        // Then we deposit into the new vault
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 outputShares = newVault.deposit(currentBalance, address(this));
        // We enforce a min output
        require(outputShares >= minOutputShares, "Not enough output");
        // Change the stored variables
        vault = newVault;
        // because of the truncation yearn vaults can't have a larger diff than ~ billion
        // times larger
        conversionRate = uint88(newConversionRate);
    }
}

// 
pragma solidity ^0.8.0;



interface IYearnVault is IERC20 {
    function deposit(uint256, address) external returns (uint256);

    function withdraw(
        uint256,
        address,
        uint256
    ) external returns (uint256);

    // Returns the amount of underlying per each unit [1e18] of yearn shares
    function pricePerShare() external view returns (uint256);

    function governance() external view returns (address);

    function setDepositLimit(uint256) external;

    function totalSupply() external view returns (uint256);

    function totalAssets() external view returns (uint256);

    function apiVersion() external view returns (string memory);
}

// 
pragma solidity ^0.8.0;



interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}
