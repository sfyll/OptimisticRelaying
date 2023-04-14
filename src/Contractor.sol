pragma solidity ^0.8.16;

import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
import {BytesLib} from "telepathy-contracts/src/libraries/MessageEncoding.sol";

struct BidTrace {
    uint64 slot;
    bytes32 parentRoot;
    bytes32 stateRoot;
    bytes builderPubkey;
    bytes proposerPubkey;
    address proposerFeeRecipient;
    uint64 gasLimit;
    uint64 gasUsed;
    uint256 value;
}

contract Contractor {

    function getHashTreeRootBlockHeader(BeaconBlockHeader memory header) public pure returns (bytes32) {
        return SSZ.sszBeaconBlockHeader(header);
    }

    function getEncodedBlockHeader(BeaconBlockHeader memory header) public pure returns (bytes memory) {
        return bytes.concat(
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(header.slot)), 0 , 8),
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(header.proposerIndex)), 0, 8),
            header.parentRoot,
            header.stateRoot,
            header.bodyRoot
        );
    }

    function getEncodedBidTrace(BidTrace memory bidTrace) public pure returns (bytes memory) {
        return bytes.concat(
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(bidTrace.slot)), 0 , 8),
            bidTrace.parentRoot,
            bidTrace.stateRoot,
            bidTrace.builderPubkey,
            bidTrace.proposerPubkey,
            abi.encodePacked(bidTrace.proposerFeeRecipient),
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(bidTrace.gasLimit)), 0, 8),
            BytesLib.slice(abi.encodePacked(SSZ.toLittleEndian(bidTrace.gasUsed)), 0, 8),
            SSZ.toLittleEndian(bidTrace.value)
        );
    }

    function getHashTreeRootBidTrace(BidTrace memory bidTrace) public pure returns (bytes32) {
        bytes32 builderPubkeyChunk = sha256(
            bytes.concat(
            BytesLib.slice(bidTrace.builderPubkey, 0, 32),
            bytes.concat(BytesLib.slice(bidTrace.builderPubkey, 32, 16), bytes16(0))
            )
        );
        bytes32 proposerPubkeyChunk = sha256(
            bytes.concat(
            BytesLib.slice(bidTrace.proposerPubkey, 0, 32),
            bytes.concat(BytesLib.slice(bidTrace.proposerPubkey, 32, 16), bytes16(0))
            )
        );

        bytes memory rightPaddedProposerFeeRecipientAddress = bytes.concat(abi.encodePacked(bidTrace.proposerFeeRecipient), hex"000000000000000000000000");

        bytes32 left = sha256(
            bytes.concat(
                sha256(
                    bytes.concat(
                        sha256(bytes.concat(SSZ.toLittleEndian(bidTrace.slot), bidTrace.parentRoot)),
                        sha256(bytes.concat(bidTrace.stateRoot, builderPubkeyChunk))
                    )
                ),
                sha256(
                    bytes.concat(
                        sha256(bytes.concat(proposerPubkeyChunk, rightPaddedProposerFeeRecipientAddress)),
                        sha256(bytes.concat(SSZ.toLittleEndian(bidTrace.gasLimit), SSZ.toLittleEndian(bidTrace.gasUsed)))
                    )
                )
            )
        );
        
        bytes32 right = sha256(
            bytes.concat(
                sha256(
                    bytes.concat(
                        sha256(bytes.concat(SSZ.toLittleEndian(bidTrace.value), bytes32(0))),
                        sha256(bytes.concat(bytes32(0), bytes32(0)))
                    )
                ),
                sha256(
                    bytes.concat(
                        sha256(bytes.concat(bytes32(0), bytes32(0))),
                        sha256(bytes.concat(bytes32(0), bytes32(0)))
                    )
                )
            )
        );

        return sha256(bytes.concat(left, right));
    }
}