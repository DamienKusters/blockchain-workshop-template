import { createApp } from 'vue'
import { ethers } from 'ethers';
import PizzaContract from '../blockchain/build/contracts/PizzaContract.json';
import App from './App.vue'

const app = createApp(App)
app.provide("ethers", ethers)
app.provide("address", PizzaContract['networks']['5777']['address'])
app.provide("abi", PizzaContract['abi'])
app.mount('#app')
