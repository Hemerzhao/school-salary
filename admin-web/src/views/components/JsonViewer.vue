<template>
  <pre class="json-viewer">{{ formatted }}</pre>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  jsonStr: { type: [String, Object, Array], default: '' }
})

const formatted = computed(() => {
  try {
    const val = typeof props.jsonStr === 'string'
      ? (props.jsonStr ? JSON.parse(props.jsonStr) : null)
      : props.jsonStr
    return JSON.stringify(val, null, 2)
  } catch (_) {
    return String(props.jsonStr)
  }
})
</script>

<style scoped>
.json-viewer {
  margin: 0;
  padding: 10px 12px;
  background: #f6f8fa;
  border-radius: 4px;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
  font-size: 12px;
  line-height: 1.5;
  color: #24292f;
  white-space: pre-wrap;
  word-break: break-all;
  max-height: 400px;
  overflow: auto;
}
</style>
