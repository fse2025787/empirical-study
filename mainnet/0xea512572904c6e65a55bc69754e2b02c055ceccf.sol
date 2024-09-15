// SPDX-License-Identifier: AGPL-3.0-only
pragma experimental ABIEncoderV2;

// 
pragma solidity 0.8.10;








contract ArcUpdateProposalPayload {

    
    ILendingPoolConfigurator constant configurator = ILendingPoolConfigurator(0x4e1c7865e7BE78A7748724Fa0409e88dc14E67aA);

    
    IArcTimelock constant arcTimelock = IArcTimelock(0xAce1d11d836cb3F51Ef658FD4D353fFb3c301218);

    
    IEcosystemReserveController constant reserveController = IEcosystemReserveController(0x3d569673dAa0575c936c7c67c4E6AedA69CC630C);

    
    address constant reserve = 0x25F2226B597E8F9514B3F68F00f494cF4f286491;

    
    address constant govHouse = 0x82cD339Fa7d6f22242B31d5f7ea37c1B721dB9C3;

    
    address constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    
    address constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    
    address constant wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    
    address constant aave = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

    
    address immutable self;

    constructor() {
        self = address(this);
    }
    
    
    
    function executeQueueTimelock() external {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        string[] memory signatures = new string[](1);
        bytes[] memory calldatas = new bytes[](1);
        bool[] memory withDelegatecalls = new bool[](1);

        targets[0] = self;
        signatures[0] = "execute()";
        withDelegatecalls[0] = true;

        arcTimelock.queue(targets, values, signatures, calldatas, withDelegatecalls);

        // reimburse gas costs from ecosystem reserve
        reserveController.transfer(reserve, aave, govHouse, 15 ether);
    }

    
    function execute() external {
        // address, ltv, liqthresh, bonus
        configurator.configureReserveAsCollateral(usdc, 8550, 8800, 10450);
        configurator.configureReserveAsCollateral(weth, 8250, 8500, 10500);
        configurator.configureReserveAsCollateral(wbtc, 7000, 7500, 10650);
        configurator.configureReserveAsCollateral(aave, 6250, 7000, 10750);
    }
}

pragma solidity 0.8.10;

interface IArcTimelock {
    function queue(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls
    ) external;

    function getActionsSetCount() external returns (uint256);
    
    function execute(uint256) external payable;
}

// 
pragma solidity >=0.4.22 <0.9.0;

interface IEcosystemReserveController {
    function transfer(address collector, address token, address guy, uint256 wad) external;
}

pragma solidity 0.8.10;


interface ILendingPoolConfigurator {

    function configureReserveAsCollateral(
        address asset,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus
    ) external;

    function setReserveFactor(address asset, uint256 reserveFactor) external;
}