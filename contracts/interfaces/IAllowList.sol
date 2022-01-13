//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title allow list
/// @notice allow list for the contract. manage the list of allowed addresses
interface IAllowList {

    /// @notice event emitted when address added to allow list
    event AllowedSet(address allowList, address _addr, bool _isAllowed);

    /// @notice Add an address to the allow list
    function setAllowed(address _addr, bool allowed) external;

    /// @notice Check if an address is on the allow list
    function isAllowed(address _addr) external view returns (bool);

}
