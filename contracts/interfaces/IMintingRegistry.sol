//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @notice a bank. allows deposits of any token and tracks balance by depositor and only allows withdraw from depositor or assigned agent, disallows negative balances.
interface IMintingRegistry {

    event MintRegistered(address indexed minter,  uint256 collection, uint256 tokenHash);

    /// @notice register a mint
    /// @param minter_ address of the account
    /// @param collectionId the collection id
    /// @param id address of the account
    function register(address minter_, uint256 collectionId, uint256 id) external;

    /// @notice get the minter for the given token
    /// @param id the id of the token
    /// @return isMinter whether the account is the minter
    function minter(uint256 id) external view returns (address isMinter);

    /// @notice return the collection id of the token
    /// @param id uint256 of the token
    /// @return collectionId the collection id
    function collection(uint256 id) external view returns (uint256 collectionId);

    /// @notice get minted tokens by account
    /// @param minter_ uint256 of the token index
    /// @return mintedOut the minted items
    function minted(address minter_) external view returns (uint256[] memory mintedOut);

    /// @notice get all the members of a collection
    /// @param collectionIn uint256 of the collection
    /// @return minterOut all the collection members
    function collectionMinter(uint256 collectionIn) external view returns (address minterOut);

    /// @notice get all the members of a collection
    /// @param collectionIn uint256 of the collection
    /// @return membersOut all the collection members
    function members(uint256 collectionIn) external view returns (uint256[] memory membersOut);

    function minters() external view returns (address[] memory _mintersOut);

    function collections() external view returns (uint256[] memory _collectionsOut);

    function tokens() external view returns (uint256[] memory _tokensOut);
}
