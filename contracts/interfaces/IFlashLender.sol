// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./IERC3156FlashLender.sol";

/// @notice a flash lender interface. extends ERC3156FlashLender by adding methods to get and set the flash fee
interface IFlashLender is IERC3156FlashLender {
    /// @notice set the fee as a permillion divisor of the price of the item
    /// @param _feePermillion the fee as a permillion divisor of the price of the item
    function setFeePermillion(uint256 _feePermillion) external;

    /// @notice get the fee as a permillion divisor of the price of the item
    /// @return the fee as a permillion divisor of the price of the item
    function getFeePermillion() external view returns (uint256);
}
