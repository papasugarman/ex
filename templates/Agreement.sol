// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;
contract Agreement{
    address public party0;
    address public party1;
    string[] public paras;
    uint public dated0;
    uint public dated1;

    constructor(){
        party0=msg.sender;
    }

    function addParty(address user) public returns (bool){
        require(msg.sender==party0);
        require(party1==address(0));
        party1=user;
        return true;
    }

    function addPara(string memory para) public returns (bool){
        require(msg.sender==party0 || msg.sender==party1);
        require(dated0==0 && dated1==0);
        paras.push(para);
        return true;
    }

    function sign() public returns (bool){
        require(
            (msg.sender==party0 && dated0==0)
            ||
            (msg.sender==party1 && dated1==0)
        );

        if(msg.sender==party0) dated0=block.timestamp;
        if(msg.sender==party1) dated1=block.timestamp;
        return true;
    }

    function getInfo() public view returns (address[] memory, string[] memory, uint[] memory,bool){
        address[] memory parties=new address[](2);
        string[] memory ps=new string[](paras.length);
        uint[] memory dates= new uint[](2);
        bool status=false;

        parties[0]=party0;
        parties[1]=party1;
        dates[0]=dated0;
        dates[1]=dated1;
        ps=paras;
        if(dated0!=0 && dated1!=0)
        status=true;

        return(parties,ps,dates,status);
    }
/////////////////
////////////////
address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==party0);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(6,t,d,"truInfos/templates/agreement.json");
    return true;
}
}

interface EX{
    function getTruAt(uint index) external view returns(address);
}
interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}