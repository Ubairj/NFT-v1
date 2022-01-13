//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IPermissionManager.sol";

import "../interfaces/IJanusRegistry.sol";

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

// TODO comments, figure out how best to use this

/// @notice common access control interface. defines access control levels
contract PermissionManager is IPermissionManager, Initializable,  AccessControl {

    bytes32 public constant SUPERADMIN_ROLE = keccak256("SUPERADMIN");
    bytes32 public constant ASSIGNMINT_ROLE = keccak256("MINT");
    bytes32 public constant ASSIGNBURN_ROLE = keccak256("BURN");

    // the service registry controls everything. It tells all objects
    // what service address they are registered to, who the owner is,
    // and all other things that are good in the world.
    IJanusRegistry private _serviceRegistry;

    function initialize(address registry) public initializer {
        _serviceRegistry = IJanusRegistry(registry);
    }

    function _isSuperAdmin() internal view returns (bool) {
        return _serviceRegistry.get("PermissionManager", "owner") == msg.sender
        || hasRole(SUPERADMIN_ROLE, msg.sender);
    }

    function isSuperAdmin() external virtual view override returns (bool) {
        return _isSuperAdmin();
    }

    modifier onlySuperAdmin() {
        require(
            _isSuperAdmin(),
            "Only superadmin can perform this action"
        );
        _;
    }

    function isPermissioned(bytes32 _role) external virtual view override returns(bool) {
        return hasRole(_role, msg.sender) || _isSuperAdmin();
    }

    function givePermission(address account, bytes32 _role) external virtual override onlySuperAdmin {
       _setupRole(_role, account);
       _setRoleAdmin(_role, SUPERADMIN_ROLE);
    }

    function takePermission(address account, bytes32 _role) external virtual override onlySuperAdmin {
       revokeRole(_role, account);
    }

}
