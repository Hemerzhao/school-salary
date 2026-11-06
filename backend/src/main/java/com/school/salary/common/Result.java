package com.school.salary.common;

import lombok.Data;

import java.io.Serializable;

@Data
public class Result<T> implements Serializable {

    private int code;
    private String msg;
    private T data;

    public Result() {}

    public Result(int code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    public static <T> Result<T> ok() {
        return new Result<>(ErrorCode.SUCCESS.getCode(), ErrorCode.SUCCESS.getMsg(), null);
    }

    public static <T> Result<T> ok(T data) {
        return new Result<>(ErrorCode.SUCCESS.getCode(), ErrorCode.SUCCESS.getMsg(), data);
    }

    public static <T> Result<T> error(String msg) {
        return new Result<>(ErrorCode.BIZ_ERROR.getCode(), msg, null);
    }

    public static <T> Result<T> error(int code, String msg) {
        return new Result<>(code, msg, null);
    }

    public static <T> Result<T> error(ErrorCode errorCode) {
        return new Result<>(errorCode.getCode(), errorCode.getMsg(), null);
    }

    public static <T> Result<T> error(ErrorCode errorCode, String msg) {
        return new Result<>(errorCode.getCode(), msg, null);
    }
}
