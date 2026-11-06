import { useEffect, useState, useCallback } from 'react'
import { View, Text } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { myStatements, SalaryStatement } from '../../services/salary'
import { formatMoney } from '../../utils/format'
import './index.scss'

const statusLabel: Record<number, string> = {
  1: '预计中',
  2: '已核算',
  3: '已发放'
}

const statusClass: Record<number, string> = {
  1: 'status-pending',
  2: 'status-done',
  3: 'status-paid'
}

export default function SalaryPage() {
  const [list, setList] = useState<SalaryStatement[]>([])
  const [loading, setLoading] = useState(false)

  const loadData = useCallback(async () => {
    setLoading(true)
    try {
      const data = await myStatements()
      setList(data || [])
    } catch {
      setList([])
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    loadData()
  }, [])

  useDidShow(() => loadData())

  const estimated = list.find(s => s.status !== 3)
  const history = list.filter(s => s.status === 3 || s.status === 2)

  const goDetail = (id: string) => {
    Taro.navigateTo({ url: `/pages/salary/detail?id=${id}` })
  }

  return (
    <View className='page salary-page'>
      {/* 顶部预计工资卡片 */}
      {estimated && (
        <View className='estimated-card' onClick={() => goDetail(estimated.id)}>
          <View className='label'>本月预计工资</View>
          <View className='amount'>{formatMoney(estimated.total)}</View>
          <View className='sub'>
            <Text>课时费 {formatMoney(estimated.classFee)}</Text>
            <Text className='divider'>|</Text>
            <Text>基础 {formatMoney(estimated.baseSalary)}</Text>
          </View>
        </View>
      )}

      {/* 历史列表 */}
      <View className='section-title'>
        <Text>历史工资</Text>
      </View>

      {loading && <Text className='loading'>加载中...</Text>}
      {!loading && history.length === 0 && <Text className='empty'>暂无历史工资</Text>}

      <View className='history-list'>
        {history.map(item => (
          <View
            key={item.id}
            className='history-item flex-between'
            onClick={() => goDetail(item.id)}
          >
            <View>
              <Text className='month'>{item.month}</Text>
              <Text className={`status ${statusClass[item.status]}`}>{statusLabel[item.status]}</Text>
            </View>
            <Text className='total'>{formatMoney(item.total)}</Text>
          </View>
        ))}
      </View>
    </View>
  )
}
