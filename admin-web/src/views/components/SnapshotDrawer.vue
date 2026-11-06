<template>
  <el-drawer v-model="visible" title="计算快照" size="560px">
    <template v-if="snapshot">
      <el-divider content-position="left">公式快照 (formula_snapshot)</el-divider>
      <JsonViewer :json-str="snapshot.formula_snapshot || snapshot.formulaSnapshot" />

      <el-divider content-position="left">参数快照 (params_snapshot)</el-divider>
      <JsonViewer :json-str="snapshot.params_snapshot || snapshot.paramsSnapshot" />

      <el-divider content-position="left">计算过程 (calculation_trace)</el-divider>
      <JsonViewer :json-str="snapshot.calculation_trace || snapshot.calculationTrace" />
    </template>
  </el-drawer>
</template>

<script setup>
import { computed } from 'vue'
import JsonViewer from './JsonViewer.vue'

const props = defineProps({
  modelValue: Boolean,
  snapshot: { type: Object, default: () => null }
})
const emit = defineEmits(['update:modelValue'])

const visible = computed({
  get: () => props.modelValue,
  set: (v) => emit('update:modelValue', v)
})
</script>
