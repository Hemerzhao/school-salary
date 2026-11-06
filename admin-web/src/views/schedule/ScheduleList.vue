<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-date-picker
            v-model="filter.dateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            range-separator="至"
            start-placeholder="开始"
            end-placeholder="结束"
            style="width: 240px"
          />
          <el-select v-model="filter.teacherId" placeholder="教师" clearable style="width: 140px">
            <el-option v-for="t in teacherOptions" :key="t.id" :value="t.id" :label="t.name" />
          </el-select>
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        </div>
        <div class="right">
          <el-button type="primary" :icon="Plus" @click="openDialog()">新建排课</el-button>
        </div>
      </div>

      <el-table :data="page.list" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="teacherName" label="教师" width="120" />
        <el-table-column prop="courseName" label="课程" width="140" />
        <el-table-column prop="className" label="班级" width="140" />
        <el-table-column prop="date" label="日期" width="120" />
        <el-table-column label="时间" width="160">
          <template #default="{ row }">{{ row.startTime || '' }} ~ {{ row.endTime || '' }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="90">
          <template #default="{ row }">
            <el-tag size="small" :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '已排' : '已取消' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDialog(row)">编辑</el-button>
            <el-popconfirm title="确认删除？" @confirm="onRemove(row.id)">
              <template #reference>
                <el-button link type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 12px; justify-content: flex-end"
        @current-change="load"
        @size-change="load"
      />
    </div>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑排课' : '新建排课'" width="560px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="教师" prop="teacherId">
              <el-select v-model="form.teacherId" filterable style="width: 100%">
                <el-option v-for="t in teacherOptions" :key="t.id" :value="t.id" :label="t.name" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="课程" prop="courseId">
              <el-select v-model="form.courseId" filterable style="width: 100%">
                <el-option v-for="c in courseOptions" :key="c.id" :value="c.id" :label="c.name" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="班级" prop="classId">
              <el-select v-model="form.classId" filterable style="width: 100%">
                <el-option v-for="c in classOptions" :key="c.id" :value="c.id" :label="c.name" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="日期" prop="date">
              <el-date-picker v-model="form.date" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="开始时间" prop="startTime">
              <el-time-picker v-model="form.startTime" value-format="HH:mm" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结束时间" prop="endTime">
              <el-time-picker v-model="form.endTime" value-format="HH:mm" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="2" /></el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { page, create, update, remove } from '@/api/schedule'
import { list as teacherList } from '@/api/teacher'
import { list as classList } from '@/api/class'
import { list as courseList } from '@/api/course'

const loading = ref(false)
const submitting = ref(false)
const filter = reactive({ dateRange: [], teacherId: null })
const dialogVisible = ref(false)
const formRef = ref(null)
const teacherOptions = ref([])
const courseOptions = ref([])
const classOptions = ref([])
const page = reactive({ list: [], total: 0, current: 1, size: 20 })

const emptyForm = () => ({
  id: null, teacherId: null, courseId: null, classId: null,
  date: dayjs().format('YYYY-MM-DD'), startTime: '09:00', endTime: '10:30',
  remark: '', status: 1
})
const form = reactive(emptyForm())

const rules = {
  teacherId: [{ required: true, message: '请选择教师', trigger: 'change' }],
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }],
  classId: [{ required: true, message: '请选择班级', trigger: 'change' }],
  date: [{ required: true, message: '请选择日期', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }]
}
const isEdit = computed(() => !!form.id)

const loadOptions = async () => {
  try { teacherOptions.value = await teacherList({}) } catch (_) {}
  try { courseOptions.value = await courseList({}) } catch (_) {}
  try { classOptions.value = await classList({}) } catch (_) {}
}

const load = async () => {
  loading.value = true
  try {
    const params = {
      page: page.current, size: page.size,
      teacherId: filter.teacherId,
      start_from: filter.dateRange?.[0],
      start_to: filter.dateRange?.[1]
    }
    const res = await page(params)
    if (Array.isArray(res)) { page.list = res; page.total = res.length }
    else { page.list = res.list || res.records || []; page.total = res.total || 0 }
  } catch (_) {} finally { loading.value = false }
}

const openDialog = (row) => { Object.assign(form, row ? { ...row } : emptyForm()); dialogVisible.value = true }

const onSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (isEdit.value) { await update(form); ElMessage.success('更新成功') }
    else { await create(form); ElMessage.success('创建成功') }
    dialogVisible.value = false
    load()
  } catch (_) {} finally { submitting.value = false }
}

const onRemove = async (id) => { try { await remove(id); ElMessage.success('删除成功'); load() } catch (_) {} }

onMounted(() => { loadOptions(); load() })
</script>
