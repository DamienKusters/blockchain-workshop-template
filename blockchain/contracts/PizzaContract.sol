// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PizzaContract {

  address seller = 0x330621a4A93ab55575923A765d9B0e2c3D629b3a;
  //Private key of seller's account: e7186783bd67b5e00b3fe81215471da51f1932b457837845219117ff09064c95

  bool open = false;

  uint sold = 0;

  function getOpen() external view returns(bool)
  {
    return open;
  }

  function setOpen(bool _open) external
  {
    open = _open;
  }

  function buyPizza() external payable {
    require(open == true, "Pizzeria is closed");
    require(msg.value == 0.7 ether, "A pizza costs 0.7 ETHER");

    payable(seller).transfer(msg.value);// Send ETH to the seller

    sold++;
  }

  //msg variable:
  //msg.value = the amount of crypto send.
  //msg.sender = the account address that called the function.
}
