pragma solidity >=0.8.6 <0.9.0;

interface IAccountHandler {
    function getBuilderBalance(address _builder) external view returns (uint256);
    function getBuilderHashCommitedBlsAddress(address _builder) external view returns (bytes32[] memory);
    function getBuilderExists(address _builder) external view returns (bool);
    function getBuilderReleaseTime(address _builder) external view returns (uint256);
}