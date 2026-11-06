import { View, Text } from '@tarojs/components'
import type { Schedule } from '../services/schedule'
import './ScheduleCard.scss'

interface Props {
  item: Schedule
  onStart?: (id: string) => void
  onEnd?: (id: string) => void
}

const statusMap: Record<Schedule['status'], { label: string; className: string }> = {
  not_started: { label: '未开始', className: 'tag-gray' },
  can_start: { label: '点击开始打卡', className: 'tag-green' },
  in_progress: { label: '结束打卡', className: 'tag-red' },
  finished: { label: '已完成', className: 'tag-gray' }
}

export default function ScheduleCard({ item, onStart, onEnd }: Props) {
  const status = statusMap[item.status]

  return (
    <View className='schedule-card'>
      <View className='flex-between'>
        <Text className='schedule-title'>{item.courseName}</Text>
        <Text className={`tag ${status.className}`}>{status.label}</Text>
      </View>
      <View className='schedule-meta text-muted'>
        <Text>{item.className}</Text>
        <Text className='time'>{item.startTime} - {item.endTime}</Text>
      </View>
      {item.location && (
        <View className='schedule-loc text-muted'>
          <Text>📍 {item.location}</Text>
        </View>
      )}
      {item.status === 'can_start' && onStart && (
        <View className='action-btn action-start' onClick={() => onStart(item.id)}>
          <Text>开始打卡</Text>
        </View>
      )}
      {item.status === 'in_progress' && onEnd && (
        <View className='action-btn action-end' onClick={() => onEnd(item.id)}>
          <Text>结束打卡</Text>
        </View>
      )}
    </View>
  )
}
