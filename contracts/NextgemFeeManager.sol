// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./fees/FeeManager.sol";
import "./interfaces/IPermissionManager.sol";
import "./utils/Withdrawable.sol";
import "./service/Service.sol";

/// @title MetadataManager
/// @notice implements a metadata (off-chain data) manager
contract NextgemFeeManager is FeeManager, Initializable, Withdrawable, Service {

    uint256 private constant CREATE_COLLECTION_FEE = 50;
    uint256 private constant MINT_TOKEN_FEE = 2000;
    uint256 private constant BURN_TOKEN_FEE = 2000;
    uint256 private constant NETWORK_TRANSFER_FEE = 10000;
    uint256 private constant FLASH_LOAN_FEE = 10000;

    bytes32 public constant FEESETTER_ROLE = keccak256("FEESETTER");
    bytes32 public constant FEEWITHDRAWER_ROLE = keccak256("FEEWITHDRAWER");

    function initialize(address registry) public initializer {

        _setRegistry(registry);
        _setFee("create_collection", CREATE_COLLECTION_FEE);
        _setFee("mint_token", MINT_TOKEN_FEE);
        _setFee("burn_token", BURN_TOKEN_FEE);
        _setFee("network_transfer", NETWORK_TRANSFER_FEE);
        _setFee("flash_loan", FLASH_LOAN_FEE);

    }

    function setInt(uint256, uint256)
        external
        pure
        override {
        require(false, "setInt is not supported");
    }

    modifier onlyFeeSetter() {
        // IPermissionManager _manager = IPermissionManager(
        //     _serviceRegistry.get("FeeManager", "PermissionManager")
        // );
        // require(
        //     _manager.isSuperAdmin()
        //     || _manager.isPermissioned(FEESETTER_ROLE),
        //     "Only fee setters can set fees");
        _;
    }

    modifier onlyWithdrawer() {
        IPermissionManager _manager = IPermissionManager(
            _serviceRegistry.get("FeeManager", "PermissionManager")
        );
        require(
            _manager.isSuperAdmin()
            || _manager.isPermissioned(FEEWITHDRAWER_ROLE),
            "Only fee withdrwaers can withdraw fees");
        _;
    }

    /// @notice set the fee for the given fee type hash
    /// @param feeTextLabel the keccak256 hash of the fee type
    /// @param _fee the new fee amount
    function setFee(string memory feeTextLabel, uint256 _fee) external override onlyFeeSetter {
        uint256 feeLabel = uint256(
            keccak256(abi.encodePacked(
                feeTextLabel
            ))
        );
        _setInt(feeLabel, _fee);
        emit FeeChanged(msg.sender, feeTextLabel, _fee);
    }


    /// @dev withdraw the specified amount of tokens
    /// @param recipient the address of the recippient
    /// @param token the token to withdraw
    /// @param id the id of the token to withdraw
    /// @param amount the amount to withdraw
    function withdraw(
        address recipient,
        address token,
        uint256 id,
        uint256 amount) external override onlyWithdrawer {
            Withdrawable(this).withdraw(recipient, token, id, amount);
    }

}
