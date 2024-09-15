// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2023-02-02
*/

// 
pragma solidity >=0.8.4;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}





///         to control their tokens using either `setApproveForAll` or `approve` functions from
//          the ERC721 contract.
contract ERC721BatchTransfer {
    
    error InvalidArguments();
    
    error NotOwnerOfToken();
    
    error InvalidCaller();

    event BatchTransferToSingle(
        address indexed contractAddress,
        address indexed to,
        uint256 amount
    );

    event BatchTransferToMultiple(
        address indexed contractAddress,
        uint256 amount
    );

    // solhint-disable-next-line no-empty-blocks
    constructor() {}

    modifier noZero() {
        if (msg.sender == address(0)) revert InvalidCaller();
        _;
    }

    
    
    
    
    
    function batchTransferToSingleWallet(
        IERC721 erc721Contract,
        address to,
        uint256[] calldata tokenIds
    ) external noZero {
        uint256 length = tokenIds.length;
        for (uint256 i; i < length; ) {
            uint256 tokenId = tokenIds[i];
            address owner = erc721Contract.ownerOf(tokenId);
            if (msg.sender != owner) {
                revert NotOwnerOfToken();
            }
            erc721Contract.transferFrom(owner, to, tokenId);
            unchecked {
                ++i;
            }
        }
        emit BatchTransferToSingle(address(erc721Contract), to, length);
    }

    
    
    
    
    function safeBatchTransferToSingleWallet(
        IERC721 erc721Contract,
        address to,
        uint256[] calldata tokenIds
    ) external noZero {
        uint256 length = tokenIds.length;
        for (uint256 i; i < length; ) {
            uint256 tokenId = tokenIds[i];
            address owner = erc721Contract.ownerOf(tokenId);
            if (msg.sender != owner) {
                revert NotOwnerOfToken();
            }
            erc721Contract.safeTransferFrom(owner, to, tokenId);
            unchecked {
                ++i;
            }
        }
        emit BatchTransferToSingle(address(erc721Contract), to, length);
    }

    
    
    
    
    ///         0x..1 will receive token 1;
    ///         0x..2 will receive token 2;
    //          0x..3 will receive token 3;
    
    
    
    function batchTransferToMultipleWallets(
        IERC721 erc721Contract,
        address[] calldata tos,
        uint256[] calldata tokenIds
    ) external noZero {
        uint256 length = tokenIds.length;
        if (tos.length != length) revert InvalidArguments();

        for (uint256 i; i < length; ) {
            uint256 tokenId = tokenIds[i];
            address owner = erc721Contract.ownerOf(tokenId);
            address to = tos[i];
            if (msg.sender != owner) {
                revert NotOwnerOfToken();
            }
            erc721Contract.transferFrom(owner, to, tokenId);
            unchecked {
                ++i;
            }
        }

        emit BatchTransferToMultiple(address(erc721Contract), length);
    }

    
    
    
    ///         0x..1 will receive token 1;
    ///         0x..2 will receive token 2;
    //          0x..3 will receive token 3;
    
    
    
    function safeBatchTransferToMultipleWallets(
        IERC721 erc721Contract,
        address[] calldata tos,
        uint256[] calldata tokenIds
    ) external noZero {
        uint256 length = tokenIds.length;
        if (tos.length != length) revert InvalidArguments();

        for (uint256 i; i < length; ) {
            uint256 tokenId = tokenIds[i];
            address owner = erc721Contract.ownerOf(tokenId);
            address to = tos[i];
            if (msg.sender != owner) {
                revert NotOwnerOfToken();
            }
            erc721Contract.safeTransferFrom(owner, to, tokenId);
            unchecked {
                ++i;
            }
        }

        emit BatchTransferToMultiple(address(erc721Contract), length);
    }
}