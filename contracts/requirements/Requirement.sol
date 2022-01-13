// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../interfaces/IRequirement.sol";
import "./RequirementLib.sol";

/// @notice describes a list of requirements which will be checked against when someone performs an action
contract Requirement is IRequirement {

    using RequirementLib for RequirementData;

    RequirementData internal _requirementData;

    /// @notice add an input requirement to the list
    /// @param req the input requirement to add
    function add(uint256 collectionId, Requirement memory req) external virtual override {
        _requirementData.requirements[collectionId].push(req);
    }

    /// @notice add an input requirement to the list
    /// @param index the output requirement to add
    function update(uint256 collectionId, uint256 index, Requirement memory req) external virtual override {
        _requirementData.requirements[collectionId][index] = req;
    }

    /// @notice get all the requirements in the list
    /// @return _reqs all the requirements in the list
    function all(uint256 collectionId)
    external
    virtual
    view
    override
    returns (Requirement[] memory _reqs) {
        _reqs = _requirementData.requirements[collectionId];
    }

    /// @notice get a single requirement at index
    /// @param index the index of the requirement to get
    /// @return _req the requirement at index
    function get(uint256 collectionId, uint256 index)
    external
    virtual
    view
    override
    returns (Requirement memory _req) {
        _req = _requirementData.requirements[collectionId][index];
    }

    /// @notice get the number of requirements in the list
    /// @return _count the number of requirements in the list
    function count(uint256 collectionId)
    external
    virtual
    view
    override
    returns (uint256 _count) {
        _count = _requirementData.requirements[collectionId].length;
    }

    /// @notice returns whether the specified account meets the requirements at the specified quantity factor
    /// @param account the minter to check
    /// @param reqs the requirement list to check
    /// @param quantity the quantity factor to check
    /// @return _meetsRequirements whether the account meets the requirements
    function meetsRequirements(address account, Requirement[] memory reqs, uint256 quantity) external virtual view override returns (bool _meetsRequirements) {
        return RequirementLib.meetsRequirements(
            _requirementData,
            account,
            reqs,
            quantity
        );
    }

    /// @notice returns whether the specified account meets the requirement at the specified quantity factor
    /// @param account the minter to check
    /// @param req the requirement list to check
    /// @param quantity the quantity factor to check
    /// @return _tokens whether the account meets the requirements
    function fulfillingTokens(
        address account,
        Requirement memory req,
        uint256 quantity)
        external virtual view override returns (Token[] memory _tokens) {
        return RequirementLib.fulfillingTokens(_requirementData, account, req, quantity);
    }


    /// @notice returns whether the specified account meets the requirement at the specified quantity factor
    /// @param account the minter to check
    /// @param req the requirement list to check
    /// @param quantity the quantity factor to check
    /// @return _meetsRequirements whether the account meets the requirements
    function meetsRequirement(
        address account,
        Requirement memory req,
        uint256 quantity)
        external virtual view override returns (bool _meetsRequirements) {
        return RequirementLib.meetsRequirement(_requirementData, account, req, quantity);
    }


    function takeCustody(
        uint256 transferId,
        address from,
        address token,
        Requirement[] memory reqs,
        uint256 quantity) external virtual override returns(Token[] memory _transferredTokens) {

        }

    function releaseCustody(
        uint256 transferId,
        address token,
        address to) external virtual override {


        }

}
