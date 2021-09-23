<template>
  <div id="app">
    <div ref="map" class="map"></div>
  </div>
</template>

<script>
import GeoJSON2Building from './GeoJSON2Building'
import Hemisphere from './Hemisphere'
import mapboxgl from 'mapbox-gl'
import { Threebox } from 'threebox-plugin'
import * as THREE from 'three'
import 'mapbox-gl/dist/mapbox-gl.css'

export default {
  name: 'App',
  components: {},
  mounted () {
    const self = this

    const map = new mapboxgl.Map({
      container: this.$refs.map,
      // style: '/static/map/style/style.json',
      style:
        'http://localhost:3000/static/map/style/night-style-no-building.json',
      center: [116.44112528833665, 39.9293], // starting position [lng, lat]
      // center: [0, 0],
      pitch: 45,
      bearing: -45,
      zoom: 14, // starting zoom
      antialias: true
    })

    map.on('click', (e) => {
      console.log(e)
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

      // -----------------------------
      function animate () {
        requestAnimationFrame(animate)

        // if (self.hemisphere) {
        //   self.hemisphere.update({
        //     time: performance.now()
        //   })
        //   map.triggerRepaint() // 必须调用重绘
        // }
      }

      animate()

      map.addLayer({
        id: 'custom_layer',
        type: 'custom',
        renderingMode: '3d',
        onAdd: async function (map, gl) {
          // instantiate threebox
          window.tb = new Threebox(
            map,
            gl, // get the context from Mapbox
            {
              defaultLights: true
            }
          )

          const scale = 0.01
          const geometry = new THREE.BoxGeometry(
            30 * scale,
            30 * scale,
            30 * scale
          )
          const cube = new THREE.Mesh(
            geometry,
            new THREE.MeshPhongMaterial({
              transparent: true,
              opacity: 0.5,
              color: 0x660000
            })
          )

          const coord = tb.projectToWorld([
            116.391229827904, 39.907092084593216
          ])
          cube.position.copy(coord)

          window.tb.add(cube)

          const jsonRes = await fetch(
            'http://localhost:3000/static/geojson/chaoyang_building.json'
          )
          const json = await jsonRes.json()

          const toBuilding = new GeoJSON2Building(json, { tb })
          const models = toBuilding.getModel()

          models.forEach((m) => {
            tb.add(m)
          })

          // --------------------------
          // self.hemisphere = new Hemisphere({
          //   tb,
          //   lnglat: [116.44112528833665, 39.9293]
          // })

          // tb.add(self.hemisphere.getModel())

          // setTimeout(() => {
          //   map.easeTo({
          //     zoom: 16,
          //     duration: 5000
          //   })

          //   setTimeout(() => {
          //     map.easeTo({
          //       pitch: 45,
          //       bearing: 45,
          //       duration: 5000
          //     })
          //   }, 5200)
          // }, 3000)
        },

        render: function (gl, matrix) {
          window.tb.update()
        }
      })
    })
  },
  beforeDestroy () {
    tb.dispose()
  }
}
</script>

<style>
.map {
  height: 100%;
}
</style>
