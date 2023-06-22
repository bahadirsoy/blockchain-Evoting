pragma solidity >= 0.4 .22 < 0.7 .0;

contract VotingApp {
    struct Participant {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address public organizer;

    mapping(address => Participant) public participants;

    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) public {
        organizer = msg.sender;
        participants[organizer].weight = 1;
    }

    for (uint i = 0; i < proposalNames.length; i++) {
        proposals.push(Proposal({
            name: proposalNames[i],
            voteCount: 0
        }));
    }
}