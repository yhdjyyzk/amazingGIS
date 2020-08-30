module.exports = {
    devServer: {
        port: 8081,
        proxy: {
            '/geoserver': {
                target: 'http://localhost:8080'
            },
            '/cdn': {
                target: 'http://localhost'
            }
        }
    },
    lintOnSave: false
}