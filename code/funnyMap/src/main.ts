// import './assets/main.css'
import 'element-plus/theme-chalk/dark/css-vars.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import { usePlugins } from './plugins'

const app = createApp(App)

app.use(createPinia())
app.use(router)

usePlugins(app)

app.mount('#app')
