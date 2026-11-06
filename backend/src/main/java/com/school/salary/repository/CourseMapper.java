package com.school.salary.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.school.salary.entity.Course;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CourseMapper extends BaseMapper<Course> {
}
