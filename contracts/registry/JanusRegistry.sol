//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IJanusRegistry.sol";

// TODO write tests

/// @notice implements a Janus (multifaced) registry. GLobal registry items can be set by specifying 0 for the registry face. Those global items are then available to all faces, and individual faces can override the global items for
contract JanusRegistry is IJanusRegistry {

    struct AddressMapItem {
        string face;
        string name;
    }
    mapping(string => mapping(string => address)) public _registry;
    mapping(address => AddressMapItem) internal _addressMap;

    // @notice sets the address of a registry item
    function _add(string memory face, string memory name, address addr) internal {
        _registry[face][name] = addr;
        _addressMap[addr] = AddressMapItem(face, name);
    }

    /// @notice Get the registro address given the face name. If the face is 0, the global registry is returned.
    /// @param face the face name or 0 for the global registry
    /// @param name uint256 of the token index
    /// @return item the service token record
    function get(string memory face, string memory name)
    external
    virtual
    view
    override
    returns (address item) {
        address global = _registry[""][name];
        address local = _registry[face][name];

        return local == address(0) ? global : local;

    }

    /// @notice returns whether the service is in the list
    /// @param item uint256 of the token index
    function member(address item)
    external
    virtual
    view
    override
    returns (string memory face, string memory name) {
        AddressMapItem memory itemInfo = _addressMap[item];
        return (itemInfo.face, itemInfo.name);
    }

}
