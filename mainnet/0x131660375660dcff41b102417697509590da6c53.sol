
pragma solidity ^0.4.23;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


interface ERC721 {
    // Required methods
    function totalSupply() external view returns (uint256 total);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function ownerOf(uint256 _tokenId) external view returns (address owner);

    function approve(address _to, uint256 _tokenId) external;

    function transfer(address _to, uint256 _tokenId) external;

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}


contract GeneScienceInterface {
    
    function isGeneScience() public pure returns (bool);

    
    
    
    
    function mixGenes(uint256 genes1, uint256 genes2, uint256 targetBlock) public returns (uint256);

    // calculate the cooldown of child pony
    function processCooldown(uint16 childGen, uint256 targetBlock) public returns (uint16);

    // calculate the result for upgrading pony
    function upgradePonyResult(uint8 unicornation, uint256 targetBlock) public returns (bool);
    
    function setMatingSeason(bool _isMatingSeason) public returns (bool);
}




interface ERC20 {
    //core ERC20 functions
    function transfer(address _to, uint _value) external returns (bool success);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address from, address to, uint256 value) external returns (bool success);

    function transferPreSigned(bytes _signature, address _to, uint256 _value, uint256 _fee, uint256 _nonce) external returns (bool);

    function recoverSigner(bytes _signature, address _to, uint256 _value, uint256 _fee, uint256 _nonce) external view returns (address);
}

/**
 * @title Signature verifier
 * @dev To verify C level actions
 */
contract SignatureVerifier {

    function splitSignature(bytes sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
        // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
        // second 32 bytes
            s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recover(bytes32 hash, bytes sig) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        //Check the signature length
        if (sig.length != 65) {
            return (address(0));
        }
        // Divide the signature in r, s and v variables
        (v, r, s) = splitSignature(sig);
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            bytes memory prefix = "\x19Ethereum Signed Message:\n32";
            bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
            return ecrecover(prefixedHash, v, r, s);
        }
    }
}

/**
 * @title A DEKLA token access control
 * @author DEKLA (https://www.dekla.io)
 * @dev The Dekla token has 3 C level address to manage.
 * They can execute special actions but it need to be approved by another C level address.
 */
contract AccessControl is SignatureVerifier {
    using SafeMath for uint256;

    // C level address that can execute special actions.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;
    address public systemAddress;
    uint256 public CLevelTxCount_ = 0;
    mapping(address => uint256) nonces;

    // @dev C level transaction must be approved with another C level address
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }


    
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    // @dev return true if transaction already signed by a C Level address
    // @param _message The string to be verify
    function signedByCLevel(
        bytes32 _message,
        bytes _sig
    )
    internal
    view
    onlyCLevel
    returns (bool)
    {
        address signer = recover(_message, _sig);
        require(signer != msg.sender);
        return (
        signer == cooAddress ||
        signer == ceoAddress ||
        signer == cfoAddress
        );
    }

    // @dev return true if transaction already signed by a C Level address
    // @param _message The string to be verify
    // @param _sig the signature from signing the _message with system key
    function signedBySystem(
        bytes32 _message,
        bytes _sig
    )
    internal
    view
    returns (bool)
    {
        address signer = recover(_message, _sig);
        require(signer != msg.sender);
        return (
        signer == systemAddress
        );
    }

    /**
     * @notice Hash (keccak256) of the payload used by setCEO
     * @param _newCEO address The address of the new CEO
     * @param _nonce uint256 setCEO transaction number.
     */
    function getCEOHashing(address _newCEO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0E94), _newCEO, _nonce));
    }

    // @dev Assigns a new address to act as the CEO. The C level transaction, must verify.
    // @param _newCEO The address of the new CEO
    // @param _sig the signature from signing the _message with CEO key
    function setCEO(
        address _newCEO,
        bytes _sig
    ) external onlyCLevel {
        require(
            _newCEO != address(0) &&
            _newCEO != cfoAddress &&
            _newCEO != cooAddress
        );

        bytes32 hashedTx = getCEOHashing(_newCEO, nonces[msg.sender]);
        require(signedByCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        ceoAddress = _newCEO;
        CLevelTxCount_++;
    }

    /**
     * @notice Hash (keccak256) of the payload used by setCFO
     * @param _newCFO address The address of the new CFO
     * @param _nonce uint256 setCFO transaction number.
     */
    function getCFOHashing(address _newCFO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0E95), _newCFO, _nonce));
    }

    // @dev Assigns a new address to act as the CFO. The C level transaction, must verify.
    // @param _newCFO The address of the new CFO
    function setCFO(
        address _newCFO,
        bytes _sig
    ) external onlyCLevel {
        require(
            _newCFO != address(0) &&
            _newCFO != ceoAddress &&
            _newCFO != cooAddress
        );

        bytes32 hashedTx = getCFOHashing(_newCFO, nonces[msg.sender]);
        require(signedByCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        cfoAddress = _newCFO;
        CLevelTxCount_++;
    }

    /**
     * @notice Hash (keccak256) of the payload used by setCOO
     * @param _newCOO address The address of the new COO
     * @param _nonce uint256 setCO transaction number.
     */
    function getCOOHashing(address _newCOO, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0E96), _newCOO, _nonce));
    }

    // @dev Assigns a new address to act as the COO. The C level transaction, must verify.
    // @param _newCOO The address of the new COO, _sig signature used to verify COO address
    // @param _sig the signature from signing the _newCOO with 1 of the C-level key
    function setCOO(
        address _newCOO,
        bytes _sig
    ) external onlyCLevel {
        require(
            _newCOO != address(0) &&
            _newCOO != ceoAddress &&
            _newCOO != cfoAddress
        );

        bytes32 hashedTx = getCOOHashing(_newCOO, nonces[msg.sender]);
        require(signedByCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        cooAddress = _newCOO;
        CLevelTxCount_++;
    }

    function getNonces(address _sender) public view returns (uint256) {
        return nonces[_sender];
    }
}



contract PonyAccessControl is AccessControl {
    
    event ContractUpgrade(address newContract);


    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;


    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    
    modifier whenPaused {
        require(paused);
        _;
    }

    
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}



contract PonyBase is PonyAccessControl {
    /*** EVENTS ***/

    
    ///  includes any time a pony is created through the giveBirth method, but it is also called
    ///  when a new gen0 pony is created.
    event Birth(address owner, uint256 ponyId, uint256 matronId, uint256 sireId, uint256 genes);

    
    ///  ownership is assigned, including births.
    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Pony {
        // The Pony's genetic code is packed into these 256-bits, the format is
        // sooper-sekret! A pony's genes never change.
        uint256 genes;

        // The timestamp from the block when this pony came into existence.
        uint64 birthTime;

        // The minimum timestamp after which this pony can engage in breeding
        // activities again. This same timestamp is used for the pregnancy
        // timer (for matrons) as well as the siring cooldown.
        uint64 cooldownEndBlock;

        // The ID of the parents of this Pony, set to 0 for gen0 ponies.
        // Note that using 32-bit unsigned integers limits us to a "mere"
        // 4 billion ponies. This number might seem small until you realize
        // that Ethereum currently has a limit of about 500 million
        // transactions per year! So, this definitely won't be a problem
        // for several years (even as Ethereum learns to scale).
        uint32 matronId;
        uint32 sireId;

        // Set to the ID of the sire pony for matrons that are pregnant,
        // zero otherwise. A non-zero value here is how we know a pony
        // is pregnant. Used to retrieve the genetic material for the new
        // pony when the birth transpires.
        uint32 matingWithId;

        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this Pony. This starts at zero
        // for gen0 ponies, and is initialized to floor(generation/2) for others.
        // Incremented by one for each successful breeding action, regardless
        // of whether this ponies is acting as matron or sire.
        uint16 cooldownIndex;

        // The "generation number" of this pony. ponies minted by the EP contract
        // for sale are called "gen0" and have a generation number of 0. The
        // generation number of all other ponies is the larger of the two generation
        // numbers of their parents, plus one.
        // (i.e. max(matron.generation, sire.generation) + 1)
        uint16 generation;

        uint16 txCount;

        uint8 unicornation;


    }

    /*** CONSTANTS ***/

    
    ///  breeding action, called "pregnancy time" for matrons and "siring cooldown"
    ///  for sires. Designed such that the cooldown roughly doubles each time a pony
    ///  is bred, encouraging owners not to just keep breeding the same pony over
    ///  and over again. Caps out at one week (a pony can breed an unbounded number
    ///  of times, and the maximum cooldown is always seven days).
    uint32[10] public cooldowns = [
    uint32(1 minutes),
    uint32(5 minutes),
    uint32(30 minutes),
    uint32(1 hours),
    uint32(4 hours),
    uint32(8 hours),
    uint32(1 days),
    uint32(2 days),
    uint32(4 days),
    uint32(7 days)
    ];

    uint8[5] public incubators = [
    uint8(5),
    uint8(10),
    uint8(15),
    uint8(20),
    uint8(25)
    ];

    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    /*** STORAGE ***/

    
    ///  of each pony is actually an index into this array. Note that ID 0 is a genesispony,
    ///  the unPony, the mythical beast that is the parent of all gen0 ponies. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, pony ID 0 is invalid... ;-)
    Pony[] ponies;

    
    ///  some valid owner address, even gen0 ponies are created with a non-zero owner.
    mapping(uint256 => address) public ponyIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping(address => uint256) ownershipTokenCount;

    
    ///  transferFrom(). Each Pony can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping(uint256 => address) public ponyIndexToApproved;

    
    ///  this Pony for siring via breedWith(). Each Pony can only have one approved
    ///  address for siring at any time. A zero value means no approval is outstanding.
    mapping(uint256 => address) public matingAllowedToAddress;

    mapping(address => bool) public hasIncubator;

    
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public saleAuction;

    
    ///  auctions. Needs to be separate from saleAuction because the actions taken on success
    ///  after a sales and siring auction are quite different.
    SiringClockAuction public siringAuction;


    BiddingClockAuction public biddingAuction;
    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of ponies is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        ponyIndexToOwner[_tokenId] = _to;
        // When creating new ponies _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // once the pony is transferred also clear sire allowances
            delete matingAllowedToAddress[_tokenId];
            // clear any previously approved ownership exchange
            delete ponyIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }

    
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Birth event
    ///  and a Transfer event.
    
    
    
    
    
    function _createPony(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _genes,
        address _owner,
        uint16 _cooldownIndex
    )
    internal
    returns (uint)
    {
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createPony() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        require(_matronId == uint256(uint32(_matronId)));
        require(_sireId == uint256(uint32(_sireId)));
        require(_generation == uint256(uint16(_generation)));


        Pony memory _pony = Pony({
            genes : _genes,
            birthTime : uint64(now),
            cooldownEndBlock : 0,
            matronId : uint32(_matronId),
            sireId : uint32(_sireId),
            matingWithId : 0,
            cooldownIndex : _cooldownIndex,
            generation : uint16(_generation),
            unicornation : 0,
            txCount : 0
            });
        uint256 newPonyId = ponies.push(_pony) - 1;

        require(newPonyId == uint256(uint32(newPonyId)));

        // emit the birth event
        emit Birth(
            _owner,
            newPonyId,
            uint256(_pony.matronId),
            uint256(_pony.sireId),
            _pony.genes
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newPonyId);

        return newPonyId;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }
}





///  See the PonyCore contract documentation to understand how the various contract facets are arranged.
contract PonyOwnership is PonyBase, ERC721 {

    
    string public constant name = "EtherPonies";
    string public constant symbol = "EP";

    bytes4 constant InterfaceSignature_ERC165 =
    bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('tokensOfOwner(address)')) ^
    bytes4(keccak256('tokenMetadata(uint256,string)'));

    
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return ponyIndexToOwner[_tokenId] == _claimant;
    }

    
    
    
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return ponyIndexToApproved[_tokenId] == _claimant;
    }

    
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Ponies on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        ponyIndexToApproved[_tokenId] = _approved;
    }

    
    
    
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  EtherPonies specifically) or your Pony may be lost forever. Seriously.
    
    
    
    function transfer(
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any ponies (except very briefly
        // after a gen0 pony is created and before it goes on auction).
        require(_to != address(this));


        // You can only send your own pony.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    
    ///  clear all approvals.
    
    
    function approve(
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }

    
    ///  has previously been granted transfer approval by the owner.
    
    
    ///  including the caller.
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any Ponies (except very briefly
        // after a gen0 pony is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    
    
    function totalSupply() public view returns (uint) {
        return ponies.length - 1;
    }

    
    
    function ownerOf(uint256 _tokenId)
    external
    view
    returns (address owner)
    {
        owner = ponyIndexToOwner[_tokenId];

    }

    
    
    
    ///  expensive (it walks the entire Pony array looking for ponies belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns (uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalPonies = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all ponies have IDs starting at 1 and increasing
            // sequentially up to the totalPony count.
            uint256 ponyId;

            for (ponyId = 1; ponyId <= totalPonies; ponyId++) {
                if (ponyIndexToOwner[ponyId] == _owner) {
                    result[resultIndex] = ponyId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    function transferPreSignedHashing(
        address _token,
        address _to,
        uint256 _id,
        uint256 _nonce
    )
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(bytes4(0x486A0E97), _token, _to, _id, _nonce));
    }

    function transferPreSigned(
        bytes _signature,
        address _to,
        uint256 _id,
        uint256 _nonce
    )
    public
    {
        require(_to != address(0));
        // require(signatures[_signature] == false);
        bytes32 hashedTx = transferPreSignedHashing(address(this), _to, _id, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));
        require(_to != address(this));

        // You can only send your own pony.
        require(_owns(from, _id));
        nonces[from]++;
        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(from, _to, _id);
    }

    function approvePreSignedHashing(
        address _token,
        address _spender,
        uint256 _tokenId,
        uint256 _nonce
    )
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_token, _spender, _tokenId, _nonce));
    }

    function approvePreSigned(
        bytes _signature,
        address _spender,
        uint256 _tokenId,
        uint256 _nonce
    )
    public
    returns (bool)
    {
        require(_spender != address(0));
        // require(signatures[_signature] == false);
        bytes32 hashedTx = approvePreSignedHashing(address(this), _spender, _tokenId, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0));

        // Only an owner can grant transfer approval.
        require(_owns(from, _tokenId));

        nonces[from]++;
        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _spender);

        // Emit approval event.
        emit Approval(from, _spender, _tokenId);
        return true;
    }
}






contract PonyBreeding is PonyOwnership {

    
    ///  timer begins for the matron.
    event Pregnant(address owner, uint256 matronId, uint256 sireId, uint256 cooldownEndBlock);

    
    ///  the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public autoBirthFee = 2 finney;

    // Keeps track of number of pregnant Ponies.
    uint256 public pregnantPonies;

    
    ///  genetic combination algorithm.
    GeneScienceInterface public geneScience;

    
    
    function setGeneScienceAddress(address _address) external onlyCEO {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isGeneScience());

        // Set the new contract address
        geneScience = candidateContract;
    }

    
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function _isReadyToMate(Pony _pon) internal view returns (bool) {
        // In addition to checking the cooldownEndBlock, we also need to check to see if
        // the pony has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_pon.matingWithId == 0) && (_pon.cooldownEndBlock <= uint64(block.number));
    }

    
    ///  and matron have the same owner, or if the sire has given siring permission to
    ///  the matron's owner (via approveSiring()).
    function _isMatingPermitted(uint256 _sireId, uint256 _matronId) internal view returns (bool) {
        address matronOwner = ponyIndexToOwner[_matronId];
        address sireOwner = ponyIndexToOwner[_sireId];

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (matronOwner == sireOwner || matingAllowedToAddress[_sireId] == matronOwner);
    }

    
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    
    function _triggerCooldown(Pony storage _pony) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
        _pony.cooldownEndBlock = uint64((cooldowns[_pony.cooldownIndex] / secondsPerBlock) + block.number);

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_pony.cooldownIndex < 13) {
            _pony.cooldownIndex += 1;
        }
    }

    function _triggerPregnant(Pony storage _pony, uint8 _incubator) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).

        if (_incubator > 0) {
            uint64 initialCooldown = uint64(cooldowns[_pony.cooldownIndex] / secondsPerBlock);
            _pony.cooldownEndBlock = uint64((initialCooldown - (initialCooldown * incubators[_incubator] / 100)) + block.number);

        } else {
            _pony.cooldownEndBlock = uint64((cooldowns[_pony.cooldownIndex] / secondsPerBlock) + block.number);
        }
        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_pony.cooldownIndex < 13) {
            _pony.cooldownIndex += 1;
        }
    }

    
    
    ///  address(0) to clear all siring approvals for this Pony.
    
    function approveSiring(address _addr, uint256 _sireId)
    external
    whenNotPaused
    {
        require(_owns(msg.sender, _sireId));
        matingAllowedToAddress[_sireId] = _addr;
    }

    
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred
    ///  by the autobirth daemon).
    function setAutoBirthFee(uint256 val) external onlyCOO {
        autoBirthFee = val;
    }

    
    ///  period has passed.
    function _isReadyToGiveBirth(Pony _matron) private view returns (bool) {
        return (_matron.matingWithId != 0) && (_matron.cooldownEndBlock <= uint64(block.number));
    }

    
    ///  in the middle of a siring cooldown).
    
    function isReadyToMate(uint256 _ponyId)
    public
    view
    returns (bool)
    {
        require(_ponyId > 0);
        Pony storage pon = ponies[_ponyId];
        return _isReadyToMate(pon);
    }

    
    
    function isPregnant(uint256 _ponyId)
    public
    view
    returns (bool)
    {
        require(_ponyId > 0);
        // A Pony is pregnant if and only if this field is set
        return ponies[_ponyId].matingWithId != 0;
    }

    
    ///  check ownership permissions (that is up to the caller).
    
    
    
    
    function _isValidMatingPair(
        Pony storage _matron,
        uint256 _matronId,
        Pony storage _sire,
        uint256 _sireId
    )
    private
    view
    returns (bool)
    {
        // A Pony can't breed with itself!
        if (_matronId == _sireId) {
            return false;
        }

        // Ponies can't breed with their parents.
        if (_matron.matronId == _sireId || _matron.sireId == _sireId) {
            return false;
        }
        if (_sire.matronId == _matronId || _sire.sireId == _matronId) {
            return false;
        }

        // We can short circuit the sibling check (below) if either pony is
        // gen zero (has a matron ID of zero).
        if (_sire.matronId == 0 || _matron.matronId == 0) {
            return true;
        }

        // Ponies can't breed with full or half siblings.
        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function canMateWithViaAuction(uint256 _matronId, uint256 _sireId)
    public
    view
    returns (bool)
    {
        Pony storage matron = ponies[_matronId];
        Pony storage sire = ponies[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId);
    }

    
    ///  ownership and siring approvals. Does NOT check that both ponies are ready for
    ///  breeding (i.e. breedWith could still fail until the cooldowns are finished).
    ///  TODO: Shouldn't this check pregnancy and cooldowns?!?
    
    
    function canMateWith(uint256 _matronId, uint256 _sireId)
    external
    view
    returns (bool)
    {
        require(_matronId > 0);
        require(_sireId > 0);
        Pony storage matron = ponies[_matronId];
        Pony storage sire = ponies[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId) &&
        _isMatingPermitted(_sireId, _matronId);
    }

    
    ///  requirements have been checked.
    function _mateWith(uint256 _matronId, uint256 _sireId, uint8 _incubator) internal {
        // Grab a reference to the Ponies from storage.
        Pony storage sire = ponies[_sireId];
        Pony storage matron = ponies[_matronId];

        // Mark the matron as pregnant, keeping track of who the sire is.
        matron.matingWithId = uint32(_sireId);

        // Trigger the cooldown for both parents.
        _triggerCooldown(sire);
        _triggerPregnant(matron, _incubator);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete matingAllowedToAddress[_matronId];
        delete matingAllowedToAddress[_sireId];

        // Every time a Pony gets pregnant, counter is incremented.
        pregnantPonies++;

        // Emit the pregnancy event.

        emit Pregnant(ponyIndexToOwner[_matronId], _matronId, _sireId, matron.cooldownEndBlock);
    }

    function getIncubatorHashing(
        address _sender,
        uint8 _incubator,
        uint256 txCount
    )
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(bytes4(0x486A0E98), _sender, _incubator, txCount));
    }

    
    ///  have previously been given Siring approval. Will either make your pony pregnant, or will
    ///  fail entirely. Requires a pre-payment of the fee given out to the first caller of giveBirth()
    
    
    function mateWithAuto(uint256 _matronId, uint256 _sireId, uint8 _incubator, bytes _sig)
    external
    payable
    whenNotPaused
    {
        // Checks for payment.
        require(msg.value >= autoBirthFee);

        // Caller must own the matron.
        require(_owns(msg.sender, _matronId));

        require(_isMatingPermitted(_sireId, _matronId));

        // Grab a reference to the potential matron
        Pony storage matron = ponies[_matronId];

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToMate(matron));

        // Grab a reference to the potential sire
        Pony storage sire = ponies[_sireId];

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToMate(sire));

        // Test that these ponies are a valid mating pair.
        require(
            _isValidMatingPair(matron, _matronId, sire, _sireId)
        );

        if (_incubator == 0 && hasIncubator[msg.sender]) {
            _mateWith(_matronId, _sireId, _incubator);
        } else {
            bytes32 hashedTx = getIncubatorHashing(msg.sender, _incubator, nonces[msg.sender]);
            require(signedBySystem(hashedTx, _sig));
            nonces[msg.sender]++;

            // All checks passed, Pony gets pregnant!
            if (!hasIncubator[msg.sender]) {
                hasIncubator[msg.sender] = true;
            }
            _mateWith(_matronId, _sireId, _incubator);
        }
    }

    
    
    
    
    ///  combines the genes of the two parents to create a new pony. The new Pony is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the
    ///  new pony will be ready to breed again. Note that anyone can call this function (if they
    ///  are willing to pay the gas!), but the new pony always goes to the mother's owner.
    function giveBirth(uint256 _matronId)
    external
    whenNotPaused
    returns (uint256)
    {
        // Grab a reference to the matron in storage.
        Pony storage matron = ponies[_matronId];

        // Check that the matron is a valid pony.
        require(matron.birthTime != 0);

        // Check that the matron is pregnant, and that its time has come!
        require(_isReadyToGiveBirth(matron));

        // Grab a reference to the sire in storage.
        uint256 sireId = matron.matingWithId;
        Pony storage sire = ponies[sireId];

        // Determine the higher generation number of the two parents
        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }

        // Call the sooper-sekret gene mixing operation.
        uint256 childGenes = geneScience.mixGenes(matron.genes, sire.genes, matron.cooldownEndBlock - 1);
        // New Pony starts with the same cooldown as parent gen/20
        uint16 cooldownIndex = geneScience.processCooldown(parentGen + 1, block.number);
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }
        // Make the new pony!
        address owner = ponyIndexToOwner[_matronId];
        uint256 ponyId = _createPony(_matronId, matron.matingWithId, parentGen + 1, childGenes, owner, cooldownIndex);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete matron.matingWithId;

        // Every time a Pony gives birth counter is decremented.
        pregnantPonies--;

        // Send the balance fee to the person who made birth happen.
        msg.sender.transfer(autoBirthFee);

        // return the new pony's ID
        return ponyId;
    }
    
    function  setMatingSeason(bool _isMatingSeason) external onlyCLevel {
        geneScience.setMatingSeason(_isMatingSeason);
    }
}





contract ClockAuctionBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address seller;
        uint256 price;
        bool allowPayDekla;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;

    ERC20 public tokens;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut = 500;

    // Map from token ID to their corresponding auction.
    mapping(uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    
    /// Throws if the escrow fails.
    
    
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }

    
    /// Returns true if the transfer succeeds.
    
    
    function _transfer(address _receiver, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transfer(_receiver, _tokenId);
    }

    
    ///  AuctionCreated event.
    
    
    function _addAuction(uint256 _tokenId, Auction _auction) internal {

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(
            uint256(_tokenId)
        );
    }


    
    /// Does NOT transfer ownership of token.
    function _bidEth(uint256 _tokenId, uint256 _bidAmount)
    internal
    returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(!auction.allowPayDekla);
        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        // Check that the bid is greater than or equal to the current price
        uint256 price = auction.price;
        require(_bidAmount >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

            seller.transfer(sellerProceeds);
        }

        // Tell the world!
        emit AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }

    
    /// Does NOT transfer ownership of token.
    function _bidDkl(uint256 _tokenId, uint256 _bidAmount)
    internal
    returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(auction.allowPayDekla);
        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        // Check that the bid is greater than or equal to the current price
        uint256 price = auction.price;
        require(_bidAmount >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

            tokens.transfer(seller, sellerProceeds);
        }
        // Tell the world!
        emit AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }


    
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        emit AuctionCancelled(_tokenId);
    }

    
    
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.price > 0);
    }

    
    
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }



    
    
    function _computeCut(uint256 _price) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _price * ownerCut / 10000;
    }

}







/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is AccessControl{
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyCEO whenNotPaused public returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyCEO whenPaused public returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}




contract ClockAuction is Pausable, ClockAuctionBase {

    
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

    
    ///  and verifies the owner cut is in the valid range.
    
    ///  the Nonfungible Interface.
    constructor(address _nftAddress, address _tokenAddress) public {
        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        tokens = ERC20(_tokenAddress);
        nonFungibleContract = candidateContract;
    }


    
    ///  Returns the NFT to original owner.
    
    ///  be called while the contract is paused.
    
    function cancelAuction(uint256 _tokenId)
    external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    
    function cancelAuctionWhenPaused(uint256 _tokenId)
    whenPaused
    onlyCEO
    external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        _cancelAuction(_tokenId, auction.seller);
    }

    
    
    function getAuction(uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        uint256 price,
        bool allowPayDekla

    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        return (
        auction.seller,
        auction.price,
        auction.allowPayDekla
        );
    }

    
    
    function getCurrentPrice(uint256 _tokenId)
    external
    view
    returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return auction.price;
    }

}




contract SiringClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSiringAuctionAddress() call.
    bool public isSiringClockAuction = true;

    uint256 public prizeCut = 100;

    uint256 public tokenDiscount = 100;

    address prizeAddress;

    // Delegate constructor
    constructor(address _nftAddr, address _tokenAddress, address _prizeAddress) public
    ClockAuction(_nftAddr, _tokenAddress) {
        prizeAddress = _prizeAddress;
    }

    
    /// require sender to be PonyCore contract.
    
    
    function createEthAuction(
        uint256 _tokenId,
        address _seller,
        uint256 _price
    )
    external
    {

        require(msg.sender == address(nonFungibleContract));
        require(_price > 0);
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            _price,
            false
        );
        _addAuction(_tokenId, auction);
    }

    
    /// require sender to be PonyCore contract.
    
    
    function createDklAuction(
        uint256 _tokenId,
        address _seller,
        uint256 _price
    )
    external
    {

        require(msg.sender == address(nonFungibleContract));
        require(_price > 0);
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            _price,
            true
        );
        _addAuction(_tokenId, auction);
    }

    
    /// is the PonyCore contract because all bid methods
    /// should be wrapped. Also returns the pony to the
    /// seller rather than the winner.
    function bidEth(uint256 _tokenId)
    external
    payable
    {
        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        // _bid checks that token ID is valid and will throw if bid fails
        _bidEth(_tokenId, msg.value);
        // We transfer the pony back to the seller, the winner will get
        // the offspring

        uint256 prizeAmount = (msg.value * prizeCut) / 10000;
        prizeAddress.transfer(prizeAmount);

        _transfer(seller, _tokenId);
    }


    function bidDkl(uint256 _tokenId,
        uint256 _price,
        uint256 _fee,
        bytes _signature,
        uint256 _nonce)
    external
    whenNotPaused
    {
        address seller = tokenIdToAuction[_tokenId].seller;
        tokens.transferPreSigned(_signature, address(this), _price, _fee, _nonce);
        // _bid will throw if the bid or funds transfer fails
        _bidDkl(_tokenId, _price);
        tokens.transfer(msg.sender, _fee);
        address spender = tokens.recoverSigner(_signature, address(this), _price, _fee, _nonce);
        uint256 discountAmount = (_price * tokenDiscount) / 10000;
        uint256 prizeAmount = (_price * prizeCut) / 10000;
        tokens.transfer(prizeAddress, prizeAmount);
        tokens.transfer(spender, discountAmount);
        _transfer(seller, _tokenId);
    }

    function setCut(uint256 _prizeCut, uint256 _tokenDiscount)
    external
    {
        require(msg.sender == address(nonFungibleContract));
        require(_prizeCut + _tokenDiscount < ownerCut);

        prizeCut = _prizeCut;
        tokenDiscount = _tokenDiscount;
    }

    
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == nftAddress
        );

        nftAddress.transfer(address(this).balance);
    }

    function withdrawDklBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == nftAddress
        );

        tokens.transfer(nftAddress, tokens.balanceOf(this));
    }
}







contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public isSaleClockAuction = true;

    uint256 public prizeCut = 100;

    uint256 public tokenDiscount = 100;

    address prizeAddress;

    // Tracks last 5 sale price of gen0 Pony sales
    uint256 public gen0SaleCount;
    uint256[5] public lastGen0SalePrices;

    // Delegate constructor
    constructor(address _nftAddr, address _token, address _prizeAddress) public
    ClockAuction(_nftAddr, _token) {
        prizeAddress = _prizeAddress;
    }

    
    
    
    function createEthAuction(
        uint256 _tokenId,
        address _seller,
        uint256 _price
    )
    external
    {

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            _price,
            false
        );
        _addAuction(_tokenId, auction);
    }

    
    
    
    function createDklAuction(
        uint256 _tokenId,
        address _seller,
        uint256 _price
    )
    external
    {

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            _price,
            true
        );
        _addAuction(_tokenId, auction);
    }


    function bidEth(uint256 _tokenId)
    external
    payable
    whenNotPaused
    {
        // _bid will throw if the bid or funds transfer fails
        _bidEth(_tokenId, msg.value);
        uint256 prizeAmount = (msg.value * prizeCut) / 10000;
        prizeAddress.transfer(prizeAmount);
        _transfer(msg.sender, _tokenId);
    }


    function bidDkl(uint256 _tokenId,
        uint256 _price,
        uint256 _fee,
        bytes _signature,
        uint256 _nonce)
    external
    whenNotPaused
    {
        address buyer = tokens.recoverSigner(_signature, address(this), _price, _fee, _nonce);
        tokens.transferPreSigned(_signature, address(this), _price, _fee, _nonce);
        // _bid will throw if the bid or funds transfer fails
        _bidDkl(_tokenId, _price);
        uint256 prizeAmount = (_price * prizeCut) / 10000;
        uint256 discountAmount = (_price * tokenDiscount) / 10000;
        tokens.transfer(buyer, discountAmount);
        tokens.transfer(prizeAddress, prizeAmount);
        _transfer(buyer, _tokenId);
    }

    function setCut(uint256 _prizeCut, uint256 _tokenDiscount)
    external
    {
        require(msg.sender == address(nonFungibleContract));
        require(_prizeCut + _tokenDiscount < ownerCut);

        prizeCut = _prizeCut;
        tokenDiscount = _tokenDiscount;
    }

    
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == nftAddress
        );

        nftAddress.transfer(address(this).balance);
    }

    function withdrawDklBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == nftAddress
        );

        tokens.transfer(nftAddress, tokens.balanceOf(this));
    }
}



///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract PonyAuction is PonyBreeding {

    // @notice The auction contract variables are defined in PonyBase to allow
    //  us to refer to them in PonyOwnership to prevent accidental transfers.
    // `saleAuction` refers to the auction for gen0 and p2p sale of Ponies.
    // `siringAuction` refers to the auction for siring rights of Ponies.

    
    
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }

    
    
    function setSiringAuctionAddress(address _address) external onlyCEO {
        SiringClockAuction candidateContract = SiringClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSiringClockAuction());

        // Set the new contract address
        siringAuction = candidateContract;
    }

    
    
    function setBiddingAuctionAddress(address _address) external onlyCEO {
        BiddingClockAuction candidateContract = BiddingClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isBiddingClockAuction());

        // Set the new contract address
        biddingAuction = candidateContract;
    }


    
    ///  Does some ownership trickery to create auctions in one tx.
    function createEthSaleAuction(
        uint256 _PonyId,
        uint256 _price
    )
    external
    whenNotPaused
    {
        // Auction contract checks input sizes
        // If Pony is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _PonyId));
        // Ensure the Pony is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the Pony IS allowed to be in a cooldown.
        require(!isPregnant(_PonyId));
        _approve(_PonyId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Pony.
        saleAuction.createEthAuction(
            _PonyId,
            msg.sender,
            _price
        );
    }


    
    ///  Does some ownership trickery to create auctions in one tx.
    function delegateDklSaleAuction(
        uint256 _tokenId,
        uint256 _price,
        bytes _ponySig,
        uint256 _nonce
    )
    external
    whenNotPaused
    {
        bytes32 hashedTx = approvePreSignedHashing(address(this), saleAuction, _tokenId, _nonce);
        address from = recover(hashedTx, _ponySig);
        // Auction contract checks input sizes
        // If Pony is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(from, _tokenId));
        // Ensure the Pony is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the Pony IS allowed to be in a cooldown.
        require(!isPregnant(_tokenId));
        approvePreSigned(_ponySig, saleAuction, _tokenId, _nonce);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Pony.
        saleAuction.createDklAuction(
            _tokenId,
            from,
            _price
        );
    }


    
    ///  Does some ownership trickery to create auctions in one tx.
    function delegateDklSiringAuction(
        uint256 _tokenId,
        uint256 _price,
        bytes _ponySig,
        uint256 _nonce
    )
    external
    whenNotPaused
    {
        bytes32 hashedTx = approvePreSignedHashing(address(this), siringAuction, _tokenId, _nonce);
        address from = recover(hashedTx, _ponySig);
        // Auction contract checks input sizes
        // If Pony is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(from, _tokenId));
        // Ensure the Pony is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the Pony IS allowed to be in a cooldown.
        require(!isPregnant(_tokenId));
        approvePreSigned(_ponySig, siringAuction, _tokenId, _nonce);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Pony.
        siringAuction.createDklAuction(
            _tokenId,
            from,
            _price
        );
    }

    
    ///  Does some ownership trickery to create auctions in one tx.
    function delegateDklBidAuction(
        uint256 _tokenId,
        uint256 _price,
        bytes _ponySig,
        uint256 _nonce,
        uint16 _durationIndex
    )
    external
    whenNotPaused
    {
        bytes32 hashedTx = approvePreSignedHashing(address(this), biddingAuction, _tokenId, _nonce);
        address from = recover(hashedTx, _ponySig);
        // Auction contract checks input sizes
        // If Pony is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(from, _tokenId));
        // Ensure the Pony is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the Pony IS allowed to be in a cooldown.
        require(!isPregnant(_tokenId));
        approvePreSigned(_ponySig, biddingAuction, _tokenId, _nonce);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Pony.
        biddingAuction.createDklAuction(_tokenId, from, _durationIndex, _price);
    }


    
    ///  Performs checks to ensure the Pony can be sired, then
    ///  delegates to reverse auction.
    function createEthSiringAuction(
        uint256 _PonyId,
        uint256 _price
    )
    external
    whenNotPaused
    {
        // Auction contract checks input sizes
        // If Pony is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _PonyId));
        require(isReadyToMate(_PonyId));
        _approve(_PonyId, siringAuction);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Pony.
        siringAuction.createEthAuction(
            _PonyId,
            msg.sender,
            _price
        );
    }

    
    ///  Does some ownership trickery to create auctions in one tx.
    function createDklSaleAuction(
        uint256 _PonyId,
        uint256 _price
    )
    external
    whenNotPaused
    {
        // Auction contract checks input sizes
        // If Pony is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _PonyId));
        // Ensure the Pony is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the Pony IS allowed to be in a cooldown.
        require(!isPregnant(_PonyId));
        _approve(_PonyId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Pony.
        saleAuction.createDklAuction(
            _PonyId,
            msg.sender,
            _price
        );
    }

    
    ///  Performs checks to ensure the Pony can be sired, then
    ///  delegates to reverse auction.
    function createDklSiringAuction(
        uint256 _PonyId,
        uint256 _price
    )
    external
    whenNotPaused
    {
        // Auction contract checks input sizes
        // If Pony is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _PonyId));
        require(isReadyToMate(_PonyId));
        _approve(_PonyId, siringAuction);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Pony.
        siringAuction.createDklAuction(
            _PonyId,
            msg.sender,
            _price
        );
    }

    function createEthBidAuction(
        uint256 _ponyId,
        uint256 _price,
        uint16 _durationIndex
    ) external whenNotPaused {
        require(_owns(msg.sender, _ponyId));
        _approve(_ponyId, biddingAuction);
        biddingAuction.createETHAuction(_ponyId, msg.sender, _durationIndex, _price);
    }

    function createDeklaBidAuction(
        uint256 _ponyId,
        uint256 _price,
        uint16 _durationIndex
    ) external whenNotPaused {
        require(_owns(msg.sender, _ponyId));
        _approve(_ponyId, biddingAuction);
        biddingAuction.createDklAuction(_ponyId, msg.sender, _durationIndex, _price);
    }

    
    ///  Immediately breeds the winning matron with the sire on auction.
    
    
    function bidOnEthSiringAuction(
        uint256 _sireId,
        uint256 _matronId,
        uint8 _incubator,
        bytes _sig
    )
    external
    payable
    whenNotPaused
    {
        // Auction contract checks input sizes
        require(_owns(msg.sender, _matronId));
        require(isReadyToMate(_matronId));
        require(canMateWithViaAuction(_matronId, _sireId));

        // Define the current price of the auction.
        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= currentPrice + autoBirthFee);

        // Siring auction will throw if the bid fails.
        siringAuction.bidEth.value(msg.value - autoBirthFee)(_sireId);
        if (_incubator == 0 && hasIncubator[msg.sender]) {
            _mateWith(_matronId, _sireId, _incubator);
        } else {
            bytes32 hashedTx = getIncubatorHashing(msg.sender, _incubator, nonces[msg.sender]);
            require(signedBySystem(hashedTx, _sig));
            nonces[msg.sender]++;

            // All checks passed, Pony gets pregnant!
            if (!hasIncubator[msg.sender]) {
                hasIncubator[msg.sender] = true;
            }
            _mateWith(_matronId, _sireId, _incubator);
        }
    }

    
    ///  Immediately breeds the winning matron with the sire on auction.
    
    
    function bidOnDklSiringAuction(
        uint256 _sireId,
        uint256 _matronId,
        uint8 _incubator,
        bytes _incubatorSig,
        uint256 _price,
        uint256 _fee,
        bytes _delegateSig,
        uint256 _nonce

    )
    external
    payable
    whenNotPaused
    {
        // Auction contract checks input sizes
        require(_owns(msg.sender, _matronId));
        require(isReadyToMate(_matronId));
        require(canMateWithViaAuction(_matronId, _sireId));

        // Define the current price of the auction.
        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= autoBirthFee);
        require(_price >= currentPrice);

        // Siring auction will throw if the bid fails.
        siringAuction.bidDkl(_sireId, _price, _fee, _delegateSig, _nonce);
        if (_incubator == 0 && hasIncubator[msg.sender]) {
            _mateWith(_matronId, _sireId, _incubator);
        } else {
            bytes32 hashedTx = getIncubatorHashing(msg.sender, _incubator, nonces[msg.sender]);
            require(signedBySystem(hashedTx, _incubatorSig));
            nonces[msg.sender]++;

            // All checks passed, Pony gets pregnant!
            if (!hasIncubator[msg.sender]) {
                hasIncubator[msg.sender] = true;
            }
            _mateWith(_matronId, _sireId, _incubator);
        }
    }

    
    /// to the PonyCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
        siringAuction.withdrawBalance();
        biddingAuction.withdrawBalance();
    }

    function withdrawAuctionDklBalance() external onlyCLevel {
        saleAuction.withdrawDklBalance();
        siringAuction.withdrawDklBalance();
        biddingAuction.withdrawDklBalance();
    }


    function setBiddingRate(uint256 _prizeCut, uint256 _tokenDiscount) external onlyCLevel {
        biddingAuction.setCut(_prizeCut, _tokenDiscount);
    }

    function setSaleRate(uint256 _prizeCut, uint256 _tokenDiscount) external onlyCLevel {
        saleAuction.setCut(_prizeCut, _tokenDiscount);
    }

    function setSiringRate(uint256 _prizeCut, uint256 _tokenDiscount) external onlyCLevel {
        siringAuction.setCut(_prizeCut, _tokenDiscount);
    }
}




contract BiddingAuctionBase {
    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address seller;
        // Duration (in seconds) of auction
        uint16 durationIndex;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;

        uint64 auctionEndBlock;
        // Price (in wei) at beginning of auction
        uint256 startingPrice;

        bool allowPayDekla;
    }

    uint32[4] public auctionDuration = [
    //production
     uint32(2 days),
     uint32(3 days),
     uint32(4 days),
     uint32(5 days)
    ];

    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;


    uint256 public ownerCut = 500;

    // Map from token ID to their corresponding auction.
    mapping(uint256 => Auction) public tokenIdToAuction;

    event AuctionCreated(uint256 tokenId);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    
    /// Throws if the escrow fails.
    
    
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }

    
    /// Returns true if the transfer succeeds.
    
    
    function _transfer(address _receiver, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transfer(_receiver, _tokenId);
    }

    
    ///  AuctionCreated event.
    
    
    function _addAuction(uint256 _tokenId, Auction _auction) internal {

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(
            uint256(_tokenId)
        );
    }

    
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        emit AuctionCancelled(_tokenId);
    }


    
    
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }



    
    
    function _computeCut(uint256 _price) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _price * ownerCut / 10000;
    }

}




contract BiddingAuction is Pausable, BiddingAuctionBase {
    
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);



    
    ///  and verifies the owner cut is in the valid range.
    
    ///  the Nonfungible Interface.
    constructor(address _nftAddress) public {

        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        nonFungibleContract = candidateContract;
    }

    function cancelAuctionHashing(
        uint256 _tokenId,
        uint64 _endblock
    )
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(bytes4(0x486A0E9E), _tokenId, _endblock));
    }

    
    ///  Returns the NFT to original owner.
    
    ///  be called while the contract is paused.
    
    function cancelAuction(
        uint256 _tokenId,
        bytes _sig
    )
    external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        address seller = auction.seller;
        uint64 endblock = auction.auctionEndBlock;
        require(msg.sender == seller);
        require(endblock < block.number);

        bytes32 hashedTx = cancelAuctionHashing(_tokenId, endblock);
        require(signedBySystem(hashedTx, _sig));

        _cancelAuction(_tokenId, seller);
    }

    
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    
    function cancelAuctionWhenPaused(uint256 _tokenId)
    whenPaused
    onlyCLevel
    external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        _cancelAuction(_tokenId, auction.seller);
    }

    
    
    function getAuction(uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        uint64 startedAt,
        uint16 durationIndex,
        uint64 auctionEndBlock,
        uint256 startingPrice,
        bool allowPayDekla
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        return (
        auction.seller,
        auction.startedAt,
        auction.durationIndex,
        auction.auctionEndBlock,
        auction.startingPrice,
        auction.allowPayDekla
        );
    }

    function setSecondsPerBlock(uint256 secs) external onlyCEO {
        secondsPerBlock = secs;
    }

}


contract BiddingWallet is AccessControl {

    //user balances is stored in this balances map and could be withdraw by owner at anytime
    mapping(address => uint) public EthBalances;

    mapping(address => uint) public DeklaBalances;

    ERC20 public tokens;

    //the limit of deposit and withdraw the minimum amount you can deposit is 0.05 eth
    //you also have to have at least 0.05 eth
    uint public EthLimit = 50000000000000000;
    uint public DeklaLimit = 100;

    uint256 public totalEthDeposit;
    uint256 public totalDklDeposit;

    event withdrawSuccess(address receiver, uint amount);
    event cancelPendingWithdrawSuccess(address sender);

    function getNonces(address _address) public view returns (uint256) {
        return nonces[_address];
    }

    function setSystemAddress(address _systemAddress, address _tokenAddress) internal {
        systemAddress = _systemAddress;
        tokens = ERC20(_tokenAddress);
    }

    //user will be assign an equivalent amount of bidding credit to bid
    function depositETH() payable external {
        require(msg.value >= EthLimit);
        EthBalances[msg.sender] = EthBalances[msg.sender] + msg.value;
        totalEthDeposit = totalEthDeposit + msg.value;
    }

    function depositDekla(
        uint256 _amount,
        uint256 _fee,
        bytes _signature,
        uint256 _nonce)
    external {
        address sender = tokens.recoverSigner(_signature, address(this), _amount, _fee, _nonce);
        tokens.transferPreSigned(_signature, address(this), _amount, _fee, _nonce);
        DeklaBalances[sender] = DeklaBalances[sender] + _amount;
        totalDklDeposit = totalDklDeposit + _amount;
    }


    function withdrawAmountHashing(uint256 _amount, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0E9B), _amount, _nonce));
    }

    // Withdraw all available eth back to user wallet, need co-verify
    function withdrawEth(
        uint256 _amount,
        bytes _sig
    ) external {
        require(EthBalances[msg.sender] >= _amount);

        bytes32 hashedTx = withdrawAmountHashing(_amount, nonces[msg.sender]);
        require(signedBySystem(hashedTx, _sig));

        EthBalances[msg.sender] = EthBalances[msg.sender] - _amount;
        totalEthDeposit = totalEthDeposit - _amount;
        msg.sender.transfer(_amount);

        nonces[msg.sender]++;
        emit withdrawSuccess(msg.sender, _amount);
    }

    // Withdraw all available dekla back to user wallet, need co-verify
    function withdrawDekla(
        uint256 _amount,
        bytes _sig
    ) external {
        require(DeklaBalances[msg.sender] >= _amount);

        bytes32 hashedTx = withdrawAmountHashing(_amount, nonces[msg.sender]);
        require(signedBySystem(hashedTx, _sig));

        DeklaBalances[msg.sender] = DeklaBalances[msg.sender] - _amount;
        totalDklDeposit = totalDklDeposit - _amount;
        tokens.transfer(msg.sender, _amount);

        nonces[msg.sender]++;
        emit withdrawSuccess(msg.sender, _amount);
    }


    event valueLogger(uint256 value);
    //bidding success tranfer eth to seller wallet
    function winBidEth(
        address winner,
        address seller,
        uint256 sellerProceeds,
        uint256 auctioneerCut
    ) internal {
        require(EthBalances[winner] >= sellerProceeds + auctioneerCut);
        seller.transfer(sellerProceeds);
        EthBalances[winner] = EthBalances[winner] - (sellerProceeds + auctioneerCut);
    }

    //bidding success tranfer eth to seller wallet
    function winBidDekla(
        address winner,
        address seller,
        uint256 sellerProceeds,
        uint256 auctioneerCut
    ) internal {
        require(DeklaBalances[winner] >= sellerProceeds + auctioneerCut);
        tokens.transfer(seller, sellerProceeds);
        DeklaBalances[winner] = DeklaBalances[winner] - (sellerProceeds + auctioneerCut);
    }

    function() public {
        revert();
    }
}




contract BiddingClockAuction is BiddingAuction, BiddingWallet {

    address public prizeAddress;

    uint256 public prizeCut = 100;

    uint256 public tokenDiscount = 100;
    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSiringAuctionAddress() call.
    bool public isBiddingClockAuction = true;

    modifier onlySystem() {
        require(msg.sender == systemAddress);
        _;
    }

    // Delegate constructor
    constructor(
        address _nftAddr,
        address _tokenAddress,
        address _prizeAddress,
        address _systemAddress,
        address _ceoAddress,
        address _cfoAddress,
        address _cooAddress)
    public
    BiddingAuction(_nftAddr) {
        // validate address
        require(_systemAddress != address(0));
        require(_tokenAddress != address(0));
        require(_ceoAddress != address(0));
        require(_cooAddress != address(0));
        require(_cfoAddress != address(0));
        require(_prizeAddress != address(0));

        setSystemAddress(_systemAddress, _tokenAddress);

        ceoAddress = _ceoAddress;
        cooAddress = _cooAddress;
        cfoAddress = _cfoAddress;
        prizeAddress = _prizeAddress;
    }


    
    /// require sender to be PonyCore contract.
    function createETHAuction(
        uint256 _tokenId,
        address _seller,
        uint16 _durationIndex,
        uint256 _startingPrice
    )
    external
    {
        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        uint64 auctionEndBlock = uint64((auctionDuration[_durationIndex] / secondsPerBlock) + block.number);
        Auction memory auction = Auction(
            _seller,
            _durationIndex,
            uint64(now),
            auctionEndBlock,
            _startingPrice,
            false
        );
        _addAuction(_tokenId, auction);
    }

    function setCut(uint256 _prizeCut, uint256 _tokenDiscount)
    external
    {
        require(msg.sender == address(nonFungibleContract));
        require(_prizeCut + _tokenDiscount < ownerCut);

        prizeCut = _prizeCut;
        tokenDiscount = _tokenDiscount;
    }

    
    /// require sender to be PonyCore contract.
    function createDklAuction(
        uint256 _tokenId,
        address _seller,
        uint16 _durationIndex,
        uint256 _startingPrice
    )
    external

    {
        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        uint64 auctionEndBlock = uint64((auctionDuration[_durationIndex] / secondsPerBlock) + block.number);
        Auction memory auction = Auction(
            _seller,
            _durationIndex,
            uint64(now),
            auctionEndBlock,
            _startingPrice,
            true
        );
        _addAuction(_tokenId, auction);
    }

    function getNonces(address _address) public view returns (uint256) {
        return nonces[_address];
    }

    function auctionEndHashing(uint _amount, uint256 _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0F0E), _tokenId, _amount));
    }

    function auctionEthEnd(address _winner, uint _amount, uint256 _tokenId, bytes _sig) public onlySystem {
        bytes32 hashedTx = auctionEndHashing(_amount, _tokenId);
        require(recover(hashedTx, _sig) == _winner);
        Auction storage auction = tokenIdToAuction[_tokenId];
        uint64 endblock = auction.auctionEndBlock;
        require(endblock < block.number);
        require(!auction.allowPayDekla);
        uint256 prize = _amount * prizeCut / 10000;
        uint256 auctioneerCut = _computeCut(_amount) - prize;
        uint256 sellerProceeds = _amount - auctioneerCut;
        winBidEth(_winner, auction.seller, sellerProceeds, auctioneerCut);
        prizeAddress.transfer(prize);
        _removeAuction(_tokenId);
        _transfer(_winner, _tokenId);
        emit AuctionSuccessful(_tokenId, _amount, _winner);
    }

    function auctionDeklaEnd(address _winner, uint _amount, uint256 _tokenId, bytes _sig) public onlySystem {
        bytes32 hashedTx = auctionEndHashing(_amount, _tokenId);
        require(recover(hashedTx, _sig) == _winner);
        Auction storage auction = tokenIdToAuction[_tokenId];
        uint64 endblock = auction.auctionEndBlock;
        require(endblock < block.number);
        require(auction.allowPayDekla);
        uint256 prize = _amount * prizeCut / 10000;
        uint256 discountAmount = _amount * tokenDiscount / 10000;
        uint256 auctioneerCut = _computeCut(_amount) - discountAmount - prizeCut;
        uint256 sellerProceeds = _amount - auctioneerCut;
        winBidDekla(_winner, auction.seller, sellerProceeds, auctioneerCut);
        tokens.transfer(prizeAddress, prize);
        tokens.transfer(_winner, discountAmount);
        _removeAuction(_tokenId);
        _transfer(_winner, _tokenId);
        emit AuctionSuccessful(_tokenId, _amount, _winner);
    }

    
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == nftAddress
        );

        nftAddress.transfer(address(this).balance - totalEthDeposit);
    }

    function withdrawDklBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == nftAddress
        );
        tokens.transfer(nftAddress, tokens.balanceOf(this) - totalDklDeposit);
    }
}


contract PonyMinting is PonyAuction {

    // Limits the number of ponies the contract owner can ever create.
    uint256 public constant PROMO_CREATION_LIMIT = 50;
    uint256 public constant GEN0_CREATION_LIMIT = 4950;


    // Counts the number of ponies the contract owner has created.
    uint256 public promoCreatedCount;
    uint256 public gen0CreatedCount;

    
    
    
    function createPromoPony(uint256 _genes, address _owner) external onlyCOO {
        address ponyOwner = _owner;
        if (ponyOwner == address(0)) {
            ponyOwner = cooAddress;
        }
        require(promoCreatedCount < PROMO_CREATION_LIMIT);

        promoCreatedCount++;
        _createPony(0, 0, 0, _genes, ponyOwner, 0);
    }

    
    ///  creates an auction for it.
    function createGen0(uint256 _genes, uint256 _price, uint16 _durationIndex, bool _saleDKL ) external onlyCOO {
        require(gen0CreatedCount < GEN0_CREATION_LIMIT);

        uint256 ponyId = _createPony(0, 0, 0, _genes, ceoAddress, 0);

        _approve(ponyId, biddingAuction);

        if(_saleDKL) {
            biddingAuction.createDklAuction(ponyId, ceoAddress, _durationIndex, _price);
        } else {
            biddingAuction.createETHAuction(ponyId, ceoAddress, _durationIndex, _price);
        }
        gen0CreatedCount++;
    }

}


contract PonyUpgrade is PonyMinting {
    event PonyUpgraded(uint256 upgradedPony, uint256 tributePony, uint8 unicornation);

    function upgradePonyHashing(uint256 _upgradeId, uint256 _txCount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A0E9D), _upgradeId, _txCount));
    }

    function upgradePony(uint256 _upgradeId, uint256 _tributeId, bytes _sig)
    external
    whenNotPaused
    {
        require(_owns(msg.sender, _upgradeId));
        require(_upgradeId != _tributeId);

        Pony storage upPony = ponies[_upgradeId];

        bytes32 hashedTx = upgradePonyHashing(_upgradeId, upPony.txCount);
        require(signedBySystem(hashedTx, _sig));

        upPony.txCount += 1;
        if (upPony.unicornation == 0) {
            if (geneScience.upgradePonyResult(upPony.unicornation, block.number)) {
                upPony.unicornation += 1;
                emit PonyUpgraded(_upgradeId, _tributeId, upPony.unicornation);
            }
        }
        else if (upPony.unicornation > 0) {
            require(_owns(msg.sender, _tributeId));

            if (geneScience.upgradePonyResult(upPony.unicornation, block.number)) {
                upPony.unicornation += 1;
                _transfer(msg.sender, address(0), _tributeId);
                emit PonyUpgraded(_upgradeId, _tributeId, upPony.unicornation);
            } else if (upPony.unicornation == 2) {
                upPony.unicornation += 1;
                _transfer(msg.sender, address(0), _tributeId);
                emit PonyUpgraded(_upgradeId, _tributeId, upPony.unicornation);
            }
        }
    }
}




contract PonyCore is PonyUpgrade {

    event WithdrawEthBalanceSuccessful(address sender, uint256 amount);
    event WithdrawDeklaBalanceSuccessful(address sender, uint256 amount);

    // This is the main MyEtherPonies contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle auctions and our super-top-secret genetic combination algorithm. The auctions are
    // seperate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // Pony ownership. The genetic combination algorithm is kept seperate so we can open-source all of
    // the rest of our code without making it _too_ easy for folks to figure out how the genetics work.
    // Don't worry, I'm sure someone will reverse engineer it soon enough!
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of CK. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - PonyBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - PonyAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - PonyOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - PonyBreeding: This file contains the methods necessary to breed ponies together, including
    //             keeping track of siring offers, and relies on an external genetic combination contract.
    //
    //      - PonyAuctions: Here we have the public methods for auctioning or bidding on ponies or siring
    //             services. The actual auction functionality is handled in two sibling contracts (one
    //             for sales and one for siring), while auction creation and bidding is mostly mediated
    //             through this facet of the core contract.
    //
    //      - PonyMinting: This final facet contains the functionality we use for creating new gen0 ponies.
    //             We can make up to 5000 "promo" ponies that can be given away (especially important when
    //             the community is new), and all others can only be created and then immediately put up
    //             for auction via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 50k gen0 ponies. After that, it's all up to the
    //             community to breed, breed, breed!

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    // ERC20 basic token contract being held
    ERC20 public token;

    
    constructor(
        address _ceoAddress,
        address _cfoAddress,
        address _cooAddress,
        address _systemAddress,
        address _tokenAddress
    ) public {
        // validate address
        require(_ceoAddress != address(0));
        require(_cooAddress != address(0));
        require(_cfoAddress != address(0));
        require(_systemAddress != address(0));
        require(_tokenAddress != address(0));

        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = _ceoAddress;
        cfoAddress = _cfoAddress;
        cooAddress = _cooAddress;
        systemAddress = _systemAddress;
        token = ERC20(_tokenAddress);

        // start with the mythical pony 0 - so we don't have generation-0 parent issues
        _createPony(0, 0, 0, uint256(- 1), address(0), 0);
    }

    //check that the token is set
    modifier validToken() {
        require(token != address(0));
        _;
    }

    function getTokenAddressHashing(address _token, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A1216), _token, _nonce));
    }

    function setTokenAddress(address _token, bytes _sig) external onlyCLevel {
        bytes32 hashedTx = getTokenAddressHashing(_token, nonces[msg.sender]);
        require(signedByCLevel(hashedTx, _sig));
        nonces[msg.sender]++;

        token = ERC20(_token);
    }

    
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    
    
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
    }

    
    
    function getPony(uint256 _id)
    external
    view
    returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes,
        uint16 upgradeIndex,
        uint8 unicornation
    ) {
        Pony storage pon = ponies[_id];

        // if this variable is 0 then it's not gestating
        isGestating = (pon.matingWithId != 0);
        isReady = (pon.cooldownEndBlock <= block.number);
        cooldownIndex = uint256(pon.cooldownIndex);
        nextActionAt = uint256(pon.cooldownEndBlock);
        siringWithId = uint256(pon.matingWithId);
        birthTime = uint256(pon.birthTime);
        matronId = uint256(pon.matronId);
        sireId = uint256(pon.sireId);
        generation = uint256(pon.generation);
        genes = pon.genes;
        upgradeIndex = pon.txCount;
        unicornation = pon.unicornation;
    }

    
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(geneScience != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }

    function withdrawBalanceHashing(address _address, uint256 _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes4(0x486A1217), _address, _nonce));
    }

    function withdrawEthBalance(address _withdrawWallet, bytes _sig) external onlyCLevel {
        bytes32 hashedTx = withdrawBalanceHashing(_withdrawWallet, nonces[msg.sender]);
        require(signedByCLevel(hashedTx, _sig));

        uint256 balance = address(this).balance;

        // Subtract all the currently pregnant ponies we have, plus 1 of margin.
        uint256 subtractFees = (pregnantPonies + 1) * autoBirthFee;
        require(balance > 0);
        require(balance > subtractFees);

        nonces[msg.sender]++;
        _withdrawWallet.transfer(balance - subtractFees);
        emit WithdrawEthBalanceSuccessful(_withdrawWallet, balance - subtractFees);
    }


    function withdrawDeklaBalance(address _withdrawWallet, bytes _sig) external validToken onlyCLevel {
        bytes32 hashedTx = withdrawBalanceHashing(_withdrawWallet, nonces[msg.sender]);
        require(signedByCLevel(hashedTx, _sig));

        uint256 balance = token.balanceOf(this);
        require(balance > 0);

        nonces[msg.sender]++;
        token.transfer(_withdrawWallet, balance);
        emit WithdrawDeklaBalanceSuccessful(_withdrawWallet, balance);
    }
}