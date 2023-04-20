pragma solidity >=0.8.0 <0.9.0;

import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
import {BidTrace} from "../src/lib/SSZUtilities.sol";

/// Forked from https://github.com/succinctlabs/telepathy-contracts/
/// @notice Helper contract for parsing the JSON fixture, and converting them to the correct types.
/// @dev    The weird ordering here is because vm.parseJSON require alphabetical ordering of the
///         fields in the struct, and odd types with conversions are due to the way the JSON is
///         handled.
contract ContractorFixture {

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

    function newBeaconBlockHeader(BeaconBlockHeaderFixture memory beaconBlockHeaderFixture)
        public
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