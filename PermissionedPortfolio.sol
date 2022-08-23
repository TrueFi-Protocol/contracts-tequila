// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./FlexiblePortfolio.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract PermissionedPortfolio is FlexiblePortfolio {
    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");

    event ControllerTransfer(address _controller, address indexed _from, address indexed _to, uint256 _value);

    function initialize(
        IProtocolConfig _protocolConfig,
        uint256 _duration,
        IERC20 _underlyingToken,
        address _manager,
        uint256 _maxValue,
        Strategies calldata _strategies,
        IDebtInstrument[] calldata _allowedInstruments,
        uint256 _managerFee,
        ERC20Metadata calldata _tokenMetadata,
        address _controller
    ) external initializer {
        require(_controller != address(0), "PermissionedPortfolio: controller cannot be the zero address");
        __FlexiblePortfolio_init(
            _protocolConfig,
            _duration,
            _underlyingToken,
            _manager,
            _maxValue,
            _strategies,
            _allowedInstruments,
            _managerFee,
            _tokenMetadata
        );
        _grantRole(CONTROLLER_ROLE, _controller);
        _setRoleAdmin(CONTROLLER_ROLE, CONTROLLER_ROLE);
    }

    function controllerTransfer(
        address _from,
        address _to,
        uint256 _value
    ) external whenNotPaused onlyRole(CONTROLLER_ROLE) {
        ERC20Upgradeable._transfer(_from, _to, _value);
        emit ControllerTransfer(msg.sender, _from, _to, _value);
    }
}
