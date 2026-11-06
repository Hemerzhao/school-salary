<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-select v-model="filter.auditStatus" placeholder="审核状态" clearable style="width: 140px">
            <el-option label="待审核" :value="0" />
            <el-option label="通过" :value="1" />
            <el-option label="驳回" :value="2" />
          </el-select>
          <el-select v-model="filter.campusId" placeholder="校区" clearable style="width: 140px">
            <el-option v-for="c in campusList" :key="c.id" :value="c.id" :label="c.name" />
          </el-select>
          <el-date-picker v-model="filter.dateRange" type="daterange" value-format="YYYY-MM-DD"
            range-separator="至" start-placeholder="开始" end-placeholder="结束" style="width: 240px" />
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        </div>
      </div>

      <el-table :data="page.list" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="teacherName" label="教师" width="120" />
        <el-table-column prop="courseName" label="课程" width="140" />
        <el-table-column prop="className" label="班级" width="140" />
        <el-table-column prop="date" label="日期" width="120" />
        <el-table-column prop="duration" label="时长(分钟)" width="110" />
        <el-table-column prop="studentCount" label="出勤人数" width="100" />
        <el-table-column prop="leaveCount" label="请假" width="80" />
        <el-table-column prop="auditStatus" label="审核状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.auditStatus === 0" type="warning" size="small">待审核</el-tag>
            <el-tag v-else-if="row.auditStatus === 1" type="success" size="small">通过</el-tag>
            <el-tag v-else type="danger" size="small">驳回</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.auditStatus === 0" link type="success" @click="openAudit(row, 1)">通过</el-button>
            <el-button v-if="row.auditStatus === 0" link type="danger" @click="openAudit(row, 2)">驳回</el-button>
            <el-button link type="primary" @click="openAudit(row, 1, true)">查看</el-button>
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

    <!-- 审核弹窗 -->
    <el-dialog v-model="auditVisible" :title="auditAction === 1 ? '审核通过' : '审核驳回'" width="460px">
      <el-form label-width="80px">
        <el-form-item label="教师">{{ current?.teacherName }}</el-form-item>
        <el-form-item label="日期">{{ current?.date }}</el-form-item>
        <el-form-item label="时长">{{ current?.duration }} 分钟</el-form-item>
        <el-form-item label="备注">
          <el-input v-model="auditRemark" type="textarea" :rows="3" placeholder="填写审核备注（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="auditVisible = false">取消</el-button>
        <el-button :type="auditAction === 1 ? 'success' : 'danger'" :loading="submitting" @click="doAudit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { list, audit } from '@/api/attendance'
import { list as campusListApi } from '@/api/campus'

const loading = ref(false)
const submitting = ref(false)
const filter = reactive({ auditStatus: null, campusId: null, dateRange: [] })
const campusList = ref([])
const page = reactive({ list: [], total: 0, current: 1, size: 20 })

const auditVisible = ref(false)
const auditAction = ref(1)
const auditRemark = ref('')
const current = ref(null)

const load = async () => {
  loading.value = true
  try {
    const res = await list({
      ...filter,
      page: page.current, size: page.size,
      start_from: filter.dateRange?.[0], start_to: filter.dateRange?.[1]
    })
    if (Array.isArray(res)) { page.list = res; page.total = res.length }
    else { page.list = res.list || res.records || []; page.total = res.total || 0 }
  } catch (_) {} finally { loading.value = false }
}

const openAudit = (row, action, readonly = false) => {
  current.value = row
  auditAction.value = action
  auditRemark.value = row.auditRemark || ''
  auditVisible.value = true
}

const doAudit = async () => {
  submitting.value = true
  try {
    await audit({ id: current.value.id, action: auditAction.value, remark: auditRemark.value })
    ElMessage.success('审核成功')
    auditVisible.value = false
    load()
  } catch (_) {} finally { submitting.value = false }
}

onMounted(() => { try { campusList.value = await campusListApi({}) } catch (_) {}; load() })
</script>
