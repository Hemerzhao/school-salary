<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-input v-model="filter.keyword" placeholder="姓名/手机号" clearable style="width: 180px" />
          <el-select v-model="filter.campusId" placeholder="校区" clearable style="width: 150px">
            <el-option v-for="c in campusList" :key="c.id" :value="c.id" :label="c.name" />
          </el-select>
          <el-select v-model="filter.level" placeholder="职级" clearable style="width: 130px">
            <el-option v-for="l in levels" :key="l.value" :value="l.value" :label="l.label" />
          </el-select>
          <el-select v-model="filter.status" placeholder="状态" clearable style="width: 120px">
            <el-option label="在职" :value="1" />
            <el-option label="离职" :value="0" />
          </el-select>
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        </div>
        <div class="right">
          <el-button type="primary" :icon="Plus" @click="openDialog()">新建教师</el-button>
        </div>
      </div>

      <el-table :data="page.list" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="姓名" width="120" />
        <el-table-column prop="mobile" label="手机号" width="150" />
        <el-table-column prop="campusName" label="校区" />
        <el-table-column prop="level" label="职级" width="100">
          <template #default="{ row }">
            {{ levels.find(l => l.value === row.level)?.label || row.level }}
          </template>
        </el-table-column>
        <el-table-column prop="baseSalary" label="基本工资" width="120">
          <template #default="{ row }">¥{{ row.baseSalary || 0 }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">{{ row.status === 1 ? '在职' : '离职' }}</el-tag>
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

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑教师' : '新建教师'" width="560px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="姓名" prop="name"><el-input v-model="form.name" /></el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="mobile"><el-input v-model="form.mobile" /></el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="校区" prop="campusId">
              <el-select v-model="form.campusId" style="width: 100%">
                <el-option v-for="c in campusList" :key="c.id" :value="c.id" :label="c.name" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="职级" prop="level">
              <el-select v-model="form.level" style="width: 100%">
                <el-option v-for="l in levels" :key="l.value" :value="l.value" :label="l.label" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="基本工资"><el-input-number v-model="form.baseSalary" :min="0" :precision="2" style="width: 100%" /></el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-switch v-model="form.status" :active-value="1" :inactive-value="0" />
            </el-form-item>
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
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { page, create, update, remove } from '@/api/teacher'
import { list as campusListApi } from '@/api/campus'

const levels = [
  { value: 'P1', label: '实习 P1' },
  { value: 'P2', label: '初级 P2' },
  { value: 'P3', label: '中级 P3' },
  { value: 'P4', label: '高级 P4' },
  { value: 'P5', label: '专家 P5' }
]

const loading = ref(false)
const submitting = ref(false)
const filter = reactive({ keyword: '', campusId: null, level: '', status: null })
const campusList = ref([])
const dialogVisible = ref(false)
const formRef = ref(null)
const page = reactive({ list: [], total: 0, current: 1, size: 20 })

const emptyForm = () => ({ id: null, name: '', mobile: '', campusId: null, level: 'P2', baseSalary: 0, status: 1 })
const form = reactive(emptyForm())

const rules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  mobile: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  campusId: [{ required: true, message: '请选择校区', trigger: 'change' }],
  level: [{ required: true, message: '请选择职级', trigger: 'change' }]
}
const isEdit = computed(() => !!form.id)

const loadCampus = async () => {
  try { campusList.value = await campusListApi({}) } catch (_) {}
}

const load = async () => {
  loading.value = true
  try {
    const res = await page({ ...filter, page: page.current, size: page.size })
    // 兼容后端返回 { list, total } 或直接数组
    if (Array.isArray(res)) {
      page.list = res
      page.total = res.length
    } else {
      page.list = res.list || res.records || []
      page.total = res.total || 0
    }
  } catch (_) {} finally {
    loading.value = false
  }
}

const openDialog = (row) => {
  Object.assign(form, row ? { ...row } : emptyForm())
  dialogVisible.value = true
}

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

const onRemove = async (id) => {
  try { await remove(id); ElMessage.success('删除成功'); load() } catch (_) {}
}

onMounted(() => { loadCampus(); load() })
</script>
