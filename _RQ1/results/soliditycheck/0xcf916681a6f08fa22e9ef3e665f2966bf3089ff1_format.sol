     pragma solidity ^0.5.0;
 contract Context {
 constructor () internal {
 }
 function _msgSender() internal view returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view returns (bytes memory) {
 this;
 return msg.data;
 }
 }
 pragma solidity ^0.5.0;
 contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor () internal {
 _owner = _msgSender();
 emit OwnershipTransferred(address(0), _owner);
 }
 function owner() public view returns (address) {
 return _owner;
 }
 modifier onlyOwner() {
 require(isOwner(), "Ownable: caller is not the owner");
 _;
 }
 function isOwner() public view returns (bool) {
 return _msgSender() == _owner;
 }
 function renounceOwnership() public onlyOwner {
 emit OwnershipTransferred(_owner, address(0));
 _owner = address(0);
 }
 function transferOwnership(address newOwner) public onlyOwner {
 _transferOwnership(newOwner);
 }
 function _transferOwnership(address newOwner) internal {
 require(newOwner != address(0), "Ownable: new owner is the zero address");
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;
 }
 }
 pragma solidity 0.5.17;
 contract TokenPool is Ownable {
 IERC20 public token;
 constructor(IERC20 _token) public {
 token = _token;
 }
 function transfer(address to, uint256 value) external onlyOwner returns (bool) {
 return token.transfer(to, value);
 }
 function rescueFunds( address tokenToRescue, address to, uint256 amount ) external onlyOwner returns (bool) {
 require( address(token) != tokenToRescue, "TokenPool: Cannot claim token held by the contract" );
 return IERC20(tokenToRescue).transfer(to, amount);
 }
 function balance() public view returns (uint256) {
 return token.balanceOf(address(this));
 }
 }
 pragma solidity ^0.5.0;
 interface IERC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 }
