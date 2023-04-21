pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";

import {BidTrace} from "src/lib/SSZUtilities.sol";
import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";

contract Loader is Test{
   struct BeaconBlockHeaderFixture {
        bytes32 bodyRoot;
        bytes32 parentRoot;
        uint64 proposerIndex;
        uint64 slot;
        bytes32 stateRoot;
    }

    struct BidTraceFixture {
        bytes builderPubkey;
        uint64 gasLimit;
        uint64 gasUsed;
        bytes32 parentRoot;
        address payable proposerFeeRecipient;
        bytes proposerPubkey;
        uint64 slot;
        bytes32 stateRoot;
        string value;
    }

    struct DataForVerification {
        bytes32 domain;
        bytes32 hashTreeRoot;
        bytes signature;
        bytes32 signingRoot;
    }
    
    function loadBeaconBlockHeaderAndSig(string memory root) public returns (BeaconBlockHeader memory, DataForVerification memory) {
        string memory beaconBlockHeaderContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header.json"));
        string memory headerVerificationDataContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header_data_for_verification.json"));
        

        bytes memory beaconBlockHeaderData = vm.parseJson(beaconBlockHeaderContent);
        bytes memory headerVerificationContent = vm.parseJson(headerVerificationDataContent);


        BeaconBlockHeaderFixture memory beaconBlockHeaderFixture = abi.decode(beaconBlockHeaderData, (BeaconBlockHeaderFixture));
        DataForVerification memory headerVerificationData = abi.decode(headerVerificationContent, (DataForVerification));
        
        return (newBeaconBlockHeader(beaconBlockHeaderFixture), headerVerificationData);
    }

    function loadBeaconBidTraceAndSig(string memory root) public returns (BidTrace memory, DataForVerification memory) {
        string memory bidTraceContent = vm.readFile(string.concat(root, "/test_data/bid_trace.json"));
        string memory bidTraceVerificationDataContent = vm.readFile(string.concat(root, "/test_data/bid_trace_data_for_verification.json"));


        bytes memory bidTraceData = vm.parseJson(bidTraceContent);
        bytes memory bidTraceVerificationContent = vm.parseJson(bidTraceVerificationDataContent);

        BidTraceFixture memory bidTraceFixture = abi.decode(bidTraceData, (BidTraceFixture));
        DataForVerification memory bidTraceVerificationData = abi.decode(bidTraceVerificationContent, (DataForVerification));


        return (newBidTrace(bidTraceFixture), bidTraceVerificationData);
    }

    function newBeaconBlockHeader(BeaconBlockHeaderFixture memory beaconBlockHeaderFixture)
        public
        pure
        returns (BeaconBlockHeader memory)
    {
        return BeaconBlockHeader(
            beaconBlockHeaderFixture.slot,
            beaconBlockHeaderFixture.proposerIndex,
            beaconBlockHeaderFixture.parentRoot,
            beaconBlockHeaderFixture.stateRoot,
            beaconBlockHeaderFixture.bodyRoot
        );
    }

    function newBidTrace(BidTraceFixture memory bidTraceFixture)
        public
        pure
        returns (BidTrace memory)
    {
        return BidTrace(
            bidTraceFixture.slot,
            bidTraceFixture.parentRoot,
            bidTraceFixture.stateRoot,
            bidTraceFixture.builderPubkey,
            bidTraceFixture.proposerPubkey,
            bidTraceFixture.proposerFeeRecipient,
            bidTraceFixture.gasLimit,
            bidTraceFixture.gasUsed,
            strToUint(string(bidTraceFixture.value))
        );
    }

    function strToUint(string memory str) internal pure returns (uint256 res) {
        for (uint256 i = 0; i < bytes(str).length; i++) {
            if ((uint8(bytes(str)[i]) - 48) < 0 || (uint8(bytes(str)[i]) - 48) > 9) {
                revert();
            }
            res += (uint8(bytes(str)[i]) - 48) * 10 ** (bytes(str).length - i - 1);
        }

        return res;
    }
}