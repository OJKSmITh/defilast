// SPDX-License-Identifier: MIT

import "./SelfToken.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.9;

contract Pair {
    SelfToken ArbLpToken;
    SelfToken UsdtLpToken;
    SelfToken EthLpToken;
    address public ArbLpaddress;
    address public UsdtLpaddress;
    address public EthLpaddress;
    uint256 private ArbpoolLv = 1;
    uint256 private UsdtpoolLv = 1;
    uint256 private EthpoolLv = 1;
    uint256 private ArbLpLv = 1;
    uint256 private UsdtLpLv = 1;
    uint256 private EthLpLv = 1;
    address public ETHtokenAddress;
    string public name1;
    struct CheckToken {
        address token1;
        address token2;
    }

    /**
    @dev lp pool용 mapping데이터들 
     */
    mapping(address => mapping(uint256 => CheckToken)) public poolData;
    uint[] public poolDataNum;
    uint public poolIndex;

    constructor() {}

    function makeLpPool(
        address _token1,
        address _token2,
        address _contractAddress
    ) external {
        bool isExists = false;

        for (uint i = 0; i < poolDataNum.length; i++) {
            CheckToken memory existingPool = poolData[_contractAddress][i];

            if (
                (existingPool.token1 == _token1 &&
                    existingPool.token2 == _token2) ||
                (existingPool.token1 == _token2 &&
                    existingPool.token2 == _token1)
            ) {
                isExists = true;
                break;
            }
        }
        require(!isExists, "The pool already exists.");
        if (!isExists) {
            CheckToken memory newPool = CheckToken(_token1, _token2);
            name1 = SelfToken(_token1).name();
            poolData[_contractAddress][poolIndex] = newPool;
            poolDataNum.push(poolIndex);
            poolIndex += 1;
            if (Strings.equal(name1, "ARB")) {
                ArbLpToken = new SelfToken("ARBLP", "LP");
                ArbLpaddress = address(ArbLpToken);
                // ARBtokenAddress = _token1;
            } else if (Strings.equal(name1, "USDT")) {
                UsdtLpToken = new SelfToken("USDTLP", "LP");
                UsdtLpaddress = address(UsdtLpToken);
                // USDTtokenAddress = _token1;
            } else if (Strings.equal(name1, "ETH")) {
                EthLpToken = new SelfToken("ETHLP", "LP");
                EthLpaddress = address(EthLpToken);
                ETHtokenAddress = _token1;
            }
        }
    }

    function getLpAddress()
        public
        view
        returns (address arblp, address usdtlp, address ethlp)
    {
        return (ArbLpaddress, UsdtLpaddress, EthLpaddress);
    }

    function getLpLv()
        public
        view
        returns (
            uint256 _ArbpoolLv,
            uint256 _ArbLpLv,
            uint256 _UsdtpoolLv,
            uint256 _UsdtLpLv,
            uint256 _EthpoolLv,
            uint256 _EthLpLv
        )
    {
        return (ArbpoolLv, ArbLpLv, UsdtpoolLv, UsdtLpLv, EthpoolLv, EthLpLv);
    }

    function poolLvManagement(address _lptoken, uint256 _level) public {
        string memory lpName = SelfToken(_lptoken).name();
        if (Strings.equal(lpName, "ARBLP")) {
            ArbpoolLv = _level;
        } else if (Strings.equal(lpName, "USDTLP")) {
            UsdtpoolLv = _level;
        } else if (Strings.equal(lpName, "ETHLP")) {
            EthpoolLv = _level;
        }
    }

    function LptokenLvManagement(address _lptoken, uint256 _level) public {
        string memory lpName = SelfToken(_lptoken).name();
        if (Strings.equal(lpName, "ARBLP")) {
            ArbLpLv = _level;
        } else if (Strings.equal(lpName, "USDTLP")) {
            UsdtLpLv = _level;
        } else if (Strings.equal(lpName, "ETHLP")) {
            EthLpLv = _level;
        }
    }
}
