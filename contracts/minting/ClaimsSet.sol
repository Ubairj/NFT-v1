// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/IClaim.sol";
import "../interfaces/IToken.sol";

/// @notice a set of requirements that must be met for an action to occur
library ClaimsSet {

    /// @notice create a unique key for the requirement
    /// @param self the requirement to create a key for
    /// @return _hash the key for the requirement
    function createKey(IClaim.ClaimSettings storage self) public view returns(uint256 _hash) {
        // user the pool address, a "claim" string, and the size of claims
        // to generate the new claim hash
        _hash = uint256(
            keccak256(abi.encodePacked(
                self.minter,
                "claim",
                self.data.claims.keyList.length + 1
            ))
        );
    }

    /**
     * @notice insert a kclaim into our list.
     * @dev duplicate keys are not permitted.
     * @param self storage pointer to a Set.
     * @param req value to insert.
     */
    function insert(IClaim.ClaimSettings storage self, IClaim.Claim memory req) public {
        require(
            !exists(self, req),
            "ClaimSet: key already exists in the set."
        );
        req.id = createKey(self);
        self.data.claims.keyList.push(req.id);
        self.data.claims.valueList.push(req);
        self.data.claims.keyPointers[req.id] = self.data.claims.keyList.length - 1;
    }

    /**
     * @notice remove a key.
     * @dev key to remove must exist.
     * @param self storage pointer to a Set.
     * @param key value to remove.
     */
    function remove(IClaim.ClaimSettings storage self, IClaim.Claim memory key) public {
        require(
            exists(self, key),
            "ClaimSet: key does not exist in the set."
        );
        uint256 keyHash = createKey(self);
        uint256 last = count(self) - 1;
        uint256 rowToReplace = self.data.claims.keyPointers[keyHash];
        if (rowToReplace != last) {
            uint256 keyToMove = self.data.claims.keyList[last];
            IClaim.Claim memory valueToMove = self.data.claims.valueList[last];
            self.data.claims.keyPointers[keyToMove] = rowToReplace;
            self.data.claims.keyList[rowToReplace] = keyToMove;
            self.data.claims.valueList[rowToReplace] = valueToMove;
        }
        delete self.data.claims.keyPointers[keyHash];
        self.data.claims.keyList.pop();
        self.data.claims.valueList.pop();
    }

    /**
     * @notice remove a key.
     * @dev key to remove must exist.
     * @param self storage pointer to a Set.
     * @param _index value to remove.
     */
    function removeAt(IClaim.ClaimSettings storage self, uint256 _index) public {
        require(
            _index < count(self),
            "ClaimSet: key does not exist in the set."
        );
        uint256 last = count(self) - 1;
        uint256 rowToReplace = _index;
        uint256 keyHash = createKey(self);
        if (rowToReplace != last) {
            uint256 keyToMove = self.data.claims.keyList[last];
            IClaim.Claim memory valueToMove = self.data.claims.valueList[last];
            self.data.claims.keyPointers[keyToMove] = rowToReplace;
            self.data.claims.keyList[rowToReplace] = keyToMove;
            self.data.claims.valueList[rowToReplace] = valueToMove;
        }
        delete self.data.claims.keyPointers[keyHash];
        self.data.claims.keyList.pop();
        self.data.claims.valueList.pop();
    }

    /**
     * @notice count the keys.
     * @param self storage pointer to a Set.
     * @return _count a count of the requirements
     */
    function count(IClaim.ClaimSettings storage self) public view returns (uint256 _count) {
        return (self.data.claims.keyList.length);
    }

    /**
     * @notice check if a key is in the Set.
     * @param self storage pointer to a Set.
     * @param key value to check.
     * @return _exists true: Set member, false: not a Set member.
     */
    function exists(IClaim.ClaimSettings storage self, IClaim.Claim memory key)
        public
        view
        returns (bool _exists)
    {
        if (self.data.claims.keyList.length == 0) return false;
        _exists = self.data.claims.keyList[self.data.claims.keyPointers[key.id]] == key.id;
    }

    /**
     * @notice check if a key is in the Set.
     * @param self storage pointer to a Set.
     * @param keyHash value to check.
     * @return _exists bool true: Set member, false: not a Set member.
     */
    function existsKey(IClaim.ClaimSettings storage self, uint256 keyHash)
        public
        view
        returns (bool _exists)
    {
        if (self.data.claims.keyList.length == 0) return false;
        _exists = self.data.claims.keyList[self.data.claims.keyPointers[keyHash]] == keyHash;
    }

    /**
     * @notice fetch a key by row (enumerate).
     * @param self storage pointer to a Set.
     * @param index row to enumerate. Must be < count() - 1.
     * @return _key key at the given row.
     */
    function keyAtIndex(IClaim.ClaimSettings storage self, uint256 index)
        public
        view
        returns (uint256 _key)
    {
        _key = self.data.claims.keyList[index];
    }

    /**
     * @notice fetch a key by row (enumerate).
     * @param self storage pointer to a Set.
     * @param index row to enumerate. Must be < count() - 1.
     * @return _value value at the given row.
     */
    function valueAtIndex(IClaim.ClaimSettings storage self, uint256 index)
        public
        view
        returns (IClaim.Claim memory _value)
    {
        _value = self.data.claims.valueList[self.data.claims.keyPointers[index]];
    }

    /**
     * @notice fetch a key by row (enumerate).
     * @param self storage pointer to a Set.
     * @param key key to get value for
     * @return _value value at the given row.
     */
    function value(IClaim.ClaimSettings storage self, uint256 key)
        public
        view
        returns (IClaim.Claim memory _value)
    {
        _value = self.data.claims.valueList[key];
    }
}
