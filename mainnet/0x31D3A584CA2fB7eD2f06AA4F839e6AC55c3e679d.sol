// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.8;



interface IERC2771 {
    
    
    
    function isTrustedForwarder(address forwarder) external view returns (bool isTrusted);
}
// 
pragma solidity 0.8.17;







contract ForwarderRegistryContextFacet is IERC2771 {
    IForwarderRegistry public immutable forwarderRegistry;

    constructor(IForwarderRegistry forwarderRegistry_) {
        forwarderRegistry = forwarderRegistry_;
    }

    
    function isTrustedForwarder(address forwarder) external view virtual override returns (bool) {
        return forwarder == address(forwarderRegistry);
    }
}

// 
pragma solidity ^0.8.8;



interface IForwarderRegistry {
    
    
    
    
    function isApprovedForwarder(address sender, address forwarder) external view returns (bool isApproved);
}