// SPDX-License-Identifier: Apache-2.0


// 
pragma solidity ^0.8.3;





abstract contract AbstractMerkleRewards {
    // The merkle root with deposits encoded into it as hash [address, amount]
    // Assumed to be a node sorted tree
    bytes32 public rewardsRoot;
    // The token to pay out
    IERC20 public immutable token;
    // The historic user claims
    mapping(address => uint256) public claimed;
    // The locking gov vault
    ILockingVault public lockingVault;

    
    
    
    
    constructor(
        bytes32 _rewardsRoot,
        IERC20 _token,
        ILockingVault _lockingVault
    ) {
        rewardsRoot = _rewardsRoot;
        token = _token;
        lockingVault = _lockingVault;
        // We approve the locking vault so that it we can deposit on behalf of users
        _token.approve(address(lockingVault), type(uint256).max);
    }

    
    ///         governance
    
    
    
    
    
    function claimAndDelegate(
        uint256 amount,
        address delegate,
        uint256 totalGrant,
        bytes32[] calldata merkleProof,
        address destination
    ) external {
        // No delegating to zero
        require(delegate != address(0), "Zero addr delegation");
        // Validate the withdraw
        _validateWithdraw(amount, totalGrant, merkleProof);
        // Deposit for this sender into governance locking vault
        lockingVault.deposit(destination, amount, delegate);
    }

    
    
    
    
    
    function claim(
        uint256 amount,
        uint256 totalGrant,
        bytes32[] calldata merkleProof,
        address destination
    ) external virtual {
        // Validate the withdraw
        _validateWithdraw(amount, totalGrant, merkleProof);
        // Transfer to the user
        token.transfer(destination, amount);
    }

    
    ///         previously withdrawn
    
    
    
    function _validateWithdraw(
        uint256 amount,
        uint256 totalGrant,
        bytes32[] memory merkleProof
    ) internal {
        // Hash the user plus the total grant amount
        bytes32 leafHash = keccak256(abi.encodePacked(msg.sender, totalGrant));

        // Verify the proof for this leaf
        require(
            MerkleProof.verify(merkleProof, rewardsRoot, leafHash),
            "Invalid Proof"
        );
        // Check that this claim won't give them more than the total grant then
        // increase the stored claim amount
        require(claimed[msg.sender] + amount <= totalGrant, "Claimed too much");
        claimed[msg.sender] += amount;
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

    
    
    function authorize(address who) external onlyOwner() {
        _authorize(who);
    }

    
    
    function deauthorize(address who) external onlyOwner() {
        authorized[who] = false;
    }

    
    
    function setOwner(address who) public onlyOwner() {
        owner = who;
    }

    
    
    function _authorize(address who) internal {
        authorized[who] = true;
    }
}

// Deployable version of the abstract
contract MerkleRewards is AbstractMerkleRewards {
    
    
    
    
    constructor(
        bytes32 _rewardsRoot,
        IERC20 _token,
        ILockingVault _lockingVault
    ) AbstractMerkleRewards(_rewardsRoot, _token, _lockingVault) {}
}
// 
pragma solidity ^0.8.3;




// A merkle rewards contract with an expiration time

contract Airdrop is MerkleRewards, Authorizable {
    // The time after which the token cannot be claimed
    uint256 public immutable expiration;

    
    
    
    
    
    
    constructor(
        address _governance,
        bytes32 _merkleRoot,
        IERC20 _token,
        uint256 _expiration,
        ILockingVault _lockingVault
    ) MerkleRewards(_merkleRoot, _token, _lockingVault) {
        // Set expiration immutable and governance to the owner
        expiration = _expiration;
        setOwner(_governance);
    }

    
    ///         Claims aren't blocked the airdrop ending at expiration is optional and gov has to
    ///         manually end it.
    
    function reclaim(address destination) external onlyOwner {
        require(block.timestamp > expiration, "Not expired");
        uint256 unclaimed = token.balanceOf(address(this));
        token.transfer(destination, unclaimed);
    }

    
    
    
    
    
    function claim(
        uint256 amount,
        uint256 totalGrant,
        bytes32[] calldata merkleProof,
        address destination
    ) external virtual override {
        revert("Not Allowed to claim");
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

// 
pragma solidity ^0.8.3;

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

// 
pragma solidity ^0.8.3;



interface ILockingVault {
    
    
    
    
    function deposit(
        address fundedAccount,
        uint256 amount,
        address firstDelegation
    ) external;

    
    
    function withdraw(uint256 amount) external;

    
    function token() external returns (IERC20);
}