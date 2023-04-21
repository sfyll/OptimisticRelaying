// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/console.sol";

import {OptimisticRelaying} from "src/OptimisticRelaying.sol";
import {Fixture} from "test/lib/fixture.sol";
import {BidTrace} from "../src/lib/SSZUtilities.sol";

contract OptimisticRelayingTest is Fixture {
    
    OptimisticRelaying public optimisticRelaying;

    BidTrace public bidTrace;
    DataForVerification public bidTraceVerificationData;
    
    function setUp() public {
        string memory root = vm.projectRoot();
        
        (bidTrace, bidTraceVerificationData) = loadBeaconBidTraceAndSig(root);

        vm.deal(address(this), 10 ether);

        optimisticRelaying = new OptimisticRelaying(bidTrace.slot);
    }

    ///@dev not need to fuzz test deposit logic as it is done in accountHandler.t.sol
    function testVerifyBlsAddressWasCommitedAndgetHashCommitedBlsAddress() public {
        uint256 value = 5 ether;

        bytes[] memory builderPubKeys = new bytes[](1);
        builderPubKeys[0] = abi.encodePacked(bidTrace.builderPubkey);

        bytes32[] memory hashCommitedBlsAddressExpected = depositAndGetHashOfCommitedBlsAddress(value, builderPubKeys, optimisticRelaying);

        bytes32[] memory hashCommitedBlsAddressActual = optimisticRelaying.getHashCommitedBlsAddress(builderPubKeys);

        assertEq(keccak256(abi.encodePacked(hashCommitedBlsAddressExpected)), keccak256(abi.encodePacked(hashCommitedBlsAddressActual)), "Contract Commited Address should be the one we commited");   

        assertEq(optimisticRelaying.verifyBlsAddressWasCommited(builderPubKeys[0], address(this)), true, "Should fine the address as commited"); 
    }

    function testFailVerifyBlsAddressWasCommitedAndgetHashCommitedBlsAddress() public {
        bytes[] memory builderPubKeys = new bytes[](1);
        builderPubKeys[0] = abi.encodePacked(bidTrace.builderPubkey);

        require(optimisticRelaying.verifyBlsAddressWasCommited(builderPubKeys[0], address(this)));
    }

}
    