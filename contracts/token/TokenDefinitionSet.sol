// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/ITokenDefinitions.sol";
import "../interfaces/IToken.sol";

/// @notice a set of requirements that must be met for an action to occur
library TokenDefinitionSetLib {

    /// @notice create a unique key for the requirement
    /// @param req the requirement to create a key for
    /// @return _hash the key for the requirement
    function createKey(ITokenDefinitions.TokenDefinitionSet storage, IToken.TokenDefinition memory req) public pure returns(uint256 _hash) {
        _hash = uint256(
            keccak256(abi.encodePacked(
                req.symbol,
                req.name,
                req.collectionId,
                req.description
            ))
        );
    }

    /**
     * @notice insert a key.
     * @dev duplicate keys are not permitted.
     * @param self storage pointer to a Set.
     * @param req value to insert.
     */
    function insert(ITokenDefinitions.TokenDefinitionSet storage self, IToken.TokenDefinition memory req) public {
        require(
            !exists(self, req),
            "TokenDefinitionSetLib: key already exists in the set."
        );
        uint256 keyHash = createKey(self, req);
        self.keyList.push(keyHash);
        self.valueList.push(req);
        self.keyPointers[keyHash] = self.keyList.length - 1;
    }

    /**
     * @notice remove a key.
     * @dev key to remove must exist.
     * @param self storage pointer to a Set.
     * @param key value to remove.
     */
    function remove(ITokenDefinitions.TokenDefinitionSet storage self, IToken.TokenDefinition memory key) public {
        require(
            exists(self, key),
            "TokenDefinitionSetLib: key does not exist in the set."
        );
        uint256 keyHash = createKey(self, key);
        uint256 last = count(self) - 1;
        uint256 rowToReplace = self.keyPointers[keyHash];
        if (rowToReplace != last) {
            uint256 keyToMove = self.keyList[last];
            IToken.TokenDefinition memory valueToMove = self.valueList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
            self.valueList[rowToReplace] = valueToMove;
        }
        delete self.keyPointers[keyHash];
        self.keyList.pop();
        self.valueList.pop();
    }

    /**
     * @notice remove a key.
     * @dev key to remove must exist.
     * @param self storage pointer to a Set.
     * @param _index value to remove.
     */
    function removeAt(ITokenDefinitions.TokenDefinitionSet storage self, uint256 _index) public {
        require(
            _index < count(self),
            "TokenDefinitionSetLib: key does not exist in the set."
        );
        uint256 last = count(self) - 1;
        uint256 rowToReplace = _index;
        uint256 keyHash = createKey(self, self.valueList[_index]);
        if (rowToReplace != last) {
            uint256 keyToMove = self.keyList[last];
            IToken.TokenDefinition memory valueToMove = self.valueList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
            self.valueList[rowToReplace] = valueToMove;
        }
        delete self.keyPointers[keyHash];
        self.keyList.pop();
        self.valueList.pop();
    }

    /**
     * @notice count the keys.
     * @param self storage pointer to a Set.
     * @return _count a count of the requirements
     */
    function count(ITokenDefinitions.TokenDefinitionSet storage self) public view returns (uint256 _count) {
        return (self.keyList.length);
    }

    /**
     * @notice check if a key is in the Set.
     * @param self storage pointer to a Set.
     * @param key value to check.
     * @return _exists true: Set member, false: not a Set member.
     */
    function exists(ITokenDefinitions.TokenDefinitionSet storage self, IToken.TokenDefinition memory key)
        public
        view
        returns (bool _exists)
    {
        if (self.keyList.length == 0) return false;
        uint256 keyHash = createKey(self, key);
        _exists = self.keyList[self.keyPointers[keyHash]] == keyHash;
    }

    /**
     * @notice check if a key is in the Set.
     * @param self storage pointer to a Set.
     * @param keyHash value to check.
     * @return _exists bool true: Set member, false: not a Set member.
     */
    function existsKey(ITokenDefinitions.TokenDefinitionSet storage self, uint256 keyHash)
        public
        view
        returns (bool _exists)
    {
        if (self.keyList.length == 0) return false;
        _exists = self.keyList[self.keyPointers[keyHash]] == keyHash;
    }

    /**
     * @notice fetch a key by row (enumerate).
     * @param self storage pointer to a Set.
     * @param index row to enumerate. Must be < count() - 1.
     * @return _key key at the given row.
     */
    function keyAtIndex(ITokenDefinitions.TokenDefinitionSet storage self, uint256 index)
        public
        view
        returns (uint256 _key)
    {
        _key = self.keyList[index];
    }

    /**
     * @notice fetch a key by row (enumerate).
     * @param self storage pointer to a Set.
     * @param index row to enumerate. Must be < count() - 1.
     * @return _value value at the given row.
     */
    function valueAtIndex(ITokenDefinitions.TokenDefinitionSet storage self, uint256 index)
        public
        view
        returns (IToken.TokenDefinition memory _value)
    {
        _value = self.valueList[index];
    }
}
