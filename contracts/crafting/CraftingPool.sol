// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../interfaces/ICraftingMatrix.sol";

import "../interfaces/IMultiToken.sol";

import "../interfaces/ICollection.sol";

import "../interfaces/ITokenDefinitions.sol";

import "../interfaces/IFactory.sol";

import "../tokensale/TokenSale.sol";

import "../token/TokenDefinitions.sol";

import "../utils/UInt256Set.sol";

import "./CraftingLib.sol";


contract CraftingPool is ICraftingMatrix, ICollection, IFactoryElement, TokenSale {

    using CraftingLib for CraftingMatrixSettings;

    address internal _serviceOwner;

    // the lootbox settings
    CollectionSettings internal _collectionSettings;
    CraftingMatrixSettings internal _craftingSettings;

    /// @notice intialize the contract. should be called by overriding contract
    /// @param craftingInit struct with tokensale data
    /// @param tdInit struct with tokensale data
    /// @param collectionInit struct with tokensale data
    function initialize(
        CraftingMatrixSettings memory craftingInit,
        ITokenDefinitions.TokenDefinitionsSettings memory tdInit,
        CollectionSettings memory collectionInit
    ) public {

        require(_collectionSettings.contractAddress == address(0),
        "Contract already initialized");

        // set collection and lootbox settings
        //_collectionSettings = collectionInit;
       // _craftingSettings = craftingInit;

        // set token definitions
        TokenDefinitions(this).initialize(tdInit);

        require(_tokenPrice.price != 0, "Price must be set");

    }

    /// @notice returns whether the given item is a member of the collection
    /// @param token the token hash
    /// @return _member true if the token is a member of the collection, false otherwise
    function isMemberOf(uint256 token) external virtual view override(ICollection,TokenSale) returns (bool _member) {

    }

    /// @notice returns all the tokens in the collection as an array
    /// @return _members the collection tokens
    function members() external virtual view override(ICollection,TokenSale) returns (uint256[] memory _members) {

    }

    function factoryCreated(address _owner) external override {

        require(_serviceOwner == address(0), "Factory already created");
        _serviceOwner = _owner;

    }

}
