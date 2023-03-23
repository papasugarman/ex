// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface EX{
    function getTruAt(uint index) external view returns(address);
    function getAccAt(uint index) external view returns(address);
    function isMandated(address _user) external view returns(bool);
}

interface XEX{
    function transfer(address recipient, uint amount) external returns (bool);
    function recycle(uint amount) external returns (bool);
}

interface Oracle{
    function pingFromPayments(address user, uint amount) external returns (bool);
}

contract Payments{
    mapping (address => uint) public balances;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    uint public payments;
    struct product{
        uint price;
        string title;
    }
    product[] public products;
    mapping (address => uint) public truQuotas;
    mapping (address => uint) public MBQuotas;
    address[] public newTruOrders;
    address[] public newMBOrders;

    constructor(){
        products.push(product(20,"1x TruCode Launch"));
        products.push(product(200,"1 MB TruCode space"));
        products.push(product(4,"1x Oracle credit"));
    }

    function getUserBalance(address _query) public view returns(uint){
        return balances[_query];
    }
    function myBalance() public view returns (uint){
        return balances[msg.sender];
    }
    function getTruPrice() public view returns (uint){
        return products[0].price;
    }
    function getMBPrice() public view returns (uint){
        return products[1].price;
    }
    function getOraclePrice() public view returns (uint){
        return products[2].price;
    }

    function pingFromXEX(address user, uint amount) public returns (bool){
        require(msg.sender==EX(EXBase).getTruAt(2));
        balances[user]+=amount;
        return true;
    }
    function refund() public returns (bool){
        require(balances[msg.sender]!=0);
        XEX(EX(EXBase).getTruAt(2)).transfer(msg.sender,balances[msg.sender]);
        balances[msg.sender]=0;
        return true;
    }

    function extractAmount(uint amount) public returns (bool){
        address admin=EX(EXBase).getAccAt(0); //admin will recycle
        require(msg.sender==admin);
        XEX(EX(EXBase).getTruAt(2)).transfer(admin,amount);
        payments-=amount;
        return true;
    }

    function updateTruLaunch(uint _new) public returns (bool){
        require (EX(EXBase).isMandated(msg.sender));
        products[0].price=_new;
        return true;
    }
    function updateMBPrice(uint _new) public returns (bool){
        require (EX(EXBase).isMandated(msg.sender));
        products[1].price=_new;
        return true;
    }
    function updateOracleRun(uint _new) public returns (bool){
        require (EX(EXBase).isMandated(msg.sender) || msg.sender==EX(EXBase).getAccAt(0)); //admin
        products[2].price=_new;
        return true;
    }
    function getNewTruOrder() public view returns (address[] memory){
        return newTruOrders;
    }
    function getNewMBOrder() public view returns (address[] memory){
        return newMBOrders;
    }
    function clearNewOrders() public returns (bool){
        require (msg.sender==EX(EXBase).getAccAt(3) || msg.sender==EX(EXBase).getAccAt(0)); //self or admin
        delete newTruOrders;
        delete newMBOrders;
        return true;
    }

    function purchase_tru(uint qty) public returns (bool){
        require (qty>0);
        uint tocharge=products[0].price*qty;
        require(balances[msg.sender]>=tocharge);
        balances[msg.sender]-=tocharge;
        truQuotas[msg.sender]+=qty;
        newTruOrders.push(msg.sender);
        payments+=tocharge;
        return true;
    }

    function purchase_mb(uint nonce,uint qty) public returns (bool){
        require (qty>0);
        uint tocharge=products[1].price*qty;
        require(balances[msg.sender]>=tocharge);
        balances[msg.sender]-=tocharge;
        address truAdd=mkAddress(msg.sender,nonce);
        MBQuotas[truAdd]+=qty*1024;
        newMBOrders.push(truAdd);
        payments+=tocharge;
        return true;
    }

    function purchase_oracle(uint qty) public returns (bool){
        require (qty>0);
        uint tocharge=products[2].price*qty;
        require(balances[msg.sender]>=tocharge);
        balances[msg.sender]-=tocharge;
        payments+=tocharge;
        Oracle(EX(EXBase).getTruAt(4)).pingFromPayments(msg.sender,qty);
        return true;
    }

    function purchase_oracleTru(uint nonce, uint qty) public returns (bool){
        require (qty>0);
        uint tocharge=products[2].price*qty;
        require(balances[msg.sender]>=tocharge);
        balances[msg.sender]-=tocharge;
        payments+=tocharge;
        address truAdd=mkAddress(msg.sender,nonce);
        Oracle(EX(EXBase).getTruAt(4)).pingFromPayments(truAdd,qty);
        return true;
    }

    function compensatePurchase(address query,uint productno,uint qty) public returns (bool){
        require (msg.sender==EX(EXBase).getAccAt(3) || msg.sender==EX(EXBase).getAccAt(0)); //self or admin
        if(productno==0){
            truQuotas[query]+=qty;
            newTruOrders.push(query);
            return true;
        }
        if(productno==1){
            MBQuotas[query]+=qty*1024;
            newMBOrders.push(query);
            return true;
        }
        if(productno==1){
            Oracle(EX(EXBase).getTruAt(4)).pingFromPayments(query,qty);
            return true;
        }
        return false;
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