<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-select v-model="filter.targetType" placeholder="目标类型" clearable style="width: 140px">
            <el-option label="教师" value="TEACHER" />
            <el-option label="工资单" value="SALARY_STATEMENT" />
            <el-option label="规则模板" value="RULE_TEMPLATE" />
            <el-option label="规则绑定" value="RULE_BINDING" />
            <el-option label="打卡" value="ATTENDANCE" />
          </el-select>
          <el-input v-model="filter.action" placeholder="操作类型" clearable style="width: 140px" />
          <el-date-picker v-model="filter.timeRange" type="datetimerange" value-format="YYYY-MM-DD HH:mm:ss"
            start-placeholder="开始时间" end-placeholder="结束时间" style="width: 260px" />
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        </div>
      </div>

      <el-table :data="page.list" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="operatorName" label="操作人" width="120" />
        <el-table-column prop="targetType" label="目标类型" width="120" />
        <el-table-column prop="targetId" label="目标ID" width="100" />
        <el-table-column prop="action" label="操作" width="120">
          <template #default="{ row }">
            <el-tag size="small" :type="actionTag(row.action)">{{ row.action }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="时间" width="180" />
        <el-table-column label="变更内容">
          <template #default="{ row }">
            <div class="audit-pair">
              <div class="audit-side">
                <div class="label">变更前</div>
                <JsonViewer :json-str="row.beforeValue" />
              </div>
              <el-icon color="#c0c4cc" :size="24"><Right /></el-icon>
              <div class="audit-side">
                <div class="label">变更后</div>
                <JsonViewer :json-str="row.afterValue" />
              </div>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="page.current" v-model:page-size="page.size"
        :total="page.total" :page-sizes="[20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 12px; justify-content: flex-end"
        @current-change="load" @size-change="load"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search, Right } from '@element-plus/icons-vue'
import { logList } from '@/api/audit'
import JsonViewer from '@/views/components/JsonViewer.vue'

const loading = ref(false)
const filter = reactive({ targetType: '', action: '', timeRange: [] })
const page = reactive({ list: [], total: 0, current: 1, size: 20 })

const actionTag = (a) => ({
  CREATE: 'success',
  UPDATE: 'primary',
  DELETE: 'danger',
  CONFIRM: 'warning',
  LOCK: 'warning',
  UNLOCK: 'info',
  MARK_PAID: 'success'
}[a] || 'info')

const load = async () => {
  loading.value = true
  try {
    const res = await logList({
      ...filter, page: page.current, size: page.size,
      start_from: filter.timeRange?.[0], start_to: filter.timeRange?.[1]
    })
    if (Array.isArray(res)) { page.list = res; page.total = res.length }
    else { page.list = res.list || res.records || []; page.total = res.total || 0 }
  } catch (_) {} finally { loading.value = false }
}

onMounted(load)
</script>

<style scoped>
.audit-pair {
  display: flex;
  align-items: center;
  gap: 8px;
}
.audit-side {
  flex: 1;
  min-width: 0;
}
.audit-side .label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}
</style>
