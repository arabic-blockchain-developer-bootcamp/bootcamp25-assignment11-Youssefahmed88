// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Assignment11 {
    mapping(address => uint256) public contributions;
    address public owner;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        /* @audit-issue: Ownership can be stolen becuase the comparision based on `contributions[msg.sender]` (from `msg.value`), was sent in the last transaction,
        not comparing the real account balances between Owner and Attacker */
        /* @Patch:

            if (address(this).balance > address(owner).balance) {
            owner = msg.sender;
        }*/
       
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}