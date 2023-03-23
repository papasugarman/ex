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

contract Wheel{
    mapping(address => uint) lastPosition;
    mapping(address => uint) lastPlay;
    mapping (address => uint) public spins;
    mapping (address => bool) public usedFree;
    uint[] public board=[1,0,0,3,2,0,4,0,2,0,0,3,0];
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    address public owner;

    constructor(){
        owner=msg.sender;
        submitOracle("Wheel of Fortune","Spin the wheel and win money. Win 1 EX ! Instant transfers. Game of luck.");
    }

    function getMySpins() public view returns(uint){
        return spins[msg.sender];
    }
    function showWheel() public view returns(uint[] memory){
        uint[] memory tosend=new uint[](board.length);
        for(uint i=0;i<board.length;i++)
        tosend[i]=board[i];
        return tosend;
    }

    function pingFromXEX(address user, uint amount) public returns (bool){
        require(EX(EXBase).isXEX(msg.sender));
        require(amount==10 ||amount==45);
        if(amount==10)
        spins[user]+=1;
        if(amount==45)
        spins[user]+=5;
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

    function play() public returns (bool){
        require(spins[msg.sender]>0);
        spins[msg.sender]-=1;
        uint rand=random();
        rand=rand%13;
        uint index=board[rand];

        if(index==0){}
        if(index==1){
            spins[msg.sender]+=2;
        }
        if(index==2){
            XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,20);
        }
        if(index==3){
            XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,40);
        }
        if(index==4){
            XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,1000);
        }
        
        lastPlay[msg.sender]=index;
        lastPosition[msg.sender]=rand;
        return true;
    }
    function getResult() public view returns(string memory){
        string memory a=string.concat("Position: ",uint2str(lastPosition[msg.sender]),", ");
        string memory b=string.concat(a,"Prize: ",uint2str(lastPlay[msg.sender]));
        return b;
    }
    function getFreeRun()public returns(bool){
        require(!usedFree[msg.sender]);
        spins[msg.sender]+=1;
        usedFree[msg.sender]=true;
        return true;
    }

    uint counter=0;
    function random() private returns (uint) {
        counter++;
        return uint(keccak256(abi.encodePacked(tx.origin,block.number,block.timestamp,counter)));
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
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(7,t,d,"truInfos/others/wheel.json");
    return true;
}
}


interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}