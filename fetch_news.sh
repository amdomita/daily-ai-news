#!/bin/bash
# 每日AI资讯抓取脚本
cd /Users/a1315/daily-ai-news

TODAY=$(date +%Y-%m-%d)
FILE="${TODAY}.md"

# 如果今天已经生成过就跳过
if [ -f "$FILE" ]; then
    echo "Today's news already exists: $FILE"
    exit 0
fi

# 用claude抓取网页并生成资讯
cat << PROMPT | /Users/a1315/.local/bin/claude -p --model sonnet --allowed-tools "Bash WebFetch WebSearch" > "$FILE" 2>/dev/null
你是每日资讯助手。请完成以下任务：

1. 搜索最新资讯（${TODAY}），三个方向：
   - AI/人工智能：大模型发布、AI应用、AI开源项目
   - 开源软件：GitHub热门项目、重要版本发布、开源工具
   - 银行金融科技：银行数字化转型、金融AI应用、监管科技

2. 每个方向选取5-8条最有价值的资讯

3. 只输出markdown格式内容，不要任何多余的解释，格式如下：

# 每日AI与科技资讯 - ${TODAY}

## AI/人工智能
- **标题** — 简要摘要（来源）

## 开源软件
- **标题** — 简要摘要（来源）

## 银行金融科技
- **标题** — 简要摘要（来源）

注意：资讯必须真实准确。
PROMPT

# 检查是否生成成功
if [ -s "$FILE" ]; then
    # 自动重建index.md（按日期倒序列出所有资讯）
    cat > index.md << 'HEADER'
# 每日AI与科技资讯

> 每天早上9点自动更新 | AI/人工智能 · 开源软件 · 银行金融科技

> 订阅方式：点右上角 **Watch** 或 RSS订阅 `https://github.com/amdomita/daily-ai-news/commits/main.atom`

---

HEADER
    for f in $(ls -r [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md 2>/dev/null); do
        d="${f%.md}"
        echo "- [${d}](${f})" >> index.md
    done

    git add "$FILE" index.md
    git commit -m "Daily AI News - ${TODAY}"
    git push
    echo "Success: ${FILE} pushed to GitHub"
else
    rm -f "$FILE"
    echo "Failed to generate news"
    exit 1
fi
