// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-04-11
*/

/// 
/*
▄▄█    ▄   ██   █▄▄▄▄ ▄█ 
██     █  █ █  █  ▄▀ ██ 
██ ██   █ █▄▄█ █▀▀▌  ██ 
▐█ █ █  █ █  █ █  █  ▐█ 
 ▐ █  █ █    █   █    ▐ 
   █   ██   █   ▀   
           ▀          */
/// Special thanks to Keno, Boring and Gonpachi for review and inspiration.
pragma solidity 0.6.12;


// File @boringcrypto/boring-solidity/contracts/interfaces/[email protected]
/// License-Identifier: MIT

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}


contract Inari {
    address public dao = msg.sender; // initialize governance with Inari summoner
    uint public offerings; // strategies offered into Kitsune and `inari()` calls
    mapping(uint => Kitsune) kitsune; // internal Kitsune mapping to `offerings`
    
    event MakeOffering(address indexed server, address[] to, bytes4[] sig, bytes32 descr, uint indexed offering);
    event Bridge(IERC20[] token, address[] approveTo);
    event Govern(address indexed dao, uint indexed kit, bool zenko);
    
    
    struct Kitsune {
        address[] to;
        bytes4[] sig;
        bytes32 descr;
        bool zenko;
    }
    
    /*********
    CALL INARI 
    *********/
    
    
    
    
    function inari(uint[] calldata kit, uint[] calldata value, bytes[] calldata param) 
        external payable returns (bool success, bytes memory returnData) {
        for (uint i = 0; i < kit.length; i++) {
            Kitsune storage ki = kitsune[kit[i]];
            (success, returnData) = ki.to[i].call{value: value[i]}
            (abi.encodePacked(ki.sig[i], param[i]));
            require(success, '!served');
        }
    }
    
    
    
    
    
    function inariZushi(uint[] calldata kit, uint[] calldata value, bytes[] calldata param) 
        external payable returns (bool success, bytes memory returnData) {
        for (uint i = 0; i < kit.length; i++) {
            Kitsune storage ki = kitsune[kit[i]];
            require(ki.zenko, "!zenko");
            (success, returnData) = ki.to[i].call{value: value[i]}
            (abi.encodePacked(ki.sig[i], param[i]));
            require(success, '!served');
        }
    }
    
    /********
    OFFERINGS 
    ********/
    
    function checkOffering(uint kit) external view returns (address[] memory to, bytes4[] memory sig, string memory descr, bool zenko) {
        Kitsune storage ki = kitsune[kit];
        to = ki.to;
        sig = ki.sig;
        descr = string(abi.encodePacked(ki.descr));
        zenko = ki.zenko;
    }
    
    
    
    
    function makeOffering(address[] calldata to, bytes4[] calldata sig, bytes32 descr) external { 
        uint kit = offerings;
        kitsune[kit] = Kitsune(to, sig, descr, false);
        offerings++;
        emit MakeOffering(msg.sender, to, sig, descr, kit);
    }
    
    /*********
    GOVERNANCE 
    *********/
    
    
    
    function bridge(IERC20[] calldata token, address[] calldata approveTo) external {
        for (uint i = 0; i < token.length; i++) {
            token[i].approve(approveTo[i], type(uint).max);
            emit Bridge(token, approveTo);
        }
    }
    
    
    
    
    
    function govern(address dao_, uint kit, bool zen) external {
        require(msg.sender == dao, "!dao");
        dao = dao_;
        kitsune[kit].zenko = zen;
        emit Govern(dao_, kit, zen);
    }
}