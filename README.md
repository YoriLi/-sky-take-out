# 苍穹外卖
关于苍穹外卖的学习资料，包括源码实现和整理的笔记，持续更新

## 接口文档

后端接口文档由 [SpringDoc OpenAPI](https://springdoc.org/v1/) 生成（OpenAPI 3.0 规范）。
启动 `sky-server` 后可通过以下地址访问：

| 用途 | 地址 |
| --- | --- |
| Swagger UI 页面 | http://localhost:8080/swagger-ui/index.html |
| OpenAPI JSON（全量） | http://localhost:8080/v3/api-docs |
| OpenAPI JSON（管理端） | http://localhost:8080/v3/api-docs/管理端接口 |
| OpenAPI JSON（用户端） | http://localhost:8080/v3/api-docs/用户端接口 |

文档分为「管理端接口」和「用户端接口」两个分组，可在 Swagger UI 右上角的
`Select a definition` 下拉框中切换。

管理端与用户端接口都需要携带 JWT 令牌，可点击页面上的 `Authorize` 按钮填入：

- 管理端：请求头 `token`
- 用户端：请求头 `authentication`

> 项目早期使用 Knife4j（Springfox Swagger2），文档地址为 `/doc.html`，该地址已不再可用。
