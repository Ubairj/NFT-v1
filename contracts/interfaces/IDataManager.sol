// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


/// @notice manages on-chain data, usually associated with a token. Can make a request to get the data, or a request to update the data.
interface IDataManager {

    enum TokenDataType {String, Address, Uint, Bool, Bytes32}

    struct TokenData {
        uint256 id;
        uint256 tokenHash;
        string key;
        TokenDataType tokenType;
        string stringValue;
        address addressValue;
        uint256 uintValue;
        bytes bytesValue;
        bool boolValue;
    }

    /// @notice this event is emitted when a metadata request is made
    event TokenStringDataUpdated(uint256 tokenHash, string key, string value);

    /// @notice this event is emitted when a metadata request is made
    event TokenStringDataDeleted(uint256 tokenHash, string key);

    /// @notice this event is emitted when a metadata request is made
    event TokenAddressDataUpdated(uint256 tokenHash, string key, address value);

    /// @notice this event is emitted when a metadata request is made
    event TokenAddressDataDeleted(uint256 tokenHash, string key);

    /// @notice this event is emitted when a metadata request is made
    event TokenUInt256DataUpdated(uint256 tokenHash, string key, uint256 value);

    /// @notice this event is emitted when a metadata request is made
    event TokenUInt256DataDeleted(uint256 tokenHash, string key);

    /// @notice this event is emitted when a metadata request is made
    event TokenBytesDataUpdated(uint256 tokenHash, string key, bytes value);

    /// @notice this event is emitted when a metadata request is made
    event TokenBytesDataDeleted(uint256 tokenHash, string key);

    /// @notice this event is emitted when a metadata request is made
    event TokenBoolDataUpdated(uint256 tokenHash, string key, bool value);

    /// @notice this event is emitted when a metadata request is made
    event TokenBoolDataDeleted(uint256 tokenHash, string key);


    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getStringData(
        uint256 tokenHash,
        string memory _key
    ) external view returns (string memory _data);

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getAddressData(
        uint256 tokenHash,
        string memory _key
    ) external view returns (address _data);

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getUInt256Data(
        uint256 tokenHash,
        string memory _key
    ) external view returns (uint256 _data);

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getBytesData(
        uint256 tokenHash,
        string memory _key
    ) external view returns (bytes memory _data);

    /// @notice get the data keyed by the given key for the given token id
    /// @param tokenHash the hash of the token to get metadata for
    /// @param _key the key to get metadata for
    /// @return _data data associated with the given key for the given token id
    function getBoolData(
        uint256 tokenHash,
        string memory _key
    ) external view returns (bool _data);

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setStringData(
        uint256 tokenHash,
        string memory _key,
        string memory _value
    ) external payable;

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setAddressData(
        uint256 tokenHash,
        string memory _key,
        address _value
    ) external payable;

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setUInt256Data(
        uint256 tokenHash,
        string memory _key,
        uint256 _value
    ) external payable;

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setBytesData(
        uint256 tokenHash,
        string memory _key,
        bytes memory _value
    ) external payable;

    /// @notice update token data
    /// @param tokenHash the hash of the token to update token data for
    /// @param _key the key to update token data for
    /// @param _value the value to update token data to
    function setBoolData(
        uint256 tokenHash,
        string memory _key,
        bool _value
    ) external payable;

}
