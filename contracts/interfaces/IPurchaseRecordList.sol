//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @dev extended by the multitoken
interface IPurchaseRecordList {

    /// @notice Data generated from a token sale
    struct PurchaseRecord {

        address token; // the token being sold
        address recipient; // the recipient of the tokens
        uint256 tokenHash; // the hash of the token
        uint256 numbering; // the number of the token
        uint256 networkId; // the network id of the token
        uint256 quantity; // the quantity of the token
        uint256 blockHeight; // the block height of the transaction
        uint256 blockTime; // the block time of the transaction

    }

    /// @notice Get get all purchase records
    /// @return purchaseRecords all purchase records
    function getPurchaseRecords()
    external
    view
    returns (PurchaseRecord[] memory purchaseRecords);

    /// @notice get purchase record at index
    /// @param index - the index of the purchase record
    function getPurchaseRecord(uint256 index)
    external
    view
    returns (PurchaseRecord memory purchaseRecord);

    /// @notice Get the number of purchase records
    /// @return count the number of purchase records
    function getPurchaseRecordCount()
    external
    view
    returns (uint256 count);

}
