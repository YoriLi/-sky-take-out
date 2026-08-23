-- ---------------------------------------------------------------------------
-- 苍穹外卖 (sky-take-out) development database schema + seed data
--
-- This script provisions the `sky_take_out` schema expected by the Spring Boot
-- backend (see sky-server/src/main/resources/application-dev.yml). It is used by
-- the Cloud Agent environment setup to bootstrap a working local database.
--
-- Table/column definitions are derived from the JPA-style entities in
-- sky-pojo/src/main/java/com/sky/entity and the MyBatis mappers in
-- sky-server/src/main/resources/mapper. Seed data provides a login-ready admin
-- account plus a few categories/dishes/setmeals so the admin console is usable
-- end to end.
-- ---------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS `sky_take_out`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `sky_take_out`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- employee (管理端员工)
-- ----------------------------
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        VARCHAR(32)  NOT NULL COMMENT '姓名',
  `username`    VARCHAR(32)  NOT NULL COMMENT '用户名',
  `password`    VARCHAR(64)  NOT NULL COMMENT '密码',
  `phone`       VARCHAR(11)  NOT NULL COMMENT '手机号',
  `sex`         VARCHAR(2)   NOT NULL COMMENT '性别',
  `id_number`   VARCHAR(18)  NOT NULL COMMENT '身份证号',
  `status`      INT          NOT NULL DEFAULT 1 COMMENT '状态 0:禁用 1:启用',
  `create_time` DATETIME     DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME     DEFAULT NULL COMMENT '更新时间',
  `create_user` BIGINT       DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT       DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工信息';

-- NOTE: This version of EmployeeServiceImpl.login() compares the submitted
-- password directly against this column (the MD5 hashing step is still a
-- commented-out TODO in the source), so the seed stores the plaintext '123456'.
INSERT INTO `employee`
  (`id`, `name`, `username`, `password`, `phone`, `sex`, `id_number`, `status`, `create_time`, `update_time`, `create_user`, `update_user`)
VALUES
  (1, '管理员', 'admin', '123456', '13812312312', '1', '110101199001010047', 1, '2022-01-01 00:00:00', '2022-01-01 00:00:00', 10, 10);

-- ----------------------------
-- category (菜品及套餐分类)
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `type`        INT          DEFAULT NULL COMMENT '类型 1:菜品分类 2:套餐分类',
  `name`        VARCHAR(32)  NOT NULL COMMENT '分类名称',
  `sort`        INT          NOT NULL DEFAULT 0 COMMENT '顺序',
  `status`      INT          DEFAULT NULL COMMENT '分类状态 0:禁用 1:启用',
  `create_time` DATETIME     DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME     DEFAULT NULL COMMENT '更新时间',
  `create_user` BIGINT       DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT       DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_category_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品及套餐分类';

INSERT INTO `category`
  (`id`, `type`, `name`, `sort`, `status`, `create_time`, `update_time`, `create_user`, `update_user`)
VALUES
  (1, 1, '主食',   1, 1, '2022-06-09 22:09:18', '2022-06-09 22:09:18', 1, 1),
  (2, 1, '饮品',   2, 1, '2022-06-09 22:09:32', '2022-06-09 22:09:32', 1, 1),
  (3, 2, '经典套餐', 3, 1, '2022-06-09 22:11:04', '2022-06-09 22:11:04', 1, 1);

-- ----------------------------
-- dish (菜品)
-- ----------------------------
DROP TABLE IF EXISTS `dish`;
CREATE TABLE `dish` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        VARCHAR(32)   NOT NULL COMMENT '菜品名称',
  `category_id` BIGINT        NOT NULL COMMENT '菜品分类id',
  `price`       DECIMAL(10,2) DEFAULT NULL COMMENT '菜品价格',
  `image`       VARCHAR(255)  DEFAULT NULL COMMENT '图片',
  `description` VARCHAR(255)  DEFAULT NULL COMMENT '描述信息',
  `status`      INT           DEFAULT 1 COMMENT '0:停售 1:起售',
  `create_time` DATETIME      DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME      DEFAULT NULL COMMENT '更新时间',
  `create_user` BIGINT        DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT        DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_dish_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品';

INSERT INTO `dish`
  (`id`, `name`, `category_id`, `price`, `image`, `description`, `status`, `create_time`, `update_time`, `create_user`, `update_user`)
VALUES
  (1, '米饭',       1, 2.00,  '', '香糯东北大米', 1, '2022-06-10 09:18:49', '2022-06-10 09:18:49', 1, 1),
  (2, '手撕肉丝面', 1, 18.00, '', '劲道手工面',   1, '2022-06-10 09:19:33', '2022-06-10 09:19:33', 1, 1),
  (3, '柠檬水',     2, 8.00,  '', '鲜榨柠檬',     1, '2022-06-10 09:20:10', '2022-06-10 09:20:10', 1, 1);

-- ----------------------------
-- dish_flavor (菜品口味)
-- ----------------------------
DROP TABLE IF EXISTS `dish_flavor`;
CREATE TABLE `dish_flavor` (
  `id`      BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dish_id` BIGINT       NOT NULL COMMENT '菜品id',
  `name`    VARCHAR(64)  DEFAULT NULL COMMENT '口味名称',
  `value`   VARCHAR(255) DEFAULT NULL COMMENT '口味数据list',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品口味关系表';

INSERT INTO `dish_flavor` (`id`, `dish_id`, `name`, `value`) VALUES
  (1, 3, '甜度', '["无糖","少糖","半糖","多糖","全糖"]');

-- ----------------------------
-- setmeal (套餐)
-- ----------------------------
DROP TABLE IF EXISTS `setmeal`;
CREATE TABLE `setmeal` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id` BIGINT        NOT NULL COMMENT '菜品分类id',
  `name`        VARCHAR(32)   NOT NULL COMMENT '套餐名称',
  `price`       DECIMAL(10,2) NOT NULL COMMENT '套餐价格',
  `status`      INT           DEFAULT 1 COMMENT '状态 0:停用 1:启用',
  `description` VARCHAR(255)  DEFAULT NULL COMMENT '描述信息',
  `image`       VARCHAR(255)  DEFAULT NULL COMMENT '图片',
  `create_time` DATETIME      DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME      DEFAULT NULL COMMENT '更新时间',
  `create_user` BIGINT        DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT        DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_setmeal_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='套餐';

INSERT INTO `setmeal`
  (`id`, `category_id`, `name`, `price`, `status`, `description`, `image`, `create_time`, `update_time`, `create_user`, `update_user`)
VALUES
  (1, 3, '经济午餐套餐', 20.00, 1, '米饭 + 手撕肉丝面', '', '2022-06-10 10:00:00', '2022-06-10 10:00:00', 1, 1);

-- ----------------------------
-- setmeal_dish (套餐菜品关系)
-- ----------------------------
DROP TABLE IF EXISTS `setmeal_dish`;
CREATE TABLE `setmeal_dish` (
  `id`         BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `setmeal_id` BIGINT        DEFAULT NULL COMMENT '套餐id',
  `dish_id`    BIGINT        DEFAULT NULL COMMENT '菜品id',
  `name`       VARCHAR(32)   DEFAULT NULL COMMENT '菜品名称（冗余字段）',
  `price`      DECIMAL(10,2) DEFAULT NULL COMMENT '菜品原价',
  `copies`     INT           DEFAULT NULL COMMENT '份数',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='套餐菜品关系';

INSERT INTO `setmeal_dish` (`id`, `setmeal_id`, `dish_id`, `name`, `price`, `copies`) VALUES
  (1, 1, 1, '米饭',       2.00,  1),
  (2, 1, 2, '手撕肉丝面', 18.00, 1);

-- ----------------------------
-- user (小程序用户)
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `openid`      VARCHAR(45)  DEFAULT NULL COMMENT '微信用户唯一标识',
  `name`        VARCHAR(32)  DEFAULT NULL COMMENT '姓名',
  `phone`       VARCHAR(11)  DEFAULT NULL COMMENT '手机号',
  `sex`         VARCHAR(2)   DEFAULT NULL COMMENT '性别',
  `id_number`   VARCHAR(18)  DEFAULT NULL COMMENT '身份证号',
  `avatar`      VARCHAR(500) DEFAULT NULL COMMENT '头像',
  `create_time` DATETIME     DEFAULT NULL COMMENT '注册时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息';

-- ----------------------------
-- address_book (地址簿)
-- ----------------------------
DROP TABLE IF EXISTS `address_book`;
CREATE TABLE `address_book` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`       BIGINT       NOT NULL COMMENT '用户id',
  `consignee`     VARCHAR(50)  DEFAULT NULL COMMENT '收货人',
  `phone`         VARCHAR(11)  NOT NULL COMMENT '手机号',
  `sex`           VARCHAR(2)   DEFAULT NULL COMMENT '性别 0:女 1:男',
  `province_code` VARCHAR(12)  DEFAULT NULL COMMENT '省级区划编号',
  `province_name` VARCHAR(32)  DEFAULT NULL COMMENT '省级名称',
  `city_code`     VARCHAR(12)  DEFAULT NULL COMMENT '市级区划编号',
  `city_name`     VARCHAR(32)  DEFAULT NULL COMMENT '市级名称',
  `district_code` VARCHAR(12)  DEFAULT NULL COMMENT '区级区划编号',
  `district_name` VARCHAR(32)  DEFAULT NULL COMMENT '区级名称',
  `detail`        VARCHAR(200) DEFAULT NULL COMMENT '详细地址',
  `label`         VARCHAR(100) DEFAULT NULL COMMENT '标签',
  `is_default`    TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '默认 0:否 1:是',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='地址簿';

-- ----------------------------
-- shopping_cart (购物车)
-- ----------------------------
DROP TABLE IF EXISTS `shopping_cart`;
CREATE TABLE `shopping_cart` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        VARCHAR(32)   DEFAULT NULL COMMENT '商品名称',
  `image`       VARCHAR(255)  DEFAULT NULL COMMENT '图片',
  `user_id`     BIGINT        NOT NULL COMMENT '用户id',
  `dish_id`     BIGINT        DEFAULT NULL COMMENT '菜品id',
  `setmeal_id`  BIGINT        DEFAULT NULL COMMENT '套餐id',
  `dish_flavor` VARCHAR(50)   DEFAULT NULL COMMENT '口味',
  `number`      INT           NOT NULL DEFAULT 1 COMMENT '数量',
  `amount`      DECIMAL(10,2) NOT NULL COMMENT '金额',
  `create_time` DATETIME      DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车';

-- ----------------------------
-- orders (订单)
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id`                      BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `number`                  VARCHAR(50)   DEFAULT NULL COMMENT '订单号',
  `status`                  INT           NOT NULL DEFAULT 1 COMMENT '订单状态 1:待付款 2:待接单 3:已接单 4:派送中 5:已完成 6:已取消',
  `user_id`                 BIGINT        NOT NULL COMMENT '下单用户id',
  `address_book_id`         BIGINT        NOT NULL COMMENT '地址id',
  `order_time`              DATETIME      NOT NULL COMMENT '下单时间',
  `checkout_time`           DATETIME      DEFAULT NULL COMMENT '结账时间',
  `pay_method`              INT           NOT NULL DEFAULT 1 COMMENT '支付方式 1:微信 2:支付宝',
  `pay_status`              TINYINT       NOT NULL DEFAULT 0 COMMENT '支付状态 0:未支付 1:已支付 2:退款',
  `amount`                  DECIMAL(10,2) NOT NULL COMMENT '实收金额',
  `remark`                  VARCHAR(100)  DEFAULT NULL COMMENT '备注',
  `phone`                   VARCHAR(11)   DEFAULT NULL COMMENT '手机号',
  `address`                 VARCHAR(255)  DEFAULT NULL COMMENT '地址',
  `user_name`               VARCHAR(32)   DEFAULT NULL COMMENT '用户名称',
  `consignee`               VARCHAR(32)   DEFAULT NULL COMMENT '收货人',
  `cancel_reason`           VARCHAR(255)  DEFAULT NULL COMMENT '订单取消原因',
  `rejection_reason`        VARCHAR(255)  DEFAULT NULL COMMENT '订单拒绝原因',
  `cancel_time`             DATETIME      DEFAULT NULL COMMENT '订单取消时间',
  `estimated_delivery_time` DATETIME      DEFAULT NULL COMMENT '预计送达时间',
  `delivery_status`         TINYINT       NOT NULL DEFAULT 1 COMMENT '配送状态 1:立即送出 0:选择具体时间',
  `delivery_time`           DATETIME      DEFAULT NULL COMMENT '送达时间',
  `pack_amount`             INT           DEFAULT NULL COMMENT '打包费',
  `tableware_number`        INT           DEFAULT NULL COMMENT '餐具数量',
  `tableware_status`        TINYINT       NOT NULL DEFAULT 1 COMMENT '餐具数量状态 1:按餐量提供 0:选择具体数量',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ----------------------------
-- order_detail (订单明细)
-- ----------------------------
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        VARCHAR(32)   DEFAULT NULL COMMENT '名称',
  `image`       VARCHAR(255)  DEFAULT NULL COMMENT '图片',
  `order_id`    BIGINT        NOT NULL COMMENT '订单id',
  `dish_id`     BIGINT        DEFAULT NULL COMMENT '菜品id',
  `setmeal_id`  BIGINT        DEFAULT NULL COMMENT '套餐id',
  `dish_flavor` VARCHAR(50)   DEFAULT NULL COMMENT '口味',
  `number`      INT           NOT NULL DEFAULT 1 COMMENT '数量',
  `amount`      DECIMAL(10,2) NOT NULL COMMENT '金额',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

SET FOREIGN_KEY_CHECKS = 1;
