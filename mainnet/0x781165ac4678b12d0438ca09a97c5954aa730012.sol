// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-02-06
*/

//
pragma solidity ^0.8.10;

// Title: ⌐◨-◨ Caterpillar V2
// Contract by: @backseats_eth

// This is an experimental implementation of an allow list game for NounCats (NounCats.com / @NounCats on Twitter).
// Periodically, this contract will open up and anyone can add themselves to the allow list before we mint.

// NEW IN V2: Add yourself, add your friend, and give to a good cause!

// Find V1 of the NounCaterpillar here: https://www.contractreader.io/contract/0x74a2867c2740bd3f12b4a5a78a9b6938782c445a

// DISCLAIMER: Yes, there are better and gasless ways to run an allow list (like a Google Form, lol). 
// This is not our only way of taking addresses before mint. It's just a fun one. 
contract NounCaterpillarV2 {
    
    // How many open slots are currently available in this contract
    uint8 public openSlots;
    
    // Using a bytes32 array rather than an array of addresses to save space and save the user on gas costs. 
    // These will eventually be used in a Merkle tree which the bytes32[] also lends itself to.
    bytes32[] public addresses;

    // A mapping to make sure you haven't been here before
    mapping(bytes32 => bool) private addressMapping;

    // Owner and donation wallet addresses
    address private owner = 0x3a6372B2013f9876a84761187d933DEe0653E377;
    address private donationWallet = 0x1D4f4dd22cB0AF859E33DEaF1FF55d9f6251C56B;

    // A simplified implementation of Ownable 
    modifier onlyOwner { 
        require(msg.sender == owner, "Not owner");
        _;
    }

    
    /// If Metamask or another wallet shows a ridiculous gas price, open slots == 0 or you're already on the list! Don't submit that transaction
    function addMeToAllowList() external {
        require(openSlots > 0, "Wait for spots to open up");
        bytes32 encoded = keccak256(abi.encodePacked(msg.sender));
        require(!addressMapping[encoded], "Already on list");
        addressMapping[encoded] = true;
        openSlots -= 1;
        addresses.push(encoded);
        delete encoded;
    }

    
    /// All proceeds will be donated to a good cause, to be determined by the Noun Cats Discord.
    
    function giveTwoGetOne(address _giveTo) payable external { 
        require(msg.value == 0.01 ether, 'Wrong price');
        bytes32 you = keccak256(abi.encodePacked(msg.sender));
        bytes32 yourFriend = keccak256(abi.encodePacked(_giveTo));
        require(!addressMapping[you], "You're already on list");
        require(!addressMapping[yourFriend], "They're already on list");
        addresses.push(you);
        addresses.push(yourFriend);
        delete you;
        delete yourFriend;
    }

    
    function extendCaterpillar(uint8 _newSlots) external onlyOwner { 
        openSlots += _newSlots;
    }
    
    
    function withdraw() external payable onlyOwner { 
        payable(donationWallet).transfer(address(this).balance);
    }

}