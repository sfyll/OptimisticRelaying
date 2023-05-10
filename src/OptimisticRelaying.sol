pragma solidity >=0.8.6 <0.9.0;

import {AccountHandler} from "src/accountHandler.sol";
import {BeaconBlockHeader, BidTrace, SSZUtilities} from"./lib/SSZUtilities.sol";

struct Groth16Proof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
}

/// @title Optimistic Relaying
/// @notice This contract handles the optimistic relaying of beacon block headers.
/// @dev Inherits from AccountHandler and uses the SSZUtilities library.
contract OptimisticRelaying is AccountHandler {

    uint64 public immutable FIRST_VALID_SLOT;

    /// @notice Sets the first valid slot during the contract deployment.
    /// @param firstValidSlot The current slot at deploy time.
    /// @dev Allows setting a lower bound for which blocks can be disputed in case of malicious behavior.
    constructor(uint64 firstValidSlot) {
        FIRST_VALID_SLOT = firstValidSlot;
    }

    /// @notice Verifies the existence of the a hashed BLS address in an array.
    /// @param blsPubKey The BLS public key.
    /// @param eth1Address The Ethereum address associated with the BLS public key.
    /// @return True if the BLS address was committed, otherwise False.
    function verifyBlsAddressWasCommited(bytes memory blsPubKey, address eth1Address) public view returns (bool) {
        bytes32 hashedBlsPubKey = sha256(abi.encodePacked(blsPubKey));
        BuilderMetaDatas storage buildermetaData = builderMetaDatas[eth1Address];

         for (uint256 i = 0; i < buildermetaData.hashCommitedBlsAddress.length; i++) {
            if (hashedBlsPubKey == buildermetaData.hashCommitedBlsAddress[i]) {
                return true;
            }
        }
        return false;
    }

    /// @notice Generates an array of hashed BLS addresses.
    /// @param blsPubKey The array of BLS public keys.
    /// @return An array of hashed BLS addresses.
    function getHashCommitedBlsAddress(bytes[] memory blsPubKey) public pure returns (bytes32[] memory) {
        bytes32[] memory hashCommitedBlsAddress = new bytes32[](blsPubKey.length);

        for (uint256 i = 0; i < blsPubKey.length; i++) {
            hashCommitedBlsAddress[i] = sha256(blsPubKey[i]);
        }
        return hashCommitedBlsAddress;    
    }

    /// @notice Submits an invalid block dispute, along with a ZK Groth16 Proof.
    /// @dev Called by the relayer as it's the only entity with both messages. it allows for verification of both builder and proposer commitments on the same block.
    /// @param header The beacon block header.
    /// @param proposerDomain The domain for the proposer according to flashbot mev-boost specs.
    /// @param bidTrace The bid trace data.
    /// @param builderDomain The domain for the builder according to flashbot mev-boost specs.
    /// @param builderPubKeyEth1 The Ethereum address of the builder public key.
    /// @param builderProof The Groth16Proof of valid BLS-signature.
    /// @param proposerProof The Groth16Proof of valid BLS-signature.
    function invalidBlockDispute(BeaconBlockHeader memory header, bytes32 proposerDomain,
                                 BidTrace memory bidTrace, bytes32 builderDomain,
                                 address builderPubKeyEth1, Groth16Proof memory builderProof,
                                 Groth16Proof memory proposerProof)
                                 external payable {
        require(header.slot >= FIRST_VALID_SLOT, "Given slot is to old");
        require(builderMetaDatas[builderPubKeyEth1].exists == true, "Builder doesn't exists");
        require(builderMetaDatas[builderPubKeyEth1].balance >= bidTrace.value, "Insufficient balance");
        require(verifyBlsAddressWasCommited(bidTrace.builderPubkey, builderPubKeyEth1), "BLS address doesn't exist");
        require(
            (header.slot == bidTrace.slot &&
            header.parentRoot == bidTrace.parentRoot &&
            header.stateRoot == bidTrace.stateRoot
        ), "block content does not match");

        bytes32 bidTraceSigningRoot = SSZUtilities.getSigningRootBidTrace(bidTrace, builderDomain);
        bytes32 headerSigningRoot = SSZUtilities.getSigningRootBeaconBlockHeader(header, proposerDomain);

        // Below will be implemented via snark-js automatically. What won't be are the circuits!
        // Nonetheless, since all inputs are fixed size SSZ encoded is trivial and one can
        // rely mostly on what was built by succinctlabs and 0xParc!
        // require(verifySignature(proof.a, proof.b, proof.c, bidTraceSigningRoot), "Invalid signature");
        // require(verifySignature(proof.a, proof.b, proof.c, headerSigningRoot), "Invalid signature");

        builderMetaDatas[msg.sender].balance -= bidTrace.value;
        bidTrace.proposerFeeRecipient.transfer(bidTrace.value);
    }
}