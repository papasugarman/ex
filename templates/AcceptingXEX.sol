// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface EX{
    function getTruAt(uint index) external view returns(address);
    function isXEX(address query) external view returns(bool);
}

interface XEX{
    function transfer(address recipient, uint amount) external returns (bool);
    function recycleAccount() external returns (bool);
}

contract AcceptingXEX{
    mapping (address => uint) public balances;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    address public owner;

    constructor(){
        owner=msg.sender;
    }

    function getUserBalance(address _query) public view returns(uint){
        return balances[_query];
    }

    function pingFromXEX(address user, uint amount) public returns (bool){
        //require(msg.sender==EX(EXBase).getTruAt(2));
        require(EX(EXBase).isXEX(msg.sender));
        balances[user]+=amount;
        return true;
    }

    function giveToOwner(uint amount) public returns (bool){
        require(msg.sender==owner);
        XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,amount);
        return true;
    }

    function finishAccount() public returns (bool){
        require(msg.sender==owner);
        XEX(EX(EXBase).getTruAt(2)).recycleAccount();
        return true;
    }


/////////////////
////////////////
//address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(0,t,d,"truInfos/templates/xexaccepting.json");
    return true;
}
}


interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}