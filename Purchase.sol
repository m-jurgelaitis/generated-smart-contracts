// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Purchase {
    uint public value;
    address payable public seller;
    address payable public buyer;
    State public state;
    enum State {Inactive, Release, Created, Locked}
    modifier atState(State _state) {
        require(state == _state);
        _;
    }
    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }
    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        require((2 * value) == msg.value, "Value has to be even.");

        state = State.Created;
    }

    function confirmReceived() public atState(State.Locked) {
        require(msg.sender == buyer);

        buyer.transfer(value);

        emit ItemReceived();
        state = State.Release;
    }

    function confirmPurchase() public payable atState(State.Created) {
        require(msg.value == (2 * value));

        buyer = payable(msg.sender);

        emit PurchaseConfirmed();
        state = State.Locked;
    }

    function abort() public atState(State.Created) onlySeller {
        seller.transfer(address(this).balance);

        emit Aborted();
        state = State.Inactive;
    }

    function refundSeller() public atState(State.Release) onlySeller {
        seller.transfer(3 * value);

        emit SellerRefunded();
        state = State.Inactive;
    }
}