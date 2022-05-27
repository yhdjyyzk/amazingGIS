<template>
  <div class="cesium-hello">
    <div class="el" ref="el"></div>
    <div class="panel">
      <el-row type="flex" align="middle">
        <el-col :span="8">heading</el-col>
        <el-col :span="16">
          <el-slider
            v-model="heading"
            :min="0"
            :max="6.283"
            :step="0.001"
          ></el-slider>
        </el-col>
      </el-row>

      <el-row type="flex" align="middle">
        <el-col :span="8">pitch</el-col>
        <el-col :span="16">
          <el-slider
            v-model="pitch"
            :min="-3.1415"
            :max="0"
            :step="0.001"
          ></el-slider>
        </el-col>
      </el-row>

      <el-row type="flex" align="middle">
        <el-col :span="8">roll</el-col>
        <el-col :span="16">
          <el-slider
            v-model="roll"
            :min="0"
            :max="6.283"
            :step="0.001"
          ></el-slider>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script>
import * as Cesium from "cesium";
import "cesium/Widgets/widgets.css";

export default {
  data() {
    return {
      heading: 0,
      pitch: -3.1415 / 2,
      roll: 0,
    };
  },
  watch: {
    heading() {
      this.$viewer.camera.setView({
        orientation: {
          heading: this.heading,
        },
      });
    },
    pitch() {
      this.$viewer.camera.setView({
        orientation: {
          pitch: this.pitch,
        },
      });
    },
    roll() {
      this.$viewer.camera.setView({
        orientation: {
          roll: this.roll,
        },
      });
    },
  },
  mounted() {
    /**
     * @type {Cesium.Viewer}
     */
    this.$viewer = new Cesium.Viewer(this.$refs.el, {
      homeButton: false,
      fullscreenButton: false,
      navigationHelpButton: false,
      infoBox: false,
      timeline: false,
      vrButton: false,
      geocoder: false,
      sceneModePicker: false,
      baseLayerPicker: false,
      animation: false,

      // mapbox satellite map
      imageryProvider: new Cesium.UrlTemplateImageryProvider({
        // url: "https://mt2.google.cn/vt/lyrs=y&hl=zh-CN&gl=cn&x={x}&y={y}&z={z}",
        url: 'https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1Ijoid2luZHloIiwiYSI6ImNrdG1kdTM3czBsbXoydW4yOXd0ZDd3MWwifQ.8iOu2RxzT-lgPkQqz7UYWQ'
      }),

      // mapbox style map
      // imageryProvider: new Cesium.MapboxStyleImageryProvider({
      //   username: 'windyh',
      //   accessToken:
      //     'pk.eyJ1Ijoid2luZHloIiwiYSI6ImNrdG1kdTM3czBsbXoydW4yOXd0ZDd3MWwifQ.8iOu2RxzT-lgPkQqz7UYWQ',
      //   styleId: 'cl35qb5of000e14qne8onjys1',
      //   tilesize: 256
      // }),

      // local terrain map
      terrainProvider: new Cesium.CesiumTerrainProvider({
        url: "/mapdata/china_terrain_30m_11level/",
      }),
    });

    this.$viewer.camera.setView({
      destination: Cesium.Cartesian3.fromDegrees(0, 0, 20000000),
      orientation: {
        pitch: -3.1415 / 2,
        roll: 0,
      },
    });
  },
};
</script>

<style lang="less" scoped>
.cesium-hello {
  height: 100%;

  .el {
    width: 100%;
    height: 100%;
  }

  .panel {
    width: 300px;
    padding: 16px;
    position: absolute;
    z-index: 1;
    top: 0px;
    right: 0px;
    background-color: #2b2b2b;
    color: #fff;
  }
}
</style>
