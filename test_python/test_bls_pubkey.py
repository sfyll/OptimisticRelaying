from eth2spec.phase0.spec import BLSPubkey

from test_python.test_lib import serialize_object, get_hash_tree_root_bls_pubkey

bls_pubkey = '0x818039ff319a6f5cdb02ea018e25cbb884f01440ca2719bfbdd66a4077dc9ed5319d33607fed94ebbba87d7cb79ae8b0'
bls_pubkey_ssz = '0x818039ff319a6f5cdb02ea018e25cbb884f01440ca2719bfbdd66a4077dc9ed5319d33607fed94ebbba87d7cb79ae8b0'

obj = BLSPubkey(bls_pubkey)

#Serialize using library
serialized_obj = serialize_object(obj)

#get hashtreeroot using library
hashtreeroot = obj.hash_tree_root()

# #get hashtreeroot using custom function
expected_hashtreeroot = get_hash_tree_root_bls_pubkey(bls_pubkey_ssz)

assert(expected_hashtreeroot == hashtreeroot.hex())
assert(serialized_obj.hex() == bls_pubkey_ssz)
