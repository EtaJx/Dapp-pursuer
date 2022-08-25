// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// 1. create a candidate ( a candidate simply a user that has uploaded an image)
// 2. Get all candidate with their images
// 3. Increase the votes from one candidate, if a user likes the image from that specific candidate

contract VoteManager {

    // each candidate's field
    struct Candidate {
        uint id;
        uint totalVote; // track current candidates votes
        string name;
        string imageHash; // store the IPFS Hash for the image
        address candidateAddress; // public key address of the candidate
    }

    using Counters for Counters.Counter;
    Counters.Counter private candidatesIds;

    mapping(address => Candidate) private candidates;
    mapping(uint => address) private accounts;

    event Voted(address indexed _candidateAddress, address indexed _voterAddress, uint _totalVote);
    event candidateCreated(address indexed candidateAddress, string name);

    // register candidate
    // `calldata` - immutable, temporary location where the function arguments are stored, and behaves mostly like `memory`
    // `memory` - variable is in memory and it exists while a function is being called
    // `storage` - where all state variables are stored, variable must be mutable, store on blockchain

    // `external` function means that this function can only be called from outside the contract.
    // also can mark it as public, but it would be gas inefficient.
    function registerCandidate(string calldata _name, string calldata _imageHash) external {
        require(msg.sender != address(0), "Sender address must be valid");

        candidatesIds.increment();
        uint candidateId = candidatesIds.current();
        address _address = address(msg.sender);
        Candidate memory newCandidate = Candidate(candidateId, 0, _name, _imageHash, _address);
        candidates[_address] = newCandidate;
        accounts[candidateId] = msg.sender;
        emit candidateCreated(_address, _name);
    }

    function fetchCandidates() external view returns (Candidate[] memory) {
        uint itemCount = candidatesIds.current();

        Candidate[] memory candidatesArray = new Candidate[](itemCount);
        for (uint i = 0; i < itemCount; i++) {
            uint currentId = i + 1;
            Candidate memory currentCandidate = candidates[accounts[currentId]];
            candidatesArray[i] = currentCandidate;
        }
        return candidatesArray;
    }

    function vote(address _forCandidate) external {
        candidates[_forCandidate].totalVote += 1;
        emit Voted(_forCandidate, msg.sender, candidates[_forCandidate].totalVote);
    }
}
