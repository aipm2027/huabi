#!/bin/bash
# ─────────────────────────────────────────────────────────────
# 双击运行:把「桌面上最新的 PDF」更新为网站简历
# 网站永远读取 ~/huabi/resume.pdf 这个固定文件,代码不用改。
# 以后改简历:把新 PDF 放到桌面 → 双击本文件 → 刷新网页即可。
# ─────────────────────────────────────────────────────────────
cd "$(dirname "$0")"
latest=$(ls -t ~/Desktop/*.pdf 2>/dev/null | head -1)
if [ -z "$latest" ]; then
  echo "❌ 桌面上没有找到 PDF。请先把简历 PDF 放到桌面,再双击本文件。"
  read -n1 -r -p "按任意键关闭…"; exit 1
fi
cp "$latest" resume.pdf
echo "✅ 已更新网站简历:"
echo "   来源:$(basename "$latest")"
echo "   目标:~/huabi/resume.pdf  ($(du -h resume.pdf | cut -f1))"
echo ""
echo "刷新网页,点桌宠菜单「下载简历」就能下到最新版了。"
read -n1 -r -p "按任意键关闭…"
