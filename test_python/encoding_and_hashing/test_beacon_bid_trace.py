from eth2spec.phase0.spec import  Slot, Root, Container, BLSPubkey
from eth2spec.utils.ssz.ssz_typing import ByteVector, uint64, uint256

from test_python.test_lib import serialize_object, get_hash_tree_root_bid_trace, serialize_test, load_json_data


"""
Bid Trace Encoding Test
"""

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

bid_trace = load_json_data("bid_trace.json")
bid_trace["value"] = int(bid_trace["value"])
bid_trace_ssz_encoded = load_json_data("bid_trace_ssz_encoded.json")

obj = BidTrace(
    slot=Slot(bid_trace['slot']),
    parent_root=Root(bid_trace['parentRoot']),
    state_root=Root(bid_trace['stateRoot']),
    BuilderPubkey=BLSPubkey(bid_trace['builderPubkey']),
    ProposerPubkey=BLSPubkey(bid_trace['proposerPubkey']),
    ProposerFeeRecipient=Address(bid_trace['proposerFeeRecipient']),
    GasLimit=uint64(bid_trace['gasLimit']),
    GasUsed=uint64(bid_trace['gasUsed']),
    Value=uint256(bid_trace['value']),
)

#Serialize using library
serialized_obj = serialize_object(obj)
print(f"{serialized_obj.hex()=}")

#Serialize using custom function
expected_ssz_encoded = serialize_test([bid_trace_ssz_encoded["slot"], bid_trace_ssz_encoded["parentRoot"], bid_trace_ssz_encoded["stateRoot"], bid_trace_ssz_encoded["builderPubkey"], bid_trace_ssz_encoded["proposerPubkey"], bid_trace_ssz_encoded["proposerFeeRecipient"], bid_trace_ssz_encoded["gasLimit"], bid_trace_ssz_encoded["gasUsed"], bid_trace_ssz_encoded["value"]])

#get hashtreeroot using library
hashtreeroot = obj.hash_tree_root()
print(f"{hashtreeroot.hex()=}")

# #get hashtreeroot using custom function
expected_hashtreeroot = get_hash_tree_root_bid_trace(bid_trace_ssz_encoded["slot"], bid_trace_ssz_encoded["parentRoot"], bid_trace_ssz_encoded["stateRoot"], bid_trace_ssz_encoded["builderPubkey"], bid_trace_ssz_encoded["proposerPubkey"], bid_trace_ssz_encoded["proposerFeeRecipient"], bid_trace_ssz_encoded["gasLimit"], bid_trace_ssz_encoded["gasUsed"], bid_trace_ssz_encoded["value"])

assert(serialized_obj.hex() == expected_ssz_encoded)
assert(expected_hashtreeroot == hashtreeroot.hex())