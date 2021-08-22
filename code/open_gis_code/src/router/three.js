export default [
  {
    path: '/three/box',
    component: () => import('@/views/three/Box.vue')
  },
  {
    path: '/three/building',
    component: () => import('@/views/three/building/Building.vue')
  }
]
