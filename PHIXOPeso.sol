// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.0;

/**
 * @title PHIXO Peso Token (ERC-20, minimal)
 * @author PhixoR13
 * @notice This work is licensed under Creative Commons Attribution 4.0 International License
 * @dev Minimal ERC-20 compatible token with a ceremonial USD conversion helper.
 */
contract PHIXOPeso {
    string public name = "PHIXO Peso";
    string public symbol = "₱";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        _balances[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    // ERC-20: balanceOf
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // ERC-20: transfer
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    // ERC-20: allowance
    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    // ERC-20: approve
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // ERC-20: transferFrom
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _allowances[from][msg.sender] = currentAllowance - amount;
        _transfer(from, to, amount);
        emit Approval(from, msg.sender, _allowances[from][msg.sender]);
        return true;
    }

    // Optional helpers: increase/decrease allowance
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "ERC20: increaseAllowance to the zero address");
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "ERC20: decreaseAllowance to the zero address");
        uint256 current = _allowances[msg.sender][spender];
        require(current >= subtractedValue, "ERC20: decreased allowance below zero");
        _allowances[msg.sender][spender] = current - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // Internal transfer with zero-address and balance checks
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[from] >= amount, "Saldo insuficiente");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    // Owner-only mint and burn (optional management)
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "ERC20: mint to the zero address");
        uint256 amt = amount * (10 ** uint256(decimals));
        totalSupply += amt;
        _balances[to] += amt;
        emit Transfer(address(0), to, amt);
    }

    function burn(uint256 amount) public {
        uint256 amt = amount * (10 ** uint256(decimals));
        require(_balances[msg.sender] >= amt, "ERC20: burn amount exceeds balance");
        _balances[msg.sender] -= amt;
        totalSupply -= amt;
        emit Transfer(msg.sender, address(0), amt);
    }

    // Ceremonial helper: convertir USD a PHIXO (pure view)
    // NOTE: this is a helper, not an oracle; keep amounts manageable to avoid overflow
    function convertUSDToPHIXO(uint256 usdAmount) public pure returns (uint256) {
        // 1 ₱ = 9,000,000 USD as ceremonial rate (documented)
        return usdAmount * 9_000_000;
    }

    // Allow owner to transfer ownership if desired
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
    }
}