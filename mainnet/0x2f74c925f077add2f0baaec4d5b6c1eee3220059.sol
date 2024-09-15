
pragma solidity ^0.4.18;


contract ERC20 {
    function balanceOf(address guy) public view returns (uint);
    function transfer(address dst, uint wad) public returns (bool);
}


contract AccessControl {
    
    event accessGranted(address user, uint8 access);
    
    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    mapping(address => mapping(uint8 => bool)) accessRights;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    
    constructor() public {
        accessRights[msg.sender][1] = true;
        emit accessGranted(msg.sender, 1);
    }

    
    
    
    function grantAccess(address _user, uint8 _transaction) public canAccess(1) {
        require(_user != address(0));
        accessRights[_user][_transaction] = true;
        emit accessGranted(_user, _transaction);
    }

    
    
    
    function revokeAccess(address _user, uint8 _transaction) public canAccess(1) {
        require(_user != address(0));
        accessRights[_user][_transaction] = false;
    }

    
    
    
    function hasAccess(address _user, uint8 _transaction) public view returns (bool) {
        require(_user != address(0));
        return accessRights[_user][_transaction];
    }

    
    
    modifier canAccess(uint8 _transaction) {
        require(accessRights[msg.sender][_transaction]);
        _;
    }

    
    function withdrawBalance() external canAccess(2) {
        msg.sender.transfer(address(this).balance);
    }

    
    function withdrawTokens(address tokenContract) external canAccess(2) {
        ERC20 tc = ERC20(tokenContract);
        tc.transfer(msg.sender, tc.balanceOf(this));
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
    function pause() public canAccess(1) whenNotPaused {
        paused = true;
    }

    
    function unpause() public canAccess(1) whenPaused {
        paused = false;
    }
}



contract BizancioCertificate is AccessControl {

    struct Certificate {
        string name;
        string email;
        string course;
        string dates;
        uint16 courseHours;
        bool valid;
    }
    
    mapping (bytes32 => Certificate) public certificates;
    event logPrintedCertificate(bytes32 contractAddress, string _name, string email, string _course, string _dates, uint16 _hours);

    function printCertificate (string _name, string _email, string _course, uint16 _hours, string _dates) public canAccess(3) whenNotPaused returns (bytes32 _certificateAddress) {

        // creates certificate smart contract
        bytes32 certificateAddress = keccak256(block.number, now, msg.data);

        // create certificate data
        certificates[certificateAddress] = Certificate(_name, _email, _course, _dates, _hours, true);
        
        // creates the event, to be used to query all the certificates
        emit logPrintedCertificate(certificateAddress, _name, _email, _course, _dates, _hours);

        return certificateAddress;
    }
    
    // @dev Invalidates a deployed certificate
    function invalidateCertificate(bytes32 _certificateAddress) external canAccess(3) {
        certificates[_certificateAddress].valid = false;
    }

}