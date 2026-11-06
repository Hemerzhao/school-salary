package com.school.salary.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.school.salary.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {
}
