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

    struct Validator {
        address validatorAddress;
        uint256 stake;
        bool isValidator;
    }

    address public organizer;
    mapping(address => Participant) public participants;
    Proposal[] public proposals;
    mapping(address => Validator) public validators;
    uint256 public totalStake;
    uint256 public consensusThreshold = 50; // Minimum stake percentage required for consensus

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

    function assignVotingRight(address participant) public {
        require(
            msg.sender == organizer,
            "Only the organizer can assign voting rights."
        );
        require(
            !participants[participant].voted,
            "The participant has already voted."
        );
        require(participants[participant].weight == 0);
        participants[participant].weight = 1;

    }

    function stakeTokens() public payable {
        require(msg.value > 0, "You must stake some tokens.");

        Validator storage validator = validators[msg.sender];
        require(!validator.isValidator, "You have already staked tokens.");

        validator.validatorAddress = msg.sender;
        validator.stake = msg.value;
        validator.isValidator = true;

        totalStake += msg.value;
    }

    function delegateVote(address to) public {
        Participant storage sender = participants[msg.sender];
        require(!sender.voted, "You have already voted.");
        require(to != msg.sender, "Self-delegation is not allowed.");

        while (participants[to].delegate != address(0)) {
            to = participants[to].delegate;
            require(to != msg.sender, "Found a loop in the delegation.");
        }

        sender.voted = true;
        sender.delegate = to;

        Participant storage delegate_ = participants[to];
        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function voteForProposal(uint proposal) public {
        Validator storage validator = validators[msg.sender];
        require(!participants[msg.sender].voted, "You have already voted.");

        participants[msg.sender].voted = true;
        participants[msg.sender].vote = proposal;
        proposals[proposal].voteCount += validator.stake;
    }

    function calculateConsensus() private view returns (bool) {
        uint256 winningVoteCount = proposals[0].voteCount;
        for (uint256 p = 1; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
            }
        }

        return (winningVoteCount * 100) >= (totalStake * consensusThreshold);
    }

    function getWinningProposal() public view returns (uint winningProposal_) {
        require(calculateConsensus(), "Consensus has not been reached.");

        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function getWinnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[getWinningProposal()].name;
    }
}