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
    bytes32
        public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    
    
    
    
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
    
    function _underlying(uint256) internal virtual view returns (uint256);

    
    
    
    function balanceOfUnderlying(address _who)
        external
        override
        view
        returns (uint256)
    {
        return _underlying(balanceOf[_who]);
    }

    
    
    
    function getSharesToUnderlying(uint256 _shares)
        external
        override
        view
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
// WARNING: This has been validated for yearn vaults up to version 0.2.11.
// Using this code with any later version can be unsafe.
pragma solidity ^0.8.0;







contract YVaultAssetProxy is WrappedPosition {
    IYearnVault public immutable vault;
    uint8 public immutable vaultDecimals;

    // This contract allows deposits to a reserve which can
    // be used to short circuit the deposit process and save gas

    // The following mapping tracks those non-transferable deposits
    mapping(address => uint256) public reserveBalances;
    // These variables store the token balances of this contract and
    // should be packed by solidity into a single slot.
    uint128 public reserveUnderlying;
    uint128 public reserveShares;
    // This is the total amount of reserve deposits
    uint256 public reserveSupply;

    
    
    
    ///               This token should revert in the event of a transfer failure.
    
    
    constructor(
        address vault_,
        IERC20 _token,
        string memory _name,
        string memory _symbol
    ) WrappedPosition(_token, _name, _symbol) {
        vault = IYearnVault(vault_);
        _token.approve(vault_, type(uint256).max);
        uint8 localVaultDecimals = IERC20(vault_).decimals();
        vaultDecimals = localVaultDecimals;
        require(
            uint8(_token.decimals()) == localVaultDecimals,
            "Inconsistent decimals"
        );
        // We check that this is a compatible yearn version
        _versionCheck(IYearnVault(vault_));
    }

    
    
    
    function _versionCheck(IYearnVault _vault) internal virtual view {
        string memory apiVersion = _vault.apiVersion();
        require(
            _stringEq(apiVersion, "0.3.0") ||
                _stringEq(apiVersion, "0.3.1") ||
                _stringEq(apiVersion, "0.3.2") ||
                _stringEq(apiVersion, "0.3.3") ||
                _stringEq(apiVersion, "0.3.4") ||
                _stringEq(apiVersion, "0.3.5"),
            "Unsupported Version"
        );
    }

    
    
    
    
    function _stringEq(string memory s1, string memory s2)
        internal
        pure
        returns (bool)
    {
        bytes32 h1 = keccak256(abi.encodePacked(s1));
        bytes32 h2 = keccak256(abi.encodePacked(s2));
        return (h1 == h2);
    }

    
    ///      Note - there's no incentive to do so. You could earn some
    ///      interest but less interest than yearn. All deposits use
    ///      the underlying token.
    
    function reserveDeposit(uint256 _amount) external {
        // Transfer from user, note variable 'token' is the immutable
        // inherited from the abstract WrappedPosition contract.
        token.transferFrom(msg.sender, address(this), _amount);
        // Load the reserves
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        // Calculate the total reserve value
        uint256 totalValue = localUnderlying;
        totalValue += _yearnDepositConverter(localShares, true);
        // If this is the first deposit we need different logic
        uint256 localReserveSupply = reserveSupply;
        uint256 mintAmount;
        if (localReserveSupply == 0) {
            // If this is the first mint the tokens are exactly the supplied underlying
            mintAmount = _amount;
        } else {
            // Otherwise we mint the proportion that this increases the value held by this contract
            mintAmount = (localReserveSupply * _amount) / totalValue;
        }

        // This hack means that the contract will never have zero balance of underlying
        // which levels the gas expenditure of the transfer to this contract. Permanently locks
        // the smallest possible unit of the underlying.
        if (localUnderlying == 0 && localShares == 0) {
            _amount -= 1;
        }
        // Set the reserves that this contract has more underlying
        _setReserves(localUnderlying + _amount, localShares);
        // Note that the sender has deposited and increase reserveSupply
        reserveBalances[msg.sender] += mintAmount;
        reserveSupply = localReserveSupply + mintAmount;
    }

    
    
    function reserveWithdraw(uint256 _amount) external {
        // Remove 'amount' from the balances of the sender. Because this is 8.0 it will revert on underflow
        reserveBalances[msg.sender] -= _amount;
        // We load the reserves
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        uint256 localReserveSupply = reserveSupply;
        // Then we calculate the proportion of the shares to redeem
        uint256 userShares = (localShares * _amount) / localReserveSupply;
        // First we withdraw the proportion of shares tokens belonging to the caller
        uint256 freedUnderlying = vault.withdraw(userShares, address(this), 0);
        // We calculate the amount of underlying to send
        uint256 userUnderlying = (localUnderlying * _amount) /
            localReserveSupply;

        // We then store the updated reserve amounts
        _setReserves(
            localUnderlying - userUnderlying,
            localShares - userShares
        );
        // We note a reduction in local supply
        reserveSupply = localReserveSupply - _amount;

        // We send the redemption underlying to the caller
        // Note 'token' is an immutable from shares
        token.transfer(msg.sender, freedUnderlying + userUnderlying);
    }

    
    ///         Tries to use the local balances before depositing
    
    function _deposit() internal override returns (uint256, uint256) {
        //Load reserves
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        // Get the amount deposited
        uint256 amount = token.balanceOf(address(this)) - localUnderlying;
        // fixing for the fact there's an extra underlying
        if (localUnderlying != 0 || localShares != 0) {
            amount -= 1;
        }
        // Calculate the amount of shares the amount deposited is worth
        uint256 neededShares = _yearnDepositConverter(amount, false);

        // If we have enough in local reserves we don't call out for deposits
        if (localShares > neededShares) {
            // We set the reserves
            _setReserves(localUnderlying + amount, localShares - neededShares);
            // And then we short circuit execution and return
            return (neededShares, amount);
        }
        // Deposit and get the shares that were minted to this
        uint256 shares = vault.deposit(localUnderlying + amount, address(this));

        // calculate the user share
        uint256 userShare = (amount * shares) / (localUnderlying + amount);

        // We set the reserves
        _setReserves(0, localShares + shares - userShare);
        // Return the amount of shares the user has produced, and the amount used for it.
        return (userShare, amount);
    }

    
    
    
    
    function _withdraw(
        uint256 _shares,
        address _destination,
        uint256 _underlyingPerShare
    ) internal override returns (uint256) {
        // If we do not have it we load the price per share
        if (_underlyingPerShare == 0) {
            _underlyingPerShare = _pricePerShare();
        }
        // We load the reserves
        (uint256 localUnderlying, uint256 localShares) = _getReserves();
        // Calculate the amount of shares the amount deposited is worth
        uint256 needed = (_shares * _pricePerShare()) / (10**vaultDecimals);
        // If we have enough underlying we don't have to actually withdraw
        if (needed < localUnderlying) {
            // We set the reserves to be the new reserves
            _setReserves(localUnderlying - needed, localShares + _shares);
            // Then transfer needed underlying to the destination
            // 'token' is an immutable in WrappedPosition
            token.transfer(_destination, needed);
            // Short circuit and return
            return (needed);
        }
        // If we don't have enough local reserves we do the actual withdraw
        // Withdraws shares from the vault. Max loss is set at 100% as
        // the minimum output value is enforced by the calling
        // function in the WrappedPosition contract.
        uint256 amountReceived = vault.withdraw(
            _shares + localShares,
            address(this),
            10000
        );

        // calculate the user share
        uint256 userShare = (_shares * amountReceived) /
            (localShares + _shares);

        _setReserves(localUnderlying + amountReceived - userShare, 0);
        // Transfer the underlying to the destination 'token' is an immutable in WrappedPosition
        token.transfer(_destination, userShare);
        // Return the amount of underlying
        return userShare;
    }

    
    
    
    function _underlying(uint256 _amount)
        internal
        override
        view
        returns (uint256)
    {
        return (_amount * _pricePerShare()) / (10**vaultDecimals);
    }

    
    
    function _pricePerShare() internal view returns (uint256) {
        return vault.pricePerShare();
    }

    
    function approve() external {
        token.approve(address(vault), 0);
        token.approve(address(vault), type(uint256).max);
    }

    
    
    function _getReserves() internal view returns (uint256, uint256) {
        return (uint256(reserveUnderlying), uint256(reserveShares));
    }

    
    
    
    function _setReserves(
        uint256 _newReserveUnderlying,
        uint256 _newReserveShares
    ) internal {
        reserveUnderlying = uint128(_newReserveUnderlying);
        reserveShares = uint128(_newReserveShares);
    }

    
    ///      of underlying to an output of shares, using yearn 's deposit pricing
    
    
    ///                 underlying to yearn shares
    
    ///                but not withdraw logic in versions 0.3.2-0.3.5. In versions 0.4.0+
    ///                it is not a match for yearn deposit ratios.
    
    function _yearnDepositConverter(uint256 amount, bool sharesIn)
        internal
        virtual
        view
        returns (uint256)
    {
        // Load the yearn total supply and assets
        uint256 yearnTotalSupply = vault.totalSupply();
        uint256 yearnTotalAssets = vault.totalAssets();
        // If we are converted shares to underlying
        if (sharesIn) {
            // then we get the fraction of yearn shares this is and multiply by assets
            return (yearnTotalAssets * amount) / yearnTotalSupply;
        } else {
            // otherwise we figure out the faction of yearn assets this is and see how
            // many assets we get out.
            return (yearnTotalSupply * amount) / yearnTotalAssets;
        }
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
