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
      style: 'http://localhost:3000/static/map/style/night-style.json',
      center: [116.391229827904, 39.907092084593216], // starting position [lng, lat]
      zoom: 3, // starting zoom
      antialias: true
    })

    map.on('load', (e) => {
      map.addSource('world_geojson', {
        type: 'geojson',
        data: 'http://localhost:3000/static/geojson/world.json'
      })

      map.addLayer({
        id: 'world_map',
        source: 'world_geojson',
        type: 'line',
        paint: {
          'line-color': '#efe9e1'
        }
      })

      map.addLayer({
        id: 'world_country_name',
        source: 'world_geojson',
        type: 'symbol',
        layout: {
          'text-field': '{chinese}',
          'text-font': ['KlokanTech Noto Sans Regular'],
          'text-size': 12,
          visibility: 'visible'
        },
        paint: {
          'text-color': 'rgba(255,255,255,0.75)'
        }
      })
    })
  }
}
</script>

<style>
.map {
  height: 100%;
}
</style>
