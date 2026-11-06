import { defineConfig } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'

// H5 模式下将 /api 代理到本地后端，避免开发期跨域
export default defineConfig({
  plugins: [uni()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  }
})
