// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;

interface EX{
    function getTruAt(uint index) external view returns(address);
    function isXEX(address query) external view returns(bool);
}

interface XEX{
    function transfer(address recipient, uint amount) external returns (bool);
    function recycleAccount() external returns (bool);
}

contract TrippleIt{
    mapping (address => uint) public balances;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    address public owner;

    constructor(){
        owner=msg.sender;
        submitOracle("Tripple it!","Game of luck. Tripple your play or lose it. 33% chance to win");
    }

    function getUserBalance(address _query) public view returns(uint){
        return balances[_query];
    }

    function getMyBalance() public view returns(uint){
        return balances[msg.sender];
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

    mapping(address => uint) lastPlay;

    function play(uint amount) public returns (bool){
        require(amount!=0 && amount<=balances[msg.sender]);
        balances[msg.sender]-=amount;
        uint rand=random();
        rand=rand%100;
        if(rand<33){
            balances[msg.sender]+=amount*3;
        }
        lastPlay[msg.sender]=rand;
        return true;
    }
    function getResult() public view returns(uint){
        return lastPlay[msg.sender];
    }

    function withdraw(uint amount) public returns(bool){
        require(amount!=0 && amount<=balances[msg.sender]);
        balances[msg.sender]-=amount;
        XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,amount);
        return true;
    }

    uint counter=0;
    function random() private returns (uint) {
        counter++;
        return uint(keccak256(abi.encodePacked(tx.origin,block.number,block.timestamp,counter)));
    } 

/////////////////
////////////////
//address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) internal returns (bool){
    //require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(7,t,d,"truInfos/others/tripple.json");
    return true;
}
}


interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}