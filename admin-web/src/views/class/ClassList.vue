<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-input v-model="keyword" placeholder="搜索班级名称" clearable style="width: 220px" @keyup.enter="load" />
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        </div>
        <div class="right">
          <el-button type="primary" :icon="Plus" @click="openDialog()">新建班级</el-button>
        </div>
      </div>

      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="班级名称" />
        <el-table-column prop="campusName" label="校区" />
        <el-table-column prop="grade" label="年级" width="100" />
        <el-table-column prop="studentCount" label="人数" width="90" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '正常' : '停用' }}</el-tag>
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
    </div>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑班级' : '新建班级'" width="500px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="名称" prop="name"><el-input v-model="form.name" /></el-form-item>
        <el-form-item label="校区" prop="campusId">
          <el-select v-model="form.campusId" style="width: 100%">
            <el-option v-for="c in campusList" :key="c.id" :value="c.id" :label="c.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="年级"><el-input v-model="form.grade" /></el-form-item>
        <el-form-item label="人数"><el-input-number v-model="form.studentCount" :min="0" /></el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" />
        </el-form-item>
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
import { list, create, update, remove } from '@/api/class'
import { list as campusListApi } from '@/api/campus'

const loading = ref(false)
const submitting = ref(false)
const keyword = ref('')
const list = ref([])
const campusList = ref([])
const dialogVisible = ref(false)
const formRef = ref(null)

const emptyForm = () => ({ id: null, name: '', campusId: null, grade: '', studentCount: 0, status: 1 })
const form = reactive(emptyForm())

const rules = {
  name: [{ required: true, message: '请输入班级名称', trigger: 'blur' }],
  campusId: [{ required: true, message: '请选择校区', trigger: 'change' }]
}
const isEdit = computed(() => !!form.id)

const loadCampus = async () => { try { campusList.value = await campusListApi({}) } catch (_) {} }

const load = async () => {
  loading.value = true
  try { list.value = await list({ keyword: keyword.value }) } catch (_) {} finally { loading.value = false }
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

const onRemove = async (id) => { try { await remove(id); ElMessage.success('删除成功'); load() } catch (_) {} }

onMounted(() => { loadCampus(); load() })
</script>
