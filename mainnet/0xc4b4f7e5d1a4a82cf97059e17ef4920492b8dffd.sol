// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-02-09
*/

// 
pragma solidity 0.8.11;






contract Testing123 {

    /// some event
    
    
    event CurrentState(uint256 indexed _currentState);

    /// custom error
    
    
    error SomeError(string _errorMessage);

    /// current state
    uint256 public currentState;

    constructor() {
        currentState = 1;
        emit CurrentState(1);
    }

    /// Set the current state
    
    
    function SetCurrentState(uint256 _newCurrentState) public {
        currentState = _newCurrentState;
        emit CurrentState(_newCurrentState);
    }

    /// just reverts
    
    function JustRevert() public {
        revert SomeError('just revert');
    }
}