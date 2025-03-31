# 胡清华

**游戏引擎开发工程师**
现居杭州 | qinghua_hu20@163.com | +86 17857009478  

***

## 工作经历

**杭州海康威视数字技术股份有限公司 图像技术组**
软件开发工程师 | 2024/07 - 至今 

* 参与屏幕显示技术的前沿研究，开发光谱仪等设备的 PC 交互接口，并封装为 DLL 供软件调用。
* 在代码评审中多次发现并修复高级缺陷，提高系统稳定性；组织技术分享会，与团队成员交流技术经验。  

**杭州电子科技大学智能可视建模与仿真实验室iGame-Lab**
计算机图形学实习生 | 2022- 2024 

* 独立复现论文方法，实现对任意三维模型的曲面光顺操作，并集成至C++开发的Qt框架 iGame 软件项目中。

***

## 项目经历

**显示调节技术项目v1.1的开发负责人，开发Windows客户端软件，实现显示器画质自动化测评与校正**

* 支持海康自研显示器的画质自动测评与校正，将测试时间从 **1 天缩短至 2.5 小时**
* 采用 **MVC 设计模式**，前端使用 **QML**，后端采用 **C++** 进行业务逻辑处理，并通过单例模式优化组件交互。
* 采用 **工厂模式** 设计功能模块，如调用造图接口时，程序可根据参数自动判断图像类型；底层绘图基于 **OpenGL**，并通过 **离屏渲染** 提升软件性能。
* 设计自定义的 DDC/CI 通信指令格式，开发适配 NVIDIA 显卡的多显示器参数控制软件接口。
* 增加 **色域校正功能**，基于论文方法建立迭代模型，生成 **8-bit 校正矩阵**，并将误差精度控制在 **0.0001** 以内。  


***

## 科研经历

**[《Parameterization of volumes with energy-minimizing diagonal surfaces from given boundary》](https://www.sciencedirect.com/science/article/abs/pii/S0377042724001936)**

* 第一作者 发表在《Journal of Computational and Applied Mathematics》SCI-2区top 2024
* 采用 **拉格朗日乘子法** 计算支持内能最小的体参数化方法，使用 **C++ 和 Mathematica** 进行实验，实现高效的参数化求解方案。  

**[《DiagVol:Multi-block Bézier Volume Modeling from Prescribed Diagonal Surface Pairs》](https://www.sciencedirect.com/science/article/abs/pii/S001044852200197X)**
* 第二作者 发表在《Computer-Aided Design》CCFB 2023
* 提出从 **n 对给定对角面** 构造 **C¹ 连续 Bézier 体** 的方法。本人负责证明 Bézier 体构造的数学充要条件，并进行大量实验，验证其建模灵活性和仿真效果。  

***

## 专业技能

**C++:** 熟练使用C++以及C++17、C++20新特性
**CET-6:** 通过CET-6,能顺利阅读英文技术文档并撰写学术论文
**Qt / QML:** 熟悉 Qt 信号槽机制，熟练使用QML语言
**OpenGL:** 了解OpenGL 渲染流程
**Vue.js:** 曾独立使用Vue.js开发支持“在线观战功能”的俄罗斯方块抖音小程序

***

## 教育背景

**计算机科学与技术(计算机科学英才班)**
杭州电子科技大学, 2020-2024