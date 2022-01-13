// SPDX-License-Identifier: MIT`
pragma solidity >=0.8.0;

import "../interfaces/IDataSource.sol";

/// this contract provides a generic data source for other smart contracts.
/// data can be set and retrieved by the owner of the contract. The basic datattypes
/// are supported: string, bytes, uint, bool, and address. Data is set and retrieved
/// through the 'setXXX' and 'getXXX' methods. This contract exists to enable a
/// modular design pattern that enables easy upgrades of business logic without
/// changing the smart contract.
contract StringDataSource is IStringDataSource {

    mapping(uint256 => string) internal stringData;

    /// @dev set a string value
    /// @param key the key of the string value
    /// @return the value if the value was set, falsey otherwise
    function _getStr(uint256 key)
        internal view
        returns (string memory)
    {
        return stringData[key];
    }
    function getStr(uint256 key)
        external
        virtual
        view
        override
        returns (string memory)
    {
        return _getStr(key);
    }

    /// @dev set a string value
    /// @param key the key of the string value
    /// @param value the value to set
    /// @return oldData string the old data the the new data replaced
    function _setStr(uint256 key, string memory value)
        internal
        returns (string memory oldData)
    {
        oldData = stringData[key];
        stringData[key] = value;
    }
    function setStr(uint256 key, string memory value)
        external
        virtual
        override
        returns (string memory oldData)
    {
        oldData = _setStr(key, value);
    }

}

contract UintDataSource is IUintDataSource {

    mapping(uint256 => uint256) internal uintData;

    function _getInt(uint256 key)
        internal
        view
        returns (uint256 _data)
    {
        _data = uintData[key];
    }

    function _setInt(uint256 key, uint256 value)
        internal
    {
        uintData[key] = value;
    }


    function getInt(uint256 key)
        external
        virtual
        view
        override
        returns (uint256 _data)
    {
        _data = _getInt(key);
    }

    function setInt(uint256 key, uint256 value)
        external
        virtual
        override
    {
        _setInt(key, value);
    }

}

contract AddressDataSource is IAddressDataSource {

    mapping(uint256 => address) internal addressData;

    function _getAddress(uint256 key)
        internal view
        returns (address)
    {
        return addressData[key];
    }

    function _setAddress(uint256 key, address value)
        internal
    {
        addressData[key] = value;
    }

    function getAddress(uint256 key)
        external
        virtual
        view
        override
        returns (address)
    {
        return _getAddress(key);
    }

    function setAddress(uint256 key, address value)
        external
        virtual
        override
    {
        _setAddress(key, value);
    }
}


contract BytesDataSource is IBytesDataSource {

    mapping(uint256 => bytes) internal bytesData;

    function _getBytes(uint256 key)
        internal view
        returns (bytes memory)
    {
        return bytesData[key];
    }

    function _setBytes(uint256 key, bytes memory value)
        internal
    {
        bytesData[key] = value;
    }

    function getBytes(uint256 key)
        external
        virtual
        view
        override
        returns (bytes memory)
    {
        return _getBytes(key);
    }

    function setBytes(uint256 key, bytes memory value)
        external
        virtual
        override
    {
        _setBytes(key, value);
    }
}



contract BoolDataSource is IBoolDataSource {

    mapping(uint256 => bool) internal boolData;

    function _getBool(uint256 key)
        internal view
        returns (bool _data)
    {
        _data = boolData[key];
    }

    function _setBool(uint256 key, bool bval)
        internal
    {
        boolData[key] = bval;
    }

    function getBool(uint256 key)
        external
        virtual
        view
        override
        returns (bool _data)
    {
        _data = _getBool(key);
    }

    function setBool(uint256 key, bool bval)
        external
        virtual
        override
    {
        _setBool(key, bval);
    }

}
