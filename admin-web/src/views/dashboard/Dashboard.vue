<template>
  <div class="page-container">
    <el-row :gutter="16">
      <el-col :span="8">
        <el-card class="stat-card" shadow="hover">
          <div class="label">教师总数</div>
          <div class="value">{{ stat.teacherCount }}</div>
          <el-icon class="stat-icon" color="#409eff" :size="48"><User /></el-icon>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="stat-card" shadow="hover">
          <div class="label">当月待审核打卡</div>
          <div class="value" style="color:#e6a23c">{{ stat.pendingAttendance }}</div>
          <el-icon class="stat-icon" color="#e6a23c" :size="48"><Stamp /></el-icon>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="stat-card" shadow="hover">
          <div class="label">已锁定工资单</div>
          <div class="value" style="color:#67c23a">{{ stat.lockedStatement }}</div>
          <el-icon class="stat-icon" color="#67c23a" :size="48"><Tickets /></el-icon>
        </el-card>
      </el-col>
    </el-row>

    <el-card style="margin-top: 16px" shadow="never">
      <template #header>
        <div class="card-header">
          <span>快捷入口</span>
        </div>
      </template>
      <el-row :gutter="12">
        <el-col v-for="entry in entries" :key="entry.path" :span="6">
          <el-button link type="primary" :icon="entry.icon" @click="$router.push(entry.path)">
            {{ entry.label }}
          </el-button>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const stat = ref({
  teacherCount: 0,
  pendingAttendance: 0,
  lockedStatement: 0
})

const entries = [
  { label: '工资计算', icon: 'Calculator', path: '/admin/salary/calc' },
  { label: '规则模板', icon: 'Document', path: '/admin/rule/template' },
  { label: '工资单管理', icon: 'Tickets', path: '/admin/salary/statement' },
  { label: '打卡审核', icon: 'Stamp', path: '/admin/attendance' }
]

onMounted(() => {
  // 真实环境下调用 /admin/stat 或拼接 API，这里给占位，让页面可展示
  stat.value = {
    teacherCount: 0,
    pendingAttendance: 0,
    lockedStatement: 0
  }
})
</script>

<style scoped>
.stat-card {
  position: relative;
  overflow: hidden;
}
.stat-card .value {
  font-size: 32px;
  font-weight: 600;
  color: #303133;
}
.stat-icon {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  opacity: 0.25;
}
.card-header {
  font-weight: 600;
}
</style>
