// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;
contract Membership{
    address owner;
    address[] members;

    constructor(){
        owner=msg.sender;
    }

    function addMember(address user) public returns (bool){
        require(msg.sender==owner);
        for(uint i=0;i<members.length;i++)
        if(members[i]==user)
        require(0!=0);
        members.push(user);
        return true;
    }
    
    function delMember(address user) public returns (bool){
        require(msg.sender==owner);
        for(uint i=0;i<members.length;i++)
        if(members[i]==user){
        removeFromArray(i);
        break;
        }
        return true;
    }

    function isMember(address user) public view returns(bool){
        for(uint i=0;i<members.length;i++)
        if(members[i]==user)
        return true;

        return false;
    }

    function listMembers() public view returns (address[] memory){
        address[] memory toreturn = new address[](members.length);
        toreturn=members;
        return toreturn;
    }

    function removeFromArray(uint index) internal {
        if (index >= members.length) return;

        for (uint i = index; i<members.length-1; i++){
            members[i] = members[i+1];
        }
        members.pop();
    }

/////////////////
////////////////
address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(3,t,d,"truInfos/templates/membership.json");
    return true;
}
}

interface EX{
    function getTruAt(uint index) external view returns(address);
}
interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}