// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PizzaContract {

  address seller = 0x330621a4A93ab55575923A765d9B0e2c3D629b3a;
  //Private key of seller's account: e7186783bd67b5e00b3fe81215471da51f1932b457837845219117ff09064c95

  bool open = false;

  mapping(string => address) pizzaSales;//pizza name => buyer

  function getOpen() external view returns(bool)
  {
    return open;
  }

  function setOpen(bool _open) external
  {
    open = _open;
  }

  //TODO: Explain memory
  function buyPizza(string memory pizza) external payable {
    require(open == true, "Pizzeria is closed");
    require(msg.value == 0.7 ether, "A pizza costs 0.7 ETHER");//msg.value = the amount of crypto send.

    //address(0x0) means no address / empty address.
    require(pizzaSales[pizza] == address(0x0), "This pizza has been sold already");

    payable(seller).transfer(msg.value);//Transfer ETHER to the seller

    pizzaSales[pizza] = msg.sender;//msg.sender = the crypto address that called the function.
  }

  //Function to be made by the attendees:
  function getPizzaBuyer(string memory pizza) external view returns(address)
  {
    require(pizzaSales[pizza] != address(0x0), "No one owns this pizza");
    return pizzaSales[pizza];
  }
}
