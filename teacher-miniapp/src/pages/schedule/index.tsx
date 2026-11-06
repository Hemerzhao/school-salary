import { useEffect, useState, useCallback } from 'react'
import { View, Text } from '@tarojs/components'
import { useDidShow } from '@tarojs/taro'
import ScheduleCard from '../../components/ScheduleCard'
import { list as fetchList, Schedule } from '../../services/schedule'
import { start as startAttendance } from '../../services/attendance'
import { formatDate } from '../../utils/format'
import './index.scss'

type RangeKey = 'week' | 'month'

const RANGES: { key: RangeKey; label: string }[] = [
  { key: 'week', label: '本周' },
  { key: 'month', label: '本月' }
]

function getRange(key: RangeKey): { from: string; to: string } {
  const now = new Date()
  if (key === 'week') {
    const start = new Date(now)
    start.setDate(now.getDate() - now.getDay())
    const end = new Date(start)
    end.setDate(start.getDate() + 6)
    return { from: formatDate(start), to: formatDate(end) }
  }
  const start = new Date(now.getFullYear(), now.getMonth(), 1)
  const end = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  return { from: formatDate(start), to: formatDate(end) }
}

export default function SchedulePage() {
  const [range, setRange] = useState<RangeKey>('week')
  const [items, setItems] = useState<Schedule[]>([])
  const [loading, setLoading] = useState(false)

  const loadData = useCallback(async (key: RangeKey) => {
    setLoading(true)
    try {
      const r = getRange(key)
      const data = await fetchList(r)
      setItems(data || [])
    } catch {
      setItems([])
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    loadData(range)
  }, [range, loadData])

  useDidShow(() => loadData(range))

  const handleStart = async (id: string) => {
    try {
      await startAttendance(id)
      loadData(range)
    } catch {}
  }

  const handleEnd = (id: string) => {
    // 仅在首页跳转，课表页不处理结束
    console.log('end', id)
  }

  return (
    <View className='page schedule-page'>
      <View className='range-tabs'>
        {RANGES.map(r => (
          <View
            key={r.key}
            className={`range-tab ${range === r.key ? 'range-active' : ''}`}
            onClick={() => setRange(r.key)}
          >
            <Text>{r.label}</Text>
          </View>
        ))}
      </View>

      <View className='list'>
        {loading && <Text className='loading'>加载中...</Text>}
        {!loading && items.length === 0 && <Text className='empty'>暂未安排课程</Text>}
        {items.map(item => (
          <ScheduleCard key={item.id} item={item} onStart={handleStart} onEnd={handleEnd} />
        ))}
      </View>
    </View>
  )
}
