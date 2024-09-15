// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2023-01-26
*/

// 
pragma solidity ^0.8.4;




contract DataRoom {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event PermissionSet(
        address indexed dao,
        address indexed account,
        bool permissioned
    );

    event RecordSet (
        address indexed dao,
        string data,
        address indexed caller
    );  
   
    /// -----------------------------------------------------------------------
    /// Custom Errors
    /// -----------------------------------------------------------------------

    error Unauthorized();

    error LengthMismatch();

    error InvalidRoom();

    /// -----------------------------------------------------------------------
    /// DataRoom Storage
    /// -----------------------------------------------------------------------

    mapping(address => string[]) public room;

    mapping(address => mapping(address => bool)) public authorized;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor() payable {}

    /// -----------------------------------------------------------------------
    /// DataRoom Logic
    /// -----------------------------------------------------------------------

    
    
    
    
    function setRecord(
        address account, 
        string[] calldata data
    ) 
        public 
        payable
        virtual
    {
        // Initialize Room.
        if (account == msg.sender && !authorized[account][msg.sender]) {
            authorized[account][msg.sender] = true;
        }
        
        _authorized(account, msg.sender);

        for (uint256 i; i < data.length; ) {
            room[account].push(data[i]);
            
            emit RecordSet(account, data[i], msg.sender);
            
            // Unchecked because the only math done is incrementing
            // the array index counter which cannot possibly overflow.
            unchecked {
                ++i;
            }
        }
    }

    
    
    
    function getRoom(address account) 
        public 
        view
        virtual
        returns (string[] memory) 
    {
        return room[account];
    }

    
    
    
    
    
    function setPermission(
        address account,
        address[] calldata users,
        bool[] calldata authorize
    ) 
        public 
        payable
        virtual
    {  
        if (account == address(0)) revert InvalidRoom();

        // Initialize Room.
        if (account == msg.sender && !authorized[account][msg.sender]) {
            authorized[account][msg.sender] = true;
        }
        
        _authorized(account, msg.sender);

        uint256 numUsers = users.length;

        if (numUsers != authorize.length) revert LengthMismatch();

        if (numUsers != 0) {
            for (uint i; i < numUsers; ) {
                authorized[account][users[i]] = authorize[i];
                
                emit PermissionSet(account, users[i], authorize[i]);
                
                // Unchecked because the only math done is incrementing
                // the array index counter which cannot possibly overflow.
                unchecked {
                    ++i;
                }
            }
        }
    }

    /// -----------------------------------------------------------------------
    /// Internal Functions
    /// -----------------------------------------------------------------------

    
    
    
    function _authorized(address account, address user) internal view virtual returns (bool) {
        if (authorized[account][user]) return true;
        else revert Unauthorized();
    }
}