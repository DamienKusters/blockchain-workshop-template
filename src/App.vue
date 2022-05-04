<template>
  <PizzaComponent msg="Welcome to Your Vue.js App"/>
</template>

<script>
import PizzaComponent from './components/PizzaComponent.vue'

export default {
  name: 'App',
  components: {
    PizzaComponent
  }
}
</script>

<style>
body {
  margin: 0;
}

#app {
  font-family: 'Gill Sans', 'Gill Sans MT', Calibri, 'Trebuchet MS', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
