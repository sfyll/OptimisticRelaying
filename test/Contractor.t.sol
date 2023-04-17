// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import {Contractor, BidTrace} from "../src/Contractor.sol";
import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
import {BytesLib} from "telepathy-contracts/src/libraries/MessageEncoding.sol";
import {ContractorFixture} from "test/fixture.sol";

contract ContractorTest is Test, ContractorFixture {

    Contractor public contractor;
    BeaconBlockHeader public header;
    bytes public beaconBlockHeaderBlsSignature;
    BidTrace public bidTrace;
    bytes public bidTraceBlsSignature;
    bytes public beaconBlockHeaderSignature;
    bytes public bidTraceSignature;

    
     function setUp() public {
        contractor = new Contractor();


        string memory root = vm.projectRoot();

        loadBeaconBlockHeaderAndSig(root);
        
        loadBeaconBidTraceAndSig(root);

        }

        function loadBeaconBlockHeaderAndSig(string memory root) public {
            string memory beaconBlockHeaderContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header.json"));
            string memory beaconBlockHeaderBlsSig = vm.readFile(string.concat(root, "/test_data/beacon_block_header_bls_sig.json"));

            bytes memory beaconBlockHeaderData = vm.parseJson(beaconBlockHeaderContent);
            bytes memory beaconBlockHeaderBlsSigData = vm.parseJson(beaconBlockHeaderBlsSig);

            BeaconBlockHeaderFixture memory beaconBlockHeaderFixture = abi.decode(beaconBlockHeaderData, (BeaconBlockHeaderFixture));
            beaconBlockHeaderBlsSignature = abi.decode(beaconBlockHeaderBlsSigData, (bytes));

            header = newBeaconBlockHeader(beaconBlockHeaderFixture);
        }

        function loadBeaconBidTraceAndSig(string memory root) public {
            string memory bidTraceContent = vm.readFile(string.concat(root, "/test_data/bid_trace.json"));
            string memory bidTraceSig = vm.readFile(string.concat(root, "/test_data/bid_trace_bls_sig.json"));

            bytes memory bidTraceData = vm.parseJson(bidTraceContent);
            bytes memory bidTraceBlsSigData = vm.parseJson(bidTraceSig);

            console.logBytes(bidTraceData);

            BidTraceFixture memory bidTraceFixture = abi.decode(bidTraceData, (BidTraceFixture));

            console.logBytes(bidTraceFixture.builderPubkey);
            bidTraceBlsSignature = abi.decode(bidTraceBlsSigData, (bytes));

            bidTrace = newBidTrace(bidTraceFixture);
        }

    function test_getHashTreeRootBlockHeader() public view{
        bytes32 expectedHashTreeRoot = 0xece514576a14314b37af4d185d905f31c54b47822dec10ff7e78641dd6a7f9d2;
        bytes32 hashTreeRoot = contractor.getHashTreeRootBlockHeader(header);

        assert(hashTreeRoot == expectedHashTreeRoot);
    }

    function test_getEncodedBlockHeader() public view{
        bytes memory expectedEncodedBlockHeader = hex"03000000000000000200000000000000fe1bc5762ac63d5f9d51f9e422746f7f30da42a57dc70567e99b22afd4718622ed099057b8526e16b3d276e12f0756c9363a4ed350f61c667f4be4df89872a1cfa29a0c1d120219c4bcd89e188fbfcfd5e2f7ad9e83bd1b38549896b0d231ba5";
        bytes memory encodedBlockHeader = contractor.getEncodedBlockHeader(header);

        assert(keccak256(encodedBlockHeader) == keccak256(expectedEncodedBlockHeader));
    }

    function test_getEncodedBidTrace() public view {
        bytes memory encodedBidTrace = contractor.getEncodedBidTrace(bidTrace);
        bytes memory expectedEncodedBidTrace = hex"0100000000000000cf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2cf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f293247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74aabcf8e0d4e9587369b2301d0790347320302cc090100000000000000010000000000000000000040eaed7446d09c2c9f0c00000000000000000000000000000000000000";
        
        assert(keccak256(encodedBidTrace) == keccak256(expectedEncodedBidTrace));
    }


    function test_getHashTreeRootBidTrace() public view {
        bytes32 hashTreeRoot = contractor.getHashTreeRootBidTrace(bidTrace);
        bytes32 expectedHashTreeRoot = 0x3272b07b7bf5b240b0da5835b1a6350f73010a49eb94cdb4a44ff392d8303473;

        assert(hashTreeRoot == expectedHashTreeRoot);
    }
}