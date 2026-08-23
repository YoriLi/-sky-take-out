package com.sky.config;

import com.sky.interceptor.JwtTokenAdminInterceptor;
import com.sky.interceptor.JwtTokenUserInterceptor;
import com.sky.json.JacksonObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurationSupport;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;

import java.util.List;

/**
 * 配置类，注册web层相关组件
 */
// @Configuration : 标记这是一个“配置类”，相当于 Spring 的 XML 配置文件。
// Spring 启动时会扫描该类，并执行其中的 @Bean 方法来初始化容器。
@Configuration
@Slf4j
// 继承 WebMvcConfigurationSupport ：表示“我要自定义 Spring MVC 的配置”。
// 一旦继承此类，Spring Boot 的自动配置部分会失效，全面交由本类管控。
public class WebMvcConfiguration extends WebMvcConfigurationSupport {

    @Autowired
    private JwtTokenAdminInterceptor jwtTokenAdminInterceptor;

    @Autowired
    private JwtTokenUserInterceptor jwtTokenUserInterceptor;

    /**
     * 注册自定义拦截器
     *
     * @param registry
     */
    protected void addInterceptors(InterceptorRegistry registry) {
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

    /**
     * 通过knife4j生成接口文档
     * @return
     */
    @Bean
    // @Bean : 将方法返回值（Docket 对象）交给 Spring IoC 容器管理
    public Docket docket() {
        ApiInfo apiInfo = new ApiInfoBuilder()
                .title("苍穹外卖项目接口文档")
                .version("2.0")
                .description("苍穹外卖项目接口文档")
                .build();
        Docket docket = new Docket(DocumentationType.SWAGGER_2)
                // 使用 Swagger 2.0 规范
                .apiInfo(apiInfo)
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.sky.controller"))
                // 开始扫描哪些包下的 Controller
                // .apis : 指定扫描路径。这里指定 com.sky.controller 包（包含 admin 和 user）
                .paths(PathSelectors.any())
                // .paths : 所有路径都生成文档（PathSelectors.any()）
                .build();
        return docket;
    }

    /**
     * 设置静态资源映射
     * @param registry
     */
    // 设置静态资源映射（让 Spring MVC 能找到 doc.html 等页面）
    // 虽然拦截器放过了 /doc.html，但如果 Spring MVC 找不到资源，还是会报 404。
    //  这里把请求路径指向 jar 包里的真实位置。
    protected void addResourceHandlers(ResourceHandlerRegistry registry) {

        registry.addResourceHandler("/doc.html").addResourceLocations("classpath:/META-INF/resources/");
        // 当访问 /doc.html 时，去 classpath:/META-INF/resources/ 目录下找文件
        registry.addResourceHandler("/webjars/**").addResourceLocations("classpath:/META-INF/resources/webjars/");
        // 当访问 /webjars/** （Swagger 依赖的前端静态文件）时，去对应目录找
    }

    /**
     * 扩展Spring MVC框架的消息转化器
     * @param converters
     */
    /**
     * 扩展 Spring MVC 框架的消息转换器（HttpMessageConverter）
     * 作用：自定义 Java 对象 转 JSON 的规则。
     * 如果不配置，LocalDateTime 会转成数组 [2024,12,11,10,30,15]。
     * 配置后，会自动转为 "yyyy-MM-dd HH:mm:ss" 格式。
     */
    protected void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        log.info("扩展消息转换器...");
        //创建一个消息转换器对象
        MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
        //需要为消息转换器设置一个对象转换器，对象转换器可以将Java对象序列化为json数据
        converter.setObjectMapper(new JacksonObjectMapper());
        //将自己的消息转化器加入容器中 3. 将自己的转换器放在列表的最前面（索引 0）优先级最高，Spring 会优先使用这个转换器处理 JSON。
        converters.add(0,converter);
    }

    @Bean
    public Docket docket1(){
        log.info("准备生成接口文档...");
        ApiInfo apiInfo = new ApiInfoBuilder()
                .title("苍穹外卖项目接口文档")
                .version("2.0")
                .description("苍穹外卖项目接口文档")
                .build();

        Docket docket = new Docket(DocumentationType.SWAGGER_2)
                .groupName("管理端接口")
                .apiInfo(apiInfo)
                .select()
                //指定生成接口需要扫描的包
                .apis(RequestHandlerSelectors.basePackage("com.sky.controller.admin"))
                .paths(PathSelectors.any())
                .build();

        return docket;
    }

    @Bean
    public Docket docket2(){
        log.info("准备生成接口文档...");
        ApiInfo apiInfo = new ApiInfoBuilder()
                .title("苍穹外卖项目接口文档")
                .version("2.0")
                .description("苍穹外卖项目接口文档")
                .build();

        Docket docket = new Docket(DocumentationType.SWAGGER_2)
                .groupName("用户端接口")
                .apiInfo(apiInfo)
                .select()
                //指定生成接口需要扫描的包
                .apis(RequestHandlerSelectors.basePackage("com.sky.controller.user"))
                .paths(PathSelectors.any())
                .build();

        return docket;
    }
}
