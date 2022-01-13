//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IClaim.sol";
import "./ClaimsSet.sol";
import "./ClaimLib.sol";

/// @notice interface for a collection of tokens. lists members of collection, allows for querying of collection members, and for minting and burning of tokens.
contract Claim is IClaim {


    // to work with token holder and held token lists
    using ClaimsSet for IClaim.ClaimSet;
    using ClaimLib for ClaimSettings;

    ClaimSet internal _claims;
    ClaimSettings internal _claimSettings;

    /// @notice create a claim
    /// @return _claim the claim hash
    function _createClaim(Claim memory claim) internal returns (Claim memory _claim) {

        _claimSettings.createClaims(claim);
        _claim = claim;

    }
    function createClaim(Claim memory claim) external virtual payable override returns (Claim memory _claim) {

        _claim = _createClaim(claim);

    }

    /// @notice submit claim for collection
    /// @param claimHash the id of the claim
    function _collectClaim(uint256 claimHash, bool requireMature) internal returns (bool success) {

        success = _claimSettings.collectClaim(claimHash, requireMature);

    }

    function collectClaim(uint256 claimHash, bool requireMature) external virtual override {

        _collectClaim(claimHash, requireMature);

    }

    /// @notice return the next claim hash
    /// @return _nextHash the next claim hash
    function nextClaimHash() external virtual view override returns (uint256 _nextHash) {

         _nextHash = _claimSettings.nextTokenHash();

    }

    /// @notice get all the claims
    /// @return __claims all the claims
    function claims() external virtual view override returns (Claim[] memory __claims) {

        __claims = _claimSettings.data.claims.valueList;

    }

}
