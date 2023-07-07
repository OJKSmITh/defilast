# hardhat version

```js
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      forking: {
        url: "https://klaytn.blockpi.network/v1/rpc/public",
      },
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        accountsBalance: "10000000000000000000000000", // 10,000,000 KLAY
      },
      blockGasLimit: 30000000,
    },
    baobab: {
      url: "https://api.baobab.klaytn.net:8651",
      chainId: 1001,
      accounts: require("./accounts.json").privateKey,
      gas: 20000000,
      gasPrice: 250000000000,
    },
    abitrum: {
      url: "https://endpoints.omniatech.io/v1/arbitrum/goerli/public",
      chainId: 421613,
      accounts: require("./accounts.json").privateKey,
      gas: 20000000,
      gasPrice: 25000000000,
    },
  },
};
```

# remixd 설치

```sh
npm install @remix-project/remixd
remixd -s . --remix-ide https://remix.ethereum.org
```

# openzeppelin/contracts 설치

```sh
npm install @openzeppelin/contracts
```

# chainlink address / decimal 10^8

eth/usd : 0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08
usdt /usd : 0x0a023a3423D9b27A0BE48c768CCF2dD7877fEf5E
arb / usd : 0x2eE9BFB2D319B31A573EA15774B755715988E99D
이렇게 총 세개임

# 상태변수 읽어오기

상태변수가 선언되어있으면 자동적으로 getter함수가 생김 하지만 constructor가 생겨야 하기떄문에

await를 써서 가져와야 함

# CA 주소들(1버전)

ASD token 주소 : 0x3136B924058Da7127f83C76Ea512576CB5a9fDBa
ARB token 주소 : 0x66E7fE6Ca7B1D2A3Bbd321160a6adA649d568F1e
VASD token 주소 : 0x1A4C3758EF080bC5F04122e950cB1b138155e387
Pool 주소: 0xDc04625769FC5Ee454804BE3271B9fe0F13bd2db
gover 주소 : 0x2905462d901930ef98f7BdA835602086Aff97612

# account

1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
2: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

# proxy 용 코드

```js
 function initialize(address _feeRecipient, uint _feePercentage) public {
        owner = msg.sender;
        contractAddress = address(this);
        feeRecipient = _feeRecipients;
        feePercentage = _feePercentage;
    }
```

da
0.03\* 100000000

3000000

# 토큰 개수

1000000000000000000 -> 1 토큰
100000000000000000000 -> 10 토큰
1000000000

# 팩토리 코드

```js
function ArbAsdPool_1(
    address _Arbtoken,
    uint256 _Arbamount,
    address _Asdtoken,
    uint256 _Asdamount
) public {}
    require(
        _Arbamount >= 1 && _Asdamount >= _Arbamount * ArbSwapPercent,
        "Please set the minimum proportion"
    );
    require(pool.ARBPoolLevel() == 1, "check the pool level");
    pool.ARBLpPool();
    address userAccount = msg.sender;
    pool.ArbAsdStaking(
        _Arbtoken,
        _Arbamount,
        _Asdtoken,
        _Asdamount,
        userAccount,
        contractAddress
    );
    ARBLpaddress = pool.ARBLpaddress();
    Accounts[userAccount][ARBLpaddress][_Arbtoken] += _Arbamount;
    Accounts[userAccount][ARBLpaddress][_Asdtoken] += _Asdamount;
    uint256 calcLp = calclending(
        _Arbtoken,
        Accounts[userAccount][ARBLpaddress][_Arbtoken],
        _Asdtoken,
        Accounts[userAccount][ARBLpaddress][_Asdtoken]
    );
    Lpcalc[ARBLpaddress][_Arbtoken] += _Arbamount;
    Lpcalc[ARBLpaddress][_Asdtoken] += _Asdamount;
    pool.ARBLpReward(userAccount, calcLp);
    totalLpAmount += calcLp;
}

function ArbAsdPool_2(
    address _Arbtoken,
    uint256 _Arbamount,
    address _Asdtoken,
    uint256 _Asdamount
) public {
    require(
        _Arbamount >= 1 && _Asdamount >= _Arbamount * ArbSwapPercent,
        "Please set the minimum proportion"
    );
    require(pool.ARBPoolLevel() == 2, "check the pool level");
    pool.ARBLpPool();
    address userAccount = msg.sender;
    pool.ArbAsdStaking(
        _Arbtoken,
        _Arbamount,
        _Asdtoken,
        _Asdamount,
        userAccount,
        contractAddress
    );
    Accounts[userAccount][ARBLpaddress][_Arbtoken] += _Arbamount;
    Accounts[userAccount][ARBLpaddress][_Asdtoken] += _Asdamount;
    uint256 calcLp = calclending(
        _Arbtoken,
        Accounts[userAccount][ARBLpaddress][_Arbtoken],
        _Asdtoken,
        Accounts[userAccount][ARBLpaddress][_Asdtoken]
    );
    Lpcalc[ARBLpaddress][_Arbtoken] += _Arbamount;
    Lpcalc[ARBLpaddress][_Asdtoken] += _Asdamount;
    pool.ARBLpReward(userAccount, calcLp);
    SelfToken(_Asdtoken).mint(83000);
    uint256 rewardPercent = ((SelfToken(_Asdtoken).balanceOf(userAccount) *
        decimals) / SelfToken(_Asdtoken).totalSupply()) / decimals;
    uint256 rewardToken = (83000 * rewardPercent) / 100;
    SelfToken(_Asdtoken).transfer(userAccount, rewardToken);
    totalLpAmount += calcLp;
}

function ArbAsdPool_3(
    address _Arbtoken,
    uint256 _Arbamount,
    address _Asdtoken,
    uint256 _Asdamount
) public {
    require(
        _Arbamount >= 1 && _Asdamount >= _Arbamount * ArbSwapPercent,
        "Please set the minimum proportion"
    );
    require(pool.ARBPoolLevel() == 3, "check the pool level");
    pool.ARBLpPool();
    address userAccount = msg.sender;
    pool.ArbAsdStaking(
        _Arbtoken,
        _Arbamount,
        _Asdtoken,
        _Asdamount,
        userAccount,
        contractAddress
    );
    Accounts[userAccount][ARBLpaddress][_Arbtoken] += _Arbamount;
    Accounts[userAccount][ARBLpaddress][_Asdtoken] += _Asdamount;
    uint256 calcLp = calclending(
        _Arbtoken,
        Accounts[userAccount][ARBLpaddress][_Arbtoken],
        _Asdtoken,
        Accounts[userAccount][ARBLpaddress][_Asdtoken]
    );
    Lpcalc[ARBLpaddress][_Arbtoken] += _Arbamount;
    Lpcalc[ARBLpaddress][_Asdtoken] += _Asdamount;
    pool.ARBLpReward(userAccount, calcLp);
    uint VASDAmount = SelfToken(ARBLpaddress).balanceOf(msg.sender);
    VASDtoken.mint(VASDAmount);
    VASDtoken.transfer(userAccount, VASDAmount);
    totalLpAmount += calcLp;
}

function withdrawArbLp(
    address _Lptoken,
    address _Arbtoken,
    address _Asdtoken,
    uint256 _amount
) public {
    require(_Lptoken == ARBLpaddress, "please send correct token");
    require(
        SelfToken(_Lptoken).totalSupply() >= _amount,
        "insufficient lp amount"
    );
    address userAccount = msg.sender;
    uint256 lpcalcparams = _amount * decimals;
    uint256 lpcalcpercent = lpcalcparams / totalLpAmount;
    uint256 withdrawArb1 = (Lpcalc[_Lptoken][_Arbtoken] * lpcalcpercent) /
        decimals;
    uint256 withdrawAsd2 = (Lpcalc[_Lptoken][_Asdtoken] * lpcalcpercent) /
        decimals;
    SelfToken(ARBLpaddress).transferFrom(
        userAccount,
        address(this),
        _amount
    );
    SelfToken(ARBLpaddress)._burn(address(this), _amount);
    SelfToken(_Arbtoken).transferFrom(
        userAccount,
        msg.sender,
        withdrawArb1
    );
    SelfToken(_Asdtoken).transferFrom(
        userAccount,
        msg.sender,
        withdrawAsd2
    );
}

function calclending(
    address _token1,
    uint256 amount1,
    address _token2,
    uint256 amount2
) public returns (uint) {
    if (
        SelfToken(_token1).balanceOf(address(this)) > 0 &&
        SelfToken(_token2).balanceOf(address(this)) > 0
    ) {
        previousLp = (SelfToken(_token1).balanceOf(address(this)) *
            SelfToken(_token2).balanceOf(address(this))).sqrt();
    }
    uint totalAmount = (SelfToken(_token1).balanceOf(address(this)) +
        amount1) * (SelfToken(_token2).balanceOf(address(this)) + amount2);
    uint totallpAmount = totalAmount.sqrt() - previousLp;
    return totallpAmount;
}

function ARBstake(uint256 month) external {
    uint256 userLpBalance = SelfToken(ARBLpaddress).balanceOf(msg.sender);
    if (month == 4) {
        ARBstakeLp(month, userLpBalance);
        stakeVASD(userLpBalance);
    } else if (month == 8) {
        ARBstakeLp(month, userLpBalance);
        stakeVASD(2 * userLpBalance);
    } else if (month == 12) {
        ARBstakeLp(month, userLpBalance);
        stakeVASD(4 * userLpBalance);
    } else {
        revert("wrong month");
    }
}

function ARBstakeLp(uint256 _month, uint256 _amount) internal {
    require(_amount > 0, "cannot stake 0Lp tokens");
    address userAccount = msg.sender;
    SelfToken(ARBLpaddress).approve(userAccount, _amount);
    SelfToken(ARBLpaddress).transferFrom(
        userAccount,
        address(this),
        _amount
    );
    uint256 currentStakeId = stakePid;
    stakeInfo[_month][msg.sender][currentStakeId].amount = _amount;
    stakeInfo[_month][msg.sender][currentStakeId].stakedTime = block
        .timestamp;
    stakeInfo[_month][msg.sender][currentStakeId].isWithdrawable = false;
    stakePid += 1;
}

function stakeVASD(uint256 _amount) internal {
    require(_amount > 0, "cannot stake 0Lp tokens");
    address userAccount = msg.sender;
    VASDtoken.mint(_amount);
    VASDtoken.approve(userAccount, _amount);
    VASDtoken.transferFrom(VASDAddress, userAccount, _amount);
}

function WithdrawChange(
    uint256 _month,
    uint256 _index
) external returns (bool) {
    if (
        _month == 4 &&
        block.timestamp > stakeInfo[4][msg.sender][_index].stakedTime + 5
        // stakeInfo[4][msg.sender][_index].stakedTime + one_month
    ) {
        stakeInfo[4][msg.sender][_index].isWithdrawable = true;
    }
    if (
        _month == 8 &&
        block.timestamp > stakeInfo[8][msg.sender][_index].stakedTime + 5
        // stakeInfo[8][msg.sender][_index].stakedTime + four_month
    ) {
        stakeInfo[8][msg.sender][_index].isWithdrawable = true;
    }
    if (
        _month == 12 &&
        block.timestamp > stakeInfo[12][msg.sender][_index].stakedTime + 5
        // stakeInfo[12][msg.sender][_index].stakedTime + one_month
    ) {
        stakeInfo[12][msg.sender][_index].isWithdrawable = true;
    }
    return stakeInfo[_month][msg.sender][_index].isWithdrawable;
}

function ARBwithDraw(uint256 _month, uint256 _index) public {
    require(
        stakeInfo[_month][msg.sender][_index].isWithdrawable,
        "not yet"
    );
    uint256 withDrawAmount = stakeInfo[_month][msg.sender][_index].amount;
    SelfToken(ARBLpaddress).transferFrom(
        address(this),
        msg.sender,
        withDrawAmount
    );
    uint256 userVASDAmount = VASDtoken.balanceOf(msg.sender);
    VASDtoken.transferFrom(msg.sender, address(this), userVASDAmount);
    VASDtoken._burn(address(this), userVASDAmount);
}

function proposalLvcheck(address _token, uint256 _level) external {
    if (_token == pool.ARBLpaddress()) {
        pool.ARBpoolLv(_level);
    }
    if (_token == pool.ETHLpaddress()) {
        pool.ETHpoolLv(_level);
    }
    if (_token == pool.USDTLpaddress()) {
        pool.USDTpoolLv(_level);
    }
}

function whatLpcheck(address _lptoken) public view returns (uint) {
    address userAccount = msg.sender;
    return SelfToken(_lptoken).balanceOf(userAccount);
}

function whatLpPoolCheck(address _lptoken) public view returns (uint) {
    return SelfToken(_lptoken).totalSupply();
}

function whoVasdPoolCheck(address _account) public view returns (uint) {
    return VASDtoken.balanceOf(_account);
}

function vasdPoolCheck() public view returns (uint) {
    return VASDtoken.totalSupply();
}
```

```js
import "@openzeppelin/contracts/utils/Strings.sol";
if (Strings.equal(name, "ETH")) price = getEthPrice();
else if (Strings.equal(name, "USDT")) price = getUsdtPrice();
else if (Strings.equal(name, "ARB")) price = getArbPrice();
```

```js
receive() external payable {
        require(ETHtokenAddress != address(0), "check the token maked");
        SelfToken(ETHtokenAddress).mint(msg.value);
        SelfToken(ETHtokenAddress).transferFrom(
            ETHtokenAddress,
            msg.sender,
            msg.value
        );
    }
```

```js
  function AsdSwap(
        address tokenA,
        address tokenB,
        address _userAccount,
        address _contractAddress,
        uint256 amountA
    ) public {
        uint256 amountB;
        uint256 feeAmount;
        uint256 amountToSwap;
        uint256 swapPercent;
        if (
            keccak256(bytes(SelfToken(tokenB).name())) ==
            keccak256(bytes("ARB"))
        ) {
            swapPercent = ArbSwapPercent;
        } else if (
            keccak256(bytes(SelfToken(tokenB).name())) ==
            keccak256(bytes("USDT"))
        ) {
            swapPercent = UsdtSwapPercent;
        } else if (
            keccak256(bytes(SelfToken(tokenB).name())) ==
            keccak256(bytes("ETH"))
        ) {
            swapPercent = EthSwapPercent;
        } else {
            revert("Unsupported token");
        }
        (feeAmount, amountToSwap) = calculateFeesAndAmountToSwap(amountA);

        amountB = calculateAmountASD(amountToSwap, swapPercent);
        conductTransfer(
            tokenA,
            tokenB,
            _userAccount,
            _contractAddress,
            amountA,
            amountB,
            feeAmount,
            amountToSwap
        );
    }
```

```js
function calculateAmountASD(
        uint256 _amountToSwap,
        uint256 _swapPercent
    ) public pure returns (uint256) {
        return _amountToSwap / _swapPercent;
    }
```
