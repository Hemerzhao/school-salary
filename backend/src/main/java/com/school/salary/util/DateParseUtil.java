package com.school.salary.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 时间参数解析工具：兼容 "yyyy-MM-dd HH:mm:ss"（空格）与 ISO "yyyy-MM-dd'T'HH:mm:ss" 两种格式
 */
public class DateParseUtil {

    public static final DateTimeFormatter SPACE_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * 柔性解析：优先按空格格式，失败再按 ISO 格式
     */
    public static LocalDateTime parseFlexible(String s) {
        if (s == null || s.isBlank()) {
            return null;
        }
        String v = s.trim();
        try {
            return LocalDateTime.parse(v, SPACE_FORMAT);
        } catch (Exception ignored) {
            return LocalDateTime.parse(v.replace(" ", "T"));
        }
    }
}
