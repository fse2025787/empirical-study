// SPDX-License-Identifier: GPL-2.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-12-01
*/

// 
pragma solidity 0.8.17;


library Constants {
    
    address internal constant _ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    
    address internal constant _stETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;

    
    address internal constant _cETHER = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    
    address internal constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    
    address internal constant _MORPHO_AAVE = 0x777777c9898D384F785Ee44Acfe945efDFf5f3E0;

    
    address internal constant _BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    
    address internal constant _MORPHO_COMPOUND = 0x8888882f8f843896699869179fB6E4f7e3B58888;

    
    address internal constant _FACTORY_GUARD_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;

    /////////////////////////////////////////////////////////////////
    /// --- ERRORS
    ////////////////////////////////////////////////////////////////

    
    error NOT_ALLOWED();

    
    error INVALID_LENDER();

    
    error INVALID_MARKET();

    
    error DEADLINE_EXCEEDED();

    
    error NOT_ENOUGH_RECEIVED();
}

interface IMorpheus {
    function multicall(uint256 deadline, bytes[] calldata data) external payable returns (bytes[] memory results);
}

interface IDSAuth {
    function setAuthority(address _authority) external;
    function authority() external view returns (address);
    function isAuthorized(address src, bytes4 sig) external view returns (bool);
}

interface IDSGuard {
    function canCall(address src_, address dst_, bytes4 sig) external view returns (bool);

    function permit(bytes32 src, bytes32 dst, bytes32 sig) external;

    function forbid(bytes32 src, bytes32 dst, bytes32 sig) external;

    function permit(address src, address dst, bytes32 sig) external;

    function forbid(address src, address dst, bytes32 sig) external;
}

interface IDSGuardFactory {
    function newGuard() external returns (address);
}

abstract contract ProxyPermission {
    
    bytes4 internal constant _EXECUTE_SELECTOR = bytes4(keccak256("execute(address,bytes)"));

    
    
    function _togglePermission(address _target, bool _give) internal {
        address currAuthority = IDSAuth(address(this)).authority();
        IDSGuard guard = IDSGuard(currAuthority);

        if (currAuthority == address(0)) {
            guard = IDSGuard(IDSGuardFactory(Constants._FACTORY_GUARD_ADDRESS).newGuard());
            IDSAuth(address(this)).setAuthority(address(guard));
        }

        if (_give && !guard.canCall(_target, address(this), _EXECUTE_SELECTOR)) {
            guard.permit(_target, address(this), _EXECUTE_SELECTOR);
        } else if (!_give && guard.canCall(_target, address(this), _EXECUTE_SELECTOR)) {
            guard.forbid(_target, address(this), _EXECUTE_SELECTOR);
        }
    }
}

interface IFlashLoan {
    function flashLoan(address _receiver, address[] memory _tokens, uint256[] memory _amounts, bytes calldata _data)
        external;
}

interface IFlashLoanBalancer {
    function flashLoanBalancer(address[] memory _tokens, uint256[] memory _amounts, bytes calldata _data) external;
}



contract Neo is ProxyPermission {
    
    IMorpheus internal immutable _MORPHEUS;

    
    IFlashLoanBalancer internal immutable _FLASH_LOAN;

    constructor(address _morpheus, address _flashLoan) {
        _MORPHEUS = IMorpheus(_morpheus);
        _FLASH_LOAN = IFlashLoanBalancer(_flashLoan);
    }

    
    
    
    
    function executeFlashloan(address[] calldata tokens, uint256[] calldata amounts, bytes calldata data)
        external
        payable
    {
        // Give _FLASH_LOAN permission to call execute on behalf DSProxy.
        _togglePermission(address(_FLASH_LOAN), true);

        // Execute flash loan.
        _FLASH_LOAN.flashLoanBalancer(tokens, amounts, data);

        // Remove _FLASH_LOAN permission to call execute on behalf DSProxy.
        _togglePermission(address(_FLASH_LOAN), false);
    }

    receive() external payable {}
}