// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice a farmer of randomness. This interface is for getting randomness. Randomness is seeded with a random seed and reseeded with the result of the previous call.
interface IRandomFarmer {

    /// @notice Get a random amount of bytes
    /// @param amount The amount of bytes to get
    /// @return The random bytes
    function getRandomBytes(uint8 amount) external returns (bytes32[] memory);

    /// @notice Get a random amount of uints
    /// @param amount The amount of uints to get
    /// @return The random uints
    function getRandomUints(uint8 amount) external returns (uint256[] memory);

    /// @notice Get a random number
    /// @param min The minimum value of the random number
    /// @param max The maximum value of the random number
    /// @return The random number
    function getRandomNumber(uint256 min, uint256 max)
        external
        returns (uint256);
}

/// @notice A farmer of randomness. This interface is for seeding the randomness.
interface IRandomFarm is IRandomFarmer {

    // init the random farm
    function initialize(uint256 seed) external;

    // add randomness to the farm
    function addRandomness(uint256 randomness) external;

}
