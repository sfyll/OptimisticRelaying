
import dataclasses
import os
from typing import Dict

from py_ecc import bls as bls_ecc
from eth2spec.phase0.spec import compute_signing_root
from eth_typing import BLSPubkey, BLSSignature

from test_python.signing_and_verifying.test_verifier import get_proposer_domain
from test_python.signing_and_verifying.test_builder import get_builder_domain
from test_python.test_lib import get_beacon_block_header, get_bid_trace, convert_bid_trace_to_dict, \
                                 convert_beacon_block_header_to_dict, write_to_json, \
                                 get_signing_root_test

@dataclasses.dataclass(init=True, eq=True, repr=True)
class keyInformation:
    private_key: bytes
    public_key: BLSPubkey


def generate_private_key() -> bytes:
    return int.from_bytes(os.urandom(32), 'big')

def derive_public_key(private_key) -> BLSPubkey:
    return bls_ecc.G2Basic.PrivToPub(private_key).hex()

def sign_message(message, private_key) -> BLSSignature:
    return bls_ecc.G2Basic.Sign(private_key, message)

def verify_signature(message, signature, public_key) -> bool:
    return bls_ecc.G2Basic.Verify(public_key, message, signature)


class testSignature:
    def __init__(self) -> None:
        self.key_information: Dict[str, keyInformation] = self.get_key_information()

    def get_key_information(self) -> Dict[str, keyInformation]:
        key_information = {}

        private_key = generate_private_key()
        public_key = derive_public_key(private_key)

        key_information["builder"] = keyInformation(private_key=private_key,
                                                    public_key=public_key)

        private_key = generate_private_key()
        public_key = derive_public_key(private_key)

        key_information["proposer"] = keyInformation(private_key=private_key,
                                                     public_key=public_key)

        return key_information

    def load_objects(self) -> None:
        self.proposer_domain = get_proposer_domain()
        self.builder_domain = get_builder_domain()
        self.bid_trace = get_bid_trace()
        self.beacon_block_header = get_beacon_block_header()

    def run(self) -> None:
        self.load_objects()
        self.builder_sign_and_json_write()
        self.proposer_sign_and_json_write()

    def builder_sign_and_json_write(self) -> None:
        self.bid_trace.BuilderPubkey = self.key_information['builder'].public_key
        self.bid_trace.ProposerPubkey =  self.key_information['proposer'].public_key

        self.test_compute_signing_root_builder()
        
        signing_root = compute_signing_root(self.bid_trace, self.builder_domain)

        signature = sign_message(signing_root, self.key_information["builder"].private_key)
        
        is_sig_valid = verify_signature(signing_root, signature, bytes.fromhex(self.key_information["builder"].public_key))

        assert(is_sig_valid == True)

        dictionary_bid_trace = convert_bid_trace_to_dict(self.bid_trace)

        data_for_verification = {
            "domain": "0x" + self.builder_domain.hex(),
            "signature": signature.hex(),
            "hash_tree_root": "0x" + self.bid_trace.hash_tree_root().hex(),
            "signing_root": "0x" + signing_root.hex(),
        }

        write_to_json(dictionary_bid_trace, "bid_trace.json")
        write_to_json(data_for_verification, "bid_trace_data_for_verification.json")

    def proposer_sign_and_json_write(self) -> None:
        self.test_compute_signing_root_proposer()

        signing_root = compute_signing_root(self.beacon_block_header, self.proposer_domain)

        signature = sign_message(signing_root, self.key_information["proposer"].private_key)
        
        is_sig_valid = verify_signature(signing_root, signature, bytes.fromhex(self.key_information["proposer"].public_key))

        assert(is_sig_valid == True)

        dictionary_beacon_block_header = convert_beacon_block_header_to_dict(self.beacon_block_header)

        data_for_verification = {
            "domain": "0x" + self.proposer_domain.hex(),
            "signature": signature.hex(),
            "hash_tree_root": "0x" + self.beacon_block_header.hash_tree_root().hex(),
            "signing_root": "0x" + signing_root.hex(),
        }
        
        write_to_json(dictionary_beacon_block_header, "beacon_block_header.json")
        write_to_json(data_for_verification, "beacon_block_header_data_for_verification.json")

    def test_compute_signing_root_proposer(self) -> None:
        """
        We can just pass the Domain as a tranasction input,
        so let's focus on handling it on-chain
        """
        expected_signing_root = compute_signing_root(self.beacon_block_header, self.proposer_domain)
        actual_signing_root = get_signing_root_test("0x" + self.beacon_block_header.hash_tree_root().hex(), "0x" + self.proposer_domain.hex())

        assert(expected_signing_root.hex() == actual_signing_root.hex())

    def test_compute_signing_root_builder(self) -> None:
        """
        We can just pass the Domain as a tranasction input,
        so let's focus on handling it on-chain
        """
        expected_signing_root = compute_signing_root(self.bid_trace, self.builder_domain)
        actual_signing_root = get_signing_root_test("0x" + self.bid_trace.hash_tree_root().hex(), "0x" + self.builder_domain.hex())

        assert(expected_signing_root.hex() == actual_signing_root.hex())


if __name__ == "__main__":
    test_signature = testSignature()
    test_signature.run()

#bid_trace.hash_tree_root().hex()='a44ed86a1affb715c125219d38f85bc1d104b2e156bac8cbef47b604c3077888'
#bid_trace.hash_tree_root().hex()='a44ed86a1affb715c125219d38f85bc1d104b2e156bac8cbef47b604c3077888
#signing_root.hex()='c825f2c0d1eb449c26607fb70967148312788a73d9b7694260432d6cd23b21d8'
#signing_root.hex()='7392667708162597561260edaee606d6da4bcbfaa03666113c99d69a0a915b31'
#builder_domain.hex()='00000001f5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a9'
#builder_domain.hex()='00000001f5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a9'
#0x50000a0d83be9c3a30327108be0a93bed9ecc35c50aae326b1b8ee061e5bb298
#
