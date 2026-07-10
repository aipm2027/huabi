# REFACTOR-PLAN — 代码整理方案（✅ 2026-07-10 已执行主体，见执行记录）

> 本文回答「这份代码怎么重新整理，后续维护起来更好改」。
> 执行时**严格按阶段推进，一次一个阶段，做完验收再进下一阶段**。禁止跳阶段、禁止顺手多改。

## ⓿ 执行记录（2026-07-10）

| 阶段 | 状态 | commit |
|---|---|---|
| P1 死代码清理（全部 12 项；P1.13 __AILOGOS doubao 保留未删） | ✅ | `P1 整理: 死代码清理` |
| P2 注释对齐（全部 5 项，含 avatar.png→jpg 用户可见文案） | ✅ | `P2 整理: 注释与实况对齐` |
| P3.1 缩进统一（349 行行首 tab→2空格，`git diff -w` 为空） | ✅ | `P3.1 整理` |
| P3.2 联系方式单源（`HUABI.contact` + footer 注释互指） | ✅ | `P3.2/P3.4/P4/P5` |
| P3.3 分区 banner 规范化 | 部分（现状已基本两级，未强推） | — |
| P3.4 珊瑚 rgba 归拢 | 方案 a（:root 换色须知注释） | 同上 |
| P4 窗口对象清单内联 | ✅ | 同上 |
| P5（新增）内容区 `▼ 内容区·XX ▼` 导引注释 + docs/CONTENT-GUIDE.md | ✅ | 同上 |

**执行中发现（重要）**：§6 设想的"逐像素等价"验收在本机不可行——空白对照实验（同代码连拍两张）差异 ~5%，存在随机 1px 整页位移；且 Google Fonts 经代理时通时断导致字体条件不定（对比需 `--host-resolver-rules` 屏蔽字体域名）。验收实际采用：目测关键区 + dump-dom 功能自检 + `git diff -w`（缩进步骤）。

---

## 0. 总原则

1. **渲染零变化**是每个阶段的验收底线：整理前后截图必须逐像素等价（验收方法见 §6）。
2. 保持**单文件**。评估过拆分（§7），结论：**不拆**。单文件是这个项目的产品身份（"浏览器直开的一个文件"），且 2000 行在良好分区注释下完全可维护。
3. 每个阶段独立成一个 commit，message 写清「渲染不变」；出问题可单独 revert。
4. 动手前 `git status`；工作区有别人未提交的活时**不开工**。

## 1. 阶段 P1 — 死代码清理（无风险，收益最大）

以下每一项都已核实"HTML 无引用、JS 无引用"（2026-07-10 工作区版本）。删除前请用给出的 grep 复核一遍（防止后续代码又用回去了）。

### P1.1 CSS 死块

| # | 删什么 | grep 锚点 | 复核命令（应无 HTML/JS 引用） |
|---|---|---|---|
| 1 | `.brand` `.brand-name` `.brand-tag` 三条规则 | `.brand {` | `grep -n 'class="brand' index.html` → 无 |
| 2 | `.sidebar-status` 规则 + 860px 媒体查询里的 `.sidebar-status { display: none; }` | `.sidebar-status` | `grep -n 'sidebar-status' index.html` → 只剩 CSS 两处 |
| 3 | `.pet-hint` 三条规则 + `@keyframes hintArrow` + reduced-motion 里 `.pet-hint .arrow` | `.pet-hint` | 同上法 |
| 4 | `.about-grid` `.about-text p` `.about-text p strong` + 860px 里 `.about-grid { … }` | `.about-grid` | 板块已删 |
| 5 | `.float` `.float-dot` `.float-text strong` + `html.js .portrait .float`、`html.js .preload .portrait .float` 两条入场规则 | `.float {` | hero 浮标已删 |
| 6 | `html.js .skills .skill-card, html.js .explore .exp-card` 一整段入场规则（含 6 条 nth-child 延迟）+ 860px 里 `.skills`/`.explore` 两行 | `html.js .skills` | 板块已删 |
| 7 | `.exp-tbd h3` `.exp-tbd p` 两行 | `.exp-tbd` | 探索卡已删 |
| 8 | 组合选择器瘦身：`.hero h1, .block h2, .skill-card h3, .exp-card h3, .item-body h3 { text-wrap: balance; }` 里去掉 `.skill-card h3, .exp-card h3` | `text-wrap: balance` | 保留其余三个 |

### P1.2 HTML 死属性

| # | 删什么 | 说明 |
|---|---|---|
| 9 | `<body class="no-anim no-translate preload">` 里的 `no-anim no-translate` | 全文件无任何 CSS/JS 引用这两个类（Claude 生成器时代的残留）。**`preload` 必须保留**（开场动画开关） |

### P1.3 JS 死代码

| # | 改什么 | 说明 |
|---|---|---|
| 10 | `document.querySelectorAll('.reveal, .skills, .explore')` → `'.reveal'` | `.skills/.explore` 已无匹配元素 |
| 11 | fireworks() 里 `el.classList.add('hopping'); setTimeout(…remove('hopping'),500)` 两句删除 | `.hopping` 无对应 CSS，纯 no-op |
| 12 | `HUABI.pet.voiceCycleMs: 5200` | 未接线的配置。**二选一**：a) 删掉该键；b) 把值改成 34000 并把 pet() 里写死的 `34000` 替换为 `HUABI.pet.voiceCycleMs`（行为不变的接线）。推荐 b（配置层承诺"单一数据源"） |
| 13 | （可选）`window.__AILOGOS` 里的 `"doubao"` 条目 | 名单未用它（Seedance 用的是 volcengine）。删了省 ~1KB；留着当备用也无害。**注意这一行是超长单行，必须用脚本改，不要手编** |

### P1.4 不要删的"疑似死代码"（有人可能误判）

- `#pet` 里 `display:none` 的 `.pet-svg`：**原版像素资产对照**，是"角色不可改"红线的基准，保留。
- `.photo-fallback` / `.avatar-illo`：头像加载失败的兜底，运行时用得上。
- `.block-full` / `.block-offset`：目前渲染无差别，但它是板块节奏的语义标记，删除要连 HTML 一起动，收益低——留着。
- `mascot-lab.html`（未跟踪）：开发预览台，留在磁盘、不提交。

## 2. 阶段 P2 — 注释与实况对齐（零风险，防误导）

过时注释对"不太聪明的接手 AI"是毒药，逐条修正：

| # | 位置（grep 锚点） | 现状 | 改成 |
|---|---|---|---|
| 1 | CSS 头部 banner `取向 A · 编辑非对称` | "紫 #6d5cff 唯一主色用狠，绿 #16e0a3 仅状态点，珊瑚 #D97757 仅桌宠" | "珊瑚 #D97757 全站唯一强调色（呼应桌宠），绿 #16e0a3 仅状态点"（紫色现仅存在于烟花色板） |
| 2 | JS 头部目录 `目录: 打字机` | 列了已删除的"打字机" | 改为实际目录：滚动揭示 · 进度线 · Hero 逐字入场 · 光斑/视差 · 3D 体素渲染器 · 桌宠编排(pet) · 彩蛋(fireworks) · tocSpy |
| 3 | `「录用冯贤宇 · 买一送十二」` | 数字写死在注释里，实际由名单长度派生（当前十四） | 改为 "买一送N（由 HUABI.fireworks.ais.length 派生）" |
| 4 | `.fallback-hint`（HTML 文案） | "放一张去背的 `avatar.png`" | 改成 `avatar.jpg`（与 `<img src="avatar.jpg">` 一致）。⚠️ 这是用户可见文案，属最轻微的渲染变化，单独提交 |
| 5 | `README.md` 与 `更新简历.command` | 还在说"桌宠菜单「下载简历」" | 菜单已改为左栏常驻按钮，措辞同步 |

## 3. 阶段 P3 — 一致性整备（低风险，需细心）

1. **缩进统一**：JS 递送系统一带（`triggerActionButton` 到 `── 三大动作` 之间）混用 tab 与空格（多轮 AI 接力的产物）。统一为 2 空格。⚠️ 这是全文件 diff 最大的一步，务必单独提交、用「忽略空白 diff」自查逻辑无变化（`git diff -w` 应为空）。
2. **联系方式双源合一**：`footer#contact` 的卡片值与 JS `openContactNote()` 的 `row(…,'待补充')` 是两份数据。方案：在 `HUABI` 里加
   ```js
   contact: { wechat: '待补充', mail: '待补充', phone: '待补充', github: '待补充' }
   ```
   `openContactNote()` 从这里读；footer 的静态 HTML 保留（SEO/无 JS 可见性需要），但在 HUABI.contact 旁加注释「改联系方式两处同步：这里 + footer .contact-grid」。（做不到全自动单源是单文件静态站的合理妥协——footer 必须是真 HTML。）
3. **分区 banner 注释规范化**：CSS 与 JS 的分区注释现在有 `═══`、`──`、`/* */` 单行三种风格。统一为两级：
   ```
   /* ═══ 一级分区: 名称 ═══ */        （CSS 大区 / JS 每个 IIFE）
   /* ── 二级: 子系统名 ── */
   ```
   并保证每个一级分区名与 docs/ARCHITECTURE.md 的表格用词一致（文档即索引）。
4. **硬编码珊瑚 rgba 归拢（可选，谨慎）**：全文件 ~28 处 `rgba(217,119,87,…)`（2026-07-10 晚计数，执行前用 `grep -o 'rgba(217,119,87' index.html | wc -l` 重数）。若换主色会很痛。方案 a) 保持现状 + 在 :root 注释里写明"换主色需全局替换 217,119,87"；方案 b) 引入 `--coral-rgb: 217,119,87` 并把所有处改为 `rgba(var(--coral-rgb),…)`。推荐 **a**（b 的 diff 大、收益只在"将来换色"这个低概率事件）。

## 4. 阶段 P4 — 结构文档内联（可选）

在 `<script>` 目录注释下补一段 10 行左右的「窗口对象清单」：
```
window.huabiPet — 渲染器 API (blink/doAction/flashExpr/setExpr/setGaze/setAuto/resize)
window.huabiFx  — 行为反馈 API (gazeTo/emitTo/react), tocSpy 依赖
window.__AILOGOS — 彩蛋 logo 资产 (head 里内联)
HUABI            — 全站配置层 (文案/名单/时序/参数)
```
让不读 docs/ 的人也能在源码内自查。

## 5. 明确不做的事（Non-goals）

- ❌ 拆分文件（见 §7）
- ❌ 引入构建工具 / minify / TypeScript / 框架
- ❌ 重写渲染器为"更可读"的风格——它是精调过的性能敏感代码，重写极易破坏光影/形体，且有像素级验收成本
- ❌ 把体素资产 RECTS 挪出渲染器（作者刻意内聚，见源码注释）
- ❌ "顺手"改视觉设计——视觉改动永远是独立需求，须用户发起

## 6. 每阶段的验收流程（缺一不可）

```bash
# 1) 改动前基线（确定性渲染：掐动画 + 桌宠显形）
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
snap() {  # $1=输出文件
  "$CHROME" --headless --disable-gpu --window-size=1440,2600 \
    --virtual-time-budget=9500 --screenshot="$1" \
    "file:///Users/admin/huabi/index.html"
}
snap /tmp/before.png
# 2) 施工
# 3) snap /tmp/after.png && 目测 + 像素对比:
python3 -c "
from PIL import Image, ImageChops
d=ImageChops.difference(Image.open('/tmp/before.png').convert('RGB'),Image.open('/tmp/after.png').convert('RGB'))
print('bbox:', d.getbbox())"   # None = 逐像素一致
# (若本机无 PIL: sips/compare 目测两图, 或临时 pip install pillow)
```
- 桌宠动效帧不参与像素对比（rAF 相位随机）；对比前可注入 CSS 冻结（MAINTENANCE §4.1）。若嫌麻烦，P1/P2 纯删除类改动允许"目测 + 功能自检清单（MAINTENANCE §4.4）"代替像素对比，但 P3.1 缩进统一必须 `git diff -w` 为空。
- 彩蛋/递送涉及的改动追加 CDP 实时截图验证（MAINTENANCE §4.2）。

## 7. 附：拆分方案评估（为什么不拆）

考虑过的形态：`index.html` + `styles.css` + `app.js` + `ailogos.js`。

| 维度 | 单文件（现状） | 拆分 |
|---|---|---|
| `file://` 直开 | ✅ 双击即用 | ✅ 也能用（相对路径），但少数浏览器安全策略下有坑 |
| 部署 | ✅ Pages 零配置 | ✅ 相同 |
| 可读性 | 靠分区注释 + docs/（本次已补齐） | 文件级隔离，略优 |
| AI 编辑安全性 | Edit 精确匹配偶有长行/缩进坑 | 文件小了匹配更稳，略优 |
| 产品身份 | ✅ "一个文件就是整站"是卖点（footer 都写着"零依赖"） | ❌ 失去 |
| 迁移风险 | — | 中：`__AILOGOS` 加载顺序、`html.js` 时序、CSP/编码细节 |

**结论：维持单文件。** 可读性问题用「分区注释规范（P3.3）+ docs/ 地图」解决，性价比远高于拆分。若未来文件涨破 ~4000 行或多人/多 AI 高频撞车，再重启本评估。

## 8. 给执行者的最后提醒

- 每阶段开工前重读根目录 CLAUDE.md 的红线。
- 本方案基于 2026-07-10 的工作区快照；若执行时 `git log` 已有新提交，先 diff 快照差异、更新本文档，再动手。
- 改超长行（`__AILOGOS`）用 python 脚本替换并校验行长变化，不要用编辑器手改。
- 做完记得同步更新 docs/ 里受影响的表格（文档也是代码的一部分）。
