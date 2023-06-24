<template>
  <div class="map-container">
    <div class="panel">
      <el-row>
        <el-col :span="8">当前层级</el-col>
        <el-col :span="16">{{ zoom }}</el-col>
      </el-row>

      <el-row>
        <el-col :span="8">地图样式</el-col>
        <el-col :span="16">
          <el-select v-model="style" size="mini">
            <el-option
              v-for="item in themes"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            >
            </el-option>
          </el-select>
        </el-col>
      </el-row>
    </div>
    <div ref="map" class="map"></div>
  </div>
</template>

<script>
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";

export default {
  name: "App",
  components: {},
  data() {
    return {
      zoom: 3,
      themes: [
        {
          label: "street-style",
          value: "/static/map/style/street-style.json",
        },
        {
          label: "basic-style",
          value: "/static/map/style/basic-style.json",
        },
        {
          label: "mapbox-street-style",
          value: "/static/map/style/mapbox-street-style.json",
        },
        {
          label: "fiord-color-gl-style",
          value:
            "/static/map/style/fiord-color-gl-style/fiord-color-gl-style.json",
        },
        {
          label: "night-style",
          value: "/static/map/style/night-style.json",
        }
      ],
      style: "/static/map/style/fiord-color-gl-style/fiord-color-gl-style.json",
    };
  },
  watch: {
    style() {
      this.$map.setStyle(`http://localhost:9001${this.style}`);
    },
  },
  mounted() {
    this.$map = new mapboxgl.Map({
      container: this.$refs.map,
      // style: '/static/map/style/style.json',
      style:
        "http://localhost:9001/static/map/style/fiord-color-gl-style/fiord-color-gl-style.json",
      center: [116.391229827904, 39.907092084593216], // starting position [lng, lat]
      zoom: this.zoom, // starting zoom
      antialias: true,
    });

    this.$map.on("zoomend", (e) => {
      this.zoom = this.$map.getZoom().toFixed(1);
    });

    this.$map.on("click", (e) => {
      const feature = this.$map.queryRenderedFeatures(e.point);

      if (feature.length) {
        console.log(feature[0].layer);
      }
    });
  },
};
</script>

<style lang="less">
.map-container {
  height: 100%;

  .map {
    height: 100%;
  }

  .panel {
    color: white;
    width: 300px;
    position: absolute;
    z-index: 100000;
    top: 0px;
    right: 0px;
    padding: 8px;
    background-color: rgb(58, 67, 91);
  }
}
</style>
