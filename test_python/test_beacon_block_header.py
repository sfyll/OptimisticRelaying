from eth2spec.phase0.spec import  BeaconBlockHeader, Slot, ValidatorIndex, Root

from test_python.test_lib import serialize_object, get_hash_tree_root_beacon_block_header

"""
Beacon Block Header Encoding Test
"""

beacon_block_header = {
                'slot': 3,
                'proposerIndex': 2,
                'parentRoot': '0xfe1bc5762ac63d5f9d51f9e422746f7f30da42a57dc70567e99b22afd4718622',
                'stateRoot': '0xed099057b8526e16b3d276e12f0756c9363a4ed350f61c667f4be4df89872a1c',
                'bodyRoot': '0xfa29a0c1d120219c4bcd89e188fbfcfd5e2f7ad9e83bd1b38549896b0d231ba5',
            }


slot_ssz='0x0300000000000000'
proposer_index_ssz='0x0200000000000000'
parent_root_ssz='0xfe1bc5762ac63d5f9d51f9e422746f7f30da42a57dc70567e99b22afd4718622'
state_root_ssz='0xed099057b8526e16b3d276e12f0756c9363a4ed350f61c667f4be4df89872a1c'
body_root_ssz='0xfa29a0c1d120219c4bcd89e188fbfcfd5e2f7ad9e83bd1b38549896b0d231ba5'

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

#get hashtreeroot using custom function
hashtreerootcustom = get_hash_tree_root_beacon_block_header(slot_ssz, proposer_index_ssz, parent_root_ssz, state_root_ssz, body_root_ssz)

# Checking output with https://www.ssz.dev/chainsafe
assert("0x" + serialized_block_header.hex() == "0x03000000000000000200000000000000fe1bc5762ac63d5f9d51f9e422746f7f30da42a57dc70567e99b22afd4718622ed099057b8526e16b3d276e12f0756c9363a4ed350f61c667f4be4df89872a1cfa29a0c1d120219c4bcd89e188fbfcfd5e2f7ad9e83bd1b38549896b0d231ba5")
assert("0x" + hashtreeroot.hex() == '0xece514576a14314b37af4d185d905f31c54b47822dec10ff7e78641dd6a7f9d2')
assert("0x" + hashtreerootcustom == '0xece514576a14314b37af4d185d905f31c54b47822dec10ff7e78641dd6a7f9d2')

