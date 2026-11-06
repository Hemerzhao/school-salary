package com.school.salary.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.school.salary.entity.Schedule;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ScheduleMapper extends BaseMapper<Schedule> {
}
