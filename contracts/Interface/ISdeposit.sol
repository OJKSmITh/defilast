// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ISdeposit {
    struct userInfo {
        address differToken;
        uint256 depositAmount;
        uint256 deposittime;
    }

    function sDeposit(
        address _userAccount,
        address _factoryAddress,
        address _differToken,
        uint256 _differAmount
    ) external;

    function withDrawOneToken(
        address _userAccount,
        address _factoryAddress,
        address _differToken,
        uint256 _differAmount
    ) external;

    function claimAmountcheck(address _userAccount) external;

    function sClaim(
        address _userAccount,
        address _factoryAddress,
        address _asdToken
    ) external;

    function returnValue() external view returns (uint256);

    function getAccountBalance(
        address _userAccount,
        address _differToken
    ) external view returns (uint256);
}
