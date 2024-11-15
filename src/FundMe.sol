// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    error FundMe__NotOwner();
    error FundMe__NotEnoughEth();
    error FundMe__FailWithdraw();

    event Funded(address indexed sender, uint256 indexed amount);
    event Withdraw(uint256 indexed amount);

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need spend more eth!"
        );

        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);

        emit Funded(msg.sender, msg.value);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    function cheaperWithdraw() public onlyOwner{
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        delete s_funders;
        s_funders = new address[](0);

        uint256 amount = address(this).balance;
        (bool callSuccess, ) = payable(msg.sender).call{value: amount}("");
        if (!callSuccess) {
            revert FundMe__FailWithdraw();
        }

        emit Withdraw(amount);
    }
    

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        delete s_funders;
        s_funders = new address[](0);

        uint256 amount = address(this).balance;
        (bool callSuccess, ) = payable(msg.sender).call{value: amount}("");
        if (!callSuccess) {
            revert FundMe__FailWithdraw();
        }

        emit Withdraw(amount);
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    //** view / pure functions (getter) */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunders(uint256 funderIndex) external view returns (address) {
        return s_funders[funderIndex];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getLengthOfFunders() external view returns (uint256) {
        return s_funders.length;
    }
}
