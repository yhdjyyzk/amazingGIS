<template>
  <div class="cesium-hello">
    <div class="el" ref="el"></div>
  </div>
</template>

<script>
import * as Cesium from "cesium";
import "cesium/Widgets/widgets.css";
import MVTImageryProvider from "../../thirds/MVTImageryProvider";

export default {
  async mounted() {
    const res = await fetch("/static/map/style/night-style.json");
    const styleJSON = await res.json();

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

      // 1.
      imageryProvider: new MVTImageryProvider({
        style: styleJSON, //"http://localhost:3000/static/map/style/night-style.json",
      }),
    });

    // 2.
    // const provider = new MVTImageryProvider({
    //   style: styleJSON,
    // });
    // provider.readyPromise.then(() => {
    //   this.$viewer.imageryLayers.addImageryProvider(provider);
    // });

    this.$viewer.camera.setView({
      destination: Cesium.Cartesian3.fromDegrees(116, 38, 20000000),
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
