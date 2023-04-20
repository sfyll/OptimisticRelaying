pragma solidity >=0.8.6 <0.9.0;

contract AccountHandler {

    struct BuilderMetaDatas {
        uint256 balance;
        bytes32[] hashCommitedBlsAddress;
        bool exists;
        uint256 releaseTime;
    }

    mapping(address => BuilderMetaDatas) builderMetaDatas;

    event Deposit(address indexed sender, uint256 amount);
    event Add(address indexed sender, uint256 amount);
    event Withdrawal(address indexed receiver, uint256 amount);

    //@notice deposit eth as collateral
    //@param hashCommitedBlsAddress array of hashed the builder's blsPublicKeys
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

    //@notice add deposit or commitment to bls addresses
    //@dev we only push so that builder's can't interact with this array
    //if they know resolution is comming as it's used as a commitment
    function add(bytes32[] memory hashCommitedBlsAddress) public payable {
        require(builderMetaDatas[msg.sender].exists == true, "Builder doesn't exists");

        builderMetaDatas[msg.sender].balance += 0;

        for (uint256 i = 0; i < hashCommitedBlsAddress.length; i++) {
            builderMetaDatas[msg.sender].hashCommitedBlsAddress.push(hashCommitedBlsAddress[i]);
        }
    }

    //@notice initiate withdraw with a 7 day timelock
    function instantiateTransfer() public {
        require(builderMetaDatas[msg.sender].releaseTime == 0, "Transfer already initialized");
        builderMetaDatas[msg.sender].releaseTime = block.timestamp + 7 days;
    }

    //@notice Transfer Ether to the recipient if 7 days have elapsed since instantiateTransfer
    function withdraw(address payable recipient) public payable {
        require(block.timestamp >= builderMetaDatas[msg.sender].releaseTime, "Transfer is time-locked");
        require(builderMetaDatas[msg.sender].balance >= msg.value, "Insufficient balance");

        builderMetaDatas[msg.sender].releaseTime = uint256(0);
        builderMetaDatas[msg.sender].balance -= msg.value;
        
        recipient.transfer(msg.value);
        
        emit Withdrawal(recipient, msg.value);
    }
}