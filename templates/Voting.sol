// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;
contract Voting{

address[] public voters;
mapping (address => bool) votes;
address public owner;
uint public started;
uint public time;
constructor(){
    owner=msg.sender;
}
function addVoter(address user) public returns (bool){
    require (msg.sender==owner);
    require (started==0);
    voters.push(user);
    return true;
}
function start(uint secs) public returns (bool){
    require(msg.sender==owner);
    require (started==0);
    started=block.timestamp;
    time=secs;
    return true;
}
function vote() public returns (bool){
    bool isVoter=false;
    for (uint i=0; i<voters.length;i++){
        if (voters[i]==msg.sender)
        isVoter=true;
    }
    require (isVoter);
    require(started+time <= block.timestamp);

    votes[msg.sender]=true;
    return true;
}
function getVotes() public view returns (uint){
    uint count;
    for (uint i=0; i<voters.length;i++)
    if(votes[voters[i]])
    count++;
    return count;
}

/////////////////
////////////////
address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(6,t,d,"truInfos/templates/voting.json");
    return true;
}
}

interface EX{
    function getTruAt(uint index) external view returns(address);
}
interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}

