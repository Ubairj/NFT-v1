//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IPurchaseRecordList.sol";

/// @dev extended by the multitoken
contract PurchaseRecordList is IPurchaseRecordList {

    // the purchase records list
    PurchaseRecord[] private purchaseRecords;

    /// @notice Get get all purchase records
    /// @param _purchaseRecord the owner of the purchase records
    /// @return the purchase record numbering
    function _addPurchaseRecord(PurchaseRecord memory _purchaseRecord)
    internal returns (uint256) {
        purchaseRecords.push(_purchaseRecord);
        return purchaseRecords.length;
    }

    /// @notice Get get all purchase records
    /// @return _purchaseRecords all purchase records
    function getPurchaseRecords()
    external
    virtual
    view
    override
    returns (PurchaseRecord[] memory _purchaseRecords) {

    }

    /// @notice get purchase record at index
    /// @param index - the index of the purchase record
    /// @return _purchaseRecord - the purchase record at index
    function getPurchaseRecord(uint256 index)
    external
    virtual
    view
    override
    returns (PurchaseRecord memory _purchaseRecord) {

    }

    /// @notice Get the number of purchase records
    /// @return count the number of purchase records
    function getPurchaseRecordCount()
    external
    virtual
    view
    override
    returns (uint256 count) {

    }

}
