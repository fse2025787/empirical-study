                        pragma solidity ^0.6.12;
 library Pairing {
 struct G1Point {
 uint X;
 uint Y;
 }
 struct G2Point {
 uint[2] X;
 uint[2] Y;
 }
 function P1() internal pure returns (G1Point memory) {
 return G1Point(1, 2);
 }
 function P2() internal pure returns (G2Point memory) {
 return G2Point( [11559732032986387107991004021392285783925812861821192530917403151452391805634, 10857046999023057135944570762232829481370756359578518086990519993285655852781], [4082367875863433681332203403145435568316851327593401208105741076214120093531, 8495653923123431417604973247489272438418190587263600148770280649306958101930] );
 }
 function negate(G1Point memory p) internal pure returns (G1Point memory r) {
 uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
 if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
 return G1Point(p.X, q - (p.Y % q));
 }
 function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
 uint[4] memory input;
 input[0] = p1.X;
 input[1] = p1.Y;
 input[2] = p2.X;
 input[3] = p2.Y;
 bool success;
 assembly {
 success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60) switch success case 0 {
 invalid() }
 }
 require(success,"pairing-add-failed");
 }
 function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
 uint[3] memory input;
 input[0] = p.X;
 input[1] = p.Y;
 input[2] = s;
 bool success;
 assembly {
 success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60) switch success case 0 {
 invalid() }
 }
 require (success,"pairing-mul-failed");
 }
 function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
 require(p1.length == p2.length,"pairing-lengths-failed");
 uint elements = p1.length;
 uint inputSize = elements * 6;
 uint[] memory input = new uint[](inputSize);
 for (uint i = 0; i < elements; i++) {
 input[i * 6 + 0] = p1[i].X;
 input[i * 6 + 1] = p1[i].Y;
 input[i * 6 + 2] = p2[i].X[0];
 input[i * 6 + 3] = p2[i].X[1];
 input[i * 6 + 4] = p2[i].Y[0];
 input[i * 6 + 5] = p2[i].Y[1];
 }
 uint[1] memory out;
 bool success;
 assembly {
 success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20) switch success case 0 {
 invalid() }
 }
 require(success,"pairing-opcode-failed");
 return out[0] != 0;
 }
 function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
 G1Point[] memory p1 = new G1Point[](2);
 G2Point[] memory p2 = new G2Point[](2);
 p1[0] = a1;
 p1[1] = b1;
 p2[0] = a2;
 p2[1] = b2;
 return pairing(p1, p2);
 }
 function pairingProd3( G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2, G1Point memory c1, G2Point memory c2 ) internal view returns (bool) {
 G1Point[] memory p1 = new G1Point[](3);
 G2Point[] memory p2 = new G2Point[](3);
 p1[0] = a1;
 p1[1] = b1;
 p1[2] = c1;
 p2[0] = a2;
 p2[1] = b2;
 p2[2] = c2;
 return pairing(p1, p2);
 }
 function pairingProd4( G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2, G1Point memory c1, G2Point memory c2, G1Point memory d1, G2Point memory d2 ) internal view returns (bool) {
 G1Point[] memory p1 = new G1Point[](4);
 G2Point[] memory p2 = new G2Point[](4);
 p1[0] = a1;
 p1[1] = b1;
 p1[2] = c1;
 p1[3] = d1;
 p2[0] = a2;
 p2[1] = b2;
 p2[2] = c2;
 p2[3] = d2;
 return pairing(p1, p2);
 }
 }
 contract VerifierWithdraw {
 using Pairing for *;
 struct VerifyingKey {
 Pairing.G1Point alfa1;
 Pairing.G2Point beta2;
 Pairing.G2Point gamma2;
 Pairing.G2Point delta2;
 Pairing.G1Point[] IC;
 }
 struct Proof {
 Pairing.G1Point A;
 Pairing.G2Point B;
 Pairing.G1Point C;
 }
 function verifyingKey() internal pure returns (VerifyingKey memory vk) {
 vk.alfa1 = Pairing.G1Point(20491192805390485299153009773594534940189261866228447918068658471970481763042,9383485363053290200918347156157836566562967994039712273449902621266178545958);
 vk.beta2 = Pairing.G2Point([4252822878758300859123897981450591353533073413197771768651442665752259397132,6375614351688725206403948262868962793625744043794305715222011528459656738731], [21847035105528745403288232691147584728191162732299865338377159692350059136679,10505242626370262277552901082094356697409835680220590971873171140371331206856]);
 vk.gamma2 = Pairing.G2Point([11559732032986387107991004021392285783925812861821192530917403151452391805634,10857046999023057135944570762232829481370756359578518086990519993285655852781], [4082367875863433681332203403145435568316851327593401208105741076214120093531,8495653923123431417604973247489272438418190587263600148770280649306958101930]);
 vk.delta2 = Pairing.G2Point([2751094526990534090668894238253836180016709486872203368764444200147936278656,3867486542528089148218819604531577576526974258710228714274713759852911283414], [20204874591037440504705650964783155054604500481118210328828746304955488319320,806563933012591355070533443501159108870756279425075113167025765074681099931]);
 vk.IC = new Pairing.G1Point[](2);
 vk.IC[0] = Pairing.G1Point(1236075739224222093527217122122373155890993807754795083486325331194264991809,16402217793693883494945175470197449161172120247390461678250316304895863629108);
 vk.IC[1] = Pairing.G1Point(639580067677185628264165442784544121418477718445878514190672006562590353682,13296455779249205142581100669360977915800042274550493883216477569522005734669);
 }
 function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
 uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
 VerifyingKey memory vk = verifyingKey();
 require(input.length + 1 == vk.IC.length,"verifier-bad-input");
 Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
 for (uint i = 0; i < input.length; i++) {
 require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
 vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
 }
 vk_x = Pairing.addition(vk_x, vk.IC[0]);
 if (!Pairing.pairingProd4( Pairing.negate(proof.A), proof.B, vk.alfa1, vk.beta2, vk_x, vk.gamma2, proof.C, vk.delta2 )) return 1;
 return 0;
 }
 function verifyProof( uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[1] memory input ) public view returns (bool r) {
 Proof memory proof;
 proof.A = Pairing.G1Point(a[0], a[1]);
 proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
 proof.C = Pairing.G1Point(c[0], c[1]);
 uint[] memory inputValues = new uint[](input.length);
 for(uint i = 0; i < input.length; i++){
 inputValues[i] = input[i];
 }
 if (verify(inputValues, proof) == 0) {
 return true;
 }
 else {
 return false;
 }
 }
 }
