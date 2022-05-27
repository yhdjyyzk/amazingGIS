const CopyWebpackPlugin = require('copy-webpack-plugin')
const path = require('path')
const webpack = require('webpack')

// The path to the CesiumJS source code
const cesiumSource = 'node_modules/cesium/Source'
const cesiumWorkers = '../Build/Cesium/Workers'

module.exports = {
  // transpileDependencies: true,
  devServer: {
    port: 8080,
    proxy: {
      // '/geoserver': {
      //   target: 'http://localhost:8080'
      // },
      // '/tile': {
      //   target: 'http://localhost:3000'
      // },
      '/mapdata': {
        target: 'http://localhost:3000'
      },
      '/static': {
        target: 'http://localhost:3000'
      },
      '/cdn': {
        target: 'http://192.168.192.128'
      }
    }
  },
  lintOnSave: false,
  chainWebpack: config => {
    config.module
      .rule('glsl')
      .test(/\.(glsl|vs|fs)$/)
      .use('glsl')
      .loader('webpack-glsl-loader')
  },
  configureWebpack: {
    amd: {
      // Enable webpack-friendly use of require in Cesium
      toUrlUndefined: true
    },
    resolve: {
      alias: {
        cesium: path.resolve(cesiumSource)
      },
      mainFiles: ['module', 'main', 'index', 'Cesium']
    },
    plugins: [
      // Copy Cesium Assets, Widgets, and Workers to a static directory
      new CopyWebpackPlugin(
        [
          { from: path.join(cesiumSource, cesiumWorkers), to: 'Workers' },
          { from: path.join(cesiumSource, 'Assets'), to: 'Assets' },
          { from: path.join(cesiumSource, 'Widgets'), to: 'Widgets' },
          { from: path.join(cesiumSource, 'ThirdParty'), to: 'ThirdParty' }
        ]
      ),
      new webpack.DefinePlugin({
        // Define relative base path in cesium for loading assets
        CESIUM_BASE_URL: JSON.stringify('/')
      })
    ]
  }
}
