<template>
  <div id="app">
    <div ref="map" class="map"></div>
  </div>
</template>

<script>
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'

export default {
  name: 'App',
  components: {},
  mounted () {
    const map = new mapboxgl.Map({
      container: this.$refs.map,
      // style: '/static/map/style/style.json',
      style: 'http://localhost:3000/static/map/style/street-style.json',
      center: [116.45911895415747, 39.90799060367809], // starting position [lng, lat]
      zoom: 15,
      pitch: 60,
      bearing: -43
    })
  }
}
</script>

<style>
.map {
  height: 100%;
}
</style>
