// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;

interface EX{
    function getTruAt(uint index) external view returns(address);
    function getAccAt(uint index) external view returns(address);
    function isMandated(address _user) external view returns(bool);
}
contract Oracle{
    mapping (address => uint) public balances;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    uint public UnitXEX2USD=60;
    string public BTCXEX="";
    string public ETHXEX="";

    mapping (uint => address[]) runs;
    string[] public cats;
    mapping (address => bool) usedFree;

    struct truInfo{
        address owner;
        uint cat;
        string title;
        string description;
        string path;
    }

    mapping (address => truInfo) public truInfos;
    mapping (uint => address[]) public inCats;

    constructor(){
        cats.push("Test");//0
        cats.push("Finance & Automation");//1
        cats.push("Science & Engineering");//2
        cats.push("Blockchain & Tech");//3
        cats.push("Arts & Entertainment");//4
        cats.push("People & Society");//5
        cats.push("Law & Governance");//6
        cats.push("Fun & Games"); //7

        truInfos[EX(EXBase).getTruAt(0)]=truInfo(EX(EXBase).getAccAt(0),6,"EX Base","Base TruCode of the EX Blockchain","truInfos/base.json");
        inCats[6].push(EX(EXBase).getTruAt(0));

        truInfos[EX(EXBase).getTruAt(1)]=truInfo(EX(EXBase).getAccAt(1),3,"EX Mandate","Voting facility to change EX Blockchain's paramenters","truInfos/mandate.json");
        inCats[3].push(EX(EXBase).getTruAt(1));

        truInfos[EX(EXBase).getTruAt(2)]=truInfo(EX(EXBase).getAccAt(2),1,"EX Coin","Currency of the EX Blockchain","truInfos/xex.json");
        inCats[1].push(EX(EXBase).getTruAt(2));

        truInfos[EX(EXBase).getTruAt(3)]=truInfo(EX(EXBase).getAccAt(3),1,"Payments","Payment system for EX Blockchain","truInfos/payment.json");
        inCats[1].push(EX(EXBase).getTruAt(3));

        truInfos[EX(EXBase).getTruAt(4)]=truInfo(EX(EXBase).getAccAt(4),3,"Oracle","EX Blockchain's Oracle services","truInfos/oracle.json");
        inCats[3].push(EX(EXBase).getTruAt(4));

        truInfos[EX(EXBase).getTruAt(5)]=truInfo(EX(EXBase).getAccAt(5),1,"Vending Machine","Official system for minting EX Coins","truInfos/vend.json");
        inCats[1].push(EX(EXBase).getTruAt(5));

        truInfos[EX(EXBase).getTruAt(6)]=truInfo(EX(EXBase).getAccAt(6),3,"EX Notice","Chain-wide notices against addresses","truInfos/notice.json");
        inCats[3].push(EX(EXBase).getTruAt(6));

        truInfos[EX(EXBase).getTruAt(7)]=truInfo(EX(EXBase).getAccAt(7),3,"Aliases","Official alias directory of the EX Blockchain","truInfos/alias.json");
        inCats[3].push(EX(EXBase).getTruAt(7));
    }

    function provideTruInfo(uint nonce, uint cat, string memory t, string memory d, string memory p) public returns (bool){
        require (bytes(t).length>=3 && bytes(t).length<=25);
        require (bytes(d).length<=100);
        require(!usedFree[msg.sender] || balances[msg.sender]>0);
        require(cat<cats.length);
        address add=mkAddress(msg.sender,nonce);

        for(uint i=0;i<inCats[cat].length;i++)
        if(inCats[cat][i]==add){
        removeFromCats(cat,i);
        break;
        }

        inCats[cat].push(add);
        truInfos[add]=truInfo(msg.sender,cat,t,d,p);
        if(!usedFree[msg.sender]) usedFree[msg.sender]=true;
        else balances[msg.sender]-=1;
        return true;

    }
    function provideTruInfoSelf(uint cat, string memory t, string memory d, string memory p) public returns (bool){
        require (bytes(t).length>=3 && bytes(t).length<=25);
        require (bytes(d).length<=100);
        require(msg.sender!=tx.origin);
        require(!usedFree[msg.sender] || balances[msg.sender]>0);
        require(cat<cats.length);
        address add=msg.sender;

        for(uint i=0;i<inCats[cat].length;i++)
        if(inCats[cat][i]==add){
        removeFromCats(cat,i);
        break;
        }

        inCats[cat].push(add);
        truInfos[add]=truInfo(msg.sender,cat,t,d,p);
        if(!usedFree[msg.sender]) usedFree[msg.sender]=true;
        else balances[msg.sender]-=1;
        return true;

    }
    function delistTruInfo(address add) public returns (bool){
        require(EX(EXBase).getAccAt(4)==msg.sender || EX(EXBase).getAccAt(0)==msg.sender); //
        uint cat=truInfos[add].cat;
        for(uint i=0;i<inCats[cat].length;i++)
        if(inCats[cat][i]==add){
        removeFromCats(cat,i);
        break;
        }
        truInfos[add].title="-Delisted-";
        truInfos[add].path="";
        return true;
    }
    function getCount() public view returns (uint[] memory){
        uint[] memory toreturncounts= new uint[](cats.length);
        for (uint i=0;i<cats.length;i++){
            toreturncounts[i]=inCats[i].length;
        }
        return toreturncounts;
    }
    function getList(uint cat, uint page, uint perpage) public view returns (address[] memory){
        uint index = perpage * page - perpage;

    if (
      inCats[cat].length == 0 || 
      index > inCats[cat].length - 1
    ) {
      return new address[](0);
    }

    address[] memory toreturn = new address[](perpage);
    uint rindex = 0;
    for (
      index; 
      index < perpage * page; 
      index++
    ) {

      if (index <= inCats[cat].length - 1) {
        toreturn[rindex] = inCats[cat][index];
      } else {
        toreturn[rindex] = address(0);
      }

      rindex++;
    }

    return toreturn;
    }
    function getListFull(uint cat, uint page, uint perpage) public view returns (address[] memory, string[] memory){
        uint index = perpage * page - perpage;

    if (
      inCats[cat].length == 0 || 
      index > inCats[cat].length - 1
    ) {
      return (new address[](0),new string[](0));
    }

    address[] memory toreturn = new address[](perpage);
    string[] memory returntitles = new string[](perpage);
    uint rindex = 0;
    for (
      index; 
      index < perpage * page; 
      index++
    ) {

      if (index <= inCats[cat].length - 1) {
        toreturn[rindex] = inCats[cat][index];
        returntitles[rindex]=truInfos[toreturn[rindex]].title;
      } else {
        toreturn[rindex] = address(0);
        returntitles[rindex]="";
      }

      rindex++;
    }

    return (toreturn,returntitles);
    }

    function removeFromCats(uint cat, uint index) internal {
        if (index >= inCats[cat].length) return;

        for (uint i = index; i<inCats[cat].length-1; i++){
            inCats[cat][i] = inCats[cat][i+1];
        }
        inCats[cat].pop();
    }

    function pingFromPayments(address user,uint no) public returns (bool){
        require(msg.sender==EX(EXBase).getTruAt(3));
        balances[user]+=no;
        return true;
    }
    function updateXEXUSD(uint _new) public returns (bool){
        require(EX(EXBase).isMandated(msg.sender));
        UnitXEX2USD=_new;
        return true;
    }
    function updateRates(string memory b, string memory e) public returns (bool){
        require(EX(EXBase).getAccAt(4)==msg.sender || EX(EXBase).getAccAt(0)==msg.sender); //
        BTCXEX=b;
        ETHXEX=e;
        return true;
    }

    function scheduleRun(uint nonce, uint timestamp) public returns (bool){
        require(balances[msg.sender]>0);
        require(timestamp>=block.timestamp);
        address add=mkAddress(msg.sender,nonce);
        uint prev; uint next;
        if((timestamp % 900)==0)
        next=timestamp;
        else{
        prev = timestamp - (timestamp % 900);
        next = prev + 900;
        }
        
        runs[next].push(add);
        balances[msg.sender]-=1;
        return true;
    }
    function scheduleRunSelf(uint timestamp) public returns (bool){ //For TruCodes
        require(msg.sender!=tx.origin);
        require(balances[msg.sender]>0);
        require(timestamp>=block.timestamp);
        address add=msg.sender;
        uint prev; uint next;
        if((timestamp % 900)==0)
        next=timestamp;
        else{
        prev = timestamp - (timestamp % 900);
        next = prev + 900;
        }
        
        runs[next].push(add);
        balances[msg.sender]-=1;
        return true;
    }
    function getRuns() public view returns (address[] memory){
        uint timestamp=block.timestamp;
        uint prev; uint next;
        if((timestamp % 900)==0)
        prev=timestamp;
        else{
        prev = timestamp - (timestamp % 900);
        next = prev + 900;
        }
        return runs[prev];
    }
    function delRuns() public returns (bool){
        require(EX(EXBase).getAccAt(4)==msg.sender || EX(EXBase).getAccAt(0)==msg.sender); //
        uint timestamp=block.timestamp;
        uint prev; uint next;
        if((timestamp % 900)==0)
        prev=timestamp;
        else{
        prev = timestamp - (timestamp % 900);
        next = prev + 900;
        }
        delete runs[prev];
        return true;
    }

    function getRunTimeForProcessing() public view returns (uint) {
        uint timestamp=block.timestamp;
        uint prev; uint next;
        if((timestamp % 900)==0)
        prev=timestamp;
        else{
        prev = timestamp - (timestamp % 900);
        next = prev + 900;
        }
        return prev;
    }
    function getRunTimeAt(uint timestamp) public pure returns (uint) {
        uint prev; uint next;
        if((timestamp % 900)==0)
        prev=timestamp;
        else{
        prev = timestamp - (timestamp % 900);
        next = prev + 900;
        }
        return next;
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

}