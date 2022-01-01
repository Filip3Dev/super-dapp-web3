// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract Register {
  address public owner = msg.sender;
  string public text;
  uint256 public dateChange;

  constructor() {
    dateChange = block.timestamp;
    text = "";
  }

  function setText(string memory _text) public {
    text = _text;
    dateChange = block.timestamp;
  }
}
