from eth2spec.phase0.spec import  Slot, Root, Container, BLSPubkey
from eth2spec.utils.ssz.ssz_typing import ByteVector, uint64, uint256

class Address(ByteVector[20]):
    pass

class BidTrace(Container):
    slot: Slot
    parent_root: Root
    state_root: Root
    BuilderPubkey: BLSPubkey
    ProposerPubkey: BLSPubkey
    ProposerFeeRecipient: Address
    GasLimit: uint64
    GasUsed: uint64
    Value: uint256

