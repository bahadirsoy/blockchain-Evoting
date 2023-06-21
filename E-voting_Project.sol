pragma solidity >=0.4.22 <0.7.0;

contract VotingApp {
  struct Participant {
      uint weight;
      bool voted;
      address delegate;
      uint vote;
  }
}