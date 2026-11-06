<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-button :icon="ArrowLeft" @click="$router.push('/admin/salary/statement')">返回工资单</el-button>
          <span class="statement-info" v-if="statement">
            工资单: #{{ statement.id }} · {{ statement.teacherName }} · {{ statement.month }} ·
            <strong>实发 ¥{{ statement.net?.toFixed(2) || '0.00' }}</strong>
          </span>
        </div>
      </div>

      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="type" label="明细类型" width="120">
          <template #default="{ row }">
            <el-tag size="small" :type="detailTypeTag(row.type)">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="attendanceDate" label="日期" width="120" />
        <el-table-column prop="scheduleInfo" label="课程/班级">
          <template #default="{ row }">{{ row.courseName }} / {{ row.className }}</template>
        </el-table-column>
        <el-table-column prop="duration" label="时长(分钟)" width="100" />
        <el-table-column prop="studentCount" label="出勤人数" width="90" />
        <el-table-column prop="amount" label="金额" width="120">
          <template #default="{ row }">¥{{ row.amount?.toFixed(2) || '0.00' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openSnapshot(row)">计算快照</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && list.length === 0" description="没有明细" />
    </div>

    <SnapshotDrawer v-model="drawerVisible" :snapshot="currentSnapshot" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import { detailList, snapshot as fetchSnapshot, statementDetail } from '@/api/salary'
import SnapshotDrawer from '@/views/components/SnapshotDrawer.vue'

const route = useRoute()
const statementId = Number(route.query.statementId)
const loading = ref(false)
const list = ref([])
const statement = ref(null)

const drawerVisible = ref(false)
const currentSnapshot = ref(null)

const detailTypeTag = (t) => ({ '课时': '', '人头': 'success', '加班': 'warning', '调整': 'danger' }[t] || 'info')

const load = async () => {
  if (!statementId) return
  loading.value = true
  try {
    list.value = await detailList(statementId)
    try { statement.value = await statementDetail(statementId) } catch (_) {}
  } catch (_) {} finally { loading.value = false }
}

const openSnapshot = async (row) => {
  currentSnapshot.value = null
  drawerVisible.value = true
  try { currentSnapshot.value = await fetchSnapshot(row.id) } catch (_) {}
}

onMounted(load)
</script>

<style scoped>
.statement-info { margin-left: 12px; color: #606266; }
</style>
