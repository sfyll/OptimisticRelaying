
import dataclasses
import os
from typing import Dict

from py_ecc import bls as bls_ecc
from eth2spec.phase0.spec import compute_signing_root
from eth_typing import (
    BLSPubkey,
    BLSSignature,
)

from test_python.signing_and_verifying.test_verifier import get_proposer_domain
from test_python.signing_and_verifying.test_builder import get_builder_domain
from test_python.test_lib import get_beacon_block_header, get_bid_trace, convert_bid_trace_to_dict, convert_beacon_block_header_to_dict, write_to_json

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
        self.run()

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

    def run(self) -> None:
        self.builder_sign_and_json_write()
        self.proposer_sign_and_json_write()

    def builder_sign_and_json_write(self) -> None:
        bid_trace = get_bid_trace()
        builder_domain = get_builder_domain()

        signing_root = compute_signing_root(bid_trace, builder_domain)

        signature = sign_message(signing_root, self.key_information["builder"].private_key)
        
        print(f"builder signature: {signature.hex()=}")

        is_sig_valid = verify_signature(signing_root, signature, bytes.fromhex(self.key_information["builder"].public_key))

        print(f"builder verification: {is_sig_valid=}")

        assert(is_sig_valid == True)
        
        bid_trace.BuilderPubkey = self.key_information['builder'].public_key
        bid_trace.ProposerPubkey =  self.key_information['proposer'].public_key

        dictionary_bid_trace = convert_bid_trace_to_dict(bid_trace)

        signature_dict = {
            "signature": signature.hex(),
        }

        write_to_json(dictionary_bid_trace, "bid_trace.json")
        write_to_json(signature_dict, "bid_trace_bls_sig.json")

    def proposer_sign_and_json_write(self) -> None:
        beacon_block_header = get_beacon_block_header()
        proposer_domain = get_proposer_domain()

        signing_root = compute_signing_root(beacon_block_header, proposer_domain)

        signature = sign_message(signing_root, self.key_information["proposer"].private_key)
        
        print(f"builder signature: {signature.hex()=}")

        is_sig_valid = verify_signature(signing_root, signature, bytes.fromhex(self.key_information["proposer"].public_key))

        print(f"builder verification: {is_sig_valid=}")

        assert(is_sig_valid == True)

        dictionary_beacon_block_header = convert_beacon_block_header_to_dict(beacon_block_header)

        signature_dict = {
            "signature": signature.hex(),
        }
        
        write_to_json(dictionary_beacon_block_header, "beacon_block_header.json")
        write_to_json(signature_dict, "beacon_block_header_bls_sig.json")

if __name__ == "__main__":
    test_signature = testSignature()
