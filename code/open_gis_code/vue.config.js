module.exports = {
  devServer: {
    port: 8081,
    proxy: {
      // '/geoserver': {
      //   target: 'http://localhost:8080'
      // },
      // '/tile': {
      //   target: 'http://localhost:3000'
      // },
      '/cdn': {
        target: 'http://192.168.192.128'
      }
    }
  },
  lintOnSave: false
}
