const PizzaContract = artifacts.require("PizzaContract");

module.exports = function (deployer) {
  deployer.deploy(PizzaContract);
};
