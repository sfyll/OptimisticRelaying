pragma solidity >=0.8.6 <0.9.0;

import {IAccountHandler} from "src/interface/IAccountHandler.sol";

/// @title Account Handler
/// @notice This contract manages account-related operations for builders.
contract AccountHandler is IAccountHandler {

    struct BuilderMetaDatas {
        uint256 balance;
        bytes32[] hashCommitedBlsAddress;
        bool exists;
        uint256 releaseTime;
    }

    mapping(address => BuilderMetaDatas) public builderMetaDatas;

    event Deposit(address indexed sender, uint256 amount);
    event Add(address indexed sender, uint256 amount);
    event Withdrawal(address indexed receiver, uint256 amount);

    /// @notice Deposit ETH as collateral.
    /// @param hashCommitedBlsAddress Array of hashed builder's BLS public keys which will serve as commitments in case of invalidBlockDispute.
    function deposit(bytes32[] memory hashCommitedBlsAddress) public payable {
        require(builderMetaDatas[msg.sender].exists == false, "Builder already exists");
        require(msg.value > 0, "Deposit amount must be greater than 0");

        builderMetaDatas[msg.sender] = BuilderMetaDatas(
            msg.value,
            hashCommitedBlsAddress,
            true,
            uint256(0)
        );

        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Add deposit or commitment to BLS addresses.
    /// @dev We only push so that builders can't interact with this array if they know an invalidBlockDispute is coming, as it's used as a commitment.
    /// @param hashCommitedBlsAddress Array of sha256 hashed BLS public keys to be added.
    function add(bytes32[] memory hashCommitedBlsAddress) public payable {
        require(builderMetaDatas[msg.sender].exists == true, "Builder doesn't exists");

        BuilderMetaDatas storage builderMetaData = builderMetaDatas[msg.sender];

        builderMetaData.balance += msg.value;

        for (uint256 i = 0; i < hashCommitedBlsAddress.length; i++) {
            builderMetaData.hashCommitedBlsAddress.push(hashCommitedBlsAddress[i]);
        }

    }

    /// @notice Initiate a withdrawal with a 7-day timelock.
    function instantiateTransfer() public {
        BuilderMetaDatas storage builderMetaData = builderMetaDatas[msg.sender];

        require(builderMetaData.exists = true, "Builder doesn't exists");
        require(builderMetaData.releaseTime == 0, "Transfer already initialized");
        
        builderMetaDatas[msg.sender].releaseTime = block.timestamp + 7 days;
    }

    /// @notice Transfer ETH to the recipient if 7 days have elapsed since `instantiateTransfer`.
    /// @param recipient The address to receive the withdrawn funds.
    function withdraw(address payable recipient) public payable {
        require(block.timestamp >= builderMetaDatas[msg.sender].releaseTime, "Transfer is time-locked");
        require(builderMetaDatas[msg.sender].balance >= msg.value, "Insufficient balance");

        builderMetaDatas[msg.sender].releaseTime = uint256(0);
        builderMetaDatas[msg.sender].balance -= msg.value;
        
        recipient.transfer(msg.value);
        
        emit Withdrawal(recipient, msg.value);
    }

    // Getter functions
    function getBuilderBalance(address _builder) external view returns (uint256) {
        return builderMetaDatas[_builder].balance;
    }

    function getBuilderHashCommitedBlsAddress(address _builder) external view returns (bytes32[] memory) {
        return builderMetaDatas[_builder].hashCommitedBlsAddress;
    }
    
    function getBuilderExists(address _builder) external view returns (bool) {
        return builderMetaDatas[_builder].exists;
    }

    function getBuilderReleaseTime(address _builder) external view returns (uint256) {
        return builderMetaDatas[_builder].releaseTime;
    }
}