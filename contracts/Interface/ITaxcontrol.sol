// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ITaxControl {
    function accountsMake(address _differLp) external;

    function claimFee(
        address _differLpToken,
        address _ArbAddress,
        address _UsdtAddress,
        address _EthAddress
    ) external;
}
