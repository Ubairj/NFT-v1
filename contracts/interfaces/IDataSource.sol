// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title IStringDataSource a generic string data source
 */
interface IStringDataSource {

    /// @notice Get the string value
    /// @param key the key to get
    /// @return string value
    function getStr(uint256 key) external view returns (string memory);

    /// @notice Set the string value
    /// @param key the key to set
    /// @param value the value to set
    function setStr(uint256 key, string memory value)
        external
        returns (string memory);

    /// @notice emitted when value is set
    event StringDataSourceSet(string key, string value);
}

/**
 * @title IUintDataSource a generic uint data source
 */
interface IUintDataSource {

    /// @notice Get the uint value
    /// @param key the key to get
    /// @return uint value
    function getInt(uint256 key) external view returns (uint256);

    /// @notice Set the uint value
    /// @param key the key to set
    /// @param value the value to set
    function setInt(uint256 key, uint256 value) external;

    /// @notice emitted when value is set
    event IntDataSourceSet(string key, string value);
}

/**
 * @title IAddressDataSource a generic address data source
 */
interface IAddressDataSource {

    /// @notice Get the address value
    /// @param key the key to get
    /// @return address value
    function getAddress(uint256 key) external view returns (address);

    /// @notice Set the address value
    /// @param key the key to set
    /// @param value the value to set
    function setAddress(uint256 key, address value) external;

    /// @notice emitted when value is set
    event AddressDataSourceSet(string key, string value);
}

/**
 * @title IBytesDataSource a generic bytes data source
 */
interface IBytesDataSource {

    /// @notice Get the bytes value
    /// @param key the key to get
    /// @return bytes value
    function getBytes(uint256 key) external view returns (bytes memory);

    /// @notice Set the bytes value
    /// @param key the key to set
    /// @param value the value to set
    function setBytes(uint256 key, bytes memory value) external;

    /// @notice emitted when value is set
    event BytesDataSourceSet(string key, string value);
}


/**
 * @title IBoolDataSource a generic bool data source
 */
interface IBoolDataSource {

    /// @notice Get the bool value
    /// @param key the key to get
    /// @return bool value
    function getBool(uint256 key) external view returns (bool);

    /// @notice Set the bool value
    /// @param key the key to set
    /// @param value the value to set
    function setBool(uint256 key, bool value) external;

    /// @notice emitted when value is set
    event BoolDataSourceSet(string key, string value);
}
