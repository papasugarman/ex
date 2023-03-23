// SPDX-License-Identifier: Copyright
pragma solidity ^0.8.13;
contract EXBase{

address[] public voters;

    function addVoter(address _voter) public returns(bool){
        require(isMandated(msg.sender) || msg.sender==EXAccounts[0]); //
        voters.push(_voter);
        return true;
    }
    function removeVoter(address _voter) public returns(bool){
        require(isMandated(msg.sender) || msg.sender==EXAccounts[0]); //
        for (uint i=0;i<voters.length;i++)
        if(voters[i]==_voter){
            remove(i);
            break;
        }
        return true;
    }
    function listVoters() public view returns(address[] memory adds){
        return voters;
    }
    function isVoter(address _voter) public view returns(bool){
        for (uint i=0;i<voters.length; i++)
        if (voters[i]==_voter)
        return true;
        return false;
    }
    function remove(uint index) internal {
        voters[index] = voters[voters.length - 1];
        voters.pop();
    }

    //////////////////////////
    address[] public EXAccounts=[
        0x92C5550FC5710400C1fe109638C0B5cE4a734D03, //base
        0x17259f1e80eDDEdc4d4aD2BF8be989A16eDc37db, //mandate
        0xca0992DeE311a05a70DB08c75eF5c394806Ba464, //xex
        0x0FBb8d0dF9d3f11b509a340F82e98D521549167D, //payments
        0x7e22Ae05a33cE9e271E2DF4Bff3c0032E6ac0Bf6, //oracle
        0x33848eDFe05bc58c9Bc9Acd591121cD44bB1B24f, //exchange
        0x49dB2fbe5f8A54504F822697639D98b8C9d5324b, //notices
        0xB25D6a0128b9EC5B3A26f7B57b8755F33e56ad50 //aliases
        ];

    address[] public EXTruCodes=[
        0x3DCc5D3f52165f68C176e39B158558f9124f1E26, //base
        0x76178F72C2B07113F78C85072F397e08bEA06723, //mandate
        0x5bE78C348d4cF921f4780C57861F0A7492B90dC3, //xex
        0x6fe0f9d0E5C19D5d505C87E03C4814aFEba5DD8c, //payments
        0xb06A6A809f01001F6223539e07a7231A64283625, //oracle
        0x022516Ac3be097f56ccc9eAe22aCB8f1D147765a, //exchange
        0x2717cF2a2AC9717449459b8e242C714ac430D1AE, //notices
        0x54Ebc90AC32c14d3F9367926334B29B727Cc4Ab1 //aliases
    ];

    bool public admin_relinquish=false;

    function getTruAt(uint index) public view returns(address){
        return EXTruCodes[index];
    }
    function getAccAt(uint index) public view returns(address){
        return EXAccounts[index];
    }
    function updateEXAccount (uint index, address _new) public returns (bool){
        require(isMandated(msg.sender) || msg.sender==EXAccounts[0]); //
        EXAccounts[index]=_new;
        return true;
    }
    function updateEXTruCode (uint index, address _new) public returns (bool){
        require(isMandated(msg.sender) || msg.sender==EXAccounts[0]); //
        EXTruCodes[index]=_new;
        return true;
    }
    function relinquishAdminControl(bool status) public returns (bool){
        require(msg.sender==EXAccounts[0]);
        admin_relinquish=status;
        return true;
    }
    function isMandated(address toCheck) public view returns (bool){
        if(toCheck==EXAccounts[0] && !admin_relinquish) return true;
        if(toCheck==EXTruCodes[1]) return true;
        return false;
    }
    function isXEX(address user) public view returns (bool){
        if(user==EXTruCodes[2])
        return true;
        return false;
    }
    function isOracle(address user) public view returns (bool){
        if(user==EXTruCodes[4] || user==EXAccounts[4])
        return true;
        return false;
    }
}