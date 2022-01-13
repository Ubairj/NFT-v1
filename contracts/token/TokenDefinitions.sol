// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/IToken.sol";
import "../interfaces/ITokenDefinitions.sol";
import "../data/DataSource.sol";

import "./TokenDefinitionSet.sol";

/// @notice A container is a contract that contains a list of token definitions, each of which can be
/// minted into a token. This contract implements the IContainer interface and handles management of the items
contract TokenDefinitions is ITokenDefinitions {

    using TokenDefinitionSetLib for ITokenDefinitions.TokenDefinitionSet;

    // the container's internal settings
    TokenDefinitionsSettings internal _tokenDefinitionsSettings;

    /// @notice init the container with the given settings
    function initialize(TokenDefinitionsSettings memory c) public {

        require(_tokenDefinitionsSettings.tokenDefinitions.length == 0,
            "TokenDefinitions already initialized");
       // _tokenDefinitionsSettings.tokenDefinitions = c.tokenDefinitions;
        emit TokenDefinitionsCreated(msg.sender, address(this), c.tokenDefinitions);

    }

    /// @notice return the list of items in this container
    /// @return the list of items in this container
    function _makeHash(IToken.TokenDefinition memory _definition) internal view returns (uint256) {

        return uint256(
            keccak256(abi.encodePacked(address(this), _definition.name))
        );

    }
    function makeHash(IToken.TokenDefinition memory _definition) external view override returns (uint256) {

        return _makeHash(_definition);

    }

    /// @notice return the list of items in this container
    /// @return the list of items in this container
    function tokenDefinitions() external virtual view override returns (IToken.TokenDefinition[] memory) {

        return _tokenDefinitionsSettings.tokenDefinitions;

    }

    /// @notice insert or update the item value in this container
    /// @param _item the item to insert or update
    function _addDefinition(IToken.TokenDefinition memory _item) internal {

        // basic sanity checks
        require(bytes(_item.symbol).length > 0, "Symbol must be set");
        require(bytes(_item.name).length > 0, "name must be set");

        // add token definition to items
        _tokenDefinitionsSettings.tokenDefinitions.push(_item);

        emit TokenDefinitionAdded(msg.sender, address(this), _item);

    }
}
