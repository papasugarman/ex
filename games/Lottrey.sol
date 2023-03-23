// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;

interface EX{
    function getTruAt(uint index) external view returns(address);
    function isXEX(address query) external view returns(bool);
    function isOracle(address query) external view returns(bool);
}

interface XEX{
    function transfer(address recipient, uint amount) external returns (bool);
    function recycleAccount() external returns (bool);
}

contract Lottrey{
    mapping (address => bool) public usedFree;
    uint[6] public lastDraw;
    struct entry{
        address user;
        uint[6] line;
        uint matches;
    }
    entry[] entries;
    entry[] previousPlays;
    mapping (address => uint) public allowance;
    uint public nextDraw;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    address public owner;

    constructor(){
        owner=msg.sender;
        submitOracle("Chain Lottery","Play 6 numbers. Match 6, get $1 million. Match 5, get $500k; 4 get $100k. Draw every 24 hours!");
    }

    function pingFromOracle() public returns (bool){
        require(EX(EXBase).isOracle(msg.sender));
        draw();
        uint t=block.timestamp+24 hours-3 minutes;
        nextDraw=getRunTimeAt(t);
        Oracle(EX(EXBase).getTruAt(4)).scheduleRunSelf(t);
        return true;
    }

    function pingFromXEX(address user, uint amount) public returns (bool){
        require(EX(EXBase).isXEX(msg.sender));
        require(amount==20 ||amount==90);
        if(amount==20)
        allowance[user]+=1;
        if(amount==90)
        allowance[user]+=5;
        return true;
    }

    function giveToOwner(uint amount) public returns (bool){
        require(msg.sender==owner);
        XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,amount);
        return true;
    }

    function finishAccount() public returns (bool){
        require(msg.sender==owner);
        XEX(EX(EXBase).getTruAt(2)).recycleAccount();
        return true;
    }

    function getMyBalance() public view returns(uint){
        return allowance[msg.sender];
    }
    function playLine(uint b0, uint b1, uint b2, uint b3, uint b4, uint b5) public returns (bool){
        require(allowance[msg.sender]>=1);
        require (b1!=b0);
        require (b2!=b1 && b2!=b0);
        require (b3!=b2 && b3!=b1 && b3!=b0);
        require (b4!=b3 && b4!=b2 && b4!=b1 && b4!=b0);
        require (b5!=b4 && b5!=b3 && b5!=b2 && b5!=b1 && b5!=b0);
        require (b0>=1 && b0<=49);
        require (b1>=1 && b1<=49);
        require (b2>=1 && b2<=49);
        require (b3>=1 && b3<=49);
        require (b4>=1 && b4<=49);
        require (b5>=1 && b5<=49);

        allowance[msg.sender]-=1;
        entries.push(entry(msg.sender,[b0,b1,b2,b3,b4,b5],0));
        return true;
    }
    function playLuckyDip(uint qty) public returns (bool){
        require (qty<=allowance[msg.sender] && qty!=0);
        for(uint i=0;i<qty;i++){
            allowance[msg.sender]-=1;
            entries.push(entry(msg.sender,getRandoms(),0));
        }
        return true;
    }
    function Draw() public returns (bool){
        require(msg.sender==owner);
        draw();
        return true;
    }
    function draw() internal returns(bool){
        lastDraw=getRandoms();
        uint ms;
        for (uint i=0;i<entries.length;i++){
             ms=0;
            for(uint j=0;j<6;j++){
                for(uint k=0;k<6;k++)
                    if(lastDraw[j]==entries[i].line[k])
                    ms++;
            }
            entries[i].matches=ms;
        }
        /*
        for(uint i=0;i<entries.length;i++){
            if(entries[i].matches==6)
            XEX(EX(EXBase).getTruAt(2)).transfer(entries[i].user,16666666);
            if(entries[i].matches==5)
            XEX(EX(EXBase).getTruAt(2)).transfer(entries[i].user,8333333);
            if(entries[i].matches==4)
            XEX(EX(EXBase).getTruAt(2)).transfer(entries[i].user,1666666);
        }*/

        previousPlays=entries;
        delete entries;
        return true;
    }
    function getLastResult() public view returns (string memory){
        string memory balls="Lines: ";
        string memory drawstr="Last Draw: ";
        for(uint k=0;k<6;k++)
        drawstr=string.concat(drawstr,uint2str(lastDraw[k])," ");
        for(uint i=0;i<previousPlays.length;i++){
            if(previousPlays[i].user==msg.sender){
                for(uint j=0;j<6;j++)
                balls=string.concat(balls,uint2str(previousPlays[i].line[j])," ");

                balls=string.concat(balls,", matches=",uint2str(previousPlays[i].matches)," ;");
            }
        }
        return string.concat(drawstr," ",balls);
    }
    function getCurrentLines() public view returns(string memory){
         string memory balls="Lines: ";
         for(uint i=0;i<entries.length;i++){
            if(entries[i].user==msg.sender){
                for(uint j=0;j<6;j++)
                balls=string.concat(balls,uint2str(entries[i].line[j])," ");

                balls=string.concat(balls,"; ");
            }
        }
        return balls;
    }
    function getFreeRun()public returns(bool){
        require(!usedFree[msg.sender]);
        allowance[msg.sender]+=1;
        usedFree[msg.sender]=true;
        return true;
    }

    uint counter=0;
    function random() private returns (uint) {
        counter++;
        return uint(keccak256(abi.encodePacked(tx.origin,block.number,block.timestamp,counter)));
    } 

    function getRandoms() internal returns(uint[6] memory){
  uint r0=random();
  r0=r0%49;
  uint r1=random();
  r1=r1%49;
  while(r1==r0){
    r1=random();
    r1=r1%49;
  }
  uint r2=random();
  r2=r2%49;
  while(r2==r0 || r2==r1){
    r2=random();
    r2=r2%49;
  }
  uint r3=random();
  r3=r3%49;
  while(r3==r2 || r3==r1 ||r3==r0){
    r3=random();
    r3=r3%49;
  }
  uint r4=random();
  r4=r4%49;
  while(r4==r3 || r4==r2 || r4==r1 ||r4==r0){
    r4=random();
    r4=r4%49;
  }
  uint r5=random();
  r5=r5%49;
  while(r5==r4 || r5==r3 || r5==r2 || r5==r1 ||r5==r0){
    r5=random();
    r5=r5%49;
  }
r0=r0+1;
r1=r1+1;
r2=r2+1;
r3=r3+1;
r4=r4+1;
r5=r5+1;
return [r0,r1,r2,r3,r4,r5];
}

 function uint2str(
  uint256 _i
)
  internal
  pure
  returns (string memory str)
{
  if (_i == 0)
  {
    return "0";
  }
  uint256 j = _i;
  uint256 length;
  while (j != 0)
  {
    length++;
    j /= 10;
  }
  bytes memory bstr = new bytes(length);
  uint256 k = length;
  j = _i;
  while (j != 0)
  {
    bstr[--k] = bytes1(uint8(48 + j % 10));
    j /= 10;
  }
  str = string(bstr);
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

/////////////////
////////////////
//address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) internal returns (bool){
    //require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(7,t,d,"truInfos/others/lottrey.json");
    return true;
}
}


interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
    function scheduleRunSelf(uint ts) external returns(bool);
}