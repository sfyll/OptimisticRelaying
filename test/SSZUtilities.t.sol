// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/console.sol";

import {BidTrace, SSZUtilities} from "../src/lib/SSZUtilities.sol";
import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
import {BytesLib} from "telepathy-contracts/src/libraries/MessageEncoding.sol";
import {Fixture} from "test/lib/fixture.sol";

/// @title SSZUtilitiesTest
/// @notice SSZUtilitiesTest contract for testing SSZUtilities functionality.
contract SSZUtilitiesTest is Fixture {

    BeaconBlockHeader public header;
    DataForVerification public headerVerificationData;
    
    BidTrace public bidTrace;
    DataForVerification public bidTraceVerificationData;
    
     /// @notice Sets up the initial state for the test cases.
    function setUp() public {

        string memory root = vm.projectRoot();

        (header, headerVerificationData) = loadBeaconBlockHeaderAndSig(root);
        
        (bidTrace, bidTraceVerificationData) = loadBeaconBidTraceAndSig(root);

    }

    /// @notice Tests the getHashTreeRootBlockHeader functionality of SSZUtilities.
    function test_getHashTreeRootBlockHeader() public view {
        bytes32 hashTreeRoot = SSZUtilities.getHashTreeRootBlockHeader(header);
        assert(hashTreeRoot == headerVerificationData.hashTreeRoot);
    }

    /// @notice Tests the getHashTreeRootBidTrace functionality of SSZUtilities.
    function test_getHashTreeRootBidTrace() public view {
        bytes32 hashTreeRoot = SSZUtilities.getHashTreeRootBidTrace(bidTrace);
        assert(hashTreeRoot == bidTraceVerificationData.hashTreeRoot);
    }

    /// @notice Tests the getSigningRootBeaconBlockHeader functionality of SSZUtilities.
    function test_getSigningRootBeaconBlockHeader() public view {
        bytes32 signingRoot = SSZUtilities.getSigningRootBeaconBlockHeader(header, headerVerificationData.domain);
        assert(signingRoot == headerVerificationData.signingRoot);
    }

    /// @notice Tests the getSigningRootBidTrace functionality of SSZUtilities.
    function test_getSigningRootBidTrace() public view {
        bytes32 signingRoot = SSZUtilities.getSigningRootBidTrace(bidTrace, bidTraceVerificationData.domain);
        assert(signingRoot == bidTraceVerificationData.signingRoot);
    }
}