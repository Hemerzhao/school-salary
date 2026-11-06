import { useState } from 'react'
import { View, Text, Input, Textarea, Button } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { end as endAttendance } from '../../services/attendance'
import './end.scss'

export default function AttendanceEndPage() {
  const scheduleId = Taro.getCurrentInstance().router?.params?.scheduleId as string

  const [studentCount, setStudentCount] = useState('')
  const [leaveCount, setLeaveCount] = useState('')
  const [exceptionNote, setExceptionNote] = useState('')
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async () => {
    if (!studentCount) {
      Taro.showToast({ title: '请填写到课人数', icon: 'none' })
      return
    }

    setSubmitting(true)
    try {
      await endAttendance(scheduleId, {
        studentCount: Number(studentCount),
        leaveCount: Number(leaveCount || 0),
        exceptionNote: exceptionNote || undefined
      })
      Taro.showToast({ title: '提交成功', icon: 'success' })
      setTimeout(() => {
        Taro.navigateBack()
      }, 800)
    } catch {
      // request 层已 toast
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <View className='page end-page'>
      <View className='form-card'>
        <View className='form-item'>
          <Text className='label'>实际到课人数</Text>
          <Input
            className='input'
            type='number'
            value={studentCount}
            placeholder='请输入到课人数'
            onInput={(e: any) => setStudentCount(e.detail.value)}
          />
        </View>

        <View className='form-item'>
          <Text className='label'>请假人数</Text>
          <Input
            className='input'
            type='number'
            value={leaveCount}
            placeholder='默认为 0'
            onInput={(e: any) => setLeaveCount(e.detail.value)}
          />
        </View>

        <View className='form-item form-item-column'>
          <Text className='label'>异常说明（选填）</Text>
          <Textarea
            className='textarea'
            value={exceptionNote}
            placeholder='如：设备故障、临时停课等'
            maxlength={200}
            onInput={(e: any) => setExceptionNote(e.detail.value)}
          />
        </View>
      </View>

      <Button
        className='submit-btn'
        type='primary'
        loading={submitting}
        disabled={submitting}
        onClick={handleSubmit}
      >
        提交
      </Button>
    </View>
  )
}
