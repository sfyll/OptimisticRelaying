pragma solidity >=0.8.0 <0.9.0;

import {AccountHandler} from "src/accountHandler.sol";
import {OptimisticRelaying} from "src/OptimisticRelaying.sol";

import {Loader} from "test/lib/loader.sol";

/// Inspired from https://github.com/succinctlabs/telepathy-contracts/
/// @title Fixture
/// @notice Helper methods for running tests.
contract Fixture is Loader {

    /// @notice Creates a new AccountHandler contract.
    /// @return newly created AccountHandler contract.
    function newAccountHandler() public returns (AccountHandler) {
        return new AccountHandler();
    }

    /// @notice Creates a new OptimisticRelaying contract with a specified slot.
    /// @param slot The slot number for the OptimisticRelaying contract to floor slot for which blocks can be disputed in case of malicious behavior..
    /// @return The newly created OptimisticRelaying contract.
    function newOptimisticRelaying(uint64 slot) public returns (OptimisticRelaying) {
        return new OptimisticRelaying(slot);
    }

    /// @notice Generates fuzzing parameters for AccountHandler deposits.
    /// @param value The amount of collateral to deposit.
    /// @param fakeBlsAddy An array of fake "BLS addresses", since we just use their sha256 their lengths doesn't matter.
    /// @return The updated value for the deposit.
    function accountHandlerFuzzingParamsDeposit(uint256 value, bytes[] memory fakeBlsAddy) public payable returns (uint256) {
        vm.assume(fakeBlsAddy.length < 10);
        value = bound(value, 1 wei, 100_000_000 ether);
        vm.deal(msg.sender, value + 10 ether); //gas fee
        return value;
    }

    /// @notice Generates fuzzing parameters for adding collateral to an AccountHandler.
    /// @param addedCollateral The amount of collateral to add.
    /// @param fakeBlsAddyAdd array of fake "BLS addresses", since we just use their sha256 their lengths doesn't matter.
    /// @return The updated value for the added collateral.
    function accountHandlerFuzzingParamsAdd(uint256 addedCollateral, bytes[] memory fakeBlsAddyAdd) public payable returns (uint256) {
        addedCollateral = bound(addedCollateral, 0 ether, 100_000_000 ether);
        vm.deal(msg.sender, addedCollateral + 10 ether);
        vm.assume(fakeBlsAddyAdd.length > 1);
        return addedCollateral;
    }

    /// @notice Computes the hash of an array of fake BLS addresses.
    /// @param fakeBlsAddy array of fake "BLS addresses", since we just use their sha256 their lengths doesn't matter.
    /// @return An array of sha256-hashes of the fake BLS addresses.
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

    /// @notice Aggregates an array of hashes of fake BLS addresses from two separate arrays.
    /// @param fakeBlsAddyDepositHash An array of hashes of fake BLS addresses from deposits.
    /// @param fakeBlsAddyAddHash An array of hashes of fake BLS addresses from adds.
    /// @return An array of aggregated hashes of the fake BLS addresses.
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

    /// @notice Deposits the fuzzed amount to the AccountHandler and returns the hash of the committed BLS addresses.
    /// @param value The amount to deposit.
    /// @param fakeBlsAddy An array of fake BLS addresses.
    /// @param accountHandler The AccountHandler contract.
    /// @return The updated value and an array of hashes of the fake BLS addresses.
    function depositAndGetHashOfCommitedBlsAddressFuzzing(uint256 value, bytes[] memory fakeBlsAddy, AccountHandler accountHandler) public returns (uint256, bytes32[] memory) {
        value = accountHandlerFuzzingParamsDeposit(value, fakeBlsAddy);
        
        bytes32[] memory hashCommitedBlsAddress = getHashCommitedBlsAddress(fakeBlsAddy);
        
        accountHandler.deposit{value: value}(hashCommitedBlsAddress);

        return (value, hashCommitedBlsAddress);
    }

    /// @notice Deposits the specified amount to the AccountHandler and returns the hash of the committed BLS addresses.
    /// @param value The amount to deposit.
    /// @param BlsAddy An array of BLS addresses.
    /// @param optimisticRelaying The OptimisticRelaying contract.
    /// @return The updated value and an array of sha256 hashes of the BLS addresses.
    function depositAndGetHashOfCommitedBlsAddress(uint256 value, bytes[] memory BlsAddy, OptimisticRelaying optimisticRelaying) public returns (bytes32[] memory) {        
        bytes32[] memory hashCommitedBlsAddress = getHashCommitedBlsAddress(BlsAddy);
        
        optimisticRelaying.deposit{value: value}(hashCommitedBlsAddress);

        return hashCommitedBlsAddress;
    }
}