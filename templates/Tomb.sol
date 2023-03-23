// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;
contract Tomb{
    string title;
    string description;
    string salutation;
    address owner;
    struct visit{
        address user;
        uint dated;
    }
    visit[] public visits;

    constructor(){
        owner=msg.sender;
    }

    function init(string memory t, string memory d, string memory s) public returns (bool){
        require(msg.sender==owner);
        string memory empty="";
        require(!compareStrings(t,empty));
        require(compareStrings(title,empty));
        title=t;
        description=d;
        salutation=s;
        return true;
    }

    function attend() public returns (bool){
        string memory empty="";
        require(!compareStrings(title,empty));

        for (uint i=0;i<visits.length;i++)
        if (visits[i].user==msg.sender)
        require (visits[i].dated+10 minutes < block.timestamp);

        visits.push(visit(msg.sender,block.timestamp));
        return true;
    }

    function viewTomb() public view returns(string memory,address[] memory, uint[] memory){
        address[] memory returnadd=new address[](visits.length);
        uint[] memory returndate=new uint[](visits.length);
        for(uint i=0;i<visits.length;i++){
            returnadd[i]=visits[i].user;
            returndate[i]=visits[i].dated;
        }

        return (salutation,returnadd,returndate);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
/////////////////
////////////////
address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(5,t,d,"truInfos/templates/tomb.json");
    return true;
}
}

interface EX{
    function getTruAt(uint index) external view returns(address);
}
interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}