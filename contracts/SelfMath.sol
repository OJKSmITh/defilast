// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library SelfMath {
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        else if (x <= 3) return 1;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}
