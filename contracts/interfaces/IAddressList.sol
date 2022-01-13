//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @notice a list of addresses.
interface IAddressList {

    /// @notice Get  all address tokens
    /// @return addressList all tokens for address
    function addresses()
    external
    view
    returns (address[] memory addressList);

    /// @notice returns whether the address is in the list
    /// @return isMember whether the address is in the list
    function isMemberAddress(address toCheck)
    external
    view
    returns (bool isMember);

}
