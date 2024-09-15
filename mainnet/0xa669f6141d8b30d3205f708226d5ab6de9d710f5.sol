// SPDX-License-Identifier: UNLICENSED

// 
pragma solidity 0.8.10;



contract RecipeContainerDSP {

    uint256 idCounter;
    address dfsRegistry;
    //recipeId to Recipe struct
    mapping(uint => Recipe) recipes;

    constructor() {
        registerDFS();
    }

    
    
    
    
    
    
    function storeRecipe(
        string memory _name,
        bytes[] memory _callData,
        bytes32[] memory _subData,
        bytes4[] memory _actionIds,
        uint8[][] memory _paramMapping
    ) 
        external 
        returns (uint)
    {
        // check targets are valid connectorsIds
        require(inputCheck(_callData,_subData,_actionIds,_paramMapping), "Invalid Recipe");
        // store recipe
        idCounter++;
        Recipe storage recipe = recipes[idCounter];
        recipe.name = _name;
        recipe.callData = _callData;
        recipe.subData = _subData;
        recipe.actionIds = _actionIds;
        recipe.paramMapping = _paramMapping;

        return idCounter;
    }


    
    
    function getRecipe(uint recipeId) public view returns (Recipe memory) {
        return recipes[recipeId];
    }

    
    ///      to prevent faulty or spammy recipe storage
    function inputCheck(
        bytes[] memory callData,
        bytes32[] memory subData,
        bytes4[] memory actionIds,
        uint8[][] memory paramMapping
    ) 
        internal
        view
        returns (bool isValid)
    {
        isValid = true;
        if(actionIds.length != callData.length || callData.length != subData.length || subData.length != paramMapping.length){
            isValid = false;
        }
        uint len = actionIds.length;
        for (uint i=0; i< len; i++){
            if (!IRegistry(dfsRegistry).isRegistered(actionIds[i])){
                isValid = false;
            }
        }
        return isValid;
    }

    function registerDFS() internal {
        if (block.chainid == 1) {
            dfsRegistry = 0x287778F121F134C66212FB16c9b53eC991D32f5b;
        } else if (block.chainid == 10){
            dfsRegistry = 0xAf707Ee480204Ed6e2640B53cE86F680D28Afcbd;
        }
    }

}

// 
pragma solidity >=0.7.0 <0.9.0;








struct Recipe {
    string name;
    bytes[] callData;
    bytes32[] subData;
    bytes4[] actionIds;
    uint8[][] paramMapping;
}

struct ParamsPull {
    address tokenAddr;
    address from;
    uint256 amount;
}

struct ParamsSend {
    address tokenAddr;
    address to;
    uint256 amount;
}

interface IDSProxy {
    function execute(
        address _targetAddress,
        bytes calldata _data
    ) external payable returns (bytes32);

    function setOwner(address _newOwner) external;
}

interface IProxyRegistry {
    function build(address owner) external returns (IDSProxy proxy);
}

interface IRegistry {
    function getAddr(bytes4) external view returns (address);
    function isRegistered(bytes4) external view returns (bool);
}

interface IPullAction{
    function parseInputs(bytes memory _callData) external pure returns (ParamsPull memory params);
}

interface ISendAction{
    function parseInputs(bytes memory _callData) external pure returns (ParamsSend memory params);
}

function registerDFS()
    view
    returns 
    (
    address recipeExecutor,
    address dfsRegistryAddress
    ) 
{
        if (block.chainid == 1) {
            recipeExecutor = 0xe822d76c2632FC52f3eaa686bDA9Cea3212579D8;
            dfsRegistryAddress = 0x287778F121F134C66212FB16c9b53eC991D32f5b;
        } else if (block.chainid == 10){
            recipeExecutor = 0xe91ff198bA6DFA97A7B4Fa43e5a606c915B0471f;
            dfsRegistryAddress = 0xAf707Ee480204Ed6e2640B53cE86F680D28Afcbd;
        }
}