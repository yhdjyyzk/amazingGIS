import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'
import threeRouter from './three'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/about',
    name: 'About',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/About.vue')
  },
  {
    path: '/china',
    name: 'ChinaMap',
    component: () => import('../views/ChinaMap.vue')
  },
  {
    path: '/beijing',
    component: () => import('../views/BeijingMap.vue')
  },
  {
    path: '/mbview',
    component: () => import('../views/MBtiles.vue')
  },
  {
    path: '/building',
    component: () => import('../views/MBtilesBuilding.vue')
  },
  {
    path: '/world',
    component: () => import('../views/MBtilesWorld.vue')
  },
  {
    path:'/cesium',
    component:() => import('../views/cesium/CesiumHello.vue')
  },
  {
    path:'/cesiumvt',
    component:() => import('../views/cesium/CesiumPBFView.vue')
  },
  ...threeRouter
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
