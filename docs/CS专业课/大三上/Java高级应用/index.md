# Java高级应用
<div class="badges">
<span class="badge cs-badge">CS <专业模块选修></span>
</div>




## 课程学习内容



## 任课教师

=== "psl"

    加油


## 课程教材

<待补充>

## 分数构成

<待补充>

## 课程学习建议

感觉找开发工作的话，会这个真的特别特别重要，光靠上课肯定不行，要花大量时间自学

---

转发杰神的记录

## 考试记录

非常抽象的考试题只能说。。。算了还是凭借记忆补充一下叭

### 题型分布

选择题（45分 30 x 1.5）共30题，每题1.5分

简答题：(40分 8 x 5) 共8题，每题5分

编程题：(5分) 程序填空，每空1分

设计题：(10分) 根据题目要求设计管理系统

### 选择题

难度偏大。。。很抽象，考了很多Spring依赖注入的内容

建议是：这部分多多找牛客网之类的刷刷题，什么课本、PPT都是浮云

个人见解，大佬轻喷

### 简答题

简述MVC架构模式，并说明它的缺点。

简述AOP的思想，及其应用举例。

简述servlet的生命周期

SpringBoot的配置文件有哪两种？并举例格式

SpringBoot有哪些启动方式？

简述Mybatis的映射方式

简述Mybatis映射文件与其内部数据结构的关系。

Web应用系统有哪四层结构，及其应用举例。

### 程序题

给出如下内容代码：

Java实体类User的bean结构

UserDAOImpl实现类

UserMapper的Mybatis映射文件

填充缺失的填空内容

需要会写delete、insert的相关代码

```java
<!-- 删除指定id的用户 -->
<delete id="deleteUser" parameterType="Integer">
  delete from user where id=#{id};
</delete>

<!-- 新增用户 -->
<insert id="addUser" parameterType="com.example.User">
  insert into user (name, age) values (#{name}, #{age});
</insert>
```

4.5 设计题
要求设计一个Boot管理系统，有用户登录模块和用户管理模块

其中用户登录模块有用户登录（包括权限验证）、用户注销子模块

用户管理模块有查询用户（包括分页查询）、新增用户、删除用户、修改用户子模块
————————————————

                            版权声明：本文为博主原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接和本声明。

原文链接：https://blog.csdn.net/weixin_62533201/article/details/135453705



>  如果有用，请关注杰神[个人博客](https://blog.csdn.net/weixin_62533201)和他的 [Gitee链接](https://gitee.com/ricejson)
>

## 课程资源