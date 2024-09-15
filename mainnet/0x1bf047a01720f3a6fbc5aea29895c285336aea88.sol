
/**
 *Submitted for verification at Etherscan.io on 2022-04-26
*/

pragma solidity ^0.4.19;


contract AxieAccessControl {

    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    function AxieAccessControl() internal {
        ceoAddress = msg.sender;
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

    modifier onlyCLevel() {
        require(
        // solium-disable operator-whitespace
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress ||
            msg.sender == cooAddress
        // solium-enable operator-whitespace
        );
        _;
    }

    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }

    function setCFO(address _newCFO) external onlyCEO {
        cfoAddress = _newCFO;
    }

    function setCOO(address _newCOO) external onlyCEO {
        cooAddress = _newCOO;
    }

    function withdrawBalance() external onlyCFO {
        cfoAddress.transfer(this.balance);
    }
}


interface AxieSpawningManager {
    function isSpawningAllowed(uint256 _genes, address _owner) external returns (bool);
    function isRebirthAllowed(uint256 _axieId, uint256 _genes) external returns (bool);
}

interface AxieRetirementManager {
    function isRetirementAllowed(uint256 _axieId, bool _rip) external returns (bool);
}

interface AxieMarketplaceManager {
    function isTransferAllowed(address _from, address _to, uint256 _axieId) external returns (bool);
}

interface AxieGeneManager {
    function isEvolvementAllowed(uint256 _axieId, uint256 _newGenes) external returns (bool);
}











/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}










interface IERC165 {
    
    
    
    ///  uses less than 30,000 gas.
    
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}


contract ERC165 is IERC165 {
    
    mapping (bytes4 => bool) internal supportedInterfaces;

    function ERC165() internal {
        supportedInterfaces[0x01ffc9a7] = true; // ERC-165
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return supportedInterfaces[interfaceID];
    }
}





///  Note: the ERC-165 identifier for this interface is 0x6466353c
interface IERC721Base /* is IERC165  */ {
    
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

    
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    
    
    ///  function throws for queries about the zero address.
    
    
    function balanceOf(address _owner) external view returns (uint256);

    
    
    
    ///  about them do throw.
    
    function ownerOf(uint256 _tokenId) external view returns (address);

    
    
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
    
    
    
    
    // solium-disable-next-line arg-overflow
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable;

    
    
    ///  except this function just sets data to []
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    
    
    
    ///  operator of the current owner.
    
    
    function approve(address _approved, uint256 _tokenId) external payable;

    
    ///  all your asset.
    
    
    
    function setApprovalForAll(address _operator, bool _approved) external;

    
    
    
    
    function getApproved(uint256 _tokenId) external view returns (address);

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}





///  Note: the ERC-165 identifier for this interface is 0x780e9d63
interface IERC721Enumerable /* is IERC721Base */ {
    
    
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    
    
    
    
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    
    
    ///  `_owner` is the zero address, representing invalid NFTs.
    
    
    
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId);
}




interface IERC721TokenReceiver {
    
    
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. This function MUST use 50,000 gas or less. Return of other
    ///  than the magic value MUST result in the transaction being reverted.
    ///  Note: the contract address is always the message sender.
    
    
    
    
    ///  unless throwing
    function onERC721Received(address _from, uint256 _tokenId, bytes _data) external returns (bytes4);
}






contract AxieDependency {

    address public whitelistSetterAddress;

    AxieSpawningManager public spawningManager;
    AxieRetirementManager public retirementManager;
    AxieMarketplaceManager public marketplaceManager;
    AxieGeneManager public geneManager;

    mapping (address => bool) public whitelistedSpawner;
    mapping (address => bool) public whitelistedByeSayer;
    mapping (address => bool) public whitelistedMarketplace;
    mapping (address => bool) public whitelistedGeneScientist;

    constructor() internal {
        whitelistSetterAddress = msg.sender;
    }

    modifier onlyWhitelistSetter() {
        require(msg.sender == whitelistSetterAddress);
        _;
    }

    modifier whenSpawningAllowed(uint256 _genes, address _owner) {
        require(
            spawningManager == address(0) ||
            spawningManager.isSpawningAllowed(_genes, _owner)
        ,"whenSpawningAllowed");
        _;
    }

    modifier whenRebirthAllowed(uint256 _axieId, uint256 _genes) {
        require(
            spawningManager == address(0) ||
            spawningManager.isRebirthAllowed(_axieId, _genes)
        );
        _;
    }

    modifier whenRetirementAllowed(uint256 _axieId, bool _rip) {
        require(
            retirementManager == address(0) ||
            retirementManager.isRetirementAllowed(_axieId, _rip)
        );
        _;
    }

    modifier whenTransferAllowed(address _from, address _to, uint256 _axieId) {
        require(
            marketplaceManager == address(0) ||
            marketplaceManager.isTransferAllowed(_from, _to, _axieId)
        );
        _;
    }

    modifier whenEvolvementAllowed(uint256 _axieId, uint256 _newGenes) {
        require(
            geneManager == address(0) ||
            geneManager.isEvolvementAllowed(_axieId, _newGenes)
        );
        _;
    }

    modifier onlySpawner() {
        require(whitelistedSpawner[msg.sender],"onlySpawner");
        _;
    }

    modifier onlyByeSayer() {
        require(whitelistedByeSayer[msg.sender]);
        _;
    }

    modifier onlyMarketplace() {
        require(whitelistedMarketplace[msg.sender]);
        _;
    }

    modifier onlyGeneScientist() {
        require(whitelistedGeneScientist[msg.sender]);
        _;
    }

    /*
     * @dev Setting the whitelist setter address to `address(0)` would be a irreversible process.
     *  This is to lock changes to Axie's contracts after their development is done.
     */
    function setWhitelistSetter(address _newSetter) external onlyWhitelistSetter {
        whitelistSetterAddress = _newSetter;
    }

    function setSpawningManager(address _manager) external onlyWhitelistSetter {
        spawningManager = AxieSpawningManager(_manager);
    }

    function setRetirementManager(address _manager) external onlyWhitelistSetter {
        retirementManager = AxieRetirementManager(_manager);
    }

    function setMarketplaceManager(address _manager) external onlyWhitelistSetter {
        marketplaceManager = AxieMarketplaceManager(_manager);
    }

    function setGeneManager(address _manager) external onlyWhitelistSetter {
        geneManager = AxieGeneManager(_manager);
    }

    function setSpawner(address _spawner, bool _whitelisted) external onlyWhitelistSetter {
        require(whitelistedSpawner[_spawner] != _whitelisted);
        whitelistedSpawner[_spawner] = _whitelisted;
    }

    function setByeSayer(address _byeSayer, bool _whitelisted) external onlyWhitelistSetter {
        require(whitelistedByeSayer[_byeSayer] != _whitelisted);
        whitelistedByeSayer[_byeSayer] = _whitelisted;
    }

    function setMarketplace(address _marketplace, bool _whitelisted) external onlyWhitelistSetter {
        require(whitelistedMarketplace[_marketplace] != _whitelisted);
        whitelistedMarketplace[_marketplace] = _whitelisted;
    }

    function setGeneScientist(address _geneScientist, bool _whitelisted) external onlyWhitelistSetter {
        require(whitelistedGeneScientist[_geneScientist] != _whitelisted);
        whitelistedGeneScientist[_geneScientist] = _whitelisted;
    }
}






contract AxiePausable is AxieAccessControl {

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}



contract AxieERC721BaseEnumerable is ERC165, IERC721Base, IERC721Enumerable, AxieDependency, AxiePausable {
    using SafeMath for uint256;

    // @dev Total amount of tokens.
    uint256 private _totalTokens;

    // @dev Mapping from token index to ID.
    mapping (uint256 => uint256) private _overallTokenId;

    // @dev Mapping from token ID to index.
    mapping (uint256 => uint256) private _overallTokenIndex;

    // @dev Mapping from token ID to owner.
    mapping (uint256 => address) private _tokenOwner;

    // @dev For a given owner and a given operator, store whether
    //  the operator is allowed to manage tokens on behalf of the owner.
    mapping (address => mapping (address => bool)) private _tokenOperator;

    // @dev Mapping from token ID to approved address.
    mapping (uint256 => address) private _tokenApproval;

    // @dev Mapping from owner to list of owned token IDs.
    mapping (address => uint256[]) private _ownedTokens;

    // @dev Mapping from token ID to index in the owned token list.
    mapping (uint256 => uint256) private _ownedTokenIndex;

    function AxieERC721BaseEnumerable() internal {
        supportedInterfaces[0x6466353c] = true; // ERC-721 Base
        supportedInterfaces[0x780e9d63] = true; // ERC-721 Enumerable
    }

    // solium-disable function-order

    modifier mustBeValidToken(uint256 _tokenId) {
        require(_tokenOwner[_tokenId] != address(0));
        _;
    }

    function _isTokenOwner(address _ownerToCheck, uint256 _tokenId) private view returns (bool) {
        return _tokenOwner[_tokenId] == _ownerToCheck;
    }

    function _isTokenOperator(address _operatorToCheck, uint256 _tokenId) private view returns (bool) {
        return whitelistedMarketplace[_operatorToCheck] ||
        _tokenOperator[_tokenOwner[_tokenId]][_operatorToCheck];
    }

    function _isApproved(address _approvedToCheck, uint256 _tokenId) private view returns (bool) {
        return _tokenApproval[_tokenId] == _approvedToCheck;
    }

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(_isTokenOwner(msg.sender, _tokenId));
        _;
    }

    modifier onlyTokenOwnerOrOperator(uint256 _tokenId) {
        require(_isTokenOwner(msg.sender, _tokenId) || _isTokenOperator(msg.sender, _tokenId));
        _;
    }

    modifier onlyTokenAuthorized(uint256 _tokenId) {
        require(
        // solium-disable operator-whitespace
            _isTokenOwner(msg.sender, _tokenId) ||
            _isTokenOperator(msg.sender, _tokenId) ||
            _isApproved(msg.sender, _tokenId)
        // solium-enable operator-whitespace
        );
        _;
    }

    // ERC-721 Base

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0));
        return _ownedTokens[_owner].length;
    }

    function ownerOf(uint256 _tokenId) external view mustBeValidToken(_tokenId) returns (address) {
        return _tokenOwner[_tokenId];
    }

    function _addTokenTo(address _to, uint256 _tokenId) private {
        require(_to != address(0),"_to != address(0)");

        _tokenOwner[_tokenId] = _to;

        uint256 length = _ownedTokens[_to].length;
        _ownedTokens[_to].push(_tokenId);
        _ownedTokenIndex[_tokenId] = length;
    }

    function _mint(address _to, uint256 _tokenId) internal {
        require(_tokenOwner[_tokenId] == address(0),"_tokenOwner[_tokenId] == address(0)");

        _addTokenTo(_to, _tokenId);

        _overallTokenId[_totalTokens] = _tokenId;
        _overallTokenIndex[_tokenId] = _totalTokens;
        _totalTokens = _totalTokens.add(1);

        emit Transfer(address(0), _to, _tokenId);
    }

    function _removeTokenFrom(address _from, uint256 _tokenId) private {
        require(_from != address(0));

        uint256 _tokenIndex = _ownedTokenIndex[_tokenId];
        uint256 _lastTokenIndex = _ownedTokens[_from].length.sub(1);
        uint256 _lastTokenId = _ownedTokens[_from][_lastTokenIndex];

        _tokenOwner[_tokenId] = address(0);

        // Insert the last token into the position previously occupied by the removed token.
        _ownedTokens[_from][_tokenIndex] = _lastTokenId;
        _ownedTokenIndex[_lastTokenId] = _tokenIndex;

        // Resize the array.
        delete _ownedTokens[_from][_lastTokenIndex];
        _ownedTokens[_from].length--;

        // Remove the array if no more tokens are owned to prevent pollution.
        if (_ownedTokens[_from].length == 0) {
            delete _ownedTokens[_from];
        }

        // Update the index of the removed token.
        delete _ownedTokenIndex[_tokenId];
    }

    function _burn(uint256 _tokenId) internal {
        address _from = _tokenOwner[_tokenId];

        require(_from != address(0));

        _removeTokenFrom(_from, _tokenId);
        _totalTokens = _totalTokens.sub(1);

        uint256 _tokenIndex = _overallTokenIndex[_tokenId];
        uint256 _lastTokenId = _overallTokenId[_totalTokens];

        delete _overallTokenIndex[_tokenId];
        delete _overallTokenId[_totalTokens];
        _overallTokenId[_tokenIndex] = _lastTokenId;
        _overallTokenIndex[_lastTokenId] = _tokenIndex;

        Transfer(_from, address(0), _tokenId);
    }

    function _isContract(address _address) private view returns (bool) {
        uint _size;
        // solium-disable-next-line security/no-inline-assembly
        assembly { _size := extcodesize(_address) }
        return _size > 0;
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data,
        bool _check
    )
    internal
    mustBeValidToken(_tokenId)
    onlyTokenAuthorized(_tokenId)
    whenTransferAllowed(_from, _to, _tokenId)
    {
        require(_isTokenOwner(_from, _tokenId));
        require(_to != address(0));
        require(_to != _from);

        _removeTokenFrom(_from, _tokenId);

        delete _tokenApproval[_tokenId];
        Approval(_from, address(0), _tokenId);

        _addTokenTo(_to, _tokenId);

        if (_check && _isContract(_to)) {
            IERC721TokenReceiver(_to).onERC721Received.gas(50000)(_from, _tokenId, _data);
        }

        Transfer(_from, _to, _tokenId);
    }

    // solium-disable arg-overflow

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable {
        _transferFrom(_from, _to, _tokenId, _data, true);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _transferFrom(_from, _to, _tokenId, "", true);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _transferFrom(_from, _to, _tokenId, "", false);
    }

    // solium-enable arg-overflow

    function approve(
        address _approved,
        uint256 _tokenId
    )
    external
    payable
    mustBeValidToken(_tokenId)
    onlyTokenOwnerOrOperator(_tokenId)
    whenNotPaused
    {
        address _owner = _tokenOwner[_tokenId];

        require(_owner != _approved);
        require(_tokenApproval[_tokenId] != _approved);

        _tokenApproval[_tokenId] = _approved;

        Approval(_owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external whenNotPaused {
        require(_tokenOperator[msg.sender][_operator] != _approved);
        _tokenOperator[msg.sender][_operator] = _approved;
        ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view mustBeValidToken(_tokenId) returns (address) {
        return _tokenApproval[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _tokenOperator[_owner][_operator];
    }

    // ERC-721 Enumerable

    function totalSupply() external view returns (uint256) {
        return _totalTokens;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < _totalTokens);
        return _overallTokenId[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId) {
        require(_owner != address(0));
        require(_index < _ownedTokens[_owner].length);
        return _ownedTokens[_owner][_index];
    }
}









///  Note: the ERC-165 identifier for this interface is 0x5b5e139f
interface IERC721Metadata /* is IERC721Base */ {
    
    function name() external pure returns (string _name);

    
    function symbol() external pure returns (string _symbol);

    
    
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string);
}



contract AxieERC721Metadata is AxieERC721BaseEnumerable, IERC721Metadata {
    string public tokenURIPrefix = "https://api-eth.winnfthorse.io/api/erc/721/horse/";
    string public tokenURISuffix = ".json";

    function AxieERC721Metadata() internal {
        supportedInterfaces[0x5b5e139f] = true; // ERC-721 Metadata
    }

    function name() external pure returns (string) {
        return "WIN NFT HORSE";
    }

    function symbol() external pure returns (string) {
        return "WNH";
    }

    function setTokenURIAffixes(string _prefix, string _suffix) external onlyCEO {
        tokenURIPrefix = _prefix;
        tokenURISuffix = _suffix;
    }

    function tokenURI(
        uint256 _tokenId
    )
    external
    view
    mustBeValidToken(_tokenId)
    returns (string)
    {
        bytes memory _tokenURIPrefixBytes = bytes(tokenURIPrefix);
        bytes memory _tokenURISuffixBytes = bytes(tokenURISuffix);
        uint256 _tmpTokenId = _tokenId;
        uint256 _length;

        do {
            _length++;
            _tmpTokenId /= 10;
        } while (_tmpTokenId > 0);

        bytes memory _tokenURIBytes = new bytes(_tokenURIPrefixBytes.length + _length + 5);
        uint256 _i = _tokenURIBytes.length - 6;

        _tmpTokenId = _tokenId;

        do {
            _tokenURIBytes[_i--] = byte(48 + _tmpTokenId % 10);
            _tmpTokenId /= 10;
        } while (_tmpTokenId > 0);

        for (_i = 0; _i < _tokenURIPrefixBytes.length; _i++) {
            _tokenURIBytes[_i] = _tokenURIPrefixBytes[_i];
        }

        for (_i = 0; _i < _tokenURISuffixBytes.length; _i++) {
            _tokenURIBytes[_tokenURIBytes.length + _i - 5] = _tokenURISuffixBytes[_i];
        }

        return string(_tokenURIBytes);
    }
}


// solium-disable-next-line no-empty-blocks
contract AxieERC721 is AxieERC721BaseEnumerable, AxieERC721Metadata {
}


// solium-disable-next-line no-empty-blocks
contract WIN_NFT_HORSE_Core is AxieERC721 {
    struct Axie {
        uint256 genes;
        uint256 bornAt;
    }

    Axie[] axies;

    event AxieSpawned(uint256 indexed _axieId, address indexed _owner, uint256 _genes);
    event AxieRebirthed(uint256 indexed _axieId, uint256 _genes);
    event AxieRetired(uint256 indexed _axieId);
    event AxieEvolved(uint256 indexed _axieId, uint256 _oldGenes, uint256 _newGenes);

    function WIN_NFT_HORSE_Core() public {
        // axies.push(Axie(0, now)); // The void Axie
        // _spawnAxie(0, msg.sender); // Will be Puff
        // _spawnAxie(0, msg.sender); // Will be Kotaro
        // _spawnAxie(0, msg.sender); // Will be Ginger
        // _spawnAxie(0, msg.sender); // Will be Stella
    }

    function getAxie(
        uint256 _axieId
    )
    external
    view
    mustBeValidToken(_axieId)
    returns (uint256 /* _genes */, uint256 /* _bornAt */)
    {
        Axie storage _axie = axies[_axieId];
        return (_axie.genes, _axie.bornAt);
    }

    function spawnAxie(uint256 _genes, address _owner) external
    onlySpawner
    whenSpawningAllowed(_genes, _owner)
    returns (uint256)
    {
        return _spawnAxie(_genes, _owner);
    }

    function rebirthAxie(
        uint256 _axieId,
        uint256 _genes
    )
    external
    onlySpawner
    mustBeValidToken(_axieId)
    whenRebirthAllowed(_axieId, _genes)
    {
        Axie storage _axie = axies[_axieId];
        _axie.genes = _genes;
        _axie.bornAt = now;
        AxieRebirthed(_axieId, _genes);
    }

    function retireAxie(
        uint256 _axieId,
        bool _rip
    )
    external
    onlyByeSayer
    whenRetirementAllowed(_axieId, _rip)
    {
        _burn(_axieId);

        if (_rip) {
            delete axies[_axieId];
        }

        AxieRetired(_axieId);
    }

    function evolveAxie(
        uint256 _axieId,
        uint256 _newGenes
    )
    external
    onlyGeneScientist
    mustBeValidToken(_axieId)
    whenEvolvementAllowed(_axieId, _newGenes)
    {
        uint256 _oldGenes = axies[_axieId].genes;
        axies[_axieId].genes = _newGenes;
        AxieEvolved(_axieId, _oldGenes, _newGenes);
    }

    function _spawnAxie(uint256 _genes, address _owner) private returns (uint256 _axieId) {
        Axie memory _axie = Axie(_genes, now);
        _axieId = axies.push(_axie) - 1;
        _mint(_owner, _axieId);
        emit AxieSpawned(_axieId, _owner, _genes);
    }
}