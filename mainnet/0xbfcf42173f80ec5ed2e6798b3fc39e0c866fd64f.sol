// SPDX-License-Identifier: AGPL-3.0-only

// 
// Copyright (C) Centrifuge 2020, based on MakerDAO dss https://github.com/makerdao/dss
pragma solidity >=0.5.15;

contract Auth {
    mapping (address => uint256) public wards;
    
    event Rely(address indexed usr);
    event Deny(address indexed usr);

    function rely(address usr) external auth {
        wards[usr] = 1;
        emit Rely(usr);
    }
    function deny(address usr) external auth {
        wards[usr] = 0;
        emit Deny(usr);
    }

    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }

}

// 
// Copyright (C) 2018 Rain <[email protected]>
pragma solidity >=0.5.15;

contract Math {
    uint256 constant ONE = 10 ** 27;

    function safeAdd(uint x, uint y) public pure returns (uint z) {
        require((z = x + y) >= x, "safe-add-failed");
    }

    function safeSub(uint x, uint y) public pure returns (uint z) {
        require((z = x - y) <= x, "safe-sub-failed");
    }

    function safeMul(uint x, uint y) public pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "safe-mul-failed");
    }

    function safeDiv(uint x, uint y) public pure returns (uint z) {
        z = x / y;
    }

    function rmul(uint x, uint y) public pure returns (uint z) {
        z = safeMul(x, y) / ONE;
    }

    function rdiv(uint x, uint y) public pure returns (uint z) {
        require(y > 0, "division by zero");
        z = safeAdd(safeMul(x, ONE), y / 2) / y;
    }

    function rdivup(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "division by zero");
        // always rounds up
        z = safeAdd(safeMul(x, ONE), safeSub(y, 1)) / y;
    }


}

// 
pragma solidity >=0.7.6;



interface MemberlistFabLike {
    function newMemberlist() external returns (address);
}

contract MemberlistFab {
    function newMemberlist() public returns (address memberList) {
        Memberlist memberlist = new Memberlist();

        memberlist.rely(msg.sender);
        memberlist.deny(address(this));

        return (address(memberlist));
    }
}

// 
pragma solidity >=0.7.6;





contract Memberlist is Math, Auth {
    uint256 constant minimumDelay = 7 days;

    // -- Members--
    mapping(address => uint256) public members;

    constructor() {
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    
    
    
    /// minimum 7 days since block.timestamp
    function updateMember(address usr, uint256 validUntil) public auth {
        require((safeAdd(block.timestamp, minimumDelay)) < validUntil);
        members[usr] = validUntil;
    }

    
    
    
    function updateMembers(address[] memory users, uint256 validUntil) public auth {
        for (uint256 i = 0; i < users.length; i++) {
            updateMember(users[i], validUntil);
        }
    }
    
    

    function member(address usr) public view {
        require((members[usr] >= block.timestamp), "not-allowed-to-hold-token");
    }

    
    
    
    function hasMember(address usr) public view returns (bool isMember) {
        if (members[usr] >= block.timestamp) {
            return true;
        }
        return false;
    }
}