import * as THREE from 'three'
import { GPS } from '../../../utils/geo'

const loader = new THREE.TextureLoader()
const texture = loader.load('http://localhost:9001/static/images/building.png')
const sideMaterial = new THREE.MeshLambertMaterial({
  transparent: true,
  map: texture
})

const topMaterial = new THREE.MeshBasicMaterial({
  color: 'skyblue',
  transparent: true
})

class GeoJSON2Building {
  constructor (geojson, options) {
    this.geojson = geojson
    this.tb = options.tb

    this.model = null
  }

  toModel () {
    const models = []

    const features = this.geojson.features

    for (let i = 0; i < features.length; i++) {
      const ft = features[i]

      if (ft.geometry.type === 'Polygon') {
        const model = this.polygonToModel(ft)
        models.push(model)
      }
    }

    this.model = models
  }

  getModel () {
    this.toModel()

    return this.model
  }

  polygonToModel (ft) {
    const vec2s = []

    for (let i = 0; i < ft.geometry.coordinates[0].length; i++) {
      const coord = this.tb.projectToWorld(GPS.gcj02_to_gps84(...ft.geometry.coordinates[0][i].reverse()))
      vec2s.push(new THREE.Vector2(coord.x, coord.y))
    }

    const shape = new THREE.Shape(vec2s)
    const uvGeometry = new THREE.ExtrudeBufferGeometry(shape, {
      depth: ft.properties.height * 0.01,
      bevelEnabled: false
    })

    const geometry = new THREE.ExtrudeBufferGeometry(shape, {
      depth: ft.properties.height * 0.01,
      bevelEnabled: false,
      UVGenerator: {
        generateTopUV: function (geometry, vertices, indexA, indexB, indexC) {
          const a_x = vertices[indexA * 3]
          const a_y = vertices[indexA * 3 + 1]
          const b_x = vertices[indexB * 3]
          const b_y = vertices[indexB * 3 + 1]
          const c_x = vertices[indexC * 3]
          const c_y = vertices[indexC * 3 + 1]

          return [
            new THREE.Vector2(a_x, a_y),
            new THREE.Vector2(b_x, b_y),
            new THREE.Vector2(c_x, c_y)
          ]
        },

        generateSideWallUV: (geometry, vertices, indexA, indexB, indexC, indexD) => {
          const base = uvGeometry.groups[1].start
          const count = uvGeometry.groups[1].count

          const uv = [
            new THREE.Vector2((indexA - base) / count, 1),
            new THREE.Vector2((indexB - base) / count, 1),
            new THREE.Vector2((indexB - base) / count, 0),
            new THREE.Vector2((indexA - base) / count, 0)
          ]

          return uv
        }
      }
    })

    const mesh = new THREE.Mesh(geometry, [topMaterial, sideMaterial])
    mesh.castShadow = true
    mesh.receiveShadow = true

    return mesh
  }
}

export default GeoJSON2Building
