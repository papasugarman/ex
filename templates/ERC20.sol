// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "";
    string public symbol = "";
    uint public decimals = 0;
    address owner;
    bool wasInited=false;

    constructor(){
        owner=msg.sender;
    }

    function init(string memory n,string memory s,uint d) public returns (bool){
        require(msg.sender==owner);
        require(!wasInited);
        name=n;
        symbol=s;
        decimals=d;
        wasInited=true;
        return true;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(amount!=0);
        require(balanceOf[msg.sender]>=amount);
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        require(amount!=0);
        require(balanceOf[msg.sender]>=amount);
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        require(amount!=0);
        require(balanceOf[sender]>=amount);
        require(allowance[sender][msg.sender]>=amount);
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external {
        require(amount!=0);
        require(msg.sender==owner);
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        require(amount!=0);
        require(balanceOf[msg.sender]>=amount);
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
/////////////////
////////////////
address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
function submitOracle(string memory t,string memory d) public returns (bool){
    require(msg.sender==owner);
    Oracle(EX(EXBase).getTruAt(4)).provideTruInfoSelf(1,t,d,"truInfos/templates/erc20.json");
    return true;
}
}

interface EX{
    function getTruAt(uint index) external view returns(address);
}
interface Oracle{
    function provideTruInfoSelf(uint _cat,string memory _t,string memory _d,string memory _p) external returns(bool);
}
