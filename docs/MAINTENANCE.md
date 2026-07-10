# MAINTENANCE — 日常维护手册（任务菜谱 + 验证 + 部署）

> 做任务前先读 [ARCHITECTURE.md](ARCHITECTURE.md) 对应小节；红线见根目录 [CLAUDE.md](../CLAUDE.md)。
> 本文写于 2026-07-10，「当前状态」小节会过时，**一切以 `git status` / `git log` 为准**。

---

## 1. 当前 git 状态（2026-07-10 整理后快照，一切以 `git log` 为准）

- `ddc271d`「内容上线」已推送：真实简历内容（教育/小鹏实习/腾讯创造营+本站/XbotPark）、荣誉图墙 10 占位槽、联系方式四项、toc 书脊导轨、删「联系方式」按钮。
- 其后为整理提交（P1 死代码 / P2 注释对齐 / P3.1 缩进统一 / P3.2 联系方式单源 / P5 内容导引注释 / 文档全面更新），渲染不变。
- **剩余占位**：荣誉图墙 10 张图、bio「多年」、教育条目描述句——见 §5 checklist。

## 2. 部署 runbook

```bash
cd ~/huabi
git status                     # 永远先看
git add <确认过的文件>
git commit -m "…"              # 仅在用户要求时
git push                       # 仅在用户要求时; SSH 偶发被代理掐断 → 重试 1-2 次
```
- Pages 配置是「Deploy from a branch」main / root（**不是** Actions），依赖根目录 `.nojekyll`。push 后 1–2 分钟自动重部署。
- 线上地址 **https://aipm2027.github.io/huabi/**（带 `/huabi/`；根域名是空的）。
- **本机验证不了线上**：HTTPS 到 github.io/github.com 被代理挡，只有 SSH 通。要确认线上效果只能请用户开浏览器看。
- 换简历/头像也要 push 才会上线（`resume.pdf`/`avatar.jpg` 是仓库文件）。

## 3. 任务菜谱（按频率排序）

### 3.1 填真实内容（最常见，需要用户提供数据）

**原则：一处占位都不许编。** 找占位：`grep -n "待补充\|tbd" index.html`。

**改内容一律先看 [CONTENT-GUIDE.md](CONTENT-GUIDE.md)（有模板可抄）。** 剩余待填项：

| 要填什么 | 改哪里 | 注意 |
|---|---|---|
| 荣誉图墙 10 张图 | 图片放 `honors/` → 按 CONTENT-GUIDE §4 换占位槽 | 竖版证书在 certs 组、横版照片在 moments 组；图片文件记得 git add |
| bio 的「多年」 | hero `.bio` 里 `<strong>多年</strong>` | 用户报真实年限 |
| 教育条目描述句 | `#education` 的 `<p>` | 当前是通用描述，可请用户补课程/研究方向 |
| 联系方式变更 | `HUABI.contact` + footer `.contact-grid` **两处同步**（CONTENT-GUIDE §5） | 邮箱/电话卡的 `href` 也要同步 |
| 简历 PDF | 覆盖 `~/huabi/resume.pdf`，或桌面放 PDF 双击 `更新简历.command` | 下载显示名固定 `冯贤宇-简历.pdf`，要改就改 `id="resumeLink"` 那行的 `download=` |
| 头像 | 覆盖 `avatar.jpg`（建议先用 `liftsubject.swift`/`framephoto.swift` 抠图裁剪） | 4:5 竖构图最合适 |

### 3.2 改文案 / 台词

- 页面文案：直接改 `<body>` 里的语义 HTML。
- 桌宠台词：`HUABI.pet.voiceLines`（心声）/ `dragLines`（拖拽）/ 按钮 `data-preview`（悬停预告）。
- 彩蛋海报署名/副标：`HUABI.fireworks.poster`。

### 3.3 调桌宠行为

全在 `HUABI.pet.*`（见 ARCHITECTURE 4.1 的接线表；`voiceCycleMs` 已接线，直接改值即可）。
动作/表情本身要新增或改造 → 读 ARCHITECTURE 4.3，先在 `mascot-lab.html` 或离线渲染脚本里验证（见 §4.3）。

### 3.4 改彩蛋 AI 名单

`HUABI.fireworks.ais` 增删条目即可，海报「买一送N」和网格布局自动适应。新 AI 需要 logo：把 base64 data-URI 加进 `window.__AILOGOS`（那是一整行，**用脚本改，别手编**）；没有 logo 会兜底显示文字瓷砖，也可给条目配 `emoji`。

### 3.5 加 / 删板块

Checklist（漏一步就会出现编号错位或导航死链）：
1. `<section id="…" class="block reveal">` 按 3.2 节模板写，放对位置。
2. eyebrow 编号 `0N — English` 全线重排（**含 footer contact 的 06**）。
3. `.toc` 里加/删 `<a href="#id"><b>0N</b>名称</a>`（tocSpy 自动生效，无需改 JS）。
4. 若板块要 Huabi 动作联动，参考 tocSpy 里 `window.huabiFx` 的用法。
5. 跑一遍 §4 验证。

### 3.6 调色 / 调字号 / 调间距

只动 `:root` token（见 ARCHITECTURE 2.1）。**别在具体规则里写死新颜色**——珊瑚系四件套（accent/soft/deep/ink）是一组派生关系，要换主色四个一起换，并同步散落的 `rgba(217,119,87,…)`（`grep -c "217,119,87" index.html` 有几十处，这是已知技债，见 REFACTOR-PLAN）。

## 4. 验证手册（改完必做）

### 4.1 快速渲染检查（DOM/CSS 层面的改动）

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CHROME" --headless --disable-gpu --window-size=1440,900 \
  --virtual-time-budget=9500 \
  --screenshot=/tmp/huabi.png "file:///Users/admin/huabi/index.html"
```
然后用 Read 工具看图。**军规**：
- budget **≥9000**：桌宠入场有 1.1s 延迟 + 持续 rAF，budget 低了会截到桌宠半透明/缺失的**假象**，别误判自己改坏了。
- **逐像素对比不可用**：本机截图有随机 1px 整页位移（2026-07-10 空白对照实验证实，同代码连拍两张差异 ~5%）。验收 = 肉眼看关键区 + §4.4 功能自检。
- **字体不确定**：Google Fonts 走代理时通时断，两次截图可能一次网络字体一次系统字体（全页文字都不同）。要对比截图时加 `--host-resolver-rules="MAP fonts.googleapis.com 127.0.0.1,MAP fonts.gstatic.com 127.0.0.1"` 固定为系统字体。
- hash 滚动（`…index.html#education`）可能截出全白；要截某板块用 `--window-size` 高一点或注入 scroll。
- 心声气泡只在 1.5–6.7s 窗口显示，budget 3200 左右最容易截到。
- 需要确定性渲染（像素对比）：注入 `*{animation-duration:.001s!important}` + `.pet{opacity:1}`。
- macOS 没有 `timeout` 命令；多实例并发加 `--user-data-dir=/tmp/cr-x` 会挂起，**串行截图就别加**。

### 4.2 canvas 动画检查（彩蛋 / 递送 —— virtual-time 无效！）

烟花与递送是 `performance.now()` + rAF 驱动，`--virtual-time-budget` 会把它们**冻在第 0 帧**（只见暗色覆盖层，看不到烟花/logo/Huabi）。必须实时 CDP：

1. `"$CHROME" --headless --remote-debugging-port=9222 about:blank &` 起实例;
2. WebSocket 连 CDP → `Page.navigate`（先 about:blank 再目标 URL 强制重载）;
3. `Runtime.evaluate` 点按钮（如 `document.querySelector('[data-act=fireworks]').click()`）;
4. **真实 sleep 若干秒**（烟花全景约 2.5–4s 时最好看）→ `Page.captureScreenshot`。

以前写过纯 stdlib 的 CDP 客户端在 `/tmp/cdp_shot.py`（/tmp 可能已清，按上面 4 步可重建：一个 WS 握手 + JSON 指令收发的小脚本即可）。

### 4.3 桌宠渲染器像素级检查（改了 huabiRenderer 内部才需要）

浏览器外"看见"渲染的唯一手段：写一个纯 node 脚本复刻页面的体素/光照/投影/表情逻辑，渲染成 PPM → `sips -s format png` 转 PNG → Read 看图，逐帧肉眼验证（**别靠公式猜**）。历史版本在 `/tmp/render.js`（可能已清，思路：把 huabiRenderer 的构建段原样拷进 node，draw 里把 ctx 调用换成手写光栅化到像素数组）。

### 4.4 功能自检清单（大改后过一遍）

- [ ] 桌宠入场落坞、悬停开心、轻点跳、拖走松手弹回、拖出侧栏气泡贴边
- [ ] 两按钮：下载简历（真下载了 resume.pdf？）、彩蛋（能开能关：点任意处/Esc/15s 自动）
- [ ] toc 点击滚动 + 高亮 + Huabi 反馈；滚动切板块高亮跟随
- [ ] 窄窗（<860px）：侧栏变横条、桌宠停靠**右缘顶栏正下方**、布局单列
- [ ] 系统开「减弱动态效果」后页面全部直接可见、无动画报错（macOS: 系统设置→辅助功能→显示）
- [ ] 断网打开 `file://`（字体回退系统字体，其余一切正常）

## 5. 待办 checklist（2026-07-10 整理后）

- [x] 教育 / 实习 / 项目 / 创业 / 联系方式 —— 已填真实内容（`ddc271d`）
- [ ] 荣誉图墙 10 张图（软著×2 / 专利 / QQ音乐 / 悦来×3 / 上游新闻×3）—— 用户提供后按 CONTENT-GUIDE §4 换入
- [ ] bio「多年」→ 真实年限
- [ ] 教育条目描述句（课程/研究方向）
- [ ] 确认 `resume.pdf` 是最新版简历
- [x] avatar.jpg 已公开可见（仓库 Public，Pages 全世界可见）

## 6. 环境与安全备忘

- 本机 git 身份是仓库级 `aipm2027`；remote 走 SSH 免 token。
- **不要**把任何 PAT/token 写进代码、提交、或对话可见的文件；历史上有过 token 泄露事件，旧 token 一律视为作废。
- gh CLI 未安装且本机网络装了也用不了（API 不通）。GitHub 网页端操作（改 Pages 设置等）只能请用户做。
- 多 AI 并发是常态：动手前 `git status`，发现工作区有陌生改动先停下来问清楚 / 读 diff，**永远不要覆盖别人未提交的活**（历史上撞过车）。
