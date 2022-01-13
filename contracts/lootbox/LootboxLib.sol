// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../interfaces/ILootbox.sol";
import "../interfaces/ICollection.sol";
import "../interfaces/IRandomFarm.sol";
import "../interfaces/IMultiToken.sol";
import "../interfaces/IERC1155Mint.sol";
import "../interfaces/IERC1155Burn.sol";
import "../interfaces/IDataManager.sol";
import "../interfaces/IJanusRegistry.sol";

/// @notice this library contains loot-related business logic, specifically mogic for opening a lootbox and awarding some amount of prizes.
library LootboxLib {
    /// @notice emitted when lootbox is created
    event LootboxCreated(uint256 id, address contractAddress, ILootbox.LootboxSettings data);

    /// @notice emitted when lootbox tokens are minted
    event LootboxTokensMinted(
        address indexed minter,
        uint256 indexed hash,
        ILootbox.LootboxSettings mintedLootbox,
        uint256 mintedAmount
    );

    /// @notice emitted when lootbox is opened
    event LootboxOpened(
        address indexed containerAddress,
        address indexed userAddress,
        ILootbox.LootboxSettings containerObject,
        IToken.TokenDefinition[] itemObjects
    );

    /// @notice emitted when loot is minted
    event LootMinted(
        address indexed minter,
        uint256 indexed hash,
        ILootbox.LootboxSettings mintedLootbox,
        IToken.TokenDefinition mintedLoot
    );

    /// @notice emitted when a loot item is added to the lootbox
    event LootAdded(
        address indexed adder,
        uint256 indexed hash,
        ILootbox.LootboxSettings targetLootbox,
        IToken.TokenDefinition addedLoot
    );

    /// @notice open the lootbox.
    /// @param _container the lootbox container struct
    /// @param _lootbox the lootbox-specific struct
    /// @param _tokenDefinitions list of loot to choose from to award to the user
    /// @return _lootOut the users newly-awarded loot items
    function openLootbox(
        ICollection.CollectionSettings memory _container,
        ILootbox.LootboxSettings memory _lootbox,
        IToken.TokenDefinition[] memory _tokenDefinitions
    ) external returns (IToken.TokenDefinition[] memory _lootOut) {

        address multiToken = IJanusRegistry(_container.serviceRegistry).get("LootboxLib", "MultiToken");
        address randomFarmer = IJanusRegistry(_container.serviceRegistry).get("LootboxLib", "RandomFarmer");

        // make sure that the caller has at least one lootbox token
        require(
            IERC1155(multiToken).balanceOf(msg.sender, _container.id) > 0,
            "Insufficient lootbox token balance"
        );

        // no need to transfer the lootbox token anywhere, we can just burn it in place
        IERC1155Burn(multiToken).burn(msg.sender, _container.id, 1);

        // first we need to determine the number of loot items to mint
        // if min == max, then we mint that exact number of items. Otherwise,
        // we use a random number between min and max to determine the number
        // of loot items to mint
        uint8 lootCount = _lootbox.minLootPerOpen;
        if (_lootbox.minLootPerOpen != _lootbox.maxLootPerOpen) {
            lootCount = uint8(
                IRandomFarmer(randomFarmer).getRandomNumber(
                    uint256(_lootbox.minLootPerOpen),
                    uint256(_lootbox.maxLootPerOpen)
                )
            );
        } else lootCount = _lootbox.minLootPerOpen;

        // now that we know how much we need to mint, we can create the
        // loot roll array that will hold our results and create some loot
        _lootOut = new IToken.TokenDefinition[](lootCount);

        // now we need some randomness to determine which loot items we win
        // we use a pseudo-random deterministic sieve to determine the number
        // and type of tokens minted
        uint256[] memory _lootRoll = IRandomFarmer(randomFarmer).getRandomUints(lootCount);

        // mint the loot items
        for (uint256 i = 0; i < lootCount; i++) {
            // generate a loot item given a random seed
            (uint8 winIndex, uint256 winRoll) = _generateLoot(_tokenDefinitions, _lootRoll[i], _lootbox.probabilitiesSum);

            // assign the loot item to the loot array
            _lootOut[i] = _tokenDefinitions[winIndex];
            _lootOut[i].probabilityRoll = winRoll;

            // mint the loot item to the multitoken
            IERC1155Mint(multiToken).mint(msg.sender, _lootOut[i].id, 1);
        }

        /// generate an event reporting on the loot that was found
        emit LootboxOpened(msg.sender, _container.contractAddress, _lootbox, _lootOut);

    }

    /// @notice mint some loot for a user from the given lootbox
    /// @param _container the lootbox to award the loot from
    /// @param _lootbox the list of all possible loot items to award from
    /// @param _tokenDefinitions the index of the loot item to mint
    /// @param index the index of the loot item to mint
    /// @param amount the amount of loot to mint
    /// @return _lootItem the minted loot item
    function mintLoot(
        ICollection.CollectionSettings memory _container,
        ILootbox.LootboxSettings memory _lootbox,
        IToken.TokenDefinition[] memory _tokenDefinitions,
        uint8 index,
        uint256 amount
    ) external returns (IToken.TokenDefinition memory _lootItem) {

        require(index < _tokenDefinitions.length, "Loot index out of bounds");

        address multiToken = IJanusRegistry(_container.serviceRegistry).get("LootboxLib", "MultiToken");

        // mint the loot item to the minter
        // TODO convert to use minting manager - not token directly
        IERC1155Mint(multiToken).mint(msg.sender, _tokenDefinitions[index].id, amount);

        // emit a message about it
        emit LootMinted(msg.sender, _container.id, _lootbox, _tokenDefinitions[index]);

        // return the loot item we minted
        return _tokenDefinitions[index];

    }

    /// @notice generate some loot given a random dice roll
    /// @param _loot the list of all possible loot items to award from
    /// @param dice the random dice roll
    /// @param _probabilitiesSum the sum of all the loot item probabilities
    function _generateLoot(
        IToken.TokenDefinition[] memory _loot,
        uint256 dice,
        uint256 _probabilitiesSum
    ) internal pure returns (uint8 winnerIndex, uint256 winnerRoll) {

        // validate the dice roll is in the proper range
        require(dice < _probabilitiesSum, "Dice roll must be less than total probability");
        uint256 floor = 0;
        // get all the loot there is to award

        // iterate through the loot items
        for (uint256 i = 0; i < _loot.length; i++) {

            // if the dice roll is between the floor and the probability index
            // then this is the item we will award
            if (floor <= dice && dice < _loot[i].probabilityIndex) {
                winnerIndex = uint8(i);
                winnerRoll = dice;
                break;
            }
            // increment the floor to the next probability index
            floor = _loot[i].probabilityIndex;

        }
        return (winnerIndex, winnerRoll);

    }

    /// @notice recalculate the probabilities for all the loot items.
    /// @param _allLoot list of loot to mint from
    /// @return _allLootOut the list of all possible loot items to award from
    function recalculateProbabilities(
        uint256,
        ILootbox.LootboxSettings memory settings,
        IToken.TokenDefinition[] memory _allLoot
    ) public returns (IToken.TokenDefinition[] memory _allLootOut) {

        uint256 floor = 0;
        // iterate through the loot items
        for (uint256 i = 0; i < _allLoot.length; i++) {

            // set the probability index to the floor
            _allLoot[i].probabilityIndex = floor + _allLoot[i].probability;
            floor += _allLoot[i].probability;
            // TODO likely security issues here that need fixing
            ILootbox(settings.contractAddress).setLoot(i, _allLoot[i]);

        }
        _allLootOut = _allLoot;

    }
}
