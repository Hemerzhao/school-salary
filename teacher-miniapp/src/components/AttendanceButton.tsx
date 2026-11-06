import { Button } from '@tarojs/components'
import type { Schedule } from '../services/schedule'

interface Props {
  status: Schedule['status']
  loading?: boolean
  onClick?: () => void
}

const statusStyle: Record<Schedule['status'], { text: string; disabled: boolean; type: 'primary' | 'default' | 'warn' }> = {
  not_started: { text: '未开始', disabled: true, type: 'default' },
  can_start: { text: '点击开始打卡', disabled: false, type: 'primary' },
  in_progress: { text: '结束打卡', disabled: false, type: 'warn' },
  finished: { text: '已完成', disabled: true, type: 'default' }
}

export default function AttendanceButton({ status, loading, onClick }: Props) {
  const s = statusStyle[status]

  return (
    <Button
      className='attendance-btn'
      type={s.type}
      disabled={s.disabled || loading}
      loading={loading}
      onClick={onClick}
    >
      {s.text}
    </Button>
  )
}
