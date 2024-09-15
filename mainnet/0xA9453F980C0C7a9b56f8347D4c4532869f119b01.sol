// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.7;

error CrypTip__ValueMustBeAboveZero();
error CrypTip__NoTips();




contract CrypTip {
    
    mapping(address => uint256) private s_tips;

    
    
    
    
    
    
    
    event Tip(
        address indexed receiver,
        address indexed sender,
        uint256 indexed amount,
        string name,
        string message
    );

    
    
    
    
    
    function sendTip(
        address receiver,
        string memory name,
        string memory message
    ) external payable {
        if (msg.value <= 0) revert CrypTip__ValueMustBeAboveZero();

        // Could just send the money...
        // https://fravoll.github.io/solidity-patterns/pull_over_push.html
        s_tips[receiver] += msg.value;
        emit Tip(receiver, msg.sender, msg.value, name, message);
    }

    
    function withdrawTips() external {
        uint256 proceeds = s_tips[msg.sender];
        if (proceeds <= 0) revert CrypTip__NoTips();

        s_tips[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    
    function getTipBalance(address walletAddress) external view returns (uint256) {
        return s_tips[walletAddress];
    }
}