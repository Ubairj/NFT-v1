// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../utils/UInt256Set.sol";
import "../token/TokenSet.sol";

import "../interfaces/IRequirement.sol";
import "../interfaces/IToken.sol";
import "../interfaces/ICollection.sol";
import "../interfaces/IERC1155.sol";
import "../interfaces/IERC1155Owned.sol";



/// @notice a set of requirements that must be met for an action to occur
library RequirementLib {

    /// @notice event generated when requirements are taken into custody
    event RequirementCustodyAssumed(
        address indexed manager,
        address indexed from,
        uint256 indexed transferId,
        IRequirement.Requirement[] requirements,
        IToken.Token[] relesedTokens
    );

    /// @notice event generated when requirements are released from custody
    event RequirementCustodyReleased(
        address indexed manager,
        address indexed to,
        uint256 indexed transferId,
        IToken.Token[] relesedTokens
    );

    using TokenSet for IToken.TokenSet;
    using UInt256Set for UInt256Set.Set;

    /// @notice returns whether the specified account meets the requirements at the specified quantity factor
    /// @param account the minter to check
    /// @param reqs the requirement list to check
    /// @param quantity the quantity factor to check
    /// @return _meetsRequirements whether the account meets the requirements
    function meetsRequirements(
        IRequirement.RequirementData storage self,
        address account,
        IRequirement.Requirement[] memory reqs,
        uint256 quantity) external view returns (bool _meetsRequirements) {
        // check if the account meets the requirements
        for (
            uint256 _inputIndex = 0;
            _inputIndex < reqs.length;
            _inputIndex += 1
        ) {
            IToken.Token[] memory _fulfillingTokens = _getFulfillingTokens(
                self,
                account,
                reqs[_inputIndex],
                quantity
            );
            if(_fulfillingTokens.length == 0) {
                return false;
            }
        }
        return true;
    }

    /// @notice returns whether the specified account meets the requirement at the specified quantity factor
    /// @param account the minter to check
    /// @param req the requirement list to check
    /// @param quantity the quantity factor to check
    /// @return _meetsRequirements whether the account meets the requirements
    function meetsRequirement(
        IRequirement.RequirementData storage self,
        address account,
        IRequirement.Requirement memory req,
        uint256 quantity) external view returns (bool _meetsRequirements) {
        IToken.Token[] memory _fulfillingTokens = _getFulfillingTokens(
            self,
            account,
            req,
            quantity);
        return _fulfillingTokens.length > 0;
    }

    /// @notice returns whether the specified account meets the requirement at the specified quantity factor
    /// @param self the minter to check
    /// @param account the minter to check
    /// @param req the requirement list to check
    /// @param quantity the quantity factor to check
    /// @return _tokens whether the account meets the requirements
    function fulfillingTokens(
        IRequirement.RequirementData storage self,
        address account,
        IRequirement.Requirement memory req,
        uint256 quantity) external view returns (IToken.Token[] memory _tokens) {

        // get the fulfilling tokens
        _tokens = _getFulfillingTokens(
            self,
            account,
            req,
            quantity);

    }

    /// @notice returns a list of tokens that fulfill the specified requirement list or an empty list if none do
    /// @param account the account to check
    /// @param req the requirement list to check
    /// @param quantity the quantity factor to check
    /// @return _fulfillingTokens the fulfilling tokens for this requirement
    function _getFulfillingTokens(
        IRequirement.RequirementData storage self,
        address account,
        IRequirement.Requirement memory req,
        uint256 quantity) internal view returns (IToken.Token[] memory _fulfillingTokens) {

        // compute the required quantity using the requirement quantity * the quantity factor
        int256 required = int256(req.quantity * quantity);

        // get the token source of the requirement
        IToken.TokenSource memory source = req.source;

        // if the source is a token collection
        if (source._type == IToken.TokenSourceType.Collection) {

            // get all owned token hashes of the given account address
            uint256[] memory hashes = IERC1155Owned(self.token).owned(account);

            _fulfillingTokens = new IToken.Token[](hashes.length);
            uint256 insertedCount = 0;

            // iterate through all token hashes and check if the requirement is met
            for (
                uint256 _hashIndex = 0;
                _hashIndex < hashes.length;
                _hashIndex += 1
            ) {

                // get the token hash
                uint256 hashAt = hashes[_hashIndex];

                // get the token collection address from the token source
                address collection = source.collectionSourceAddress;
                // get the balance of the token for the given account
                uint256 balance = IERC1155(self.token).balanceOf(account, hashAt);
                // check to see if the token hash is a member of the given collection
                bool isCollectionMember = ICollection(collection).isMemberOf(hashAt);

                // if the token is a member of the collection and the balance is greater than or equal to the required quantity
                if (balance > uint256(required)) {
                    balance = uint256(required);
                }
                // if no balance or not collection member then continue
                if (balance == 0 || !isCollectionMember) continue;

                // decrememnt required balance for colection member
                required = required - int256(balance);

                // add the fulfilling token and its amount to the token list
                _fulfillingTokens[insertedCount++] =
                    IToken.Token(
                        hashAt,
                        balance,
                        req.burn
                    );

                // if we met requirements and exact amount not required we are done
                if (required == 0 && req.requireExactAmount == false) {
                    break;
                }

                // if we have not met exact requirements then revert transaction
                if (required < 0) {
                   break;
                }

            }

            // if requirements are met then return the list of fulfilling tokens
            if(required > 0) {
                delete _fulfillingTokens;
            }

        } else {
            // else its a static token id - get balance of the token
            uint256 tokenBal = IERC1155(self.token).balanceOf(account, source.staticSourceId);
            bool _meetsRequirement = tokenBal >= uint256(required); // flag to indicate if the requirement is met
            bool _hasExactAmount = tokenBal == uint256(required); // flag to indicate if the requirement has exact amount

            // if we require exact amount and the token balance is not equal to the required amount
            // then return from the function without adding the token to the list
            if(req.requireExactAmount == true && !_hasExactAmount) {}
            else {
                // if the requirement is met then add the token to the list
                if(_meetsRequirement) {
                    _fulfillingTokens = new IToken.Token[](1);
                    _fulfillingTokens[0] = IToken.Token(
                        source.staticSourceId,
                        tokenBal,
                        req.burn
                    );
                }
            }
        }

    }


    /// @notice transfer the specified requirements from the from address to the manager address using the quantity factor
    /// @param self requirements data from contract
    /// @param from the address to transfer from
    /// @param reqs the requirement list to transfer
    /// @param quantity the factor to multiply the quantity by
    function takeCustody(
        IRequirement.RequirementData storage self,
        uint256 transferId,
        address from,
        IRequirement.Requirement[] memory reqs,
        uint256 quantity) external returns(IToken.Token[] memory _transferredTokens) {

        // iterate through all requirements
        for (
            uint256 _inputIndex = 0;
            _inputIndex < reqs.length;
            _inputIndex += 1) {

            // get the requirement
            IRequirement.Requirement memory req = reqs[_inputIndex];

            // get a list of fulfilling tokens for the requirement from the user
            IToken.Token[] memory _fulfillingTokens = _getFulfillingTokens(
                self,
                from,
                req,
                quantity
            );

            // require that fulfilling tokens are found for the requirement
            require(_fulfillingTokens.length > 0, "No fulfilling tokens found");

            // skip the requrement if item is not taken into custody
            if(!req.takeCustody) { continue; }

            // add all fulfilling tokens to the list of transferred tokens
            for (
                uint256 _fulfillingTokenIndex = 0;
                _fulfillingTokenIndex < _fulfillingTokens.length;
                _fulfillingTokenIndex += 1) {
                self.tokens[transferId].insert(_fulfillingTokens[_fulfillingTokenIndex]);
            }

        }

        uint256 fulfilTokenLen = self.tokens[transferId].valueList.length;

        // build the token and quantity lists for the requirement
        uint256[] memory tokenIdList = new uint256[](fulfilTokenLen);
        uint256[] memory tokenQtyList = new uint256[](fulfilTokenLen);

        // gather all tokens that fulfill the requirement and their quantity
        // and transfer all of them to the manager address for custody
        for (
            uint256 _fulfillingTokenIndex = 0;
            _fulfillingTokenIndex < fulfilTokenLen;
            _fulfillingTokenIndex += 1) {
            IToken.Token memory tok = self.tokens[transferId].valueList[_fulfillingTokenIndex];
            tokenIdList[_fulfillingTokenIndex] = tok.id;
            tokenQtyList[_fulfillingTokenIndex] = tok.balance;
        }

        // set the result for the function
        _transferredTokens = self.tokens[transferId].valueList;

        // transfer the token balance to the to address
        IERC1155(self.token).safeBatchTransferFrom(
            from,
            self.manager,
            tokenIdList,
            tokenQtyList,
            ""
        );

    }

    /// @notice release custody of the specified requirements from the manager address to the to address
    function releaseCustody(
        IRequirement.RequirementData storage self,
        uint256 transferId,
        address to) public {

        // get a count of tokens to releast
        uint256 tokensCount = self.tokens[transferId].valueList.length;

        // make sure there are tokens to release from this transfer
        require(tokensCount > 0, "No tokens to release");

        // build the token and quantity lists for the requirement
        uint256[] memory tokenIdList = new uint256[](tokensCount);
        uint256[] memory tokenQtyList = new uint256[](tokensCount);

        // gather all tokens that fulfill the requirement and their quantity
        // and transfer all of them from the manager address to the to address
        uint256 keepOffset = 0;
        for (
            uint256 _fulfillingTokenIndex = 0;
            _fulfillingTokenIndex < tokensCount;
            _fulfillingTokenIndex += 1) {

            // get the token
            IToken.Token memory tok = self.tokens[transferId].valueList[_fulfillingTokenIndex];

            // if we are to burn this token then skip adding the token to the list
            if(tok.burn) {
                // instead we add that token to the list of tokens id that have been burned
                if(!self.burnedTokenIds.exists(tok.id)) {
                    self.burnedTokenIds.insert(tok.id);
                }
                // and increment the burned balance for that token id
                self.burnedTokenQuantities[tok.id] += tok.balance;
                // and increase the keep offset so we know when to stop adding tokens to the list
                keepOffset += 1;
                continue;
            }

            // set the token id and quantity
            tokenIdList[_fulfillingTokenIndex - keepOffset] = tok.id;
            tokenQtyList[_fulfillingTokenIndex - keepOffset] = tok.balance;
        }

        // transfer the token balances to the to address
        IERC1155(self.token).safeBatchTransferFrom(
            self.manager,
            to,
            tokenIdList,
            tokenQtyList,
            ""
        );

        // emit an event indicating the custody release occurred
        emit RequirementCustodyReleased(
            self.manager,
            to,
            transferId,
            self.tokens[transferId].valueList
        );

        // delete the token set from storage
        delete self.tokens[transferId];

    }


    // /**
    //  * @dev add an input requirement for this token
    //  */
    // function addInputRequirement(
    //     ComplexPoolData storage self,
    //     address token,
    //     address pool,
    //     INFTComplexGemPool.RequirementType inputType,
    //     uint256 tokenId,
    //     uint256 minAmount,
    //     bool takeCustody,
    //     bool burn,
    //     bool exactAmount
    // ) public {
    //     require(token != address(0), "INVALID_TOKEN");
    //     require(
    //         inputType == INFTComplexGemPool.RequirementType.ERC20 ||
    //             inputType == INFTComplexGemPool.RequirementType.ERC1155 ||
    //             inputType == INFTComplexGemPool.RequirementType.POOL,
    //         "INVALID_INPUTTYPE"
    //     );
    //     require(
    //         (inputType == INFTComplexGemPool.RequirementType.POOL &&
    //             pool != address(0)) ||
    //             inputType != INFTComplexGemPool.RequirementType.POOL,
    //         "INVALID_POOL"
    //     );
    //     require(
    //         (inputType == INFTComplexGemPool.RequirementType.ERC20 &&
    //             tokenId == 0) ||
    //             inputType == INFTComplexGemPool.RequirementType.ERC1155 ||
    //             (inputType == INFTComplexGemPool.RequirementType.POOL &&
    //                 tokenId == 0),
    //         "INVALID_TOKENID"
    //     );
    //     require(minAmount != 0, "ZERO_AMOUNT");
    //     require(!(!takeCustody && burn), "INVALID_TOKENSTATE");
    //     self.inputRequirements.push(
    //         INFTComplexGemPoolData.InputRequirement(
    //             token,
    //             pool,
    //             inputType,
    //             tokenId,
    //             minAmount,
    //             takeCustody,
    //             burn,
    //             exactAmount
    //         )
    //     );
    // }

    // /**
    //  * @dev update input requirement at index
    //  */
    // function updateInputRequirement(
    //     ComplexPoolData storage self,
    //     uint256 _index,
    //     address _tokenAddress,
    //     address _poolAddress,
    //     INFTComplexGemPool.RequirementType _inputRequirementType,
    //     uint256 _tokenId,
    //     uint256 _minAmount,
    //     bool _takeCustody,
    //     bool _burn,
    //     bool _exactAmount
    // ) public {
    //     require(_index < self.inputRequirements.length, "OUT_OF_RANGE");
    //     require(_tokenAddress != address(0), "INVALID_TOKEN");
    //     require(
    //         _inputRequirementType == INFTComplexGemPool.RequirementType.ERC20 ||
    //             _inputRequirementType ==
    //             INFTComplexGemPool.RequirementType.ERC1155 ||
    //             _inputRequirementType ==
    //             INFTComplexGemPool.RequirementType.POOL,
    //         "INVALID_INPUTTYPE"
    //     );
    //     require(
    //         (_inputRequirementType == INFTComplexGemPool.RequirementType.POOL &&
    //             _poolAddress != address(0)) ||
    //             _inputRequirementType !=
    //             INFTComplexGemPool.RequirementType.POOL,
    //         "INVALID_POOL"
    //     );
    //     require(
    //         (_inputRequirementType ==
    //             INFTComplexGemPool.RequirementType.ERC20 &&
    //             _tokenId == 0) ||
    //             _inputRequirementType ==
    //             INFTComplexGemPool.RequirementType.ERC1155 ||
    //             (_inputRequirementType ==
    //                 INFTComplexGemPool.RequirementType.POOL &&
    //                 _tokenId == 0),
    //         "INVALID_TOKENID"
    //     );
    //     require(_minAmount != 0, "ZERO_AMOUNT");
    //     require(!(!_takeCustody && _burn), "INVALID_TOKENSTATE");
    //     self.inputRequirements[_index] = INFTComplexGemPoolData
    //     .InputRequirement(
    //         _tokenAddress,
    //         _poolAddress,
    //         _inputRequirementType,
    //         _tokenId,
    //         _minAmount,
    //         _takeCustody,
    //         _burn,
    //         _exactAmount
    //     );
    // }

}
