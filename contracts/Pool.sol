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
import "./Interface/ISdeposit.sol";
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
    address public taxAddress;
    address public sDepositAddress;
    // test용
    uint256 public withdrawtoken1;
    uint256 public withdrawAsd;
    uint256 public totalLpAmount;
    uint256 public digiCount;
    bool public isPossible;
    uint256 public firstNum;
    uint256 public secondNum;
    address public firstTokenName;
    uint256 public firstTokenMon;
    uint256 public firstAmount;
    uint256 public secondAmount;
    // address public withdrawName;
    // uint256 public withdrawtokenMonth;
    // pool에 예치된 양이 얼마나 되는가!

    mapping(address => uint256) lqTokenAmount;
    uint256 public lqAmountARB;
    uint256 public lqAmountUSDT;
    uint256 public lqAmountETH;
    uint256 public lqAmountASD1;
    uint256 public lqAmountASD2;
    uint256 public lqAmountASD3;
    Deploy getData;

    mapping(address => mapping(address => bool)) public testinfo;

    constructor(
        address _deployaddress,
        address _sDeployAddress,
        address _ETHtokenAddress
    ) {
        poolAddress = address(this);
        (pairAddress, liquidAddress, swapAddress) = IDeploy(_deployaddress)
            .featureAddress();
        (stakingAddress, taxAddress, sDepositAddress) = ISdeploy(
            _sDeployAddress
        ).getFeatureAddress();
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
        IPair(pairAddress).makeLpPool(_token1, _token2, _contractAddress);
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
        uint256 recordAmount1 = _amount1 / (10 ** 18);
        uint256 recordAmount2 = _amount2 / (10 ** 18);
        lqTokenAmount[_token1] += recordAmount1;
        lqTokenAmount[_token2] += recordAmount2;
        string memory tokenName = SelfToken(_token1).name();
        if (Strings.equal(tokenName, "ARB")) {
            lqAmountARB = lqTokenAmount[_token1];
        } else if (Strings.equal(tokenName, "USDT")) {
            lqAmountUSDT = lqTokenAmount[_token1];
        } else if (Strings.equal(tokenName, "ETH")) {
            lqAmountETH = lqTokenAmount[_token1];
        }
    }

    function refundAmount(
        address _differLptoken,
        uint256 _amount,
        address _AsdToken
    ) public {
        ILiquid(liquidAddress).checkRefundAmount(
            _differLptoken,
            _amount,
            _AsdToken
        );
        (withdrawtoken1, withdrawAsd) = ILiquid(liquidAddress).provideAmount();
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
        (
            withdrawtoken1,
            withdrawAsd,
            totalLpAmount,
            ARBtokenAddress,
            USDTtokenAddress,
            ETHtokenAddress
        ) = ILiquid(liquidAddress).checkTest();
        string memory tokenName = SelfToken(_differLptoken).name();
        uint256 drawAmount1 = withdrawtoken1 / (10 ** 18);
        uint256 drawAmount2 = withdrawAsd / (10 ** 18);

        if (Strings.equal(tokenName, "ARBLP")) {
            lqTokenAmount[ARBtokenAddress] -= drawAmount1;
            lqTokenAmount[_AsdToken] -= drawAmount2;
            lqAmountARB = lqTokenAmount[ARBtokenAddress];
        } else if (Strings.equal(tokenName, "USDTLP")) {
            lqTokenAmount[USDTtokenAddress] -= drawAmount1;
            lqTokenAmount[_AsdToken] -= drawAmount2;
            lqAmountUSDT = lqTokenAmount[USDTtokenAddress];
        } else if (Strings.equal(tokenName, "ETHLP")) {
            lqTokenAmount[ETHtokenAddress] -= drawAmount1;
            lqTokenAmount[_AsdToken] -= drawAmount2;
            lqAmountETH = lqTokenAmount[ETHtokenAddress];
        }
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
        address _factoryAddress,
        address _differLp,
        uint256 _amount
    ) public {
        IStaking(stakingAddress).withDrawDifferLp(
            _userAccount,
            _factoryAddress,
            _differLp,
            _amount
        );
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

    function getAmount() public view returns (uint256, uint256) {
        return (withdrawtoken1, withdrawAsd);
    }

    function sDeposit(
        address _userAccount,
        address _factoryAddress,
        address _differToken,
        uint256 _differAmount
    ) public {
        ISdeposit(sDepositAddress).sDeposit(
            _userAccount,
            _factoryAddress,
            _differToken,
            _differAmount
        );
    }

    function Swithdraw(
        address _userAccount,
        address _factoryAddress,
        address _differToken,
        uint256 _differAmount
    ) public {
        ISdeposit(sDepositAddress).withDrawOneToken(
            _userAccount,
            _factoryAddress,
            _differToken,
            _differAmount
        );
    }

    function claimWithdraw(
        address _userAccount,
        address _factoryAddress,
        address _asdToken
    ) public {
        ISdeposit(sDepositAddress).sClaim(
            _userAccount,
            _factoryAddress,
            _asdToken
        );
    }

    function getInfor(address _userAccount, address _differLp) public {
        IStaking(stakingAddress).withDrawBool(_userAccount, _differLp);
        (
            firstNum,
            secondNum,
            firstTokenName,
            firstTokenMon,
            firstAmount,
            secondAmount
        ) = IStaking(stakingAddress).getValue1();
        isPossible = IStaking(stakingAddress).getValue2();
    }

    function getToken(address _differToken) public view returns (uint256) {
        return SelfToken(_differToken).balanceOf(msg.sender);
    }
}
