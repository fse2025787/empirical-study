// SPDX-License-Identifier: AGPL-3.0-only


// 
pragma solidity >=0.8.0;



abstract contract ERC1155 {
    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    /*///////////////////////////////////////////////////////////////
                            ERC1155 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*///////////////////////////////////////////////////////////////
                             METADATA LOGIC
    //////////////////////////////////////////////////////////////*/

    function uri(uint256 id) public view virtual returns (string memory);

    /*///////////////////////////////////////////////////////////////
                             ERC1155 LOGIC
    //////////////////////////////////////////////////////////////*/

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        for (uint256 i = 0; i < idsLength; ) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] memory owners, uint256[] memory ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        uint256 ownersLength = owners.length; // Saves MLOADs.

        require(ownersLength == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        // Unchecked because the only math done is incrementing
        // the array index counter which cannot possibly overflow.
        unchecked {
            for (uint256 i = 0; i < ownersLength; i++) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    /*///////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

// 
pragma solidity >=0.8.0;




/// afterwards using `transferOwnership`. There is no check when transferring
/// ownership so ensure you don't use `address(0)` unintentionally. The modifier
/// to guard functions with is `onlyOwner`.


abstract contract Ownable {
    
    
    
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    error NotOwner();

    
    address public owner;

    
    constructor() {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    
    
    
    function transferOwnership(address newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}// 
pragma solidity >=0.8.0;







contract ElyGenesisCollection is ERC1155, Ownable {
    //////////////////////
    /// External State ///
    //////////////////////

    
    
    /// the definitive name, but it's provided for compatibility with existing front-ends.
    string public constant name = "Ely Genesis Collection"; // solhint-disable-line const-name-snakecase

    
    
    /// data", but, again, it's provided for compatibility with existing front-ends.
    string public constant symbol = "ELYGENESIS"; // solhint-disable-line const-name-snakecase

    
    uint256 public constant PRICE = 0.05 ether;

    
    uint256 public constant MAX_SUPPLY = 500;

    
    uint256 public constant MAX_SUPPLY_PER_ID = 100;

    
    bool public metadataFrozen = false;

    
    uint256 public transactionLimit = 3;

    
    bool public purchaseable = false;

    
    
    /// for convenience, and compatibility with marketplaces and other front-ends.
    uint256 public totalSupplyAll = 0;

    
    
    uint8[5] public totalSupply;

    //////////////////////
    /// Internal State ///
    //////////////////////

    
    /// Ids are removed from this array when their max amount has been minted.
    uint8[] private availableIds = [0, 1, 2, 3, 4];

    
    /// length cannot be modified, so this variable is used instead.
    uint8 private availableIdsLength = 5;

    
    string private baseUri;

    //////////////
    /// Errors ///
    //////////////

    error WithdrawFail();
    error FrozenMetadata();
    error NotPurchaseable();
    error SoldOut();
    error InsufficientValue();
    error InvalidPurchaseAmount();
    error ExternalAccountOnly();

    //////////////
    /// Events ///
    //////////////

    event PermanentURI(string uri, uint256 indexed id);
    event Purchaseable(bool state);
    event TransactionLimit(uint256 previousLimit, uint256 newLimit);

    // solhint-disable-next-line no-empty-blocks
    constructor() {}

    
    
    function purchase(uint256 amount) public payable {
        if (!purchaseable) revert NotPurchaseable();
        if (amount + totalSupplyAll > MAX_SUPPLY) revert SoldOut();
        if (msg.value != amount * PRICE) revert InsufficientValue();
        if (msg.sender.code.length != 0) revert ExternalAccountOnly();
        if (amount > transactionLimit || amount < 1)
            revert InvalidPurchaseAmount();

        for (uint256 i; i < amount; ) {
            uint256 idx = getPseudorandom() % availableIdsLength;
            uint256 id = availableIds[idx];

            _mint(msg.sender, id, 1, "");

            // `totalSupplyAll` needs to be incremented in the loop to provide a unique nonce for
            // each call to `getPseudorandom()`.
            unchecked {
                ++i;
                ++totalSupplyAll;
                ++totalSupply[id];
            }

            // Remove the token from `availableIds` if it's reached the supply limit
            if (totalSupply[id] == MAX_SUPPLY_PER_ID) removeIndex(idx);
        }
    }

    
    
    function uri(uint256 id) public view override returns (string memory) {
        return
            bytes(baseUri).length > 0
                ? string(abi.encodePacked(baseUri, toString(id), ".json"))
                : "";
    }

    //////////////////////
    /// Administration ///
    //////////////////////

    
    
    function freezeMetadata() public onlyOwner {
        metadataFrozen = true;
        for (uint256 i = 0; i < 5; ++i) {
            emit PermanentURI(uri(i), i);
        }
    }

    
    
    /// baseURI given here applies to all token IDs.
    function setBaseUri(string memory newBaseUri) public onlyOwner {
        if (metadataFrozen == true) revert FrozenMetadata();
        baseUri = newBaseUri;
    }

    
    function setPurchaseable(bool state) public onlyOwner {
        purchaseable = state;
        emit Purchaseable(purchaseable);
    }

    
    function withdrawEth() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        if (!success) revert WithdrawFail();
    }

    
    function setTransactionLimit(uint256 newTransactionLimit) public onlyOwner {
        emit TransactionLimit(transactionLimit, newTransactionLimit);
        transactionLimit = newTransactionLimit;
    }

    ////////////////
    /// Internal ///
    ////////////////

    
    /// necessary because IDs have no rarity (no ID is inherently more valuable than another).
    function getPseudorandom() internal view returns (uint256) {
        // solhint-disable not-rely-on-time
        unchecked {
            return
                uint256(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            msg.sender,
                            totalSupplyAll
                        )
                    )
                );
        }
        // solhint-enable not-rely-on-time
    }

    
    /// of the token ID at `index` has already been purchased. The index isn't checked because useage is internal.
    function removeIndex(uint256 index) internal {
        availableIds[index] = availableIds[availableIdsLength - 1];
        availableIdsLength--;
    }

    
    /// (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol)
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}



interface ERC1155TokenReceiver {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external returns (bytes4);
}
