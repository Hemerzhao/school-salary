<template>
  <div class="page-container">
    <div class="page-card">
      <div class="table-toolbar">
        <div class="left">
          <el-select v-model="filter.teacherId" placeholder="教师" clearable filterable style="width: 180px">
            <el-option v-for="t in teacherOptions" :key="t.id" :value="t.id" :label="t.name" />
          </el-select>
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        </div>
        <div class="right">
          <el-button type="primary" :icon="Plus" @click="openDialog()">新建绑定</el-button>
        </div>
      </div>

      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="teacherName" label="教师" width="120" />
        <el-table-column prop="templateName" label="模板" width="140" />
        <el-table-column prop="versionNo" label="版本" width="120" />
        <el-table-column label="最终参数（合并后）">
          <template #default="{ row }">
            <template v-if="row.mergedParams">
              <el-tag v-for="(v, k) in row.mergedParams" :key="k" size="small" class="param-tag">
                {{ k }}: {{ v }}
              </el-tag>
            </template>
            <template v-else>
              <el-tag v-for="(v, k) in row.paramOverrides" :key="k" size="small" type="info" class="param-tag">
                {{ k }}: {{ v }}
              </el-tag>
            </template>
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

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑绑定' : '新建绑定'" width="600px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="教师" prop="teacherId">
          <el-select v-model="form.teacherId" filterable style="width: 100%">
            <el-option v-for="t in teacherOptions" :key="t.id" :value="t.id" :label="t.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="规则模板" prop="templateId">
          <el-select v-model="form.templateId" filterable style="width: 100%">
            <el-option v-for="t in templateOptions" :key="t.id" :value="t.id" :label="t.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="参数覆盖">
          <el-input v-model="form.paramOverrides" type="textarea" :rows="6" placeholder='{"hourlyRate": 80, "studentBonus": 10}' />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" />
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
import {
  bindingList, bindingCreate, bindingUpdate, bindingDelete,
  templateList
} from '@/api/rule'
import { list as teacherList } from '@/api/teacher'

const loading = ref(false)
const submitting = ref(false)
const filter = reactive({ teacherId: null })
const list = ref([])
const teacherOptions = ref([])
const templateOptions = ref([])
const dialogVisible = ref(false)
const formRef = ref(null)

const emptyForm = () => ({ id: null, teacherId: null, templateId: null, paramOverrides: '{}', remark: '' })
const form = reactive(emptyForm())

const rules = {
  teacherId: [{ required: true, message: '请选择教师', trigger: 'change' }],
  templateId: [{ required: true, message: '请选择模板', trigger: 'change' }]
}
const isEdit = computed(() => !!form.id)

const loadOptions = async () => {
  try { teacherOptions.value = await teacherList({}) } catch (_) {}
  try { templateOptions.value = await templateList({}) } catch (_) {}
}

const load = async () => {
  loading.value = true
  try { list.value = await bindingList({ teacherId: filter.teacherId }) } catch (_) {} finally { loading.value = false }
}

const openDialog = (row) => { Object.assign(form, row ? { ...row } : emptyForm()); dialogVisible.value = true }

const onSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  const data = { ...form }
  if (typeof data.paramOverrides === 'string') {
    try { data.paramOverrides = JSON.parse(data.paramOverrides) } catch { /* 保留字符串 */ }
  }
  try {
    if (isEdit.value) { await bindingUpdate(data); ElMessage.success('更新成功') }
    else { await bindingCreate(data); ElMessage.success('创建成功') }
    dialogVisible.value = false
    load()
  } catch (_) {} finally { submitting.value = false }
}

const onRemove = async (id) => { try { await bindingDelete(id); ElMessage.success('删除成功'); load() } catch (_) {} }

onMounted(() => { loadOptions(); load() })
</script>

<style scoped>
.param-tag { margin-right: 4px; margin-bottom: 4px; }
</style>
