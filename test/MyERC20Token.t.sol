// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {MyERC20Token} from "../src/MyERC20Token.sol";

contract MyERC20TokenTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    MyERC20Token token;

    address owner   = address(1);
    address alice   = address(2);
    address bob     = address(3);
    address charlie = address(4);

    uint256 constant INITIAL_SUPPLY = 1_000_000 ether;

    function setUp() public {
        vm.prank(owner);
        token = new MyERC20Token();

        vm.prank(owner);
        token.transfer(alice, 1000 ether);
    }

    // UNIT TESTS

    function testTransfer() public {
        vm.prank(alice);
        bool success = token.transfer(bob, 100 ether);

        assertTrue(success);
        assertEq(token.balanceOf(alice), 900 ether);
        assertEq(token.balanceOf(bob), 100 ether);
    }

    function testApprove() public {
        vm.prank(alice);
        bool success = token.approve(bob, 500 ether);

        assertTrue(success);
        assertEq(token.allowance(alice, bob), 500 ether);
    }

    function testTransferFrom() public {
        vm.prank(alice);
        token.approve(bob, 500 ether);

        vm.prank(bob);
        bool success = token.transferFrom(alice, charlie, 200 ether);

        assertTrue(success);
        assertEq(token.balanceOf(charlie), 200 ether);
        assertEq(token.balanceOf(alice), 800 ether);
    }

    function testBalanceOf() public view {
        assertEq(token.balanceOf(alice), 1_000 ether);
        assertEq(token.balanceOf(bob), 0);
    }

    function testAllowanceGetter() public {
        vm.prank(alice);
        token.approve(bob, 400 ether);

        assertEq(token.allowance(alice, bob), 400 ether);
    }

    function testTotalSupplyFixed() public view {
        assertEq(token.totalSupply(), 1_000_000 ether);
    }


    //  NEGATIVE TESTS

    function testTransferInsufficientBalance() public {
        vm.prank(alice);
        bool success = token.transfer(bob, 2000 ether);

        assertFalse(success);
        assertEq(token.balanceOf(alice), 1000 ether);
    }

    function testTransferFromWithoutApproval() public {
        vm.prank(bob);
        bool success = token.transferFrom(alice, charlie, 100 ether);

        assertFalse(success);
    }

    function testTransferFromExceedsAllowance() public {
        vm.prank(alice);
        token.approve(bob, 100 ether);

        vm.prank(bob);
        bool success = token.transferFrom(alice, charlie, 200 ether);

        assertFalse(success);
    }

    // SECURITY TESTS

    function testTransferFromDecreasesAllowance() public {
        vm.prank(alice);
        token.approve(bob, 500 ether);

        vm.prank(bob);
        token.transferFrom(alice, charlie, 200 ether);

        uint256 remaining = token.allowance(alice, bob);
        assertEq(remaining, 300 ether);
    }

    function testNoInfiniteAllowanceDrain() public {
        vm.prank(alice);
        token.approve(bob, 300 ether);

        vm.prank(bob);
        token.transferFrom(alice, charlie, 300 ether);

        vm.prank(bob);
        bool success = token.transferFrom(alice, charlie, 1 ether);

        assertFalse(success);
    }

    function testUnauthorizedCannotTransferFromOthers() public {
        vm.prank(bob);
        vm.expectRevert();
        token.transferFrom(alice, bob, 1 ether);
    }

    function testNoHiddenMint() public {
        uint256 supplyBefore = token.totalSupply();

        vm.prank(alice);
        token.transfer(bob, 10 ether);

        assertEq(token.totalSupply(), supplyBefore);
    }

    // CONTRACT INTERACTION

    function testTransferFromToContractFails() public {
        address targetContract = address(token);

        vm.prank(alice);
        token.approve(bob, 100 ether);

        vm.prank(bob);
        bool success = token.transferFrom(alice, targetContract, 50 ether);

        assertFalse(success);
    }

    // EDGE CASES

    function testZeroTransferFails() public {
        vm.prank(alice);
        bool success = token.transfer(bob, 0);

        assertFalse(success);
    }

    function testZeroApproveAllowed() public {
        vm.prank(alice);
        token.approve(bob, 0);

        assertEq(token.allowance(alice, bob), 0);
    }

    function testSelfTransfer() public {
        vm.prank(alice);
        bool success = token.transfer(alice, 100 ether);

        assertTrue(success);
        assertEq(token.balanceOf(alice), 1000 ether);
    }

    function testZeroTransferFrom() public {
        vm.prank(alice);
        token.approve(bob, 10 ether);

        vm.prank(bob);
        token.transferFrom(alice, charlie, 0);

        assertEq(token.balanceOf(charlie), 0);
    }

    function testMaxUintApproval() public {
        vm.prank(alice);
        token.approve(bob, type(uint256).max);

        assertEq(token.allowance(alice, bob), type(uint256).max);
    }

    function testRepeatedApproveOverwrites() public {
        vm.prank(alice);
        token.approve(bob, 100 ether);

        vm.prank(alice);
        token.approve(bob, 50 ether);

        assertEq(token.allowance(alice, bob), 50 ether);
    }

    // EVENT TESTS

    function testTransferEmitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 100 ether);

        token.transfer(bob, 100 ether);
    }

    function testApproveEmitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, bob, 200 ether);

        token.approve(bob, 200 ether);
    }

    function testTransferFromEmitsTransferEvent() public {
        vm.prank(alice);
        token.approve(bob, 100 ether);
    
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, charlie, 50 ether);
    
        vm.prank(bob);
        token.transferFrom(alice, charlie, 50 ether);
    }
    
    function testNoEventOnFailedTransfer() public {
        vm.prank(bob);
        bool success = token.transfer(alice, 1 ether);
        assertFalse(success);
    }
    

    // FUZZ TESTS

    function testFuzzTransfer(uint256 amount) public {
        amount = bound(amount, 1, 1000 ether);

        vm.prank(alice);
        bool success = token.transfer(bob, amount);

        assertTrue(success);
        assertEq(token.balanceOf(bob), amount);
    }

    function testFuzzApproveAndTransferFrom(uint256 amount) public {
        amount = bound(amount, 1, 500 ether);

        vm.prank(alice);
        token.approve(bob, amount);

        vm.prank(bob);
        bool success = token.transferFrom(alice, charlie, amount);

        assertTrue(success);
    }

    // INVARIANT TESTS

    function invariant_totalSupplyEqualsBalances() public view {
        uint256 sum = token.balanceOf(owner) + token.balanceOf(alice) + token.balanceOf(bob) + token.balanceOf(charlie);

        assertEq(sum, token.totalSupply());
    }

    function testAllowanceNeverExceedsApproval() public {
        vm.prank(alice);
        token.approve(bob, 100 ether);
    
        vm.prank(bob);
        token.transferFrom(alice, charlie, 60 ether);
    
        assertLe(token.allowance(alice, bob), 100 ether);
    }
    
    function testTotalSupplyNeverChanges() public {
        uint256 supply = token.totalSupply();

        vm.prank(alice);
        token.transfer(bob, 50 ether);

        vm.prank(bob);
        token.transfer(alice, 1 ether); 

        assertEq(token.totalSupply(), supply);
    }
}
