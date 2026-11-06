import { View, Text, Button } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { useState } from 'react'
import { useUser } from '../../store/useUser'
import { login as doLogin } from '../../services/auth'
import './index.scss'

export default function MePage() {
  const { user, token, login, logout } = useUser()

  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  useDidShow(() => {
    // 每次进来刷新
  })

  const handleLogin = async () => {
    if (!username || !password) {
      Taro.showToast({ title: '请输入账号密码', icon: 'none' })
      return
    }
    setLoading(true)
    try {
      const res = await doLogin(username, password)
      login(res.token, res.user)
      Taro.showToast({ title: '登录成功', icon: 'success' })
      Taro.switchTab({ url: '/pages/index/index' })
    } catch {
      // request 层已 toast
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = () => {
    Taro.showModal({
      title: '提示',
      content: '确定退出登录？',
      success: (res) => {
        if (res.confirm) {
          logout()
          Taro.showToast({ title: '已退出登录', icon: 'none' })
        }
      }
    })
  }

  if (!token || !user) {
    return (
      <View className='page me-page'>
        <View className='login-card'>
          <View className='login-title'>教师端登录</View>
          <View className='form-item'>
            <Text className='label'>账号</Text>
            <input
              className='input'
              placeholder='请输入账号'
              value={username}
              onChange={(e: any) => setUsername(e.target.value)}
            />
          </View>
          <View className='form-item'>
            <Text className='label'>密码</Text>
            <input
              className='input'
              placeholder='请输入密码'
              password
              value={password}
              onChange={(e: any) => setPassword(e.target.value)}
            />
          </View>
          <Button
            className='login-btn'
            type='primary'
            loading={loading}
            disabled={loading}
            onClick={handleLogin}
          >
            登录
          </Button>
        </View>
      </View>
    )
  }

  return (
    <View className='page me-page'>
      {/* 用户信息卡 */}
      <View className='profile-card'>
        <View className='avatar'>{user.name?.[0] || 'T'}</View>
        <View className='profile-info'>
          <Text className='name'>{user.name}</Text>
          <Text className='role-tag'>{user.role}</Text>
        </View>
      </View>

      {/* 详情列表 */}
      <View className='info-list'>
        <View className='info-item'>
          <Text className='label'>工号</Text>
          <Text className='value'>{user.employeeNo || '-'}</Text>
        </View>
        <View className='info-item'>
          <Text className='label'>校区</Text>
          <Text className='value'>{user.campus || '-'}</Text>
        </View>
        <View className='info-item'>
          <Text className='label'>职级</Text>
          <Text className='value'>{user.level || '-'}</Text>
        </View>
        <View className='info-item'>
          <Text className='label'>账号</Text>
          <Text className='value'>{user.username}</Text>
        </View>
      </View>

      {/* 退出登录 */}
      <Button className='logout-btn' onClick={handleLogout}>
        退出登录
      </Button>
    </View>
  )
}
