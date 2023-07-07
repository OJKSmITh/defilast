// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./SelfToken.sol";
import "./Pool.sol";
import "./Interface/IPair.sol";
import "./Interface/IDeploy.sol";
import "./Interface/ISdeploy.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Factory_v1 {
    uint256 public factoryLevel; // 팩토리레벨
    address private owner; // 거버넌스
    address public factoryAddress; // Factory 주소
    // 토큰들 주소
    address public ARBtokenAddress;
    address public USDTtokenAddress;
    address public ETHtokenAddress;
    address public ASDtokenAddress; // 여기서는 테스트 용으로 지금 놓지만 나중에는 자동으로 배포해서 받자.
    address public VASDtokenAddress;
    // pair, liquid, swap, pool, staking
    address public pairAddress;
    address public liquidAddress;
    address public swapAddress;
    address public poolAddress;
    address public stakingAddress;
    // lp 주소
    address public ArbLpaddress; // ARBLpaddress
    address public UsdtLpaddress; // ARBLpaddress
    address public EthLpaddress; // ARBLpaddress
    // lp 관련 레벨들
    uint256 public ArbpoolLv;
    uint256 public ArbLpLv;
    uint256 public UsdtpoolLv;
    uint256 public UsdtLpLv;
    uint256 public EthpoolLv;
    uint256 public EthLpLv;
    // check value
    uint256 public backAmount;
    bool public isPossible;
    Pool pool;

    struct LvContent {
        uint256 poolLv;
        uint256 LptokenLv;
    }

    mapping(address => LvContent) public LvContents;

    constructor(
        address _deployAddress,
        address _sDeployAddress,
        address _ETHtokenAddress
    ) {
        factoryAddress = address(this);
        pool = new Pool(_deployAddress, _sDeployAddress, _ETHtokenAddress);
        poolAddress = address(pool);
        (VASDtokenAddress) = ISdeploy(_sDeployAddress).tokenAddress();
        (pairAddress, liquidAddress, swapAddress) = IDeploy(_deployAddress)
            .featureAddress();
        (stakingAddress) = ISdeploy(_sDeployAddress).getFeatureAddress();
        ETHtokenAddress = _ETHtokenAddress;
    }

    event CalcLendingEvent(uint tokenTotalLp);

    function buyToken() public payable {
        require(msg.value > 0, "check the ether amount");
        address userAccount = msg.sender;
        pool.depositEther{value: msg.value}(userAccount);
    }

    function refundToken(address _ETHtokenAddress, uint _amount) public {
        require(_ETHtokenAddress == ETHtokenAddress, "check the right token");
        uint256 checkAmount = SelfToken(_ETHtokenAddress).balanceOf(msg.sender);
        require(checkAmount >= _amount, "check the amount");
        SelfToken(_ETHtokenAddress)._burn(msg.sender, _amount);
        pool.refundEther(payable(msg.sender), _amount);
    }

    function swapToken(
        address _diffrentToken,
        address _AsdToken,
        uint256 _amount
    ) public {
        address userAccount = msg.sender;
        pool.swapToken(
            _diffrentToken,
            _AsdToken,
            userAccount,
            factoryAddress,
            _amount
        );
    }

    function createPool(address _differentToken, address _AsdToken) public {
        pool.differLpPool(_differentToken, _AsdToken, factoryAddress);
        pairAddress = pool.pairAddress();
        (ArbLpaddress, UsdtLpaddress, EthLpaddress) = IPair(pairAddress)
            .getLpAddress();
        (ArbpoolLv, ArbLpLv, UsdtpoolLv, UsdtLpLv, EthpoolLv, EthLpLv) = IPair(
            pairAddress
        ).getLpLv();
        LvContents[ArbLpaddress].poolLv = ArbpoolLv;
        LvContents[ArbLpaddress].LptokenLv = ArbLpLv;
        LvContents[UsdtLpaddress].poolLv = UsdtpoolLv;
        LvContents[UsdtLpaddress].LptokenLv = UsdtLpLv;
        LvContents[EthLpaddress].poolLv = EthpoolLv;
        LvContents[EthLpaddress].LptokenLv = EthLpLv;
    }

    function checkLptoken(
        address _randomAddress
    ) public view returns (uint256) {
        address userAccount = msg.sender;
        return SelfToken(_randomAddress).balanceOf(userAccount);
    }

    function addLiquid_1(
        address _differentToken,
        uint256 _amount1,
        address _AsdToken,
        uint256 _amount2
    ) public {
        address userAccount = msg.sender;
        pool.differLiquid(
            _differentToken,
            _amount1,
            _AsdToken,
            _amount2,
            userAccount,
            factoryAddress
        );
    }

    function poolLvup(address _Lptoken, uint256 _level) public {
        string memory lpName = SelfToken(_Lptoken).name();
        if (Strings.equal(lpName, "ARBLP")) {
            ArbpoolLv = _level;
            LvContents[ArbLpaddress].poolLv = _level;
        } else if (Strings.equal(lpName, "USDTLP")) {
            UsdtpoolLv = _level;
            LvContents[UsdtLpaddress].poolLv = _level;
        } else if (Strings.equal(lpName, "ETHLP")) {
            EthpoolLv = _level;
            LvContents[EthLpaddress].poolLv = _level;
        }
        IPair(pairAddress).poolLvManagement(_Lptoken, _level);
    }

    function tokenLvManagement(address _Lptoken, uint256 _level) public {
        string memory lpName = SelfToken(_Lptoken).name();
        if (Strings.equal(lpName, "ARBLP")) {
            ArbLpLv = _level;
            LvContents[ArbLpaddress].LptokenLv = _level;
        } else if (Strings.equal(lpName, "USDTLP")) {
            UsdtLpLv = _level;
            LvContents[UsdtLpaddress].LptokenLv = _level;
        } else if (Strings.equal(lpName, "ETHLP")) {
            EthLpLv = _level;
            LvContents[EthLpaddress].LptokenLv = _level;
        }
        IPair(pairAddress).LptokenLvManagement(_Lptoken, _level);
    }

    function withDrawLiquid(
        address _differLpToken,
        uint256 _amount,
        address _AsdToken
    ) public {
        address userAccount = msg.sender;
        pool.removeLiquid(
            _differLpToken,
            _amount,
            userAccount,
            factoryAddress,
            _AsdToken
        );
    }

    function LpStaking(
        address _differLptoken,
        uint256 _amount,
        uint256 month
    ) public {
        address userAccount = msg.sender;
        uint256 checkAmount = SelfToken(_differLptoken).balanceOf(userAccount);
        require(_amount <= checkAmount, "check the LpBalance");
        pool.differLpstaking(
            _differLptoken,
            userAccount,
            factoryAddress,
            _amount,
            month,
            VASDtokenAddress
        );
    }

    function withDrawStaking() public {
        address userAccount = msg.sender;
        pool.differLpWithdraw(userAccount, factoryAddress);
        backAmount = pool.firstAmount();
    }
}
