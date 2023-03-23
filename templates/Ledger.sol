// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;
contract Ledger{
    struct entry{
        address entity;
        uint amount;
        bool debit;
        uint dated;
    }
    entry[] public entries;
    address owner;

    constructor(){
        owner=msg.sender;
    }

    function addEntry(address _who, uint _amount, bool _isdebit) public returns (bool){
        require(msg.sender==owner);
        entries.push(entry(_who,_amount,_isdebit,block.timestamp));
        return true;
    }

    function viewLedger() public view returns (address[] memory,uint[] memory, bool[] memory,uint[] memory){
        address[] memory returnadd=new address[](entries.length);
        uint[] memory returnamt=new uint[](entries.length);
        bool[] memory returnis=new bool[](entries.length);
        uint[] memory returndate=new uint[](entries.length);
        for(uint i=0;i<entries.length;i++){
            returnadd[i]=entries[i].entity;
            returnamt[i]=entries[i].amount;
            returnis[i]=entries[i].debit;
            returndate[i]=entries[i].dated;
        }
        return(returnadd,returnamt,returnis,returndate);
    }

/////////////////
////////////////
address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(1,t,d,"truInfos/templates/ledger.json");
    return true;
}
}

interface EX{
    function getTruAt(uint index) external view returns(address);
}
interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}