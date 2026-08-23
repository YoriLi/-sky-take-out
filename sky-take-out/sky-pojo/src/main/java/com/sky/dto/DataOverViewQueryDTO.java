package com.sky.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "数据概览统计的查询条件")
public class DataOverViewQueryDTO implements Serializable {

    @Schema(description = "统计开始时间")
    private LocalDateTime begin;

    @Schema(description = "统计结束时间")
    private LocalDateTime end;

}
