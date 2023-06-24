<template>
  <div ref="el" class="local-map-view"></div>
</template>

<script lang="ts">
import { defineComponent, onMounted, onUnmounted, ref } from 'vue'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'

export default defineComponent({
  setup() {
    const el = ref()

    let map: mapboxgl.Map = null
    onMounted(() => {
      map = new mapboxgl.Map({
        container: el.value,
        style: 'http://localhost:9001/static/map/style/osm_liberty2.json',
        center: [110, 31],
        zoom: 3.5,
        antialias: true
      })
    })

    onUnmounted(() => {
      map.remove()
    })

    return {
      el
    }
  }
})
</script>

<style lang="less" scoped>
.local-map-view {
  height: 100%;
}
</style>
