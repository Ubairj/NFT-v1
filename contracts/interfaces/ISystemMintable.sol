//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


/// @notice system-mintable. Not sure how this one is used, need to doublecheck
interface ISystemMintable {

    /// @notice mint a token
    /// @param recipient address of the recipient
    /// @param tokenHash the token hash of the token to mint
    function mint(address recipient, uint256 tokenHash) external;

    /// @notice burn a token
    /// @param tokenHash the token hash of the token to burn
    function burn(uint256 tokenHash) external;

}
