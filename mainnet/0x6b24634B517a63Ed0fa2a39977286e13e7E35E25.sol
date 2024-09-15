// SPDX-License-Identifier: GPL-3.0-or-later
pragma abicoder v1;

// 
pragma solidity =0.8.10;


/**
 *    ,,                           ,,                                
 *   *MM                           db                      `7MM      
 *    MM                                                     MM      
 *    MM,dMMb.      `7Mb,od8     `7MM      `7MMpMMMb.        MM  ,MP'
 *    MM    `Mb       MM' "'       MM        MM    MM        MM ;Y   
 *    MM     M8       MM           MM        MM    MM        MM;Mm   
 *    MM.   ,M9       MM           MM        MM    MM        MM `Mb. 
 *    P^YbmdP'      .JMML.       .JMML.    .JMML  JMML.    .JMML. YA.
 *
 *    SaltedDeployer.sol :: 0x6b24634B517a63Ed0fa2a39977286e13e7E35E25
 *    etherscan.io verified 2021-12-18
 */ 




/// and errors.
contract SaltedDeployer {
  
  event Deployed(address deployAddress);

  
  error DeployFailed();

  
  error DeploymentExists();

  
  bytes32 constant SALT = 0xd2a5b1e84cb7a6df481438c61ec4144631172d3d29b2a30fe7c5f0fbf4e51735;

  
  
  ISingletonFactory constant SINGLETON_FACTORY = ISingletonFactory(0xce0042B868300000d44A59004Da54A005ffdcf9f);

  
  
  function getDeployAddress (bytes memory initCode) public pure returns (address deployAddress) {
    bytes32 hash = keccak256(
      abi.encodePacked(bytes1(0xff), address(SINGLETON_FACTORY), SALT, keccak256(initCode))
    );
    deployAddress = address(uint160(uint(hash)));
  }

  
  
  function deploy(bytes memory initCode) external {
    if (_isContract(getDeployAddress(initCode))) {
      revert DeploymentExists();
    }
    address deployAddress = SINGLETON_FACTORY.deploy(initCode, SALT);
    if (deployAddress == address(0)) {
      revert DeployFailed();
    }
    emit Deployed(deployAddress);
  }

  function _isContract(address account) internal view returns (bool) {
    return account.code.length > 0;
  }
}

// 
pragma solidity =0.8.10;


interface ISingletonFactory {
  function deploy(bytes memory _initCode, bytes32 _salt) external returns (address payable createdContract);
}