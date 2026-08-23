package com.sky.dto;
// 1. 包声明：这个类属于 sky 项目的 dto（数据传输对象）包
import lombok.Data;
// 2. 导入 Lombok 库的 Data 注解：可以不用重复写setter、getter
import java.io.Serializable;
// 3. 导入 Java 标准库的序列化接口（用于网络传输或缓存）
@Data
// lombok 插件提供的注解，作用在类上，会在编译期间自动生成以下方法：
// 1. 所有非静态字段的 getter 方法（获取属性值）
// 2. 所有非静态字段的 setter 方法（设置属性值）
// 3. toString() 方法（方便打印对象信息，调试用）
// 4. equals() 和 hashCode() 方法（用于对象间的比较和集合存储）
// 5. 无参构造方法（便于框架通过反射实例化对象）
// 注意：该注解在编译后生效，生成的代码会写入 .class 字节码文件，不影响源码的整洁度。
public class EmployeeDTO implements Serializable {

    private Long id; //员工ID（数据库主键）

    private String username; //员工登录用的用户名

    private String name;  //员工真实姓名

    private String phone; //员工手机号码

    private String sex; //员工性别

    private String idNumber; //员工身份证号码

}
