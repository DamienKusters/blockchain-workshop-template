// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PizzaContract {

  bool open = false;

  function getOpen() external view returns(bool)
  {
    return open;
  }

  function setOpen(bool _open) external
  {
    open = _open;
  }
}
