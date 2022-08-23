// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IFlexiblePortfolio} from "./helium/interfaces/IFlexiblePortfolio.sol";
import {IPermissionedPortfolio} from "./interfaces/IPermissionedPortfolio.sol";
import {IERC20WithDecimals} from "./helium/interfaces/IERC20WithDecimals.sol";
import {IDebtInstrument} from "./helium/interfaces/IDebtInstrument.sol";
import {IValuationStrategy} from "./helium/interfaces/IValuationStrategy.sol";
import {BasePortfolioFactory} from "./helium/BasePortfolioFactory.sol";

contract PermissionedPortfolioFactory is BasePortfolioFactory {
    address defaultController;

    function setDefaultController(address _defaultController) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_defaultController != address(0), "PermissionedPortfolioFactory: Default controller admin cannot be address zero");
        require(
            _defaultController != defaultController,
            "PermissionedPortfolioFactory: Default controller admin cannot be set to its current value"
        );
        defaultController = _defaultController;
    }

    function createPortfolio(
        IERC20WithDecimals _underlyingToken,
        uint256 _duration,
        uint256 _maxValue,
        IFlexiblePortfolio.Strategies calldata strategies,
        IDebtInstrument[] calldata _allowedInstruments,
        uint256 _managerFee,
        IFlexiblePortfolio.ERC20Metadata calldata _tokenMetadata
    ) external onlyRole(MANAGER_ROLE) {
        require(defaultController != address(0), "PermissionedPortfolioFactory: Default controller admin is not set");
        bytes memory initCalldata = abi.encodeWithSelector(
            IPermissionedPortfolio.initialize.selector,
            protocolConfig,
            _duration,
            _underlyingToken,
            msg.sender,
            _maxValue,
            strategies,
            _allowedInstruments,
            _managerFee,
            _tokenMetadata,
            defaultController
        );
        _deployPortfolio(initCalldata);
    }
}
