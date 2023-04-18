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
    bytes32 public beaconBlockHeaderHashTreeRoot;
    
    BidTrace public bidTrace;
    bytes public bidTraceBlsSignature;
    bytes32 public bidTraceHashTreeRoot;
    
     function setUp() public {
        contractor = new Contractor();


        string memory root = vm.projectRoot();

        loadBeaconBlockHeaderAndSig(root);
        
        loadBeaconBidTraceAndSig(root);

        }

        function loadBeaconBlockHeaderAndSig(string memory root) public {
            string memory beaconBlockHeaderContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header.json"));
            string memory beaconBlockHeaderBlsSig = vm.readFile(string.concat(root, "/test_data/beacon_block_header_bls_sig.json"));
            string memory beaconBlockHeaderHashTreeRootContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header_hash_tree_root.json"));

            bytes memory beaconBlockHeaderData = vm.parseJson(beaconBlockHeaderContent);
            bytes memory beaconBlockHeaderBlsSigData = vm.parseJson(beaconBlockHeaderBlsSig);
            bytes memory beaconBlockHeaderHashTreeRootData = vm.parseJson(beaconBlockHeaderHashTreeRootContent);

            BeaconBlockHeaderFixture memory beaconBlockHeaderFixture = abi.decode(beaconBlockHeaderData, (BeaconBlockHeaderFixture));
            beaconBlockHeaderBlsSignature = abi.decode(beaconBlockHeaderBlsSigData, (bytes));
            beaconBlockHeaderHashTreeRoot = abi.decode(beaconBlockHeaderHashTreeRootData, (bytes32));

            header = newBeaconBlockHeader(beaconBlockHeaderFixture);
        }

        function loadBeaconBidTraceAndSig(string memory root) public {
            string memory bidTraceContent = vm.readFile(string.concat(root, "/test_data/bid_trace.json"));
            string memory bidTraceSig = vm.readFile(string.concat(root, "/test_data/bid_trace_bls_sig.json"));
            string memory bidTraceHashTreeRootContent = vm.readFile(string.concat(root, "/test_data/bid_trace_hash_tree_root.json"));

            bytes memory bidTraceData = vm.parseJson(bidTraceContent);
            bytes memory bidTraceBlsSigData = vm.parseJson(bidTraceSig);
            bytes memory bidTraceHashTreeRootData = vm.parseJson(bidTraceHashTreeRootContent);

            BidTraceFixture memory bidTraceFixture = abi.decode(bidTraceData, (BidTraceFixture));
            bidTraceBlsSignature = abi.decode(bidTraceBlsSigData, (bytes));
            bidTraceHashTreeRoot = abi.decode(bidTraceHashTreeRootData, (bytes32));

            bidTrace = newBidTrace(bidTraceFixture);
        }

    function test_getHashTreeRootBlockHeader() public view{
        bytes32 hashTreeRoot = contractor.getHashTreeRootBlockHeader(header);

        assert(hashTreeRoot == beaconBlockHeaderHashTreeRoot);
    }

    function test_getHashTreeRootBidTrace() public view {
        bytes32 hashTreeRoot = contractor.getHashTreeRootBidTrace(bidTrace);

        assert(hashTreeRoot == bidTraceHashTreeRoot);
    }
}