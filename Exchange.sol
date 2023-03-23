// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//0
interface EX{
    function getTruAt(uint index) external view returns(address);
    function getAccAt(uint index) external view returns(address);
    function isMandated(address _user) external view returns(bool);
}
interface XEX{
    function mint(address user, uint amount) external returns(bool);
}
contract Exchange{
    uint public toMint;
    uint public totalMinted;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    string public xpub= "xpub661MyMwAqRbcG2CgU2WWzmPavMjBxZwcsqd5aSXJGaqmvBnN6LoT46zwaDPn7Gggm5w3xiC5ayW2N6YNAfzZMmZx4waFFHt7rGHzv4tFaBZ";
    string public initialPath= "m/1/5";
    string public btcPath="1";
    string public ethPath="2";
    string public thrPath="3";
    string public formula="initialPath/Path/no";
    struct order{
        uint path;
        uint xexAmount;
        uint started;
        uint lastChecked;
        string add_btc;
        string add_eth;
        string add_thr;
        string bal_btc;
        string bal_eth;
        string bal_thr;
    }
    mapping (address => order) public orders;
    uint[] public usedPaths;
    address[] public toCheck;
    uint[] toCheckPaths;

    function updateToMint(uint no) public returns (bool){
        require(EX(EXBase).isMandated(msg.sender));
        toMint+=no;
        return true;
    }

    function isUsedPath(uint no) public view returns (bool){
        bool used=false;
        for (uint i=0;i<usedPaths.length;i++)
        if(usedPaths[i]==no)
        used=true;
        
        if(no==0) used=true;
        return used;

    }
    function start(uint no) public returns(bool){
        require(no!=0);
        for (uint i=0;i<usedPaths.length;i++)
        if(usedPaths[i]==no)
        require(0!=0);
        require(orders[msg.sender].path==0);

        orders[msg.sender]=order(no,0,block.timestamp,0,"","","","","","");
        usedPaths.push(no);
        return true;
    }
    function check() public returns (bool){
        require(orders[msg.sender].path!=0);
        require(orders[msg.sender].lastChecked+5 minutes <= block.timestamp);
        toCheck.push(msg.sender);
        toCheckPaths.push(orders[msg.sender].path);
        orders[msg.sender].lastChecked=block.timestamp;
        return true;
    }
    function exchange() public returns (bool){
        uint amount=orders[msg.sender].xexAmount;
        require(amount!=0);
        require(amount<=toMint);
        XEX(EX(EXBase).getTruAt(2)).mint(msg.sender,amount);
        toMint-=amount;
        totalMinted+=amount;
        orders[msg.sender]=order(0,0,0,0,"","","","","","");
        return true;
    }
    function cancel() public returns (bool){
        require (orders[msg.sender].xexAmount==0);
        require (orders[msg.sender].started+1 days <= block.timestamp && orders[msg.sender].started!=0);
        orders[msg.sender]=order(0,0,0,0,"","","","","","");
        return true;
    }
    function getOrderDetails() public view returns(uint, string memory,string memory,string memory, string memory,string memory,string memory){
        return (orders[msg.sender].xexAmount,
                orders[msg.sender].add_btc,  orders[msg.sender].add_eth,  orders[msg.sender].add_thr,
                orders[msg.sender].bal_btc, orders[msg.sender].bal_eth, orders[msg.sender].bal_thr);
    }

    function getOrderstoCheck() public view returns (address[] memory, uint[] memory){
        return (toCheck, toCheckPaths);
    }
    function delOrdersToCheck() public returns (bool){
        require(EX(EXBase).getAccAt(5)==msg.sender || EX(EXBase).getAccAt(0)==msg.sender); //
        delete toCheck;
        delete toCheckPaths;
        return true;
    }
    function rescindOrder(address user) public returns (bool){
        require(EX(EXBase).getAccAt(5)==msg.sender || EX(EXBase).getAccAt(0)==msg.sender); //
        orders[user]=order(0,0,0,0,"","","","","","");
        return true;
    }
    function updateOrder(address user, uint xex, 
    string memory _add_btc, string memory _add_eth, string memory _add_thr,
    string memory _bal_btc,string memory _bal_eth, string memory _bal_thr) 
    public returns (bool){
        require(EX(EXBase).getAccAt(5)==msg.sender || EX(EXBase).getAccAt(0)==msg.sender); //
        orders[user].xexAmount=xex;
        orders[user].lastChecked=block.timestamp;
        orders[user].add_btc=_add_btc;
        orders[user].add_eth=_add_eth;
        orders[user].add_thr=_add_thr;
        orders[user].bal_btc=_bal_btc;
        orders[user].bal_eth=_bal_eth;
        orders[user].bal_thr=_bal_thr;

        return true;
    }

}