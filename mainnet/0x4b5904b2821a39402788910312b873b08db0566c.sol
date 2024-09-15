// SPDX-License-Identifier: AGPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2022-03-04
*/

// 
pragma solidity 0.8.12;

/// [MIT License]



library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



abstract contract ERC721 {
    /*///////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*///////////////////////////////////////////////////////////////
                          METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*///////////////////////////////////////////////////////////////
                            ERC721 STORAGE                        
    //////////////////////////////////////////////////////////////*/

    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) public ownerOf;

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*///////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*///////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || msg.sender == getApproved[id] || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            balanceOf[from]--;

            balanceOf[to]++;
        }

        ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*///////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            balanceOf[to]++;
        }

        ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = ownerOf[id];

        require(ownerOf[id] != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            balanceOf[owner]--;
        }

        delete ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}



interface ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4);
}
////////////////////////////////////////////////
///                                          ///
///         /|\                /|\           ///
///        |||||              |||||          ///
///        |||||              |||||          ///
///    /\  |||||          /\  |||||          ///
///   |||| |||||         |||| |||||          ///
///   |||| |||||  /\     |||| |||||  /\      ///
///   |||| ||||| ||||    |||| ||||| ||||     ///
///    \|`-'|||| ||||     \|`-'|||| ||||     ///
///     \__ |||| ||||      \__ |||| ||||     ///
///        ||||`-'|||         ||||`-'|||     ///
///        |||| ___/          |||| ___/      ///
///        |||||              |||||          ///
///        |||||              |||||          ///
///   ------------------------------------   ///
///                                          ///
////////////////////////////////////////////////






contract Pioneers is ERC721 {

    /// ~~~~~~~~~~~~~~~~~~~~~~ CUSTOM ERRORS ~~~~~~~~~~~~~~~~~~~~~~ ///

    
    error MaximumMints();

    
    error InsufficientTokensRemain();

    
    error InsufficientFunds();

    
    error Unauthorized();

    
    error AlreadyMinted();

    
    error MintClosed();

    /// ~~~~~~~~~~~~~~~~~~~~~~~~~ STORAGE ~~~~~~~~~~~~~~~~~~~~~~~~~ ///

    
    uint8 public tokenCount;

    
    address public owner;

    
    bool public isPublicSaleActive;

    
    mapping(address => bool) public minted;

    
    uint256 public constant MAXIMUM_COUNT = 100;

    
    uint256 public constant MAX_TOKENS_PER_WALLET = 1;

    
    uint256 public constant PUBLIC_SALE_PRICE = 0.05 ether;

    /// ~~~~~~~~~~~~~~~~~~~~~~~~ MODIFIERS ~~~~~~~~~~~~~~~~~~~~~~~~ ///

    
    modifier canMint() {
      if (tokenCount >= MAXIMUM_COUNT) {
        revert MaximumMints();
      }
      if (tokenCount + 1 > MAXIMUM_COUNT) {
        revert InsufficientTokensRemain();
      }
      if (minted[msg.sender]) {
        revert AlreadyMinted();
      }
      _;
    }

    
    modifier isCorrectPayment() {
      if (PUBLIC_SALE_PRICE > msg.value) {
        revert InsufficientFunds();
      }
      _;
    }

    
    modifier onlyOwner() {
      if (msg.sender != owner) {
        revert Unauthorized();
      }
      _;
    }

    
    modifier isMintingOpen() {
      if (!isPublicSaleActive) {
        revert MintClosed();
      }
      _;
    }

    /// ~~~~~~~~~~~~~~~~~~~~~~~ CONSTRUCTOR ~~~~~~~~~~~~~~~~~~~~~~~ ///

    
    constructor() ERC721("Pioneers", "PINR") {
      owner = msg.sender;
    }

    /// ~~~~~~~~~~~~~~~~~~~~~~~~~ METADATA ~~~~~~~~~~~~~~~~~~~~~~~~ ///

    
    
    function tokenURI(uint256 tokenId)
      public
      view
      virtual
      override
      returns (string memory)
    {
      string memory baseSvg =
        "<svg viewBox='0 0 800 800' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>"
        "<style>.text--line{font-size:400px;font-weight:bold;font-family:'Arial';}"
        ".top-text{fill:#bafe49;font-weight: bold;font-color:#bafe49;font-size:40px;font-family:'Arial';}"
        ".text-copy{fill:none;stroke:white;stroke-dasharray:25% 40%;stroke-width:4px;animation:stroke-offset 9s infinite linear;}"
        ".text-copy:nth-child(1){stroke:#bafe49;stroke-dashoffset:6% * 1;}.text-copy:nth-child(2){stroke:#bafe49;stroke-dashoffset:6% * 2;}"
        ".text-copy:nth-child(3){stroke:#bafe49;stroke-dashoffset:6% * 3;}.text-copy:nth-child(4){stroke:#bafe49;stroke-dashoffset:6% * 4;}"
        ".text-copy:nth-child(5){stroke:#bafe49;stroke-dashoffset:6% * 5;}.text-copy:nth-child(6){stroke:#bafe49;stroke-dashoffset:6% * 6;}"
        ".text-copy:nth-child(7){stroke:#bafe49;stroke-dashoffset:6% * 7;}.text-copy:nth-child(8){stroke:#bafe49;stroke-dashoffset:6% * 8;}"
        ".text-copy:nth-child(9){stroke:#bafe49;stroke-dashoffset:6% * 9;}.text-copy:nth-child(10){stroke:#bafe49;stroke-dashoffset:6% * 10;}"
        "@keyframes stroke-offset{45%{stroke-dashoffset:40%;stroke-dasharray:25% 0%;}60%{stroke-dashoffset:40%;stroke-dasharray:25% 0%;}}"
        "</style>"
        "<rect width='100%' height='100%' fill='black' />"
        "<symbol id='s-text'>"
        "<text text-anchor='middle' x='50%' y='70%' class='text--line'>Y</text>"
        "</symbol><g class='g-ants'>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use>"
        "<use href='#s-text' class='text-copy'></use></g>";

      // Convert token id to string
      string memory sTokenId = toString(tokenId);

      // Create the SVG Image
      string memory finalSvg = string(
        abi.encodePacked(
          baseSvg,
          "<text class='top-text' margin='2px' x='4%' y='8%'>",
          sTokenId,
          "</text></svg>"
        )
      );

      // Base64 Encode our JSON Metadata
      string memory json = Base64.encode(
        bytes(
          string(
            abi.encodePacked(
              '{"name": "Pioneer ',
              sTokenId,
              '", "description": "',
              'Number ',
              sTokenId,
              ' of the Pioneer collection for early Yobot Adopters", "image": "data:image/svg+xml;base64,',
              Base64.encode(bytes(finalSvg)),
              '"}'
            )
          )
        )
      );

      // Prepend data:application/json;base64 to define the base64 encoded data
      return string(
        abi.encodePacked("data:application/json;base64,", json)
      );
    }

    /// ~~~~~~~~~~~~~~~~~~~~~~ MINTING LOGIC ~~~~~~~~~~~~~~~~~~~~~~ ///

    
    
    function mint(address to)
      public
      virtual
      payable
      isCorrectPayment
      canMint
      isMintingOpen
    {
      uint256 tokenId = uint256(tokenCount);
      unchecked { ++tokenCount; }
      minted[msg.sender] = true;
      _mint(to, tokenId);
    }

    
    
    function privateMint(address to) public virtual payable onlyOwner {
      uint256 tokenId = uint256(tokenCount);
      unchecked { ++tokenCount; }
      _mint(to, tokenId);
    }

    
    
    function safeMint(address to)
      public
      virtual
      payable
      isCorrectPayment
      canMint
      isMintingOpen
    {
      uint256 tokenId = uint256(tokenCount);
      unchecked { ++tokenCount; }
      minted[msg.sender] = true;
      _safeMint(to, tokenId);
    }

    
    
    
    function safeMint(
      address to,
      bytes memory data
    )
      public
      virtual
      payable
      isCorrectPayment
      canMint
      isMintingOpen
    {
      uint256 tokenId = uint256(tokenCount);
      unchecked { ++tokenCount; }
      minted[msg.sender] = true;
      _safeMint(to, tokenId, data);
    }

    /// ~~~~~~~~~~~~~~~~~~~~~~~ ADMIN LOGIC ~~~~~~~~~~~~~~~~~~~~~~~ ///

    
    
    function setIsPublicSaleActive(bool _isPublicSaleActive)
      external
      onlyOwner
    {
      isPublicSaleActive = _isPublicSaleActive;
    }

    
    function withdraw() public onlyOwner {
      uint256 balance = address(this).balance;
      (bool sent,) = msg.sender.call{value: balance}("");
      require(sent, "Failed to send Ether");
    }

    
    
    function withdrawTokens(IERC20 token) public onlyOwner {
      uint256 balance = token.balanceOf(address(this));
      token.transfer(msg.sender, balance);
    }

    /// ~~~~~~~~~~~~~~~~~~~~~~ CUSTOM LOGIC ~~~~~~~~~~~~~~~~~~~~~~~ ///

    
    
    function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
      return
        interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
        interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
        interfaceId == 0x5b5e139f;   // ERC165 Interface ID for ERC721Metadata
    }

    
    
    function toString(uint256 value) public pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}