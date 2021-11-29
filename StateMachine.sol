// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract StateMachine {
    State public state = State.AcceptingBlindedBids;
    uint public creationTime = block.timestamp;

    enum State { AcceptingBlindedBids, RevealBids, AnotherStage, AreWeDoneYet, Finished}
    modifier atState(State _state) {
        require(state == _state);
        _;
    }

    modifier timedTransitions() {
        if (state == State.AcceptingBlindedBids && block.timestamp >= creationTime + 2 minutes)
        state = State.RevealBids;
        if (state == State.RevealBids && block.timestamp >= creationTime + 5 minutes)
        state = State.AnotherStage;
        _;
    }

    function bid() public payable timedTransitions atState(State.AcceptingBlindedBids) {
    }

    function reveal() public timedTransitions atState(State.RevealBids) {
    }

    function g() public timedTransitions atState(State.AnotherStage) {
        state = State.AreWeDoneYet;
    }

    function h() public timedTransitions atState(State.AreWeDoneYet) {
        state = State.Finished;
    }

    function i() public timedTransitions atState(State.Finished) {
    }
}