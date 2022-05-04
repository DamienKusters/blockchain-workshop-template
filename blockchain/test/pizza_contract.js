const PizzaContract = artifacts.require("PizzaContract");

contract("PizzaContract", function () {
  before(async () => {
    //Ensure the contract is deployed before tests are run
    contract = await PizzaContract.deployed();
  });

  it("should be open", async function () {
    var online = await contract.getOpen();
    return assert.isTrue(online);
  });

  it("should be able to close", async function () {
    try {
      await contract.setOpen(false);
      assert.isTrue(true);
    } catch (error) {
      assert.isTrue(false);
    }
  });

  it("should be closed", async function () {
    var online = await contract.getOpen();
    return assert.isTrue(online == false);
  });
});
