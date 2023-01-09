// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Test {
    uint256 public testvalue;

    function testFunc(uint amount) public returns(uint) {
        testvalue = testvalue + amount;
        return testvalue;
    }
}