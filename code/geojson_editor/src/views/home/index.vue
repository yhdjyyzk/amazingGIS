<template>
  <div class="home">
    <map-container/>
  </div>
</template>

<script>
import MapContainer from '@/components/MapContainer.vue'

export default {
  name: 'Home',
  components: {
    MapContainer
  }
}
</script>

<style lang="less">
.home {
  height: 100%;
}
</style>
