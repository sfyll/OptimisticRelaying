from typing import Tuple

from eth2spec.phase0.spec import compute_domain, compute_signing_root

domain = Tuple[bytes, ...]
domainType = Tuple[bytes, ...]
forkVersion = Tuple[bytes, ...]

domainTypeBeaconProposer = b'\x00' + b'\x00' + b'\x00' + b'\x00'

def get_proposer_domain(forkVersion = None, root = None) -> bytes:
    return compute_domain(domainTypeBeaconProposer, forkVersion, root)

proposer_domain = get_proposer_domain(domainTypeBeaconProposer)

#check that returned domain is 32 bytes long
assert(len(proposer_domain) == 32 and isinstance(proposer_domain, bytes))
