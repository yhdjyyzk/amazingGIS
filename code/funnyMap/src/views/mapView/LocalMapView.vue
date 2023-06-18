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
        style: 'http://localhost:3000/static/map/style/osm_liberty1.json',
        center: [116.391229827904, 39.907092084593216], // starting position [lng, lat]
        zoom: 5, // starting zoom
        antialias: true
      })
    })

    onUnmounted(() => {
      map.destroy()
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
