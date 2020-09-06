<template>
  <div id="app">
    <button class="change-style" @click="onClickChangeStyle">change style</button>
    <div ref="map" class="map" @click="onClickMap"></div>
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
      center: [116.391229827904, 39.907092084593216], // starting position [lng, lat]
      zoom: 16, // starting zoom
      style: {
        glyphs: '/cdn/map/fonts/{fontstack}/{range}.pbf',
        version: 8,
        sources: {
          beijingSource: {
            type: 'vector',
            scheme: 'tms',
            tiles: [
              'http://localhost/geoserver/gwc/service/tms/1.0.0/beijing_test%3Abeijing_shp@EPSG%3A900913@pbf/{z}/{x}/{y}.pbf' // 使用nginx转发
            ]
          }
        },
        layers: []
      }
    })

    this.$map = map

    map.on('load', function () {
      // --------- 背景 -----------
      map.addSource('bg', {
        type: 'geojson',
        data: {
          type: 'FeatureCollection',
          features: [
            {
              type: 'Feature',
              properties: {},
              geometry: {
                type: 'Polygon',
                coordinates: [
                  [
                    [115.13671875, 39.2492708462234],
                    [117.57568359374999, 39.2492708462234],
                    [117.57568359374999, 41.08763212467916],
                    [115.13671875, 41.08763212467916],
                    [115.13671875, 39.2492708462234]
                  ]
                ]
              }
            }
          ]
        }
      })

      // ------------------ bg
      map.addLayer({
        id: 'bg',
        source: 'bg',
        type: 'fill',
        paint: {
          'fill-color': '#efe9e1'
        }
      })

      // ---------------- natural
      map.addLayer({
        id: 'natural-not-water',
        source: 'beijingSource',
        'source-layer': 'natural',
        type: 'fill',
        minzoom: 12,
        filter: ['!=', 'type', 'water'],
        paint: {
          'fill-color': '#B3E49B',
          'fill-opacity': 1
        }
      })

      map.addLayer({
        id: 'natural-water',
        source: 'beijingSource',
        'source-layer': 'natural',
        type: 'fill',
        minzoom: 12,
        filter: ['==', 'type', 'water'],
        paint: {
          'fill-color': '#75CFEF',
          'fill-opacity': 1
        }
      })

      // ---------------- landuse
      map.addLayer({
        id: 'landuse',
        source: 'beijingSource',
        'source-layer': 'landuse',
        type: 'fill',
        minzoom: 12,
        paint: {
          'fill-color': '#B3E49B',
          'fill-opacity': 1
        }
      })

      //  --------------- road
      map.addLayer({
        id: 'roads-primary',
        source: 'beijingSource',
        'source-layer': 'roads',
        filter: ['==', 'type', 'primary'],
        type: 'line',
        //   minzoom: 12,
        paint: {
          'line-color': '#ffffff',
          'line-opacity': 1,
          'line-width': 8
        }
      })

      map.addLayer({
        id: 'roads-tertiary',
        source: 'beijingSource',
        'source-layer': 'roads',
        filter: ['==', 'type', 'tertiary'],
        type: 'line',
        //   minzoom: 12,
        paint: {
          'line-color': '#ffffff',
          'line-opacity': 1,
          'line-width': 3
        }
      })

      // -------------------- railways
      map.addLayer({
        id: 'railways',
        source: 'beijingSource',
        'source-layer': 'railways',
        type: 'line',
        //   minzoom: 12,
        paint: {
          'line-color': '#f2934a',
          'line-opacity': 1,
          'line-width': 3
        }
      })

      // ------------------ building
      map.addLayer({
        id: 'buildings',
        source: 'beijingSource',
        'source-layer': 'buildings',
        type: 'fill',
        minzoom: 13,
        paint: {
          'fill-color': '#dfdcd7',
          'fill-opacity': 1
        }
      })

      map.addLayer({
        id: 'buildings-stroke',
        source: 'beijingSource',
        'source-layer': 'buildings',
        type: 'line',
        minzoom: 13,
        paint: {
          'line-color': '#aaaaaa',
          'line-opacity': 0.8
        }
      })

      //   map.addLayer({
      //     id: "3d-buildings",
      //     source: "beijingSource",
      //     "source-layer": "buildings",
      //     type: "fill-extrusion",
      //     minzoom: 12,
      //     paint: {
      //       "fill-extrusion-color": "#dfdcd7",
      //       "fill-extrusion-opacity": 1,
      //       "fill-extrusion-height": 50,
      //     },
      //   });

      // --------------- poi
      map.addLayer({
        id: 'points-name',
        source: 'beijingSource',
        'source-layer': 'points',
        type: 'symbol',
        layout: {
          'text-field': '{name}',
          'text-transform': 'uppercase',
          'text-font': ['Microsoft YaHei Regular'],
          'text-padding': 10,
          'text-size': 12
        },
        paint: {
          'text-halo-color': 'rgb(200, 200, 200)',
          'text-halo-width': 1,
          'text-color': 'rgb(0, 0, 0)',
          'text-halo-blur': 0.5
        },
        interactive: true
      })

      map.addLayer({
        id: 'roads-name',
        source: 'beijingSource',
        'source-layer': 'roads',
        type: 'symbol',
        layout: {
          'text-field': '{name}',
          'text-transform': 'uppercase',
          'text-font': ['Microsoft YaHei Regular'],
          'text-padding': 5,
          'text-keep-upright': false,
          'text-rotation-alignment': 'map',
          'symbol-placement': 'line-center',
          'text-pitch-alignment': 'viewport',
          'text-size': 12
        },
        paint: {
          'text-halo-color': 'rgb(200, 200, 200)',
          'text-halo-width': 1,
          'text-color': 'rgb(0, 0, 0)',
          'text-halo-blur': 0.5
        },
        interactive: true
      })

      map.addLayer({
        id: 'railways-name',
        source: 'beijingSource',
        'source-layer': 'railways',
        //   minzoom: 12,
        type: 'symbol',
        layout: {
          'text-field': '{name}',
          'text-transform': 'uppercase',
          'text-font': ['Microsoft YaHei Regular'],
          'text-padding': 5,
          'text-keep-upright': false,
          'text-rotation-alignment': 'map',
          'symbol-placement': 'line-center',
          'text-pitch-alignment': 'viewport',
          'text-size': 12
        },
        paint: {
          'text-halo-color': 'rgb(255, 255, 255)',
          'text-halo-width': 1,
          'text-color': 'rgb(0, 0, 200)',
          'text-halo-blur': 0.5
        },
        interactive: true
      })

      //   map.addSource("marker", {
      //     type: "geojson",
      //     data: {
      //       type: "Feature",
      //       geometry: {
      //         type: "Point",
      //         coordinates: [116.39068172935634, 39.8998],
      //       },
      //       properties: {
      //         title: "Mapbox DC",
      //         "marker-symbol": "monument",
      //       },
      //     },
      //   });

      //   map.addLayer({
      //     id: "marker-layer",
      //     source: "marker",
      //     type: "circle",
      //     paint: {
      //       "circle-color": "red",
      //       "circle-stroke-color": "yellow",
      //       "circle-stroke-width": 3,
      //       "circle-radius": 100,
      //     },
      //   });
    })
  },
  methods: {
    onClickMap (e) {
      const objs = this.$map.queryRenderedFeatures([
        [e.offsetX - 5, e.offsetY - 5],
        [e.offsetX + 5, e.offsetY + 5]
      ])
      console.log(objs)
    },
    onClickChangeStyle () {
      const style = this.$map.getStyle()

      const naturalWater = style.layers.find(
        (layer) => layer.id === 'natural-water'
      )
      naturalWater.paint['fill-color'] = '#ffff00'

      this.$map.setStyle(style)
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  height: 100%;
}

.map {
  height: 100%;
}

.change-style {
  position: absolute;
  z-index: 1;
  top: 0px;
  left: 0px;
}
</style>
