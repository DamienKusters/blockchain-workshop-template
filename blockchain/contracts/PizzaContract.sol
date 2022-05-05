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

  function setOpen(bool value) external
  {
    open = value;
  }

  function buyPizza(string memory pizza) external payable {
    //1.  Make sure this function call is allowed:
    require(open == true, "Pizzeria is closed");//require(boolean, string) functions require the given boolean to be true, or the given string will be returned as error.
    require(msg.value == 0.7 ether, "A pizza costs 0.7 ETHER");//'msg.value' = the amount of crypto send.
    require(pizzaSales[pizza] == address(0x0), "This pizza has been sold already");//address(0x0) means no address / empty address.

    //2.  Transfer provided ETHER to the seller:
    payable(seller).transfer(msg.value);

    //3.  Save the sale in the Smart Contract:
    pizzaSales[pizza] = msg.sender;
  }

  //TODO:
  //Create a function that:
  //  - Takes the pizza name as a parameter.
  //  - Checks if the send pizza name exists in the Smart Contract.
  //  - Returns the crypto address that has bought that pizza.
}
