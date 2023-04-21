pragma solidity >=0.8.6 <0.9.0;

interface IAccountHandler {
    /// @notice Get the balance of a builder.
    /// @param _builder The address of the builder.
    /// @return balance of the builder.
    function getBuilderBalance(address _builder) external view returns (uint256);

    /// @notice Get the hash256-committed BLS addresses of a builder.
    /// @param _builder The address of the builder.
    /// @return array of hash-committed BLS addresses.
    function getBuilderHashCommitedBlsAddress(address _builder) external view returns (bytes32[] memory);

    /// @notice Check if a builder exists.
    /// @param _builder The address of the builder.
    /// @return True if the builder exists, false otherwise.
    function getBuilderExists(address _builder) external view returns (bool);

    /// @notice Get the release time for a builder's withdrawal.
    /// @param _builder The address of the builder.
    /// @return release time for the withdrawal.
    function getBuilderReleaseTime(address _builder) external view returns (uint256);
}