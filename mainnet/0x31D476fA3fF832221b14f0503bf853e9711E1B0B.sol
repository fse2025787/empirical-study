// SPDX-License-Identifier: MIT

// 

pragma solidity ^0.8.0;

/**
 * @title Partial ERC173 interface needed by internal functions
 */
interface IERC173Internal {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}

// 

pragma solidity ^0.8.0;



interface IOwnableInternal is IERC173Internal {}

// 

pragma solidity ^0.8.0;




abstract contract OwnableInternal is IOwnableInternal {
    using OwnableStorage for OwnableStorage.Layout;

    modifier onlyOwner() {
        require(
            msg.sender == OwnableStorage.layout().owner,
            'Ownable: sender must be owner'
        );
        _;
    }

    function _owner() internal view virtual returns (address) {
        return OwnableStorage.layout().owner;
    }

    function _transferOwnership(address account) internal virtual {
        OwnableStorage.layout().setOwner(account);
        emit OwnershipTransferred(msg.sender, account);
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @title Partial ERC1155Metadata interface needed by internal functions
 */
interface IERC1155MetadataInternal {
    event URI(string value, uint256 indexed tokenId);
}

// 

pragma solidity ^0.8.0;




/**
 * @title ERC1155Metadata internal functions
 */
abstract contract ERC1155MetadataInternal is IERC1155MetadataInternal {
    /**
     * @notice set base metadata URI
     * @dev base URI is a non-standard feature adapted from the ERC721 specification
     * @param baseURI base URI
     */
    function _setBaseURI(string memory baseURI) internal {
        ERC1155MetadataStorage.layout().baseURI = baseURI;
    }

    /**
     * @notice set per-token metadata URI
     * @param tokenId token whose metadata URI to set
     * @param tokenURI per-token URI
     */
    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal {
        ERC1155MetadataStorage.layout().tokenURIs[tokenId] = tokenURI;
        emit URI(tokenURI, tokenId);
    }
}

// 

pragma solidity ^0.8.0;

// Enums

enum MintState {
	CLOSED,
	CLAIM,
	PRESALE,
	PUBLIC
}

// Init Args

struct LandInitArgs {
	address signer;
	address avatars;
	uint64 price;
	Zone avatarClaim;
	Zone[] zones;
}

// Structs

// waves for sale
// each tranche is mapped to a zone by Id
// except zone 0 which is the claim
// the first 10k are the claim
struct Zone {
	uint8 zoneId;
	uint16 count;
	uint16 max;
	uint24 startIndex;
	uint24 endIndex;
}

// requests

struct ClaimRequest {
	address to;
	uint64 deadline; // block.timestamp
	uint256[] tokenIds;
}

struct MintRequest {
	address to;
	uint64 deadline; // block.timestamp
	uint8 zoneId;
	uint16 count;
}

struct MintManyRequest {
	address to;
	uint64 deadline;
	uint16[] count; // array by zone index
}

// 
pragma solidity ^0.8.0;







abstract contract ERC2981Admin is OwnableInternal {
	
	
	
	function setRoyalties(address recipient, uint256 value) external onlyOwner {
		require(value <= 10000, "ERC2981Royalties: Too high");
		ERC2981Storage.layout().royalties = RoyaltyInfo(recipient, uint24(value));
	}
}

// 

pragma solidity ^0.8.0;

interface IOpenSeaCompatible {
	/**
	 * Get the contract metadata
	 */
	function contractURI() external view returns (string memory);
}

abstract contract OpenSeaCompatibleInternal {
	function _setContractURI(string memory contractURI) internal virtual {
		OpenSeaCompatibleStorage.layout().contractURI = contractURI;
	}
}

// 

pragma solidity ^0.8.0;

library OwnableStorage {
    struct Layout {
        address owner;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.Ownable');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function setOwner(Layout storage l, address owner) internal {
        l.owner = owner;
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @title ERC1155 metadata extensions
 */
library ERC1155MetadataStorage {
    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.ERC1155Metadata');

    struct Layout {
        string baseURI;
        mapping(uint256 => string) tokenURIs;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}

// 

pragma solidity ^0.8.0;












contract LandAdmin is
	OwnableInternal,
	ERC1155MetadataInternal,
	OpenSeaCompatibleInternal,
	ERC2981Admin
{
	// event fired when a proxy is updated
	event SetProxy(address proxy, bool enabled);

	// event fired when a signer is updated
	event SetSigner(address old, address newAddress);

	function addInventory(uint16 zoneId, uint16 count) external onlyOwner {
		Zone storage zone = LandStorage._getZone(zoneId);
		require(
			count <= zone.endIndex - zone.startIndex - zone.max - zone.count,
			"_addInventory: too much"
		);
		LandStorage._addInventory(zone, count);
	}

	function removeInventory(uint16 zoneId, uint16 count) external onlyOwner {
		Zone storage zone = LandStorage._getZone(zoneId);
		require(count <= zone.max - zone.count, "_removeInventory: too much");
		LandStorage._removeInventory(zone, count);
	}

	/**
	 * ability to add a zone.
	 * can be disabled by adding a zone with zero available inventory.
	 */
	function addZone(Zone memory zone) external onlyOwner {
		uint16 index = LandStorage._getIndex();
		Zone memory last = LandStorage._getZone(index);

		require(zone.count == 0, "_addZone: wrong count");
		require(zone.startIndex == last.endIndex, "_addZone: wrong start");
		require(zone.startIndex <= zone.endIndex, "_addZone: wrong end");
		require(zone.max <= zone.endIndex - zone.startIndex, "_addZone: wrong max");
		require(
			zone.endIndex - zone.startIndex <= last.endIndex - last.startIndex,
			"_addZone: too much"
		);

		LandStorage._addZone(zone);
	}

	function setAvatars(address avatars) external onlyOwner {
		LandStorage._setAvatars(avatars);
	}

	function setBaseURI(string memory baseURI) external onlyOwner {
		_setBaseURI(baseURI);
	}

	// can be used to effectively deny claims by setting them to already claimed
	function setClaimedAvatar(uint256 tokenId, address claimedBy) external onlyOwner {
		LandStorage._setClaimedAvatar(tokenId, claimedBy);
	}

	function setContractURI(string memory contractURI) external onlyOwner {
		_setContractURI(contractURI);
	}

	function setIndex(uint16 index) external onlyOwner {
		LandStorage._setIndex(index);
	}

	function setInventory(uint16 zoneId, uint16 maxCount) external onlyOwner {
		Zone storage zone = LandStorage._getZone(zoneId);
		require(maxCount >= zone.count, "_setInventory: invalid");
		require(maxCount <= zone.endIndex - zone.startIndex - zone.count, "_setInventory: too much");
		LandStorage._setInventory(zone, maxCount);
	}

	function setMintState(MintState mintState) external onlyOwner {
		LandStorage.layout().mintState = uint8(mintState);
	}

	function setPrice(uint64 price) external onlyOwner {
		LandStorage._setPrice(price);
	}

	function setProxy(address proxy, bool enabled) external onlyOwner {
		LandStorage._setProxy(proxy, enabled);
		emit SetProxy(proxy, enabled);
	}

	function setOSProxies(address os721Proxy, address os1155Proxy) external onlyOwner {
		OpenSeaProxyStorage._setProxies(os721Proxy, os1155Proxy);
	}

	function setSigner(address signer) external onlyOwner {
		address old = LandStorage._getSigner();
		LandStorage._setSigner(signer);
		emit SetSigner(old, signer);
	}

	function setTokenURI(uint256 tokenId, string memory tokenURI) external onlyOwner {
		_setTokenURI(tokenId, tokenURI);
	}

	function withdraw() external onlyOwner {
		payable(OwnableStorage.layout().owner).transfer(address(this).balance);
	}
}

// 

pragma solidity ^0.8.0;



library LandStorage {
	struct Layout {
		uint8 mintState;
		uint16 index; // current incremental index of zone id's
		uint64 price;
		address signer;
		address avatars;
		Zone avatarClaim; // zoneId is zero
		mapping(uint256 => address) claimedAvatars;
		mapping(uint16 => Zone) zones;
		mapping(address => bool) proxies;
	}

	bytes32 internal constant STORAGE_SLOT = keccak256("io.frogland.contracts.storage.LandStorage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		// slither-disable-next-line timestamp
		// solhint-disable no-inline-assembly
		assembly {
			l.slot := slot
		}
	}

	// Adders

	function _addClaimCount(uint16 count) internal {
		layout().avatarClaim.count += count;
	}

	function _addCount(uint16 index, uint16 count) internal {
		Zone storage zone = _getZone(index);
		_addCount(zone, count);
	}

	function _addCount(Zone storage zone, uint16 count) internal {
		zone.count += count;
	}

	function _addInventory(Zone storage zone, uint16 count) internal {
		zone.max += count;
	}

	function _removeInventory(Zone storage zone, uint16 count) internal {
		zone.max -= count;
	}

	function _addZone(Zone memory zone) internal {
		uint16 index = _getIndex();
		index += 1;
		layout().zones[index] = zone;
		_setIndex(index);
	}

	// Getters

	function _getClaimedAvatar(uint256 tokenId) internal view returns (address) {
		return layout().claimedAvatars[tokenId];
	}

	function _getIndex() internal view returns (uint16 index) {
		return layout().index;
	}

	function _getPrice() internal view returns (uint64) {
		return layout().price;
	}

	function _getSigner() internal view returns (address) {
		return layout().signer;
	}

	function _getZone(uint16 index) internal view returns (Zone storage) {
		if (index == 0) {
			return layout().avatarClaim;
		}
		return layout().zones[index];
	}

	// Setters

	function _setAvatars(address avatars) internal {
		layout().avatars = avatars;
	}

	function _setClaimedAvatar(uint256 tokenId, address claimedBy) internal {
		layout().claimedAvatars[tokenId] = claimedBy;
	}

	function _setClaimedAvatars(uint256[] memory tokenIds, address claimedBy) internal {
		for (uint256 index = 0; index < tokenIds.length; index++) {
			uint256 tokenId = tokenIds[index];
			_setClaimedAvatar(tokenId, claimedBy);
		}
	}

	function _setIndex(uint16 index) internal {
		layout().index = index;
	}

	function _setInventory(Zone storage zone, uint16 maxCount) internal {
		zone.max = maxCount;
	}

	function _setPrice(uint64 price) internal {
		layout().price = price;
	}

	function _setProxy(address proxy, bool enabled) internal {
		layout().proxies[proxy] = enabled;
	}

	function _setSigner(address signer) internal {
		layout().signer = signer;
	}
}

// 

pragma solidity ^0.8.0;

struct RoyaltyInfo {
	address recipient;
	uint24 amount;
}

library ERC2981Storage {
	struct Layout {
		RoyaltyInfo royalties;
	}

	bytes32 internal constant STORAGE_SLOT =
		keccak256("IERC2981Royalties.contracts.storage.ERC2981Storage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		// slither-disable-next-line timestamp
		// solhint-disable no-inline-assembly
		assembly {
			l.slot := slot
		}
	}
}

// 

pragma solidity ^0.8.0;



library OpenSeaCompatibleStorage {
	struct Layout {
		string contractURI;
	}

	bytes32 internal constant STORAGE_SLOT =
		keccak256("com.opensea.contracts.storage.OpenSeaCompatibleStorage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		// slither-disable-next-line timestamp
		// solhint-disable no-inline-assembly
		assembly {
			l.slot := slot
		}
	}
}

abstract contract OpenSeaCompatible is OpenSeaCompatibleInternal, IOpenSeaCompatible {
	function contractURI() external view returns (string memory) {
		return OpenSeaCompatibleStorage.layout().contractURI;
	}
}

// 

pragma solidity ^0.8.0;

struct OpenSeaProxyInitArgs {
	address os721Proxy;
	address os1155Proxy;
}

library OpenSeaProxyStorage {
	struct Layout {
		address os721Proxy;
		address os1155Proxy;
	}

	bytes32 internal constant STORAGE_SLOT = keccak256("com.opensea.contracts.storage.proxy");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		assembly {
			l.slot := slot
		}
	}

	function _setProxies(OpenSeaProxyInitArgs memory init) internal {
		_setProxies(init.os721Proxy, init.os1155Proxy);
	}

	function _setProxies(address os721Proxy, address os1155Proxy) internal {
		layout().os721Proxy = os721Proxy;
		layout().os1155Proxy = os1155Proxy;
	}
}