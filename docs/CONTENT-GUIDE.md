# CONTENT-GUIDE — 内容修改手册（给接手的 AI，照抄即可）

> **你大概率只需要这一篇。** 本手册覆盖"改简历内容/换图/改联系方式"这类高频任务，每个任务给出精确步骤和可复制模板。
> 涉及样式、桌宠、动画、结构的任务 → 先读 [ARCHITECTURE.md](ARCHITECTURE.md)，别猜。
> 红线见根目录 [CLAUDE.md](../CLAUDE.md)。**最重要的三条**：动手前 `git status`；只改文字不改 class 名和标签结构；改完必须验证（§7）。

---

## 1. 页面结构 30 秒速览

全站只有一个文件 `index.html`。内容都在 `<body>` 的 `<main>` 里，每个区块开头有 `▼ 内容区·XX ▼` 注释导引（直接搜索这个符号能跳到每个可改区）：

| 区块 | 搜索定位 | 里面是什么 |
|---|---|---|
| Hero 开场 | `▼` 无（搜 `hero-text`） | 名字 / 一句话 / 简介两段 |
| 教育背景 | `▼ 内容区·教育背景` | 时间线条目 `.item` |
| 实习经历 | `▼ 内容区·实习经历` | 时间线条目（内含子项目分组） |
| 项目经历 | `▼ 内容区·项目经历` | 卡片 `.proj-card`，一卡一项目 |
| 创业经历 | `▼ 内容区·创业经历` | 全宽卡 `.venture-card` |
| 荣誉奖项 | `▼ 内容区·荣誉图墙` | 图墙 `figure.honor-tile`，一图一格 |
| 联系方式 | `▼ 内容区·联系方式` | 四张卡 + ⚠ JS 里还有一份（§5） |

## 2. 改一段文字

直接改标签里的中文/英文，**别动标签名、class、属性**。要强调某个数字/关键词：包一层 `<strong>…</strong>`（自动变深色加粗）。

## 3. 加 / 删条目

**删**：整块删掉（从开标签到对应的闭标签）。
**加**：复制对应模板，改文字。模板：

### 教育 / 实习（时间线条目）
```html
<div class="item">
  <div class="when">2023.9 — 2027.6</div>
  <div class="item-body">
    <h3>标题（学位·专业 或 公司·职位）</h3>
    <div class="org">机构（学校 或 团队·方向·地点）</div>
    <p>一句话描述。</p>
    <ul>
      <li>要点，量化结果包 <strong>加粗</strong>。</li>
    </ul>
    <div class="item-tags"><span class="tag">关键词</span><span class="tag">关键词</span></div>
  </div>
</div>
```
实习条目里给多个子项目分组：在 `item-body` 里用 `<div class="item-sub">子项目标题</div>` + 各自的 `<ul>`（见现有小鹏条目）。

### 项目（卡片）
```html
<article class="proj-card">
  <div class="pc-kicker">2026 · 来源/类型</div>
  <h3>项目名称</h3>
  <p>一句话价值。</p>
  <ul><li>要点。</li></ul>
  <div class="item-tags"><span class="tag">关键词</span></div>
  <a class="pc-link" href="https://链接" target="_blank" rel="noopener">链接文字<span class="arr" aria-hidden="true">↗</span></a>
</article>
```
没有链接就删掉整行 `<a class="pc-link"…>`。占位空卡片：class 写成 `proj-card proj-tbd`（虚线空态）。

### 荣誉图墙（一格）
```html
<figure class="honor-tile">
  <div class="ht-frame"><img src="honors/文件名.jpg" alt="图片说明"></div>
  <figcaption><b>标题</b>小字说明</figcaption>
</figure>
```

## 4. 荣誉图墙换图（用户给图后的标准流程）

1. 建 `honors/` 目录（若无），图片放进去。文件名用英文小写，如 `ruanzhu-1.jpg`。
2. 找到对应 `figure`（按 figcaption 里的名字认）。
3. 把 `<div class="ht-ph">…（含 svg）…</div>` **整个**换成 `<img src="honors/文件名.jpg" alt="说明">`。
4. 把外层 `<div class="ht-frame ht-empty">` 里的 ` ht-empty` 删掉。
5. 竖版证书在「证书」组（3:4 裁切）、横版照片在「现场」组（4:3 裁切），放错组会被裁得难看。图片默认 `object-fit: cover` 居中裁切。
6. **图片文件也要 `git add`**，否则线上 404。

## 5. 改联系方式（⚠ 有两处，都要改）

1. **页脚卡片**：搜 `▼ 内容区·联系方式`，改四张卡的 `.cc-value` 文字；邮箱/电话卡还要同步 `<a>` 上的 `href="mailto:…"` / `href="tel:…"`。
2. **JS 配置**：搜 `HUABI.contact`（文件上部 `const HUABI = {` 里），改 `contact: { wechat, mail, phone, github }` 的值。

## 6. 其他高频

| 任务 | 做法 |
|---|---|
| 换简历 | 新 PDF 覆盖 `resume.pdf`（或桌面放 PDF 双击 `更新简历.command`），代码不用改；记得 git add + push |
| 换头像 | 覆盖 `avatar.jpg`（4:5 竖构图最佳） |
| 改桌宠台词 | `HUABI.pet.voiceLines`（心声）/ `dragLines`（拖拽时） |
| 改 hero 那句"让左边的 AI 助手…" | 搜 `dir-d`：桌面版文案在 `.dir-d`，手机版在 `.dir-m`（手机上桌宠停右上角，所以方位词不同——改的时候两个都看一眼） |
| bio 里的「多年」 | 是软占位，用户给真实年限后替换 |

## 7. 改完必须验证（一条命令）

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CHROME" --headless --disable-gpu --hide-scrollbars --window-size=1440,5200 \
  --virtual-time-budget=9500 --screenshot=/tmp/check.png \
  "file:///Users/admin/huabi/index.html"
```
然后用 Read 工具看 `/tmp/check.png`，检查：改的地方对不对、页面有没有塌、左栏桌宠还在不在。
**已知事实**：本机截图有随机 1px 整页位移，**逐像素对比不可用**——肉眼看关键区域即可。budget 别低于 9000（桌宠入场慢，低了会截到半透明假象，不是你改坏了）。

## 8. 出错回滚

```bash
cd ~/huabi && git status          # 看改了什么
git diff index.html               # 看具体差异
git checkout -- index.html        # 全部撤销，回到上次提交
```

## 9. 不许做的事（违反 = 返工）

- ❌ 改/删任何 class 名、id、`data-*` 属性
- ❌ 动 `<script>` 里除 `HUABI` 配置外的代码
- ❌ 动桌宠（形状/颜色/动画）、彩蛋、下载简历按钮
- ❌ 引入任何外部库/CDN/构建工具
- ❌ 编造用户没提供的个人信息（宁可留占位）
- ❌ 未经用户要求 commit / push
