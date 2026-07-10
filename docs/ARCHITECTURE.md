# ARCHITECTURE — index.html 代码地图

> 本文对应 2026-07-10 的工作区版本（约 1985 行）。**行号会漂移，定位一律优先用「grep 锚点」**（文中给出的可搜索字符串），行号只作辅助。
> 阅读顺序建议：先看「总体分区」，再按需跳到 CSS / HTML / JS 各自的地图。

---

## 0. 设计哲学（为什么长这样）

- **单文件**：整站 = 一个 `index.html`。没有构建、没有依赖、没有模块加载。浏览器双击直开（`file://`）必须完整可用——这是产品身份，不是偷懒。
- **零依赖红线的由来**：曾用 three.js CDN + ES module，Safari 在 `file://` 下拦截 module 导致整页全白。此后所有 3D 都是自写的 canvas 2D 软件体素渲染器。
- **珊瑚单色系**：全站唯一强调色 `--accent:#D97757` 派生自桌宠本体色（Anthropic Crail 珊瑚），绿色 `--green` 只用于"开放中"状态点。CSS 头部注释里"紫 #6d5cff 主色"是**过时注释**，勿信。
- **桌宠不只是装饰**：Huabi 是导航系统的一部分——两动作按钮（下载简历/彩蛋）由它"执行"（「联系方式」按钮 2026-07-10 应用户要求移除，与页脚联系卡重复；递送代码保留备用），toc 点击它会看向目标并发射体素粒子，滚动换板块它会瞟一眼。
- **占位即设计**：未填的真实信息做成刻意空态——`.tbd-tag` 胶囊 / 虚线边框（`.proj-tbd`/`.vc-tbd`）/ 图墙占位槽（`.ht-empty`），视觉上是"预留位"而非"没做完"。当前正文已填真实内容，空态类保留为模板资产。

## 1. 总体分区

| 区块 | grep 锚点 | 大致行号 | 内容 |
|---|---|---|---|
| head 元信息 | `<title>冯贤宇` | 1–10 | charset / viewport / description / Google Fonts |
| CSS | `取向 A · 编辑非对称` | 11–878 | 全部样式，一个 `<style>` 块 |
| logo 资产 | `window.__AILOGOS=` | 879 | **一整行** base64 SVG 字典（15 个 AI logo），别手工编辑这一行 |
| HTML 左栏 | `═══ 左栏 ═══` | ~1000 | sidebar：桌宠坞位 + 两动作 + toc（书脊导轨滑点） |
| HTML 主内容 | `═══ 主内容 ═══` | 908–1108 | hero + 5 个板块 + footer |
| 全局元素 | `id="fireworks"` | 1110–1152 | 彩蛋 canvas / 桌宠 #pet / 遮罩 / 气泡 |
| JS | `Huabi — 交互脚本` | 1154–1983 | 一个 `<script>` 块，按 IIFE 分段 |

## 2. CSS 地图

### 2.1 设计 token（`:root`，锚点 `--ink: #1a1a2e`）

| 组 | token | 语义 |
|---|---|---|
| 墨色 | `--ink` / `--muted` / `--hairline(-solid)` | 正文 / 次级 / 发丝线 |
| 底色 | `--bg` #fafafa / `--surface` #fff | 页面底 / 卡片底 |
| **强调（珊瑚系）** | `--accent` #D97757 | 唯一主强调色（= `--coral`） |
| | `--accent-soft` #f9e3d8 | 图标底 / hover 浅底 |
| | `--accent-deep` #C15F3C | hover 加深态 |
| | `--accent-ink` #a8472a | 亮底上的文字（时间/机构/eyebrow），对比达 WCAG AA |
| 绿（仅状态点） | `--green` / `--green-deep` / `--green-glow` | 「开放中」呼吸点 |
| 桌宠 | `--coral` / `--coral-soft` | 桌宠专属（与 accent 同值但语义独立） |
| 字体 | `--font-display` / `--font-body` | Space Grotesk / Inter（中文回退 PingFang SC 等） |
| 布局 | `--sidebar-w` clamp(196px,14vw,216px) / `--maxw` 1100px | |
| **字阶** | `--fs-lead/title/body/small/label/eyebrow` | 同层级共用同 token，改字号只动这里 |
| 间距 | `--space-4 … --space-128` | 4px 基数 |
| **简历布局** | `--resume-time-w` 128px / `--resume-gap` 28px / `--resume-line` 760px | 条目「时间列宽 / 列间距 / 正文行长」——板块标题和条目共用，保证左对齐 |

### 2.2 分区顺序（自上而下 ≈ 页面视觉顺序）

| 段 | grep 锚点 | 管什么 |
|---|---|---|
| 重置 & 基础 | `* { margin: 0` | reset / body / `:focus-visible` |
| 噪点层 | `.noise {` | 全屏噪点纹理（z 9999，pointer-events:none） |
| 左栏 | `.sidebar {` | 侧栏 + 右缘珊瑚渐变线（`.sidebar::after`） |
| 桌宠坞位 | `.pet-dock {` | 侧栏里给桌宠留的 120px 高空位（`pointer-events:none`，桌宠自己是 fixed 定位到这里） |
| 导航 | `.toc {` | 竖排（`writing-mode:vertical-rl`）01–05 + active 珊瑚体素方块标记（`.toc a::before` + `tocMark` 动画） |
| 页面容器 | `.page, main {` | maxw + 桌面端 `body{padding-left:var(--sidebar-w)}`（断点 861px） |
| Hero | `#about { min-height` | 图文双栏 grid(1.15fr/0.85fr)；`.role .hl` 珊瑚高亮词 + `hlSwipe` 下划线扫入动画（延迟 2s） |
| 板块通用 | `section.block {` | `.eyebrow` 序号 / `.block h2` / `.section-header` 与条目同网格对齐 |
| 照片 | `.portrait {` | 头像 + 珊瑚光晕 `-shadow` + 边框装饰 `hero-media::before` + 加载失败兜底 `.photo-fallback/.avatar-illo` |
| **条目（核心）** | `.items { display` | 简历式条目：`grid: var(--resume-time-w) minmax(0,1fr)`；`.when` 时间列 / `.item-body` 正文 / `.org` 机构 / li marker 珊瑚色；`.item-sub` 子项目小标题（珊瑚小方点） |
| 时间线 spine | `.items-spine {` | 教育/实习的竖线+珊瑚方点节点（复用 toc 活动点视觉语言）；TBD 条目空心节点 |
| 关键词 chips | `.item-tags {` | `.tag` 胶囊（实习条目/项目卡通用） |
| 项目卡 | `.proj-grid {` | auto-fit 卡片网格；`.pc-kicker` 眉题 / `.pc-link` 出口链接；`.proj-tbd` 虚线空态 |
| 创业卡 | `.venture-card {` | 全宽叙事卡：左珊瑚渐变条 + `.vc-facts` 方向/角色/阶段字段槽；`.vc-tbd` 空态 |
| section-lede | `.section-lede {` | 每区块 h2 下的一行引导文案 |
| 条目入场 | `html.js .item {` | 逐条上浮 stagger（nth-child 1–6 延迟递增） |
| 荣誉图墙 | `.honors-gallery {` | `.wall-group`(kicker 分组) > `.honors-wall.certs`(3:4 竖版) / `.moments`(4:3 横版) > `figure.honor-tile`；`.ht-empty` 占位态 |
| **待补充设计态** | `占位「待补充」设计态` | `.tbd-tag` 胶囊 + `.item-tbd` 降灰（当前无实例，保留为模板资产） |
| 页脚联系 | `footer#contact {` | `.contact-body` 左缩进对齐条目正文列 + `.contact-grid` 2×2 卡片 + `.contact-baseline` |
| 揭示动画 | `html.js .reveal {` | 板块整体上浮；hero 逐字（`.char`）；照片 clip-path 揭幕 |
| 光斑/进度线 | `.cursor-aura {` / `#progress {` | 跟随光标的珊瑚光晕 / 顶部 2px 阅读进度条 |
| **桌宠** | `.pet { position: fixed` | 88px（移动 72px）；`petEnter` 入场（延迟 1.1s）；`petHalo` 呼吸光环；`.dragging/.running`；**递送/彩蛋的状态类**（下表） |
| 递送道具 | `.pet-carry-sheet {` | 桌宠"叼着"的小纸片；`.huabi-paper-release` 简历纸放大卡；`.huabi-contact-note` 联系方式对话卡；`.huabi-token-fx` 飞行 emoji 令牌；`.pet-voxel-fx` 定向体素粒子 |
| 气泡 | `.pet-bubble {` | 心声气泡 + 四向小尾巴（`.tail-up/.tail-down/.left-side/默认右侧`，尾巴 y 用 `--tail-y`） |
| 动作按钮 | `Huabi 工具箱` | `.ha-btn`：左珊瑚竖条 hover 长高 + `.is-attentive/.is-working` 状态 + `haPing` 圆点脉冲 |
| 遮罩/彩蛋 | `.focus-scrim {` / `#fireworks {` | 递送时毛玻璃弱化整页（z190）/ 彩蛋暗色宇宙底（z200） |
| reduced-motion | `@media (prefers-reduced-motion` | **有两段**（桌宠一段 + 全局一段），新加动画记得两边都考虑 |
| 响应式 | `@media (max-width: 860px)` | 侧栏变横条置顶、坞位隐藏、toc 横排、条目单列；另有 640px 桌宠缩小一档 |

### 2.3 桌宠状态类 → 动画对照（都挂在 `#pet` 上）

| 类 | 谁加的 | 效果 |
|---|---|---|
| `.dragging` | pet() down() | grabbing 光标 |
| `.running` | runHome/递送/彩蛋 | left/top 0.72s spring 过渡（位移动画全靠它） |
| `.fx-travel` / `.fx-arrived` | 彩蛋召唤 | z 抬到 235 / 到位后 `fxPetArrive` 放大浮动 |
| `.delivery-travel` / `.delivery-arrived` | 递送 | z 242 / `petCarry` 搬运摆动 / `petPresent` 呈上 |
| `.action-resume/.action-contact/.action-egg` | pulsePetAction() | 点按钮时的原地小动作（`petDeliver/petGuide/petCharge`） |

### 2.4 z-index 阶梯（新弹出物请对号入座）

```
0 .cursor-aura → 1 .page → 100 .sidebar → 110 .pet → 112 .pet-bubble → 113 .pet-voxel-fx
→ 190 .focus-scrim → 200 #fireworks → 235 .pet.fx-travel → 236 .huabi-token-fx
→ 242 .pet.delivery-travel → 244 .huabi-paper-release/.huabi-contact-note
→ 300 #progress → 9999 .noise(不可点)
```

## 3. HTML 地图

### 3.1 左栏（锚点 `═══ 左栏 ═══`）

- `.pet-dock`：**只是占位坑**，桌宠本体不在这里面（见 3.3）。`aria-hidden`。
- `.huabi-actions`：两个 `.ha-btn`（resume/fireworks），靠 `data-act` + `data-preview`（悬停时 Huabi 说的话）驱动，JS 在 pet() 里统一委托监听（`data-target` 联系递送分支仍在，入口已移除）。
- `.toc`：5 个链接 `#education/#experience/#projects/#startup/#honors`，`<b>` 是序号；书脊导轨 `.toc::before` + 滑动指示钻 `.toc-dot`（JS 定位 top）。**contact 不进 toc**（滚到底即达），但 eyebrow 编号里它是 06。

### 3.2 主内容板块（每个 section 结构一致）

```html
<section id="…" class="block block-full|block-offset reveal">
  <header class="section-header">
    <span class="eyebrow">0N — English</span>
    <h2>中文标题</h2>
  </header>
  <div class="items"> <div class="item [item-tbd]"> <div class="when">时间</div>
    <div class="item-body"> <h3>标题[<span class="tbd-tag">待补充</span>]</h3>
      <div class="org [org-tbd]">机构</div> <ul><li>要点</li></ul> 或 <p>说明</p>
  …
```

| id | eyebrow | 标题 | 内容状态（2026-07-10） |
|---|---|---|---|
| `about`（header 元素） | — | hero | 真实（bio「多年」仍是软占位）；方位词自适应 `.dir-d`桌面「左边」/`.dir-m`移动「右上角」 |
| `education` | 01 — Education | 教育背景 | 真实：西南大学 智能制造工程（创新班）2023.9–2027.6 |
| `experience` | 02 — Experience | 实习经历 | 真实：小鹏汽车 AI 产品经理实习（`.item-sub` 分三个子项目） |
| `projects` | 03 — Projects | 项目经历 | 真实：腾讯创造营 AI 客服（aipm2027.cn）+ 本站 Huabi，卡片式 `.proj-card` |
| `startup` | 04 — Ventures | 创业经历 | 真实：XbotPark Mini 四足机器人，全宽 `.venture-card` |
| `honors` | 05 — Honors | 荣誉奖项 | **图墙 10 个占位槽等图**（软著×2/专利/QQ音乐 + 悦来×3/上游新闻×3） |
| `contact`（footer） | 06 — Contact | 一起聊聊 | 真实四项（微信/邮箱/电话/GitHub），与 `HUABI.contact` 两处同步 |

每个内容区顶部有 `▼ 内容区·XX ▼` 导引注释；改内容手册见 [CONTENT-GUIDE.md](CONTENT-GUIDE.md)。

`block-full` / `block-offset` 目前渲染无差别（`.block-offset{padding-left:0}`），是历史交替非对称布局的残留标记。

### 3.3 全局元素（在 main 之后）

- `<canvas id="fireworks">`：彩蛋画布，常驻 DOM，`.show` 才显示。
- `#pet`：**必须是 body 直属**——源码里有注释（锚点 `桌宠本体: 必须是 body 直属`）：若嵌进 z-index:100 的侧栏，其层叠上下文会封死 z，递送/彩蛋时永远压不过遮罩。内含 `#petCanvas`（真身）+ `display:none` 的 `.pet-svg`（**原版像素小人对照资产**，是 RECTS 数组的源头出处，别删——这是"角色本体不可改"红线的基准）。
- `#focusScrim` / `#petBubble`：遮罩与气泡，都由 pet() 控制。

## 4. JS 地图（一个 `<script>`，按出现顺序）

### 4.1 `HUABI` 配置层（锚点 `HUABI — 全站配置层`）

**改参数/文案/名单先来这里，不要翻正文逻辑。** 顶部第一项就是 `contact`（联系方式，桌宠名片卡数据源，与 footer 卡片两处同步）。刻意不外提的：渲染器深层数学常量（光照/AO/shear/S,D）、CSS token、体素资产 RECTS。

| 键 | 作用 | 已接线? |
|---|---|---|
| `pet.margin` | 桌宠与视口边最小间距 | ✅ |
| `pet.gazeSensitivity` | 视线跟随灵敏度（除数，越小越灵敏） | ✅ |
| ~~`pet.rail`~~ | ~~移动端左侧停靠轨道宽~~ | 🗑 **2026-07-10 晚已删除**（并发会话）：移动端桌宠改停「右缘、顶栏正下方」，不再需要轨道 |
| `pet.voiceCycleMs` | 心声轮播间隔 | ✅（2026-07-10 接线，值 34000 行为不变） |
| `pet.flashDefaultMs` | flash() 默认停留 | ✅ |
| `pet.blink` / `pet.idle` | 自发眨眼/待机动作的间隔与权重 | ✅ |
| `pet.voiceLines` / `pet.dragLines` | 心声/拖拽台词 | ✅ |
| `pet.emit` | 定向体素粒子参数（数量/大小/散布/时长/色板） | ✅ |
| `fireworks.ais` | 彩蛋 AI 名单（key 对应 `__AILOGOS`；可选 `scale/bg/emoji/logoKey`）。**海报"买一送N"由 `ais.length` 派生**，增删自动同步 | ✅ |
| `fireworks.palette/timing/poster` | 烟花色板 / 入场时序（stagger/dur/firstDelay/holdMs） / 海报署名 | ✅ |

### 4.2 小型 IIFE（锚点即注释标题）

| 锚点 | 职责 | 备注 |
|---|---|---|
| `── 滚动淡入 ──` | IntersectionObserver 给 `.reveal` 加 `.in` | 选择器已收敛为 `.reveal`（2026-07-10 整理） |
| `顶部滚动进度线` | scroll → `#progress` 宽度 | |
| `heroEntrance` | h1 拆 `.char` 逐字入场；双 rAF 后移除 `body.preload` | **所有开场动画的总开关**：`preload` 不移除页面就一直隐藏 |
| `光标环境光斑` | pointermove 缓动跟随（仅 `pointer:fine` 且非 reduce） | |
| `人物照片 3D 微视差` | ≤3° perspective 旋转 | |
| `photoFallback` | avatar.jpg 加载失败 → 显示插画兜底 | img 上还有内联 onerror 双保险 |
| `tocSpy` | rootMargin `-45%/-50%` 判定当前板块 → toc 高亮 + Huabi 瞟一眼；点击 → gaze+emit+hop | 平滑滚动交给 CSS `scroll-behavior` |

### 4.3 `huabiRenderer()` — 3D 体素渲染器（锚点 `Huabi 3D 体素桌宠渲染器`）

**压缩风格代码（单字母变量、无空格）——这是全文件最难读的一段，改前必读本节。**

渲染管线（构建期，只跑一次）：
1. `RECTS`：21 个 `[色,x,y,w,h]` = 原版 100×100 像素画（与隐藏 SVG 完全一致）。
2. → `grid[100][100]` 铺色 → 按 `S=2` 降采样成 `sil[50][50]` 剪影。
3. → 挤出 `D=6` 层深度，**只保留表面体素**（内部剔除）；每体素记 `{x,y,z,gx,gy,rgb}`。
4. **角色标注**：按颜色+原始坐标自动分类 `role: eye/glint/spark/cheek/foot/arm/body`；手臂另记 `side:L/R`。
5. 预计算：眼睛包围盒 `lE/rE`、嘴巴锚点（由眼睛推导）、AO（26 邻域暴露度 → `v.ao`）、包围半径。

每帧（`loop()`，rAF 驱动，`visibilitychange` 自动暂停/恢复）：
`updateAction()`（动作时间轴 → 手臂 shear 量/脚抬升/z 倾斜）→ `updatePhysics()`（跳跃弹性 + 惯性旋转 + 视线缓动）→ `draw()`（逐体素局部变形 `localPos` → 旋转 → 按 rz 画家排序 → 每面光照着色）。

关键机制（改动效必懂）：
- **手臂用剪切不用旋转**（锚点 `v.role==='arm'`）：`y += k*(x-xin)*dir`，内缘钉死贴身、外缘上抬——粗手臂刚性旋转必脱节。挥手 k≈0.5±0.28、欢呼 0.65（**88px 小尺寸下调大会变尖刺**，踩过坑）。
- **表情只重绘正脸**：`faceOverride(gx,gy)` 仅作用于 `z===ZFRONT` 体素的 +z 面；表情表 `EXPR = open/blink/happy/surprised/dizzy`（眼型 open/shut/arc/dot/x + 嘴 smile/o）。
- **光照**：Key/Fill 双向光 + 边缘光 + **正对镜头补光 `+0.30*max(0,rn.z)`**（没有它正面发暗，踩过坑）+ 顶面提亮 + AO + 饱和度 1.15。
- 星芒 `spark` 体素有独立闪烁相位 `twk`。

对外 API：`window.huabiPet = { blink, doAction(name), flashExpr(name,ms), setExpr(name), setGaze(x,y), setAuto(bool), resize }`
动作名：`hop / wave / cheer / walk / spin / hearts`（hearts= 比心飘珊瑚爱心）。
自发行为：`scheduleBlink`（2.6–6s）+ `scheduleIdle`（5–7.5s 按 `HUABI.pet.idle.weights` 加权随机）；`prefers-reduced-motion` 下全部关闭。

### 4.4 `pet()` — 桌宠行为编排（锚点 `(function pet(){`）

内部小系统（按锚点索引）：

| 锚点 | 系统 | 要点 |
|---|---|---|
| `computeHome` | 坞位 | 桌面 = `.pet-dock` 中心；移动端 = **右缘、塌缩顶栏正下方**（`max(顶栏底+12, 96)`，避开 hero 文案；`validPy` 保证气泡放得下） |
| `positionBubble` | 气泡定位 | **inSidebar 分支**：桌宠在侧栏内 → 气泡在其正上方、尾巴朝下；拖出侧栏 → 贴左/右边兜底 |
| `── 心声` | 台词 | 入场自我介绍 8s + 每 34s 轻声一句（写死，未用 voiceCycleMs）；`say/flash/hideBubble` |
| `── Huabi 反馈特效` | gazeTo/emitTo/react | 看向目标 / 发射 `HUABI.pet.emit` 体素粒子（双 rAF 触发过渡）/ 开心+动作 |
| `previewActionButton` | 按钮悬停预响应 | `.is-attentive` + 挥手 + 80ms 后说 `data-preview` |
| `── Focus 遮罩` | armDismiss 契约 | **弹出物统一关闭协议**：`armDismiss(fn)` 挂 pointerdown(捕获,260ms 防误触)+Esc；`disarmDismiss` 拆除；`forceDismiss` 给彩蛋抢占用 |
| `runCenterDelivery` | 递送状态机 | `deliveryActive` 重入护栏 → scrim + 叼纸片 + walk 走到屏幕中央偏左（工件卡零重叠站位）→ 到位回调；非桌面/reduce 直接回调(false) |
| `startResumeDelivery` | 简历递送 | 到位 → 弹简历纸卡 → **700ms 触发真下载**（`#resumeLink.click()`，兜底 close 时也触发一次，`downloaded` 防重）→ 3.6s 自动收 |
| `startContactDelivery` | 名片递送 | 到位 → `openContactNote()` 弹联系卡（值读 `HUABI.contact`）。**入口按钮已移除**，此链路成备用代码，勿删（恢复=加回按钮） |
| `returnFromDelivery` | 归位 | running 回坞 → 980ms 后清所有状态类 + `setAuto(true)` |
| `── 拖拽` | down/move/up | pointer 捕获；`moved>6px` 才算拖；松手 `runHome()` 小跑回坞；**轻点 = 摸摸它**（hop/hearts + "嘿嘿~"）；拖拽台词 1.4s 轮换 |
| `彩蛋召唤` | summonHuabiToFx | 彩蛋开启时**真身跑进海报 C 位**（fx-travel）；`returnHuabiFromFx` 关闭时跑回；兜底：非桌面/reduce 时在烟花画布里 `drawImage(petCanvas)` |
| `── 两大动作` | 按钮 click 委托 | resume→递送；fireworks→`forceDismiss()` 先解散在场弹出物 + 令牌飞行 + 220ms 后 `fireworks()`；`data-target`→联系递送（现无入口按钮） |
| `addEventListener('resize'` | 自适应 | 非活动态时重算坞位归位 |

暴露：`window.huabiFx = { gazeTo, emitTo, react }`（tocSpy 用）。

### 4.5 `fireworks()` — 彩蛋（定义在 pet() 内部，锚点 `AI 天团招募`）

时间轴（全部由 `HUABI.fireworks.timing` 驱动）：
```
t=0 显示暗色宇宙底 + 背景烟花开始发射
t=firstDelay(320) 起, 每 stagger(90ms) 一个 logo 从格位上方的烟花中"孵化",
   贝塞尔弧线弹入(dur=640ms each) + 光轨 + 落位冲击环
T_SETTLE = firstDelay + (N-1)*stagger + dur   → 海报文案+Huabi 聚光淡入
T_END = T_SETTLE + holdMs(15000)              → 自动关闭(海报上有倒计时)
随时: 点画布任意处 / Esc → close()
```
- `fxOn` 重入护栏；close() 撤销一切监听并让 Huabi 跑回侧栏。
- 海报标题 `录用冯贤宇 · 买一送{中文数字}` 由 `AIS.length` 派生（当前 14 → 十四）；注释里"买一送十二"是过时注释。
- logo 优先 `a.img`（从 `__AILOGOS[a.logoKey||a.key]` 预加载），缺失时兜底画 key 大写文本；`a.emoji` 分支支持 emoji 瓷砖。
- reduced-motion：静态海报 + 10s 自动关。
- 响应式 `layout()`：列数按宽度 7/5/4/3。

## 5. 全局契约（不变式清单——改任何东西前对一遍）

1. `#pet` 永远是 body 直属（z-index 层叠上下文契约）。
2. `.pet-dock` 有 `pointer-events:none`，桌宠可点是因为 `.pet{pointer-events:auto}`——别在侧栏上乱加 pointer-events。
3. 全屏 canvas（`#fireworks`）必须显式 `width/height:100%`——`inset:0` 对 replaced 元素不撑满（踩过坑）。
4. 弹出物（纸卡/名片/彩蛋）一律遵守 armDismiss 契约：点任意处/Esc 可关，且新弹出物出现前先 `forceDismiss()` 旧的。
5. 心声气泡在侧栏内永远在桌宠**上方**（不翻转不遮挡）。
6. 所有"用户可感的等待"都有自动超时（递送 3.6s、彩蛋 15s、气泡 2.2–8s）。
7. `html.js` / `body.preload` 双类控制开场：JS 挂了才有动画，preload 移除才开始播——无 JS 时页面直接全可见（优雅降级）。
8. `prefers-reduced-motion`：渲染器停自发行为、递送不走位直接出结果、彩蛋出静态海报。新交互必须补 reduce 分支。
9. 桌宠正面朝前不自转；只有拖拽甩动/「转圈」才 360°，完了回正（表情可读性契约）。

## 6. 其他文件

| 文件 | 角色 | git 状态 |
|---|---|---|
| `avatar.jpg` | 头像（已去背+美颜）。**注意**：兜底提示文案写的是 `avatar.png`，实际用的 jpg（文案漂移） | 已跟踪 |
| `resume.pdf` | 简历。固定文件名契约：换简历=覆盖此文件，代码不用改 | 已跟踪 |
| `更新简历.command` | 双击把「桌面最新 PDF」复制成 resume.pdf | 已跟踪 |
| `liftsubject.swift` / `framephoto.swift` | macOS Vision 抠图/裁剪小工具（生成头像用，非部署所需） | 已跟踪 |
| `mascot-lab.html` (+backup) | 桌宠 3D 的一次性开发预览台（S=1 全分辨率 + 表情/动作按钮面板）。**已 .gitignore，不提交**；渲染器改大了可以拿它对照，但注意它是旧快照 | 忽略 |
| `.nojekyll` | GitHub Pages 关 Jekyll（必须保留） | 已跟踪 |
| `README.md` | 面向用户的简版说明（更新简历/预览/部署） | 已跟踪 |
| `honors/`（待建） | 荣誉图墙图片目录（用户给图后创建，见 CONTENT-GUIDE §4） | — |
