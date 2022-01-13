// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice implemented by erc1155 tokens to allow the bridge to mint and burn tokens bridge must be able to mint and burn tokens on the multitoken contract
interface IERC721Multinetwork {

    /// @notice transfer tokens from one network / address to another network / address
    /// @param from from address
    /// @param to to address
    /// @param network destination network id
    /// @param id token id
    /// @param data additional data
    function networkTransferFrom(
        address from,
        address to,
        uint256 network,
        uint256 id,
        bytes calldata data
    ) external;

    /**
     * @notice Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferNetworkERC721(
        uint256 networkFrom,
        uint256 networkTo,
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id
    );

}
