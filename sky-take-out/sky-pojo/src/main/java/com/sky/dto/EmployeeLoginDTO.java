package com.sky.dto;

import io.swagger.annotations.ApiModel; // 导入 Swagger 框架中用于描述"整个模型"的注解
import io.swagger.annotations.ApiModelProperty;// 导入 Swagger 框架中用于描述"具体字段"的注解
import lombok.Data;

import java.io.Serializable;

@Data
@ApiModel(description = "员工登录时传递的数据模型")
// @ApiModel 是 Swagger 注解，作用在"类"上。
// 它的作用是告诉 Swagger 生成的 API 文档："这个类是前端传入的 JSON 数据模型"。
// description 属性就是给这个模型起个中文名字，显示在文档页面上，方便前端开发人员看懂。
// 注意：这个注解只影响文档显示，代码运行时完全不起作用，删掉它登录功能照样正常运行。
public class EmployeeLoginDTO implements Serializable {

    @ApiModelProperty("用户名")
    // @ApiModelProperty 同理，给 password 字段标注中文解释"密码"。
    // 前端开发人员看到文档就知道这个字段填的是登录密码。
    private String username;

    @ApiModelProperty("密码")
    private String password;

}
