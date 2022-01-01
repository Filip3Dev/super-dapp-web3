pragma solidity 0.8.10;
// SPDX-License-Identifier: MIT
contract Raffle {
  struct Ticket {
    string fullname;
    string email;
    uint256 block;
    address wallet;
  }

 // State
  address public owner;

  Ticket[] public tickets;
  Ticket[] public drawnTickets;

  mapping (address => Ticket) public users;
  uint256 public dateChange;
  uint256 public dateRun;

  event TicketBought(string);
  event TicketDrawn();

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  constructor() {
    owner = msg.sender;
    dateChange = block.timestamp;
  }

  // Sell a ticket. Validate that the email associated to the buyer doesn't have a ticket already
  function buyTicket(string memory fullname, string memory email) public returns (bool confirmation){
    bool exists = false;
    for (uint i = 0; !exists && i < tickets.length; i++) {
      Ticket memory ticket = tickets[i];

      if (keccak256(abi.encodePacked(email)) == keccak256(abi.encodePacked(ticket.email))) {
        exists = true;
      }
    }

    if (!exists) {
      Ticket memory newTicket = Ticket(fullname, email, block.number, msg.sender);
      tickets.push(newTicket);
      users[msg.sender] = newTicket;
      emit TicketBought(email);
      dateChange = block.timestamp;
      return true;
    } else {
        return false;
    }
  }

  function currentWinner() public view returns (string memory fullname, string memory email, uint256 block, address wallet) {
    if (drawnTickets.length > 0) {
        return (
            drawnTickets[drawnTickets.length - 1].fullname,
            drawnTickets[drawnTickets.length - 1].email,
            drawnTickets[drawnTickets.length - 1].block,
            drawnTickets[drawnTickets.length - 1].wallet
        );
    } else {
        return ('', '', 0, msg.sender);
    }
  }

  function size() public view returns (uint) {
    return tickets.length;
  }

  function getTickets() public view returns (Ticket[] memory){
      Ticket[] memory lTickets = new Ticket[](tickets.length);
      for (uint i = 0; i < tickets.length; i++) {
          Ticket storage lTicket = tickets[i];
          lTickets[i] = lTicket;
      }
      return lTickets;
  }

  function drawnSize() public view returns (uint) {
    return drawnTickets.length;
  }

  function drawTicket() public restricted {
    require(msg.sender == owner);
    require(dateRun < block.timestamp);

    uint idx = randomTicketIndex();
    drawnTickets.push(tickets[idx]);
    removeTicket(idx);
    emit TicketDrawn();
    cleanTickets();
  }

  function removeTicket(uint idx) internal restricted {
    for (uint i = idx; i + 1 < tickets.length; i++) {
      tickets[i] = tickets[i+1];
    }
    delete tickets[tickets.length - 1];
  }
  
  function cleanTickets() internal restricted {
    for (uint i = 0;i < tickets.length; i++) {
      Ticket memory ticket = tickets[i];
      delete users[ticket.wallet];
    }
    delete tickets;
    dateRun = block.timestamp + 7 days;
  }

  function randomTicketIndex() internal view returns (uint) {
    uint idx = random() % tickets.length;
    return idx;
  }

  function random() internal view returns (uint) {
    uint seed = block.number;

    uint a = 1103515245;
    uint c = 12345;
    uint m = 2 ** 32;

    return (a * seed + c) % m;
  }
}