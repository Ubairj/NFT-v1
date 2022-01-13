//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../interfaces/IToken.sol";

import "../interfaces/IClaim.sol";

import "../interfaces/ITransfer.sol";

import "../interfaces/IGemPool.sol";

import "../interfaces/IERC1155Mint.sol";

import "../interfaces/IERC1155Burn.sol";

import "../interfaces/IBank.sol";

import "../interfaces/IDataManager.sol";

import "../interfaces/IFeeManager.sol";

import "../interfaces/IJanusRegistry.sol";

import "./ClaimsSet.sol";

// TODO implement

/// @notice a claim is a deposit of tokens with a promise of a reward when the tokens are withdrawn
library ClaimLib {

    /// @notice emitted when a token is added to the collection
    event ClaimCreated(
        address indexed user,
        address indexed minter,
        IClaim.Claim claim
    );

    /// @notice emitted when a token is removed from the collection
    event ClaimRedeemed (
        address indexed user,
        address indexed minter,
        IClaim.Claim claim
    );

    using ClaimsSet for IClaim.ClaimSet;

    /// @notice the hash of the next gem to be minted
    /// @param self the claim settings
    function nextTokenHash(IClaim.ClaimSettings storage self)
        public view returns (uint256) {
        return uint256(
            keccak256(abi.encodePacked(
                "claim",
                address(self.minter),
                self.data.claims.valueList.length)
            )
        );
    }


    /// @notice validate that the claim is valid
    /// @param claim the claim to validate
    /// @return _valid the gem pool to validate against
    function validateCreateClaim(IClaim.ClaimSettings storage, IClaim.Claim memory claim)
    internal returns(bool _valid) {
        // zero payment
        require(msg.value != 0, "Zero payment attached");
        // zero qty
        require(claim.mintQuantity != 0, "Zero quantity order");
        _valid = true;
    }


    /// @notice get a fee hash given an address
    /// @param self the claim settings
    /// @return _fee the feeamount
    function _claimFee(IClaim.ClaimSettings storage self, address) internal view returns(uint256 _fee) {
        address feeManager = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "FeeManager");
        // get the fee for this pool if it exists
        _fee = IFeeManager(feeManager).fee("claim_fee");
    }


    /// @notice get the fee for a claim
    /// @param self the claim settings
    /// @return _fee the fee amount
    function claimFee(IClaim.ClaimSettings storage self)
        internal
        view
        returns (uint256) {

        address multiToken = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "MultiToken");

        uint256 poolFee = _claimFee(self, address(self.minter));
        uint256 poolTokenFee = _claimFee(self, address(multiToken));
        uint256 defaultFee = _claimFee(self, address(0));

        defaultFee = defaultFee == 0 ? 2000 : defaultFee;

        // get the fee, preferring the token fee if available
        uint256 feeNum = poolFee != poolTokenFee
            ? (poolTokenFee != 0 ? poolTokenFee : poolFee)
            : poolFee;

        // set the fee to default if it is 0
        return feeNum == 0 ? defaultFee : feeNum;
    }


    /// @notice create a claim to mint a given gem
    /// @param self the GemPoolSettings object
    /// @param claim the claim to mint
    function createClaims(
        IClaim.ClaimSettings storage self,
        IClaim.Claim memory claim
    ) public {
        // get the minting manager
        address bank = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "Bank");

        // require all services to be present
        require(bank != address(0), "services not set");

        // validate the incoming claim to mint
        require(validateCreateClaim(self, claim), "Invalid claim");

        // assign system values - always override user values in case shit happens
        claim.id = nextTokenHash(self);
        claim.creator = msg.sender;
        claim.serviceRegistry = self.serviceRegistry;
        claim.createdTime = block.timestamp;
        claim.createdBlock = block.number;

        if(claim.depositToken != address(0)) {

            // if this is an ERC20 claim then transfer the erc20 into the bank
            IBank(bank).deposit(
                uint256(uint160(claim.depositToken)), // need to cast address to uint to pass it in
                claim.depositAmount);

        } else {

            // make sure we got enough ether to cover the deposit
            require(msg.value >= claim.depositAmount, "Insufficient deposit");

            // else this is ether so transfer the ether into the bank
             IBank(bank).deposit{value:claim.depositAmount}(
                0,
                claim.depositAmount);

        }

        // add the claim to the pool
        addClaim(self, claim);

        // increase the staked eth balance
        self.data.stakedTotal[claim.depositToken] += claim.depositAmount;

        // return the extra tokens to sender
        if (msg.value > claim.depositAmount && claim.depositToken == address(0)) {
            (bool success, ) = payable(msg.sender).call{
                value: msg.value - claim.depositAmount
            }("");
            require(success, "Failed to refund extra payment");
        }

    }


    /// @notice add a claim to the claims list
    /// @param self the GemPoolSettings object
    /// @param claim the claim to add
    function addClaim(
        IClaim.ClaimSettings storage self,
        IClaim.Claim memory claim
    ) public {

        // get the minting manager
        address mintingManager = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "MintingManager");
        address dataManager = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "DataManager");

        // require all services to be present
        require(
            mintingManager != address(0)
            && dataManager != address(0), "services not set");

        // mint the new claim to the caller's address
        IERC1155Mint(mintingManager).mint(msg.sender, claim.id, 1);

        // add the claims to claim list
        ClaimsSet.insert(self, claim);

        // store the minter for the token
        IDataManager(dataManager).setAddressData(
            claim.id,
            "minter",
            address(this)
        );

        // store the type of token this is
        IDataManager(dataManager).setUInt256Data(
            claim.id,
            "type",
            0 // 0 is a claim
        );

        // emit a event announceing claim
        emit ClaimCreated(claim.creator, address(this), claim);

    }

    /// @notice add a claim to the claims list
    /// @param self the GemPoolSettings object
    /// @param claim the claim to add
    function addGem(
        IClaim.ClaimSettings storage self,
        IClaim.Claim memory claim
    ) public {

        // get the next gem hash, increase the staking sifficulty
        // for the pool, and mint a gem token back to account
        claim.gemHash = nextTokenHash(self);

        address mintingManager = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "MintingManager");
        address dataManager = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "DataManager");

        // mint the new claim to the caller's address
        IERC1155Mint(mintingManager).mint(
            msg.sender,
            claim.gemHash,
            claim.mintQuantity
        );

        // store the minter for the token
        IDataManager(dataManager).setAddressData(
            claim.gemHash,
            "minter",
            address(this)
        );

        // store the type of token this is
        IDataManager(dataManager).setUInt256Data(
            claim.gemHash,
            "type",
            1 // 0 is a claim
        );

        // update the claim
        self.data.claims.valueList[claim.id] = claim;

        // emit an event about a gem getting created
        emit ClaimRedeemed(claim.creator, address(this), claim);

    }


    /// @notice validate that the claim is valid
    /// @param claim the claim to validate
    /// @param _valid the gem pool to validate against
    function validateCollectClaim(IClaim.ClaimSettings storage self, IClaim.Claim memory claim)
    internal view returns(bool _valid) {

        // get the minting manager
        address multiToken = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "MintingManager");

        // validation checks - disallow if not owner (holds coin with claimHash)
        // or if the unlockTime amd unlockPaid data is in an invalid state
        require(IERC1155(multiToken).balanceOf(msg.sender, claim.id) == 1,
            "Not the claim owner");

        uint256 unlockTime = claim.createdTime + claim.depositLength;
        uint256 unlockPaid = claim.depositAmount;
        // both values must be greater than zero
        require(unlockTime != 0 && unlockPaid > 0, "Invalid claim");
        _valid = true;
    }


    /// @notice collect an open claim (take custody of the funds the claim is redeeemable for and maybe a gem too)
    /// @param self the GemPoolSettings object
    /// @param _claimHash the claim to collect
    /// @param _requireMature if true, the claim must be mature
    function collectClaim(
        IClaim.ClaimSettings storage self,
        uint256 _claimHash,
        bool _requireMature
    ) public returns (bool) {

        address bank = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "Bank");
        address feeRecipient = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "FeeRecipient");
        address mintingManager = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "MintingManager");
        address feeManager = IJanusRegistry(self.serviceRegistry).get("ClaimLib", "FeeManager");

        // get the claim for this claim id
        IClaim.Claim memory claim = self.data.claims.valueList[_claimHash];
        require(claim.id == _claimHash, "Claim not found");

        // check the maturity of the claim - only issue gem if mature
        bool isMature = claim.createdTime + claim.depositLength < block.timestamp;
        require(!_requireMature || (_requireMature && isMature), "Immature Claim");

        // validate the claim
        require(validateCollectClaim(self, claim), "Invalid claim");

        // grab the erc20 token info if there is any
        uint256 unlockTokenPaid = claim.depositAmount;

        //  burn claim and transfer money back to user
        IERC1155Burn(mintingManager).burn(msg.sender, claim.id, 1);

        // if they used erc20 tokens stake their claim, return their tokens
        if (claim.depositToken != address(0)) {

            // calculate fee portion using fee tracker
            uint256 feePortion = 0;
            if (isMature == true) {
                feePortion = unlockTokenPaid / IFeeManager(feeManager).fee("collect_claim");
            }

            if(feePortion != 0) {

                // transfer fee to fee recipient
                ITransfer(bank).transfer(
                    feeRecipient,
                    uint256(uint160(claim.depositToken)),
                    feePortion
                );

                // return deposit to originator
                ITransfer(bank).transfer(
                    msg.sender,
                    uint256(uint160(claim.depositToken)),
                    unlockTokenPaid - feePortion
                );

                // record the fee paid by the user
                claim.feePaid = feePortion;

            }


        } else {

            // calculate fee portion using fee tracker
            uint256 feePortion = 0;
            if (isMature == true) {
                feePortion = claim.depositAmount / IFeeManager(feeManager).fee("collect_claim");
            }
            // transfer the ETH fee to fee tracker
            payable(feeManager).transfer(feePortion);

            // transfer the ETH back to user
            payable(msg.sender).transfer(claim.depositAmount - feePortion);

            // update the claim with the fee paid
            claim.feePaid = feePortion;

        }

        // update the claim with the claim block
        claim.claimedBlock = block.number;

        // increase the staked eth balance
        self.data.stakedTotal[claim.depositToken] += claim.depositAmount;

        // emit an event that the claim was redeemed for ETH
        emit ClaimRedeemed(
            msg.sender,
            address(self.minter),
            claim
        );


        // if all this is happening before the unlocktime then we exit
        // without minting a gem because the user is withdrawing early
        if (!isMature) {

            return false;

        }

        // create a new token from the claim
        addGem(self, claim);

        // update the claim
        self.data.claims.valueList[claim.id] = claim;

        return true;
    }

}
