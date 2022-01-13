//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @notice common access control interface. defines access control levels
interface IPermissionManager {

    function isSuperAdmin() external view returns (bool);

    function isPermissioned(bytes32 _role) external view returns(bool);

    function givePermission(address account, bytes32 _role) external;

    function takePermission(address account, bytes32 _role) external;

}
