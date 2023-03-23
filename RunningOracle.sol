// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface EX{
    function getTruAt(uint index) external view returns(address);
    function getAccAt(uint index) external view returns(address);
}
contract RunningOracle{
    bool public flag=false;
    address public EXBase = 0x3DCc5D3f52165f68C176e39B158558f9124f1E26;

    function pingFromOracle() public returns (bool){
        require(EX(EXBase).getAccAt(4)==msg.sender || EX(EXBase).getTruAt(4)==msg.sender);
        flag=true;
        return true;
    } 
}