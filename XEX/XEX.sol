// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;

import "./Coin.sol";

contract XEX is Coin {
    string public name = "EXCoin";
    string public symbol = "XEX";
    uint public decimals = 3;

    function updateDecimals(uint _new) public returns (bool){
        require (EX(EXBase).isMandated(msg.sender));
        decimals=_new;
        return true;
    }

     function mint(address user, uint amount) public returns(bool) {
        require (EX(EXBase).isMandated(msg.sender) || msg.sender==EX(EXBase).getTruAt(5));
        return Mint(user,amount);
     }

    function mine(uint amount) public returns (bool){
        require (EX(EXBase).isMandated(msg.sender));
        address user=EX(EXBase).getAccAt(0); //goes to admin
        if (amount>=pot_recycling){
        uint tomake=amount-pot_recycling;
        balanceOf[user]+=amount; 
        totalSupply+=tomake;
        balanceOf[address(this)]-=pot_recycling;
        pot_recycling=0;
        }
        else{
        balanceOf[user]+=amount; 
        totalSupply+=amount;
        }
        emit Transfer(address(this), user, amount);
        return true;
    }

    function recycle(uint amount) public returns(bool) {
        require (amount>0);
        require (balanceOf[msg.sender]-amount>=accountFee);
        require (amount<=balanceOf[msg.sender]);
        balanceOf[msg.sender] -= amount;
        balanceOf[address(this)] += amount;
        pot_recycling+=amount;
        emit Transfer(msg.sender, address(this), amount);
        return true;
    }

    function recycleAccount() public returns (bool){
        require(balanceOf[msg.sender]==accountFee);
        balanceOf[msg.sender]=0;
        firstSeen[msg.sender]=0;
        balanceOf[address(this)]+=accountFee;
        pot_recycling+=accountFee;
        emit Transfer(msg.sender, address(this), accountFee);
        return true;
    }
}