
pragma solidity ^0.4.13;

/**
 * @title Basic Math Library
 * @author Majoolr.io
 *
 * version 1.1.0
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The Basic Math Library is inspired by the Safe Math library written by
 * OpenZeppelin at https://github.com/OpenZeppelin/zeppelin-solidity/ .
 * Majoolr works on open source projects in the Ethereum community with the
 * purpose of testing, documenting, and deploying reusable code onto the
 * blockchain to improve security and usability of smart contracts. Majoolr
 * also strives to educate non-profits, schools, and other community members
 * about the application of blockchain technology.
 * For further information: majoolr.io, openzeppelin.org
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

library BasicMathLib {
  event Err(string typeErr);

  
  /// Does not throw but rather logs an Err event if there is overflow.
  
  
  
  
  function times(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
    assembly{
      res := mul(a,b)
      switch or(iszero(b), eq(div(res,b), a))
      case 0 {
        err := 1
        res := 0
      }
    }
    if (err)
      Err("times func overflow");
  }

  
  /// Does not throw but rather logs an Err event if 0 is in the divisor.
  
  
  
  
  function dividedBy(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
    assembly{
      switch iszero(b)
      case 0 {
        res := div(a,b)
        mstore(add(mload(0x40),0x20),res)
        return(mload(0x40),0x40)
      }
    }
    Err("tried to divide by zero");
    return (true, 0);
  }

  
  /// Does not throw but rather logs an Err event if there is overflow.
  
  
  
  
  function plus(uint256 a, uint256 b) constant returns (bool err, uint256 res) {
    assembly{
      res := add(a,b)
      switch and(eq(sub(res,b), a), or(gt(res,b),eq(res,b)))
      case 0 {
        err := 1
        res := 0
      }
    }
    if (err)
      Err("plus func overflow");
  }

  
  /// Does not throw but rather logs an Err event if there is underflow.
  
  
  
  
  function minus(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
    assembly{
      res := sub(a,b)
      switch eq(and(eq(add(res,b), a), or(lt(res,a), eq(res,a))), 1)
      case 0 {
        err := 1
        res := 0
      }
    }
    if (err)
      Err("minus func underflow");
  }
}