// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./Factory.sol";
import "../lootbox/Lootbox.sol";
import "../service/Service.sol";

import "../interfaces/ILootbox.sol";
import "../interfaces/ITokenDefinitions.sol";

/// @notice the manager of fees
contract LootboxFactory is Factory, Service, Initializable {

    mapping(uint256 => address) internal _isDeployed;

    // set the bytecode for the factory
    constructor() {

        _bytecode = type(Lootbox).creationCode;

    }

    function initialize(address registry) public initializer {

        _setRegistry(registry);

    }

    /// @notice creates a new contract instance
    /// @param _container the owner of the new contract
    /// @param _lootbox the owner of the new contract
    /// @param tdInit the owner of the new contract
    /// @return instanceOut the address of the new contract
    function createLootbox(
        ICollection.CollectionSettings memory _container,
        ILootbox.LootboxSettings memory _lootbox,
        ITokenDefinitions.TokenDefinitionsSettings memory tdInit)
    external
    returns (Instance memory instanceOut) {

        uint256 _hash = lootboxHash(_container.symbol);

        require(_isDeployed[_hash] == address(0), "collection already deployed");

        _container.serviceRegistry = address(_serviceRegistry);
        instanceOut = Factory(this).create(
            msg.sender, _hash
        );
        _isDeployed[_hash] = instanceOut.contractAddress;

        // initialize the lootbox
        Lootbox lootboxInstance = Lootbox(instanceOut.contractAddress);
        lootboxInstance.initialize(_lootbox, tdInit, _container);

    }

    /// @notice create a hash given owner and collection name
    function lootboxHash(string memory symbol) public pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked("LootboxFactory", symbol)));

    }

    /// @notice get the collection address given hash or zero if not deployed
    function lootboxByHash(uint256 tcHash) public view returns (address) {

        return _isDeployed[tcHash];

    }

}
