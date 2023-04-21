// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/console.sol";

import {BidTrace, SSZUtilities} from "../src/lib/SSZUtilities.sol";
import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
import {BytesLib} from "telepathy-contracts/src/libraries/MessageEncoding.sol";
import {Fixture} from "test/lib/fixture.sol";

contract SSZUtilitiesTest is Fixture {

    SSZUtilities public SSZutilities;

    BeaconBlockHeader public header;
    DataForVerification public headerVerificationData;
    
    BidTrace public bidTrace;
    DataForVerification public bidTraceVerificationData;
    
    function setUp() public {
        SSZutilities = new SSZUtilities();

        string memory root = vm.projectRoot();

        (header, headerVerificationData) = loadBeaconBlockHeaderAndSig(root);
        
        (bidTrace, bidTraceVerificationData) = loadBeaconBidTraceAndSig(root);

    }

    function test_getHashTreeRootBlockHeader() public view {
        bytes32 hashTreeRoot = SSZutilities.getHashTreeRootBlockHeader(header);
        assert(hashTreeRoot == headerVerificationData.hashTreeRoot);
    }

    function test_getHashTreeRootBidTrace() public view {
        bytes32 hashTreeRoot = SSZutilities.getHashTreeRootBidTrace(bidTrace);
        assert(hashTreeRoot == bidTraceVerificationData.hashTreeRoot);
    }

    function test_getSigningRootBeaconBlockHeader() public view {
        bytes32 signingRoot = SSZutilities.getSigningRootBeaconBlockHeader(header, headerVerificationData.domain);
        assert(signingRoot == headerVerificationData.signingRoot);
    }

    function test_getSigningRootBidTrace() public view {
        bytes32 signingRoot = SSZutilities.getSigningRootBidTrace(bidTrace, bidTraceVerificationData.domain);
        assert(signingRoot == bidTraceVerificationData.signingRoot);
    }
}