// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-12-13
*/

// 
/*   
                                                              
T H E D A R K J E S T E R . E T H


                                        %%##%%%&                                
                           ,@@@@(     %#%%%%%%%%%&                              
                          ,&&&&@@@& %##%%%&%    ,#&                             
                          &&&&%&&&&%%#%#%%&       #                             
                         *&   %&& @% .% @&%       .,                            
                         /     & %  @#% @%&%                                    
                                  /[email protected]/#&&                                    
                                  .../*@..%&.                                   
                                 ,    **&@&&                                    
                           *&#%%&%&&@@&&&&%&@@&@                                
                       %#####&&&&&&&&&/(&&&&&&&&&&&%%                            
                     %#######&&&&&&&#//((%&&&&&&&&&@@&&(                         
 @@# *&*   @&       &%######%&&&&&&
 . .%&&&&%%@&*     &%########&&&&
     &&&@@&@@@@@&&@&#&&%#####&&&
    &*&&&@&%@@@@@@@@@&&%#%###&#((((((()))))))))%&&&&&&@%%%                       
     &%&&&&@@@@@@@&@&&#*  ##&&#\(((#(((())))))%%&&@@&&&%%@                      
    % %*&%.%.  .*@&@#  * .#%&&&&//(# T D J ((&&&&@@@ &&&&&&&*                   
       / %*              , #%&&&&&
         .,                 #&&&&&&%
                             @%#%%%##\%%&/&&@&@@*         &%%&%%%&%%%&%@@@@ #%@@
                            &#&&@&&&&&\&/@@@@@@@@@             *%&&%&&%&&@@   #@ 
                           ##&@&&%%%%%&&&@&@&@@&&@               %%&&%#.%  @    
                          ,#%&@&&&%#%%&&&&&&@@&&@@/             *% *%%( &       
                          .#%@@@&@%%%%&&&&&&&&&&@@.                 *%          
                          %#&@@&&@%%%%&&&&&&&&&&&&&.                 (          
                          ##&@&&&&%%%&&&&&%%&&%%&&&%                            
                          #%&@&&&&&%%&%&&&%%%%%%%%&%&                           
                         *#&&@&&&&@#@@%%&&%%%%%%%%%&%&                          
                         %&&@@&&&&&@@@@%%%%%%%%%%%%%%%&                         
                         &&&@@&&&&&@@#   %%%%%%%%%%%%%%.                        
                         &&&@@&&&&&&#     *%%%%%%%%%%%%%                        
                         .%&@@&&&&&@        %%%%%%%%%%%%%                       
                          &&@@&@@&&/         ,%%%%%%%%%%%&,                     
                           &@@@@@@&@           %%%%%%%%%%%%%                    
                           @@@@@@@@@#           (%%%%%%&%%%%%%                  
                           (&&@@@@@@@             %%%%%%&%%%%%#                 
                            @&&@@@@@&@             /%%%%%&%%%%%(                
                             &&&@@@@@@               %%%%%&&%%%%                
                             *&&&@@@@@@               %%%%%%&&%%&               
                              (&&&@@@@&@.               &%%%%%&%%%&             
                               #&&@@@@@@@                 &%%&%&%&&             
                                  @@@@@@@&@                  &&&&%%&%           
                                  &@@&&&&@ .                %&%&&%@%&&%         
                                 *&@@&&@@&&                 %%%[email protected]&(&&@          
                             &&@&&&&@@@@@@(                 %(%#&&%(%,          
                               (#%#,                         ,,&&@&&&,  
                                                              
T H E D A R K J E S T E R . E T H
                
*/

pragma solidity 0.8.17;

interface IQueryNFTTokens{
    function addressOwnsToken(address _contractAddress, address owner, uint256 tokenId) external view returns (bool);
    function getTokenMetadataUri(address _contractAddress, uint256 tokenId) external view returns (string memory);
    function isSupported(address _contractAddress, address owner, uint256 tokenId) external view returns (bool);
    function getName() external pure returns (string memory);
    function getDescription() external pure returns (string memory);
}
interface ISimplifiedERC1155{
    function uri(uint256 id) external view returns (string memory);
    function balanceOf(address account, uint256 id) external view returns (uint256);
}





contract ERC1155NFTQuerier is IQueryNFTTokens {
    constructor(){

    }

    
    
    
    function getName() external pure returns (string memory){
        return "ERC1155"; 
    }

    
    
    
    function getDescription() external pure returns (string memory){
        return "ERC1155"; 
    }  
    
    
    
    
    
    
    
    function addressOwnsToken(address contractAddress, address owner, uint256 tokenId) external view returns (bool){
       return addressOwnsTokenPrivate(contractAddress,owner, tokenId);
    }

    
    
    
    
    
    
    function addressOwnsTokenPrivate(address contractAddress, address owner, uint256 tokenId) private view returns (bool){
        try ISimplifiedERC1155(contractAddress).balanceOf(owner, tokenId) returns (uint256 balance) {
            return balance > 0;
        }
        catch Error(string memory reason) {
            // catch failing revert() and require()
            revert(reason);
        }  
        catch (bytes memory reason) {
            // catch failing assert()
            revert(abi.decode(reason, (string)));
        }
    }

    
    
    
    
    
    function getTokenMetadataUri(address contractAddress, uint256 tokenId) external view returns (string memory){
        return getTokenMetadataUriPrivate(contractAddress, tokenId);
    }

    
    
    
    
    
    function getTokenMetadataUriPrivate(address contractAddress, uint256 tokenId) private view returns (string memory){
        try ISimplifiedERC1155(contractAddress).uri(tokenId) returns (string memory uri) {
            return uri;
        }
        catch Error(string memory reason) {
            // catch failing revert() and require()
            revert(reason);
        }  
        catch (bytes memory reason) {
            // catch failing assert()
            revert(abi.decode(reason, (string)));
        }
    }
    
    
    
    
    
    
    
    function isSupported(address contractAddress, address owner, uint256 tokenId) external view returns (bool){
        bool isOwner = addressOwnsTokenPrivate(contractAddress,owner,tokenId);
        if(!isOwner){
            return false;
        }

        bool hasUri = bytes(getTokenMetadataUriPrivate(contractAddress,tokenId)).length > 0;
        return hasUri;
    }

     // NO FALLBACK RECEIVE FUNCTION - DON'T SEND ETHER HERE.
}