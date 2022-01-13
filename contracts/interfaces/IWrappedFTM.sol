//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


/// @notice implements wrapped FTM. Used for repayments of flash loans.
interface IWrappedFTM {

    /// @notice deposit wraps received FTM tokens as wFTM in 1:1 ratio by minting the received amount of FTMs in wFTM on the sender's address.
    /// @return the amount of wFTM deposited
    function deposit() external payable returns (uint256);

    /// @notice withdraw unwraps FTM tokens by burning specified amount of wFTM from the caller address and sending the same amount of FTMs back in exchange.
    /// @param amount the amount of wFTM to be withdrawn
    /// @return the amount of FTMs withdrawn
    function withdraw(uint256 amount) external returns (uint256);

}
