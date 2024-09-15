
// Lottery Source code

pragma solidity ^0.4.21;




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
    
    
    
    function isNormalUser(address addr) internal view returns (bool) {
        if (addr == address(0)) {
            return false;
        }
        uint size = 0;
        assembly { 
            size := extcodesize(addr) 
        } 
        return size == 0;
    }
}


contract Lottery is OwnerBase {

    event Winner( address indexed account,uint indexed id, uint indexed sn );
    
    uint public price = 1 finney;
    
    uint public reward = 10 finney;
    
    uint public sn = 1;
    
    uint private seed = 0;
    
    
    
    function Lottery() public {
        ceoAddress = msg.sender;
        cooAddress = msg.sender;
        cfoAddress = msg.sender;
        seed = now;
    }
    
    
    function setSeed( uint val) public onlyCOO {
        seed = val;
    }
    
    
    function() public payable {
        // get ether, maybe from coo.
    }
        
    
    
    
    function buy(uint id) payable public {
        require(isNormalUser(msg.sender));
        require(msg.value >= price);
        uint back = msg.value - price;  
        
        sn++;
        uint sum = seed + sn + now + uint(msg.sender);
        uint ran = uint16(keccak256(sum));
        if (ran * 10000 < 880 * 0xffff) { // win the reward 
            back = reward + back;
            emit Winner(msg.sender, id, sn);
        }else{
            emit Winner(msg.sender, id, 0);
        }
        
        if (back > 1 finney) {
            msg.sender.transfer(back);
        }
    }
    
    

    // @dev Allows the cfo to capture the balance.
    function cfoWithdraw( uint remain) external onlyCFO {
        address myself = address(this);
        require(myself.balance > remain);
        cfoAddress.transfer(myself.balance - remain);
    }
    
    
    
    
}