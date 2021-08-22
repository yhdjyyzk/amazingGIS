var GPS = {
  PI: 3.14159265358979324,
  x_pi: 3.14159265358979324 * 3000.0 / 180.0,
  a: 6378245.0, //  a: 卫星椭球坐标投影到平面地图坐标系的投影因子。
  ee: 0.00669342162296594323, //  ee: 椭球的偏心率。
  delta: function (lat, lon) {
    var a = 6378245.0 //  a: 卫星椭球坐标投影到平面地图坐标系的投影因子。
    var ee = 0.00669342162296594323 //  ee: 椭球的偏心率。
    var dLat = this.transformLat(lon - 105.0, lat - 35.0)
    var dLon = this.transformLon(lon - 105.0, lat - 35.0)
    var radLat = lat / 180.0 * this.PI
    var magic = Math.sin(radLat)
    magic = 1 - ee * magic * magic
    var sqrtMagic = Math.sqrt(magic)
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * this.PI)
    dLon = (dLon * 180.0) / (a / sqrtMagic * Math.cos(radLat) * this.PI)
    return { lat: dLat, lon: dLon }
  },

  // 84 to 火星坐标系 (GCJ-02)
  gps84_To_Gcj02: function (wgsLat, wgsLon) {
    if (this.outOfChina(wgsLat, wgsLon)) { return { lat: wgsLat, lon: wgsLon } }

    var d = this.delta(wgsLat, wgsLon)
    return { lat: wgsLat + d.lat, lon: wgsLon + d.lon }
  },

  // 火星坐标系 (GCJ-02) to 百度坐标系 (BD-09)
  gcj02_To_Bd09: function (lat, lng) {
    const x_pi = 3.14159265358979324 * 3000.0 / 180.0
    const x = lng
    const y = lat
    const z = Math.sqrt(x * x + y * y) + 0.00002 * Math.sin(y * x_pi)
    const theta = Math.atan2(y, x) + 0.000003 * Math.cos(x * x_pi)
    const lngs = z * Math.cos(theta) + 0.0065
    const lats = z * Math.sin(theta) + 0.006
    return { lat: lats, lon: lngs }
  },
  // 百度坐标系 (BD-09) to 火星坐标系 (GCJ-02)
  bd09_To_Gcj02: function (lat, lng) {
    const x_pi = 3.14159265358979324 * 3000.0 / 180.0
    const x = lng - 0.0065
    const y = lat - 0.006
    const z = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * x_pi)
    const theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * x_pi)
    const lngs = z * Math.cos(theta)
    const lats = z * Math.sin(theta)

    return { lat: lats, lon: lngs }
  },
  gcj02_to_gps84: function (lat, lng) {
    var lat = +lat
    var lng = +lng
    if (this.outOfChina(lat, lng)) {
      return [lng, lat]
    } else {
      var dlat = this.transformLat(lng - 105.0, lat - 35.0)
      var dlng = this.transformLon(lng - 105.0, lat - 35.0)
      var radlat = lat / 180.0 * this.PI
      var magic = Math.sin(radlat)
      magic = 1 - this.ee * magic * magic
      var sqrtmagic = Math.sqrt(magic)
      dlat = (dlat * 180.0) / ((this.a * (1 - this.ee)) / (magic * sqrtmagic) * this.PI)
      dlng = (dlng * 180.0) / (this.a / sqrtmagic * Math.cos(radlat) * this.PI)
      var mglat = lat + dlat
      var mglng = lng + dlng
      return [lng * 2 - mglng, lat * 2 - mglat]
    }
  },
  gps84_To_Bd09: function (wgsLat, wgsLon) {
    const point = this.gps84_To_Gcj02(wgsLat, wgsLon)
    return this.gcj02_To_Bd09(point.lat, point.lon)
  },

  bd09_To_Gps84: function (wgsLat, wgsLon) {
    const point = this.bd09_To_Gcj02(wgsLat, wgsLon)
    return this.gcj02_to_gps84(point.lat, point.lon)
  },

  outOfChina: function (lat, lon) {
    if (lon < 72.004 || lon > 137.8347) { return true }
    if (lat < 0.8293 || lat > 55.8271) { return true }
    return false
  },
  transformLat: function (x, y) {
    var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.sqrt(Math.abs(x))
    ret += (20.0 * Math.sin(6.0 * x * this.PI) + 20.0 * Math.sin(2.0 * x * this.PI)) * 2.0 / 3.0
    ret += (20.0 * Math.sin(y * this.PI) + 40.0 * Math.sin(y / 3.0 * this.PI)) * 2.0 / 3.0
    ret += (160.0 * Math.sin(y / 12.0 * this.PI) + 320 * Math.sin(y * this.PI / 30.0)) * 2.0 / 3.0
    return ret
  },
  transformLon: function (x, y) {
    var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.sqrt(Math.abs(x))
    ret += (20.0 * Math.sin(6.0 * x * this.PI) + 20.0 * Math.sin(2.0 * x * this.PI)) * 2.0 / 3.0
    ret += (20.0 * Math.sin(x * this.PI) + 40.0 * Math.sin(x / 3.0 * this.PI)) * 2.0 / 3.0
    ret += (150.0 * Math.sin(x / 12.0 * this.PI) + 300.0 * Math.sin(x / 30.0 * this.PI)) * 2.0 / 3.0
    return ret
  }
}

export {
  GPS
}
