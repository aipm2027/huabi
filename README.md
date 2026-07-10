# huabi

冯贤宇的个人作品集网站(单文件),内置 AI 桌宠 **Huabi** 作为全站导航。

- `index.html` — 站点本体(HTML/CSS/JS,零依赖,浏览器打开即用)
- `avatar.jpg` — 头像(去背景 + 轻度美颜)
- `resume.pdf` — 简历(左栏「下载简历」按钮下载的就是它)
- `liftsubject.swift` / `framephoto.swift` — 生成头像用的 macOS Vision 抠图/裁剪小工具(可选,非部署所需)

## 更新简历
网站永远读取固定文件 **`resume.pdf`**,代码里不写死具体文件名,所以换简历**不用改代码**:
- 方式一:直接用新 PDF 覆盖 `~/huabi/resume.pdf`。
- 方式二(更省事):把新 PDF 放到**桌面**,双击 `更新简历.command`,它会自动把桌面最新的 PDF 复制成 `resume.pdf`。
- 下载时显示的文件名固定为 `冯贤宇-简历.pdf`(要改就改 `index.html` 里 `id="resumeLink"` 那行的 `download="…"`)。
- 部署时记得把 `resume.pdf` 一起提交/上传。

## 本地预览
用浏览器直接打开 `index.html`。

## 部署
纯静态站点,可托管到 GitHub Pages / Vercel / Cloudflare Pages。
