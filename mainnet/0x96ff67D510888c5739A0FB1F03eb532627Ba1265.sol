// SPDX-License-Identifier: BUSL-1.1


// 
pragma solidity ^0.8.17;

struct DealPointDataInternal {
    uint256 dealId;
    uint256 value;
    address from;
    address to;
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
}

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





abstract contract DealPointsController is IDealPointsController {
    IDealsController immutable _dealsController;
    mapping(uint256 => DealPointDataInternal) internal _data;

    /*mapping(uint256 => uint256) internal _dealId;
    mapping(uint256 => address) internal _from;
    mapping(uint256 => address) internal _to;
    mapping(uint256 => uint256) internal _value;*/
    mapping(uint256 => uint256) internal _balances;
    mapping(uint256 => uint256) internal _fee;
    mapping(uint256 => bool) internal _isExecuted;
    mapping(uint256 => address) internal _tokenAddress;

    constructor(address dealsController_) {
        _dealsController = IDealsController(dealsController_);
    }

    receive() external payable {}

    modifier onlyDealsController() {
        require(
            address(_dealsController) == msg.sender,
            'only deals controller can call this function'
        );
        _;
    }

    modifier onlyFactory() {
        require(
            _dealsController.isFactory(msg.sender),
            'only factory can call this function'
        );
        _;
    }

    function isSwapped(uint256 pointId) external view returns (bool) {
        //return _dealsController.isSwapped(_dealId[pointId]);
        return _dealsController.isSwapped(_data[pointId].dealId);
    }

    function isExecuted(uint256 pointId) external view returns (bool) {
        return _isExecuted[pointId];
        //return _data[pointId].isExecuted;
    }

    function dealId(uint256 pointId) external view returns (uint256) {
        //return _dealId[pointId];
        return _data[pointId].dealId;
    }

    function from(uint256 pointId) external view returns (address) {
        //return _from[pointId];
        return _data[pointId].from;
    }

    function to(uint256 pointId) external view returns (address) {
        //return _to[pointId];
        return _data[pointId].to;
    }

    function setTo(uint256 pointId, address account)
        external
        onlyDealsController
    {
        require(
            //_to[pointId] == address(0),
            _data[pointId].to == address(0),
            'to can be setted only once for deal point'
        );
        //_to[pointId] = account;
        _data[pointId].to = account;
    }

    function tokenAddress(uint256 pointId) external view returns (address) {
        return _tokenAddress[pointId];
    }

    function value(uint256 pointId) external view returns (uint256) {
        //return _value[pointId];
        return _data[pointId].value;
    }

    function balance(uint256 pointId) external view returns (uint256) {
        return _balances[pointId];
        //return _data[pointId].balance;
    }

    function fee(uint256 pointId) external view returns (uint256) {
        return _fee[pointId];
        //return _data[pointId].fee;
    }

    function owner(uint256 pointId) external view returns (address) {
        //return this.isSwapped(pointId) ? this.to(pointId) : this.from(pointId);
        DealPointDataInternal memory point = _data[pointId];
        return this.isSwapped(pointId) ? point.to : point.from;
    }

    function dealsController() external view returns (address) {
        return address(_dealsController);
    }

    function withdraw(uint256 pointId) external payable onlyDealsController {
        address ownerAddr = this.owner(pointId);
        DealPointDataInternal memory point = _data[pointId];
        require(
            _balances[pointId] > 0,
            //point.balance > 0,
            'has no balance to withdraw'
        );
        require(
            address(_dealsController) == msg.sender || ownerAddr == msg.sender,
            'only owner or deals controller can withdraw'
        );
        if (ownerAddr == point.from) _isExecuted[pointId] = false;
        uint256 withdrawCount = _balances[pointId];
        _balances[pointId] = 0;
        require(withdrawCount > 0, 'not enough balance');
        _withdraw(pointId, ownerAddr, withdrawCount);
    }

    function execute(uint256 pointId, address addr)
        external
        payable
        onlyDealsController
    {
        DealPointDataInternal storage point = _data[pointId];
        if (_isExecuted[pointId]) return;
        //if (_from[pointId] == address(0)) _from[pointId] = addr;
        //if (point.isExecuted) return;
        if (point.from == address(0)) point.from = addr;
        _execute(pointId, addr);
        _isExecuted[pointId] = true;
        //point.isExecuted = true;
    }

    function _execute(uint256 pointId, address from) internal virtual;

    function _withdraw(
        uint256 pointId,
        address withdrawAddr,
        uint256 withdrawCount
    ) internal virtual;
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





contract EtherDealPointsController is
    DealPointsController,
    IEtherDealPointsController
{
    constructor(address dealsController_)
        DealPointsController(dealsController_)
    {}

    function dealPointTypeId() external pure returns (uint256) {
        return 1;
    }

    function createPoint(
        uint256 dealId_,
        address from_,
        address to_,
        uint256 count_
    ) external onlyFactory {
        uint256 pointId = _dealsController.getTotalDealPointsCount() + 1;
        _data[pointId] = DealPointDataInternal(dealId_, count_, from_, to_);
        _dealsController.addDealPoint(dealId_, address(this), pointId);
    }

    function _execute(uint256 pointId, address) internal virtual override {
        DealPointDataInternal memory point = _data[pointId];
        // transfer
        uint256 count = point.value;
        require(msg.value >= count, 'not enough eth');
        _balances[pointId] = count;

        // calculate fee
        _fee[pointId] =
            (count * _dealsController.feePercent()) /
            _dealsController.feeDecimals();
    }

    function _withdraw(
        uint256 pointId,
        address withdrawAddr,
        uint256 withdrawCount
    ) internal virtual override {
        uint256 pointFee = _fee[pointId];
        if (!this.isSwapped(pointId)) pointFee = 0;
        uint256 toTransfer = withdrawCount - pointFee;
        if (pointFee > 0) {
            (bool sentFee, ) = payable(_dealsController.feeAddress()).call{
                value: pointFee
            }('');
            require(sentFee, 'sent fee error: ether is not sent');
        }
        (bool sent, ) = payable(withdrawAddr).call{ value: toTransfer }('');
        require(sent, 'withdraw error: ether is not sent');
    }

    function feeIsEthOnWithdraw() external pure returns (bool) {
        return false;
    }    
    
    function executeEtherValue(uint256 pointId) external view returns (uint256) {
        return _data[pointId].value;
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
