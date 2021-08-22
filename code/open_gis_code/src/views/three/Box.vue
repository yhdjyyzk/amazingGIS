<template>
  <div id="app">
    <div ref="map" class="map"></div>
  </div>
</template>

<script>
import { Threebox } from 'threebox-plugin'
import * as THREE from 'three'
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
      zoom: 15, // starting zoom
      antialias: true
    })

    // function animate () {
    //   requestAnimationFrame(animate)
    // }

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

      // -----------------------------
      // animate()

      map.addLayer({
        id: 'custom_layer',
        type: 'custom',
        renderingMode: '3d',
        onAdd: function (map, gl) {
          // instantiate threebox
          window.tb = new Threebox(
            map,
            gl, // get the context from Mapbox
            { defaultLights: true }
          )
          var geometry = new THREE.BoxGeometry(30, 30, 30)
          let cube = new THREE.Mesh(
            geometry,
            new THREE.MeshPhongMaterial({ transparent: true, opacity: 0.5, color: 0x660000 })
          )
          cube = window.tb.Object3D({ obj: cube, units: 'meters' })
          cube.setCoords([116.391229827904, 39.907092084593216])
          window.tb.add(cube)
        },

        render: function (gl, matrix) {
          window.tb.update()
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
