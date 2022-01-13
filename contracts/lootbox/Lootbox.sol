// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../interfaces/ILootbox.sol";

import "../interfaces/IMultiToken.sol";

import "../interfaces/ICollection.sol";

import "../interfaces/ITokenDefinitions.sol";

import "../interfaces/IFactory.sol";

import "../tokensale/TokenSale.sol";

import "../token/TokenDefinitions.sol";

import "./LootboxLib.sol";
import "./LootSet.sol";

/// @notice A lootbox is a contract that works with an erc1155 to implement a game lootbox:
/// a lootbox is a contract that accepts a single quantity of some erc1155 tokenhash and
/// then based on a set of rules goverened by probability, mints one or more outgoing tokens
/// as it burns the incoming token. The rules are defined by the lootbox author and are
/// stored in the lootbox contract. A newly-created lootbox contract assigns controllership
/// to its creator, who can them add other controllers, and can set the rules for the lootbox.
/// Each lootbox is configured with some number of Loot items, each of which has deterministic
/// tokenhash. These loot items each have names, symbols, and a probability of being minted.
/// Users open the lootbox by providing the right gem to the lootbox contract, and then
/// the lootbox contract mints the right number of tokens for the user. This contract uses
/// a pseudo-random deterministic sieve to determine the number and type of tokens minted
contract Lootbox is ILootbox, ICollection, IFactoryElement, TokenSale {

    using LootboxLib for LootboxSettings;
    using LootSetLib for ILootbox.LootSet;

    address internal _serviceOwner;

    // the lootbox settings
    CollectionSettings internal _collectionSettings;
    LootboxSettings internal _lootboxSettings;

    LootSet internal _loot;

    /// @notice intialize the contract. should be called by overriding contract
    /// @param lootboxInit struct with tokensale data
    function initialize(
        LootboxSettings memory lootboxInit,
        TokenDefinitionsSettings memory tdInit,
        CollectionSettings memory collectionInit) public {

        // set collection and lootbox settings
        //_collectionSettings = collectionInit;
        //_lootboxSettings = lootboxInit;

        // get the multitoken address
        address multiToken = IJanusRegistry(_collectionSettings.serviceRegistry).get("LootboxLib", "MultiToken");

        // set token definitions
        TokenDefinitions(this).initialize(tdInit);

        // sanity check input values
        require(multiToken != address(0), "Multitoken address must be set");
        require(_tokenPrice.price != 0, "Price must be set");

        // check symbol and name for validity
        require(bytes(collectionInit.name).length != 0, "Name must be set");
        require(bytes(collectionInit.symbol).length != 0, "Symbol must be set");

        // check min and max loot per open
        require(lootboxInit.minLootPerOpen != 0, "Min loot must be set");
        require(lootboxInit.maxLootPerOpen != 0, "Max loot must be set");

    }

    // *********************  ILootbox Implementation **********************

    /// @notice open the lootbox. mints loot according to lootbox data
    /// @return the the minted loot
    function open() external payable virtual override returns (Loot[] memory) {

        //return LootboxLib.openLootbox(_collectionSettings.container, lootboxSettings, _loot);

    }

    /// @notice get the loot data by index
    /// @return lootItem the loot data
    function tokenDefinitions() external view virtual override returns (TokenDefinition[] memory lootItem) {

        return _tokenDefinitionsSettings.tokenDefinitions;

    }

    /// @notice returns whether the given item is a member of the collection
    /// @param token the token hash
    /// @return _member true if the token is a member of the collection, false otherwise
    function isMemberOf(uint256 token) external virtual view override(ICollection,TokenSale) returns (bool _member) {

        return _loot.valueList[token].id == token;

    }

    /// @notice returns all the tokens in the collection as an array
    /// @return _members the collection tokens
    function members() external virtual view override(ICollection,TokenSale) returns (uint256[] memory _members) {


    }

    /// @notice add a loot
    /// @param tokenDefinition the loot to add
    function addLoot(
        IToken.TokenDefinition memory tokenDefinition
    )
    external
    virtual
    override {

        _tokenDefinitionsSettings.tokenDefinitions.push(tokenDefinition);

    }

    /// @notice add a loot
    /// @param tokenDefinition the loot to add
    function setLoot(
        uint256 index,
        IToken.TokenDefinition memory tokenDefinition
    ) external virtual override {

        _tokenDefinitionsSettings.tokenDefinitions[index] = tokenDefinition;

    }

    function factoryCreated(address _owner) external override {

        require(_serviceOwner == address(0), "Factory already created");
        _serviceOwner = _owner;

    }

}
