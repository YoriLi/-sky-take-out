package com.sky.config;

import com.sky.interceptor.JwtTokenAdminInterceptor;
import com.sky.interceptor.JwtTokenUserInterceptor;
import io.swagger.v3.oas.models.ExternalDocumentation;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springdoc.core.GroupedOpenApi;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalTimeSerializer;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * 配置类，注册web层相关组件
 */
// @Configuration : 标记这是一个“配置类”，相当于 Spring 的 XML 配置文件。
// Spring 启动时会扫描该类，并执行其中的 @Bean 方法来初始化容器。
@Configuration
@Slf4j
// 实现 WebMvcConfigurer ：表示在 Spring Boot 默认 MVC 配置上追加自定义内容。
public class WebMvcConfiguration implements WebMvcConfigurer {

    @Autowired
    private JwtTokenAdminInterceptor jwtTokenAdminInterceptor;

    @Autowired
    private JwtTokenUserInterceptor jwtTokenUserInterceptor;

    /**
     * 注册自定义拦截器
     *
     * @param registry
     */
    public void addInterceptors(InterceptorRegistry registry) {
        log.info("开始注册自定义拦截器...");

        registry.addInterceptor(jwtTokenAdminInterceptor)
                .addPathPatterns("/admin/**")
                // .addPathPatterns : 定义巡逻范围（/** 表示该路径下所有子路径都要拦截）
                // 例如：/admin/employee/page、/admin/dish/save 都会触发拦截器校验 Token
                .excludePathPatterns("/admin/employee/login");
        // .excludePathPatterns : 定义免检区域（不需要登录就能访问的接口）
        // 例如：登录接口如果也拦截，用户永远无法登录，所以必须放行！

        registry.addInterceptor(jwtTokenUserInterceptor)
                .addPathPatterns("/user/**")
                .excludePathPatterns("/user/user/login")
                // 用户端的登录接口放行
                .excludePathPatterns("/user/shop/status");
        // 用户端查看店铺营业状态也放行（不需要登录就能看）
    }

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("苍穹外卖项目接口文档")
                        .version("2.0")
                        .description("苍穹外卖项目接口文档"))
                .externalDocs(new ExternalDocumentation()
                        .description("苍穹外卖项目接口文档"));
    }

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jackson2ObjectMapperBuilderCustomizer() {
        log.info("配置Jackson日期格式...");
        return builder -> {
            builder.deserializers(
                    new LocalDateTimeDeserializer(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")),
                    new LocalDateDeserializer(DateTimeFormatter.ofPattern("yyyy-MM-dd")),
                    new LocalTimeDeserializer(DateTimeFormatter.ofPattern("HH:mm:ss"))
            );
            builder.serializers(
                    new LocalDateTimeSerializer(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")),
                    new LocalDateSerializer(DateTimeFormatter.ofPattern("yyyy-MM-dd")),
                    new LocalTimeSerializer(DateTimeFormatter.ofPattern("HH:mm:ss"))
            );
        };
    }

    @Bean
    public GroupedOpenApi adminOpenApi() {
        log.info("准备生成接口文档...");
        return GroupedOpenApi.builder()
                .group("管理端接口")
                .packagesToScan("com.sky.controller.admin")
                .build();
    }

    @Bean
    public GroupedOpenApi userOpenApi() {
        log.info("准备生成接口文档...");
        return GroupedOpenApi.builder()
                .group("用户端接口")
                .packagesToScan("com.sky.controller.user")
                .build();
    }
}
