<template>
  <div class="map-container" ref="map"></div>
</template>

<script>
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";

export default {
  name: "App",
  components: {},
  mounted() {
    const map = new mapboxgl.Map({
      container: this.$refs.map,
      // style: '/static/map/style/style.json',
      style: "http://localhost:3000/static/map/style/night-style.json",
      center: [116.391229827904, 39.907092084593216], // starting position [lng, lat]
      zoom: 8, // starting zoom
      antialias: true,
    });

    map.on("load", () => {
      map.addSource("beijing", {
        type: "geojson",
        data: "http://localhost:3000/static/geojson/beijing.json",
      });

      map.addLayer({
        id: "polygon",
        source: "beijing",
        type: "line",
        paint: {
          "line-color": "red",
          "line-width": 2,
        },
      });

      map.addLayer({
        id: "point",
        source: "beijing",
        type: "circle",
        paint: {
          "circle-stroke-color": "orange",
          "circle-stroke-width": 2,
          "circle-color": "yellow",
          "circle-radius": 3
        },
      });
    });

    map.on('click', 'point' ,e => {
      console.log(e)
    })
  },
};
</script>

<style lang="less">
.map-container {
  width: 100%;
  height: 100%;
}
</style>