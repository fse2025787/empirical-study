// SPDX-License-Identifier: UNLICENSED

// 
pragma solidity ^0.8.10;

interface IGnosisSettlement{
    function setPreSignature(
        bytes calldata orderUid, 
        bool signed) external;
}

contract BatchExecutor {

    // GPv2Settlement
    address gnosisSettlement = 0x9008D19f58AAbD9eD0D60971565AA8510560ab41;

    constructor(){}

    
    
    
    function sendSetSignatureTx(
        bytes calldata orderUid, 
        bool signed) 
        external
    {
        IGnosisSettlement(gnosisSettlement).setPreSignature(orderUid,signed);
    }   

    
    
    
    function sendSetSignatureTxBatch(
        bytes[] calldata orderUids, 
        bool signed) 
        external
    {
        uint len = orderUids.length;
        for (uint i = 0; i < len; i++){
            IGnosisSettlement(gnosisSettlement).setPreSignature(orderUids[i],signed);
        }
    }   

}