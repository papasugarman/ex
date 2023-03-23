// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;
contract Obituary{
    address owner;
    string title;
    string statement;
    string url;
    uint published;

    constructor(){
        owner=msg.sender;
    }

    function init(string memory t, string memory s, string memory u) public returns (bool){
        require(msg.sender==owner);
        string memory empty="";
        require(!compareStrings(t,empty));
        require(!compareStrings(s,empty));
        require(!compareStrings(u,empty));
        require(published==0);
        title=t;
        statement=s;
        url=u;
        return true;
    }

    function publish() public returns(bool){
        require(msg.sender==owner);
        string memory empty="";
        require(!compareStrings(title,empty));
        require(published==0);
        published=block.timestamp;
        return true;
    }

    function viewObituary() public view returns(address,string memory, string memory,string memory,uint){
        if(published==0) return(address(0),"Un-Initialized","","",0);
        return (owner,title,statement,url,published);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

/////////////////
////////////////
address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(5,t,d,"truInfos/templates/obituary.json");
    return true;
}
}

interface EX{
    function getTruAt(uint index) external view returns(address);
}
interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}