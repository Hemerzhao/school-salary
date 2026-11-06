<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-input v-model="keyword" placeholder="搜索模板名称" clearable style="width: 220px" @keyup.enter="load" />
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        </div>
        <div class="right">
          <el-button type="primary" :icon="Plus" @click="openDialog()">新建模板</el-button>
        </div>
      </div>

      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="模板名称" width="180" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDialog(row)">编辑</el-button>
            <el-button link type="success" @click="openVersionDialog(row)">新建版本</el-button>
            <el-popconfirm title="确认删除？" @confirm="onRemove(row.id)">
              <template #reference>
                <el-button link type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 模板弹窗 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑模板' : '新建模板'" width="600px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="模板名称" prop="name"><el-input v-model="form.name" /></el-form-item>
        <el-form-item label="描述"><el-input v-model="form.description" /></el-form-item>
        <el-form-item label="参数结构" prop="paramSchema">
          <el-input v-model="form.paramSchema" type="textarea" :rows="8" placeholder='{"hourlyRate": "...", "studentBonus": "..."}' />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 新建版本弹窗 -->
    <el-dialog v-model="versionVisible" title="新建版本" width="560px">
      <el-form label-width="100px">
        <el-form-item label="版本号">
          <el-input v-model="version.versionNo" placeholder="如 v1.0.0" />
        </el-form-item>
        <el-form-item label="公式">
          <el-input v-model="version.formula" type="textarea" :rows="4" placeholder="例如: base + hourlyRate * duration + studentBonus * studentCount" />
        </el-form-item>
        <el-form-item label="默认参数">
          <el-input v-model="version.defaultParams" type="textarea" :rows="4" placeholder='{"hourlyRate": 50, "studentBonus": 5}' />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="versionVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="onSubmitVersion">创建</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import {
  templateList, templateCreate, templateUpdate, templateDelete,
  versionCreate
} from '@/api/rule'

const loading = ref(false)
const submitting = ref(false)
const keyword = ref('')
const list = ref([])
const dialogVisible = ref(false)
const versionVisible = ref(false)
const formRef = ref(null)
const currentTemplate = ref(null)

const emptyForm = () => ({ id: null, name: '', description: '', paramSchema: '{}', status: 1 })
const form = reactive(emptyForm())
const version = reactive({ templateId: null, versionNo: '', formula: '', defaultParams: '{}' })

const rules = {
  name: [{ required: true, message: '请输入模板名称', trigger: 'blur' }],
  paramSchema: [{ required: true, message: '请输入参数结构 JSON', trigger: 'blur' }]
}
const isEdit = computed(() => !!form.id)

const load = async () => {
  loading.value = true
  try { list.value = await templateList({ keyword: keyword.value }) } catch (_) {} finally { loading.value = false }
}

const openDialog = (row) => {
  Object.assign(form, row ? { ...row } : emptyForm())
  dialogVisible.value = true
}

const openVersionDialog = (row) => {
  currentTemplate.value = row
  version.templateId = row.id
  version.versionNo = ''
  version.formula = ''
  version.defaultParams = '{}'
  versionVisible.value = true
}

const onSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (isEdit.value) { await templateUpdate(form); ElMessage.success('更新成功') }
    else { await templateCreate(form); ElMessage.success('创建成功') }
    dialogVisible.value = false
    load()
  } catch (_) {} finally { submitting.value = false }
}

const onSubmitVersion = async () => {
  submitting.value = true
  try {
    await versionCreate({
      templateId: version.templateId,
      versionNo: version.versionNo,
      formula: version.formula,
      defaultParams: (() => { try { return JSON.parse(version.defaultParams) } catch { return {} } })()
    })
    ElMessage.success('版本创建成功')
    versionVisible.value = false
  } catch (_) {} finally { submitting.value = false }
}

const onRemove = async (id) => { try { await templateDelete(id); ElMessage.success('删除成功'); load() } catch (_) {} }

onMounted(load)
</script>
