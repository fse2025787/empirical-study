   pragma solidity ^0.4.20;
 contract FalconFarmer{
 uint256 public EGGS_TO_HATCH_1FALCON=86400;
 uint256 public STARTING_FALCON=300;
 uint256 PSN=10000;
 uint256 PSNH=5000;
 bool public initialized=false;
 address public ceoAddress;
 mapping (address => uint256) public hatcheryFalcon;
 mapping (address => uint256) public claimedEggs;
 mapping (address => uint256) public lastHatch;
 mapping (address => address) public referrals;
 uint256 public marketEggs;
 uint256 public falconmasterReq=100000;
 function FalconFarmer() public{
 ceoAddress=msg.sender;
 }
 function becomeFalconmaster() public{
 require(initialized);
 require(hatcheryFalcon[msg.sender]>=falconmasterReq);
 hatcheryFalcon[msg.sender]=SafeMath.sub(hatcheryFalcon[msg.sender],falconmasterReq);
 falconmasterReq=SafeMath.add(falconmasterReq,100000);
 ceoAddress=msg.sender;
 }
 function hatchEggs(address ref) public{
 require(initialized);
 if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
 referrals[msg.sender]=ref;
 }
 uint256 eggsUsed=getMyEggs();
 uint256 newFalcon=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1FALCON);
 hatcheryFalcon[msg.sender]=SafeMath.add(hatcheryFalcon[msg.sender],newFalcon);
 claimedEggs[msg.sender]=0;
 lastHatch[msg.sender]=now;
 claimedEggs[referrals[msg.sender]]=SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,5));
 marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,10));
 }
 function sellEggs() public{
 require(initialized);
 uint256 hasEggs=getMyEggs();
 uint256 eggValue=calculateEggSell(hasEggs);
 uint256 fee=devFee(eggValue);
 hatcheryFalcon[msg.sender]=SafeMath.mul(SafeMath.div(hatcheryFalcon[msg.sender],3),2);
 claimedEggs[msg.sender]=0;
 lastHatch[msg.sender]=now;
 marketEggs=SafeMath.add(marketEggs,hasEggs);
 ceoAddress.transfer(fee);
 msg.sender.transfer(SafeMath.sub(eggValue,fee));
 }
 function buyEggs() public payable{
 require(initialized);
 uint256 eggsBought=calculateEggBuy(msg.value,SafeMath.sub(this.balance,msg.value));
 eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
 ceoAddress.transfer(devFee(msg.value));
 claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
 }
 function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
 return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
 }
 function calculateEggSell(uint256 eggs) public view returns(uint256){
 return calculateTrade(eggs,marketEggs,this.balance);
 }
 function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
 return calculateTrade(eth,contractBalance,marketEggs);
 }
 function calculateEggBuySimple(uint256 eth) public view returns(uint256){
 return calculateEggBuy(eth,this.balance);
 }
 function devFee(uint256 amount) public view returns(uint256){
 return SafeMath.div(SafeMath.mul(amount,4),100);
 }
 function seedMarket(uint256 eggs) public payable{
 require(marketEggs==0);
 initialized=true;
 marketEggs=eggs;
 }
 function getFreeFalcon() public payable{
 require(initialized);
 require(msg.value==0.001 ether);
 ceoAddress.transfer(msg.value);
 require(hatcheryFalcon[msg.sender]==0);
 lastHatch[msg.sender]=now;
 hatcheryFalcon[msg.sender]=STARTING_FALCON;
 }
 function getBalance() public view returns(uint256){
 return this.balance;
 }
 function getMyFalcon() public view returns(uint256){
 return hatcheryFalcon[msg.sender];
 }
 function getFalconmasterReq() public view returns(uint256){
 return falconmasterReq;
 }
 function getMyEggs() public view returns(uint256){
 return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
 }
 function getEggsSinceLastHatch(address adr) public view returns(uint256){
 uint256 secondsPassed=min(EGGS_TO_HATCH_1FALCON,SafeMath.sub(now,lastHatch[adr]));
 return SafeMath.mul(secondsPassed,hatcheryFalcon[adr]);
 }
 function min(uint256 a, uint256 b) private pure returns (uint256) {
 return a < b ? a : b;
 }
 }
 library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) {
 return 0;
 }
 uint256 c = a * b;
 assert(c / a == b);
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a / b;
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 assert(b <= a);
 return a - b;
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 assert(c >= a);
 return c;
 }
 }
