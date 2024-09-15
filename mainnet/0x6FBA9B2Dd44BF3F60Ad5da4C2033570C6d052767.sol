// SPDX-License-Identifier: BUSL-1.1


// 
pragma solidity ^0.8.17;



struct Deal {
    uint256 state; // 0 - not exists, 1-editing 2-execution 3-swaped
    address owner1; // owner 1 - creator
    address owner2; // owner 2 - second part if zero than it is open deal
    uint256 pointsCount;
}

// 
pragma solidity ^0.8.17;

struct DealPointData {
    address controller;
    uint256 id;
    
    /// 1 - eth
    /// 2 - erc20
    /// 3 erc721 item
    /// 4 erc721 count
    uint256 dealPointTypeId;
    uint256 dealId;
    address from;
    address to;
    address owner;
    uint256 value;
    uint256 balance;
    uint256 fee;
    address tokenAddress;
    bool isSwapped;
    bool isExecuted;
}

// 
pragma solidity ^0.8.17;

interface IOwnable {
    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;
}

// 
pragma solidity ^0.8.17;

interface IFeeSettings {
    function feeAddress() external returns (address); // address to pay fee

    function feePercent() external returns (uint256); // fee in 1/decimals for deviding values

    function feeDecimals() external view returns(uint256); // fee decimals

    function feeEth() external returns (uint256); // fee value for not dividing deal points
}

// 
pragma solidity ^0.8.17;



interface IHasFactories is IOwnable {
    
    function isFactory(address addr) external view returns (bool);

    
    function addFactory(address factory) external;

    
    function removeFactory(address factory) external;

    
    function setFactories(address[] calldata addresses, bool isFactory_)
        external;
}

// 
pragma solidity ^0.8.17;

struct DealPointRef {
    
    address controller;
    
    uint256 id;
}

// 
pragma solidity ^0.8.17;

interface IDealPointsController {
    receive() external payable;

    
    /// 1 - eth
    /// 2 - erc20
    /// 3 erc721 item
    /// 4 erc721 count
    function dealPointTypeId() external pure returns (uint256);

    
    function dealId(uint256 pointId) external view returns (uint256);

    
    function tokenAddress(uint256 pointId) external view returns (address);

    
    /// zero address - for open swap
    function from(uint256 pointId) external view returns (address);

    
    function to(uint256 pointId) external view returns (address);

    
    /// only DealsController and only once
    function setTo(uint256 pointId, address account) external;

    
    function value(uint256 pointId) external view returns (uint256);

    
    function balance(uint256 pointId) external view returns (uint256);

    
    function fee(uint256 pointId) external view returns (uint256);

    
    function feeIsEthOnWithdraw() external pure returns (bool);

    
    /// zero address - for open deals, before execution
    function owner(uint256 pointId) external view returns (address);

    
    function dealsController() external view returns (address);

    
    function isSwapped(uint256 pointId) external view returns (bool);

    
    function isExecuted(uint256 pointId) external view returns (bool);

    
    /// if already executed than nothing happens
    function execute(uint256 pointId, address addr) external payable;

    
    function executeEtherValue(uint256 pointId) external view returns(uint256);

    
    /// only deals controller
    function withdraw(uint256 pointId) external payable;
}// 
pragma solidity ^0.8.17;

//import 'hardhat/console.sol';







struct EtherPointCreationData {
    address from;
    address to;
    uint256 count;
}
struct Erc20PointCreationData {
    address from;
    address to;
    address token;
    uint256 count;
}
struct Erc721ItemPointCreationData {
    address from;
    address to;
    address token;
    uint256 tokenId;
}
struct Erc721CountPointCreationData {
    address from;
    address to;
    address token;
    uint256 count;
}
struct DealCreationData {
    address owner2; // another owner or zero if open swap
    EtherPointCreationData[] eth; // tyoe id 1
    Erc20PointCreationData[] erc20; // type id 2
    Erc721ItemPointCreationData[] erc721Item; // type id 3
    Erc721CountPointCreationData[] erc721Count; // type id 4
}

contract DealsFactory {
    IDealsController public dealsController;
    IEtherDealPointsController public eth;
    IErc20DealPointsController public erc20;
    IErc721ItemDealPointsController public erc721Item;
    IErc721CountDealPointsController public erc721Count;

    constructor(
        IDealsController dealsController_,
        IEtherDealPointsController eth_,
        IErc20DealPointsController erc20_,
        IErc721ItemDealPointsController erc721Item_,
        IErc721CountDealPointsController erc721Count_
    ) {
        dealsController = dealsController_;
        erc20 = erc20_;
        eth = eth_;
        erc721Item = erc721Item_;
        erc721Count = erc721Count_;
    }

    function createDeal(DealCreationData calldata data) external {
        // limitation
        uint256 dealPointsCount = data.erc20.length +
            data.erc721Item.length +
            data.eth.length;
        require(dealPointsCount > 1, 'at least 2 deal points required');
        // create deal
        uint256 dealId = dealsController.createDeal(msg.sender, data.owner2);
        // create points
        for (uint256 i = 0; i < data.eth.length; ++i) {
            checkPoindAddresses(data.eth[i].from, data.eth[i].to, data.owner2);
            eth.createPoint(
                dealId,
                data.eth[i].from,
                data.eth[i].to,
                data.eth[i].count
            );
        }
        for (uint256 i = 0; i < data.erc20.length; ++i) {
            checkPoindAddresses(
                data.erc20[i].from,
                data.erc20[i].to,
                data.owner2
            );
            erc20.createPoint(
                dealId,
                data.erc20[i].from,
                data.erc20[i].to,
                data.erc20[i].token,
                data.erc20[i].count
            );
        }
        for (uint256 i = 0; i < data.erc721Item.length; ++i) {
            checkPoindAddresses(
                data.erc721Item[i].from,
                data.erc721Item[i].to,
                data.owner2
            );
            erc721Item.createPoint(
                dealId,
                data.erc721Item[i].from,
                data.erc721Item[i].to,
                data.erc721Item[i].token,
                data.erc721Item[i].tokenId
            );
        }
        for (uint256 i = 0; i < data.erc721Count.length; ++i) {
            checkPoindAddresses(
                data.erc721Count[i].from,
                data.erc721Count[i].to,
                data.owner2
            );
            erc721Count.createPoint(
                dealId,
                data.erc721Count[i].from,
                data.erc721Count[i].to,
                data.erc721Count[i].token,
                data.erc721Count[i].count
            );
        }

        // stop deal editing
        dealsController.stopDealEditing(dealId);
    }

    function checkPoindAddresses(
        address from,
        address to,
        address owner2
    ) private view {
        require(from != to, 'from equals to address');
        require(
            !(from == address(0) && to == address(0)),
            'from ant to booth equals zero address'
        );
        require(
            from == msg.sender || from == owner2,
            'from must be msg.sender address or owner2 address'
        );
        require(
            to == msg.sender || to == owner2,
            'to must be msg.sender address or owner2 address'
        );
    }
}

// 
pragma solidity ^0.8.17;






interface IDealsController is IFeeSettings, IHasFactories {
    
    /// deals are creates by factories by one transaction, therefore another events, such as deal point adding is no need
    event NewDeal(uint256 indexed dealId, address indexed creator);
    
    event Swap(uint256 indexed dealId);
    
    event Execute(uint256 indexed dealId, address account, bool executed);
    
    event OnWithdraw(uint256 indexed dealId, address indexed account);

    
    function swap(uint256 dealId) external;

    
    function isSwapped(uint256 dealId) external view returns (bool);

    
    function getTotalDealPointsCount() external view returns (uint256);

    
    /// Only for factories.
    
    
    
    function createDeal(address owner1, address owner2)
        external
        returns (uint256);

    
    function getDeal(uint256 dealId)
        external
        view
        returns (Deal memory, DealPointData[] memory);

    
    function getDealHeader(uint256 dealId) external view returns (Deal memory);

    
    /// only for factories
    
    function addDealPoint(
        uint256 dealId,
        address dealPointsController,
        uint256 newPointId
    ) external;

    
    function getDealPoint(uint256 dealId, uint256 pointIndex)
        external
        view
        returns (DealPointData memory);

    
    function getDealPointsCount(uint256 dealId) external view returns (uint256);

    
    function isExecuted(uint256 dealId) external view returns (bool);

    
    function withdraw(uint256 dealId) external payable;

    
    /// only for factories
    function stopDealEditing(uint256 dealId) external;

    
    function execute(uint256 dealId) external payable;

    
    function executeEtherValue(uint256 dealId, uint256 ownerNumber) external view returns(uint256);

    
    function feeEthOnWithdraw(uint256 dealId, uint256 ownerNumber)
        external
        view
        returns (uint256);
}

// 
pragma solidity ^0.8.17;



interface IErc20DealPointsController is IDealPointsController {
    
    /// only for factories
    function createPoint(
        uint256 dealId_,
        address from_,
        address to_,
        address token_,
        uint256 count_
    ) external;
}

// 
pragma solidity ^0.8.17;



interface IEtherDealPointsController is IDealPointsController {
    
    /// only for factories
    function createPoint(
        uint256 dealId_,
        address from_,
        address to_,
        uint256 count_
    ) external;
}

// 
pragma solidity ^0.8.17;



interface IErc721ItemDealPointsController is IDealPointsController {
    
    function createPoint(
        uint256 dealId_,
        address from_,
        address to_,
        address token_,
        uint256 tokenId_
    ) external;

    
    function tokenId(uint256 pointId) external view returns (uint256);
}

// 
pragma solidity ^0.8.17;

interface IErc721CountDealPointsController {
    
    function createPoint(
        uint256 dealId_,
        address from_,
        address to_,
        address token_,
        uint256 count_
    ) external;

    
    function tokensId(uint256 pointId) external view returns (uint256[] memory);
}
