from eth2spec.phase0.spec import  Slot, Root, Container, BLSPubkey
from eth2spec.utils.ssz.ssz_typing import ByteVector, uint64, uint256

from test_python.test_lib import serialize_object, get_hash_tree_root_bid_trace, serialize_test


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

bid_trace = {
    "slot": 1,
    "parent_hash": "0xcf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2",
    "block_hash": "0xcf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2",
    "builder_pubkey": "0x93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a",
    "proposer_pubkey": "0x93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a",
    "proposer_fee_recipient": "0xabcf8e0d4e9587369b2301d0790347320302cc09",
    "gas_limit": 1,
    "gas_used": 1,
    "value":1000000000000000000000000000000
  }

#Note on below: ByteList of fixed size remain the same !
slot_ssz = "0x0100000000000000"
parent_root_ssz = "0xcf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2"
state_root_ssz = "0xcf8e0d4e9587369b2301d0790347320302cc0943d5a1884560367e8208d920f2"
builder_pubkey_ssz = "0x93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a"
proposer_pubkey_ssz = "0x93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a"
proposer_fee_recipient_ssz = "0xabcf8e0d4e9587369b2301d0790347320302cc09"
gas_limit_ssz = "0x0100000000000000"
gas_used_ssz = "0x0100000000000000"
value_ssz = "0x00000040eaed7446d09c2c9f0c00000000000000000000000000000000000000"

obj = BidTrace(
    slot=Slot(bid_trace['slot']),
    parent_root=Root(bid_trace['parent_hash']),
    state_root=Root(bid_trace['block_hash']),
    BuilderPubkey=BLSPubkey(bid_trace['builder_pubkey']),
    ProposerPubkey=BLSPubkey(bid_trace['proposer_pubkey']),
    ProposerFeeRecipient=Address(bid_trace['proposer_fee_recipient']),
    GasLimit=uint64(bid_trace['gas_limit']),
    GasUsed=uint64(bid_trace['gas_used']),
    Value=uint256(bid_trace['value']),
)

#Serialize using library
serialized_obj = serialize_object(obj)

#Serialize using custom function
expected_ssz_encoded = serialize_test([slot_ssz, parent_root_ssz, state_root_ssz, builder_pubkey_ssz, proposer_pubkey_ssz, proposer_fee_recipient_ssz, gas_limit_ssz, gas_used_ssz, value_ssz])

#get hashtreeroot using library
hashtreeroot = obj.hash_tree_root()


# #get hashtreeroot using custom function
expected_hashtreeroot = get_hash_tree_root_bid_trace(slot_ssz, parent_root_ssz, state_root_ssz, builder_pubkey_ssz, proposer_pubkey_ssz, proposer_fee_recipient_ssz, gas_limit_ssz, gas_used_ssz, value_ssz)

assert(serialized_obj.hex() == expected_ssz_encoded)
assert(expected_hashtreeroot == hashtreeroot.hex())