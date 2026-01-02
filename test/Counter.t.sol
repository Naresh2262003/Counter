
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {MyContract} from "../src/MyContract.sol";

contract MyContractTest is Test{

    MyContract public myContract;

    function setUp() public {
        myContract = new MyContract();
    }

    function testSetName() public {
        myContract.setName("Bob");
        assertEq(myContract.getName(), "Bob");
    }

    function testSetAge() public{
        myContract.setAge(25);
        assertEq(myContract.getAge(), 25);

        vm.expectRevert(bytes("Age must be greater than 0"));
        myContract.setAge(0); 

        assertEq(myContract.getAge(), 25); 
    }

    function testSetStudentStatus() public {
        myContract.setStudentStatus(true);
        assertEq(myContract.getStudentStatus(), true);

        myContract.setStudentStatus(false);
        assertEq(myContract.getStudentStatus(), false);
    }

    function testFuzz_SetName(string memory name) public {
        myContract.setName(name);
        assertEq(myContract.getName(), name);
    }

    function testFuzz_SetAge(uint256 age) public{
        if( age > 0 ){
            myContract.setAge(age);
            assertEq(myContract.getAge(), age);
        } else {
            vm.expectRevert(bytes("Age must be greater than 0"));
            myContract.setAge(age);
        }
    }

    function testFuzz_SetStudentStatus(bool status) public {
        myContract.setStudentStatus(status);
        assertEq(myContract.getStudentStatus(), status);
    }
}
