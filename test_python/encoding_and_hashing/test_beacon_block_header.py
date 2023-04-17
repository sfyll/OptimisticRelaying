from eth2spec.phase0.spec import  BeaconBlockHeader, Slot, ValidatorIndex, Root

from test_python.test_lib import serialize_object, get_hash_tree_root_beacon_block_header, load_json_data

"""
Beacon Block Header Encoding Test
"""

beacon_block_header = load_json_data("beacon_block_header.json")
beacon_block_header["slot"] = int(beacon_block_header["slot"])
beacon_block_header["proposerIndex"] = int(beacon_block_header["proposerIndex"])
beacon_block_header_ssz_encoded = load_json_data("beacon_block_header_ssz_encoded.json")

obj = BeaconBlockHeader(
    slot=Slot(beacon_block_header['slot']),
    proposer_index=ValidatorIndex(beacon_block_header['proposerIndex']),
    parent_root=Root(beacon_block_header['parentRoot']),
    state_root=Root(beacon_block_header['stateRoot']),
    body_root=Root(beacon_block_header['bodyRoot']),
)

# Serialize beacon block header using library
serialized_block_header = serialize_object(obj)
hashtreeroot = obj.hash_tree_root()
print(f"{serialized_block_header.hex()=}")
print(f"{hashtreeroot.hex()=}")

#get hashtreeroot using custom function
expected_hashtreeroot = get_hash_tree_root_beacon_block_header(beacon_block_header_ssz_encoded["slot"], beacon_block_header_ssz_encoded["proposerIndex"], beacon_block_header_ssz_encoded["parentRoot"], beacon_block_header_ssz_encoded["stateRoot"], beacon_block_header_ssz_encoded["bodyRoot"])

# Checking output with https://www.ssz.dev/chainsafe
assert("0x" + serialized_block_header.hex() == "0x03000000000000000200000000000000fe1bc5762ac63d5f9d51f9e422746f7f30da42a57dc70567e99b22afd4718622ed099057b8526e16b3d276e12f0756c9363a4ed350f61c667f4be4df89872a1cfa29a0c1d120219c4bcd89e188fbfcfd5e2f7ad9e83bd1b38549896b0d231ba5")
assert(hashtreeroot.hex() == expected_hashtreeroot)
