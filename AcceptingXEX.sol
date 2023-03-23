// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface EX{
    function getTruAt(uint index) external view returns(address);
}

interface XEX{
    function transfer(address recipient, uint amount) external returns (bool);
    function recycleAccount() external returns (bool);
}

contract AcceptingXEX{
    mapping (address => uint) public balances;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    address public papa;

    constructor(){
        papa=msg.sender;
    }

    function getUserBalance(address _query) public view returns(uint){
        return balances[_query];
    }

    function pingFromXEX(address user, uint amount) public returns (bool){
        require(msg.sender==EX(EXBase).getTruAt(2));
        balances[user]+=amount;
        return true;
    }

    function giveToPapa(uint amount) public returns (bool){
        require(msg.sender==papa);
        XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,amount);
        return true;
    }

    function finishAccount() public returns (bool){
        require(msg.sender==papa);
        XEX(EX(EXBase).getTruAt(2)).recycleAccount();
        return true;
    }

}