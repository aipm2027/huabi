# huabi — 接手必读（给 AI 维护者的操作手册）

> 冯贤宇的个人作品集：**单文件、零依赖、浏览器直开**的静态站。
> 特色：左栏一只纯 canvas 3D 体素桌宠 **Huabi**，承担全站导航与彩蛋。
> 风格：瑞士编辑风 + **珊瑚单色系**（`--accent` 派生自桌宠珊瑚色 `#D97757`）。

**详细文档在 `docs/` 目录，改代码前先读对应篇：**

| 文档 | 什么时候读 |
|---|---|
| [docs/CONTENT-GUIDE.md](docs/CONTENT-GUIDE.md) | **只改内容（简历条目/换图/联系方式/文案）？读这篇就够**，有步骤和模板 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 想知道"某段代码在哪 / 是干嘛的 / 动了会影响什么" |
| [docs/MAINTENANCE.md](docs/MAINTENANCE.md) | 要做具体任务：填内容 / 换简历 / 调桌宠 / 部署 / 截图验证 |
| [docs/REFACTOR-PLAN.md](docs/REFACTOR-PLAN.md) | 想清理死代码 / 整理结构（**方案已写好，按阶段执行，别自由发挥**） |

---

## 硬规则（红线，违反 = 返工）

1. **动任何文件前先 `git status`。** 本仓库经常有多个 AI 会话并发工作，工作区可能有别人未提交的活。若有你不认识的改动，先弄清来源再动手。
2. **桌宠 Huabi 的角色本体不可改**：形状、配色、五官、比例都不能变（体素资产 = `huabiRenderer` 里的 `RECTS` 数组 + HTML 里隐藏的 `.pet-svg` 原版对照）。只允许改"渲染 / 光影 / 动效 / 交互"。
3. **零依赖、零联网、`file://` 直开必须永远成立。** 不引入任何 CDN / npm / 构建步骤 / ES module（Safari 在 `file://` 下拦 module，踩过坑，页面会全白）。唯一的外链是 Google Fonts（有系统字体兜底，断网不致命）。
4. **不编造用户的个人信息。** 剩余占位（荣誉图墙 10 张图、bio「多年」等）只能由用户本人提供真实内容后才替换。占位是刻意的设计态（虚线空态/`.tbd-tag`），不是 bug。
5. **未经用户明确要求不 push、不 commit。** 用户习惯"先看再推"。
6. **保持单文件结构。** 不要把 index.html 拆成多文件（这是产品身份的一部分，拆分方案的利弊见 REFACTOR-PLAN，结论是不拆）。
7. **改完必须验证**：无头截图对比（方法见 MAINTENANCE.md「验证手册」——canvas 动画截图有大坑，别用错方法然后误判自己改坏了）。
8. **不把任何 token / 密钥写进仓库或提交历史。** 推送走 SSH（已配好）。

## 30 秒结构速览

```
index.html (~2000 行, 单文件)
├─ <head>
│  ├─ Google Fonts (Space Grotesk / Inter / Noto Sans SC)
│  ├─ <style>            ← 全部 CSS。token 在 :root; 分区顺序 ≈ 页面视觉顺序
│  └─ window.__AILOGOS   ← 彩蛋用的 AI 官方 logo, base64 内联 (一大行, 别手改)
├─ <body>
│  ├─ .sidebar           ← 左栏: 桌宠坞位 + 两动作按钮(下载简历/彩蛋) + 导航 01-05
│  ├─ main.page          ← #about(hero) → #education → #experience → #projects
│  │                        → #startup → #honors → footer#contact
│  ├─ #fireworks         ← 彩蛋全屏 canvas
│  ├─ #pet               ← 桌宠本体 (必须是 body 直属, 有注释说明为什么)
│  └─ #petBubble         ← 心声气泡
└─ <script> (一个大块, 按 IIFE 分段)
   ├─ const HUABI = {…}  ← 全站配置层: 文案/名单/时序/参数, 改参数先来这
   ├─ 滚动淡入 / 进度线 / hero 入场 / 光斑 / 照片视差
   ├─ huabiRenderer()    ← 3D 体素渲染器 → window.huabiPet
   ├─ pet()              ← 拖拽/气泡/递送/彩蛋编排 → window.huabiFx; fireworks() 在其内部
   └─ photoFallback() / tocSpy()
```

## 当前状态快照（2026-07-10 整理后，过时请以 git 为准）

- `ddc271d` 已把真实内容上线：教育（西南大学）/ 实习（小鹏汽车，三子项目）/ 项目（腾讯创造营 AI 客服 + 本站）/ 创业（XbotPark 四足机器人）/ 联系方式（四项全填，HUABI.contact 单源）。侧栏「联系方式」按钮已删（与页脚重复），Huabi 只剩 下载简历/彩蛋 两动作。
- 之后是本次整理提交（P1 死代码 / P2 注释对齐 / P3 缩进统一+联系方式单源 / P5 内容区导引注释），渲染不变。
- 线上 https://aipm2027.github.io/huabi/ 跟随 origin/main，push 后 Pages 自动重部署（1–2 分钟）。
- **剩余占位**：荣誉图墙 10 张图（用户提供后按 CONTENT-GUIDE §4 换入）、bio「多年」、教育条目描述句。

## 已知陷阱 Top 5（详情见 docs/）

1. **联系方式有两处数据源**：JS 配置 `HUABI.contact`（桌宠名片卡读它；该功能入口按钮已移除、代码保留备用）+ `footer#contact` 的静态卡片。改联系方式**两处同步**，步骤见 CONTENT-GUIDE §5。
2. **无头截图**：DOM/CSS 动画用 `--virtual-time-budget≥9000` 即可；**canvas 动画（彩蛋烟花/递送）会被 virtual-time 冻在第 0 帧**，必须走 CDP 实时截图。另：本机截图存在**随机 1px 整页位移**（空白对照实验证实），逐像素对比不可用，验收靠肉眼看关键区 + 功能自检；Google Fonts 在本机代理下时通时断，对比截图请加 `--host-resolver-rules` 屏蔽字体域名以固定字体条件。
3. **缩进已全文件统一为 2 空格**（2026-07-10 整理，`git diff -w` 验证零逻辑变化）。新增代码请保持空格缩进，别再引入 tab。
4. 注释漂移已于 2026-07-10 整理清零（紫色主色/打字机/买一送十二等均已修正）。发现新漂移随手修，别让它积累。
5. 本机网络：到 github.com 只有 **SSH(22) 通**，HTTPS/API/github.io 全被内网代理挡 → 无法在本机自测线上页、无法调 GitHub API（确认线上效果只能请用户开浏览器）；`git push` 偶发被代理掐断，**重试一两次即可**。
