<template>
  <div id="app">
    <router-view/>
  </div>
</template>

<style lang="less">
#app {
  height: 100%;
}

#nav {
  padding: 30px;

  a {
    font-weight: bold;
    color: #2c3e50;

    &.router-link-exact-active {
      color: #42b983;
    }
  }
}
</style>
