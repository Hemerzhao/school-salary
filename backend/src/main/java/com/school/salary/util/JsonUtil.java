package com.school.salary.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class JsonUtil {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    public static JsonNode readTree(String json) {
        if (json == null || json.isBlank()) {
            return null;
        }
        try {
            return OBJECT_MAPPER.readTree(json);
        } catch (JsonProcessingException e) {
            log.error("JSON 解析失败: {}", json, e);
            return null;
        }
    }

    public static String writeValueAsString(Object obj) {
        if (obj == null) {
            return null;
        }
        try {
            return OBJECT_MAPPER.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            log.error("JSON 序列化失败: {}", obj, e);
            return null;
        }
    }

    /** 别名：writeValueAsString 的简写 */
    public static String toJson(Object obj) {
        return writeValueAsString(obj);
    }

    /** 解析 JSON 数组为 List */
    public static <T> java.util.List<T> parseArray(String json, Class<T> elementClass) {
        if (json == null || json.isBlank()) {
            return java.util.Collections.emptyList();
        }
        try {
            return OBJECT_MAPPER.readValue(json,
                OBJECT_MAPPER.getTypeFactory().constructCollectionType(java.util.List.class, elementClass));
        } catch (JsonProcessingException e) {
            log.error("JSON 数组解析失败: {}", json, e);
            return java.util.Collections.emptyList();
        }
    }

    public static <T> T parseObject(String json, Class<T> clazz) {
        if (json == null || json.isBlank()) {
            return null;
        }
        try {
            return OBJECT_MAPPER.readValue(json, clazz);
        } catch (JsonProcessingException e) {
            log.error("JSON 转对象失败: {}", json, e);
            return null;
        }
    }

    public static <T> T parseObject(String json, TypeReference<T> typeRef) {
        if (json == null || json.isBlank()) {
            return null;
        }
        try {
            return OBJECT_MAPPER.readValue(json, typeRef);
        } catch (JsonProcessingException e) {
            log.error("JSON 转对象失败: {}", json, e);
            return null;
        }
    }
}
