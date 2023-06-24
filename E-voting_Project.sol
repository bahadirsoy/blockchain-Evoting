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
}