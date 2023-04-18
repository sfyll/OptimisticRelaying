
from test_python.test_lib import serialize_object, get_hash_tree_root_bid_trace, serialize_test, load_json_data, get_bid_trace

bid_trace_ssz_encoded = load_json_data("bid_trace_ssz_encoded.json")
bid_trace = get_bid_trace()

#Serialize using library
serialized_obj = serialize_object(bid_trace)
print(f"{serialized_obj.hex()=}")

#Serialize using custom function
expected_ssz_encoded = serialize_test([bid_trace_ssz_encoded["slot"], bid_trace_ssz_encoded["parentRoot"], bid_trace_ssz_encoded["stateRoot"], bid_trace_ssz_encoded["builderPubkey"], bid_trace_ssz_encoded["proposerPubkey"], bid_trace_ssz_encoded["proposerFeeRecipient"], bid_trace_ssz_encoded["gasLimit"], bid_trace_ssz_encoded["gasUsed"], bid_trace_ssz_encoded["value"]])

#get hashtreeroot using library
hashtreeroot = bid_trace.hash_tree_root()
print(f"{hashtreeroot.hex()=}")

# #get hashtreeroot using custom function
expected_hashtreeroot = get_hash_tree_root_bid_trace(bid_trace_ssz_encoded["slot"], bid_trace_ssz_encoded["parentRoot"], bid_trace_ssz_encoded["stateRoot"], bid_trace_ssz_encoded["builderPubkey"], bid_trace_ssz_encoded["proposerPubkey"], bid_trace_ssz_encoded["proposerFeeRecipient"], bid_trace_ssz_encoded["gasLimit"], bid_trace_ssz_encoded["gasUsed"], bid_trace_ssz_encoded["value"])

assert(serialized_obj.hex() == expected_ssz_encoded)
assert(expected_hashtreeroot == hashtreeroot.hex())