# 宁波大学课程攻略共享计划

## 前言

来到一所大学，从第一次接触许多课，直到一门一门完成，这个过程中我们时常收集起许多资料和情报。

有些是需要在网上搜索的电子书，每次见到一门新课程，Google 一下教材名称，有的可以立即找到，有的却是要花费许多眼力；有些是历年试卷或者 A4 纸，前人精心收集制作，抱着能对他人有用的想法公开，却需要在各个群中摸索以至于从学长手中代代相传；有些是上完一门课才恍然领悟的技巧，原来这门课重点如此，当初本可以更轻松地完成得更好……

我也曾很努力地收集各种课程资料，但到最后，某些重要信息的得到却往往依然是纯属偶然。这种状态时常令我感到后怕与不安。我也曾在课程结束后终于有了些许方法与总结，但这些想法无处诉说，最终只能把花费时间与精力才换来的经验耗散在了漫漫的遗忘之中。

我为这一年一年，这么多人孤军奋战的重复劳动感到不平。

我希望能够将这些隐晦的、不确定的、口口相传的资料和经验，变为公开的、易于获取的和大家能够共同完善、积累的共享资料。

我希望只要是前人走过的弯路，后人就不必再走。这是我的信念，也是我建立这个项目的原因。

## 特性
本项目计划收录以下内容：

 - 选课攻略
 - 电子版教材
 - 平时作业答案
 - 历年试卷
 - 复习/一页开卷资料
 - 竞赛/科研指南

 等等。。

## 本地构建/预览
1. 克隆本项目 repo
    ```shell
    $ git clone https://github.com/NBUComputerRepairClub/nbu-icicles.git
    $ cd nbu-icicles
    ```
2. 安装 python 依赖（mkdocs 以及 material）
    ```shell
    $ pip install -r requirements.txt
    ```

3. 启动 mkdocs 本地服务
    ```shell
    $ mkdocs serve
    ```
    - 之后即可通过浏览器访问 localhost:8000 预览网站

## 贡献
欢迎贡献！

欢迎贡献！

欢迎贡献！

——因为很重要所以说了三遍


[贡献指南](docs/contributing.md)：

 - 有Pull Request和直接提交 2种方式，具体详见[贡献指南](docs/contributing.md)： docs/contributing.md


## 贡献规范：

我们希望该项目可以持续性地发展下去，因此希望提交最好满足

### 提交内容

 - 统一使用markdown作为介绍（有typora可以直接预览，没有可以用任意的编辑器打开，参考本文件的语法）。文件优先pdf。

 - 避免上传较大的文件。电子书等内容最好给出百度云/google drive的链接，而不是直接放在项目里

 - 指明课程的时间（如2023春/秋）与老师名称（统一首字母大写，如FXZ）。

 - 不要向仓库内上传图片！所有图片一律通过图床显示（推荐使用[postimage](https://postimages.org/)使用简单无需注册）

### 提交格式

 - 增加文档内容：`docs: 增加/更新xxx课程内容`
 - 增加网站功能：`feat: xxx`
 - 修改bug：`fix: xxx`

Issue、PR、纠错、资料、选课/考试攻略，完全欢迎！

来自大家的关注、维护和贡献，才是让这个宁波大学独有的攻略本继续存在的动力~

## 微信公众号

 - n8u-icicles
 - 请注意，搜索公众号时不输入短横杠时不会搜索出结果

## 访问域名：

https://nbucomputerrepairclub.github.io/nbu-icicles/ （github.io源站点）

由于github访问慢的问题，提供**国内访问较快**的站点：
+ https://workstation.love/         域名提供者：[LingLingLinging](https://github.com/LingLingLinging)
+ https://nbu-icicles.1u0yt.fun/  域名提供者：[lindocedskes](https://github.com/lindocedskes)

## 贡献者

<a href="https://github.com/NBUComputerRepairClub/nbu-icicles/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=NBUComputerRepairClub/nbu-icicles" />
</a>

## 鸣谢
本项目参考了

 - https://github.com/ZJU-Turing/TuringCourses

 - https://github.com/QSCTech/zju-icicles