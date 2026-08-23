package com.sky.interceptor;

import com.sky.constant.JwtClaimsConstant;
import com.sky.context.BaseContext;
import com.sky.properties.JwtProperties;
import com.sky.utils.JwtUtil;
import io.jsonwebtoken.Claims;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * jwt令牌校验的拦截器
 */
@Component
// 标记后，Spring 启动时会扫描并创建该类的实例（Bean），放入 IoC 容器中管理。
// 这里必须加，因为拦截器需要被 Spring 管理，才能注入JwtProperties等依赖。
@Slf4j
public class JwtTokenAdminInterceptor implements HandlerInterceptor {
    @Autowired
    // 自动从 IoC 容器中获取 JwtProperties 的实例（它里面封装了 admin-secret-key 和 admin-token-name），
    // 并赋值给当前变量。这样在拦截器中就能直接读取 application.yml 的配置了。
    private JwtProperties jwtProperties;
    /**
     * 校验jwt
     *
     * @param request
     * @param response
     * @param handler
     * @return
     * @throws Exception
     */
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        //判断当前拦截到的是Controller的方法还是其他资源
        if (!(handler instanceof HandlerMethod)) {
            //当前拦截到的不是动态方法，直接放行
            return true;
        }
        //1、从请求头中获取令牌
        String token = request.getHeader(jwtProperties.getAdminTokenName());
        //2、校验令牌
        try {
            log.info("jwt校验:{}", token);
            Claims claims = JwtUtil.parseJWT(jwtProperties.getAdminSecretKey(), token);
            // 解析成功后，从载荷（Claims）中取出存放的员工 ID。
            Long empId = Long.valueOf(claims.get(JwtClaimsConstant.EMP_ID).toString());
            // JwtClaimsConstant.EMP_ID 是常量（值为 "EMP_ID"），登录生成 Token 时用它作为键名。
            log.info("当前员工id：", empId);
            //将用户id存储到ThreadLocal
            BaseContext.setCurrentId(empId);
            //ThreadLocal 的工具类）的静态方法 setCurrentId，将用户 ID 存储到 ThreadLocal当前线程（即处理这个请求的 Tomcat 线程）的局部变量中。
            // 在后续的 Controller、Service、Mapper 中，都可以通过此方法获取这个 ID，而无需通过方法参数层层传递。
            // 例如：在 EmployeeServiceImpl.save() 方法中，就是通过这种方式拿到 createUser 的值的。
            //3、通过，放行
            return true;
        } catch (Exception ex) {
            //4、不通过，响应 401 状态码
            response.setStatus(401);
            return false;
            // 返回 false，表示拦截请求。后续 Controller 不会被执行，请求在此终止。
        }
    }
}
