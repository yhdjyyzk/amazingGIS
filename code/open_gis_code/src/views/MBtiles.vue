<template>
  <div id="app">
    <div ref="map" class="map"></div>
  </div>
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
      style: '/static/map/style/style.json',
      center: [116.391229827904, 39.907092084593216], // starting position [lng, lat]
      zoom: 16, // starting zoom
    });
  }
};
</script>

<style>
.map {
  height: 100%;
}
</style>
