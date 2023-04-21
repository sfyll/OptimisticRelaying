pragma solidity >=0.8.0 <0.9.0;

import {SSZ, BeaconBlockHeader} from "telepathy-contracts/src/libraries/SimpleSerialize.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {BidTrace} from "../src/lib/SSZUtilities.sol";
import {AccountHandler} from"src/lib/accountHandler.sol";


/// Forked from https://github.com/succinctlabs/telepathy-contracts/
/// @notice Helper contract for parsing the JSON fixture, and converting them to the correct types.
/// @dev    The weird ordering here is because vm.parseJSON require alphabetical ordering of the
///         fields in the struct, and odd types with conversions are due to the way the JSON is
///         handled.
contract Fixture is Test {

    //SSZUtilities Test Section

    struct BeaconBlockHeaderFixture {
        bytes32 bodyRoot;
        bytes32 parentRoot;
        uint64 proposerIndex;
        uint64 slot;
        bytes32 stateRoot;
    }

    struct BidTraceFixture {
        bytes builderPubkey;
        uint64 gasLimit;
        uint64 gasUsed;
        bytes32 parentRoot;
        address payable proposerFeeRecipient;
        bytes proposerPubkey;
        uint64 slot;
        bytes32 stateRoot;
        string value;
    }

    struct DataForVerification {
        bytes32 domain;
        bytes32 hashTreeRoot;
        bytes signature;
        bytes32 signingRoot;
    }

    function newBeaconBlockHeader(BeaconBlockHeaderFixture memory beaconBlockHeaderFixture)
        public
        pure
        returns (BeaconBlockHeader memory)
    {
        return BeaconBlockHeader(
            beaconBlockHeaderFixture.slot,
            beaconBlockHeaderFixture.proposerIndex,
            beaconBlockHeaderFixture.parentRoot,
            beaconBlockHeaderFixture.stateRoot,
            beaconBlockHeaderFixture.bodyRoot
        );
    }

    function newBidTrace(BidTraceFixture memory bidTraceFixture)
        public
        pure
        returns (BidTrace memory)
    {
        return BidTrace(
            bidTraceFixture.slot,
            bidTraceFixture.parentRoot,
            bidTraceFixture.stateRoot,
            bidTraceFixture.builderPubkey,
            bidTraceFixture.proposerPubkey,
            bidTraceFixture.proposerFeeRecipient,
            bidTraceFixture.gasLimit,
            bidTraceFixture.gasUsed,
            strToUint(string(bidTraceFixture.value))
        );
    }

    function strToUint(string memory str) internal pure returns (uint256 res) {
        for (uint256 i = 0; i < bytes(str).length; i++) {
            if ((uint8(bytes(str)[i]) - 48) < 0 || (uint8(bytes(str)[i]) - 48) > 9) {
                revert();
            }
            res += (uint8(bytes(str)[i]) - 48) * 10 ** (bytes(str).length - i - 1);
        }

        return res;
    }

    //AccountHandler test section

    function accountHandlerFuzzingParamsDeposit(uint256 value, bytes[] memory fakeBlsAddy) public payable returns (uint256) {
        vm.assume(fakeBlsAddy.length < 10);
        value = bound(value, 1 wei, 100_000_000 ether);
        vm.deal(msg.sender, value + 10 ether); //gas fee
        return value;
    }

    function accountHandlerFuzzingParamsAdd(uint256 value, uint256 addedCollateral, bytes[] memory fakeBlsAddyDeposit, bytes[] memory fakeBlsAddyAdd) public payable returns (uint256, uint256) {
        addedCollateral = bound(addedCollateral, 0 ether, 100_000_000 ether);
        vm.deal(msg.sender, addedCollateral + 10 ether);
        uint256 deposit =  accountHandlerFuzzingParamsDeposit(value, fakeBlsAddyDeposit);
        vm.assume(fakeBlsAddyAdd.length > 1);
        return (deposit, addedCollateral);
    }

    function newAccountHandler() public returns (AccountHandler) {
        return new AccountHandler();
    }

    function getHashCommitedBlsAddress(bytes[] memory fakeBlsAddy)
        public
        pure
        returns (bytes32[] memory)
    {
        bytes32[] memory hashCommitedBlsAddress = new bytes32[](fakeBlsAddy.length);

        for (uint256 i = 0; i < fakeBlsAddy.length; i++) {
            hashCommitedBlsAddress[i] = sha256(abi.encodePacked(fakeBlsAddy[i]));
        }

        return hashCommitedBlsAddress;
    }

    function aggregateBlsAddressHashes(bytes32[] memory fakeBlsAddyDepositHash, bytes32[] memory fakeBlsAddyAddHash) public pure returns (bytes32[] memory) {
        uint256 length = fakeBlsAddyDepositHash.length + fakeBlsAddyAddHash.length;
        bytes32[] memory hashCommitedBlsAddress = new bytes32[](length); 
        for (uint256 i = 0; i < fakeBlsAddyDepositHash.length; i++) {
            hashCommitedBlsAddress[i] = fakeBlsAddyDepositHash[i];
        }
        for (uint256 i = 0; i < fakeBlsAddyAddHash.length; i++) {
            hashCommitedBlsAddress[i + fakeBlsAddyDepositHash.length] = fakeBlsAddyAddHash[i];
        }
        return hashCommitedBlsAddress;
    }
}