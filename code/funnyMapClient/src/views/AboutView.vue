<template>
  <div class="about">
    <el-button @click="changeTheme()">{{ isDark ? 'Dark' : 'Light' }}</el-button>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { useDark, useToggle } from '@vueuse/core'

export default defineComponent({
  setup() {
    const isDark = useDark()
    const changeTheme = useToggle(isDark)

    return {
      changeTheme,
      isDark
    }
  }
})
</script>


<style>
@media (min-width: 1024px) {
  .about {
  }
}
</style>
