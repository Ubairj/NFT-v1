// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./ITokenDefinitions.sol";
import "./IRequirement.sol";


/// @notice a crafting matrix describes a set of items that can be crafted
interface ICraftingMatrix {

    struct CraftingBundle {
        IRequirement[] requirements;
        ITokenDefinitions[] outputs;
    }

    struct CraftingMatrixSettings {
        CraftingBundle[] craftingBundles;
    }

}
