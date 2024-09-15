// SPDX-License-Identifier: AGPL-3.0-only


// 
pragma solidity ^0.8.15;




interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// 
pragma solidity ^0.8.15;







contract NftChecker {
    
    function areOwners(address[] memory targets, address[] memory potentialOwners) public view returns (bool) {
        uint256 targetsLength = targets.length;
        uint256 potentialOwnersLength = potentialOwners.length;
        uint256 i;
        uint256 j;
        // for every contract in the targets array
        for (i = 0; i < targetsLength;) {
            // for every address in the potential owners array
            for (j = 0; j < potentialOwnersLength;) {
                // if the potential owner is an actual owner, return true
                if (IERC721(targets[i]).balanceOf(potentialOwners[j]) > 0) {
                    return true;
                }
                unchecked {
                    ++j;
                }
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }
}

// 
pragma solidity ^0.8.15;





interface IERC721 is IERC165 {
    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) external view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) external view returns (address owner);

    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    
    function transferFrom(address from, address to, uint256 tokenId) external;

    
    function approve(address to, uint256 tokenId) external;

    
    function setApprovalForAll(address operator, bool _approved) external;

    
    function getApproved(uint256 tokenId) external view returns (address operator);

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
