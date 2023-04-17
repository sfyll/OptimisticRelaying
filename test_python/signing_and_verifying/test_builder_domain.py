from typing import Tuple

from eth2spec.phase0.spec import compute_domain, compute_signing_root

domain = Tuple[bytes, ...]
domainType = Tuple[bytes, ...]
forkVersion = Tuple[bytes, ...]

domainTypeBeaconProposer = b'\x00' + b'\x00' + b'\x00' + b'\x00'
domainTypeAppBuilder = b'\x00' + b'\x00' + b'\x00' + b'\x01'

def get_builder_domain(domainTypeAppBuilder, forkVersion = None, root = None) -> bytes:
    return compute_domain(domainTypeAppBuilder, forkVersion, root)

def get_proposer_domain(domainTypeBeaconProposer, forkVersion = None, root = None) -> bytes:
    return compute_domain(domainTypeBeaconProposer, forkVersion, root)

builder_domain = get_builder_domain(domainTypeAppBuilder)
proposer_domain = get_proposer_domain(domainTypeBeaconProposer)

#check that returned domain is 32 bytes long
assert(len(builder_domain) == 32 and isinstance(builder_domain, bytes))
assert(len(proposer_domain) == 32 and isinstance(proposer_domain, bytes))
