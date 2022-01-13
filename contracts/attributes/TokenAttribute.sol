// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../interfaces/ITokenAttribute.sol";
import "./TokenAttributeSet.sol";

/// @notice defines an interface to allow defining of token attributes - key/value pairs of onchain data associated with a token id
contract TokenAttribute is ITokenAttribute {

    using TokenAttributeSet for AttributeSet;

    mapping(uint256 => AttributeSet) internal _attributes;

    /// @notice get all the attributes given this token id
    /// @param objectHash the token hash
    /// @return _attribs the token attributes for this token id
    function all(uint256 objectHash) external virtual view override returns (TokenAttribute[] memory _attribs) {
        _attribs = _attributes[objectHash].valueList;
    }

    /// @notice get the attribute at index given this token id
    /// @param objectHash the token hash
    /// @param index the index of the attribute to get
    /// @return _attrib the attribute at index for this token id
    function get(uint256 objectHash, uint256 index) external virtual view override  returns (TokenAttribute memory _attrib) {
        _attrib = _attributes[objectHash].valueAtIndex(index);
    }

    /// @notice set the attribute at index given this token id
    /// @param objectHash the token hash
    /// @param index the index of the attribute to set
    /// @param _attrib the attribute to set at index for this token id
    function set(uint256 objectHash, uint256 index, TokenAttribute memory _attrib) external virtual override {
        _attributes[objectHash].valueList[index] = _attrib;
    }

    /// @notice add a new attribute to this token id
    /// @param objectHash the token hash
    /// @param _attrib the attribute to add to this token id
    /// @return _newIndex the index of the attribute added
    function add(uint256 objectHash, TokenAttribute memory _attrib) external virtual override returns (uint256 _newIndex) {
        _attributes[objectHash].insert(_attrib);
        _newIndex = _attributes[objectHash].count() - 1;
    }

    /// @notice remove attribute at index given this token id
    /// @param objectHash the token hash
    /// @param index the index of the attribute to remove
    /// @return _removed the attribute removed
    function remove(uint256 objectHash, uint256 index) external virtual override  returns (TokenAttribute memory _removed) {
        _removed = _attributes[objectHash].valueList[index];
        _attributes[objectHash].removeAt(index);
    }

    /// @notice get a count of attributes given this token id
    /// @param objectHash the token hash
    /// @return _count the count of attributes for this token id
    function count(uint256 objectHash) external virtual view override  returns (uint256 _count) {
        return _attributes[objectHash].count();
    }

}
