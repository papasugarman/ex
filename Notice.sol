// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;

interface EX{
    function getAccAt(uint index) external view returns(address);
}

contract Notice{
    struct notice{
        uint noticetype;
        string description;
    }
    mapping (address => notice) public notices;
    string[] public noticetypes;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;

    constructor(){
        noticetypes.push("TruCode creating a new TruCode");
    }

    function readNotice(address query) public view returns (uint, string memory){
        return(notices[query].noticetype,notices[query].description);
    }
    function getNoticeType(uint query) public view returns (string memory){
        return noticetypes[query];
    }

    function issueNotice(address _user, uint _type, string memory _desc) public returns (bool){
        require(EX(EXBase).getAccAt(0)==msg.sender || EX(EXBase).getAccAt(6)==msg.sender); //admin
        notices[_user]=notice(_type, _desc);
        return true;
    }
    function insertNType(string memory _ntype) public returns (bool){
        require(EX(EXBase).getAccAt(0)==msg.sender || EX(EXBase).getAccAt(6)==msg.sender); //admin
        noticetypes.push(_ntype);
        return true;
    }

}