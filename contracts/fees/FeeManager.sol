// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../data/DataSource.sol";
import "../interfaces/IFeeManager.sol";

/// @notice the manager of fees
contract FeeManager is IFeeManager, UintDataSource {

    /// @notice default receive
    receive() external payable {}

    /// @notice get the fee for a given hash
    /// @param feeTextLabel the hash of the fee
    /// @return _fee the fee
    function fee(string memory feeTextLabel)
        external
        view
        override
        returns (uint256 _fee) {
        uint256 feeLabel = uint256(
            keccak256(abi.encodePacked(
                feeTextLabel
            ))
        );
        _fee = _getInt(feeLabel);
    }

    /// @notice get the fee for a given hash
    /// @param feeTextLabel the hash of the fee
    /// @param _fee the hash of the fee
    function _setFee(string memory feeTextLabel, uint256 _fee)
        internal {
        uint256 feeLabel = uint256(
            keccak256(abi.encodePacked(
                feeTextLabel
            ))
        );
        _setInt(feeLabel, _fee);
        emit FeeChanged(msg.sender, feeTextLabel, _fee);
    }

    /// @notice set the fee for the given fee type hash
    /// @param feeTextLabel the keccak256 hash of the fee type
    /// @param _fee the new fee amount
    function setFee(string memory feeTextLabel, uint256 _fee) external virtual override {
        _setFee(feeTextLabel, _fee);
    }


}
