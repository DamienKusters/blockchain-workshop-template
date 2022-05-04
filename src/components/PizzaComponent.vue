<template>
  <div>
    <header>
      <h1>
          The Pizzeria is
          <span class="card" v-if="open == null">...</span>
          <span class="card open" v-else-if="open == true">Open!</span>
          <span class="card closed" v-else-if="open == false">Closed</span>
          <!-- <span :class="{closed:true, open:this.open}">{{open ? "Open!" : "Closed..."}}</span> -->
      </h1>
      <div v-if="open != null">
        <div v-if="account">
          <img height="50" :src="require('../assets/metamask.svg')" />
          <br />
          <div>{{account[0].substring(0,11) + "..."}}</div>
        </div>
        <div v-else>
          <img height="50" :src="require('../assets/metamask.svg')" />
          <br />
          <button @click="connectToMetaMask()">Connect to MetaMask</button>
        </div>
      </div>
      <div>
        <p>Blockchain: {{blockchainUrl}}</p>
        <p>Address: {{this.address.substring(0,7) + "..."}}</p>
      </div>
    </header>
    <div class="content">
      <p>This website will call the Smart Contract function 'getOpen()' to see if the contract is available and open the Pizzeria.</p>
      <button v-if="account" @click="togglePizzeria()">{{open ? "Close Pizzeria" : "Open Pizzeria"}}</button>
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
      this.contract = markRaw(new this.ethers.Contract(this.address, this.abi, providerOrSigner));
    },
    async togglePizzeria()
    {
      var res = await this.contract.setOpen(!this.open);
      await this.contract.provider.waitForTransaction(res['hash']);
      this.open = await this.contract.getOpen();
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
    }
  }
}
</script>

<style scoped>
header {
  display: grid;
  grid-template-columns: 4fr 1fr 1fr;
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
</style>