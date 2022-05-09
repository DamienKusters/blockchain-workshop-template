const PizzaContract = artifacts.require("PizzaContract");

contract("PizzaContract", function () {
  before(async () => {
    //Ensure the contract is deployed before tests are run
    contract = await PizzaContract.deployed();
  });

  it("should be closed on startup", async function () {
    var online = await contract.getOpen();
    return assert.isTrue(online == false);
  });

  it("should be able to open", async function () {
    try {
      await contract.setOpen(true);
      assert.isTrue(true);
    } catch (error) {
      assert.isTrue(false);
    }
  });

  it("should be open", async function () {
    var online = await contract.getOpen();
    return assert.isTrue(online == true);
  });
});
