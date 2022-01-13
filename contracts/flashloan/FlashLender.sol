//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IFlashLender.sol";
import "../interfaces/IWrappedFTM.sol";


contract FlashLender is IFlashLender {

    uint256 feePerMillion;

    address private constant WFTM = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;

    constructor() {
        feePerMillion = 1000;
    }

    /**
     * @dev The maximum flash loan amount - 90% of available funds
     */
    function maxFlashLoan(address tokenAddress)
        external
        view
        override
        returns (uint256)
    {
        // if the token address is zero then get the FTM balance
        // other wise get the token balance of the given token address
        // must not revert
        if (tokenAddress != address(0)) {
            try IERC20(tokenAddress).balanceOf(address(this)) returns (
                uint256 balance
            ) {
                return balance;
            } catch {
                return 0;
            }
        }
        // if the token address is zero then get the FTM balance
        return address(this).balance;
    }

    function flashFee(address token, uint256 amount)
        public
        view
        override
        returns (uint256)
    {
        // must revert if token balanve is 0 or
        // if the token address is not a ERC20 token
        if (token != address(0)) {
            try IERC20(token).balanceOf(address(this)) returns (
                uint256 balance
            ) {
                require(balance > 0, "ERC20 token not found");
            } catch {
                require(false, "ERC20 token not found");
            }
        }
        // get the flash fee from the storage
        uint256 feeDiv = feePerMillion;        // if no default fee, set the fee to 1000 (0.1%)
        if (feeDiv == 0) {
            feeDiv = 1000;
        }
        // fee div indicates the fee per million
        return ( amount / 1000000 ) * feeDiv;
    }

    function setFeePermillion(
        uint256 _feePermillion
    ) external override {
        feePerMillion = _feePermillion;
    }

    function getFeePermillion(
    ) external view override returns (uint256) {
        return feePerMillion;
    }

/**
     * @dev Perform a flash loan (borrow tokens from the controller and return them after a certain time)
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        // get the fee of the flash loan
        uint256 fee = flashFee(token, amount);

        // get the receiver's address
        address receiverAddress = address(receiver);

        // no token address means we are sending FTM
        if (token == address(0)) {
            // transfer FTM to receiver - we get paid back in WFTM
            payable(receiverAddress).transfer(amount);
        } else {
            // else we are sending erc20 tokens
            IERC20(token).transfer(receiverAddress, amount);
        }

        // create success callback hash
        bytes32 callbackSuccess = keccak256("ERC3156FlashBorrower.onFlashLoan");
        // call the flash loan callback
        require(
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) ==
                callbackSuccess,
            "FlashMinter: Callback failed"
        );

        // if the token is 0 then we have to
        // get paid in WFTM in order to properly
        // meter the loan since the erc20 approval
        // sets us widthdraw a specific amount
        if (token == address(0)) {
            token = WFTM;
        }

        // to get our allowance of the token from the receiver
        // this is the amount we will be allowed to withdraw
        // aka the loan repayment amount
        uint256 _allowance = IERC20(token).allowance(
            address(receiver),
            address(this)
        );

        // if the allowance is greater than the loan amount plus
        // the fee then we can finish the flash loan
        require(
            _allowance >= (amount + fee),
            "FlashMinter: Repay not approved"
        );

        // transfer the tokens back to the lender
        IERC20(token).transferFrom(
            address(receiver),
            address(this),
            _allowance
        );

        // if this is wrapped fantom and wrapped fantom is not
        // in allowed tokens then this is a repay so unwrap the WFTM
        if (token == WFTM) {
            IWrappedFTM(WFTM).withdraw(_allowance);
        }

        return true;
    }

}
