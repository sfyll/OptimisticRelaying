// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import {Contractor, BidTrace} from "../src/Contractor.sol";
import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
import {BytesLib} from "telepathy-contracts/src/libraries/MessageEncoding.sol";


contract ContractorTest is Test {

    Contractor private contractor;

    constructor() {
        contractor = new Contractor();
    }

    function test_getHashTreeRootBlockHeader() public view{
        BeaconBlockHeader memory header = BeaconBlockHeader({
            slot: 3,
            proposerIndex: 2,
            parentRoot: 0xfe1bc5762ac63d5f9d51f9e422746f7f30da42a57dc70567e99b22afd4718622,
            stateRoot: 0xed099057b8526e16b3d276e12f0756c9363a4ed350f61c667f4be4df89872a1c,
            bodyRoot: 0xfa29a0c1d120219c4bcd89e188fbfcfd5e2f7ad9e83bd1b38549896b0d231ba5
        });

        bytes32 expectedHashTreeRoot = 0xece514576a14314b37af4d185d905f31c54b47822dec10ff7e78641dd6a7f9d2;
        bytes32 hashTreeRoot = contractor.getHashTreeRootBlockHeader(header);

        assert(hashTreeRoot == expectedHashTreeRoot);
    }

    function test_getEncodedBlockHeader() public view{
        BeaconBlockHeader memory header = BeaconBlockHeader({
            slot: 5,
            proposerIndex: 5,
            parentRoot: 0xd6246e4747ebae0f579f525ef36beb3fe30c6a2e758793ce09f98f5e7fc7a8eb,
            stateRoot: 0x06818bb46773e4ec7dff06962a76ba6f0fc9d44cf35a9c415e983bcd18e485e3,
            bodyRoot: 0x818ae32c7552fbd5001731361c01bfc6f7b278017b19a3e541e85b5df6186d28
        });

        bytes memory expectedEncodedBlockHeade = hex"05000000000000000500000000000000d6246e4747ebae0f579f525ef36beb3fe30c6a2e758793ce09f98f5e7fc7a8eb06818bb46773e4ec7dff06962a76ba6f0fc9d44cf35a9c415e983bcd18e485e3818ae32c7552fbd5001731361c01bfc6f7b278017b19a3e541e85b5df6186d28";
        bytes memory encodedBlockHeader = contractor.getEncodedBlockHeader(header);

        assert(keccak256(encodedBlockHeader) == keccak256(expectedEncodedBlockHeade));
    }

    function test_costConcat() public view returns (bytes memory) {
         BeaconBlockHeader memory header = BeaconBlockHeader({
            slot: 5,
            proposerIndex: 5,
            parentRoot: 0xd6246e4747ebae0f579f525ef36beb3fe30c6a2e758793ce09f98f5e7fc7a8eb,
            stateRoot: 0x06818bb46773e4ec7dff06962a76ba6f0fc9d44cf35a9c415e983bcd18e485e3,
            bodyRoot: 0x818ae32c7552fbd5001731361c01bfc6f7b278017b19a3e541e85b5df6186d28
        });

        return bytes.concat(
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(header.slot)), 0 , 8),
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(header.proposerIndex)), 0, 8),
            header.parentRoot,
            header.stateRoot,
            header.bodyRoot
        );
    }

    function test_costEncodePacked() public view returns (bytes memory) {
         BeaconBlockHeader memory header = BeaconBlockHeader({
            slot: 5,
            proposerIndex: 5,
            parentRoot: 0xd6246e4747ebae0f579f525ef36beb3fe30c6a2e758793ce09f98f5e7fc7a8eb,
            stateRoot: 0x06818bb46773e4ec7dff06962a76ba6f0fc9d44cf35a9c415e983bcd18e485e3,
            bodyRoot: 0x818ae32c7552fbd5001731361c01bfc6f7b278017b19a3e541e85b5df6186d28
        });

        return abi.encodePacked(
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(header.slot)), 0 , 8),
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(header.proposerIndex)), 0, 8),
            header.parentRoot,
            header.stateRoot,
            header.bodyRoot
        );
    }

    function test_getEncodedBidTrace() public view {
        BidTrace memory bidTrace = BidTrace({
            slot: 1,
            parentRoot: 0xcf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2,
            stateRoot: 0xcf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2,
            builderPubkey: bytes(hex"93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a"),
            proposerPubkey: bytes(hex"93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a"),
            proposerFeeRecipient: 0xAbcF8e0d4e9587369b2301D0790347320302cc09,
            gasLimit: 1,
            gasUsed: 1,
            value: 1000000000000000000000000000000
        });

        bytes memory encodedBidTrace = contractor.getEncodedBidTrace(bidTrace);
        bytes memory expectedEncodedBidTrace = hex"0100000000000000cf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2cf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f293247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74aabcf8e0d4e9587369b2301d0790347320302cc090100000000000000010000000000000000000040eaed7446d09c2c9f0c00000000000000000000000000000000000000";
        
        assert(keccak256(encodedBidTrace) == keccak256(expectedEncodedBidTrace));
    }


    function test_getHashTreeRootBidTrace() public view {
        BidTrace memory bidTrace = BidTrace({
            slot: 1,
            parentRoot: 0xcf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2,
            stateRoot: 0xcf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2,
            builderPubkey: bytes(hex"93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a"),
            proposerPubkey: bytes(hex"93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a"),
            proposerFeeRecipient: 0xAbcF8e0d4e9587369b2301D0790347320302cc09,
            gasLimit: 1,
            gasUsed: 1,
            value: 1000000000000000000000000000000
        });

        bytes32 hashTreeRoot = contractor.getHashTreeRootBidTrace(bidTrace);
        bytes32 expectedHashTreeRoot = 0x3272b07b7bf5b240b0da5835b1a6350f73010a49eb94cdb4a44ff392d8303473;

        assert(hashTreeRoot == expectedHashTreeRoot);
    }
}