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





interface IImplementingPermitted {

    error ImplementingNotPermitted(uint256 identifier, uint256 status);

    
    
    
    
    function implementingPermitted(uint256 identifier) external view returns(bool permitted);
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


interface IGetToken {
    function getToken(uint256 identifier) external view returns(address token);
}

// 
pragma solidity ^0.8.13;


interface IHasAlreadyVoted {
    function hasAlreadyVoted(uint256 identifier, address voter) external view returns(bool alreadyVoted);
}

// 
pragma solidity ^0.8.13;



contract CastYesNoAbstainVote {

    enum VoteOptions {no, yes, abstain}

    mapping(uint256=>uint256[3]) internal _vote;

    function _castVote(uint256 identifier, VoteOptions option, uint256 amount) internal {
        // Since solidity 0.8.0 this will throw an error for amounts bigger than 2^(255-1), as it should!
        _vote[identifier][uint256(option)] += amount;
    }

    function _getVotes(uint256 identifier) internal view returns(uint256[3] memory _votes) {
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

abstract contract ImplementingPermittedPublicly is IImplementingPermitted, ImplementingPermitted {
    function implementingPermitted(uint256 identifier) external view override(IImplementingPermitted) returns(bool permitted) {
        permitted = _implementingPermitted(identifier);
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

abstract contract HandleDoubleVotingGuard {

    enum VotingGuard {none, onSender, onVotingData}

    mapping(uint256=>VotingGuard) internal _guardOnSenderVotingDataOrNone; //_guardOnSenderVotingDataOrNone;

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


abstract contract TokenPrimitive {
    
    mapping(uint256=>address) internal _token;

}
// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

abstract contract CallbackHashGetter is IGetCallbackHash, CallbackHashPrimitive{

    function getCallbackHash(uint256 identifier) public view virtual override(IGetCallbackHash) returns(bytes32) {
        return _callbackHash[identifier];
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





























contract MajorityVoteWithNFTQuorumAndOptionalDVGuard is 
IImplementingPermitted,
CallbackHashPrimitive,
TargetGetter,
StatusGetter,
CheckCalldataValidity,
TokenPrimitive,
IGetDoubleVotingGuard,
NoDoubleVoting,
IGetToken,
HandleDoubleVotingGuard,
CastYesNoAbstainVote,
IGetDeadline,
Deadline,
IGetQuorum,
QuorumPrimitive,
ImplementingPermittedPublicly,
BaseVotingContract,
ExpectReturnValue,
HandleImplementationResponse,
ImplementResult
{


    
    function _start(uint256 identifier, bytes memory votingParams, bytes calldata callback)
    virtual
    internal
    override(BaseVotingContract) 
    {
        // Store the status in storage.
        _status[identifier] = uint256(IVotingContract.VotingStatus.active);
        
        address tokenAddress;
        uint256 duration;
        uint256 quorumInTokens;
        bool expectReturnValue;
        HandleDoubleVotingGuard.VotingGuard guardOnSenderVotingDataOrNone;
    
        (tokenAddress, 
         duration,
         quorumInTokens,
         expectReturnValue, 
         guardOnSenderVotingDataOrNone
        ) = decodeParameters(votingParams);
        
        _target[identifier] = msg.sender;
        _token[identifier] = tokenAddress;
        _expectReturnValue[identifier] = expectReturnValue;
        _guardOnSenderVotingDataOrNone[identifier] = guardOnSenderVotingDataOrNone;
        _quorum[identifier] = quorumInTokens;

        Deadline._setDeadline(identifier, duration);

        // hash the callback
        _callbackHash[identifier] = keccak256(callback);
    }

    /// We obtain the caller and a flag (whether the target function returns a value) from the votingParams' only argument.
    function decodeParameters(bytes memory votingParams)
    public 
    pure
    returns(
        address token,
        uint256 duration,
        uint256 quorumInTokens,
        bool expectReturnValue,
        HandleDoubleVotingGuard.VotingGuard guardOnSenderVotingDataOrNone)
    {
        (
            token, 
            duration,
            quorumInTokens,
            expectReturnValue, 
            guardOnSenderVotingDataOrNone
        ) = abi.decode(votingParams, (address, uint256, uint256, bool, HandleDoubleVotingGuard.VotingGuard)); 
    }

    /// We obtain the caller and a flag (whether the target function returns a value) from the votingParams' only argument.
    function encodeParameters(
        address token,
        uint256 duration,
        uint256 quorumInTokens,
        bool expectReturnValue,
        HandleDoubleVotingGuard.VotingGuard guardOnSenderVotingDataOrNone) 
    public
    pure
    returns(bytes memory votingParams) 
    {
        votingParams = abi.encode(
            token,
            duration,
            quorumInTokens,
            expectReturnValue,
            guardOnSenderVotingDataOrNone); 
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

        uint256 option;
        uint256 weight;
        if (_guardOnSenderVotingDataOrNone[identifier] != HandleDoubleVotingGuard.VotingGuard.none){
            address voter;
            if (_guardOnSenderVotingDataOrNone[identifier] == HandleDoubleVotingGuard.VotingGuard.onSender){
                voter = msg.sender;
                option = abi.decode(votingData, (uint256));
            } else {
                voter = address(bytes20(votingData[0:20]));
                option = abi.decode(votingData[20:votingData.length], (uint256));
            }
            if(NoDoubleVoting._alreadyVoted[identifier][voter]){
                revert NoDoubleVoting.AlreadyVoted(identifier, voter);
            }
            weight = IERC721(_token[identifier]).balanceOf(voter);
            NoDoubleVoting._alreadyVoted[identifier][voter] = true;
        } else {
            if(msg.sender==_target[identifier]){
                (option, weight) = abi.decode(votingData, (uint256, uint256));
            } else {
                option = abi.decode(votingData, (uint256));
                weight = IERC721(_token[identifier]).balanceOf(msg.sender);
            }
        }
        
        
        CastYesNoAbstainVote.VoteOptions voteOption = CastYesNoAbstainVote.VoteOptions(option>2 ? 2 : option);
        CastYesNoAbstainVote._castVote(identifier, voteOption, weight);
        // emit VoteCasted(voter, option, weight);
        return _status[identifier];
    }

    


    
    function result(uint256 identifier) public view override(BaseVotingContract) returns(bytes memory resultData) {
        return abi.encode(CastYesNoAbstainVote._getVotes(identifier));   
    }

    function _implementingPermitted(uint256 identifier) internal view override(ImplementingPermitted) returns(bool permitted) {
        bool awaitCall = _status[identifier] == uint256(IImplementResult.VotingStatusImplement.awaitcall); 
        bool finishedVoting = _checkCondition(identifier) && _status[identifier]==uint256(IImplementResult.VotingStatusImplement.active);
        permitted = awaitCall || (finishedVoting && _outcomeSuccessful(identifier));
    }

    function _outcomeSuccessful(uint256 identifier) internal view returns(bool successFlag){
        uint256[3] memory votes = CastYesNoAbstainVote._getVotes(identifier);
        bool quorumSatisfied = (votes[0]+votes[1]+votes[2]) >= _quorum[identifier]; 
        return votes[1]>votes[0] && quorumSatisfied;   
    }


    function _setStatus(uint256 identifier) internal {
        _status[identifier] = _outcomeSuccessful(identifier) ?
            uint256(IImplementResult.VotingStatusImplement.awaitcall) :
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


    function getDeadline(uint256 identifier) 
    external view
    override(IGetDeadline) 
    returns(uint256) {
        return _deadline[identifier];
    }

    function getQuorum(uint256 identifier) 
    external view
    override(IGetQuorum) 
    returns(uint256 quorum, uint256 inUnitsOf) {
        return (_quorum[identifier], 0);
    }

    function getToken(uint256 identifier) 
    external view
    override(IGetToken) 
    returns(address) {
        return _token[identifier];
    }

    function getDoubleVotingGuard(uint256 identifier)
    external view
    override(IGetDoubleVotingGuard)
    returns(HandleDoubleVotingGuard.VotingGuard) {
        // by default any vote that is not inactive has this guard enabled
        return _guardOnSenderVotingDataOrNone[identifier];
    } 

    function supportsInterface(bytes4 interfaceId) public pure virtual override(BaseVotingContract) returns (bool) {
        return 
            super.supportsInterface(interfaceId) ||
            interfaceId == type(IGetDeadline).interfaceId ||
            interfaceId == type(IGetDoubleVotingGuard).interfaceId ||
            interfaceId == type(IGetQuorum).interfaceId ||
            interfaceId == type(IImplementingPermitted).interfaceId ||
            interfaceId == type(IGetToken).interfaceId;
            
    }

}
