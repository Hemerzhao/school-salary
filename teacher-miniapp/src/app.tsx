import { PropsWithChildren } from 'react'
import { useDidShow } from '@tarojs/taro'
import { getUser } from './utils/storage'
import './app.scss'

function App({ children }: PropsWithChildren<any>) {
  useDidShow(() => {
    const user = getUser()
    if (!user) {
      // 未登录可跳转登录页，这里先留空
      console.log('未登录状态')
    }
  })

  return children
}

export default App
