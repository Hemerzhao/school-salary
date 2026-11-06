package com.school.salary.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.school.salary.entity.AuditLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AuditLogMapper extends BaseMapper<AuditLog> {
}
