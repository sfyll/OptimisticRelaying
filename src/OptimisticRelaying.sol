pragma solidity >=0.8.6 <0.9.0;

import {AccountHandler} from "./lib/accountHandler.sol";
import {BeaconBlockHeader, BidTrace, SSZUtilities} from"./lib/SSZUtilities.sol";

struct Groth16Proof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
}

contract OptimisticRelaying is AccountHandler, SSZUtilities {

    uint64 public immutable FIRST_VALID_SLOT;

    ///@notice enforce a first valid slot that should ideally be the one at deploy time
    ///@param firstValidSlot is ideally the curent slot at deploy time
    ///@dev this allows to set a lower bound in which block can be disputed in case of mallicious behavior
    constructor(uint64 firstValidSlot) {
        FIRST_VALID_SLOT = firstValidSlot;
    }

    ///@notice verify existance of BLS address in array
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

    ///@notice get hash of a eth1 address blspubkey
    function getHashCommitedBlsAddress(bytes[] memory blsPubKey) public pure returns (bytes32[] memory) {
        bytes32[] memory hashCommitedBlsAddress = new bytes32[](blsPubKey.length);

        for (uint256 i = 0; i < blsPubKey.length; i++) {
            hashCommitedBlsAddress[i] = sha256(blsPubKey[i]);
        }
        return hashCommitedBlsAddress;    
    }

    //@notice submit builder invalid block + zk Groth16Proof
    //@dev this function is called by the relayer and allow to verify
    //both builder and proposer commited on the same block.
    function invalidBlockDispute(BeaconBlockHeader memory header, bytes32 proposerDomain,
                                 BidTrace memory bidTrace, bytes32 builderDomain,
                                 address builderPubKeyEth1, Groth16Proof memory proof)
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

        bytes32 bidTraceSigningRoot = getSigningRootBidTrace(bidTrace, builderDomain);
        bytes32 headerSigningRoot = getSigningRootBeaconBlockHeader(header, proposerDomain);

        // Below will be implemented via snark-js automatically. What won't be are the circuits!
        // Nonetheless, since all inputs are fixed size SSZ encoded is trivial and one can
        // rely mostly on what was built by succinctlabs and 0xParc!
        // require(verifySignature(proof.a, proof.b, proof.c, bidTraceSigningRoot), "Invalid signature");
        // require(verifySignature(proof.a, proof.b, proof.c, headerSigningRoot), "Invalid signature");

        builderMetaDatas[msg.sender].balance -= bidTrace.value;
        bidTrace.proposerFeeRecipient.transfer(bidTrace.value);
    }
}