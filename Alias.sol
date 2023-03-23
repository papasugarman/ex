// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;

interface EX{
    function getAccAt(uint index) external view returns(address);
    function getTruAt(uint index) external view returns(address);
}

contract Alias{
    string[] aliases;
    address[] users;
    bool[] blacklisted;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;

    constructor(){
        aliases.push("admin"); users.push(EX(EXBase).getAccAt(0)); blacklisted.push(false);
        aliases.push("base"); users.push(EX(EXBase).getTruAt(0)); blacklisted.push(false);
        aliases.push("mandate"); users.push(EX(EXBase).getTruAt(1)); blacklisted.push(false);
        aliases.push("xex"); users.push(EX(EXBase).getTruAt(2)); blacklisted.push(false);
        aliases.push("payment"); users.push(EX(EXBase).getTruAt(3)); blacklisted.push(false);
        aliases.push("oracle"); users.push(EX(EXBase).getTruAt(4)); blacklisted.push(false);
        aliases.push("vend"); users.push(EX(EXBase).getTruAt(5)); blacklisted.push(false);
        aliases.push("notice"); users.push(EX(EXBase).getTruAt(6)); blacklisted.push(false);
        aliases.push("alias"); users.push(EX(EXBase).getTruAt(7)); blacklisted.push(false);
    }

    function isUsed(string memory _name) public view returns (bool){
        for (uint i=0;i<aliases.length;i++)
        if(compareStrings(aliases[i],_name))
        return true;

        return false;
    }

    function set(string memory _name) public returns(bool){
        require(chkAlias(_name));
        require (bytes(_name).length>=3 && bytes(_name).length<=20);
        for (uint i=0; i<aliases.length; i++)
        if(compareStrings(aliases[i],_name))
        require(0!=0);
        for (uint j=0; j<users.length;j++)
        if(users[j]==msg.sender)
        require(0!=0);

        aliases.push(_name);
        users.push(msg.sender);
        blacklisted.push(false);
        return true;
    }

    function setTru(uint nonce, string memory _name) public returns(bool){
        require(chkAlias(_name));
        require (bytes(_name).length>=3 && bytes(_name).length<=20);
        for (uint i=0; i<aliases.length; i++)
        if(compareStrings(aliases[i],_name))
        require(0!=0);
        for (uint j=0; j<users.length;j++)
        if(users[j]==mkAddress(msg.sender,nonce))
        require(0!=0);

        aliases.push(_name);
        users.push(mkAddress(msg.sender,nonce));
        blacklisted.push(false);
        return true;
    }

    function getByName(string memory _name) public view returns(address){
        address result=address(0);
        for(uint i=0;i<aliases.length;i++)
        if(compareStrings(aliases[i],_name)){
        if(blacklisted[i]==false)
        result=users[i];
        }

        return result;
    }

    function getByAddress(address query) public view returns(string memory){
        string memory result="";
        for(uint i=0;i<users.length;i++)
        if(users[i]==query){
        if(blacklisted[i]==false)
        result=aliases[i];
        }

        return result;
    }

    function delist(address query, bool status) public returns(bool){
        require (msg.sender==EX(EXBase).getAccAt(0) || msg.sender==EX(EXBase).getAccAt(7));
        for(uint i=0;i<users.length;i++)
        if(users[i]==query){
            blacklisted[i]=status;
        }
        return true;
    }

    ////////////////////////////
    function mkAddress(address _origin, uint _nonce)  public pure returns (address _address) {
    bytes memory data;
    if(_nonce == 0x00)          data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80));
    else if(_nonce <= 0x7f)     data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, uint8(_nonce));
    else if(_nonce <= 0xff)     data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), _origin, bytes1(0x81), uint8(_nonce));
    else if(_nonce <= 0xffff)   data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), _origin, bytes1(0x82), uint16(_nonce));
    else if(_nonce <= 0xffffff) data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), _origin, bytes1(0x83), uint24(_nonce));
    else                        data = abi.encodePacked(bytes1(0xda), bytes1(0x94), _origin, bytes1(0x84), uint32(_nonce));
    bytes32 hash = keccak256(data);
    assembly {
        mstore(0, hash)
        _address := mload(0)
    }
    }
    function chkAlias(string memory _name) public pure returns(bool){
        uint allowedChars =0;
        bytes memory byteString = bytes(_name);
        bytes memory allowed = bytes("abcdefghijklmnopqrstuvwxyz0123456789");  //here you put what character are allowed to use
        for(uint i=0; i < byteString.length ; i++){
           for(uint j=0; j<allowed.length; j++){
              if(byteString[i]==allowed[j] )
              allowedChars++;         
           }
        }
        if(allowedChars<byteString.length)
        return false;
        return true;
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}