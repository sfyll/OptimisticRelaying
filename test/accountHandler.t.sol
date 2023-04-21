// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/console.sol";

import {AccountHandler} from"src/lib/accountHandler.sol";
import {Fixture} from "test/fixture.sol";

contract AccountHandlerTest is Fixture {
    AccountHandler accountHandler;

    //@dev: we use any bytes array as a fake bls address since
    //we manipulate their sha256 hash which is of size 32 bytes
    function testDeposit(uint256 value, bytes[] memory fakeBlsAddy) public accountHandlerFuzzingParams(value, fakeBlsAddy) {
        accountHandler = newAccountHandler();
        
        bytes32[] memory hashCommitedBlsAddress = getHashCommitedBlsAddress(fakeBlsAddy);
        
        accountHandler.deposit{value: value}(hashCommitedBlsAddress);

        uint256 balance = address(accountHandler).balance;
        bytes32[] memory inContractHashedBlsAdd = accountHandler.getBuilderHashCommitedBlsAddress(address(this));

        assertEq(balance, value, "The contract balance should be 1 ether after deposit");
        assertEq(keccak256(abi.encodePacked(inContractHashedBlsAdd)), keccak256(abi.encodePacked(hashCommitedBlsAddress)), "Contract Commited Address should be the one we commited");
    }


    function testAdd(uint256 value, bytes[] memory fakeBlsAddy) public accountHandlerFuzzingParams(value, fakeBlsAddy) {
        accountHandler = newAccountHandler();
        
        bytes32[] memory hashCommitedBlsAddress1 = new bytes32[](0);
        accountHandler.deposit{value: value}(hashCommitedBlsAddress1);

        bytes32[] memory hashCommitedBlsAddress2 = new bytes32[](1);
        hashCommitedBlsAddress2[0] = sha256(abi.encodePacked("BLS_ADDRESS_2"));
        accountHandler.add(hashCommitedBlsAddress2);

        uint256 balance = address(accountHandler).balance;
        assertEq(balance, value, "The contract balance should be 1 ether after add");
    }

    function testInstantiateTransfer(uint256 value) public {
        bytes32[] memory hashCommitedBlsAddress = new bytes32[](0);
        accountHandler.deposit{value: value}(hashCommitedBlsAddress);

        accountHandler.instantiateTransfer();
        uint256 releaseTime = accountHandler.getBuilderReleaseTime(address(this));

        assertTrue(releaseTime > 0, "The release time should be set after initiateTransfer");
    }

    function testWithdraw(uint256 value) public {
        vm.deal(address(this), 1 ether);
        bytes32[] memory hashCommitedBlsAddress = new bytes32[](0);
        accountHandler.deposit{value: value}(hashCommitedBlsAddress);

        accountHandler.instantiateTransfer();
        uint256 releaseTime = accountHandler.getBuilderReleaseTime(address(this));

        uint256 currentTimestamp = block.timestamp;
        vm.warp(7 days);
        uint256 newTimestamp = block.timestamp;

        assertTrue(newTimestamp > releaseTime, "The new timestamp should be greater than the release time");

        address payable recipient = payable(address(0x123));
        uint256 recipientInitialBalance = recipient.balance;

        accountHandler.withdraw{value: value}(recipient);
        uint256 recipientFinalBalance = recipient.balance;

        assertEq(recipientFinalBalance, recipientInitialBalance + value, "The recipient balance should increase by 1 ether after withdrawal");
    }
}
