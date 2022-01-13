// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice the fee manager manages fees by providing the fee amounts for the requested identifiers, which are keccak256 hashes of the elements that use this contract
interface IFeeManager {

    /// @notice emitted when a fee is changed
    event FeeChanged(
        address indexed operator,
        string indexed feeLabel,
        uint256 value
    );

    /// @notice get the fee for the given fee type hash
    /// @param feeLabel the keccak256 hash of the fee type
    /// @return the fee amount
    function fee(string memory feeLabel) external view returns (uint256);

    /// @notice set the fee for the given fee type hash
    /// @param feeLabel the keccak256 hash of the fee type
    /// @param _fee the new fee amount
    function setFee(string memory feeLabel, uint256 _fee) external;

}
