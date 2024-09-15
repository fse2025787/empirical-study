// SPDX-License-Identifier: MIT

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
pragma solidity ^0.8.13;



error StatusError(uint256 identifier, uint256 status);

abstract contract StatusPrimitive {
    mapping (uint256=>uint256) internal _status;
}

// 
pragma solidity ^0.8.13;

interface IImplementResult {

    enum VotingStatusImplement {inactive, completed, failed, active, awaitcall}
    
    enum Response {precall, successful, failed}

    
    
    
    
    function implement(uint256 identifier, bytes calldata callback) 
    external payable
    returns(Response response); 
}

// 
pragma solidity ^0.8.13;


interface IStatusGetter {
    function getStatus(uint256 identifier) external view returns(uint256 status);
}

// 
pragma solidity ^0.8.13;


interface ITargetGetter {
    function getTarget(uint256 identifier) external view returns(address target);
}

// 
pragma solidity ^0.8.13;




abstract contract CallbackHashPrimitive {
    mapping(uint256=>bytes32) internal _callbackHash;
}

// 
pragma solidity ^0.8.13;






abstract contract ImplementingPermitted is StatusPrimitive {
    
    function _implementingPermitted(uint256 identifier) virtual internal view returns(bool permitted) {
        permitted = _status[identifier] == uint256(IImplementResult.VotingStatusImplement.awaitcall);
    }

}


abstract contract ImplementResultPrimitive {

    
    
    
    
    
    
    function _implement(address _contract, bytes memory callback) 
    internal 
    virtual
    returns(IImplementResult.Response, bytes memory)
    {
        (bool success, bytes memory errorMessage) = _contract.call{value: msg.value}(callback);
        IImplementResult.Response response = success ? IImplementResult.Response.successful : IImplementResult.Response.failed; 
        return (response, errorMessage);
    }
}

abstract contract HandleImplementationResponse {

    event Implemented(uint256 identifier);
    
    event NotImplemented(uint256 identifier);

    
    
    
    function _handleFailedImplementation(uint256 identifier, bytes memory responseData) 
    virtual
    internal 
    returns(IImplementResult.Response responseStatus)
    {}

    function _handleNotFailedImplementation(uint256 identifier, bytes memory responseData)
    virtual
    internal
    returns(IImplementResult.Response responseStatus)
    {}

}

// 
pragma solidity ^0.8.13;




abstract contract TargetPrimitive {    
    mapping (uint256=>address) internal _target;
}

//
pragma solidity ^0.8.13;







///      It can be thought of as a standalone contract that handles the entire life-cycle of voting, 
///      from the initialization, via the casting of votes to the retrieval of results. Optionally it can
///      be extended by the functionality of triggering the outcome of the vote through a call whose calldata is already passsed at the initialization. 
///      The standard allows for a great deal of versatility and modularity. Versatility stems from the fact that 
///      the standard doesn't prescribe any particular way of defining the votes and the status of the vote. But it does
///      define a universal interface used by them all.  



interface IVotingContract is IERC165{
    ///  Note: the ERC-165 identifier for this interface is 0x9452d78d.
    ///  0x9452d78d ===
    ///         bytes4(keccak256('start(bytes,bytes)')) ^
    ///         bytes4(keccak256('vote(uint256,bytes)')) ^
    ///         bytes4(keccak256('result(uint256)'));
    ///

    
    ///         'inactive', 'completed' and 'failed'.
    enum VotingStatus {inactive, completed, failed, active}

    
    event VotingInstanceStarted(uint256 indexed identifier, address caller);

    
    
    
    
    function start(bytes memory votingParams, bytes calldata callback) external returns(uint256 identifier); 

    
    
    
    
    function vote(uint256 identifier, bytes calldata votingData) external returns(uint256 status);

    
    
    
    
    function result(uint256 identifier) external view returns(bytes memory resultData);

}
////////////////////////////////////////////////////////////////////////////
//                                                                        //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░░░░░░░░░██╗░░░██╗░█████╗░████████╗██╗███╗░░██╗░██████╗░░░░░░░░░░░░░ //
// ░░░░░░░░░░░██║░░░██║██╔══██╗╚══██╔══╝██║████╗░██║██╔════╝░░░░░░░░░░░░░ //
// ░░░░░░░░░░░╚██╗░██╔╝██║░░██║░░░██║░░░██║██╔██╗██║██║░░██╗░░░░░░░░░░░░░ //
// ░░░░░░░░░░░░╚████╔╝░██║░░██║░░░██║░░░██║██║╚████║██║░░╚██╗░░░░░░░░░░░░ //
// ░░░░░░░░░░░░░╚██╔╝░░╚█████╔╝░░░██║░░░██║██║░╚███║╚██████╔╝░░░░░░░░░░░░ //
// ░░░░░░░░░░░░░░╚═╝░░░░╚════╝░░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░░░░░░░░░░░░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //    
// ░░░█████╗░░█████╗░███╗░░██╗████████╗██████╗░░█████╗░░█████╗░████████╗░ //
// ░░██╔══██╗██╔══██╗████╗░██║╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝░ //
// ░░██║░░╚═╝██║░░██║██╔██╗██║░░░██║░░░██████╔╝███████║██║░░╚═╝░░░██║░░░░ //
// ░░██║░░██╗██║░░██║██║╚████║░░░██║░░░██╔══██╗██╔══██║██║░░██╗░░░██║░░░░ //
// ░░╚█████╔╝╚█████╔╝██║░╚███║░░░██║░░░██║░░██║██║░░██║╚█████╔╝░░░██║░░░░ //
// ░░░╚════╝░░╚════╝░╚═╝░░╚══╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY without even the implied warranty of MERCHANTABILITY 
// or FITNESS FOR A PARTICULAR PURPOSE. See the 
// GNU Affero General Public License for more details.
//
//
// 
pragma solidity ^0.8.13;










abstract contract BaseVotingContract is TargetPrimitive, StatusPrimitive, IERC165, IVotingContract {
    

    //////////////////////////////////////////////////
    // STATE VARIABLES                              //
    //////////////////////////////////////////////////

    uint256 private _currentIndex; 

    //////////////////////////////////////////////////
    // WRITE FUNCTIONS                              //
    //////////////////////////////////////////////////

    
    
    function start(bytes memory votingParams, bytes calldata callback)
    public
    virtual
    override(IVotingContract) 
    returns(uint256 identifier) {
        
        // Start the voting Instance
        _start(_currentIndex, votingParams, callback);

        // emit event
        emit VotingInstanceStarted(_currentIndex, msg.sender);
        
        // return the identifier of this voting instance
        identifier = _currentIndex;
        
        // increment currentIndex
        _currentIndex += 1;
    }


    
    
    
    function vote(uint256 identifier, bytes calldata votingData) 
    external 
    virtual 
    override(IVotingContract) 
    returns (uint256 status);
    

    //////////////////////////////////////////////////
    // INTERNAL HELPER FUNCTIONS                    //
    //////////////////////////////////////////////////

    
    
    
    function _start(uint256 identifier, bytes memory votingParams, bytes calldata callback) virtual internal;


    
    
    function _checkCondition(uint256 identifier) internal view virtual returns(bool condition) {}


    //////////////////////////////////////////////////
    // GETTER FUNCTIONS                             //
    //////////////////////////////////////////////////

    
    
    function result(uint256 identifier) public view virtual override(IVotingContract) returns(bytes memory resultData);


    function getCurrentIndex() external view returns(uint256 currentIndex) {
        currentIndex = _currentIndex;
    }


    function supportsInterface(bytes4 interfaceId) public pure virtual override(IERC165) returns (bool) {
        return 
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IVotingContract).interfaceId;
    }
}

// 
pragma solidity ^0.8.13;


interface IGetCallbackHash {
    function getCallbackHash(uint256 identifier) external view returns(bytes32 callbackHash);
}

// 
pragma solidity ^0.8.13;


interface IGetDeadline {
    function getDeadline(uint256 identifier) external view returns(uint256);
}

// 
pragma solidity ^0.8.13;



interface IGetDoubleVotingGuard{
    function getDoubleVotingGuard(uint256 identifier) external view returns(HandleDoubleVotingGuard.VotingGuard);
}

// 
pragma solidity ^0.8.13;


interface IGetQuorum {
    function getQuorum(uint256 identifier) external view returns(uint256 quorum, uint256 inUnitsOf);
}

// 
pragma solidity ^0.8.13;


interface IHasAlreadyVoted {
    function hasAlreadyVoted(uint256 identifier, address voter) external view returns(bool alreadyVoted);
}

// 
pragma solidity ^0.8.13;





interface IImplementingPermitted {

    error ImplementingNotPermitted(uint256 identifier, uint256 status);

    
    
    
    
    function implementingPermitted(uint256 identifier) external view returns(bool permitted);
}

// 
pragma solidity ^0.8.13;



contract CastSimpleVote {

    mapping(uint256=>int256) internal _vote;

    function _castVote(uint256 identifier, int256 amount) internal {
        // Since solidity 0.8.0 this will throw an error for amounts bigger than 2^(255-1), as it should!
        _vote[identifier] += int256(amount);
    }

    function _getVotes(uint256 identifier) internal view returns(int256 amount) {
        return _vote[identifier];
    }
}

// 
pragma solidity ^0.8.13;




abstract contract CheckCalldataValidity is CallbackHashPrimitive {
    
    error InvalidCalldata();
    
    function _isValidCalldata(uint256 identifier, bytes calldata callback)
    internal 
    view
    returns(bool isValid)
    {
        isValid = CallbackHashPrimitive._callbackHash[identifier] == keccak256(callback);
    }
}

// 
pragma solidity ^0.8.13;


contract Deadline {

    error DeadlineHasPassed(uint256 identifier, uint256 deadline);
    error DeadlineHasNotPassed(uint256 identifier, uint256 deadline);

    mapping(uint256=>uint256) internal _deadline;

    function _setDeadline(uint256 identifier, uint256 duration) internal {
        _deadline[identifier] = block.timestamp + duration;
    }

    function _deadlineHasPassed(uint256 identifier) internal view returns(bool hasPassed) {
        hasPassed = block.timestamp > _deadline[identifier];
    }
}

// 
pragma solidity ^0.8.13;








abstract contract ImplementResult is
IImplementResult,
TargetPrimitive,
ImplementingPermitted,
HandleImplementationResponse,
ImplementResultPrimitive
{
    
    
    
    
    
    function implement(uint256 identifier, bytes calldata callback) 
    external 
    payable
    override(IImplementResult)
    returns(IImplementResult.Response) {

        // check whether the current voting instance allows implementation
        if(!_implementingPermitted(identifier)) {
            revert IImplementingPermitted.ImplementingNotPermitted(identifier, _status[identifier]);
        }

        // check wether this is the correct calldata for the voting instance
        _requireValidCallbackData(identifier, callback);

        // retrieve calling contract from the identifier.
        address callingContract = TargetPrimitive._target[identifier];
        
        // implement the result
        (
            IImplementResult.Response _responseStatus,
            bytes memory _responseData
        ) = ImplementResultPrimitive._implement(
                callingContract, 
                abi.encodePacked(callback, identifier)  // add the identifier to the calldata for good measure (added security!)
            );
        
        // check whether the response from the call was susccessful
        if (_responseStatus == IImplementResult.Response.successful) {
            // calling a non-contract address by accident can result in a successful response, when it shouldn't.
            // That's why the user is encouraged to implement a return value to the target function and pass to the 
            // votingParams a flag that a return value should be expected.
            _responseStatus = _handleNotFailedImplementation(identifier, _responseData);
        } else {
            // this can be implemented by the user.
            _responseStatus = _handleFailedImplementation(identifier, _responseData);
        } 

        _status[identifier] = _responseStatus == IImplementResult.Response.successful? 
            uint256(IImplementResult.VotingStatusImplement.completed): 
            uint256(IImplementResult.VotingStatusImplement.failed);

        return _responseStatus;
    } 

    function _requireValidCallbackData(uint256 identifier, bytes calldata callback) internal virtual view {}

        
}

// 
pragma solidity ^0.8.13;




abstract contract ExpectReturnValue {
    // Expected Return
    mapping(uint256 => bool) internal _expectReturnValue;

    // Corresponding Error Message
    error ExpectedReturnError(uint256 identifier);
}

// 
pragma solidity ^0.8.13;





abstract contract NoDoubleVoting  {
    
    error AlreadyVoted(uint256 identifier, address voter);
    
    mapping(uint256=>mapping(address=>bool)) internal _alreadyVoted;

}

// 
pragma solidity ^0.8.13;

abstract contract QuorumPrimitive {
    mapping(uint256=>uint256) internal _quorum;
}


abstract contract StatusGetter is StatusPrimitive, IStatusGetter {
    
    function getStatus(uint256 identifier) public view virtual override(IStatusGetter) returns(uint256 status) {
        status = _status[identifier];
    } 
}


abstract contract TargetGetter is TargetPrimitive, ITargetGetter {
    
    function getTarget(uint256 identifier) public view virtual override(ITargetGetter) returns(address target) {
        target = _target[identifier];
    } 
}

// 
pragma solidity ^0.8.13;


interface IGetToken {
    function getToken(uint256 identifier) external view returns(address token);
}

abstract contract CallbackHashGetter is IGetCallbackHash, CallbackHashPrimitive{

    function getCallbackHash(uint256 identifier) public view virtual override(IGetCallbackHash) returns(bytes32) {
        return _callbackHash[identifier];
    }

}

abstract contract ImplementingPermittedPublicly is IImplementingPermitted, ImplementingPermitted {
    function implementingPermitted(uint256 identifier) external view override(IImplementingPermitted) returns(bool permitted) {
        permitted = _implementingPermitted(identifier);
    }
}




abstract contract ImplementResultWithInsertion is
IImplementResult,
TargetPrimitive,
ImplementingPermitted,
HandleImplementationResponse,
ImplementResultPrimitive
{
    // stores the number of bytes where the bytes32 should be inserted
    mapping(uint256=>uint48) internal _insertAtByte;

    
    
    
    
    function implement(uint256 identifier, bytes calldata callback) 
    external 
    payable
    override(IImplementResult)
    returns(IImplementResult.Response) {

        // check whether the current voting instance allows implementation
        if(!_implementingPermitted(identifier)) revert IImplementingPermitted.ImplementingNotPermitted(identifier, _status[identifier]);

        // check wether this is the correct calldata for the voting instance
        _requireValidCallbackData(identifier, callback);

        // retrieve calling contract from the identifier
        // modify the callback and
        // implement the result
        (
            IImplementResult.Response _responseStatus,
            bytes memory _responseData
        ) = ImplementResultPrimitive._implement(
            TargetPrimitive._target[identifier],
            abi.encodePacked(
                _modifyCallback(identifier, callback),
                identifier
            ));
        


        // check whether the response from the call was susccessful
        // calling a non-contract address by accident can result in a successful response, when it shouldn't.
        // That's why the user is encouraged to implement a return value to the target function and pass to the 
        // votingParams a flag that a return value should be expected. 
        // this can be implemented by the user.
        

        _responseStatus = (_responseStatus == IImplementResult.Response.successful) ? 
                          _handleNotFailedImplementation(identifier, _responseData) :
                          _handleFailedImplementation(identifier, _responseData);


        _status[identifier] = _responseStatus == IImplementResult.Response.successful? 
            uint256(IImplementResult.VotingStatusImplement.completed): 
            uint256(IImplementResult.VotingStatusImplement.failed);

        return _responseStatus;
    } 

    function _modifyCallback(uint256 identifier, bytes calldata callback) virtual internal view returns(bytes memory modifiedCallback){modifiedCallback = callback;}

    function _requireValidCallbackData(uint256 identifier, bytes calldata callback) internal virtual view {}

        
}


    
abstract contract HandleFailedImplementationResponse {
    
    event NotImplemented(uint256 identifier);

    
    
    
    function _handleFailedImplementation(uint256 identifier, bytes memory responseData) 
    virtual
    internal
    returns(IImplementResult.Response responseStatus)
    {}

}




abstract contract HandleImplementationResponseWithErrorsAndEvents is 
ExpectReturnValue, 
HandleImplementationResponse 
{

    function _handleFailedImplementation(uint256 identifier, bytes memory responseData) 
    virtual
    internal 
    override(HandleImplementationResponse) 
    returns(IImplementResult.Response responseStatus)
    {
        if (responseData.length > 0) {
            assembly {
                revert(add(responseData,32),mload(responseData))
            }
        } else { 
            emit HandleImplementationResponse.NotImplemented(identifier);
            return IImplementResult.Response.failed;
        }
        
    }


    function _handleNotFailedImplementation(uint256 identifier, bytes memory responseData) 
    virtual
    internal 
    override(HandleImplementationResponse) 
    returns(IImplementResult.Response responseStatus){
        // could still be non-successful
        // calling a non-contract address by accident can result in a successful response, when it shouldn't.
        // That's why the user is encouraged to implement a return value to the target function and pass to the 
        // votingParams a flag that a return value should be expected.
        if (_expectReturnValue[identifier] && responseData.length==0) {
            // responseStatus = IImplementResult.Response.failed;
            // emit IImplementResult.NotImplemented(identifier);
            revert ExpectedReturnError(identifier);
        } else {
            responseStatus = IImplementResult.Response.successful;
            emit HandleImplementationResponse.Implemented(identifier);
        }

    }
}




abstract contract HandleImplementationResponseWithoutExpectingResponse is 
HandleImplementationResponse {

    function _handleFailedImplementation(uint256 identifier, bytes memory responseData) internal 
    override(HandleImplementationResponse) 
    returns(IImplementResult.Response responseStatus){
        if (responseData.length > 0) {
            assembly {
                revert(add(responseData,32),mload(responseData))
            }
        } else {
            emit HandleImplementationResponse.NotImplemented(identifier);
            return IImplementResult.Response.failed;
        }
        
    }


    function _handleNotFailedImplementation(uint256 identifier, bytes memory responseData) 
    internal 
    override(HandleImplementationResponse) 
    returns(IImplementResult.Response responseStatus){
        responseStatus = IImplementResult.Response.successful;
        emit HandleImplementationResponse.Implemented(identifier);
    }
}

abstract contract HandleDoubleVotingGuard {

    enum VotingGuard {none, onSender, onVotingData}

    mapping(uint256=>VotingGuard) internal _guardOnSenderVotingDataOrNone; //_guardOnSenderVotingDataOrNone;

}


abstract contract NoDoubleVotingPublic is 
IHasAlreadyVoted,
NoDoubleVoting 
{
    function hasAlreadyVoted(uint256 identifier, address voter) 
    external 
    view 
    override(IHasAlreadyVoted)
    returns(bool alreadyVoted)
    {
        alreadyVoted = _alreadyVoted[identifier][voter]; 
    }   
}

// 
pragma solidity ^0.8.13;
























// WARNING: THIS IS AN EXAMPLE IMPLEMENTATION. It should not be used for production. This voting contract allows the user to choose and vote on any desired target contract. This could cause problems if that target contract is known to integrate with this voting contract. Otherwise it is a convenient way to trigger a function by popular vote.


contract PlainMajorityVoteWithQuorum is 
CallbackHashPrimitive,
TargetGetter,
StatusGetter,
CheckCalldataValidity,
IGetDoubleVotingGuard,
NoDoubleVoting,
CastSimpleVote,
IGetDeadline,
Deadline,
IGetQuorum,
QuorumPrimitive,
ImplementingPermitted,
BaseVotingContract,
ExpectReturnValue,
HandleImplementationResponse,
ImplementResult
{

    // GLOBAL DURATION
    // uint256 public constant VOTING_DURATION = 5 days;
    mapping(uint256=>uint256) internal _totalVotesCast;
    
    // We choose the start function from VotingWithImplementing, which handles 
    // the iteration and identification of instances via a progressing index (VotingContract)
    // and it handles the implementation retrieving first the calling contract and upon
    // a successful vote it calls that contract with the calldata.
    // The VotingContract demands an implementation of an internal _start function.
    // The Implementation demands an implementation of the internal _retrieveCaller function. 
    // We implement a trivial _start function for the snapshot vote.
    function _start(uint256 identifier, bytes memory votingParams, bytes calldata callback)
    virtual
    internal
    override(BaseVotingContract) 
    {
        // Store the status in storage.
        _status[identifier] = uint256(IVotingContract.VotingStatus.active);
        address target;
        uint256 duration;
        uint256 quorum;
        bool expectReturnValue;
        
        (target, quorum, duration, expectReturnValue) = decodeParameters(votingParams);
        _target[identifier] = target;
        _quorum[identifier] = quorum;
        _expectReturnValue[identifier] = expectReturnValue;
        Deadline._setDeadline(identifier, duration);

        // hash the callback
        _callbackHash[identifier] = keccak256(callback);
    }

    /// We obtain the caller and a flag (whether the target function returns a value) from the votingParams' only argument.
    function decodeParameters(bytes memory votingParams) public pure returns(address target, uint256 quorum, uint256 duration, bool expectReturnValue) {
        (target, quorum, duration, expectReturnValue) = abi.decode(votingParams, (address, uint256, uint256, bool)); 
    }

    /// We obtain the caller and a flag (whether the target function returns a value) from the votingParams' only argument.
    function encodeParameters(address target, uint256 quorum, uint256 duration, bool expectReturnValue) public pure returns(bytes memory votingParams) {
        votingParams = abi.encode(target, quorum, duration, expectReturnValue); 
    }

    
    function vote(uint256 identifier, bytes calldata votingData) 
    external 
    override(BaseVotingContract)
    returns (uint256)
    {
        if(_status[identifier]!=uint256(IVotingContract.VotingStatus.active)) {
            revert StatusError(identifier, _status[identifier]);
        }
        // check whether voting is closed. If yes, then update the status, if no then cast a vote.
        if (_checkCondition(identifier)) {
            _setStatus(identifier);
            return _status[identifier];
        } 
        
        if(NoDoubleVoting._alreadyVoted[identifier][msg.sender]){
            revert NoDoubleVoting.AlreadyVoted(identifier, msg.sender);
        }
        
        NoDoubleVoting._alreadyVoted[identifier][msg.sender] = true;

        bool approve = abi.decode(votingData, (bool));
        CastSimpleVote._castVote(identifier, approve ? int256(1) : int256(-1));
        _totalVotesCast[identifier] ++;
        return _status[identifier];
    }


    
    function result(uint256 identifier) public view override(BaseVotingContract) returns(bytes memory resultData) {
        return abi.encode(CastSimpleVote._getVotes(identifier));   
    }

    function _implementingPermitted(uint256 identifier) internal view override(ImplementingPermitted) returns(bool permitted) {
        bool awaitCall = _status[identifier] == uint256(IImplementResult.VotingStatusImplement.awaitcall); 
        bool finishedVoting = _checkCondition(identifier) && _status[identifier]==uint256(IImplementResult.VotingStatusImplement.active);
        permitted = awaitCall || (finishedVoting && _getVotes(identifier)>0 && _totalVotesCast[identifier]>=_quorum[identifier]);
    }


    function _setStatus(uint256 identifier) internal {
        _status[identifier] = (_getVotes(identifier)>0 && _totalVotesCast[identifier]>=_quorum[identifier]) ?
            uint256(IImplementResult.VotingStatusImplement.awaitcall):
            uint256(IImplementResult.VotingStatusImplement.failed); 
    }

    
    function _checkCondition(uint256 identifier) internal view override(BaseVotingContract) returns(bool condition) {
        condition = Deadline._deadlineHasPassed(identifier);
    }

    function _requireValidCallbackData(uint256 identifier, bytes calldata callback) internal view override(ImplementResult) {
        if(!CheckCalldataValidity._isValidCalldata(identifier, callback)){
            revert CheckCalldataValidity.InvalidCalldata();
        }
    }

    function _handleFailedImplementation(uint256 identifier, bytes memory responseData) internal 
    override(HandleImplementationResponse) 
    returns(IImplementResult.Response responseStatus){
        if (responseData.length > 0) {
            assembly {
                revert(add(responseData,32),mload(responseData))
            }
        } else {
            emit HandleImplementationResponse.NotImplemented(identifier);
            return IImplementResult.Response.failed;
        }
    }


    function _handleNotFailedImplementation(uint256 identifier, bytes memory responseData) 
    internal 
    override(HandleImplementationResponse) 
    returns(IImplementResult.Response responseStatus){
        // could still be non-successful
        // calling a non-contract address by accident can result in a successful response, when it shouldn't.
        // That's why the user is encouraged to implement a return value to the target function and pass to the 
        // votingParams a flag that a return value should be expected.
        if (_expectReturnValue[identifier] && responseData.length==0) {
            revert ExpectedReturnError(identifier);
        } else {
            responseStatus = IImplementResult.Response.successful;
            emit HandleImplementationResponse.Implemented(identifier);
        }

    }



    function getQuorum(uint256 identifier) 
    external view
    override(IGetQuorum) 
    returns(uint256 quorum, uint256 inUnitsOf) {
        return (_quorum[identifier], 0);
    }


    function getDeadline(uint256 identifier) 
    external view
    override(IGetDeadline) 
    returns(uint256) {
        return _deadline[identifier];
    }

    function getDoubleVotingGuard(uint256 identifier)
    external view
    override(IGetDoubleVotingGuard)
    returns(HandleDoubleVotingGuard.VotingGuard) {
        // by default any vote that is not inactive has this guard enabled
        return _status[identifier]==0? 
            HandleDoubleVotingGuard.VotingGuard.none:
            HandleDoubleVotingGuard.VotingGuard.onSender;
    } 

    function supportsInterface(bytes4 interfaceId) public pure virtual override(BaseVotingContract) returns (bool) {
        return 
            super.supportsInterface(interfaceId) ||
            interfaceId == type(IGetDeadline).interfaceId ||
            interfaceId == type(IGetDoubleVotingGuard).interfaceId ||
            interfaceId == type(IGetQuorum).interfaceId;
    }

}
