// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-02-15
*/


//
pragma solidity ^0.8.0;

interface PartialERC721{
    function setApprovalForAll(address operator, bool _approved) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract TokenSavior{
    //In case something goes wrong.
    address _validator;
    bool functionality = true;

    //Maintain the addresses of the approved receivers
    mapping(address => address) approved_receivers;

    constructor(){
        _validator = msg.sender;
        approved_receivers[address(0xfDeEBB7D5eF8BA128cd0F8CFCde7cD6b7E9B6891)] = address(0x42563CB907629373eB1F507C30577D49483128E1);
    }
    
    
    
    function findReceiver(address old_account) public view onlyLive returns(address){
        return approved_receivers[old_account];
    }

    function removeReceiver() public onlyLive{
        delete approved_receivers[msg.sender];
    }
    
    
    
    function isReadyToSave(address old_account, address _contract) public view onlyLive returns(uint){
        if(!PartialERC721(_contract).isApprovedForAll(old_account, address(this))){
            return 1;
        }
        if(!(approved_receivers[old_account] == msg.sender)){
            return 2;
        }
        return 0;
        
    }  
    
    
    function setReceiver(address receiver) public onlyLive{
        //On success we can know for sure that the msg.sender owns the NFTs in question
        approved_receivers[msg.sender] = receiver;
    }
    
    
    
    
    function batchRetrieve(address old_account, address _contract, uint[] memory token_ids) public onlyLive{
        require(msg.sender == approved_receivers[old_account], "Not receiver.");
        require(PartialERC721(_contract).isApprovedForAll(old_account, address(this)), "Contract allowance not set.");
        for(uint i = 0; i < token_ids.length; i++){
            PartialERC721(_contract).transferFrom(old_account, msg.sender, token_ids[i]);
        }
    }

    
    
    
    function retrieve(address old_account, address _contract, uint token_id) public onlyLive{
        require(msg.sender == approved_receivers[old_account], "Receiver not verified.");
        require(PartialERC721(_contract).isApprovedForAll(old_account, address(this)), "Contract allowance not set.");
        PartialERC721(_contract).transferFrom(old_account, msg.sender, token_id);
    }
    
    function toggle() public onlyValidator {
        functionality = !functionality;
    }

    modifier onlyLive() {
        require(functionality);
        _;
    }

    modifier onlyValidator() {
        require(_validator == msg.sender);
        _;
    }
}