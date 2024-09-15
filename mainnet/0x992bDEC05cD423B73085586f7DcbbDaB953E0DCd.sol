// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.9;




abstract contract AccessControlTwoOfficers {
    
    address public executiveOfficer;

    
    address payable public financialOfficer;

    constructor() {
        executiveOfficer = msg.sender;
    }

    
    
    function setExecutiveOfficer(address newExecutiveOfficer) external {
        require(msg.sender == executiveOfficer);
        require(newExecutiveOfficer != address(0));
        executiveOfficer = newExecutiveOfficer;
    }

    
    
    function setFinancialOfficer(address payable newFinancialOfficer) external {
        require(msg.sender == executiveOfficer);
        require(newFinancialOfficer != address(0));
        financialOfficer = newFinancialOfficer;
    }

    
    function withdrawBalance() external {
        require(msg.sender == financialOfficer);
        financialOfficer.transfer(address(this).balance);
    }
}// 
pragma solidity ^0.8.9;


interface SuSquares {
    function ownerOf(uint256) external view returns(address);
}



contract SuSquaresUnderlay is AccessControlTwoOfficers {
    SuSquares public constant suSquares = SuSquares(0xE9e3F9cfc1A64DFca53614a0182CFAD56c10624F);
    uint256 public constant pricePerSquare = 1e15; // 1 Finney

    struct Personalization {
        uint256 squareId;
        bytes rgbData;
        string title;
        string href;
    }

    event PersonalizedUnderlay(
        uint256 indexed squareId,
        bytes rgbData,
        string title,
        string href
    );

    
    
    ///                  below 1... the last one at bottom-right is 10000
    
    ///                  Imagemagick's command: convert -size 10x10 -depth 8 in.rgb out.png
    
    
    function personalizeSquareUnderlay(
        uint256 squareId,
        bytes calldata rgbData,
        string calldata title,
        string calldata href
    )
        external payable
    {
        require(msg.value == pricePerSquare);
        _personalizeSquareUnderlay(squareId, rgbData, title, href);
    }

    
    
    function personalizeSquareUnderlayBatch(Personalization[] calldata personalizations) external payable {
        require(personalizations.length > 0, "Missing personalizations");
        require(msg.value == pricePerSquare * personalizations.length);
        for(uint256 i=0; i<personalizations.length; i++) {
            _personalizeSquareUnderlay(
                personalizations[i].squareId,
                personalizations[i].rgbData,
                personalizations[i].title,
                personalizations[i].href
            );
        }
    }

    function _personalizeSquareUnderlay(
        uint256 squareId,
        bytes calldata rgbData,
        string calldata title,
        string calldata href
    ) private {
        require(suSquares.ownerOf(squareId) == msg.sender, "Only the Su Square owner may personalize underlay");
        require(rgbData.length == 300, "Pixel data must be 300 bytes: 3 colors (RGB) x 10 columns x 10 rows");
        require(bytes(title).length <= 64, "Title max 64 bytes");
        require(bytes(href).length <= 96, "HREF max 96 bytes");
        emit PersonalizedUnderlay(
            squareId,
            rgbData,
            title,
            href
        );
    }
}
