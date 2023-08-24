// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/fundme.sol";
import {deployfundMe} from "../../script/fundMe.s.sol";
import {Interaction} from "../../script/Interaction.s.sol";

contract IntegrationTest is Test {
    FundMe fundme;
    address user = makeAddr("user");

    function setUp() public {
        deployfundMe DeployFundMe = new deployfundMe();
        fundme = DeployFundMe.run();
        vm.deal(user, 100 ether);
    }
 modifier fundAlways() {
        vm.prank(user);
        fundme.fund{value: 1e18}();
        _;
    }
    function testUser() public{
        Interaction interactionbyuser = new Interaction();
        interactionbyuser.fundContract(address(fundme));
        vm.prank(user);
        assertEq(fundme.getAdderssOfFunders(msg.sender), 1e18);
        assertEq(fundme.getFunders(0), msg.sender);
    }
}