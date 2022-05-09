<template>
  <div>
    <header>
      <h1>
          De Pizzeria is
          <span class="card" v-if="open == null">Offline...</span>
          <span class="card open" v-else-if="open == true">Open!</span>
          <span class="card closed" v-else-if="open == false">Gesloten</span>
      </h1>
      <!-- MetaMask -->
      <div v-if="open != null">
        <div>
          <img height="50" :src="require('../assets/metamask.svg')" />
          <br />
          <div v-if="account">{{account[0].substring(0,11) + "..."}}</div>
          <button v-else @click="connectToMetaMask()">MetaMask Login</button>
        </div>
      </div>
    </header>

    <div class="content">
      <p v-if="open == null">
        De website probeert te communiceren met de Ganache test blockchain.
        <br />
        Hier probeert hij de functie 'getOpen()' aan te roepen in de Smart Contract (PizzaContract).
      </p>
      <div v-else>
        <p>De website probeert de functie 'getOpen()' aan te roepen in de Smart Contract (PizzaContract).</p>
        <button :disabled="!account" @click="togglePizzeria()">{{open ? "Sluit Pizzeria" : "Open Pizzeria"}}</button>
        <p>Deze knop zal de 'setOpen()' Smart Contract functie aanroepen. <br/> Omdat 'setOpen()' een aanpassing is aan de inhoud van de Smart Contract, moeten de Gas fees worden betaald door het account dat het aanroept.</p>
      </div>
      <hr />
      <!-- Pizza lijst -->
      <h2>Pizzas</h2>
      <div class="pizzaInventory">
        <div v-for="pizza in pizzas" :key="pizza">
          <img :src="tryToGetPizzaPicture(pizza)" alt="🍕" />
          <h3>Pizza {{pizza}}</h3>
          <button @click="buyPizza(pizza)">Bestel Pizza {{pizza}}<br />({{pizzaCost}} ETH)</button>
        </div>
      </div>
      <p v-if="error" class="error">Je kan geen pizza kopen: '{{error}}'</p>
      <hr />
      <!-- Klanten lijst -->
      <h2>Klanten</h2>
      <div v-for="owner in pizzaOwners" :key="owner">
        <p class="owner">{{owner}}</p>
      </div>
    </div>
  </div>
</template>

<script>
import { markRaw } from '@vue/reactivity';//This is required by Vue.js 3

export default {
  inject: ["ethers", "address", "abi"],
  data()
  {
    return {
      blockchainUrl: "http://127.0.0.1:7545",//Ganache URL
      contract: null,
      account: null,//Logged-in MetaMask Account

      open: null,
      error: null,

      pizzas: ["Pepperoni", "Tonno", "Veggie"],
      pizzaCost: "0.2",

      pizzaOwners: [],
    }
  },
  mounted()
  {
    //This provider directly connects to the Ganache blockchain.
    var provider = new this.ethers.providers.JsonRpcProvider(this.blockchainUrl);
    this.createContract(provider);

    this.load();
  },
  methods: {
    async load()
    {
      //Example of reading from a Smart Contract:
      this.open = await this.contract.getOpen();
    },
    async createContract(providerOrSigner)
    {
      //A provider provides read access to a Smart Contract.
      //A signer can call both read and write functions to a Smart Contract.
      this.contract = markRaw(new this.ethers.Contract(this.address, this.abi, providerOrSigner));
    },
    async togglePizzeria()
    {
      //Example of writing to a Smart Contract:
      var res = await this.contract.setOpen(!this.open);//We will request to open/close the pizzeria whatever it is currently not.
      await this.contract.provider.waitForTransaction(res['hash']);//This simply waits for the transaction to complete.
      this.open = await this.contract.getOpen();//When the transaction is complete, ask the Smart Contract for the new state.
    },
    async buyPizza(name)
    {
      this.error = null;
      try {
        //When we send an object with the value field {value:x} to a Smart Contract function, we can send some crypto over to the contract.
        await this.contract.buyPizza(name, {value: this.ethers.utils.parseEther(this.pizzaCost)});
      } catch (e) {
        console.error(e);
        this.error = this.convertToError(e);//We will show a readable version of the error message.
      }
    },
    async connectToMetaMask()
    {
      const { ethereum } = window;

      try {
        if(this.account == null)
          this.account = await ethereum.request({method: "eth_requestAccounts"});
      } catch (error) {
        return;
      }

      //Because the website is now connected to MetaMask; a Wallet.
      //We want to update the contract by replacing the provider with a signer.
      // (The MetaMask wallet will become the signer)
      //This allows us to use the full Smart Contract's functionalities, like modifications and sending transactions.
      const metamaskProvider = new this.ethers.providers.Web3Provider(ethereum);
      const signer = metamaskProvider.getSigner();
      this.createContract(signer);
    },

    //TODO:
    //Create a function that:
    //  - Fills the 'pizzaOwners' array with strings describing all bought pizzas and their owners.
    //  Format example: 'Pizza [pizza name] is bought by: [crypto address]'

    //Helper functions:
    tryToGetPizzaPicture(pizza)
    {
      try {
        return require('../assets/pizzas/'+pizza+'.png');
      } catch (error) {
        return "";
      }
    },
    convertToError(e)
    {
      if(e.data)//Error is coming from the Smart Contract
      {
        return e.data['message'].split(': revert ')[1];
      }
      else//Other errors, (likely MetaMask)
      {
        if(this.open == null)
          return "Er is geen verbinding met de PizzaContract";

        var err = e.toString().substring(7).split(" (")[0];
        if(err != " Object]")
          return e.toString().substring(7).split(" (")[0];
        else
          return "Transactie geannuleerd";
      }
    }
  }
}
</script>

<style scoped>
header {
  display: grid;
  grid-template-columns: 4fr 1fr;
  background: yellowgreen;
}

.card {
  background-color: lightslategray;
  color: whitesmoke;
  padding: 10px;
  border-radius: 20px;
}
.open { background-color: green; }
.closed { background-color: darkred; }

.content {
  max-width: 600px;
  margin: auto auto;
  padding: 10px;
}

.error {
  color: darkred;
  font-weight: bold;
  text-decoration: underline;
}

.owner {
  color: green;
  font-weight: bold;
  text-decoration: underline;
}

.pizzaInventory {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
}
.pizzaInventory div { padding: 10px; }
.pizzaInventory img { max-width: 90%; }
</style>