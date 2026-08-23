package com.sky.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.stereotype.Controller;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Swagger 页面跳转入口
 */
@Controller
public class SwaggerRedirectController {

    @GetMapping("/doc.html")
    public void redirectToSwaggerUi(HttpServletResponse response) throws IOException {
        response.sendRedirect("/swagger-ui.html");
    }
}
