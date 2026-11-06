import { defineStore } from 'pinia'
import api from '@/utils/request'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    user: JSON.parse(localStorage.getItem('user') || 'null')
    // user: { id, username, name, role, campusId }
  }),
  getters: {
    isLoggedIn: (state) => !!state.token,
    role: (state) => state.user?.role || '',
    name: (state) => state.user?.name || state.user?.username || ''
  },
  actions: {
    async login(username, password) {
      const data = await api.post('/auth/login', { username, password })
      this.token = data.token
      this.user = data.user
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))
      return data
    },
    async fetchProfile() {
      const user = await api.get('/auth/profile')
      this.user = user
      localStorage.setItem('user', JSON.stringify(user))
      return user
    },
    logout() {
      this.token = ''
      this.user = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
})
