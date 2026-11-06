package com.school.salary.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.school.salary.entity.SalarySnapshot;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SalarySnapshotMapper extends BaseMapper<SalarySnapshot> {
}
