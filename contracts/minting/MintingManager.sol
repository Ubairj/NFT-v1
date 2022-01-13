// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/ITokenMinter.sol";
import "../interfaces/IERC1155Mint.sol";
import "../interfaces/IERC1155Burn.sol";
import "../interfaces/IMeteredService.sol";
import "../interfaces/IFeeManager.sol";
import "../interfaces/IJanusRegistry.sol";
import "../interfaces/IMintingRegistry.sol";
import "../interfaces/IMintingManager.sol";

import "../bank/Bank.sol";
import "../service/Service.sol";

import "hardhat/console.sol";

/**
 * @dev The minting manager is responsible for minting new tokens upon permissioned minter request
 */
contract MintingManager is
IMintingManager,
Bank,
Service,
ITokenMinter,
IERC1155Burn,
IMeteredService,
Initializable {

    mapping(address => Minter) internal _minters;

    function initialize(address registry) public initializer {

        _setRegistry(registry);

    }

    function makeHash(uint256 tokenId) public view returns (uint256) {

        return uint256(keccak256(abi.encodePacked("Token", tokenId, msg.sender)));

    }

    /// @notice deposit funds so that we can mint tokens
    /// @param amount the amount to deposit
    function depositTokens(uint256 amount) external payable {

        // ensure enough funds have been attached to the deposit
        require(msg.value >= amount, "Insufficient attached funds");

        // if the account field on the minters record is blank then
        // this is a new minter and we need to register them with the system
        if(_minters[msg.sender].account == address(0)) {

            // get the fee manager contract address
            address _feeManager = IJanusRegistry(_serviceRegistry).get("MintingManager", "FeeManager");
            // get the bank's contract address
            address _bank = IJanusRegistry(_serviceRegistry).get("MintingManager", "Bank");
            // get the fee receiver address - we send the fee to the bank for them to pick up
            address _feeReceiver = IJanusRegistry(_serviceRegistry).get("MintingManager", "FeeReceiver");
            // get the fee amount for new registrants
            uint256 _fee = IFeeManager(_feeManager).fee("Registration");

            // ensure enough fees are attached to the transaction
            require(msg.value >= _fee, "Insufficient funds to register new minter");

            // deposit the fee amount into the bank for the fee receiver
            Bank(_bank).depositFrom{value: _fee}(_feeReceiver, 0, _fee);
            // deposit the remainder into the mintere account
            if(amount - _fee > 0) {
                _deposit(msg.sender, 0, amount - _fee);
            }
            // set the account field on the minters record to the current sender
            _minters[msg.sender] = Minter(msg.sender, 0, 0, 0);
        }
        //
        else if(_minters[msg.sender].account == msg.sender) {

            // deposit the amount to the minter account
            //_deposit(msg.sender, 0, amount);

        }

    }

    /// @notice get the registration record for a permissioned minter.
    /// @param _minter the address
    function minter(address _minter) external view override returns (Minter memory __minter) {

        __minter = _minters[_minter];

    }

    /// @notice mint some amount of tokens for the given id
    /// @param receiver the receiver of the minted token
    /// @param id the id of the minted token
    /// @param amount the amount of tokens to mint
    function mint(address receiver, uint256 collectionId, uint256 id, uint256 amount) external override {

        // get the multitoken we are minting on
        address _multitoken = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "MultiToken"
        );

        // get the fee manager that gives us the fee for minting
        address _feeManager = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "FeeManager"
        );

        // get the fee manager that gives us the fee for minting
        address _mintRegistry = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "MintingRegistry"
        );

        // get current minter if any for this id
        address registryMinter = IMintingRegistry(_mintRegistry).minter(id);

        // require that this id not be already minted on by another minter
        require(registryMinter == address(0) || registryMinter == msg.sender,
            "Not owner of this id");

        // get current minter if any for this id
        address collectionMinter = IMintingRegistry(_mintRegistry).collectionMinter(collectionId);

        // require that the collection id is not already minted on by another minter
        require(collectionMinter == address(0) || collectionMinter == msg.sender,
            "Not owner of this collection");

        // get the minting fee
        uint256 mintFee = IFeeManager(_feeManager).fee("Mint");
        mintFee *= amount;

        // ensure the sender has enough funds to cover the minting fee
        require(mintFee <= balances[msg.sender][id], "Insufficient funds to mint");

        // get the bank's contract address
        address _bank = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "Bank"
        );

        // get the fee receiver address - we send the fee to the bank for them to pick up
        address _feeReceiver = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "FeeReceiver"
        );

        // decrement the minter's fee balance
        balances[msg.sender][id] -= mintFee;
        // increment the number of minted tokens
        _minters[msg.sender].minted += amount;
        // increment the amount of fee tokens spent
        _minters[msg.sender].spent += mintFee;


        // deposit the fee amount into the bank for the fee receiver
        Bank(_bank).depositFrom{value: mintFee}(_feeReceiver, 0, mintFee);

        // register the minting with the registry
        IMintingRegistry(_mintRegistry).register(msg.sender, collectionId, id);

        // mint the token
        IERC1155Mint(_multitoken).mint(receiver, id, amount);

    }

    /// @notice burn a given amount of tokens for the given id
    /// @param target the receiver of the minted token
    /// @param id the id of the minted token
    /// @param amount the amount of tokens to burn
    function burn(address target, uint256 id, uint256 amount) external override(IERC1155Burn, ITokenMinter) {

        // ensure that the caller is a registered minter
        require(
            _minters[msg.sender].account == msg.sender,
            "Not a registered minter");

        // get the multitoken we are minting on
        address _multitoken = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "MultiToken"
        );
        // get the fee manager that gives us the fee for minting
        address _feeManager = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "FeeManager"
        );
        // get the fee manager that gives us the fee for minting
        address _mintRegistry = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "MintingRegistry"
        );

        // get current minter if any for this id
        address registryMinter = IMintingRegistry(_mintRegistry).minter(id);

        // require that this id not be already minted on by another minter
        require(registryMinter == msg.sender, "Not owner of this id");

        // get the burn fee
        uint256 burnFee = IFeeManager(_feeManager).fee("Burn");
        burnFee *= amount;

        // ensure the sender has enough funds to cover the minting fee
        require(burnFee <= balances[msg.sender][id], "Insufficient funds to burn");
        // check to see if the target has enough balance
        require(IERC1155(_multitoken).balanceOf(target, id) >= amount,
            "Target balance insufficient");

        // get the bank's contract address
        address _bank = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "Bank"
        );
        // get the fee receiver address - we send the fee to the bank for them to pick up
        address _feeReceiver = IJanusRegistry(_serviceRegistry).get(
            "MintingManager",
            "FeeReceiver"
        );

        // decrement the minter's fee balance
        balances[msg.sender][id] -= burnFee;
        // increment the number of minted tokens
        _minters[msg.sender].burned += amount;
        // increment the amount of fee tokens spent
        _minters[msg.sender].spent += burnFee;

        // deposit the fee amount into the bank for the fee receiver
        Bank(_bank).depositFrom{value: burnFee}(_feeReceiver, 0, burnFee);

        // burn the token
        IERC1155Burn(_multitoken).burn(target, id, amount);

    }

    /// @notice get the service fee uid
    /// @return _feeUids the service fee
    function getFeeUids() external pure override returns (string[] memory _feeUids) {

        _feeUids = new string[](3);
        _feeUids[0] = "Mint";
        _feeUids[1] = "Burn";
        _feeUids[2] = "Register";

    }

}
