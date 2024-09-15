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

interface IVotingRegistry {
    
    
    
    
    function register(address contractAddress, address resolver) external;

    
    
    
    function changeResolver(address contractAddress, address resolver) external;

    
    
    
    function getRegistrar(address votingContract) external view returns (address registrar);

    
    
    
    function getResolver(address votingContract) external view returns(address resolver);

    
    
    
    function isRegistered(address votingContract) external view returns(bool registrationStatus);
}

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░░░░░░░░██╗░░░██╗░█████╗░████████╗██╗███╗░░██╗░██████╗░░░░░░░░░░░░░░ //
// ░░░░░░░░░░██║░░░██║██╔══██╗╚══██╔══╝██║████╗░██║██╔════╝░░░░░░░░░░░░░░ //
// ░░░░░░░░░░╚██╗░██╔╝██║░░██║░░░██║░░░██║██╔██╗██║██║░░██╗░░░░░░░░░░░░░░ //
// ░░░░░░░░░░░╚████╔╝░██║░░██║░░░██║░░░██║██║╚████║██║░░╚██╗░░░░░░░░░░░░░ //
// ░░░░░░░░░░░░╚██╔╝░░╚█████╔╝░░░██║░░░██║██║░╚███║╚██████╔╝░░░░░░░░░░░░░ //
// ░░░░░░░░░░░░░╚═╝░░░░╚════╝░░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░░░░░░░░░░░░░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░░██████╗░███████╗░██████╗░██╗░██████╗████████╗██████╗░██╗░░░██╗░░░░ //
// ░░░░██╔══██╗██╔════╝██╔════╝░██║██╔════╝╚══██╔══╝██╔══██╗╚██╗░██╔╝░░░░ //
// ░░░░██████╔╝█████╗░░██║░░██╗░██║╚█████╗░░░░██║░░░██████╔╝░╚████╔╝░░░░░ //
// ░░░░██╔══██╗██╔══╝░░██║░░╚██╗██║░╚═══██╗░░░██║░░░██╔══██╗░░╚██╔╝░░░░░░ //
// ░░░░██║░░██║███████╗╚██████╔╝██║██████╔╝░░░██║░░░██║░░██║░░░██║░░░░░░░ //
// ░░░░╚═╝░░╚═╝╚══════╝░╚═════╝░╚═╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝░░░╚═╝░░░░░░░ // 
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY without even the implied warranty of MERCHANTABILITY 
// or FITNESS FOR A PARTICULAR PURPOSE. See the 
// GNU Affero General Public License for more details.



// 

pragma solidity ^0.8.13;









contract VotingRegistry is IVotingRegistry{

    //////////////////////////////////////////////////
    // TYPE, ERROR AND EVENT DECLARATIONS           //
    //////////////////////////////////////////////////

    // types
    struct Record {
        address registrar;
        address resolver;
    }

    // events
    event Registered(address contractAddress, address registrar, address resolver);
    event ResolverUpdated(address contractAddress, address newResolver);

    // errors
    error AlreadyRegistered(address contractAddress, address registrar);
    error DoesNotSatisfyInterface(address contractAddress);
    error OnlyRegistrar(address sender, address registrar);

    //////////////////////////////////////////////////
    // STATE VARIABLES                              //
    //////////////////////////////////////////////////

    mapping(address=>Record) private records;
    bytes4 immutable private VOTING_CONTRACT_STANDARD_ID;
    
    constructor(bytes4 _VOTING_CONTRACT_STANDARD_ID){
        VOTING_CONTRACT_STANDARD_ID = _VOTING_CONTRACT_STANDARD_ID;
    }

    //////////////////////////////////////////////////
    // WRITE FUNCTIONS                              //
    //////////////////////////////////////////////////

    function register(
        address contractAddress,
        address resolver)
    external
    override(IVotingRegistry)
    {
        if (isRegistered(contractAddress)){
            revert AlreadyRegistered(contractAddress, records[contractAddress].registrar);
        }
        if (! checkInterface(contractAddress)){
            revert DoesNotSatisfyInterface(contractAddress);
        }
        records[contractAddress] = Record({
            registrar: msg.sender,
            resolver: resolver
        });
        emit Registered(contractAddress, msg.sender, resolver);
    }

    function changeResolver(
        address contractAddress,
        address resolver)
    external
    override(IVotingRegistry)
    {
        if (msg.sender!=records[contractAddress].registrar){
            revert OnlyRegistrar(msg.sender, records[contractAddress].registrar);
        }
        records[contractAddress].resolver = resolver;
        emit ResolverUpdated(contractAddress, resolver);
    }


    //////////////////////////////////////////////////
    // GETTER FUNCTIONS                             //
    //////////////////////////////////////////////////
    

    
    
    
    function getRegistrar(address votingContract) 
    public
    view
    override(IVotingRegistry)
    returns (address registrar)
    {
        registrar = records[votingContract].registrar;
    }

    
    function getResolver(address votingContract)
    external 
    view
    override(IVotingRegistry)
    returns(address resolver)
    {
        resolver = records[votingContract].resolver;
    }
    
    function isRegistered(address votingContract) 
    public 
    view 
    override(IVotingRegistry)
    returns(bool registrationStatus)
    {
        registrationStatus =  records[votingContract].registrar!=address(0);
    }


    //////////////////////////////////////////////////
    // INTERNAL HELPER FUNCTIONS                    //
    //////////////////////////////////////////////////


    function checkInterface(address contractAddress) internal view returns(bool) {
        return IERC165(contractAddress).supportsInterface(VOTING_CONTRACT_STANDARD_ID);
    }
    

}