// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./SelfToken.sol";

contract Sdeposit {
    struct userInfo {
        address differToken;
        uint256 depositAmount;
        uint256 deposittime;
    }
    uint256 private testMonth = 5;
    uint256 private test2Month = 2 minutes;
    uint256 private test3Month = 300;
    uint256 private Month = 30 days;
    uint256 private tMonth = 2 * Month;
    uint256 private thirdMonth = 3 * Month;
    uint256 private accountBalance;
    uint256 private checkAmount;
    mapping(address => userInfo) public depositInfo;

    constructor() {}

    function sDeposit(
        address _userAccount,
        address _factoryAddress,
        address _differToken,
        uint256 _differAmount
    ) public {
        depositInfo[_userAccount].differToken = _differToken;
        depositInfo[_userAccount].depositAmount += _differAmount;
        depositInfo[_userAccount].deposittime = block.timestamp;
        accountBalance = depositInfo[_userAccount].depositAmount;
        SelfToken(_differToken).transferFrom(
            _userAccount,
            _factoryAddress,
            _differAmount
        );
    }

    function withDrawOneToken(
        address _userAccount,
        address _factoryAddress,
        address _differToken,
        uint256 _differAmount
    ) public {
        depositInfo[_userAccount].depositAmount -= _differAmount;
        accountBalance = depositInfo[_userAccount].depositAmount;
        SelfToken(_differToken).transferFrom(
            _factoryAddress,
            _userAccount,
            _differAmount
        );
    }

    function claimAmountcheck(address _userAccount) public {
        uint256 userAmount = depositInfo[_userAccount].depositAmount;
        uint256 rateAmount = userAmount / 10;
        uint256 userTime = depositInfo[_userAccount].deposittime;
        if (
            block.timestamp >= userTime + testMonth &&
            block.timestamp < userTime + test2Month
        ) {
            checkAmount = rateAmount;
        } else if (block.timestamp >= userTime + test2Month) {
            checkAmount = 2 * rateAmount;
        }
    }

    function sClaim(
        address _userAccount,
        address _factoryAddress,
        address _asdToken
    ) public {
        uint256 userAmount = depositInfo[_userAccount].depositAmount;
        uint256 rateAmount = userAmount / 10;
        uint256 userTime = depositInfo[_userAccount].deposittime;
        if (
            block.timestamp >= userTime + testMonth &&
            block.timestamp < userTime + test2Month
        ) {
            SelfToken(_asdToken).transferFrom(
                _factoryAddress,
                _userAccount,
                rateAmount
            );
        } else if (block.timestamp >= test2Month) {
            SelfToken(_asdToken).transferFrom(
                _factoryAddress,
                _userAccount,
                2 * rateAmount
            );
        }
    }

    function returnValue() public view returns (uint256) {
        return checkAmount;
    }

    function getAccountBalance(
        address _userAccount,
        address _differToken
    ) public returns (uint256) {
        if (depositInfo[_userAccount].differToken == _differToken) {
            accountBalance = depositInfo[_userAccount].depositAmount;
        }
        return accountBalance;
    }
}
