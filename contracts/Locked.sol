// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LockToken is ERC20, ERC20Burnable, Pausable, Ownable{

    struct UserInfo {
        uint lockedAmount;
        uint lockBlockNumber;
    }
    mapping( address => UserInfo[]) lockedBalance;

    constructor() ERC20("MyToken", "MTK") {}

    modifier isUnlocked(address from, address to, uint amount){
        uint lockedFunds;
        UserInfo[] array = lockedBalance[from];

        // loop through the array that contains the user info and add the funds to the variable 
        for(uint funds = 0; funds < array.length; funds++){
            if(block.number)
            lockedFunds+= array[funds].lockedAmount;
        }

        uint unlockedBalance = address(this).balance - lockedFunds;
        require(unlockedBalance >= amount, "User does not have enough unlocked balance!");
        _;
    }

    function getUnlockedAmount() public view returns(uint) {
        return 17;
    }


    function burn(address account, uint256 amount) public isUnlocked {
        _burn(account, amount);
    }

    function trasnfer( address from, address to, uint256 amount) public isUnlocked {
        _transfer(from, to, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }


    function allowance( address owner, address spender) public view virtual override returns(uint256){
        return _allowance[owner][spender];
    }

      function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override isUnlocked(from, to, amount) returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

}