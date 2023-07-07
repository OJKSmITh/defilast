// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./SelfToken.sol";
import "./Deploy.sol";
import "./Interface/IDeploy.sol";
import "./Interface/ISwap.sol";
import "./Interface/IPair.sol";
import "./Interface/ILiquid.sol";
import "./Interface/IStaking.sol";
import "./Interface/ISdeploy.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Pool {
    address public poolAddress;
    // token
    address public ARBtokenAddress;
    address public USDTtokenAddress;
    address public ETHtokenAddress;
    // lp 토큰 관련 주소들
    address public ArbLpaddress;
    address public UsdtLpaddress;
    address public EthLpaddress;
    // pair, liquid, swap, staking주소
    address public pairAddress;
    address public liquidAddress;
    address public swapAddress;
    address public stakingAddress;
    // test용
    // uint256 public withdrawArb;
    // uint256 public withdrawAsd;
    // uint256 public totalLpAmount;
    // bool public isPossible;
    uint256 public firstNum;
    uint256 public secondNum;
    address public firstTokenName;
    uint256 public firstTokenMon;
    uint256 public firstAmount;
    uint256 public secondAmount;
    uint256 public digiCount;
    bool public isPossible;
    // address public withdrawName;
    // uint256 public withdrawtokenMonth;

    Deploy getData;

    constructor(
        address _deployaddress,
        address _sDeployAddress,
        address _ETHtokenAddress
    ) {
        poolAddress = address(this);
        (pairAddress, liquidAddress, swapAddress) = IDeploy(_deployaddress)
            .featureAddress();
        (stakingAddress) = ISdeploy(_sDeployAddress).getFeatureAddress();
        ETHtokenAddress = _ETHtokenAddress;
    }

    function depositEther(address _userAccount) external payable {
        require(ETHtokenAddress != address(0), "check the token maked");
        uint256 digicount = getDigitCount(msg.value);
        uint256 EthAmount = msg.value / (10 ** digicount);
        SelfToken(ETHtokenAddress).Ethmint(EthAmount, digicount);
        SelfToken(ETHtokenAddress).transferFrom(
            ETHtokenAddress,
            _userAccount,
            msg.value
        );
    }

    function refundEther(address payable recipient, uint amount) public {
        require(address(this).balance >= amount, "Not enough ETH in contract");
        recipient.transfer(amount);
    }

    function swapToken(
        address _diffrentToken,
        address _AsdToken,
        address _userAccount,
        address _contractAddress,
        uint256 _amount
    ) public {
        ISwap(swapAddress).differTokenSwap(
            _diffrentToken,
            _AsdToken,
            _userAccount,
            _contractAddress,
            _amount
        );
    }

    function differLpPool(
        address _token1,
        address _token2,
        address _contractAddress
    ) public {
        string memory differTokenName = SelfToken(_token1).name();

        IPair(pairAddress).makeLpPool(
            _token1,
            _token2,
            _contractAddress,
            differTokenName
        );
        (ArbLpaddress, UsdtLpaddress, EthLpaddress) = IPair(pairAddress)
            .getLpAddress();
    }

    function differLiquid(
        address _token1,
        uint256 _amount1,
        address _token2,
        uint256 _amount2,
        address _userAccount,
        address _factoryAddress
    ) public {
        ILiquid(liquidAddress).makeLiquid(
            _token1,
            _amount1,
            _token2,
            _amount2,
            _userAccount,
            _factoryAddress,
            pairAddress
        );
    }

    function removeLiquid(
        address _differLptoken,
        uint256 _amount,
        address _userAccount,
        address _factoryAddress,
        address _AsdToken
    ) public {
        ILiquid(liquidAddress).doRemoveLiquid(
            _differLptoken,
            _amount,
            _userAccount,
            _factoryAddress,
            _AsdToken
        );
    }

    function differLpstaking(
        address _differLptoken,
        address _userAccount,
        address _factoryAddress,
        uint256 _amount,
        uint256 _month,
        address _VASDtokenAddress
    ) public {
        // string memory tokenName = SelfToken(_differLptoken).name();

        IStaking(stakingAddress).StakeDifferLp(
            _differLptoken,
            _userAccount,
            _factoryAddress,
            _amount,
            _month,
            _VASDtokenAddress
        );
    }

    function differLpWithdraw(
        address _userAccount,
        address _factoryAddress
    ) public {
        IStaking(stakingAddress).withDrawDifferLp(
            _userAccount,
            _factoryAddress
        );
        (
            firstNum,
            secondNum,
            firstTokenName,
            firstTokenMon,
            firstAmount,
            secondAmount
        ) = IStaking(stakingAddress).getValue1();
        (isPossible) = IStaking(stakingAddress).getValue2();
    }

    function getDigitCount(uint256 number) public returns (uint256) {
        if (number == 0) {
            return 1;
        }

        uint256 digitCount = 0;
        digiCount = 0;
        while (number > 0) {
            digitCount++;
            digiCount++;
            number = number / 10;
        }

        return digitCount - 1;
    }
}

// function USDTpoolLv(uint256 _level) external {
//     USDTPoolLevel = _level;
// }
