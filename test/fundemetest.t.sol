// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/fundme.sol";
import {deployfundMe} from "../script/fundMe.s.sol";
// import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract fundmetest is Test {
    FundMe fundme;
    address user = makeAddr("user");

    function setUp() public {
        deployfundMe DeployFundMe = new deployfundMe();
        fundme = DeployFundMe.run();
        vm.deal(user, 100 ether);
    }

    function testMinUsd() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testcheckOwner() public {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testVersion() public {
        console.log(fundme.getVersion());
        assertEq(fundme.getVersion(), 4);
    }

    function testFund() public {
        vm.expectRevert();
        fundme.fund();
    }

    modifier fundAlways() {
        vm.prank(user);
        fundme.fund{value: 1e18}();
        _;
    }

    function testFundMeFundedEnoughEth() public fundAlways {
        assertEq(fundme.getAdderssOfFunders(user), 1e18);
        assertEq(fundme.getFunders(0), user);
    }

    function testWithdraw() public fundAlways {
        vm.expectRevert();
        vm.prank(user);
        fundme.withdraw();
    }

    function testOwner() public fundAlways {
        uint256 balance = fundme.getOwner().balance;
        uint256 startingFundMebalance = address(fundme).balance;

        //Act
        uint256 gasLeftt = gasleft();
        vm.txGasPrice(1);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 gasLeft2 = gasleft();
        uint256 gastotalUSED = (gasLeftt - gasLeft2) * tx.gasprice;
        console.log(gastotalUSED);

        //test
        uint256 endingFundmeBalance = address(fundme).balance;
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        assertEq(endingFundmeBalance, 0);
        assertEq(startingFundMebalance + balance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleOwner() public {
        for (uint160 i = 1; i < 10; i++) {
            hoax(address(i), 2e18);
            fundme.fund{value: 1e18}();
        }

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        for (uint160 i = 1; i < 10; i++) {
            assertEq(fundme.getAdderssOfFunders(address(i)), 0);
        }
    }
}
