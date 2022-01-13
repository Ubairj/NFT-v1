//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @notice a metered service. returns a fee amount for each fee call and a uid for the fee
interface IMeteredService {

    /// @notice get the fee uid for the current call
    /// @return _fees the fee uid
    function getFeeUids() external view returns (string[] memory _fees);

}
