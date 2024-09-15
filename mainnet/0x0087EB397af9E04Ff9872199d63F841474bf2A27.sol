// SPDX-License-Identifier: Unlicense

//
pragma solidity ^0.8.4;









contract Greeter {
  event GreetingSet(string _greeting);

  string public greeting;

  constructor(string memory _greeting) {

    greeting = _greeting;
  }

  function greet() public view returns (string memory) {
    return greeting;
  }

  
  
  
  
  function setGreeting(string memory _greeting) public returns (bool _changedGreet) {
    require(bytes(_greeting).length > 0, 'Greeter: empty greeting');

    greeting = _greeting;
    _changedGreet = true;
    emit GreetingSet(_greeting);
  }
}