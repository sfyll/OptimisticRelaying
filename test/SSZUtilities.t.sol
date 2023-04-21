// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/console.sol";

import {BidTrace, SSZUtilities} from "../src/lib/SSZUtilities.sol";
import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
import {BytesLib} from "telepathy-contracts/src/libraries/MessageEncoding.sol";
import {Fixture} from "test/fixture.sol";

contract SSZUtilitiesTest is Fixture {

    SSZUtilities public SSZutilities;

    BeaconBlockHeader public header;
    DataForVerification public headerVerificationData;
    
    BidTrace public bidTrace;
    DataForVerification public bidTraceVerificationData;
    
     function setUp() public {
        SSZutilities = new SSZUtilities();

        string memory root = vm.projectRoot();

        loadBeaconBlockHeaderAndSig(root);
        
        loadBeaconBidTraceAndSig(root);

        }

        function loadBeaconBlockHeaderAndSig(string memory root) public {
            string memory beaconBlockHeaderContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header.json"));
            string memory headerVerificationDataContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header_data_for_verification.json"));
            

            bytes memory beaconBlockHeaderData = vm.parseJson(beaconBlockHeaderContent);
            bytes memory headerVerificationContent = vm.parseJson(headerVerificationDataContent);


            BeaconBlockHeaderFixture memory beaconBlockHeaderFixture = abi.decode(beaconBlockHeaderData, (BeaconBlockHeaderFixture));
            headerVerificationData = abi.decode(headerVerificationContent, (DataForVerification));
            
            header = newBeaconBlockHeader(beaconBlockHeaderFixture);
        }

        function loadBeaconBidTraceAndSig(string memory root) public {
            string memory bidTraceContent = vm.readFile(string.concat(root, "/test_data/bid_trace.json"));
            string memory bidTraceVerificationDataContent = vm.readFile(string.concat(root, "/test_data/bid_trace_data_for_verification.json"));


            bytes memory bidTraceData = vm.parseJson(bidTraceContent);
            bytes memory bidTraceVerificationContent = vm.parseJson(bidTraceVerificationDataContent);

            BidTraceFixture memory bidTraceFixture = abi.decode(bidTraceData, (BidTraceFixture));
            bidTraceVerificationData = abi.decode(bidTraceVerificationContent, (DataForVerification));


            bidTrace = newBidTrace(bidTraceFixture);
        }

    function test_getHashTreeRootBlockHeader() public view{
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