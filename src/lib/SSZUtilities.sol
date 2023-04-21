pragma solidity >=0.8.6 <0.9.0;

import {BytesLib} from "telepathy-contracts/src/libraries/MessageEncoding.sol";
import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
    
struct BidTrace {
    uint64 slot;
    bytes32 parentRoot;
    bytes32 stateRoot;
    bytes builderPubkey;
    bytes proposerPubkey;
    address payable proposerFeeRecipient;
    uint64 gasLimit;
    uint64 gasUsed;
    uint256 value;
}

/// @title SSZ Utilities
/// @notice This contract provides utility functions for working with SSZ encoding and computing signing roots.
library SSZUtilities {
    
    /// @notice Compute the signing root of a BeaconBlockHeader.
    /// @param header The BeaconBlockHeader to compute the signing root for.
    /// @param domain The domain to be used for signing.
    /// @return signingroot.
    function getSigningRootBeaconBlockHeader(BeaconBlockHeader memory header, bytes32 domain) public pure returns (bytes32) {
        return sha256(
            bytes.concat(
                getHashTreeRootBlockHeader(header),
                domain
            )
        );
    }

    /// @notice Compute the signing root of a BidTrace.
    /// @param bidTrace The BidTrace to compute the signing root for.
    /// @param domain The domain to be used for signing.
    /// @return The signing root.
    function getSigningRootBidTrace(BidTrace memory bidTrace, bytes32 domain) public pure returns (bytes32) {
        return sha256(
            bytes.concat(
                getHashTreeRootBidTrace(bidTrace),
                domain
            )
        );
    }

    /// @notice Compute the hash tree root of a BeaconBlockHeader.
    /// @param header The BeaconBlockHeader to compute the hash tree root for.
    /// @return The hash tree root.
    function getHashTreeRootBlockHeader(BeaconBlockHeader memory header) public pure returns (bytes32) {
        return SSZ.sszBeaconBlockHeader(header);
    }

    /// @notice Compute the hash tree root of a BidTrace.
    /// @param bidTrace The BidTrace to compute the hash tree root for.
    /// @return The hash tree root.
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