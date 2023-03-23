// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;

interface EX{
    function getTruAt(uint index) external view returns(address);
    function isXEX(address query) external view returns(bool);
}

interface XEX{
    function transfer(address recipient, uint amount) external returns (bool);
    function recycleAccount() external returns (bool);
}

contract ThreeCards{
    mapping (address => uint) public balances;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    address public owner;

    constructor(){
        owner=msg.sender;
        submitOracle("3 Cards","Game of luck played on the Blockchain. You and the computer draw three cards each. 50% chance to win");
    uint cno=2;
    for(uint i=0;i<13;i++){
      cards[i].no=cno;
      cards[i].suit=unicode"♠";
      cno++;
    }
    cno=2;
    for(uint i=13;i<13*2;i++){
      cards[i].no=cno;
      cards[i].suit=unicode"♥";
      cno++;
    }
    cno=2;
    for(uint i=13*2;i<13*3;i++){
      cards[i].no=cno;
      cards[i].suit=unicode"♦";
      cno++;
    }
    cno=2;
    for(uint i=13*3;i<13*4;i++){
      cards[i].no=cno;
      cards[i].suit=unicode"♣";
      cno++;
    }
    }

    function getMyBalance() public view returns(uint){
        return balances[msg.sender];
    }

    function pingFromXEX(address user, uint amount) public returns (bool){
        require(EX(EXBase).isXEX(msg.sender));
        balances[user]+=amount;
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

    struct card{
        uint no;
        string suit;
        }
    card[52] public cards;
    card[3] public userHand;
    card[3] public compHand;

    function play(uint amount) public returns(bool){
        require(amount!=0 && amount<=balances[msg.sender]);
        balances[msg.sender]-=amount;
        getRandoms();
        uint userScore=userHand[0].no+userHand[1].no+userHand[2].no;
        uint compScore=compHand[0].no+compHand[1].no+compHand[2].no;
        if(userScore>compScore){
            balances[msg.sender]+=2*amount;
        }
        return true;
    }

    function withdraw(uint amount) public returns(bool){
        require(amount!=0 && amount<=balances[msg.sender]);
        balances[msg.sender]-=amount;
        XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,amount);
        return true;
    }


    function getResult() view public returns(string memory,string memory){
        string memory a=string.concat(uint2str(userHand[0].no)," ",userHand[0].suit,",");
        string memory b=string.concat(a,uint2str(userHand[1].no)," ",userHand[1].suit,",");
        string memory c=string.concat(b,uint2str(userHand[2].no)," ",userHand[2].suit);
        string memory d=string.concat(uint2str(compHand[0].no)," ",compHand[0].suit,",");
        string memory e=string.concat(d,uint2str(compHand[1].no)," ",compHand[1].suit,",");
        string memory f=string.concat(e,uint2str(compHand[2].no)," ",compHand[2].suit);
        return(c,f);
    }

    uint counter=0;
    function random() private returns (uint) {
        counter++;
        return uint(keccak256(abi.encodePacked(tx.origin,block.number,block.timestamp,counter)));
    } 

function getRandoms() internal returns(bool){
  uint r0=random();
  r0=r0%52;
  uint r1=random();
  r1=r1%52;
  while(r1==r0){
    r1=random();
    r1=r1%52;
  }
  uint r2=random();
  r2=r2%52;
  while(r2==r0 || r2==r1){
    r2=random();
    r2=r2%52;
  }
  uint r3=random();
  r3=r3%52;
  while(r3==r2 || r3==r1 ||r3==r0){
    r3=random();
    r3=r3%52;
  }
  uint r4=random();
  r4=r4%52;
  while(r4==r3 || r4==r2 || r4==r1 ||r4==r0){
    r4=random();
    r4=r4%52;
  }
  uint r5=random();
  r5=r5%52;
  while(r5==r4 || r5==r3 || r5==r2 || r5==r1 ||r5==r0){
    r5=random();
    r5=r5%52;
  }
userHand[0]=cards[r0];
userHand[1]=cards[r2];
userHand[2]=cards[r4];
compHand[0]=cards[r1];
compHand[1]=cards[r3];
compHand[2]=cards[r5];
return true;
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

/////////////////
////////////////
//address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) internal returns (bool){
    //require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(7,t,d,"truInfos/others/threecards.json");
    return true;
}
}


interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}