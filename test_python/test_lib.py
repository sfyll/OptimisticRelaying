from io import BytesIO
import json
import os
from typing import List, Optional

from eth2spec.utils.hash_function import hash as hash_function
from eth2spec.phase0.spec import BeaconBlockHeader, BLSPubkey, Root, Slot, ValidatorIndex
from eth2spec.utils.ssz.ssz_typing import uint64, uint256

from test_python.test_objects import BidTrace, Address

__path = os.path.dirname(os.path.dirname(__file__)) + "/test_data/"

def write_to_json(data: dict, filename: str):
    with open("test_data/" + filename, "w") as file:
        json.dump(data, file)

def load_json_data(filename: str):
    """
    Load a JSON file, just pass in the extension
    """
    with open(__path + filename, "r") as f:
        return json.load(f)

def get_bid_trace() -> BidTrace:
    bid_trace = load_json_data("bid_trace.json")
    bid_trace["value"] = int(bid_trace["value"])

    return BidTrace(
        slot=Slot(bid_trace["slot"]),
        parent_root=Root(bid_trace["parentRoot"]),
        state_root=Root(bid_trace["stateRoot"]),
        BuilderPubkey=BLSPubkey(bid_trace["builderPubkey"]),
        ProposerPubkey=BLSPubkey(bid_trace["proposerPubkey"]),
        ProposerFeeRecipient=Address(bid_trace["proposerFeeRecipient"]),
        GasLimit=uint64(bid_trace["gasLimit"]),
        GasUsed=uint64(bid_trace["gasUsed"]),
        Value=uint256(bid_trace["value"]),
    )

def convert_bid_trace_to_dict(bid_trace: BidTrace) -> dict:
    return {
    "slot": bid_trace.slot,
    "parentRoot": str(bid_trace.parent_root),
    "stateRoot": str(bid_trace.state_root),
    "builderPubkey": str(bid_trace.BuilderPubkey),
    "proposerPubkey": str(bid_trace.ProposerPubkey),
    "proposerFeeRecipient": str(bid_trace.ProposerFeeRecipient),
    "gasLimit": bid_trace.GasLimit,
    "gasUsed": bid_trace.GasUsed,
    "value": str(bid_trace.Value)
    }

def get_beacon_block_header() -> BeaconBlockHeader:
    beacon_block_header = load_json_data("beacon_block_header.json")

    return BeaconBlockHeader(
        slot=Slot(beacon_block_header["slot"]),
        proposer_index=ValidatorIndex(beacon_block_header["proposerIndex"]),
        parent_root=Root(beacon_block_header["parentRoot"]),
        state_root=Root(beacon_block_header["stateRoot"]),
        body_root=Root(beacon_block_header["bodyRoot"]),
    )

def convert_beacon_block_header_to_dict(beacon_block_header: BeaconBlockHeader) -> dict:
    return {
    "slot": beacon_block_header.slot,
    "proposerIndex": beacon_block_header.proposer_index,
    "parentRoot": str(beacon_block_header.parent_root),
    "stateRoot": str(beacon_block_header.state_root),
    "bodyRoot": str(beacon_block_header.body_root)
    }

def serialize_object(obj, stream = BytesIO()):
    """
    Serialize an object to a stream.
    """
    obj.serialize(stream)
    return stream.getvalue()


def right_padding(element_to_pad):
    """
    Right padding of an element to 32 bytes, if needed
    """
    return element_to_pad  + "0" * (66 - len(element_to_pad))

def get_value_to_hash(a: Optional[str] = None, b: Optional[str] = None):
    """
    Get the value to hash for a pair of elements.
    """
    if a and b:
        return bytes.fromhex(a[2:]) + bytes.fromhex(b[2:])
    elif a and b is None:
        return bytes.fromhex(a[2:]) + bytes.fromhex("0" * 64)
    elif a is None and b is None:
        return bytes.fromhex("0" * 64) +  bytes.fromhex("0" * 64)
    
#Special cases cause no element > 32 bytes
def get_hash_tree_root_beacon_block_header(slot_ssz, proposer_index_ssz, parent_root_ssz, state_root_ssz, body_root_ssz):
    padded_slot = right_padding(slot_ssz)
    proposed_index = right_padding(proposer_index_ssz)
    padded_parent_root = right_padding(parent_root_ssz)
    padded_state_root = right_padding(state_root_ssz)
    padded_body_root = right_padding(body_root_ssz)

    node_1 = hash_function(get_value_to_hash(padded_slot, proposed_index))
    node_2 = hash_function(get_value_to_hash(padded_parent_root, padded_state_root))
    node_3 = hash_function(get_value_to_hash(padded_body_root))
    node_4 = hash_function(get_value_to_hash())

    node_a = hash_function(node_1 + node_2)
    node_b = hash_function(node_3 + node_4)

    return hash_function(node_a + node_b).hex()

def get_hash_tree_root_bid_trace(slot_ssz, parent_root_ssz, state_root_ssz, builder_pubkey_ssz, proposer_pubkey_ssz, proposer_fee_recipient_ssz, gas_limit_ssz, gas_used_ssz, value_ssz):
    padded_slot = right_padding(slot_ssz)
    padded_parent_root = right_padding(parent_root_ssz)
    padded_state_root = right_padding(state_root_ssz)
    padded_builder_pubkey_first_chunk = builder_pubkey_ssz[:66]
    padded_builder_pubkey_second_chunk = right_padding("0x"+ builder_pubkey_ssz[66:])
    padded_proposer_pubkey_first_chunk = proposer_pubkey_ssz[:66]
    padded_proposer_pubkey_second_chunk = right_padding("0x"+proposer_pubkey_ssz[66:])
    padded_proposer_fee_recipient = right_padding(proposer_fee_recipient_ssz)
    padded_gas_limit = right_padding(gas_limit_ssz)
    padded_gas_used = right_padding(gas_used_ssz)
    padded_value = right_padding(value_ssz)

    hashed_builder_pubkey = "0x" + str(hash_function(get_value_to_hash(padded_builder_pubkey_first_chunk, padded_builder_pubkey_second_chunk)).hex())
    hashed_proposer_pubkey = "0x" + str(hash_function(get_value_to_hash(padded_proposer_pubkey_first_chunk, padded_proposer_pubkey_second_chunk)).hex())

    node_1 = hash_function(get_value_to_hash(padded_slot, padded_parent_root))
    node_2 = hash_function(get_value_to_hash(padded_state_root, hashed_builder_pubkey))
    node_3 = hash_function(get_value_to_hash(hashed_proposer_pubkey, padded_proposer_fee_recipient))
    node_4 = hash_function(get_value_to_hash(padded_gas_limit, padded_gas_used))
    node_5 = hash_function(get_value_to_hash(padded_value))
    node_6 = hash_function(get_value_to_hash())
    node_7 = hash_function(get_value_to_hash())
    node_8 = hash_function(get_value_to_hash())

    node_a = hash_function(node_1 + node_2)
    node_b = hash_function(node_3 + node_4)
    node_c = hash_function(node_5 + node_6)
    node_d = hash_function(node_7 + node_8)

    node_1_final = hash_function(node_a + node_b)
    node_2_final = hash_function(node_c + node_d)

    return hash_function(node_1_final + node_2_final).hex()

def get_hash_tree_root_bls_pubkey(bls_pubkey_ssz):
    padded_bls_pubkey_first_chunk = bls_pubkey_ssz[:66]
    padded_bls_pubkey_second_chunk = right_padding("0x"+ bls_pubkey_ssz[66:])

    return hash_function(get_value_to_hash(padded_bls_pubkey_first_chunk, padded_bls_pubkey_second_chunk)).hex()

def get_signing_root_test(tree_root, domain):
    padded_tree_root = right_padding(tree_root)
    padded_domain = right_padding(domain)

    return hash_function(get_value_to_hash(padded_tree_root, padded_domain))

def serialize_test(to_serialize: List[str]) -> str:
    result = ""
    for element in to_serialize:
        result += element[2:]
    return result