package com.sky.controller.admin;

import com.sky.constant.MessageConstant;
import com.sky.result.Result;
import com.sky.utils.AliOssUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.SchemaProperty;
import io.swagger.v3.oas.annotations.parameters.RequestBody;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

/**
 * 通用接口
 */
@RestController
@RequestMapping("/admin/common")
@Tag(name = "通用接口")
@Slf4j
public class CommonController {

    @Autowired
    private AliOssUtil aliOssUtil;

    // 方法签名保持不变。这里只描述文档：
    // 该接口实际以 multipart/form-data 上传，但 @PostMapping 没有声明 consumes，
    // SpringDoc 会退化成把 file 当作 query 参数，因此显式声明请求体并隐藏那个多余的参数。
    @PostMapping("/upload")
    @Operation(summary = "文件上传",
            requestBody = @RequestBody(required = true,
                    content = @Content(mediaType = MediaType.MULTIPART_FORM_DATA_VALUE,
                            schemaProperties = @SchemaProperty(name = "file",
                                    schema = @Schema(type = "string", format = "binary", description = "待上传的文件")))))
    @Parameter(name = "file", hidden = true)
    public Result<String> upload(MultipartFile file) {
        log.info("文件上传：{}", file);

        try {
//        原始文件名
            String originalFilename = file.getOriginalFilename();

//        截取原始文件名的后缀
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));

//        构造新文件名称
            String objectName = UUID.randomUUID().toString() + extension;

//        文件的请求路径
            String filePath = aliOssUtil.upload(file.getBytes(), objectName);
            return Result.success(filePath);
        } catch (IOException e) {
            log.error("文件删除失败：{}", e);
        }

        return Result.error(MessageConstant.UPLOAD_FAILED);
    }

}
