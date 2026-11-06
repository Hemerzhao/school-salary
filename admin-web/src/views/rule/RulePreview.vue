<template>
  <div class="page-container">
    <div class="page-card">
      <div class="page-title">规则预览与试算</div>
      <el-form :inline="true" :model="query" @submit.prevent="doPreview">
        <el-form-item label="教师">
          <el-select v-model="query.teacherId" filterable placeholder="请选择教师" style="width: 200px">
            <el-option v-for="t in teacherOptions" :key="t.id" :value="t.id" :label="t.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="日期">
          <el-date-picker v-model="query.date" type="date" value-format="YYYY-MM-DD" style="width: 160px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" :loading="loading" @click="doPreview">查询规则</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div v-if="result" style="margin-top: 16px">
      <el-card shadow="never">
        <template #header><div class="card-header">匹配信息</div></template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="教师">{{ result.teacherName }}</el-descriptions-item>
          <el-descriptions-item label="校区">{{ result.campusName }}</el-descriptions-item>
          <el-descriptions-item label="模板">{{ result.templateName }}</el-descriptions-item>
          <el-descriptions-item label="版本">{{ result.versionNo }}</el-descriptions-item>
          <el-descriptions-item label="公式" :span="2">{{ result.formula }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card shadow="never" style="margin-top: 12px">
        <template #header><div class="card-header">合并后参数</div></template>
        <div class="params-wrap">
          <el-tag v-for="(v, k) in result.mergedParams" :key="k" class="param-tag">{{ k }} = {{ v }}</el-tag>
          <span v-if="!result.mergedParams || Object.keys(result.mergedParams).length === 0" class="empty-text">无参数</span>
        </div>
      </el-card>

      <el-card shadow="never" style="margin-top: 12px">
        <template #header><div class="card-header">示例试算（duration=120, student_count=28, leave=2）</div></template>

        <el-alert v-if="calcError" :title="calcError" type="error" show-icon style="margin-bottom: 12px" />

        <el-statistic title="计算结果 (实付金额)" :value="calcResult?.finalAmount" :precision="2" prefix="¥" />

        <el-divider content-position="left">计算追踪 (step-by-step)</el-divider>
        <el-collapse v-if="calcResult?.trace">
          <el-collapse-item v-for="(step, i) in calcResult.trace" :key="i" :title="`Step ${i + 1}: ${step.title || step.name || '步骤'}`">
            <JsonViewer :json-str="step" />
          </el-collapse-item>
        </el-collapse>
        <div v-else class="empty-text">暂未产生 trace</div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { preview } from '@/api/rule'
import { list as teacherList } from '@/api/teacher'
import JsonViewer from '@/views/components/JsonViewer.vue'

const query = reactive({ teacherId: null, date: dayjs().format('YYYY-MM-DD') })
const loading = ref(false)
const teacherOptions = ref([])
const result = ref(null)
const calcResult = ref(null)
const calcError = ref('')

const doPreview = async () => {
  if (!query.teacherId) { ElMessage.warning('请选择教师'); return }
  loading.value = true
  calcResult.value = null
  calcError.value = ''
  try {
    result.value = await preview(query.teacherId, query.date)
    // 模拟试算 —— 真实场景由后端返回
    calcResult.value = {
      finalAmount: 0,
      trace: [
        { title: '获取基础参数', params: result.value?.mergedParams },
        { title: '解析公式', formula: result.value?.formula },
        { title: '代入打卡数据', duration: 120, student_count: 28, leave: 2 },
        { title: '计算时薪', detail: 'hourlyRate * (duration/60)' },
        { title: '计算课时费 + 人头奖励', detail: 'final = base + ...' }
      ]
    }
  } catch (e) {
    result.value = null
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  try { teacherOptions.value = await teacherList({}) } catch (_) {}
})
</script>

<style scoped>
.page-title { font-size: 18px; font-weight: 600; margin-bottom: 16px; }
.card-header { font-weight: 600; }
.params-wrap { display: flex; flex-wrap: wrap; gap: 6px; }
.param-tag { margin-right: 4px; }
.empty-text { color: #909399; }
</style>
