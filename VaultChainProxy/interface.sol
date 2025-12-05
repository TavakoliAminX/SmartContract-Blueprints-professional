// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Chainlink AggregatorV3 interface (commonly named AggregatorV3Interface)
interface AggregatorV3Interface {
    /// @notice Number of decimals the aggregator responses are scaled by
    function decimals() external view returns (uint8);

    /// @notice Short description of the aggregator (e.g., "ETH / USD")
    function description() external view returns (string memory);

    /// @notice Version of the aggregator contract
    function version() external view returns (uint256);

    /**
     * @notice Get historical round data
     * @param _roundId the round ID to fetch
     * @return roundId id of the round
     * @return answer price (signed integer)
     * @return startedAt timestamp when round started
     * @return updatedAt timestamp when round was last updated
     * @return answeredInRound round ID in which the answer was computed
     */
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    /**
     * @notice Get latest round data
     * @return roundId id of the latest round
     * @return answer latest price (signed integer)
     * @return startedAt timestamp when the latest round started
     * @return updatedAt timestamp when the latest round was last updated
     * @return answeredInRound round ID in which the latest answer was computed
     */
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}
