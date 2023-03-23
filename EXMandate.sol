// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
interface EX{
    function getTruAt(uint index) external view returns(address);
    function getAccAt(uint index) external view returns(address);
    function isVoter(address _voter) external view returns(bool);
    function listVoters() external view returns(address[] memory adds);
}
interface XEX{
    function updateAccountFee(uint _new) external returns (bool);
    function updateInterestRate(uint _new) external returns (bool);
    function mine(uint amount) external returns (bool);
    function updateDecimals(uint _new) external returns (bool);
}
interface Vend{
    function updateToMint(uint no) external returns (bool);
}
interface Payments{
    function updateTruLaunch(uint _new) external returns (bool);
    function updateMBPrice(uint _new) external returns (bool);
}
interface Oracle{
    function updateXEXUSD(uint _new) external returns (bool);
}
contract EXMandate{
    uint[] public mtypes=[
        0, //XEX account fee
        1, //XEX interest rate
        2, //XEX Mine to admin
        3, //XEX add to Mint
        4, //TruCode Price
        5, //MB space price
        6, //XEX2USD unit
        7 //XEX decimals
    ];
    struct round{
        uint mtype;
        uint started;
        uint value;
        bool spent;
    }

    uint public mandateNo;
    mapping (uint => mapping(address => bool)) public voted;
    mapping (uint => round) public mandates;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;
    uint public mandateTime=30 days;

    function updateBase(address _new) public returns (bool){
        require(EX(EXBase).getAccAt(0)==msg.sender); //admin
        EXBase=_new;
        return true;
    }
    function updateMandateTime(uint _new) public returns (bool){
        require(EX(EXBase).getAccAt(0)==msg.sender); //admin
        mandateTime=_new;
        return true;
    }
    function getCurrentMandateNo() public view returns (uint){
        return mandateNo;
    }
    function startPetition(uint _no, uint _mtype, uint _value) public returns (bool){
        require (EX(EXBase).isVoter(msg.sender));
        require(_no==mandateNo+1);
        mandateNo+=1;
        mandates[mandateNo]=round(_mtype,block.timestamp,_value,false);
        return true;
    }
    function getPetition(uint _no) public view returns(uint, uint, uint, bool){
        return (mandates[_no].mtype, mandates[_no].value, mandates[_no].started, mandates[_no].spent);
    }
    function hasVoted(uint _no, address _m) public view returns (bool){
        return voted[_no][_m];
    }
    function isVoter(address _tochech) public view returns(bool){
        return EX(EXBase).isVoter(_tochech);
    }
    function vote(uint _no) public returns (bool){
        require (EX(EXBase).isVoter(msg.sender));
        require(_no<=mandateNo);
        require(voted[_no][msg.sender]==false);
        require(mandates[_no].spent==false);
        require (mandates[_no].started+mandateTime>=block.timestamp);

        voted[_no][msg.sender]=true;
        address[] memory voters=EX(EXBase).listVoters();
        uint total=0;
        uint votes=0;
        for (uint i=0;i<voters.length;i++){
            if (voted[_no][voters[i]]==true)
            votes++;
            total++;
        }
        if (votes>(total/2)){
            if (mandates[_no].mtype==0){
                XEX(EX(EXBase).getTruAt(2)).updateAccountFee(mandates[_no].value);
            }
            if (mandates[_no].mtype==1){
                XEX(EX(EXBase).getTruAt(2)).updateInterestRate(mandates[_no].value);
            }
            if (mandates[_no].mtype==2){
                XEX(EX(EXBase).getTruAt(2)).mine(mandates[_no].value);
            }
            if (mandates[_no].mtype==3){
                Vend(EX(EXBase).getTruAt(5)).updateToMint(mandates[_no].value);
            }
            if (mandates[_no].mtype==4){
                Payments(EX(EXBase).getTruAt(3)).updateTruLaunch(mandates[_no].value);
            }
            if (mandates[_no].mtype==5){
                Payments(EX(EXBase).getTruAt(3)).updateMBPrice(mandates[_no].value);
            }
            if (mandates[_no].mtype==6){
                Oracle(EX(EXBase).getTruAt(4)).updateXEXUSD(mandates[_no].value);
            }
            if (mandates[_no].mtype==7){
                XEX(EX(EXBase).getTruAt(2)).updateDecimals(mandates[_no].value);
            }
            mandates[_no].spent=true;
        }
        return true;
    }
}