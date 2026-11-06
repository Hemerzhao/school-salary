<template>
  <div class="page-container">
    <!-- 顶部操作区 -->
    <div class="page-card top-bar">
      <div class="top-row">
        <div class="title">工资计算与预览</div>
        <div class="actions">
          <el-date-picker
            v-model="month"
            type="month"
            value-format="YYYY-MM"
            placeholder="选择月份"
            style="width: 180px"
          />
          <el-button type="warning" :icon="DocumentChecked" :loading="validating" @click="doValidate">
            校验配置
          </el-button>
          <el-button type="primary" :icon="Calculator" :loading="calculating" @click="doCalc">
            触发计算
          </el-button>
        </div>
      </div>
      <div class="sub">选择月份后，点击"校验配置"可预先检查规则绑定/打卡数据完整性；"触发计算"将生成该月全部教师的工资明细。</div>
    </div>

    <!-- 汇总卡片 -->
    <div v-if="summary" class="summary-row">
      <el-card class="stat-card" shadow="hover">
        <div class="label">总明细数</div>
        <div class="value">{{ summary.detailCount }}</div>
        <el-icon class="stat-icon" color="#409eff" :size="40"><Tickets /></el-icon>
      </el-card>
      <el-card class="stat-card" shadow="hover">
        <div class="label">教师数</div>
        <div class="value">{{ summary.teacherCount }}</div>
        <el-icon class="stat-icon" color="#67c23a" :size="40"><User /></el-icon>
      </el-card>
      <el-card class="stat-card" shadow="hover">
        <div class="label">待审核打卡</div>
        <div class="value" style="color:#e6a23c">{{ summary.pendingAttendance }}</div>
        <el-icon class="stat-icon" color="#e6a23c" :size="40"><Stamp /></el-icon>
      </el-card>
      <el-card class="stat-card" shadow="hover">
        <div class="label">总应发工资</div>
        <div class="value" style="color:#f56c6c">¥{{ summary.totalGross?.toFixed(2) || '0.00' }}</div>
        <el-icon class="stat-icon" color="#f56c6c" :size="40"><Money /></el-icon>
      </el-card>
    </div>

    <!-- 错误/警告列表 -->
    <div v-if="errors.length" style="margin-top: 16px">
      <el-alert title="计算异常（请先处理）" type="error" show-icon :closable="false">
        <template #default>
          <el-table :data="errors" border size="small" style="margin-top: 8px">
            <el-table-column prop="teacherName" label="教师" width="120" />
            <el-table-column prop="code" label="错误码" width="100" />
            <el-table-column prop="message" label="错误信息" />
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button link type="primary" @click="$router.push('/admin/rule/binding')">去查看</el-button>
              </template>
            </el-table-column>
          </el-table>
        </template>
      </el-alert>
    </div>

    <div v-if="warnings.length" style="margin-top: 16px">
      <el-alert title="警告提示" type="warning" show-icon :closable="false">
        <el-table :data="warnings" border size="small" style="margin-top: 8px">
          <el-table-column prop="teacherName" label="教师" width="120" />
          <el-table-column prop="message" label="说明" />
        </el-table>
      </el-alert>
    </div>

    <!-- 工资单列表 -->
    <div v-if="summary" class="page-card" style="margin-top: 16px">
      <div class="table-toolbar">
        <div class="left"><span class="section-title">工资单列表（{{ month }}）</span></div>
      </div>
      <el-table :data="statements" border stripe v-loading="loading">
        <el-table-column prop="id" label="工资单号" width="120" />
        <el-table-column prop="teacherName" label="教师" width="120" />
        <el-table-column label="应发金额" width="140">
          <template #default="{ row }">¥{{ row.gross?.toFixed(2) || '0.00' }}</template>
        </el-table-column>
        <el-table-column label="调整项" width="120">
          <template #default="{ row }">¥{{ row.adjustment?.toFixed(2) || '0.00' }}</template>
        </el-table-column>
        <el-table-column label="实发金额" width="140">
          <template #default="{ row }"><strong>¥{{ row.net?.toFixed(2) || '0.00' }}</strong></template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="viewDetail(row)">查看明细</el-button>
            <el-button link @click="openStatement(row)">工资单</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import { Calculator, DocumentChecked, Tickets, User, Stamp, Money } from '@element-plus/icons-vue'
import { calcMonth, validate, statementList } from '@/api/salary'

const router = useRouter()
const month = ref(dayjs().format('YYYY-MM'))
const calculating = ref(false)
const validating = ref(false)
const loading = ref(false)

const summary = ref(null)
const statements = ref([])
const errors = ref([])
const warnings = ref([])

const statusTag = (s) => ({ 0: 'info', 1: 'primary', 2: 'warning', 3: 'success' }[s] || 'info')
const statusText = (s) => ({ 0: '待确认', 1: '已确认', 2: '已锁定', 3: '已发放' }[s] || '-')

const doValidate = async () => {
  validating.value = true
  errors.value = []
  warnings.value = []
  try {
    const res = await validate(month.value)
    // 后端返回 { errors: [...], warnings: [...] }
    errors.value = res.errors || res.errorList || []
    warnings.value = res.warnings || res.warnList || []
    if (errors.value.length === 0) ElMessage.success('校验通过 ✅')
    else ElMessage.warning(`发现 ${errors.value.length} 个错误，请处理`)
  } catch (_) {} finally { validating.value = false }
}

const doCalc = async () => {
  calculating.value = true
  summary.value = null
  statements.value = []
  errors.value = []
  warnings.value = []
  try {
    const res = await calcMonth(month.value)
    summary.value = {
      detailCount: res.detailCount || 0,
      teacherCount: res.teacherCount || 0,
      pendingAttendance: res.pendingAttendance || 0,
      totalGross: res.totalGross || 0
    }
    errors.value = res.errors || res.errorList || []
    warnings.value = res.warnings || res.warnList || []
    ElMessage.success('计算完成，正在加载工资单...')
    await loadStatements()
  } catch (_) {} finally { calculating.value = false }
}

const loadStatements = async () => {
  loading.value = true
  try {
    const res = await statementList({ month: month.value, page: 1, size: 200 })
    if (Array.isArray(res)) statements.value = res
    else statements.value = res.list || res.records || []
  } catch (_) {} finally { loading.value = false }
}

const viewDetail = (row) => {
  router.push({ path: '/admin/salary/detail', query: { statementId: row.id } })
}

const openStatement = (row) => {
  router.push('/admin/salary/statement')
}
</script>

<style scoped>
.top-bar { padding: 20px 24px; }
.top-row { display: flex; justify-content: space-between; align-items: center; }
.top-bar .title { font-size: 20px; font-weight: 700; }
.top-bar .actions { display: flex; gap: 10px; }
.top-bar .sub { margin-top: 10px; color: #909399; font-size: 13px; }

.summary-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-top: 16px;
}
@media (max-width: 1200px) { .summary-row { grid-template-columns: repeat(2, 1fr); } }

.stat-card { position: relative; overflow: hidden; }
.stat-card .label { color: #909399; font-size: 13px; margin-bottom: 8px; }
.stat-card .value { font-size: 28px; font-weight: 700; color: #303133; }
.stat-card .stat-icon {
  position: absolute; right: 20px; top: 50%;
  transform: translateY(-50%); opacity: 0.22;
}
.section-title { font-weight: 600; }
</style>
