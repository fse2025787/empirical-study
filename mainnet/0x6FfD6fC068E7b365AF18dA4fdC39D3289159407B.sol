// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IDispatcher {
    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;

    function claimOwnership() external;

    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external returns (address vaultProxy_);

    function executeMigration(address _vaultProxy, bool _bypassFailure) external;

    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);

    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        returns (address fundDeployer_);

    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        );

    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getOwner() external view returns (address owner_);

    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);

    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        returns (uint256 secondsRemaining_);

    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasExecutableRequest_);

    function hasMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasMigrationRequest_);

    function removeNominatedOwner() external;

    function setCurrentFundDeployer(address _nextFundDeployer) external;

    function setMigrationTimelock(uint256 _nextTimelock) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSharesTokenSymbol(string calldata _nextSymbol) external;

    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;







contract UintListRegistry {
    enum UpdateType {None, AddOnly, RemoveOnly, AddAndRemove}

    event ItemAddedToList(uint256 indexed id, uint256 item);

    event ItemRemovedFromList(uint256 indexed id, uint256 item);

    event ListAttested(uint256 indexed id, string description);

    event ListCreated(
        address indexed creator,
        address indexed owner,
        uint256 id,
        UpdateType updateType
    );

    event ListOwnerSet(uint256 indexed id, address indexed nextOwner);

    event ListUpdateTypeSet(
        uint256 indexed id,
        UpdateType prevUpdateType,
        UpdateType indexed nextUpdateType
    );

    struct ListInfo {
        address owner;
        UpdateType updateType;
        mapping(uint256 => bool) itemToIsInList;
    }

    address private immutable DISPATCHER;

    ListInfo[] private lists;

    modifier onlyListOwner(uint256 _id) {
        require(__isListOwner(msg.sender, _id), "Only callable by list owner");
        _;
    }

    constructor(address _dispatcher) public {
        DISPATCHER = _dispatcher;

        // Create the first list as completely empty and immutable, to protect the default `id`
        lists.push(ListInfo({owner: address(0), updateType: UpdateType.None}));
    }

    // EXTERNAL FUNCTIONS

    
    
    
    function addToList(uint256 _id, uint256[] calldata _items) external onlyListOwner(_id) {
        UpdateType updateType = getListUpdateType(_id);
        require(
            updateType == UpdateType.AddOnly || updateType == UpdateType.AddAndRemove,
            "addToList: Cannot add to list"
        );

        __addToList(_id, _items);
    }

    
    
    
    
    /// for UserB to attest to their management of the items therein. It will not be visible
    /// on-chain, but will be available in event logs.
    function attestLists(uint256[] calldata _ids, string[] calldata _descriptions) external {
        require(_ids.length == _descriptions.length, "attestLists: Unequal arrays");

        for (uint256 i; i < _ids.length; i++) {
            require(
                __isListOwner(msg.sender, _ids[i]),
                "attestLists: Only callable by list owner"
            );

            emit ListAttested(_ids[i], _descriptions[i]);
        }
    }

    
    
    
    
    
    
    function createList(
        address _owner,
        UpdateType _updateType,
        uint256[] calldata _initialItems
    ) external returns (uint256 id_) {
        id_ = getListCount();

        lists.push(ListInfo({owner: _owner, updateType: _updateType}));

        emit ListCreated(msg.sender, _owner, id_, _updateType);

        __addToList(id_, _initialItems);

        return id_;
    }

    
    
    
    function removeFromList(uint256 _id, uint256[] calldata _items) external onlyListOwner(_id) {
        UpdateType updateType = getListUpdateType(_id);
        require(
            updateType == UpdateType.RemoveOnly || updateType == UpdateType.AddAndRemove,
            "removeFromList: Cannot remove from list"
        );

        // Silently ignores items that are not in the list
        for (uint256 i; i < _items.length; i++) {
            if (isInList(_id, _items[i])) {
                lists[_id].itemToIsInList[_items[i]] = false;

                emit ItemRemovedFromList(_id, _items[i]);
            }
        }
    }

    
    
    
    function setListOwner(uint256 _id, address _nextOwner) external onlyListOwner(_id) {
        lists[_id].owner = _nextOwner;

        emit ListOwnerSet(_id, _nextOwner);
    }

    
    
    
    
    function setListUpdateType(uint256 _id, UpdateType _nextUpdateType)
        external
        onlyListOwner(_id)
    {
        UpdateType prevUpdateType = getListUpdateType(_id);
        require(
            _nextUpdateType == UpdateType.None || prevUpdateType == UpdateType.AddAndRemove,
            "setListUpdateType: _nextUpdateType not allowed"
        );

        lists[_id].updateType = _nextUpdateType;

        emit ListUpdateTypeSet(_id, prevUpdateType, _nextUpdateType);
    }

    // PRIVATE FUNCTIONS

    
    function __addToList(uint256 _id, uint256[] memory _items) private {
        for (uint256 i; i < _items.length; i++) {
            if (!isInList(_id, _items[i])) {
                lists[_id].itemToIsInList[_items[i]] = true;

                emit ItemAddedToList(_id, _items[i]);
            }
        }
    }

    
    function __isListOwner(address _who, uint256 _id) private view returns (bool isListOwner_) {
        address owner = getListOwner(_id);
        return
            _who == owner ||
            (owner == getDispatcher() && _who == IDispatcher(getDispatcher()).getOwner());
    }

    /////////////////
    // LIST SEARCH //
    /////////////////

    // These functions are concerned with exiting quickly and do not consider empty params.
    // Developers should sanitize empty params as necessary for their own use cases.

    // EXTERNAL FUNCTIONS

    // Multiple items, single list

    
    
    
    
    function areAllInList(uint256 _id, uint256[] memory _items)
        external
        view
        returns (bool areAllInList_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (!isInList(_id, _items[i])) {
                return false;
            }
        }

        return true;
    }

    
    
    
    
    function areAllNotInList(uint256 _id, uint256[] memory _items)
        external
        view
        returns (bool areAllNotInList_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (isInList(_id, _items[i])) {
                return false;
            }
        }

        return true;
    }

    // Multiple items, multiple lists

    
    
    
    
    function areAllInAllLists(uint256[] memory _ids, uint256[] memory _items)
        external
        view
        returns (bool areAllInAllLists_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (!isInAllLists(_ids, _items[i])) {
                return false;
            }
        }

        return true;
    }

    
    
    
    
    function areAllInSomeOfLists(uint256[] memory _ids, uint256[] memory _items)
        external
        view
        returns (bool areAllInSomeOfLists_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (!isInSomeOfLists(_ids, _items[i])) {
                return false;
            }
        }

        return true;
    }

    
    
    
    
    function areAllNotInAnyOfLists(uint256[] memory _ids, uint256[] memory _items)
        external
        view
        returns (bool areAllNotInAnyOfLists_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (isInSomeOfLists(_ids, _items[i])) {
                return false;
            }
        }

        return true;
    }

    // PUBLIC FUNCTIONS

    // Single item, multiple lists

    
    
    
    
    function isInAllLists(uint256[] memory _ids, uint256 _item)
        public
        view
        returns (bool isInAllLists_)
    {
        for (uint256 i; i < _ids.length; i++) {
            if (!isInList(_ids[i], _item)) {
                return false;
            }
        }

        return true;
    }

    
    
    
    
    function isInSomeOfLists(uint256[] memory _ids, uint256 _item)
        public
        view
        returns (bool isInSomeOfLists_)
    {
        for (uint256 i; i < _ids.length; i++) {
            if (isInList(_ids[i], _item)) {
                return true;
            }
        }

        return false;
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    
    
    function getDispatcher() public view returns (address dispatcher_) {
        return DISPATCHER;
    }

    
    
    function getListCount() public view returns (uint256 count_) {
        return lists.length;
    }

    
    
    
    function getListOwner(uint256 _id) public view returns (address owner_) {
        return lists[_id].owner;
    }

    
    
    
    function getListUpdateType(uint256 _id) public view returns (UpdateType updateType_) {
        return lists[_id].updateType;
    }

    
    
    
    
    function isInList(uint256 _id, uint256 _item) public view returns (bool isInList_) {
        return lists[_id].itemToIsInList[_item];
    }
}