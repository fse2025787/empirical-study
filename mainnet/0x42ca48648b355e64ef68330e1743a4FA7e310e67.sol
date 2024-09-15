// SPDX-License-Identifier: GPL-3.0-or-later


// 
pragma solidity 0.8.10;

interface IOwnableEvents {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}

contract Ownable is IOwnableEvents {
    address public owner;
    address private nextOwner;

    // modifiers

    modifier onlyOwner() {
        require(isOwner(), "caller is not the owner.");
        _;
    }

    modifier onlyNextOwner() {
        require(isNextOwner(), "current owner must set caller as next owner.");
        _;
    }

    /**
     * @dev Initialize contract by setting transaction submitter as initial owner.
     */
    constructor(address owner_) {
        owner = owner_;
        emit OwnershipTransferred(address(0), owner);
    }

    /**
     * @dev Initiate ownership transfer by setting nextOwner.
     */
    function transferOwnership(address nextOwner_) external onlyOwner {
        require(nextOwner_ != address(0), "Next owner is the zero address.");

        nextOwner = nextOwner_;
    }

    /**
     * @dev Cancel ownership transfer by deleting nextOwner.
     */
    function cancelOwnershipTransfer() external onlyOwner {
        delete nextOwner;
    }

    /**
     * @dev Accepts ownership transfer by setting owner.
     */
    function acceptOwnership() external onlyNextOwner {
        delete nextOwner;

        owner = msg.sender;

        emit OwnershipTransferred(owner, msg.sender);
    }

    /**
     * @dev Renounce ownership by setting owner to zero address.
     */
    function renounceOwnership() external onlyOwner {
        _renounceOwnership();
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    /**
     * @dev Returns true if the caller is the next owner.
     */
    function isNextOwner() public view returns (bool) {
        return msg.sender == nextOwner;
    }

    function _setOwner(address previousOwner, address newOwner) internal {
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, owner);
    }

    function _renounceOwnership() internal {
        emit OwnershipTransferred(owner, address(0));

        owner = address(0);
    }
}

// 
pragma solidity 0.8.10;

interface IERC20Events {
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    
    event Mint(address indexed _to, uint256 _value);
}

interface IERC20 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function initialize(
        address operator_,
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint8 decimals_
    ) external returns (address);

    function setBurnable(bool canBurn) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;
}// 
pragma solidity 0.8.10;




/**
 * @title ERC20
 * @notice EIP-20 (https://eips.ethereum.org/EIPS/eip-20) implementation with EIP-2612
 * (https://eips.ethereum.org/EIPS/eip-2612) support, as well as mint and burn functionality.
 * @author MirrorXYZ
 */
contract ERC20 is Ownable, IERC20, IERC20Events {
    
    
    bytes32 public constant override PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    
    uint256 public override totalSupply;

    
    string public override name;

    
    string public override symbol;

    
    uint8 public override decimals;

    
    mapping(address => uint256) public override balanceOf;

    
    mapping(address => mapping(address => uint256)) public override allowance;

    
    bytes32 public override DOMAIN_SEPARATOR;

    
    mapping(address => uint256) public override nonces;

    
    bool public burnable;

    
    address public immutable factory;

    modifier ifBurnable() {
        require(burnable, "ERC20: cannot burn");
        _;
    }

    
    constructor(address factory_) Ownable(address(0)) {
        factory = factory_;
    }

    
    
    
    
    
    
    
    function initialize(
        address owner_,
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint8 decimals_
    ) external override returns (address) {
        // ensure that this function is only callable by the factory
        require(msg.sender == factory, "unauthorized caller");

        // set owner
        _setOwner(address(0), owner_);

        // set metadata
        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        // mint initial supply
        _mint(owner_, totalSupply_);

        // generate domain separator
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name_)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );

        // set burn status
        burnable = false;

        return address(this);
    }

    
    
    function setBurnable(bool canBurn) external override onlyOwner {
        burnable = canBurn;
    }

    // ============ ERC-20 Methods ============

    
    
    ///  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
    
    
    
    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);

        return true;
    }

    
    
    
    
    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, to, value);

        return true;
    }

    
    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= value;
        }

        _transfer(from, to, value);

        return true;
    }

    
    
    
    
    
    
    
    
    function permit(
        address _owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(deadline >= block.timestamp, "ERC20: EXPIRED");

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        _owner,
                        spender,
                        value,
                        nonces[_owner]++,
                        deadline
                    )
                )
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);

        require(
            recoveredAddress != address(0) && recoveredAddress == _owner,
            "ERC20: INVALID_SIGNATURE"
        );

        _approve(_owner, spender, value);
    }

    
    
    
    function burn(uint256 value) external override ifBurnable {
        _burn(msg.sender, value);
    }

    
    
    
    
    function mint(address to, uint256 value) external override onlyOwner {
        _mint(to, value);
    }

    // ============ Internal Methods ============

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(to != address(0), "ERC20: transfer to the zero address");

        balanceOf[from] -= value;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += value;
        }

        emit Transfer(from, to, value);
    }

    function _mint(address to, uint256 value) internal {
        require(to != address(0), "ERC20: mint to the zero address");

        totalSupply += value;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += value;
        }

        emit Transfer(address(0), to, value);
    }

    function _approve(
        address _owner,
        address spender,
        uint256 value
    ) internal {
        allowance[_owner][spender] = value;

        emit Approval(_owner, spender, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] -= value;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= value;
        }

        emit Transfer(from, address(0), value);
    }
}
