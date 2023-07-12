// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SelfToken is ERC20 {
    address public tokenAddress;
    address public deployAddress;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) public tokenLevel;
    address[] private accounts;
    uint256 private accountsL;
    uint256 private totalSupply_;

    string private _name;
    string private _symbol;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        tokenAddress = address(this);
        deployAddress = address(this);
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        address owner = address(this);
        _transfer(owner, to, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        address owner = deployAddress;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(from, to, amount);
        _spendAllowance(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public override returns (bool) {
        address owner = deployAddress;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public override returns (bool) {
        address owner = deployAddress;
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function mint(uint256 _amount) external {
        _mint(deployAddress, (_amount * (10 ** 18)));
        approve(deployAddress, (_amount * (10 ** 18)));
        tokenLevel[deployAddress] = 1;
    }

    function Ethmint(uint256 _amount, uint256 _digicount) public {
        _mint(deployAddress, (_amount * (10 ** _digicount)));
        approve(deployAddress, (_amount * (10 ** _digicount)));
        tokenLevel[deployAddress];
    }

    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply_ += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function _burn(address account, uint256 amount) public override {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            totalSupply_ -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal override {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal override {
        uint256 currentAllowance = allowance(deployAddress, owner);
        uint256 currentAllowance2 = allowance(deployAddress, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(deployAddress, owner, currentAllowance - amount);
                _approve(deployAddress, spender, currentAllowance2 + amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        bool addressExists = false;
        for (uint256 i = 0; i < accountsL; i++) {
            if (accounts[i] == to) {
                addressExists = true;
                break;
            }
        }
        if (!addressExists) {
            accounts.push(to);
            accountsL++;
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {}

    function getAccounts() public view returns (address[] memory, uint256) {
        return (accounts, accountsL);
    }
}
