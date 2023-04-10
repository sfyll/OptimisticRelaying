from io import BytesIO
from eth2spec.phase0.spec import  BeaconBlockHeader, Slot, ValidatorIndex, Root


beacon_block_header = {
                'slot': 5,
                'proposerIndex': 1,
                'parentRoot': '0x07fb98708ec295a199020cc23ca0c2af0692d113d87220c6d458bf5230a1e73a',
                'stateRoot': '0x93691eb5afb94db3faf33d1a9076df592ab71e727cfbdafe1dd3e9887b4fc931',
                'bodyRoot': '0x9f4ffbcb0853a4a63c7abd4ec8e2658a0d5ec67fb325414e36c21db740985869',
            }


# Example block header data
obj = BeaconBlockHeader(
    slot=Slot(beacon_block_header['slot']),
    proposer_index=ValidatorIndex(beacon_block_header['proposerIndex']),
    parent_root=Root(beacon_block_header['parentRoot']),
    state_root=Root(beacon_block_header['stateRoot']),
    body_root=Root(beacon_block_header['bodyRoot']),
)

# Serialize the block header
serialized_stream = BytesIO()
serialized_block_header = obj.serialize(serialized_stream)
serialized_block_header = serialized_stream.getvalue()
print("Serialized block header: 0x", serialized_block_header.hex())

# Checking output with https://www.ssz.dev/chainsafe
assert("0x" + serialized_block_header.hex() == "0x0500000000000000010000000000000007fb98708ec295a199020cc23ca0c2af0692d113d87220c6d458bf5230a1e73a93691eb5afb94db3faf33d1a9076df592ab71e727cfbdafe1dd3e9887b4fc9319f4ffbcb0853a4a63c7abd4ec8e2658a0d5ec67fb325414e36c21db740985869")