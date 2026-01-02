pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {MyContract} from "../src/MyContract1.sol";

contract MyContractTest is Test{

    MyContract public myContract;

    function setUp() public {
        myContract = new MyContract();
    }

    function testEmitAgeChanged() public {
        vm.expectEmit(false, false, false, true);

        emit MyContract.AgeChanged(address(this), 25);

        // 3. THE ACTION (Trigger)
        // This function MUST emit the event exactly as above, or test fails.
        myContract.setAge(25);
    }

    function testEmitNameChanged() public {
        vm.expectEmit(false, false, false, true);

        emit MyContract.NameChanged("", "Alice");

        myContract.setName("Alice");
    }

    function testEmitStatusChanged() public {
        vm.expectEmit(false, false, false, true);

        emit MyContract.StatusChanged(true);

        myContract.setStatus(true);
    }

    function testEmitResetAge() public {
        // 1. SETUP: We must set the age to 30 first!
        myContract.setAge(30);

        // 2. EXPECTATION
        vm.expectEmit(false, false, false, true);
        emit MyContract.AgeReset(address(this), 30);

        // 3. ACTION
        myContract.resetAge();
    }
    
}
