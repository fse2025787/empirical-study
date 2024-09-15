// SPDX-License-Identifier: MIT


// 
pragma solidity >=0.6.2;

interface IERC165 {
    
    
    
    /// uses less than 30,000 gas.
    
    /// `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
// 
pragma solidity >=0.6.2;





/// Note: The ERC-165 identifier for this interface is 0xd9b67a26.
interface IERC1155 is IERC165 {
    
    /// - Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
    /// - The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
    /// - The `_from` argument MUST be the address of the holder whose balance is decreased.
    /// - The `_to` argument MUST be the address of the recipient whose balance is increased.
    /// - The `_id` argument MUST be the token type being transferred.
    /// - The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
    /// - When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
    /// - When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    event TransferSingle(
        address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value
    );

    
    /// - Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
    /// - The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
    /// - The `_from` argument MUST be the address of the holder whose balance is decreased.
    /// - The `_to` argument MUST be the address of the recipient whose balance is increased.
    /// - The `_ids` argument MUST be the list of tokens being transferred.
    /// - The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.
    /// - When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
    /// - When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    event TransferBatch(
        address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values
    );

    
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    
    /// The URI MUST point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
    event URI(string _value, uint256 indexed _id);

    
    
    /// - MUST revert if `_to` is the zero address.
    /// - MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
    /// - MUST revert on any other error.
    /// - MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
    /// - After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    
    
    /// - MUST revert if `_to` is the zero address.
    /// - MUST revert if length of `_ids` is not the same as length of `_values`.
    /// - MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
    /// - MUST revert on any other error.
    /// - MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
    /// - Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
    /// - After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
    
    
    
    
    
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    
    
    
    
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    
    
    
    
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

    
    
    
    
    function setApprovalForAll(address _operator, bool _approved) external;

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// 
pragma solidity >=0.8.0;



abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// 
pragma solidity 0.8.15;

struct NCAParams {
    string seed;
    string bg;
    string fg1;
    string fg2;
    string matrix;
    string activation;
    string rand;
    string mods;
}

interface INeuralAutomataEngine {
    function baseScript() external view returns(string memory);

    function parameters(NCAParams memory _params) external pure returns(string memory);

    function p5() external view returns(string memory);

    function script(NCAParams memory _params) external view returns(string memory);

    function page(NCAParams memory _params) external view returns(string memory);
}

// 
pragma solidity 0.8.15;



interface IZooOfNeuralAutomata {

    function updateEngine(address _engine) external;

    function updateContractURI(string memory _contractURI) external;

    function updateParams(uint256 _id, NCAParams memory _params) external;

    function updateMinter(uint256 _id, address _minter) external;

    function updateBurner(uint256 _id, address _burner) external;

    function updateBaseURI(uint256 _id, string memory _baseURI) external;

    function freeze(uint256 _id) external;

    function newToken(
        uint256 _id,
        NCAParams memory _params, 
        address _minter, 
        address _burner,
        string memory _baseURI
    ) external;

    function mint(
        address _to,
        uint256 _id,
        uint256 _amount
    ) external;

    function burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) external;
    
}

//
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@(//@@@@@@@
//@@@@@@@@@@@@@@@@@@(
//@@@@@@@@@@@@@@@@(
//@@@@@@@@@@@@@@%
//@@@@@@@@@@@@@
//@@@@@@@@@@@@#
//@@@@@@@@@@@@
//@@@@@@@@@@@
//@@@@@@@@@@@
//@@@@@@@@@@@
//@@@@@@@@@@@
//@@@@@@@@@@@
//@@@@@@@@@@@@
//@@@@@@@@@@@@@
//@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@%//*******                             .***
//@@@@@@@@@@@@@@@@@@@********..                         .*****
//@@@@@@@@@@@@@@@@@@@@@*******,.....               .....******/(@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@******,,,,,.............,,,,******@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@******,,,,,,,,,,,,,******@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

pragma solidity 0.8.15;





contract Enfernous{

    address immutable zona;
    uint256 immutable startTime;

    address owner;
    uint256 public burned = 0;

    constructor(address _owner, address _zona, uint256 _startTime) {
        owner = _owner;
        zona = _zona;
        startTime = _startTime;
    }

    function mint(uint256 amount) external {
        require(startTime <= block.timestamp || msg.sender == owner);
        require(IERC1155(zona).balanceOf(msg.sender, 1) >= amount);
        require(burned + amount <= 512);

        burned += amount;

        IZooOfNeuralAutomata(zona).burn(msg.sender, 1, amount);
        IZooOfNeuralAutomata(zona).mint(msg.sender, 666, amount);
    }

}