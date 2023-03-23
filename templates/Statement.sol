// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;
contract Statement{
    address owner;
    string statement;
    uint signed;
    address addendum;

    constructor(){
        owner=msg.sender;
    }

    function issueStatement(string memory s) public returns(bool){
        require(msg.sender==owner);
        require(signed==0);
        string memory empty="";
        require(!compareStrings(s,empty));
        statement=s;
        return true;
    }

    function sign() public returns(bool){
        require(msg.sender==owner);
        require(signed==0);
        string memory empty="";
        require(!compareStrings(statement,empty));
        signed=block.timestamp;
        return true;
    }

    function issueAddendum(address _new) public returns (bool){
        require(msg.sender==owner);
        require(signed!=0);
        require(addendum==address(0));
        require(_new!=address(0));
        addendum=_new;
        return true;
    }

    function viewStatement() public view returns(address,string memory,uint,address){
        if(signed==0) return (address(0),"Un-initialized",0,address(0));
        return (owner,statement,signed,addendum);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

/////////////////
////////////////
address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(5,t,d,"truInfos/templates/statement.json");
    return true;
}
}

interface EX{
    function getTruAt(uint index) external view returns(address);
}
interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}