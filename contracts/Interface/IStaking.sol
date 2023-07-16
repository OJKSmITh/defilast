// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IStaking {
    function StakeDifferLp(
        address _differLptoken,
        address _userAccount,
        address _factoryAddress,
        uint256 _amount,
        uint256 _month,
        address _VASDtokenAddress
    ) external;

    function withDrawDifferLp(
        address _userAccount,
        address _factoryAddress,
        address _differLp,
        uint256 _amount
    ) external;

    function getValue1()
        external
        returns (
            uint256 _firstNum,
            uint256 _secondNum,
            address _firstTokenName,
            uint256 _firstTokenMon,
            uint256 _firstAmount,
            uint256 _secondAmount
        );

    function getValue2() external returns (bool _isPossible);

    function withDrawBool(
        address _userAccount,
        address _differLp
    ) external returns (address[] memory tkname, uint256[] memory tkValue);
}
