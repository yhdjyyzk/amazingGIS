import * as THREE from 'three'
import hemisphereImg from './hemisphere.png'
import hemisphereVs from './hemisphere.vs'
import hemisphereFs from './hemisphere.fs'

const defaultOptions = {
  lnglat: [116.451229827904, 39.937092084593216],
  radius: 500 * 0.01,
  color: 'red'
}

const loader = new THREE.TextureLoader()
const texture = loader.load(hemisphereImg)

class Hemisphere {
  constructor (options = {}) {
    this.options = Object.assign({}, defaultOptions, options)
    this.coord = this.options.tb.projectToWorld(this.options.lnglat)

    this.material = new THREE.ShaderMaterial({
      transparent: true,
      vertexColors: true,
      vertexShader: hemisphereVs,
      fragmentShader: hemisphereFs,
      blending: THREE.AdditiveBlending,
      uniforms: {
        u_color: {
          value: new THREE.Color('#ffff00')
        },
        u_time: {
          value: 0
        },
        u_texture: {
          value: texture
        }
      }
    })

    this.model = null

    this.render()
  }

  render () {
    const geometry = new THREE.SphereBufferGeometry(this.options.radius, 30, 30, 0, Math.PI * 2, 0, Math.PI / 2)
    geometry.rotateX(Math.PI / 2)
    const mesh = new THREE.Mesh(geometry, this.material)
    mesh.position.set(this.coord.x, this.coord.y, 0)
    this.model = mesh
  }

  getModel () {
    return this.model
  }

  update ({ time }) {
    this.material.uniforms.u_time.value = time
  }
}

export default Hemisphere
