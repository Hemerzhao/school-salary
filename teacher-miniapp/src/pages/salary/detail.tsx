import { useEffect, useState } from 'react'
import { View, Text } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { detail as fetchDetail, SalaryDetail, SalaryDetailItem } from '../../services/salary'
import { formatMoney } from '../../utils/format'
import './detail.scss'

export default function SalaryDetailPage() {
  const id = Taro.getCurrentInstance().router?.params?.id as string
  const [detail, setDetail] = useState<SalaryDetail | null>(null)
  const [expandedId, setExpandedId] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (!id) return
    setLoading(true)
    fetchDetail(id)
      .then(setDetail)
      .catch(() => setDetail(null))
      .finally(() => setLoading(false))
  }, [id])

  const toggle = (attendanceId: string) => {
    setExpandedId(prev => (prev === attendanceId ? null : attendanceId))
  }

  if (loading) return <View className='page'><Text>加载中...</Text></View>
  if (!detail) return <View className='page'><Text>未找到详情</Text></View>

  return (
    <View className='page detail-page'>
      {/* 概览卡片 */}
      <View className='summary-card'>
        <View className='month'>{detail.month} 工资明细</View>
        <View className='total'>{formatMoney(detail.total)}</View>

        <View className='breakdown'>
          <View className='breakdown-item flex-between'>
            <Text className='label'>基础工资</Text>
            <Text className='value'>{formatMoney(detail.baseSalary)}</Text>
          </View>
          <View className='breakdown-item flex-between'>
            <Text className='label'>课时费</Text>
            <Text className='value'>{formatMoney(detail.classFee)}</Text>
          </View>
          <View className='breakdown-item flex-between'>
            <Text className='label'>奖金</Text>
            <Text className='value'>{formatMoney(detail.bonus)}</Text>
          </View>
          <View className='breakdown-item flex-between'>
            <Text className='label'>调整项</Text>
            <Text className={`value ${detail.adjustment < 0 ? 'neg' : ''}`}>
              {detail.adjustment >= 0 ? '+' : ''}{formatMoney(detail.adjustment)}
            </Text>
          </View>
          <View className='breakdown-item flex-between subtotal'>
            <Text className='label'>实发合计</Text>
            <Text className='value'>{formatMoney(detail.total)}</Text>
          </View>
        </View>
      </View>

      {/* 打卡明细 */}
      <View className='section-title'>
        <Text>打卡明细（{detail.items?.length || 0} 条）</Text>
      </View>

      <View className='items'>
        {(detail.items || []).map((item: SalaryDetailItem) => (
          <View key={item.attendanceId} className='item-card'>
            <View className='item-main flex-between' onClick={() => toggle(item.attendanceId)}>
              <View>
                <Text className='item-title'>{item.courseName}</Text>
                <Text className='item-sub text-muted'>
                  {item.date} · {item.classHours}课时 · {item.studentCount}人
                </Text>
              </View>
              <View className='item-right flex-between'>
                <Text className='item-amount'>{formatMoney(item.amount)}</Text>
                <Text className='expand-arrow'>{expandedId === item.attendanceId ? '▲' : '▼'}</Text>
              </View>
            </View>

            {expandedId === item.attendanceId && (
              <View className='trace'>
                <View className='trace-title'>计算轨迹</View>
                {item.formula && <View className='trace-row'><Text className='trace-label'>公式:</Text><Text className='trace-val'>{item.formula}</Text></View>}
                {item.params && (
                  <View className='trace-row'>
                    <Text className='trace-label'>参数:</Text>
                    <Text className='trace-val'>{Object.entries(item.params).map(([k, v]) => `${k}=${v}`).join(', ')}</Text>
                  </View>
                )}
                {item.trace && <View className='trace-row'><Text className='trace-label'>过程:</Text><Text className='trace-val'>{item.trace}</Text></View>}
              </View>
            )}
          </View>
        ))}
      </View>
    </View>
  )
}
