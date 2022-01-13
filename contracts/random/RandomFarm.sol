// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IRandomFarm.sol";

import "../access/Controllable.sol";

/// @notice A randomness farm. It does what it says - it farms randomness that is provided by the user into usable randomness by other contracts.
contract RandomFarm is IRandomFarm, Initializable {
    uint256 private randomSeed;
    mapping(address => uint256) private salt;

    /// @notice initialize the contract with a seed random value
    /// @param seed the seed random value
    function initialize(uint256 seed) external override initializer {
        randomSeed = seed;
    }

    /// @notice returns whether the contract is initialized
    /// @return whether the contract is initialized
    function isInitialized() external view returns (bool) {
        return randomSeed != 0;
    }

    /// @notice add randomness to the random farm
    /// @param randomness the randomness to add
    function addRandomness(uint256 randomness) external override {
        randomSeed = uint256(keccak256(abi.encodePacked(randomSeed, randomness)));
    }

    /// @notice get some random bytes from the farm
    /// @param amount the number of bytes to get
    /// @return _randomBytes the random bytes
    function getRandomBytes(uint8 amount) external override returns (bytes32[] memory _randomBytes) {
        _randomBytes = new bytes32[](amount);
        for (uint8 i = 0; i < amount; i++) {
            _randomBytes[i] = _randomByte32();
        }
    }

    /// @notice get some random uints from the farm
    /// @param amount the number of uints to get
    /// @return _randomUints the random uints
    function getRandomUints(uint8 amount) external override returns (uint256[] memory _randomUints) {
        _randomUints = new uint256[](amount);
        for (uint8 i = 0; i < amount; i++) {
            _randomUints[i] = _randomUint();
        }
    }

    /// @notice get some random uints from the farm. internal
    /// @return _bytes32 the random byte
    function _randomByte32() internal returns (bytes32 _bytes32) {
        _bytes32 = bytes32(
            keccak256(abi.encodePacked
            (blockhash(block.number - 1),
            randomSeed,
            tx.origin,
            salt[tx.origin]++)
        ));
    }

    /// @notice get a random uint from the farm. internal
    /// @return _uint the random uint
    function _randomUint() internal returns (uint256 _uint) {
        _uint = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), randomSeed, tx.origin, salt[tx.origin]++))
        );
    }

    /// @notice get a random number from the farm
    /// @param min the minimum number
    /// @param max the maximum number
    /// @return _randomNumber the random number
    function getRandomNumber(uint256 min, uint256 max) external override returns (uint256 _randomNumber) {
        return min + (_randomUint() % (max - min));
    }
}

/// @notice a random farmer harvests randomness from the farm. Use the random farmer to get random numbers.
contract RandomFarmer is IRandomFarmer, Initializable {
    IRandomFarm internal farm;

    constructor() {
        farm = new RandomFarm();
        farm.initialize(block.timestamp * block.number);
    }

    /// @notice initialize the contract with a seed random value
    /// @param _farm the seed random value
    function initialize(address _farm) external initializer {
        farm = IRandomFarm(_farm);
    }

    /// @notice get the random farm
    /// @return _farm the random farm
    function getFarm() public view returns (address _farm) {
        _farm = address(farm);
    }

    /// @notice harvest randomness from the farm
    /// @param amount the amount of randomness to harvest
    /// @return _randomness the randomness
    function getRandomBytes(uint8 amount) external override returns (bytes32[] memory _randomness) {
        return farm.getRandomBytes(amount);
    }

    /// @notice harvest randomness from the farm
    /// @param amount the amount of randomness to harvest
    /// @return _randomness the randomness
    function getRandomUints(uint8 amount) external override returns (uint256[] memory _randomness) {
        return farm.getRandomUints(amount);
    }

    /// @notice harvest randomness from the farm
    /// @param min the minimum number
    /// @param max the maximum number
    /// @return _randomNumber the random number
    function getRandomNumber(uint256 min, uint256 max) external override returns (uint256 _randomNumber) {
        return farm.getRandomNumber(min, max);
    }
}
