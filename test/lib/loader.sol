pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";

import {BidTrace} from "src/lib/SSZUtilities.sol";
import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";


/// @title Loader
/// @notice Loader contract for loading test data from JSON files.
/// @dev The weird ordering here is because vm.parseJSON requires alphabetical ordering of the fields in the struct, and odd types with conversions are due to the way the JSON is handled.
contract Loader is Test{

    /// @notice Represents a BeaconBlockHeader with its params alphabetically sorted.
   struct BeaconBlockHeaderFixture {
        bytes32 bodyRoot;
        bytes32 parentRoot;
        uint64 proposerIndex;
        uint64 slot;
        bytes32 stateRoot;
    }

    /// @notice Represents a BidTrace with its params alphabetically sorted.
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

    /// @notice Represents data required for tests verification.
    struct DataForVerification {
        bytes32 domain;
        bytes32 hashTreeRoot;
        bytes signature;
        bytes32 signingRoot;
    }
    
    /// @notice Loads a BeaconBlockHeader and its associated signature data from JSON files.
    /// @param root The root path of the JSON files.
    /// @return tuple containing the loaded BeaconBlockHeader and the DataForVerification.
    function loadBeaconBlockHeaderAndSig(string memory root) public view returns (BeaconBlockHeader memory, DataForVerification memory) {
        string memory beaconBlockHeaderContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header.json"));
        string memory headerVerificationDataContent = vm.readFile(string.concat(root, "/test_data/beacon_block_header_data_for_verification.json"));
        

        bytes memory beaconBlockHeaderData = vm.parseJson(beaconBlockHeaderContent);
        bytes memory headerVerificationContent = vm.parseJson(headerVerificationDataContent);


        BeaconBlockHeaderFixture memory beaconBlockHeaderFixture = abi.decode(beaconBlockHeaderData, (BeaconBlockHeaderFixture));
        DataForVerification memory headerVerificationData = abi.decode(headerVerificationContent, (DataForVerification));
        
        return (newBeaconBlockHeader(beaconBlockHeaderFixture), headerVerificationData);
    }

    /// @notice Loads a BidTrace and its associated signature data from JSON files.
    /// @param root The root path of the JSON files.
    /// @return tuple containing the loaded BidTrace and the DataForVerification.
    function loadBeaconBidTraceAndSig(string memory root) public view returns (BidTrace memory, DataForVerification memory) {
        string memory bidTraceContent = vm.readFile(string.concat(root, "/test_data/bid_trace.json"));
        string memory bidTraceVerificationDataContent = vm.readFile(string.concat(root, "/test_data/bid_trace_data_for_verification.json"));


        bytes memory bidTraceData = vm.parseJson(bidTraceContent);
        bytes memory bidTraceVerificationContent = vm.parseJson(bidTraceVerificationDataContent);

        BidTraceFixture memory bidTraceFixture = abi.decode(bidTraceData, (BidTraceFixture));
        DataForVerification memory bidTraceVerificationData = abi.decode(bidTraceVerificationContent, (DataForVerification));


        return (newBidTrace(bidTraceFixture), bidTraceVerificationData);
    }

    /// @notice Creates a new BeaconBlockHeader instance from a fixture.
    /// @param beaconBlockHeaderFixture The BeaconBlockHeaderFixture to convert.
    /// @return The converted BeaconBlockHeader instance.
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

    /// @notice Creates a new BidTrace instance from a fixture.
    /// @param bidTraceFixture The BidTraceFixture to convert.
    /// @return The converted BidTrace instance.
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

    /// @notice Converts a string to a uint256.
    /// @param str The input string to convert.
    /// @return res converted uint256.
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