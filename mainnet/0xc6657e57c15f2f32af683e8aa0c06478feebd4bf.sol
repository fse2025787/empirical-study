
// CryptoRabbit Source code

pragma solidity ^0.4.18;







contract OwnerBase {

    // The addresses of the accounts that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;
    
    /// constructor
    function OwnerBase() public {
       ceoAddress = msg.sender;
       cfoAddress = msg.sender;
       cooAddress = msg.sender;
    }

    
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }
    
    
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    
    
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }


    
    
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }
    
    
    
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    
    modifier whenPaused {
        require(paused);
        _;
    }

    
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCOO whenNotPaused {
        paused = true;
    }

    
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    
    ///  derived contracts.
    function unpause() public onlyCOO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}






contract FoodStore is OwnerBase {
	/// event
	event Bought(address buyer, uint32 bundles);
	
	
    event ContractUpgrade(address newContract);

	
    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;
    
    // Price (in wei) for food
    uint public price = 10 finney;    
    
    
    

    
    function FoodStore() public {
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;
        cooAddress = msg.sender;
        cfoAddress = msg.sender;
    }
    
        
    
    
    function buyFood(uint32 _bundles) external payable whenNotPaused returns (bool) {
		require(newContractAddress == address(0));
		
        uint cost = _bundles * price;
		require(msg.value >= cost);
		
        // Return the funds. 
        uint fundsExcess = msg.value - cost;
        if (fundsExcess > 1 finney) {
            msg.sender.transfer(fundsExcess);
        }
		emit Bought(msg.sender, _bundles);
        return true;
    }
    
    

    
    
    function upgradeContract(address _v2Address) external onlyCOO whenPaused {
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    // @dev Allows the CEO to capture the balance available to the contract.
    function withdrawBalance() external onlyCFO {
        address tmp = address(this);
        cfoAddress.transfer(tmp.balance);
    }
}