// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address Address_User = makeAddr("User");
    uint256 constant SEND_VALUE = 0.1 ether; // 0.1 ETH in wei
    uint256 constant Current_Value = 1 ether; // 1 ETH in wei

    function setUp() external {
        //FundMe fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(Address_User, Current_Value); // Give the user some ether
    }

    function testMiniumDollerIsFive() public view {
       
        assertEq(fundme.MINIMUM_USD(), 5 * 10 ** 18);
    }
    function testOwnerIsMsgSender() public view {
        console.log("i_owner: ", fundme.getOwner());
        console.log("msg.sender: ", msg.sender);
        assertEq(fundme.getOwner(), msg.sender);
    }
    function testVersionIsCorrect() public view{
         assertEq(fundme.getVersion(), 4);          
    }
    function testMinimunUsdFail() public {
        // This test will fail if the minimum USD is not set to 5 ETH
        vm.expectRevert();
        fundme.fund();
    }
    modifier Funded {
        vm.prank(Address_User);
        fundme.fund{value: SEND_VALUE}();
        _;
    }
    function testFundUpdateFundDatastructure() public Funded{
        // Check if the addressToAmountFunded mapping is updated correctly
        uint256 amountFunded = fundme.getAddressToAmountFunded(Address_User);
        assertEq(amountFunded, SEND_VALUE);
    }
    function testAddFunderTFunderArray() public Funded{
        // Check if the funder is added to the funders array
        address funder = fundme.getFunder(0);
        assertEq(funder, Address_User);
    }
    function testOnlyOwnerCanWithdraw() public Funded{
        vm.prank(Address_User);
        vm.expectRevert();
        fundme.withdraw();
    }
    function testWithdrawWithSingleFunder() public Funded {
        uint256 StartingOwnerBalance = fundme.getOwner().balance;
        uint256 StartingFundMeBalance =address(fundme).balance;
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 EndingOwnerBalance = fundme.getOwner().balance;
        uint256 EndingFundMeBalance = address(fundme).balance;
        assertEq(EndingFundMeBalance, 0);
        assertEq(EndingOwnerBalance, StartingFundMeBalance + StartingOwnerBalance);
    }
    function testWithdrawWithMultipleFunders() public Funded {
        uint160 NumberOfFunders =10;
        uint160 StartingFunderIndex = 1;
        for(uint160 i =StartingFunderIndex;i< NumberOfFunders; i++){
            // vm.deal(address(i), SEND_VALUE);
            // vm.prank(address(i));
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 StartingOwnerBalance = fundme.getOwner().balance;
        uint256 StartingFundMeBalance = address(fundme).balance;
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 EndingOwnerBalance = fundme.getOwner().balance;
        uint256 EndingFundMeBalance = address(fundme).balance;
        assertEq(EndingFundMeBalance, 0);
        assertEq(EndingOwnerBalance, StartingFundMeBalance + StartingOwnerBalance); 
    }
}
