<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-date-picker v-model="filter.month" type="month" value-format="YYYY-MM" placeholder="月份" style="width: 150px" />
          <el-select v-model="filter.status" placeholder="状态" clearable style="width: 130px">
            <el-option label="待确认" :value="0" />
            <el-option label="已确认" :value="1" />
            <el-option label="已锁定" :value="2" />
            <el-option label="已发放" :value="3" />
          </el-select>
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        </div>
      </div>

      <el-table :data="page.list" border stripe v-loading="loading">
        <el-table-column prop="id" label="工资单号" width="120" />
        <el-table-column prop="month" label="月份" width="110" />
        <el-table-column prop="teacherName" label="教师" width="120" />
        <el-table-column label="应发" width="110">
          <template #default="{ row }">¥{{ row.gross?.toFixed(2) || '0.00' }}</template>
        </el-table-column>
        <el-table-column label="调整" width="110">
          <template #default="{ row }">
            <span :style="{ color: (row.adjustment || 0) < 0 ? '#f56c6c' : '#67c23a' }">
              {{ row.adjustment < 0 ? '' : '+' }}¥{{ row.adjustment?.toFixed(2) || '0.00' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="实发" width="120">
          <template #default="{ row }"><strong>¥{{ row.net?.toFixed(2) || '0.00' }}</strong></template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="confirmedAt" label="确认时间" width="160" />
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDetail(row)">查看明细</el-button>
            <el-button link type="info" @click="showDetailDialog(row)">详情</el-button>
            <el-button v-if="row.status === 0" link type="success" @click="confirmRow(row)">确认</el-button>
            <el-button v-if="row.status === 1" link type="warning" @click="lockRow(row)">锁定</el-button>
            <el-button v-if="row.status === 2" link type="primary" @click="markPaidRow(row)">已发放</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="page.current" v-model:page-size="page.size"
        :total="page.total" :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 12px; justify-content: flex-end"
        @current-change="load" @size-change="load"
      />
    </div>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="工资单详情" width="640px">
      <el-descriptions :column="2" border v-if="current">
        <el-descriptions-item label="工资单号">{{ current.id }}</el-descriptions-item>
        <el-descriptions-item label="月份">{{ current.month }}</el-descriptions-item>
        <el-descriptions-item label="教师">{{ current.teacherName }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ statusText(current.status) }}</el-descriptions-item>
        <el-descriptions-item label="应发金额">¥{{ current.gross?.toFixed(2) || '0.00' }}</el-descriptions-item>
        <el-descriptions-item label="调整项">¥{{ current.adjustment?.toFixed(2) || '0.00' }}</el-descriptions-item>
        <el-descriptions-item label="实发金额" :span="2">
          <strong>¥{{ current.net?.toFixed(2) || '0.00' }}</strong>
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button type="primary" @click="openDetail(current)">查看明细与快照</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import {
  statementList, statementDetail,
  statementConfirm, statementLock, statementMarkPaid
} from '@/api/salary'

const router = useRouter()
const loading = ref(false)
const filter = reactive({ month: '', status: null })
const page = reactive({ list: [], total: 0, current: 1, size: 20 })

const detailVisible = ref(false)
const current = ref(null)

const statusTag = (s) => ({ 0: 'info', 1: 'primary', 2: 'warning', 3: 'success' }[s] || 'info')
const statusText = (s) => ({ 0: '待确认', 1: '已确认', 2: '已锁定', 3: '已发放' }[s] || '-')

const load = async () => {
  loading.value = true
  try {
    const res = await statementList({ ...filter, page: page.current, size: page.size })
    if (Array.isArray(res)) { page.list = res; page.total = res.length }
    else { page.list = res.list || res.records || []; page.total = res.total || 0 }
  } catch (_) {} finally { loading.value = false }
}

const openDetail = (row) => {
  detailVisible.value = false
  router.push({ path: '/admin/salary/detail', query: { statementId: row.id } })
}

const showDetailDialog = async (row) => {
  detailVisible.value = true
  try { current.value = await statementDetail(row.id) } catch (_) { current.value = row }
}

const confirmRow = async (row) => {
  await ElMessageBox.confirm(`确认工资单 ${row.id}？确认后将无法修改明细。`, '操作确认', { type: 'warning' })
  try { await statementConfirm(row.id); ElMessage.success('已确认'); load() } catch (_) {}
}
const lockRow = async (row) => {
  await ElMessageBox.confirm(`锁定工资单 ${row.id}？锁定后不能再修改。`, '操作确认', { type: 'warning' })
  try { await statementLock(row.id); ElMessage.success('已锁定'); load() } catch (_) {}
}
const markPaidRow = async (row) => {
  await ElMessageBox.confirm(`标记工资单 ${row.id} 为已发放？`, '操作确认', { type: 'warning' })
  try { await statementMarkPaid(row.id); ElMessage.success('已标记发放'); load() } catch (_) {}
}

onMounted(load)
</script>
