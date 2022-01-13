//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./GemPoolLib.sol";

import "../bank/Bank.sol";

import "../tokensale/TokenPrice.sol";

import "../minting/Claim.sol";

import "../interfaces/IGemPool.sol";

import "../interfaces/IEarned.sol";

import "../interfaces/ICollection.sol";

import "../interfaces/IRequirement.sol";

import "../interfaces/IFactory.sol";

import "../utils/UInt256Set.sol";

import "../access/Controllable.sol";

// TODO implement

/// @notice a pool of tokens that users can deposit into and withdraw from
contract GemPool is

ICollection,
IEarned,
IGemPool,
IFactoryElement,
Bank,
TokenPrice,
Initializable,
Controllable,
Claim {

    using UInt256Set for UInt256Set.Set;
    using GemPoolLib for GemPoolSettings;
    using GemPoolLib for GemPoolData;

    address internal _serviceOwner;

    struct GemPoolStruct{
        GemPoolSettings _gemPoolSettings;
        GemPoolData _gemPoolData;
    }

    mapping(uint256 => GemPoolStruct) internal _gemPools;
    mapping(uint256 => UInt256Set.Set) internal _recordHashes;

    UInt256Set.Set internal _allRecordHashes;

    string[] internal _symbols;

    address private _serviceRegistry;

    constructor() {
        _addController(msg.sender);
    }

    function factoryCreated(address _owner) external override {

        require(_serviceOwner == address(0), "already created");
        _serviceOwner = _owner;
        _addController(_owner);

    }

    function initialize(address serviceRegistry) public initializer {

        _serviceRegistry = serviceRegistry;

    }

    /// @notice create a gem pool
    /// @return _gemPoolId the gem pool settings
    function addGemPool(IGemPool.GemPoolSettings memory gemPoolSettings) external virtual payable onlyController returns (uint256 _gemPoolId) {

        _gemPoolId = gemPoolHash(gemPoolSettings.tokenDefinition.symbol);
        require(_gemPools[_gemPoolId]._gemPoolData.pool == 0, "collection already deployed");
        _gemPools[_gemPoolId]._gemPoolSettings.serviceRegistry = _serviceRegistry;
        _symbols.push(gemPoolSettings.tokenDefinition.symbol);
        _gemPools[_gemPoolId] = GemPoolStruct(
            gemPoolSettings,
            GemPoolData(_gemPoolId, 0, 0, 0, 0)
        );
        emit GemPoolCreated(msg.sender, address(this), _gemPoolId, gemPoolSettings);
    }


    /// @notice create a hash given owner and collection name
    function gemPoolHash(string memory symbol) public view returns (uint256 _gemPoolHash) {

        _gemPoolHash = uint256(keccak256(abi.encodePacked(address(this), symbol)));

    }

    /// @notice create a claim
    /// @return _gpsettings the claim hash
    function getGemPool(uint256 _gemPoolHash) external virtual payable  returns (GemPoolSettings memory _gpsettings) {

        require(_gemPools[_gemPoolHash]._gemPoolSettings.tokenDefinition.id == _gemPoolHash, "invalid gem pool");
        _gpsettings = _gemPools[_gemPoolHash]._gemPoolSettings;

    }

    /// @notice create a claim
    /// @return _claim the claim hash
    function createClaim(Claim memory claim) external virtual payable override returns (Claim memory _claim) {

        _claim = _createClaim(claim);
        _recordHashes[claim.poolId].insert(_claim.id);
        _allRecordHashes.insert(_claim.id);

    }

    /// @notice submit claim for collection
    /// @param claimHash the id of the claim
    function collectClaim(uint256 claimHash, bool requireMature) external virtual override {

        bool gemMinted = _collectClaim(claimHash, requireMature);
        if (gemMinted) {
            IClaim.Claim storage claim = _claimSettings.data.claims.valueList[claimHash];
            emit GemCreated(msg.sender, _claimSettings.data.claims.valueList[claimHash].poolId, claimHash, _gemPools[claimHash]._gemPoolSettings.tokenDefinition, claim.mintQuantity);
        }

    }

    /// @notice returns the token at the given index
    /// @param token the index of the token to return
    /// @return _isMember the token at the given index
    function isMemberOf(uint256 token) external virtual view override returns (bool _isMember) {

        _isMember = _allRecordHashes.exists(token);

    }

    /// @notice returns the token at the given index
    /// @param token the index of the token to return
    /// @return _isMember the token at the given index
    function isMemberOfPool(uint256 gemPoolId, uint256 token) external virtual view override returns (bool _isMember) {

        _isMember = _recordHashes[gemPoolId].exists(token);

    }

    /// @notice returns all the record hashes in the collection as an array
    /// @return _output the collection as an array
    function members() external virtual view override returns (uint256[] memory _output) {

        _output = _allRecordHashes.keyList;

    }

    /// @notice returns all the record hashes in the collection as an array
    /// @return _output the collection as an array
    function symbols() external virtual view override returns (string[] memory _output) {

        _output = _symbols;

    }

    /// @notice gives all the record hashes in the collection as an array
    /// @param gemPoolId the collection as an array
    /// @return _output the collection as an array
    function poolMembers(uint256 gemPoolId) external virtual view override returns (uint256[] memory _output) {

        _output = _recordHashes[gemPoolId].keyList;

    }

    /// @notice get the settings for the gem pool
    function settings(uint256 gemPoolId) public virtual view returns (GemPoolSettings memory, GemPoolData memory) {

        return (_gemPools[gemPoolId]._gemPoolSettings, _gemPools[gemPoolId]._gemPoolData);

    }

    /// @notice get the gem pool's current earned token
    /// @return _output the gem pool's current earned token. returns a token definiton
    function earnedToken(uint256 gemPoolId) external virtual view override returns (TokenDefinition memory  _output) {

        _output = _gemPools[gemPoolId]._gemPoolSettings.tokenDefinition;

    }

    /// @notice get the gem pool's current earned balance for the given token
    /// @return _balance the gem pool's current earned balance for the given token
    function earnedBalance(uint256, uint256 id) external virtual view override returns (uint256 _balance) {

        Claim memory claim = _claims.valueList[id];
        require(claim.id == id, "Claim not found");
        _balance = claim.mintQuantity;

    }

    /// @notice collect earnings for token / user
    /// @param id the id of the token to collect earnings for
    function collectEarnings(uint256, uint256 id) external virtual override {

        _collectClaim(id, false);

    }
}
