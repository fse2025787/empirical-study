
pragma solidity ^0.4.22;


contract ERC721 {
    // イベント
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    // 必要なメソッド
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) external view returns (address _owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function totalSupply() public view returns (uint);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    *               契約が一時停止されている場合にのみアクションを許可する
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    *               契約が一時停止されていない場合にのみアクションを許可する
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    *             一時停止するために所有者によって呼び出され、停止状態をトリガする
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    *             ポーズをとるためにオーナーが呼び出し、通常の状態に戻ります
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract RocsCoreRe {

    function getRoc(uint _tokenId) public returns (
        uint rocId,
        string dna,
        uint marketsFlg);

    function getRocIdToTokenId(uint _rocId) public view returns (uint);
    function getRocIndexToOwner(uint _rocId) public view returns (address);
}

contract ItemsBase is Pausable {
    // ハント代
    uint public huntingPrice = 5 finney;
    function setHuntingPrice(uint256 price) public onlyOwner {
        huntingPrice = price;
    }

    // ERC721
    event Transfer(address from, address to, uint tokenId);
    event ItemTransfer(address from, address to, uint tokenId);

    // Itemの作成
    event ItemCreated(address owner, uint tokenId, uint ticketId);

    event HuntingCreated(uint huntingId, uint rocId);

    
    struct Item {
        uint itemId;
        uint8 marketsFlg;
        uint rocId;
        uint8 equipmentFlg;
    }
    Item[] public items;

    // itemIdとtokenIdのマッピング
    mapping(uint => uint) public itemIndex;
    // itemIdからtokenIdを取得
    function getItemIdToTokenId(uint _itemId) public view returns (uint) {
        return itemIndex[_itemId];
    }

    
    mapping (uint => address) public itemIndexToOwner;
    // @dev itemの所有者アドレスから所有するトークン数へのマッピング
    mapping (address => uint) public itemOwnershipTokenCount;
    
    mapping (uint => address) public itemIndexToApproved;

    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        itemOwnershipTokenCount[_to]++;
        itemOwnershipTokenCount[_from]--;
        itemIndexToOwner[_tokenId] = _to;
        // イベント開始
        emit ItemTransfer(_from, _to, _tokenId);
    }

    address public rocCoreAddress;
    RocsCoreRe rocCore;

    function setRocCoreAddress(address _rocCoreAddress) public onlyOwner {
        rocCoreAddress = _rocCoreAddress;
        rocCore = RocsCoreRe(rocCoreAddress);
    }
    function getRocCoreAddress() 
        external
        view
        onlyOwner
        returns (
        address
    ) {
        return rocCore;
    }

    
    struct Hunting {
        uint huntingId;
    }
    // Huntingのmapping rocHuntingIndex[rocId][tokenId] = Hunting
    mapping(uint => mapping (uint => Hunting)) public rocHuntingIndex;

    
    
    
    function _createRocHunting(
        uint _rocId,
        uint _huntingId
    )
        internal
        returns (bool)
    {
        Hunting memory _hunting = Hunting({
            huntingId: _huntingId
        });

        rocHuntingIndex[_rocId][_huntingId] = _hunting;
        // HuntingCreatedイベント
        emit HuntingCreated(_huntingId, _rocId);

        return true;
    }
}



contract ItemsOwnership is ItemsBase, ERC721 {

    
    string public constant name = "CryptoFeatherItems";
    string public constant symbol = "CCHI";

    bytes4 constant InterfaceSignature_ERC165 = 
    bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('totalSupply()'));

    
    ///  この契約によって実装された標準化されたインタフェースでtrueを返します。
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return itemIndexToOwner[_tokenId] == _claimant;
    }

    
    
    
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return itemIndexToApproved[_tokenId] == _claimant;
    }

    
    function _approve(uint256 _tokenId, address _approved) internal {
        itemIndexToApproved[_tokenId] = _approved;
    }

    // 指定されたアドレスのitem数を取得します。
    function balanceOf(address _owner) public view returns (uint256 count) {
        return itemOwnershipTokenCount[_owner];
    }

    
    
    function transfer(address _to, uint256 _tokenId) public whenNotPaused {
        // 安全チェック
        require(_to != address(0));
        // 自分のitemしか送ることはできません。
        require(_owns(msg.sender, _tokenId));
        // 所有権の再割り当て、保留中の承認のクリア、転送イベントの送信
        _transfer(msg.sender, _to, _tokenId);
    }

    
    
    function approve(address _to, uint256 _tokenId) external whenNotPaused {
        // 所有者のみが譲渡承認を認めることができます。
        require(_owns(msg.sender, _tokenId));
        // 承認を登録します（以前の承認を置き換えます）。
        _approve(_tokenId, _to);
        // 承認イベントを発行する。
        emit Approval(msg.sender, _to, _tokenId);
    }

    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
        // 安全チェック。
        require(_to != address(0));
        // 承認と有効な所有権の確認
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        // 所有権を再割り当てします（保留中の承認をクリアし、転送イベントを発行します）。
        _transfer(_from, _to, _tokenId);
    }

    
    
    function totalSupply() public view returns (uint) {
        return items.length - 1;
    }

    
    
    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = itemIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    
    
    
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        transferFrom(_owner, this, _tokenId);
    }

}


contract ItemsBreeding is ItemsOwnership {

    
    
    
    
    
    
    function _createItem(
        uint _itemId,
        uint _marketsFlg,
        uint _rocId,
        uint _equipmentFlg,
        address _owner
    )
        internal
        returns (uint)
    {
        Item memory _item = Item({
            itemId: _itemId,
            marketsFlg: uint8(_marketsFlg),
            rocId: _rocId,
            equipmentFlg: uint8(_equipmentFlg)
        });

        uint newItemId = items.push(_item) - 1;
        // 同一のトークンIDが発生した場合は実行を停止します
        require(newItemId == uint(newItemId));
        // RocCreatedイベント
        emit ItemCreated(_owner, newItemId, _itemId);

        // これにより所有権が割り当てられ、ERC721ドラフトごとに転送イベントが発行されます
        itemIndex[_itemId] = newItemId;
        _transfer(0, _owner, newItemId);

        return newItemId;
    }

    
    
    
    
    function equipmentItem(
        uint[] _reItems,
        uint[] _inItems,
        uint _rocId
    )
        external
        whenNotPaused
        returns(bool)
    {
        uint checkTokenId = rocCore.getRocIdToTokenId(_rocId);
        uint i;
        uint itemTokenId;
        Item memory item;
        // 解除
        for (i = 0; i < _reItems.length; i++) {
            itemTokenId = getItemIdToTokenId(_reItems[i]);
            // itemのパラメータチェック
            item = items[itemTokenId];
            // マーケットへの出品中か確認してください。
            require(uint(item.marketsFlg) == 0);
            // アイテム装着中か確認してください。
            require(uint(item.equipmentFlg) == 1);
            // 装着チックが同一か確認してください。
            require(uint(item.rocId) == _rocId);
            // 装備解除
            items[itemTokenId].rocId = 0;
            items[itemTokenId].equipmentFlg = 0;
            // アイテムのオーナーが違えばチックのオーナーをセットしなおします。
            address itemOwner = itemIndexToOwner[itemTokenId];
            address checkOwner = rocCore.getRocIndexToOwner(checkTokenId);
            if (itemOwner != checkOwner) {
                itemIndexToOwner[itemTokenId] = checkOwner;
            }
        }
        // 装着
        for (i = 0; i < _inItems.length; i++) {
            itemTokenId = getItemIdToTokenId(_inItems[i]);
            // itemのパラメータチェック
            item = items[itemTokenId];
            // itemのオーナーである事
            require(_owns(msg.sender, itemTokenId));
            // マーケットへの出品中か確認してください。
            require(uint(item.marketsFlg) == 0);
            // アイテム未装備か確認してください。
            require(uint(item.equipmentFlg) == 0);
            // 装備処理
            items[itemTokenId].rocId = _rocId;
            items[itemTokenId].equipmentFlg = 1;
        }
        return true;
    }

    
    
    function usedItem(
        uint _itemId
    )
        external
        whenNotPaused
        returns(bool)
    {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        Item memory item = items[itemTokenId];
        // itemのオーナーである事
        require(_owns(msg.sender, itemTokenId));
        // マーケットへの出品中か確認してください。
        require(uint(item.marketsFlg) == 0);
        // アイテム未装備か確認してください。
        require(uint(item.equipmentFlg) == 0);
        delete itemIndex[_itemId];
        delete items[itemTokenId];
        delete itemIndexToOwner[itemTokenId];
        return true;
    }

    
    
    
    
    function processHunting(
        uint _rocId,
        uint _huntingId,
        uint[] _items
    )
        external
        payable
        whenNotPaused
        returns(bool)
    {
        require(msg.value >= huntingPrice);

        uint checkTokenId = rocCore.getRocIdToTokenId(_rocId);
        uint marketsFlg;
        ( , , marketsFlg) = rocCore.getRoc(checkTokenId);

        // markets中か確認してください。
        require(marketsFlg == 0);
        bool createHunting = false;
        // Hunting処理
        require(_huntingId > 0);
        createHunting = _createRocHunting(
            _rocId,
            _huntingId
        );

        uint i;
        for (i = 0; i < _items.length; i++) {
            _createItem(
                _items[i],
                0,
                0,
                0,
                msg.sender
            );
        }

        // 超過分を買い手に返す
        uint256 bidExcess = msg.value - huntingPrice;
        msg.sender.transfer(bidExcess);

        return createHunting;
    }

    
    
    
    function createItems(
        uint[] _items,
        address[] _owners
    )
        external onlyOwner
        returns (uint)
    {
        uint i;
        uint createItemId;
        for (i = 0; i < _items.length; i++) {
            createItemId = _createItem(
                _items[i],
                0,
                0,
                0,
                _owners[i]
            );
        }
        return createItemId;
    }

}


contract ItemsMarkets is ItemsBreeding {

    event ItemMarketsCreated(uint256 tokenId, uint128 marketsPrice);
    event ItemMarketsSuccessful(uint256 tokenId, uint128 marketsPriceice, address buyer);
    event ItemMarketsCancelled(uint256 tokenId);

    // ERC721
    event Transfer(address from, address to, uint tokenId);

    // NFT上のMarket
    struct ItemMarkets {
        // 登録時のNFT売手
        address seller;
        // Marketの価格
        uint128 marketsPrice;
    }

    // トークンIDから対応するマーケットへの出品にマップします。
    mapping (uint256 => ItemMarkets) tokenIdToItemMarkets;

    // マーケットへの出品の手数料を設定
    uint256 public ownerCut = 0;
    function setOwnerCut(uint256 _cut) public onlyOwner {
        require(_cut <= 10000);
        ownerCut = _cut;
    }

    
    
    
    function createItemSaleMarkets(
        uint256 _itemId,
        uint256 _marketsPrice
    )
        external
        whenNotPaused
    {
        require(_marketsPrice == uint256(uint128(_marketsPrice)));

        // チェック用のtokenIdをセット
        uint itemTokenId = getItemIdToTokenId(_itemId);
        // itemのオーナーである事
        require(_owns(msg.sender, itemTokenId));
        // itemのパラメータチェック
        Item memory item = items[itemTokenId];
        // マーケットへの出品中か確認してください。
        require(uint(item.marketsFlg) == 0);
        // 装備中か確認してください。
        require(uint(item.rocId) == 0);
        require(uint(item.equipmentFlg) == 0);
        // 承認
        _approve(itemTokenId, msg.sender);
        // マーケットへの出品セット
        _escrow(msg.sender, itemTokenId);
        ItemMarkets memory itemMarkets = ItemMarkets(
            msg.sender,
            uint128(_marketsPrice)
        );

        // マーケットへの出品FLGをセット
        items[itemTokenId].marketsFlg = 1;

        _itemAddMarkets(itemTokenId, itemMarkets);
    }

    
    ///  また、ItemMarketsCreatedイベントを発生させます。
    
    
    function _itemAddMarkets(uint256 _tokenId, ItemMarkets _markets) internal {
        tokenIdToItemMarkets[_tokenId] = _markets;
        emit ItemMarketsCreated(
            uint256(_tokenId),
            uint128(_markets.marketsPrice)
        );
    }

    
    
    function _itemRemoveMarkets(uint256 _tokenId) internal {
        delete tokenIdToItemMarkets[_tokenId];
    }

    
    
    function _itemCancelMarkets(uint256 _tokenId) internal {
        _itemRemoveMarkets(_tokenId);
        emit ItemMarketsCancelled(_tokenId);
    }

    
    ///  元の所有者にNFTを返します。
    
    
    function itemCancelMarkets(uint _itemId) external {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        ItemMarkets storage markets = tokenIdToItemMarkets[itemTokenId];
        address seller = markets.seller;
        require(msg.sender == seller);
        _itemCancelMarkets(itemTokenId);
        itemIndexToOwner[itemTokenId] = seller;
        items[itemTokenId].marketsFlg = 0;
    }

    
    ///  所有者だけがこれを行うことができ、NFTは売り手に返されます。 
    ///  緊急時にのみ使用してください。
    
    function itemCancelMarketsWhenPaused(uint _itemId) whenPaused onlyOwner external {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        ItemMarkets storage markets = tokenIdToItemMarkets[itemTokenId];
        address seller = markets.seller;
        _itemCancelMarkets(itemTokenId);
        itemIndexToOwner[itemTokenId] = seller;
        items[itemTokenId].marketsFlg = 0;
    }

    
    ///  十分な量のEtherが供給されればNFTの所有権を移転する。
    
    function itemBid(uint _itemId) external payable whenNotPaused {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        // マーケットへの出品構造体への参照を取得する
        ItemMarkets storage markets = tokenIdToItemMarkets[itemTokenId];

        uint128 sellingPrice = uint128(markets.marketsPrice);
        // 入札額が価格以上である事を確認する。
        // msg.valueはweiの数
        require(msg.value >= sellingPrice);
        // マーケットへの出品構造体が削除される前に、販売者への参照を取得します。
        address seller = markets.seller;

        // マーケットへの出品を削除します。
        _itemRemoveMarkets(itemTokenId);

        if (sellingPrice > 0) {
            // 競売人のカットを計算します。
            uint128 marketseerCut = uint128(_computeCut(sellingPrice));
            uint128 sellerProceeds = sellingPrice - marketseerCut;

            // 売り手に送金する
            seller.transfer(sellerProceeds);
        }

        // 超過分を買い手に返す
        msg.sender.transfer(msg.value - sellingPrice);
        // イベント
        emit ItemMarketsSuccessful(itemTokenId, sellingPrice, msg.sender);

        _transfer(seller, msg.sender, itemTokenId);
        // マーケットへの出品FLGをセット
        items[itemTokenId].marketsFlg = 0;
    }

    
    
    function _computeCut(uint128 _price) internal view returns (uint) {
        return _price * ownerCut / 10000;
    }

}


contract ItemsCore is ItemsMarkets {

    // コア契約が壊れてアップグレードが必要な場合に設定します
    address public newContractAddress;

    
    function unpause() public onlyOwner whenPaused {
        require(newContractAddress == address(0));
        // 実際に契約を一時停止しないでください。
        super.unpause();
    }

    // @dev 利用可能な残高を取得できるようにします。
    function withdrawBalance(uint _subtractFees) external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > _subtractFees) {
            owner.transfer(balance - _subtractFees);
        }
    }

    
    
    function getItem(uint _tokenId)
        external
        view
        returns (
        uint itemId,
        uint marketsFlg,
        uint rocId,
        uint equipmentFlg
    ) {
        Item memory item = items[_tokenId];
        itemId = uint(item.itemId);
        marketsFlg = uint(item.marketsFlg);
        rocId = uint(item.rocId);
        equipmentFlg = uint(item.equipmentFlg);
    }

    
    
    function getItemItemId(uint _itemId)
        external
        view
        returns (
        uint itemId,
        uint marketsFlg,
        uint rocId,
        uint equipmentFlg
    ) {
        Item memory item = items[getItemIdToTokenId(_itemId)];
        itemId = uint(item.itemId);
        marketsFlg = uint(item.marketsFlg);
        rocId = uint(item.rocId);
        equipmentFlg = uint(item.equipmentFlg);
    }

    
    
    function getMarketsItemId(uint _itemId)
        external
        view
        returns (
        address seller,
        uint marketsPrice
    ) {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        ItemMarkets storage markets = tokenIdToItemMarkets[itemTokenId];
        seller = markets.seller;
        marketsPrice = uint(markets.marketsPrice);
    }

    
    
    function getItemIndexToOwner(uint _itemId)
        external
        view
        returns (
        address owner
    ) {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        owner = itemIndexToOwner[itemTokenId];
    }

    
    
    
    function getHunting(uint _rocId, uint _huntingId)
        public
        view
        returns (
        uint huntingId
    ) {
        Hunting memory hunting = rocHuntingIndex[_rocId][_huntingId];
        huntingId = uint(hunting.huntingId);
    }

    
    
    function getRocOwnerItem(uint _rocId)
        external
        view
        returns (
        address owner
    ) {
        uint checkTokenId = rocCore.getRocIdToTokenId(_rocId);
        owner = rocCore.getRocIndexToOwner(checkTokenId);
    }

}