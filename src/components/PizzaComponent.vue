<template>
  <div>
    <header>
      <h1>
          De Pizzeria is
          <span class="card" v-if="open == null">...</span>
          <span class="card open" v-else-if="open == true">Open!</span>
          <span class="card closed" v-else-if="open == false">Gesloten</span>
      </h1>
      <!-- Connect to MetaMask Button -->
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
      <p>De website roept de functie 'getOpen()' aan in de 'PizzaContract' Smart Contract.</p>
      <div v-if="open != null">
        <button :disabled="!account" @click="togglePizzeria()">{{open ? "Sluit Pizzeria" : "Open Pizzeria"}}</button>
        <p>Deze knop zal de 'setOpen()' Smart Contract functie aanroepen. <br/> Omdat 'setOpen()' een aanpassing is aan de inhoud van de Smart Contract, moeten de Gas fees worden betaald door het account dat het aanroept.</p>
      </div>
      <hr />
      <div>
        <button  @click="buyPizza()">Bestel Pizza ({{pizzaCost}} ETH)</button>
        <p v-if="error" class="error">Je kan geen pizza kopen: '{{error}}'</p>
      </div>
    </div>
  </div>
</template>

<script>
import { markRaw } from '@vue/reactivity';

export default {
  inject: ["ethers", "address", "abi"],
  data()
  {
    return {
      contract: null,
      blockchainUrl: "http://127.0.0.1:7545",
      open: null,
      account: null,
      error: null,

      pizzaCost: "0.4"
    }
  },
  mounted(){
    var provider = new this.ethers.providers.JsonRpcProvider(this.blockchainUrl);
    this.createContract(provider);
    this.load();
  },
  methods: {
    async load()
    {
      //Example of reading from a Blockchain
      this.open = await this.contract.getOpen();
    },
    async login()
    {
      try
      {
        const { ethereum } = window;
        if (!ethereum)
          return console.log("Make sure you have metamask!");
        const accounts = await ethereum.request({ method: "eth_accounts" });
        if (accounts.length !== 0)
          this.accountAddress = accounts[0];
        else
          this.accountAddress = null;
        return this.accountAddress;
      } catch (error) { console.log(error); return null; }
    },
    async createContract(providerOrSigner)
    {
      //Een provider kan 
      this.contract = markRaw(new this.ethers.Contract(this.address, this.abi, providerOrSigner));
    },
    async togglePizzeria()
    {
      var res = await this.contract.setOpen(!this.open);
      await this.contract.provider.waitForTransaction(res['hash']);
      this.open = await this.contract.getOpen();
    },
    async buyPizza()
    {
      try {
        var res = await this.contract.buyPizza({value: this.ethers.utils.parseEther(this.pizzaCost)});
        await this.contract.provider.waitForTransaction(res['hash']);
      } catch (e) {
        console.error(e);
        this.error = this.convertToError(e);
      }
    },
    async connectToMetaMask()
    {
      const { ethereum } = window;

      if(this.account == null)
      {
        try {
          this.account = await ethereum.request({method: "eth_requestAccounts"});
        } catch (error) {
          return;
        }
      }

      const metamaskProvider = new this.ethers.providers.Web3Provider(ethereum);
      const signer = metamaskProvider.getSigner();

      this.createContract(signer);
    },
    convertToError(e)
    {
      if(e.data)
      {
        return e.data['message'].split(': revert')[1];
      }
      else
      {
        return e.toString().split("Error: ")[1].split(" (")[0];
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
.open {
  background-color: green;
}
.closed {
  background-color: darkred;
}

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
</style>