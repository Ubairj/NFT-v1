//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @notice a list of addresses.
interface IUint256List {

    /// @notice Get all items
    /// @return itemList all items
    function getItems()
    external
    view
    returns (uint256[] memory itemList);

    /// @notice get item at
    /// @param _index index of the item
    /// @return _item the item
    function getItemAt(uint256 _index)
    external
    view
    returns (address _item);

    /// @notice Get the number of items
    /// @return count the number of items
    function getItemCount()
    external
    view
    returns (uint256 count);

    /// @notice returns whether the item is in the list
    /// @param toCheck the item to check
    /// @return isMember whether the item is in the list
    function isMemberItem(uint256 toCheck)
    external
    view
    returns (bool isMember);

}
