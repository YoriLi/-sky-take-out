package com.sky.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

@Data
@Schema(description = "菜品分页查询的数据模型")
public class DishPageQueryDTO implements Serializable {

    @Schema(description = "页码")
    private int page;

    @Schema(description = "每页记录数")
    private int pageSize;

    @Schema(description = "菜品名称")
    private String name;

    @Schema(description = "分类id")
    private Integer categoryId;

    @Schema(description = "状态 0表示禁用 1表示启用")
    private Integer status;

}
