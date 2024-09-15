pragma experimental ABIEncoderV2;

pragma solidity >=0.7.0;



/**
* @title MarketsRegistry
* @dev Implements market proposal and approval/denial
 */
contract MarketsRegistry {

    
    mapping(address=>uint) public admins;

    modifier onlyAdmin() {
        require(admins[msg.sender] == 1, "Not admin");
        _;
    }

    function addAdmin(address newAdmin) onlyAdmin public {
        admins[newAdmin] = 1;
        emit AddNewAdministrator(msg.sender, newAdmin);
    }

    function removeAdmin(address admin) onlyAdmin public {
        admins[admin] = 0;
        emit RemoveAdminstrator(msg.sender, admin);
    }
    
    struct MarketProposal {
        uint marketProposalId;
        string title;
        string description;
        uint resolutionTimestampUnix;
        bool approved;
    }

    
    uint public marketProposalCount;

    
    uint public totalPendingProposals;

    
    uint public totalApprovedProposals;

    
    mapping(uint => MarketProposal) public proposals;

    // Events
    
    
    event AddNewAdministrator(address admin, address newAdmin);

    
    event RemoveAdminstrator(address admin, address removedAdmin);

    
    event ProposalSubmitted(address proposer, uint marketProposalId, string title, string description, uint resolutionTimestamp);
    
    
    event ProposalApproved(address admin, uint marketProposalId);
    
    
    event ProposalDenied(address admin, uint marketProposalId);

    constructor(){
        admins[msg.sender] = 1;
    }

    
    function getAllApprovedMarketProposals() external view returns (MarketProposal[] memory){
        MarketProposal[] memory marketProposals = new MarketProposal[](totalApprovedProposals);
        for(uint i = 0; i < marketProposalCount; i++){
            MarketProposal storage marketProposal = proposals[i];
            
            //check that the MarketProposal struct has been initialized and approved
            if(bytes(marketProposal.title).length > 0 && marketProposal.approved == true){
                marketProposals[i] = marketProposal;
            }
        }
        return marketProposals;
    }

    
    function getPendingMarketProposals() external view returns (MarketProposal[] memory){
        MarketProposal[] memory marketProposals = new MarketProposal[](totalPendingProposals);
        for(uint i = 0; i < marketProposalCount; i++){
            MarketProposal storage marketProposal = proposals[i];
            if(bytes(marketProposal.title).length > 0 && marketProposal.approved == false){
                marketProposals[i] = marketProposal;
            }
        }
        return marketProposals;
    }

    
    function submitNewMarketProposal(string calldata title, string calldata description, uint resolutionTimestamp) external returns (uint) {
        uint proposalId = marketProposalCount;
        proposals[proposalId] = MarketProposal({
            marketProposalId: proposalId, 
            title: title, 
            description: description, 
            resolutionTimestampUnix: resolutionTimestamp, 
            approved: false
        });

        marketProposalCount++;
        totalPendingProposals++;
        emit ProposalSubmitted(msg.sender, proposalId, title, description, resolutionTimestamp);
        return proposalId;
    }

    function approveMarketProposal(uint marketProposalId) onlyAdmin external {
        MarketProposal storage marketProposal = proposals[marketProposalId];
        //require that the marketProposal struct was initialized
        require(isMarketProposalInitialized(marketProposal), "MarketProposal doesn't exist");    
        //necessary so we dont approve a proposal twice 
        require(!marketProposal.approved, "MarketProposal already approved");
        
        marketProposal.approved = true;
        totalApprovedProposals++;
        totalPendingProposals--;
        emit ProposalApproved(msg.sender, marketProposalId);
    }

    function denyMarketProposal(uint marketProposalId) onlyAdmin external {
        MarketProposal storage marketProposal = proposals[marketProposalId];
        //require that the marketProposal struct was initialized
        require(isMarketProposalInitialized(marketProposal), "MarketProposal doesn't exist");

        if(marketProposal.approved == true){
            //If the market proposal has already been approved, decrement totalApprovedProposals 
            totalApprovedProposals--;
        } 
        if(marketProposal.approved == false){
            //If the market proposal is pending, decrement totalPendingProposals
            totalPendingProposals--;
        }
        delete proposals[marketProposalId];
        emit ProposalDenied(msg.sender, marketProposalId);
    }

    function isMarketProposalInitialized(MarketProposal memory marketProposal) internal pure returns (bool) {
        return bytes(marketProposal.title).length > 0;
    }

}

