// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;

import "./IERC20.sol";

interface EX{
    function getTruAt(uint index) external view returns(address);
    function getAccAt(uint index) external view returns(address);
    function isMandated(address _user) external view returns(bool);
}
interface tru{
    function pingFromXEX(address user, uint amount) external returns (bool);
}

contract Coin is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    uint public accountFee=17;
    uint public interestRate=13;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    mapping(address => uint) firstSeen;

    event RefundableTransfer(address indexed, address indexed, uint,uint,uint);
    event SmartTransfer(address indexed, address indexed, uint,uint,uint);

    function updateAccountFee(uint _new) public returns (bool){
        require (EX(EXBase).isMandated(msg.sender));
        accountFee=_new;
        return true;
    }

    function updateInterestRate(uint _new) public returns (bool){
        require (EX(EXBase).isMandated(msg.sender));
        interestRate=_new;
        return true;
    }

    function isUserEX(address _query) public view returns (bool){
        if (balanceOf[_query]<accountFee) return false;
        if (firstSeen[_query]==0) return false;
        if (firstSeen[_query]+3 minutes<block.timestamp)
        return true;
        return false;
    }

    function myBalance() public view returns(uint){
        return balanceOf[msg.sender];
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(recipient!=msg.sender);
        require (amount!=0);
        require(balanceOf[msg.sender]-amount>=accountFee);
        require (amount<=balanceOf[msg.sender]);
        if (!isUserEX(recipient)){
            require(amount==accountFee && balanceOf[recipient]==0);
            firstSeen[recipient]=block.timestamp;
        }
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        require (spender!=msg.sender);
        require (isUserEX(msg.sender) && isUserEX(spender));
        require (amount!=0);
        require (balanceOf[msg.sender]-amount>=accountFee);
        require (amount<=balanceOf[msg.sender]);
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        require (amount!=0);
        require(amount<=allowance[sender][msg.sender]);
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    ////////////////////////////
    uint public pot_aribitration;
    uint public pot_recycling;
    uint public pot_savings;


    struct refundable{
        uint amount;
        uint started;
        uint time;
    }

    mapping(address => mapping(address => refundable)) public refundables;

    function refundableTransfer(address to,uint amount, uint time) public returns (bool){
        require (to!=msg.sender);
        require (isUserEX(msg.sender) && isUserEX(to));
        require (amount!=0);
        require (balanceOf[msg.sender]-amount>=accountFee);
        require (amount<=balanceOf[msg.sender]);
        require (refundables[msg.sender][to].amount==0);
        require (time>60);
        refundables[msg.sender][to]=refundable(amount,block.timestamp,time);
        balanceOf[msg.sender]-=amount;
        balanceOf[address(this)]+=amount;
        pot_aribitration+=amount;
        emit Transfer(msg.sender, address(this), amount);
        emit RefundableTransfer(msg.sender, to, amount,time,block.timestamp);
        return true;
    }

    function refundableTransfer_extract(address from, address to) public returns (bool){
        require (refundables[from][to].amount!=0);
        bool sender=false; bool receiver=false;
        if (msg.sender==from) sender=true;
        if (msg.sender==to) receiver=true;
        require (sender || receiver);
        bool timepassed=false;
        if (refundables[from][to].started+refundables[from][to].time<=block.timestamp) timepassed=true;

        uint amount=refundables[from][to].amount;
        if(sender && !timepassed){
            balanceOf[from]+=amount;
            balanceOf[address(this)]-=amount;
            pot_aribitration-=amount;
            refundables[from][to].amount=0;
            emit Transfer(address(this), from, amount);
            return true;
        }
        if(receiver && timepassed){
            balanceOf[to]+=amount;
            balanceOf[address(this)]-=amount;
            pot_aribitration-=amount;
            refundables[from][to].amount=0;
            emit Transfer(address(this),to,amount);
            return true;
        }
        require(0!=0);
        return false;
    }

    ////////////////////////////
    struct smartxn{
        uint amount;
        uint started;
        uint time;
        uint status_x;
        uint status_y;
    }

    mapping(address => mapping(address => smartxn)) public smartxns;

    function smartTransfer(address to,uint amount, uint time) public returns (bool){
        require (to!=msg.sender);
        require (isUserEX(msg.sender) && isUserEX(to));
        require (amount>=5);
        require (balanceOf[msg.sender]-amount>=accountFee);
        require (amount<=balanceOf[msg.sender]);
        require (smartxns[msg.sender][to].amount==0);
        require (time>60);
        smartxns[msg.sender][to]=smartxn(amount,block.timestamp,time,1,1);
        balanceOf[msg.sender]-=amount;
        balanceOf[address(this)]+=amount;
        pot_aribitration+=amount;
        emit Transfer(msg.sender, address(this), amount);
        emit SmartTransfer(msg.sender, to, amount,time,block.timestamp);
        return true;
    }
    function smartTransfer_update(address from, address to, uint status) public returns (bool){
        require(smartxns[from][to].amount!=0);
        bool sender=false; bool receiver=false;
        if (msg.sender==from) sender=true;
        if (msg.sender==to) receiver=true;
        require (sender || receiver);
        uint phase=0; //0=decision, 1=reaping
        if (smartxns[from][to].started+smartxns[from][to].time<=block.timestamp) phase=1;

        if(phase==0)
        require(status==0 || status==1);
        else
        require (status>1 && status<=smartxns[from][to].amount);

        if(sender) 
        smartxns[from][to].status_x=status;
        else
        smartxns[from][to].status_y=status;
        
        return true;
    }
    function smartTransfer_extract(address from, address to) public returns (bool){
        require(smartxns[from][to].amount!=0);
        bool sender=false; bool receiver=false;
        if (msg.sender==from) sender=true;
        if (msg.sender==to) receiver=true;
        require (sender || receiver);
        uint phase=0; //0=decision, 1=reaping
        if (smartxns[from][to].started+smartxns[from][to].time<=block.timestamp) phase=1;
        require(phase==1);

        uint amount=smartxns[from][to].amount;
        if (smartxns[from][to].status_x==0 && smartxns[from][to].status_y==0 && sender){
            balanceOf[from]+=amount;
            balanceOf[address(this)]-=amount;
            pot_aribitration-=amount;
            smartxns[from][to].amount=0;
            emit Transfer(address(this), from, amount);
            return true;
        }
        if (smartxns[from][to].status_x==1 && smartxns[from][to].status_y==1 && receiver){
            balanceOf[to]+=amount;
            balanceOf[address(this)]-=amount;
            pot_aribitration-=amount;
            smartxns[from][to].amount=0;
            emit Transfer(address(this),to,amount);
            return true;
        }
        if (smartxns[from][to].status_x == smartxns[from][to].status_y){
            uint torefund=amount-smartxns[from][to].status_x;
            balanceOf[to]+=smartxns[from][to].status_x;
            balanceOf[from]+=torefund;
            balanceOf[address(this)]-=amount;
            pot_aribitration-=amount;
            smartxns[from][to].amount=0;
            emit Transfer(address(this), from, torefund);
            emit Transfer(address(this),to,smartxns[from][to].status_x);
            return true;
        }
        require(0!=0);
        return false;
    }

    //////////////////////////////
    function truTransfer(address from, address to, uint amount) public returns (bool){
        require (to!=msg.sender);
        require (isUserEX(msg.sender) && isUserEX(to) );// && isUserEX(from));
        require (amount>0);
        require (balanceOf[msg.sender]-amount>=accountFee);
        require (amount<=balanceOf[msg.sender]);
        balanceOf[msg.sender]-=amount;
        balanceOf[to]+=amount;
        emit Transfer(msg.sender, to, amount);
        tru(to).pingFromXEX(from,amount);
        return true;
    }

    ////////////////////////////////
    struct saving{
        uint amount;
        uint started;
        uint percent;
    }

    mapping (address => saving) savings;

    function savings_deposit(uint amount) public returns (bool){
        require (isUserEX(msg.sender));
        require (amount>0);
        require (balanceOf[msg.sender]-amount>=accountFee);
        require (amount<=balanceOf[msg.sender]);
        require (savings[msg.sender].amount==0);
        savings[msg.sender]=saving(amount,block.timestamp,interestRate);
        balanceOf[msg.sender]-=amount;
        balanceOf[address(this)]+=amount;
        pot_savings+=amount;
        emit Transfer(msg.sender, address(this), amount);
        return true;
    }

    function savings_withdraw() public returns (bool){
        require (savings[msg.sender].amount!=0);
        uint amount=savings[msg.sender].amount;
        uint interest=0;
        uint timepassed=block.timestamp-savings[msg.sender].started;
        interest=(savings[msg.sender].percent*amount*timepassed)/3153600000;
        balanceOf[msg.sender]+=amount;
        balanceOf[address(this)]-=amount;
        pot_savings-=amount;
        savings[msg.sender].amount=0;

        if(interest>0)
        Mint(msg.sender,interest);

        emit Transfer(address(this), msg.sender, amount+interest);

        return true;
    }

    //////////////////////////
    function Mint(address user, uint amount) internal returns(bool) {
        balanceOf[user] += amount;
        totalSupply += amount;
        if (firstSeen[user]==0)
        firstSeen[user]=block.timestamp;
        emit Transfer(address(this), user, amount);
        return true;
    }
}