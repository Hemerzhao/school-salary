import { useEffect, useState, useCallback } from 'react'
import { View, Text, Button } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import ScheduleCard from '../../components/ScheduleCard'
import { today as fetchToday, list as fetchList, Schedule } from '../../services/schedule'
import { start as startAttendance } from '../../services/attendance'
import { formatDate } from '../../utils/format'
import './index.scss'

type TabKey = 'today' | 'week' | 'month'

const TABS: { key: TabKey; label: string }[] = [
  { key: 'today', label: '今日' },
  { key: 'week', label: '本周' },
  { key: 'month', label: '本月' }
]

function getRange(key: TabKey): { from: string; to: string } {
  const now = new Date()
  if (key === 'today') {
    const d = formatDate(now)
    return { from: d, to: d }
  }
  if (key === 'week') {
    const start = new Date(now)
    start.setDate(now.getDate() - now.getDay())
    const end = new Date(start)
    end.setDate(start.getDate() + 6)
    return { from: formatDate(start), to: formatDate(end) }
  }
  // month
  const start = new Date(now.getFullYear(), now.getMonth(), 1)
  const end = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  return { from: formatDate(start), to: formatDate(end) }
}

export default function Home() {
  const [tab, setTab] = useState<TabKey>('today')
  const [items, setItems] = useState<Schedule[]>([])
  const [loading, setLoading] = useState(false)

  const loadData = useCallback(async (key: TabKey) => {
    setLoading(true)
    try {
      let data: Schedule[]
      if (key === 'today') {
        data = await fetchToday()
      } else {
        const range = getRange(key)
        data = await fetchList(range)
      }
      setItems(data || [])
    } catch {
      setItems([])
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    loadData(tab)
  }, [tab, loadData])

  useDidShow(() => {
    loadData(tab)
  })

  const handleStart = async (id: string) => {
    try {
      await startAttendance(id)
      Taro.showToast({ title: '打卡成功', icon: 'success' })
      loadData(tab)
    } catch {}
  }

  const handleEnd = (id: string) => {
    Taro.navigateTo({ url: `/pages/attendance/end?scheduleId=${id}` })
  }

  return (
    <View className='page home-page'>
      <View className='tabs'>
        {TABS.map(t => (
          <View
            key={t.key}
            className={`tab ${tab === t.key ? 'tab-active' : ''}`}
            onClick={() => setTab(t.key)}
          >
            <Text>{t.label}</Text>
          </View>
        ))}
      </View>

      <View className='list'>
        {loading && <Text className='loading'>加载中...</Text>}
        {!loading && items.length === 0 && <Text className='empty'>暂无排课</Text>}
        {items.map(item => (
          <ScheduleCard key={item.id} item={item} onStart={handleStart} onEnd={handleEnd} />
        ))}
      </View>

      <View className='bottom-actions'>
        <Button className='btn-makeup' onClick={() => Taro.showToast({ title: '补卡申请开发中', icon: 'none' })}>
          补卡申请
        </Button>
      </View>
    </View>
  )
}
