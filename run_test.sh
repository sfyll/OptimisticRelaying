#!/bin/bash

# Get the script's directory
SCRIPT_DIR="$(dirname "$0")"

# Activate the Python environment
source "$SCRIPT_DIR/env/bin/activate"

# Run the Python test
python3 -m test_python.signing_and_verifying.test_signature

# Run the Forge tests with verbosity level 4
forge test -vvv

# Deactivate the Python environment
deactivate