//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../service/Service.sol";

import "../utils/AddressSet.sol";
import "../utils/UInt256Set.sol";

import "../interfaces/IMintingRegistry.sol";
import "../interfaces/IJanusRegistry.sol";

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @notice a bank. allows deposits of any token and tracks balance by depositor and only allows withdraw from depositor or assigned agent, disallows negative balances.
contract MintingRegistry is IMintingRegistry, Initializable, Service {
    using AddressSet for AddressSet.Set;
    using UInt256Set for UInt256Set.Set;

    mapping(address => UInt256Set.Set) internal _tokensByMinter;
    mapping(uint256 => UInt256Set.Set) internal _tokensByCollection;

    mapping(uint256 => address) internal _tokenMinters;
    mapping(uint256 => uint256) internal _tokenCollections;
    mapping(uint256 => address) internal _collectionMinters;

    AddressSet.Set internal _minters;
    UInt256Set.Set internal _collections;
    UInt256Set.Set internal _tokens;

    /// @notice only the minting manager shall pass
    modifier onlyMintingManager() {

        address _mintingManager = IJanusRegistry(_serviceRegistry).get("MintingRegistry", "MintingManager");
        require(_mintingManager == msg.sender, "Only the minting manager can call this function.");
        _;

    }

    /// @notice init the contract
    /// @param serviceRegistry address of the account
    function initialize(address serviceRegistry) public initializer {

        _setRegistry(serviceRegistry);

    }

    /// @notice register a mint
    /// @param minterIn address of the account
    /// @param collectionId address of the account
    /// @param id address of the account
    function register(
        address minterIn,
        uint256 collectionId,
        uint256 id
    ) external override onlyMintingManager {

        require(!_tokens.exists(id), "Token already registered.");

        _tokensByMinter[minterIn].insert(id);
        _tokensByCollection[collectionId].insert(id);
        _tokenMinters[id] = minterIn;
        _tokenCollections[id] = collectionId;
        _collectionMinters[collectionId] = minterIn;

        if(!_minters.exists(minterIn)) _minters.insert(minterIn);
        if (!_collections.exists(collectionId)) _collections.insert(collectionId);

        _tokens.insert(id);

        emit MintRegistered(minterIn, collectionId, id);

    }

    /// @notice get the minter for the given token
    /// @param id the id of the token
    /// @return _minter whether the account is the minter
    function minter(uint256 id) external view virtual override returns (address _minter) {

        _minter = _tokenMinters[id];

    }

    /// @notice return the collection id of the token
    /// @param id uint256 of the token index
    /// @return collectionId the collection id
    function collection(uint256 id) external view virtual override returns (uint256 collectionId) {

        collectionId = _tokenCollections[id];

    }

    /// @notice get all the members of a collection
    /// @param collectionIn uint256 of the collection
    /// @return minterOut all the collection members
    function collectionMinter(uint256 collectionIn) external view virtual override returns (address minterOut) {

        minterOut = _collectionMinters[collectionIn];

    }

    /// @notice get minted tokens by account
    /// @param minterIn uint256 of the token index
    /// @return _mintedOut whether the account is the minter
    function minted(address minterIn) external view virtual override returns (uint256[] memory _mintedOut) {

        _mintedOut = _tokensByMinter[minterIn].keyList;

    }

    /// @notice get all the members of a collection
    /// @param collectionIn uint256 of the collection
    /// @return _membersOut all the collection members
    function members(uint256 collectionIn) external view virtual override returns (uint256[] memory _membersOut) {

        _membersOut = _tokensByCollection[collectionIn].keyList;

    }

    /// @notice get all minters
    /// @return _mintersOut the minthers
    function minters() external view virtual override returns (address[] memory _mintersOut) {

        _mintersOut = _minters.keyList;

    }

    /// @notice get all collections
    /// @return _collectionsOut the collectiond
    function collections() external view virtual override returns (uint256[] memory _collectionsOut) {

        _collectionsOut = _collections.keyList;

    }

    /// @notice get all tokens
    /// @return _tokensOut the minthers
    function tokens() external view virtual override returns (uint256[] memory _tokensOut) {

        _tokensOut = _tokens.keyList;

    }
}
