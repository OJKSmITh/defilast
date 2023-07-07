// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SelfMath.sol";
import "./SelfToken.sol";

contract Airdrop {
    using SelfMath for uint;
    address owner;
    address factory;
    address myaddress;

    constructor(address _owner, address _factory){
        owner = _owner;
        factory = _factory;
        myaddress = address(this);
    }

    function div (uint256 x, uint256 y)public pure returns(uint256){
      require(y != 0);
      uint256 c = x * 10 ** 18/y;
      return uint256(c);
    }

    function doAirdrop(address[] memory _accounts, address _droptoken, address _lptoken)public {
        // require(msg.sender == owner, "only Gov");
        require(SelfToken(_droptoken).balanceOf(_droptoken) > 0);
        require(SelfToken(_droptoken).allowance(_droptoken, myaddress) != 0);
        // require(Factory_v1(factory).getTokenlevel())
        uint256 _lpTotalAmount = SelfToken(_lptoken).totalSupply();
        uint256 _dropTotalAmount = SelfToken(_droptoken).totalSupply();
        uint256 count = _accounts.length;

        for (uint256 i = 0; i < count; i++) {
            uint256 _balance = SelfToken(_lptoken).balanceOf(_accounts[i]);
            SelfToken(_droptoken).transferFrom(_droptoken , _accounts[i], 
            (_dropTotalAmount * div(_balance, _lpTotalAmount))/10**18);               
        }
    }
    
    function getToken(address _token)public view returns(uint256){
        return SelfToken(_token).balanceOf(address(this));
    }

    function deployaddress()public view returns(address){
      return address(this);
    }
}
