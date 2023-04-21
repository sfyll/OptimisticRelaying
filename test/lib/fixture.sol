pragma solidity >=0.8.0 <0.9.0;

import {AccountHandler} from"src/lib/accountHandler.sol";
import {OptimisticRelaying} from "src/OptimisticRelaying.sol";

import {Loader} from "test/lib/loader.sol";

/// Inspired from https://github.com/succinctlabs/telepathy-contracts/
/// @notice Helper contract for parsing the JSON fixture, and converting them to the correct types.
/// @dev    The weird ordering here is because vm.parseJSON require alphabetical ordering of the
///         fields in the struct, and odd types with conversions are due to the way the JSON is
///         handled.
contract Fixture is Loader {

    function newAccountHandler() public returns (AccountHandler) {
        return new AccountHandler();
    }

    function newOptimisticRelaying(uint64 slot) public returns (OptimisticRelaying) {
        return new OptimisticRelaying(slot);
    }

    function accountHandlerFuzzingParamsDeposit(uint256 value, bytes[] memory fakeBlsAddy) public payable returns (uint256) {
        vm.assume(fakeBlsAddy.length < 10);
        value = bound(value, 1 wei, 100_000_000 ether);
        vm.deal(msg.sender, value + 10 ether); //gas fee
        return value;
    }

    function accountHandlerFuzzingParamsAdd(uint256 addedCollateral, bytes[] memory fakeBlsAddyAdd) public payable returns (uint256) {
        addedCollateral = bound(addedCollateral, 0 ether, 100_000_000 ether);
        vm.deal(msg.sender, addedCollateral + 10 ether);
        vm.assume(fakeBlsAddyAdd.length > 1);
        return addedCollateral;
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

    function depositAndGetHashOfCommitedBlsAddressFuzzing(uint256 value, bytes[] memory fakeBlsAddy, AccountHandler accountHandler) public returns (uint256, bytes32[] memory) {
        value = accountHandlerFuzzingParamsDeposit(value, fakeBlsAddy);
        
        bytes32[] memory hashCommitedBlsAddress = getHashCommitedBlsAddress(fakeBlsAddy);
        
        accountHandler.deposit{value: value}(hashCommitedBlsAddress);

        return (value, hashCommitedBlsAddress);
    }

    function depositAndGetHashOfCommitedBlsAddress(uint256 value, bytes[] memory BlsAddy, OptimisticRelaying optimisticRelaying) public returns (bytes32[] memory) {        
        bytes32[] memory hashCommitedBlsAddress = getHashCommitedBlsAddress(BlsAddy);
        
        optimisticRelaying.deposit{value: value}(hashCommitedBlsAddress);

        return hashCommitedBlsAddress;
    }
}