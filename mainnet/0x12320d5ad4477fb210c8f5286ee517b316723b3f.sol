// SPDX-License-Identifier: CC0-1.0

/**
 *Submitted for verification at Etherscan.io on 2022-08-09
*/

// 
pragma solidity ^0.8.15;

interface IImmutablesArt {
    function anyoneMintProjectEdition(uint) external payable;
    function artistUpdateProjectArtistAddress(uint, address) external;
    function currentTokenId() external view returns (uint);
    function projectIdToRoyaltyAddress(uint) external view returns (address);
    function safeTransferFrom(address, address, uint) external;
}

interface IRoyaltyManager {
    function release() external;
}

contract Fermaminter {
    
    IImmutablesArt public immutable immutablesArt;
    
    uint public immutable projectId;

    IRoyaltyManager private immutable royaltyManager;

    
    address public owner;
    
    mapping(address => bool) public isApproved;

    event Approval(address indexed operator, bool approved);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    error NotApproved();
    error NotOwner();

    constructor(IImmutablesArt immutablesArt_, uint projectId_) {
        immutablesArt = immutablesArt_;
        projectId = projectId_;
        royaltyManager = IRoyaltyManager(immutablesArt_.projectIdToRoyaltyAddress(projectId_));

        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    
    function mint(address to) external payable {
        if (!isApproved[msg.sender] && msg.sender != owner) revert NotApproved();

        immutablesArt.anyoneMintProjectEdition(projectId);
        immutablesArt.safeTransferFrom(address(this), to, immutablesArt.currentTokenId());
    }

    
    function setApproval(address operator, bool approved) external {
        if (msg.sender != owner) revert NotOwner();
        isApproved[operator] = approved;
        emit Approval(operator, approved);
    }

    
    function transferOwnership(address newOwner) external {
        if (msg.sender != owner) revert NotOwner();
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }

    
    function relinquishProject() external {
        if (msg.sender != owner) revert NotOwner();
        immutablesArt.artistUpdateProjectArtistAddress(projectId, owner);
    }

    
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC-165,
            interfaceId == 0x7f5828d0; // ERC-173.
    }

    receive() external payable {}
    fallback() external payable {}

    
    function release() external returns (bytes memory) {
        if (msg.sender != owner) revert NotOwner();
        royaltyManager.release();
        (bool success, bytes memory returndata) = owner.call{value: address(this).balance}("");
        require(success);
        return returndata;
    }

    
    function withdrawl(address erc20, uint value) external returns (bytes memory) {
        if (msg.sender != owner) revert NotOwner();
        // "0xa9059cbb" is the selector for ERC-20 transfer.
        (bool success, bytes memory returndata) = erc20.call(abi.encodeWithSelector(0xa9059cbb, owner, value));
        require(success);
        return returndata;
    }

    
    function call(address contractAddress, bytes calldata data) external payable returns (bytes memory) {
        if (msg.sender != owner) revert NotOwner();
        (bool success, bytes memory returndata) = contractAddress.call{value: msg.value}(data);
        require(success);
        return returndata;
    }
}