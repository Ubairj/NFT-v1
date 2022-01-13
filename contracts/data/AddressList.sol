//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IAddressList.sol";

// TODO: implement this contract

/// @notice a list of addresses.
contract AddressList is IAddressList {

    address[] private _addresses;
    mapping (address => bool) private _isMember;

    /// @notice internal adddress adder method. used by overriding classes to populte the address list
    /// @param _address the address to add
    function _addAddress(address _address) internal {
        if(!_isMember[_address]) {
            _addresses.push(_address);
            _isMember[_address] = true;
        }
    }

    /// @notice Get  all address tokens
    /// @return addressList all tokens for address
    function addresses()
    external
    virtual
    view
    override
    returns (address[] memory addressList) {
        addressList = _addresses;
    }

    /// @notice returns whether the address is in the list
    /// @return isMember whether the address is in the list
    function isMemberAddress(address toCheck)
    external
    virtual
    view
    override
    returns (bool isMember) {
        isMember = _isMember[toCheck];
    }

}
