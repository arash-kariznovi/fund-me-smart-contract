// SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SENT_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSD() public view {
        uint256 price = 5e18;
        assertEq(fundMe.MINIMUM_USD(), price);
    }

    function testOwnerIsMessageSender() public view {
        // us(msg.sender=> call the first contract) => fundMeTest(owner) => fundMe
        // in this case since we use vm.startBroadCast() the msg.sender is the FundMe itself
        // console.log(fundMe.i_owner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersion() public view {
        uint version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFailsWithoutEnoughEth() public {
        vm.expectRevert("Must be larger than $5");
        fundMe.fund{value:0}();

        // fundMe.fund();
    }

    function testAmountFundedOnDataStructure() public {
        vm.prank(USER); // the next tx will be sent by USER
        fundMe.fund{value: SENT_VALUE}();

        uint256 fund = fundMe.getAddressToAmountFunded(USER);
        assertEq(fund, SENT_VALUE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SENT_VALUE}();
        _;
    }

    function testAddsFundersToArrayOfFunders() public funded {
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithASingleFunder() public funded {
        //  Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //  Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Asset
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        console.log(startingOwnerBalance);
        console.log(startingFundMeBalance);
        console.log(endingOwnerBalance);
        console.log(endingFundMeBalance);
        console.log(fundMe.getOwner());
        assertEq(endingOwnerBalance, startingOwnerBalance+startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);

    }

    function testWithdrawMultipleFunders() public funded{
        // Arrange
        // must be uint160 to be converted to an address
        uint160 numberOfFunders = 15;
        uint160 indexOfFunders = 1;

        for(uint160 i = indexOfFunders; i<numberOfFunders;i++){
            hoax(address(i), SENT_VALUE);
            fundMe.fund{value:SENT_VALUE}();
        }

        uint256 fundMeStartingBalance = address(fundMe).balance;
        uint256 ownerStartingBalance = fundMe.getOwner().balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // assert
        console.log(fundMeStartingBalance);
        console.log(ownerStartingBalance);
        console.log(address(fundMe).balance);
        console.log(fundMe.getOwner().balance);
        assert(address(fundMe).balance==0);
        assert(fundMeStartingBalance + ownerStartingBalance ==fundMe.getOwner().balance);

    }
    // 1. Unit: testing a specific part of our code
    // 2. Fork: testing our code on a simulated real environment
    // 3. Integration: testing how our code is working with other part of our code
    // 4. Staging: testing in a real enironment that is not production


    function testWithdrawMultipleFundersCheaper() public funded{
        // Arrange
        // must be uint160 to be converted to an address
        uint160 numberOfFunders = 15;
        uint160 indexOfFunders = 1;

        for(uint160 i = indexOfFunders; i<numberOfFunders;i++){
            hoax(address(i), SENT_VALUE);
            fundMe.fund{value:SENT_VALUE}();
        }

        uint256 fundMeStartingBalance = address(fundMe).balance;
        uint256 ownerStartingBalance = fundMe.getOwner().balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // assert
        console.log(fundMeStartingBalance);
        console.log(ownerStartingBalance);
        console.log(address(fundMe).balance);
        console.log(fundMe.getOwner().balance);
        assert(address(fundMe).balance==0);
        assert(fundMeStartingBalance + ownerStartingBalance ==fundMe.getOwner().balance);

    }
  
}
