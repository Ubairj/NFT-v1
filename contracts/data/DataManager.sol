// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IMeteredService.sol";
import "../interfaces/IDataManager.sol";
import "../interfaces/IMintingRegistry.sol";

import "./DataSource.sol";

import "../service/Service.sol";

// TODO: implement this

contract DataManager is

    IDataManager,
    StringDataSource,
    UintDataSource,
    AddressDataSource,
    BytesDataSource,
    BoolDataSource,
    Service,
    Initializable {

    modifier onlyAllowed(uint256 tokenHash) {
        address mintingRegistry = IJanusRegistry(_serviceRegistry).get("DataManager", "MintingRegsitry");
        address minter = IMintingRegistry(mintingRegistry).minter(tokenHash);
        require(msg.sender == minter);
        _;
    }

    function initialize(address registry) public initializer {

        _setRegistry(registry);

    }

    function _createKey(string memory keyType, string memory keyName, uint256 keyValue) internal pure returns(uint256 _hash) {
        _hash = uint256(
            keccak256(abi.encodePacked(
                keyType,
                keyName,
                keyValue
            ))
        );
    }

    function createKey(string memory keyType, string memory keyName, uint256 keyValue) public pure returns(uint256 _hash) {
        return _createKey(keyType, keyName, keyValue);
    }

    // TODO: the base datasource meethods are overridden to add metering

    /// @notice Set the string value
    function setStr(uint256, string memory)
    external
    virtual
    override
    returns (string memory) {
        require(false, "setStr is not implemented");
    }

    /// @notice Set the uint value
    function setInt(uint256, uint256)
    external
    virtual
    override {
        require(false, "setInt is not implemented");
    }

    /// @notice Set the address value
    function setAddress(uint256, address)
    external
    virtual
    override {
        require(false, "setAddress is not implemented");
    }

    /// @notice Set the bytes value
    function setBytes(uint256, bytes memory)
    external
    virtual
    override {
        require(false, "setBytes is not implemented");
    }

    /// @notice Set the boot value
    function setBool(uint256, bool)
    external
    virtual
    override {
        require(false, "setBool is not implemented");
    }

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getStringData(
        uint256 tokenHash,
        string memory _key
    ) external virtual view override returns (string memory _data) {
        uint256 keyHash = _createKey("string", _key, tokenHash);
        _data = _getStr(keyHash);
    }

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getAddressData(
        uint256 tokenHash,
        string memory _key
    ) external virtual view override returns (address _data) {
        uint256 keyHash = _createKey("address", _key, tokenHash);
        _data = _getAddress(keyHash);
    }

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getUInt256Data(
        uint256 tokenHash,
        string memory _key
    ) external virtual view override returns (uint256 _data) {
        uint256 keyHash = _createKey("uint256", _key, tokenHash);
        _data = _getInt(keyHash);
    }

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getBytesData(
        uint256 tokenHash,
        string memory _key
    ) external virtual view override returns (bytes memory _data) {
        uint256 keyHash = _createKey("bytes", _key, tokenHash);
        _data = _getBytes(keyHash);
    }

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getBoolData(
        uint256 tokenHash,
        string memory _key
    ) external virtual view override returns (bool _data) {
        uint256 keyHash = _createKey("bool", _key, tokenHash);
        _data = _getBool(keyHash);
    }

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setStringData(
        uint256 tokenHash,
        string memory _key,
        string memory _value
    ) external virtual payable override {
        uint256 keyHash = _createKey("string", _key, tokenHash);
        _setStr(keyHash, _value);
        emit TokenStringDataUpdated(tokenHash, _key, _value);
    }

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setAddressData(
        uint256 tokenHash,
        string memory _key,
        address _value
    ) external virtual payable override {
        uint256 keyHash = _createKey("address", _key, tokenHash);
        _setAddress(keyHash, _value);
        emit TokenAddressDataUpdated(tokenHash, _key, _value);
    }

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setUInt256Data(
        uint256 tokenHash,
        string memory _key,
        uint256 _value
    ) external virtual payable override {
        uint256 keyHash = _createKey("uint256", _key, tokenHash);
        _setInt(keyHash, _value);
        emit TokenUInt256DataUpdated(tokenHash, _key, _value);
    }

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setBytesData(
        uint256 tokenHash,
        string memory _key,
        bytes memory _value
    ) external virtual payable override {
        uint256 keyHash = _createKey("bytes", _key, tokenHash);
        _setBytes(keyHash, _value);
        emit TokenBytesDataUpdated(tokenHash, _key, _value);
    }

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setBoolData(
        uint256 tokenHash,
        string memory _key,
        bool _value
    ) external virtual payable override {
        uint256 keyHash = _createKey("bool", _key, tokenHash);
        _setBool(keyHash, _value);
        emit TokenBoolDataUpdated(tokenHash, _key, _value);
    }

    function setData(TokenData[] memory) external virtual {
        require(false, "setData is not implemented");
    }

}
