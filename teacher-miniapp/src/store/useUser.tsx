import { createContext, useContext, useState, useCallback, ReactNode } from 'react'
import type { UserInfo } from '../services/auth'
import { getToken, getUser as storageGetUser, setUser as storageSetUser, clearAuth } from '../utils/storage'

interface UserState {
  token: string
  user: UserInfo | null
  login: (token: string, user: UserInfo) => void
  logout: () => void
}

const UserContext = createContext<UserState | null>(null)

export function UserProvider({ children }: { children: ReactNode }) {
  const [token, setToken] = useState<string>(() => getToken())
  const [user, setUser] = useState<UserInfo | null>(() => storageGetUser())

  const login = useCallback((t: string, u: UserInfo) => {
    setToken(t)
    setUser(u)
    storageSetUser(u)
  }, [])

  const logout = useCallback(() => {
    clearAuth()
    setToken('')
    setUser(null)
  }, [])

  return (
    <UserContext.Provider value={{ token, user, login, logout }}>
      {children}
    </UserContext.Provider>
  )
}

export function useUser(): UserState {
  const ctx = useContext(UserContext)
  if (!ctx) throw new Error('useUser must be used within UserProvider')
  return ctx
}
