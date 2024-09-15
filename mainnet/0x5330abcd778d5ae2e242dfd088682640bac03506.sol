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

interface INFTQuerierProvider{
    function getSupportedQueriers() external view returns (IQueryNFTTokens[] memory queriers);
    function registerQuerier(address querier) external;
    function getQuerierByIndex(uint256 index) external view returns (IQueryNFTTokens querier);
}





contract PFPPointer {
  address _owner;
  address _nftQuerierProvider;

  mapping(address=>Pointer) private pfpAddressPointers;
  
  struct Pointer{
    address nftContract;
    uint256 tokenId;
    uint256 querierIndex;
  }

  event PfpRegistered(address indexed owner, address nftContract, uint256 tokenId);
  event OwnerChanged(address indexed newOwner, address oldOwner);
  event OwnershipBurnt(address owner);
  event ProviderChanged(address newProvider, address oldProvider);

  
  constructor(address nftQuerierProvider)  {
      _owner = msg.sender;

      _nftQuerierProvider = nftQuerierProvider;
  }

  
  
  
  function getProvider() public view returns (address) {
      return _nftQuerierProvider;
  }

  
  
  
  
  function registerStandardPfpPointer(address nftContract, uint256 tokenId) public {
      uint256 supportedTokenStandardId = getSupportingStandardId(nftContract, tokenId);

      emit PfpRegistered(msg.sender, nftContract, tokenId);

      pfpAddressPointers[msg.sender] = Pointer(nftContract,tokenId,supportedTokenStandardId);
  }

  
  
  
  
  
  function registerPfpPointerByIndex(address nftContract, uint256 tokenId, uint256 index) public {
      verifyStandardAtIndexIsSupported(nftContract, tokenId,index);

      emit PfpRegistered(msg.sender, nftContract, tokenId);

      pfpAddressPointers[msg.sender] = Pointer(nftContract,tokenId,index);
  }

  
  
  
  
  function getMetadataDetails(address expectedPfpOwner) public view returns (string memory uri, string memory standardSupported){
     Pointer memory pointer = pfpAddressPointers[expectedPfpOwner];
     require(pointer.nftContract != address(0), "Not Registered");
    
     IQueryNFTTokens querier = (INFTQuerierProvider(_nftQuerierProvider).getSupportedQueriers())[pointer.querierIndex];
     
     string memory tokenUri = getTokenMetadataUri(pointer, querier,expectedPfpOwner);

     uri = tokenUri;
     standardSupported = querier.getDescription();
  }

  
  
  
  
  
  
   function getTokenMetadataUri(Pointer memory pointer, IQueryNFTTokens querier,address expectedPfpOwner) private view returns (string memory) {
      try querier.getTokenMetadataUri(pointer.nftContract, pointer.tokenId) returns (string memory uri) {
          require(bytes(uri).length > 0, "Uri missing");
          checkOwner(pointer,expectedPfpOwner, querier);
          return uri;
      }  
      catch Error(string memory reason) {
          revert(reason);
      }  
      catch (bytes memory reason) {
          revert(abi.decode(reason, (string)));
      }
  }

  
  
  
  
  
  function checkOwner(Pointer memory pointer, address expectedPfpOwner, IQueryNFTTokens querier) private view {
      try querier.addressOwnsToken(pointer.nftContract, expectedPfpOwner, pointer.tokenId) returns (bool ownsToken) {
          require(ownsToken, "Not owner");
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

  
  
  
  
  
  function verifyStandardAtIndexIsSupported(address nftContract, uint256 tokenId, uint256 index) private view {
     require(isContract(nftContract), "not contract");

     IQueryNFTTokens querier = INFTQuerierProvider(_nftQuerierProvider).getQuerierByIndex(index);
     
     try querier.isSupported(nftContract, msg.sender, tokenId) returns (bool supported) {
        if(!supported) {
            revert("Unsupported / not owner");
        }
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

  
  
  
  
  
  function getSupportingStandardId(address nftContract, uint256 _tokenId) private view returns (uint256) {
     require(isContract(nftContract), "not contract");

     IQueryNFTTokens[] memory queriers = INFTQuerierProvider(_nftQuerierProvider).getSupportedQueriers();

     for (uint256 i = 0; i < queriers.length; i++) {
        try queriers[i].isSupported(nftContract, msg.sender, _tokenId) returns (bool supported) {
              if(supported) {
                  return i; // array index wrt providers
              }
        }  
        catch Error(string memory) {
          // deliberate fallthrough to cater for loop
        }  
        catch (bytes memory) {
          // deliberate fallthrough to cater for loop
        }
     }

     revert("Unsupported / not owner");
  }

  
  
  
  function changeProvider(address provider) _isOwner() public {
    emit ProviderChanged(_nftQuerierProvider, address(provider));
    _nftQuerierProvider = provider;
  }

  
  
  function burnOwnership() _isOwner() public {
    emit OwnershipBurnt(msg.sender);
    _owner = address(0);
  }

  
  
  function changeOwnership(address owner) _isOwner() public {
    emit OwnerChanged(owner,_owner);
    _owner = owner;
  }

  modifier _isOwner() {
    require(_owner == msg.sender, "Not owner");
    _;
  }

  
  
  function isContract(address _addr) internal view returns (bool)
  {
    uint size;
    assembly { size := extcodesize(_addr)}
    return size > 0;
  }

  // NO FALLBACK RECEIVE FUNCTION - DON'T SEND ETHER HERE - IT WILL GO TO THE ABYSS
}