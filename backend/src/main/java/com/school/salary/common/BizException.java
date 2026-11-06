package com.school.salary.common;

import lombok.Getter;

@Getter
public class BizException extends RuntimeException {

    private final int code;

    public BizException(String msg) {
        super(msg);
        this.code = ErrorCode.BIZ_ERROR.getCode();
    }

    public BizException(int code, String msg) {
        super(msg);
        this.code = code;
    }

    public BizException(ErrorCode errorCode) {
        super(errorCode.getMsg());
        this.code = errorCode.getCode();
    }

    public BizException(ErrorCode errorCode, String msg) {
        super(msg);
        this.code = errorCode.getCode();
    }
}
