// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LockToken is ERC20, ERC20Burnable, Pausable, Ownable{

    struct UserInfo {
        uint lockedAmount;
        uint unlockBlockNumber;
    }

    mapping (address => mapping (address => uint256)) private _allowance;
    mapping( address => UserInfo[]) lockedBalance;

    constructor() ERC20("LockToken", "LTK") {}

    modifier isUnlocked(address user, uint amount){
        uint lockedFunds;
        UserInfo[] memory array = lockedBalance[user];

        for(uint funds = 0; funds < array.length; funds++){
            if(array[funds].unlockBlockNumber > block.number){
            lockedFunds+= array[funds].lockedAmount;
        }
        }

        uint unlockedBalance = balanceOf(user) - lockedFunds;
        require(unlockedBalance >= amount, "User does not have enough unlocked balance!");
        _;
    }

    function getUnlockedAmount(address user) public view  returns(uint) {
        uint lockedFunds;
        UserInfo[] memory array = lockedBalance[user];
        uint unlockedAmount;

        for(uint i =0; i < array.length; i++){
            if(array[i].unlockBlockNumber > block.number){
            lockedFunds+= array[i].lockedAmount;
            }
        }
        unlockedAmount = balanceOf(user) - lockedFunds;
        return unlockedAmount;
    }

    function lock(uint amount, uint unlockBlockNumber) public {
        uint userUnlockedAmount = getUnlockedAmount(msg.sender);
        require(userUnlockedAmount >= amount, "User does not have enough funds to lock this amount");
        require(unlockBlockNumber > block.number, "unlockBlockNumber has to be greater than the current blockNumber");
        UserInfo memory lockUserInfo;
        lockUserInfo.lockedAmount = amount;
        lockUserInfo.unlockBlockNumber = unlockBlockNumber;
        lockedBalance[msg.sender].push(lockUserInfo);
    }


    function burn(address account, uint256 amount) public isUnlocked(msg.sender, amount) {
        _burn(account, amount);
    }

    function transfer( address from, address to, uint256 amount) public isUnlocked(msg.sender, amount) {
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
    ) public virtual override isUnlocked(msg.sender, amount) returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

}