
pragma solidity ^0.4.19;



contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function takeOwnership(uint256 _tokenId) public;
    function implementsERC721() public pure returns (bool);

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





contract EthernautsBase {

    /*** CONSTANTS USED ACROSS CONTRACTS ***/

    
    ///      The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('takeOwnership(uint256)')) ^
    bytes4(keccak256('tokensOfOwner(address)')) ^
    bytes4(keccak256('tokenMetadata(uint256,string)'));

    
    /// so it creates incompability between functions across different contracts
    uint8 public constant STATS_SIZE = 10;
    uint8 public constant SHIP_SLOTS = 5;

    // Possible state of any asset
    enum AssetState { Available, UpForLease, Used }

    // Possible state of any asset
    // NotValid is to avoid 0 in places where category must be bigger than zero
    enum AssetCategory { NotValid, Sector, Manufacturer, Ship, Object, Factory, CrewMember }

    
    enum ShipStats {Level, Attack, Defense, Speed, Range, Luck}
    
    /// 00000001 - Seeded - Offered to the economy by us, the developers. Potentially at regular intervals.
    /// 00000010 - Producible - Product of a factory and/or factory contract.
    /// 00000100 - Explorable- Product of exploration.
    /// 00001000 - Leasable - Can be rented to other users and will return to the original owner once the action is complete.
    /// 00010000 - Permanent - Cannot be removed, always owned by a user.
    /// 00100000 - Consumable - Destroyed after N exploration expeditions.
    /// 01000000 - Tradable - Buyable and sellable on the market.
    /// 10000000 - Hot Potato - Automatically gets put up for sale after acquiring.
    bytes2 public ATTR_SEEDED     = bytes2(2**0);
    bytes2 public ATTR_PRODUCIBLE = bytes2(2**1);
    bytes2 public ATTR_EXPLORABLE = bytes2(2**2);
    bytes2 public ATTR_LEASABLE   = bytes2(2**3);
    bytes2 public ATTR_PERMANENT  = bytes2(2**4);
    bytes2 public ATTR_CONSUMABLE = bytes2(2**5);
    bytes2 public ATTR_TRADABLE   = bytes2(2**6);
    bytes2 public ATTR_GOLDENGOOSE = bytes2(2**7);
}


//          that can be executed only by specific roles. Namely CEO and CTO. it also includes pausable pattern.
contract EthernautsAccessControl is EthernautsBase {

    // This facet controls access control for Ethernauts.
    // All roles have same responsibilities and rights, but there is slight differences between them:
    //
    //     - The CEO: The CEO can reassign other roles and only role that can unpause the smart contract.
    //       It is initially set to the address that created the smart contract.
    //
    //     - The CTO: The CTO can change contract address, oracle address and plan for upgrades.
    //
    //     - The COO: The COO can change contract address and add create assets.
    //
    
    
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public ctoAddress;
    address public cooAddress;
    address public oracleAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    
    modifier onlyCTO() {
        require(msg.sender == ctoAddress);
        _;
    }

    
    modifier onlyOracle() {
        require(msg.sender == oracleAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == ceoAddress ||
            msg.sender == ctoAddress ||
            msg.sender == cooAddress
        );
        _;
    }

    
    
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    
    
    function setCTO(address _newCTO) external {
        require(
            msg.sender == ceoAddress ||
            msg.sender == ctoAddress
        );
        require(_newCTO != address(0));

        ctoAddress = _newCTO;
    }

    
    
    function setCOO(address _newCOO) external {
        require(
            msg.sender == ceoAddress ||
            msg.sender == cooAddress
        );
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    
    
    function setOracle(address _newOracle) external {
        require(msg.sender == ctoAddress);
        require(_newOracle != address(0));

        oracleAddress = _newOracle;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    
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

    
    ///  one reason we may pause the contract is when CTO account is compromised.
    
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }

}













//          internal functions for managing the assets. It is isolated and only interface with
//          a list of granted contracts defined by CTO

contract EthernautsStorage is EthernautsAccessControl {

    function EthernautsStorage() public {
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is the initial CTO as well
        ctoAddress = msg.sender;

        // the creator of the contract is the initial CTO as well
        cooAddress = msg.sender;

        // the creator of the contract is the initial Oracle as well
        oracleAddress = msg.sender;
    }

    
    
    function() external payable {
        require(msg.sender == address(this));
    }

    /*** Mapping for Contracts with granted permission ***/
    mapping (address => bool) public contractsGrantedAccess;

    
    
    function grantAccess(address _v2Address) public onlyCTO {
        // See README.md for updgrade plan
        contractsGrantedAccess[_v2Address] = true;
    }

    
    
    function removeAccess(address _v2Address) public onlyCTO {
        // See README.md for updgrade plan
        delete contractsGrantedAccess[_v2Address];
    }

    
    modifier onlyGrantedContracts() {
        require(contractsGrantedAccess[msg.sender] == true);
        _;
    }

    modifier validAsset(uint256 _tokenId) {
        require(assets[_tokenId].ID > 0);
        _;
    }
    /*** DATA TYPES ***/

    
    ///  of this structure. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Asset {

        // Asset ID is a identifier for look and feel in frontend
        uint16 ID;

        // Category = Sectors, Manufacturers, Ships, Objects (Upgrades/Misc), Factories and CrewMembers
        uint8 category;

        // The State of an asset: Available, On sale, Up for lease, Cooldown, Exploring
        uint8 state;

        // Attributes
        // byte pos - Definition
        // 00000001 - Seeded - Offered to the economy by us, the developers. Potentially at regular intervals.
        // 00000010 - Producible - Product of a factory and/or factory contract.
        // 00000100 - Explorable- Product of exploration.
        // 00001000 - Leasable - Can be rented to other users and will return to the original owner once the action is complete.
        // 00010000 - Permanent - Cannot be removed, always owned by a user.
        // 00100000 - Consumable - Destroyed after N exploration expeditions.
        // 01000000 - Tradable - Buyable and sellable on the market.
        // 10000000 - Hot Potato - Automatically gets put up for sale after acquiring.
        bytes2 attributes;

        // The timestamp from the block when this asset was created.
        uint64 createdAt;

        // The minimum timestamp after which this asset can engage in exploring activities again.
        uint64 cooldownEndBlock;

        // The Asset's stats can be upgraded or changed based on exploration conditions.
        // It will be defined per child contract, but all stats have a range from 0 to 255
        // Examples
        // 0 = Ship Level
        // 1 = Ship Attack
        uint8[STATS_SIZE] stats;

        // Set to the cooldown time that represents exploration duration for this asset.
        // Defined by a successful exploration action, regardless of whether this asset is acting as ship or a part.
        uint256 cooldown;

        // a reference to a super asset that manufactured the asset
        uint256 builtBy;
    }

    /*** CONSTANTS ***/

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right storage contract in our EthernautsLogic(address _CStorageAddress) call.
    bool public isEthernautsStorage = true;

    /*** STORAGE ***/

    
    ///  of each asset is actually an index into this array.
    Asset[] public assets;

    
    /// stored outside Asset Struct to save gas, because price can change frequently
    mapping (uint256 => uint256) internal assetIndexToPrice;

    
    mapping (uint256 => address) internal assetIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) internal ownershipTokenCount;

    
    ///  transferFrom(). Each Asset can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) internal assetIndexToApproved;


    /*** SETTERS ***/

    
    
    
    function setPrice(uint256 _tokenId, uint256 _price) public onlyGrantedContracts {
        assetIndexToPrice[_tokenId] = _price;
    }

    
    
    
    function approve(uint256 _tokenId, address _approved) public onlyGrantedContracts {
        assetIndexToApproved[_tokenId] = _approved;
    }

    
    
    
    
    function transfer(address _from, address _to, uint256 _tokenId) public onlyGrantedContracts {
        // Since the number of assets is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        assetIndexToOwner[_tokenId] = _to;
        // When creating new assets _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete assetIndexToApproved[_tokenId];
        }
    }

    
    ///  method does basic checking and should only be called from other contract when the
    ///  input data is known to be valid. Will NOT generate any event it is delegate to business logic contracts.
    
    
    
    
    
    
    
    
    function createAsset(
        uint256 _creatorTokenID,
        address _owner,
        uint256 _price,
        uint16 _ID,
        uint8 _category,
        uint8 _state,
        uint8 _attributes,
        uint8[STATS_SIZE] _stats,
        uint256 _cooldown,
        uint64 _cooldownEndBlock
    )
    public onlyGrantedContracts
    returns (uint256)
    {
        // Ensure our data structures are always valid.
        require(_ID > 0);
        require(_category > 0);
        require(_attributes != 0x0);
        require(_stats.length > 0);

        Asset memory asset = Asset({
            ID: _ID,
            category: _category,
            builtBy: _creatorTokenID,
            attributes: bytes2(_attributes),
            stats: _stats,
            state: _state,
            createdAt: uint64(now),
            cooldownEndBlock: _cooldownEndBlock,
            cooldown: _cooldown
            });

        uint256 newAssetUniqueId = assets.push(asset) - 1;

        // Check it reached 4 billion assets but let's just be 100% sure.
        require(newAssetUniqueId == uint256(uint32(newAssetUniqueId)));

        // store price
        assetIndexToPrice[newAssetUniqueId] = _price;

        // This will assign ownership
        transfer(address(0), _owner, newAssetUniqueId);

        return newAssetUniqueId;
    }

    
    /// This method doesn't do any checking and should only be called when the
    ///  input data is known to be valid.
    
    
    
    
    
    
    
    
    
    function editAsset(
        uint256 _tokenId,
        uint256 _creatorTokenID,
        uint256 _price,
        uint16 _ID,
        uint8 _category,
        uint8 _state,
        uint8 _attributes,
        uint8[STATS_SIZE] _stats,
        uint16 _cooldown
    )
    external validAsset(_tokenId) onlyCLevel
    returns (uint256)
    {
        // Ensure our data structures are always valid.
        require(_ID > 0);
        require(_category > 0);
        require(_attributes != 0x0);
        require(_stats.length > 0);

        // store price
        assetIndexToPrice[_tokenId] = _price;

        Asset storage asset = assets[_tokenId];
        asset.ID = _ID;
        asset.category = _category;
        asset.builtBy = _creatorTokenID;
        asset.attributes = bytes2(_attributes);
        asset.stats = _stats;
        asset.state = _state;
        asset.cooldown = _cooldown;
    }

    
    
    
    function updateStats(uint256 _tokenId, uint8[STATS_SIZE] _stats) public validAsset(_tokenId) onlyGrantedContracts {
        assets[_tokenId].stats = _stats;
    }

    
    
    
    function updateState(uint256 _tokenId, uint8 _state) public validAsset(_tokenId) onlyGrantedContracts {
        assets[_tokenId].state = _state;
    }

    
    
    
    function setAssetCooldown(uint256 _tokenId, uint256 _cooldown, uint64 _cooldownEndBlock)
    public validAsset(_tokenId) onlyGrantedContracts {
        assets[_tokenId].cooldown = _cooldown;
        assets[_tokenId].cooldownEndBlock = _cooldownEndBlock;
    }

    /*** GETTERS ***/

    
    
    ///      when we have large qty of parameters it throws StackTooDeepException
    
    function getStats(uint256 _tokenId) public view returns (uint8[STATS_SIZE]) {
        return assets[_tokenId].stats;
    }

    
    
    function priceOf(uint256 _tokenId) public view returns (uint256 price) {
        return assetIndexToPrice[_tokenId];
    }

    
    
    
    function hasAllAttrs(uint256 _tokenId, bytes2 _attributes) public view returns (bool) {
        return assets[_tokenId].attributes & _attributes == _attributes;
    }

    
    
    
    function hasAnyAttrs(uint256 _tokenId, bytes2 _attributes) public view returns (bool) {
        return assets[_tokenId].attributes & _attributes != 0x0;
    }

    
    
    
    function isCategory(uint256 _tokenId, uint8 _category) public view returns (bool) {
        return assets[_tokenId].category == _category;
    }

    
    
    
    function isState(uint256 _tokenId, uint8 _state) public view returns (bool) {
        return assets[_tokenId].state == _state;
    }

    
    
    
    function ownerOf(uint256 _tokenId) public view returns (address owner)
    {
        return assetIndexToOwner[_tokenId];
    }

    
    
    
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    
    
    function approvedFor(uint256 _tokenId) public view onlyGrantedContracts returns (address) {
        return assetIndexToApproved[_tokenId];
    }

    
    
    function totalSupply() public view returns (uint256) {
        return assets.length;
    }

    
    
    function getTokenList(address _owner, uint8 _withAttributes, uint256 start, uint256 count) external view returns(
        uint256[6][]
    ) {
        uint256 totalAssets = assets.length;

        if (totalAssets == 0) {
            // Return an empty array
            return new uint256[6][](0);
        } else {
            uint256[6][] memory result = new uint256[6][](totalAssets > count ? count : totalAssets);
            uint256 resultIndex = 0;
            bytes2 hasAttributes  = bytes2(_withAttributes);
            Asset memory asset;

            for (uint256 tokenId = start; tokenId < totalAssets && resultIndex < count; tokenId++) {
                asset = assets[tokenId];
                if (
                    (asset.state != uint8(AssetState.Used)) &&
                    (assetIndexToOwner[tokenId] == _owner || _owner == address(0)) &&
                    (asset.attributes & hasAttributes == hasAttributes)
                ) {
                    result[resultIndex][0] = tokenId;
                    result[resultIndex][1] = asset.ID;
                    result[resultIndex][2] = asset.category;
                    result[resultIndex][3] = uint256(asset.attributes);
                    result[resultIndex][4] = asset.cooldown;
                    result[resultIndex][5] = assetIndexToPrice[tokenId];
                    resultIndex++;
                }
            }

            return result;
        }
    }
}



//          transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
//          It interfaces with EthernautsStorage provinding basic functions as create and list, also holds
//          reference to logic contracts as Auction, Explore and so on


contract EthernautsOwnership is EthernautsAccessControl, ERC721 {

    
    EthernautsStorage public ethernautsStorage;

    /*** CONSTANTS ***/
    
    string public constant name = "Ethernauts";
    string public constant symbol = "ETNT";

    /********* ERC 721 - COMPLIANCE CONSTANTS AND FUNCTIONS ***************/
    /**********************************************************************/

    bytes4 constant InterfaceSignature_ERC165 = bytes4(keccak256('supportsInterface(bytes4)'));

    /*** EVENTS ***/

    // Events as per ERC-721
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed approved, uint256 tokens);

    
    
    
    
    
    event Build(address owner, uint256 tokenId, uint16 assetId, uint256 price);

    function implementsERC721() public pure returns (bool) {
        return true;
    }

    
    ///  Returns true for any standardized interfaces implemented by this contract. ERC-165 and ERC-721.
    
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return ethernautsStorage.ownerOf(_tokenId) == _claimant;
    }

    
    
    
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return ethernautsStorage.approvedFor(_tokenId) == _claimant;
    }

    
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Assets on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        ethernautsStorage.approve(_tokenId, _approved);
    }

    
    
    
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ethernautsStorage.balanceOf(_owner);
    }

    
    
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  Ethernauts specifically) or your Asset may be lost forever. Seriously.
    
    
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
        // The contract should never own any assets
        // (except very briefly after it is created and before it goes on auction).
        require(_to != address(this));
        // Disallow transfers to the storage contract to prevent accidental
        // misuse. Auction or Upgrade contracts should only take ownership of assets
        // through the allow + transferFrom flow.
        require(_to != address(ethernautsStorage));

        // You can only send your own asset.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        ethernautsStorage.transfer(msg.sender, _to, _tokenId);
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
        Approval(msg.sender, _to, _tokenId);
    }


    
    ///  has previously been granted transfer approval by the owner.
    
    
    ///  including the caller.
    
    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    internal
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any assets (except for used assets).
        require(_owns(_from, _tokenId));
        // Check for approval and valid ownership
        require(_approvedFor(_to, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        ethernautsStorage.transfer(_from, _to, _tokenId);
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
        _transferFrom(_from, _to, _tokenId);
    }

    
    
    
    function takeOwnership(uint256 _tokenId) public {
        address _from = ethernautsStorage.ownerOf(_tokenId);

        // Safety check to prevent against an unexpected 0x0 default.
        require(_from != address(0));
        _transferFrom(_from, msg.sender, _tokenId);
    }

    
    
    function totalSupply() public view returns (uint256) {
        return ethernautsStorage.totalSupply();
    }

    
    
    
    function ownerOf(uint256 _tokenId)
    external
    view
    returns (address owner)
    {
        owner = ethernautsStorage.ownerOf(_tokenId);

        require(owner != address(0));
    }

    
    
    
    
    
    
    
    function createNewAsset(
        uint256 _creatorTokenID,
        address _owner,
        uint256 _price,
        uint16 _assetID,
        uint8 _category,
        uint8 _attributes,
        uint8[STATS_SIZE] _stats
    )
    external onlyCLevel
    returns (uint256)
    {
        // owner must be sender
        require(_owner != address(0));

        uint256 tokenID = ethernautsStorage.createAsset(
            _creatorTokenID,
            _owner,
            _price,
            _assetID,
            _category,
            uint8(AssetState.Available),
            _attributes,
            _stats,
            0,
            0
        );

        // emit the build event
        Build(
            _owner,
            tokenID,
            _assetID,
            _price
        );

        return tokenID;
    }

    
    
    function isExploring(uint256 _tokenId) public view returns (bool) {
        uint256 cooldown;
        uint64 cooldownEndBlock;
        (,,,,,cooldownEndBlock, cooldown,) = ethernautsStorage.assets(_tokenId);
        return (cooldown > now) || (cooldownEndBlock > uint64(block.number));
    }
}


// Extend this library for child contracts
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
    * @dev Compara two numbers, and return the bigger one.
    */
    function max(int256 a, int256 b) internal pure returns (int256) {
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }

    /**
    * @dev Compara two numbers, and return the bigger one.
    */
    function min(int256 a, int256 b) internal pure returns (int256) {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }


}



contract EthernautsLogic is EthernautsOwnership {

    // Set in case the logic contract is broken and an upgrade is required
    address public newContractAddress;

    
    function EthernautsLogic() public {
        // the creator of the contract is the initial CEO, COO, CTO
        ceoAddress = msg.sender;
        ctoAddress = msg.sender;
        cooAddress = msg.sender;
        oracleAddress = msg.sender;

        // Starts paused.
        paused = true;
    }

    
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    
    function setNewAddress(address _v2Address) external onlyCTO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    
    
    function setEthernautsStorageContract(address _CStorageAddress) public onlyCLevel whenPaused {
        EthernautsStorage candidateContract = EthernautsStorage(_CStorageAddress);
        require(candidateContract.isEthernautsStorage());
        ethernautsStorage = candidateContract;
    }

    
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(ethernautsStorage != address(0));
        require(newContractAddress == address(0));
        // require this contract to have access to storage contract
        require(ethernautsStorage.contractsGrantedAccess(address(this)) == true);

        // Actually unpause the contract.
        super.unpause();
    }

    // @dev Allows the COO to capture the balance available to the contract.
    function withdrawBalances(address _to) public onlyCLevel {
        _to.transfer(this.balance);
    }

    /// return current contract balance
    function getBalance() public view onlyCLevel returns (uint256) {
        return this.balance;
    }
}




contract EthernautsPreSale is EthernautsLogic {

    
    ///  and verifies the owner cut is in the valid range.
    ///  and Delegate constructor to EthernautsUpgrade contract.
    function EthernautsPreSale() public
    EthernautsLogic() {}

    /*** EVENTS ***/
    
    event Bid(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner);

    /*** CONSTANTS ***/
    uint8 private constant percBase = 100;

    /*** STORAGE ***/

    
    uint256[5] public countdowns;

    
    uint256[][5] public waveToTokens;

    
    uint8[5] public bonus;

    
    mapping (uint256 => address) public tokenToBuyer;

    
    mapping (uint256 => uint256) public tokenToLastPrice;

    function getCountdowns() public view returns(uint256[5]) {
        return countdowns;
    }

    function getBonuses() public view returns(uint8[5]) {
        return bonus;
    }

    function getTokensPerWave(uint256 _wave) public view returns(uint256[]) {
        return waveToTokens[_wave];
    }

    function setCountdown(uint256[5] _countdowns) public onlyCLevel {
        countdowns = _countdowns;
    }

    function setBonus(uint8[5] _bonus) public onlyCLevel {
        bonus = _bonus;
    }

    function setBuyer(uint256 _tokenId, address _buyer) public onlyCLevel whenPaused {
        tokenToBuyer[_tokenId] = _buyer;
    }

    function setLastPrice(uint256 _tokenId, uint256 _lastPrice) public onlyCLevel whenPaused {
        tokenToLastPrice[_tokenId] = _lastPrice;
    }

    function setTokensWave(uint256 _wave, uint256[10] _tokens) public onlyCLevel {
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_tokens[i] > 0) {
                if (int256(waveToTokens[_wave].length) - 1 < int256(i)) {
                    waveToTokens[_wave].push(_tokens[i]);
                } else {
                    waveToTokens[_wave][i] = _tokens[i];
                }
            }
        }
    }

    function setTokensByWaveIndex(uint256 _wave, uint256 _index, uint256 _tokenId) public onlyCLevel {
        if (_index == 0) {
            waveToTokens[_wave].push(_tokenId);
        } else {
            waveToTokens[_wave][_index] = _tokenId;
        }
    }

    // ************************* BIDDING ****************************

    
    
    
    function bid(uint256 _wave, uint256 _tokenId) external payable whenNotPaused {
        // Check if token is owned by this contract
        require(ethernautsStorage.ownerOf(_tokenId) == address(this));

        // Check if pre sale is still active
        require(countdowns[_wave] >= now);

        // Check if token is part of the correct wave
        bool existInWave = false;
        for (uint256 i = 0; i < waveToTokens[_wave].length; i++) {
            if (waveToTokens[_wave][i] == _tokenId) {
                existInWave = true;
                break;
            }
        }
        require(existInWave);

        address oldBuyer = tokenToBuyer[_tokenId];
        uint256 sellingPrice = ethernautsStorage.priceOf(_tokenId);

        // Safety check to prevent against an unexpected 0x0 default.
        require(msg.sender != address(0));

        // Making sure sent amount is greater than or equal to the sellingPrice
        require(msg.value > sellingPrice);

        // sellingPrice must be the same value sent
        sellingPrice = msg.value;

        // Update price
        uint256 newPrice = SafeMath.div(SafeMath.mul(sellingPrice, bonus[_wave]), percBase);

        // set new price and owner after confirmed transaction
        uint256 lastPrice = tokenToLastPrice[_tokenId];
        tokenToLastPrice[_tokenId] = sellingPrice;
        ethernautsStorage.setPrice(_tokenId, newPrice);
        tokenToBuyer[_tokenId] = msg.sender;

        // pay back previous buyer and apply percentage return
        if (oldBuyer != address(0)) {
            oldBuyer.transfer(lastPrice);
        }

        Bid(_tokenId, sellingPrice, newPrice, oldBuyer, msg.sender);
    }

    function transfer(
        uint256 _wave
    )
    external onlyCLevel
    {
        // Check if pre sale is not active
        require(countdowns[_wave] < now);

        for (uint256 i = 0; i < waveToTokens[_wave].length; i++) {
            uint256 tokenId = waveToTokens[_wave][i];

            // in case buyer is not this contract or empty transfer
            if (tokenToBuyer[tokenId] != address(0) && tokenToBuyer[tokenId] != address(this)) {

                // Contract needs to own asset.
                require(_owns(address(this), tokenId));

                // Reassign ownership, clear pending approvals, emit Transfer event.
                _approve(tokenId, tokenToBuyer[tokenId]);
                ethernautsStorage.transfer(address(this), tokenToBuyer[tokenId], tokenId);

                // set state as available
                ethernautsStorage.updateState(tokenId, uint8(AssetState.Available));
            }
        }
    }
}