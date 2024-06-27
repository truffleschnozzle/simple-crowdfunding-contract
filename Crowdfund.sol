// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

contract Crowdfunding {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public fundsRaised;

    mapping(address => uint) public contributions;

    constructor(uint _goal, uint _duration) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign is over");
        require(msg.value > 0, "Contribution must be more than 0");
        contributions[msg.sender] += msg.value;
        fundsRaised += msg.value;
    }

    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw funds");
        require(block.timestamp >= deadline, "Campaign is still in progress");
        require(fundsRaised >= goal, "Funding goal has not been reached");
        (bool sent, ) = payable(owner).call{value: fundsRaised}("");
        require(sent == true, "Transfer failed");
    }

    function getRefund() external {
        require(block.timestamp >= deadline, "Campaign is still in progress");
        require(fundsRaised < goal, "Funding goal has been reached");
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution found from your address");
        contributions[msg.sender] = 0;
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent == true, "Transfer failed");
    }
}
