// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./SelfToken.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Staking {
    address private VASDtokenAddress;
    address private stakingAddress;
    SelfToken VASDtoken;
    struct StakeInfo {
        uint256 amount;
        uint256 stakedTime;
        bool isWithdrawable;
        address Lpaddress;
    }
    uint256 four_month = 4 * 30 days;
    uint256 eight_month = 8 * 30 days;
    uint256 twelve_month = 12 * 30 days;
    uint256 test_month = 60;
    bool timePassage;
    address[] tokenNames;
    uint[] tokenValue;
    bool isPossible;

    /**
    @dev 어떤 유저에게 어떤 토큰을 어떤 개월수만큼 얼마나, 언제, 인출가능한지, 어떤 lptoken인지!
     */
    mapping(address => mapping(address => mapping(uint256 => StakeInfo)))
        public stakeInfo;

    /**
    @dev 어떤 유저에게 어떤 토큰을 얼마나 예치했니
    */
    mapping(address => mapping(address => uint256)) public stakeMonth;

    /**
    @dev 무슨 토큰 예치했니
     */
    mapping(address => mapping(uint256 => address)) public stakeTokenName;
    /**
    @dev 몇개의 토큰 예치했니
     */
    mapping(address => uint256) public userLenth;
    // test
    uint256 firstNum;
    uint256 secondNum;
    address firstTokenName;
    uint256 firstTokenMon;
    uint256 firstAmount;
    uint256 secondAmount;
    address withdrawName;
    uint256 withdrawtokenMonth;

    constructor() {
        stakingAddress = address(this);
    }

    function StakeDifferLp(
        address _differLptoken,
        address _userAccount,
        address _factoryAddress,
        uint256 _amount,
        uint256 _month,
        address _VASDtokenAddress
    ) public {
        VASDtokenAddress = _VASDtokenAddress;
        VASDtoken = SelfToken(VASDtokenAddress);
        uint256 currentPid = userLenth[_userAccount];
        stakeTokenName[_userAccount][currentPid] = _differLptoken;
        userLenth[_userAccount] += 1;
        if (stakeMonth[_userAccount][_differLptoken] == 0) {
            mergeFunction(
                _differLptoken,
                _userAccount,
                _factoryAddress,
                _amount,
                _month
            );
            stakeMonth[_userAccount][_differLptoken] = _month;
        } else if (stakeMonth[_userAccount][_differLptoken] < _month) {
            uint256 existMonth = stakeMonth[_userAccount][_differLptoken];
            uint256 existAmount = stakeInfo[_userAccount][_differLptoken][
                stakeMonth[_userAccount][_differLptoken]
            ].amount;
            uint256 takeAmount = _amount + existAmount;
            mergeFunction(
                _differLptoken,
                _userAccount,
                _factoryAddress,
                takeAmount,
                _month
            );
            resetValue(_userAccount, _differLptoken, existMonth);
            stakeMonth[_userAccount][_differLptoken] = _month;
        } else if (stakeMonth[_userAccount][_differLptoken] > _month) {
            uint256 existMonth = stakeMonth[_userAccount][_differLptoken];
            mergeFunction(
                _differLptoken,
                _userAccount,
                _factoryAddress,
                _amount,
                _month
            );
            stakeInfo[_userAccount][_differLptoken][existMonth]
                .amount += stakeInfo[_userAccount][_differLptoken][_month]
                .amount;
            resetValue(_userAccount, _differLptoken, _month);
            stakeMonth[_userAccount][_differLptoken] = existMonth;
        } else if (stakeMonth[_userAccount][_differLptoken] == _month) {
            uint256 existMonth = stakeMonth[_userAccount][_differLptoken];
            uint256 existValue = stakeInfo[_userAccount][_differLptoken][
                existMonth
            ].amount;
            mergeFunction(
                _differLptoken,
                _userAccount,
                _factoryAddress,
                _amount,
                _month
            );
            stakeInfo[_userAccount][_differLptoken][_month]
                .amount += existValue;
            stakeMonth[_userAccount][_differLptoken] = _month;
        }
    }

    function withDrawDifferLp(
        address _userAccount,
        address _factoryAddress
    ) public {
        firstNum = userLenth[_userAccount] - 1;

        for (uint256 i = 0; i <= firstNum; i++) {
            firstTokenName = stakeTokenName[_userAccount][i];
            firstTokenMon = stakeMonth[_userAccount][firstTokenName];
            firstAmount = stakeInfo[_userAccount][firstTokenName][firstTokenMon]
                .amount;
            withDrawBool(_userAccount);
            isPossible = stakeInfo[_userAccount][firstTokenName][firstTokenMon]
                .isWithdrawable;
            if (isPossible) {
                SelfToken(firstTokenName).approve(_factoryAddress, firstAmount);
                SelfToken(firstTokenName).transferFrom(
                    _factoryAddress,
                    _userAccount,
                    firstAmount
                );
                resetValue(_userAccount, firstTokenName, firstTokenMon);
            }
        }
    }

    function withDrawBool(
        address _userAccount
    ) internal returns (address[] memory tkname, uint256[] memory tkValue) {
        secondNum = userLenth[_userAccount] - 1;
        // uint256 withDrawAmount;

        for (uint256 i = 0; i <= secondNum; i++) {
            withdrawName = stakeTokenName[_userAccount][i];
            withdrawtokenMonth = stakeMonth[_userAccount][withdrawName];

            if (withdrawtokenMonth == 4) {
                timePassage =
                    block.timestamp >=
                    stakeInfo[_userAccount][withdrawName][withdrawtokenMonth]
                        .stakedTime +
                        test_month;
                // stakeInfo[_userAccount][tokenName][tokenMonth].stakedTime +
                //     four_month;
            } else if (withdrawtokenMonth == 8) {
                timePassage =
                    block.timestamp >=
                    stakeInfo[_userAccount][withdrawName][withdrawtokenMonth]
                        .stakedTime +
                        test_month;
                // stakeInfo[_userAccount][tokenName][tokenMonth].stakedTime +
                //     eight_month;
            } else if (withdrawtokenMonth == 12) {
                timePassage =
                    block.timestamp >=
                    stakeInfo[_userAccount][withdrawName][withdrawtokenMonth]
                        .stakedTime +
                        test_month;
                // stakeInfo[_userAccount][tokenName][tokenMonth].stakedTime +
                //     twelve_month;
            }
            if (timePassage) {
                stakeInfo[_userAccount][withdrawName][withdrawtokenMonth]
                    .isWithdrawable = true;
                tokenNames.push(withdrawName);
                uint256 currentAmount = stakeInfo[_userAccount][withdrawName][
                    withdrawtokenMonth
                ].amount;
                tokenValue.push(currentAmount);
                secondAmount += currentAmount;
            }
        }
        return (tokenNames, tokenValue);
    }

    function transferStaking(
        address _differLptoken,
        address _userAccount,
        uint256 _amount,
        uint256 _month,
        address _factoryAddress
    ) internal {
        SelfToken(_differLptoken).transferFrom(
            _userAccount,
            _factoryAddress,
            _amount
        );
        stakeInfo[_userAccount][_differLptoken][_month].amount = _amount;
        stakeInfo[_userAccount][_differLptoken][_month].stakedTime = block
            .timestamp;
        stakeInfo[_userAccount][_differLptoken][_month].isWithdrawable = false;
    }

    function rewardStaking(address _userAccount, uint256 _amount) internal {
        uint256 VASDtokenAmount = _amount / 10 ** 18;
        VASDtoken.mint(VASDtokenAmount);
        VASDtoken.approve(_userAccount, VASDtokenAmount);
        VASDtoken.transferFrom(VASDtokenAddress, _userAccount, VASDtokenAmount);
    }

    function mergeFunction(
        address _differLptoken,
        address _userAccount,
        address _factoryAddress,
        uint256 _amount,
        uint256 _month
    ) internal {
        if (_month == 4) {
            transferStaking(
                _differLptoken,
                _userAccount,
                _amount,
                _month,
                _factoryAddress
            );
            rewardStaking(_userAccount, _amount);
        } else if (_month == 8) {
            transferStaking(
                _differLptoken,
                _userAccount,
                _amount,
                _month,
                _factoryAddress
            );
            rewardStaking(_userAccount, 2 * _amount);
        } else if (_month == 12) {
            transferStaking(
                _differLptoken,
                _userAccount,
                _amount,
                _month,
                _factoryAddress
            );
            rewardStaking(_userAccount, 4 * _amount);
        } else {
            revert("wrong month");
        }
    }

    function resetValue(
        address _userAccount,
        address _differLptoken,
        uint256 _findValue
    ) internal {
        stakeInfo[_userAccount][_differLptoken][_findValue].amount = 0;
        stakeInfo[_userAccount][_differLptoken][_findValue].stakedTime = 0;
        stakeInfo[_userAccount][_differLptoken][_findValue]
            .isWithdrawable = false;
    }

    function getValue1()
        public
        view
        returns (
            uint256 _firstNum,
            uint256 _secondNum,
            address _firstTokenName,
            uint256 _firstTokenMon,
            uint256 _firstAmount,
            uint256 _secondAmount
        )
    {
        return (
            firstNum,
            secondNum,
            firstTokenName,
            firstTokenMon,
            firstAmount,
            secondAmount
        );
    }

    function getValue2() public view returns (bool _isPossible) {
        return (isPossible);
    }
}
