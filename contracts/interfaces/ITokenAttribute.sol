// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice defines an interface to allow defining of token attributes - key/value pairs of onchain data associated with a token id
interface ITokenAttribute {

    // the type of attribute this is
    enum TokenAttributeType {

        StringAttribute,
        UInt256Attribute,
        BytesAttribute,
        AddressAttribute,
        BoolAttribute

    }

    /// @notice a token attribute. Attributes can be strings, bytes32, uint256, or address
    struct TokenAttribute {

        // the attribute name
        string name;
        // type of attribute - string, numeric, bytes, address, bool
        TokenAttributeType _type;
        // the string value of the attribute
        string stringValue;
        // the uint value of the attribute
        uint256 uintValue;
        // this bytes value of the attribute
        bytes32 bytesValue;
        // the address value of the attribute
        address addressValue;
        // the bool value of the attribute
        bool boolValue;
        // default string value of attribute
        string defaultStringValue;
        // default uint value of attribute
        uint256 defaultUintValue;
        // default bytes value of attribute
        bytes32 defaultBytesValue;
        // default address value of attribute
        address defaultAddressValue;
        // default bool value of attribute
        bool defaultBoolValue;

    }

    /// @notice a set of token attributes. allows for random access & enumeration of attributes
    struct AttributeSet {
        mapping(uint256 => uint256) keyPointers;
        uint256[] keyList;
        TokenAttribute[] valueList;
    }

    /// @notice emitted when an attribute is added
    event AttributeAdded(TokenAttribute attribute);
    /// @notice emitted when an attribute is removed
    event AttributeRemoved(TokenAttribute attribute);
    /// @notice emitted when an attribute is updated
    event AttributeUpdated(TokenAttribute attribute);

    /// @notice get the increased price of the token
    function all(uint256 objectHash) external view returns (TokenAttribute[] memory _attribs);

    /// @notice get the increased price of the token
    function get(uint256 objectHash, uint256 index) external view returns (TokenAttribute memory _attrib);

    /// @notice get the increased price of the token
    function set(uint256 objectHash, uint256 index, TokenAttribute memory _attrib) external;

    /// @notice get the increased price of the token
    function add(uint256 objectHash, TokenAttribute memory _attrib) external returns (uint256 _newIndex);

    /// @notice get the increased price of the token
    function remove(uint256 objectHash, uint256 index) external returns (TokenAttribute memory);

    /// @notice get the attribute acount
    function count(uint256 objectHash) external view returns (uint256);

}
