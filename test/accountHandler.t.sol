// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/console.sol";

import {AccountHandler} from "src/lib/accountHandler.sol";
import {Fixture} from "test/lib/fixture.sol";

contract AccountHandlerTest is Fixture {
    AccountHandler accountHandler;

    function testDeposit(uint256 value, bytes[] memory fakeBlsAddy) public {
        accountHandler = newAccountHandler();

        (uint256 value, bytes32[] memory hashCommitedBlsAddress) = depositAndGetHashOfCommitedBlsAddressFuzzing(value, fakeBlsAddy, accountHandler);

        uint256 balance = address(accountHandler).balance;
        bytes32[] memory inContractHashedBlsAdd = accountHandler.getBuilderHashCommitedBlsAddress(address(this));

        assertEq(balance, value, "The contract balance should be deposit ether after deposit");
        assertEq(keccak256(abi.encodePacked(inContractHashedBlsAdd)), keccak256(abi.encodePacked(hashCommitedBlsAddress)), "Contract Commited Address should be the one we commited");
    }

    function testAdd(uint256 deposit, uint256 addedCollateral, bytes[] memory fakeBlsAddyDeposit,
                     bytes[] memory fakeBlsAddyAdd) public {
        accountHandler = newAccountHandler();

        (uint256 deposit, bytes32[] memory hashCommitedBlsAddressDeposit) = depositAndGetHashOfCommitedBlsAddressFuzzing(deposit, fakeBlsAddyDeposit, accountHandler);

        addedCollateral = accountHandlerFuzzingParamsAdd(addedCollateral, fakeBlsAddyAdd);

        bytes32[] memory hashCommitedBlsAddressAdd = getHashCommitedBlsAddress(fakeBlsAddyAdd);

        accountHandler.add{value: addedCollateral}(hashCommitedBlsAddressAdd);

        uint256 balance = address(accountHandler).balance;

        bytes32[] memory inContractHashedBlsAdd = accountHandler.getBuilderHashCommitedBlsAddress(address(this));
        bytes32[] memory ourCommittedHashedBlsAddies = aggregateBlsAddressHashes(hashCommitedBlsAddressDeposit, hashCommitedBlsAddressAdd);

        assertEq(balance, deposit + addedCollateral, "The contract balance should be deposit + addedCollateral ether after deposit");
        assertEq(keccak256(abi.encodePacked(inContractHashedBlsAdd)), keccak256(abi.encodePacked(ourCommittedHashedBlsAddies)), "Contract Commited Address should be the one we commited");    
    }

    function testInstantiateTransfer(uint256 value, bytes[] memory fakeBlsAddy) public {
        accountHandler = newAccountHandler();
        
        (uint256 value, bytes32[] memory __) = depositAndGetHashOfCommitedBlsAddressFuzzing(value, fakeBlsAddy, accountHandler);

        accountHandler.instantiateTransfer();
        uint256 releaseTime = accountHandler.getBuilderReleaseTime(address(this));

        assertTrue(releaseTime > 0, "The release time should be set after initiateTransfer");
    }

    function testWithdraw(uint256 value, bytes[] memory fakeBlsAddy) public {
        accountHandler = newAccountHandler();

        (uint256 value, bytes32[] memory hashCommitedBlsAddress) = depositAndGetHashOfCommitedBlsAddressFuzzing(value, fakeBlsAddy, accountHandler);

        accountHandler.instantiateTransfer();
        uint256 releaseTime = accountHandler.getBuilderReleaseTime(address(this));

        uint256 currentTimestamp = block.timestamp;
        vm.warp(8 days);
        uint256 newTimestamp = block.timestamp;

        assertTrue(newTimestamp > releaseTime, "The new timestamp should be greater than the release time");

        address payable recipient = payable(address(0x123));
        uint256 recipientInitialBalance = recipient.balance;

        accountHandler.withdraw{value: value}(recipient);
        uint256 recipientFinalBalance = recipient.balance;

        assertEq(recipientFinalBalance, recipientInitialBalance + value, "The recipient balance should increase by 1 ether after withdrawal");
    }
}
