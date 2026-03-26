# Plugin Settings 学习笔记

## 是什么

插件可以将配置保存在项目的 `.claude/plugin-name.local.md` 文件中。
Hook / Agent / Command 读取这个文件，实现**每个项目独立配置**的效果。

---

## 为什么需要它

Hook 一旦注册就一直生效，改 `settings.json` 还要重启。
有了配置文件，只需改一行 `enabled: false` 就能临时关掉 Hook，不用动任何脚本。

---

## 文件结构

```
.claude/plugin-name.local.md
```

```markdown
---
enabled: true
mode: standard
max_retries: 3
---

# 可选的 Markdown 正文
用来放提示词、说明、任务描述等。
```

- **frontmatter**：YAML，存结构化配置（开关、参数）
- **正文**：Markdown，存提示词或补充说明（可选）

---

## Hook 中读取配置的固定套路

```bash
#!/bin/bash
STATE_FILE=".claude/my-plugin.local.md"

# 1. 文件不存在 → 直接放行（未配置视为跳过）
[[ ! -f "$STATE_FILE" ]] && exit 0

# 2. 解析 frontmatter（两个 --- 之间的内容）
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")

# 3. 读取字段
ENABLED=$(echo "$FRONTMATTER" | grep '^enabled:' | sed 's/enabled: *//')
MODE=$(echo "$FRONTMATTER" | grep '^mode:' | sed 's/mode: *//')

# 4. 未启用 → 放行
[[ "$ENABLED" != "true" ]] && exit 0

# 5. 以下是真正的 Hook 逻辑
echo "mode=$MODE"
```

---

## 读取正文（Markdown body）

```bash
# 取第二个 --- 之后的所有内容
BODY=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")
```

常见用途：把正文作为提示词喂回给 Claude（ralph-loop 插件的做法）。

---

## 常见使用场景

| 场景 | 配置文件的作用 |
|------|--------------|
| 临时关掉 Hook | `enabled: false` |
| 多 Agent 协调 | 存任务编号、coordinator 会话名 |
| 参数化行为 | 存模式（strict/standard/lenient）、限制值 |
| 循环任务（ralph-loop） | 正文作为提示词，frontmatter 存迭代计数 |

---

## 注意事项

- 文件改完**必须重启 Claude Code** 才生效（Hook 不支持热加载）
- `.local.md` 后缀代表本地私有，加入 `.gitignore`：
  ```gitignore
  .claude/*.local.md
  ```
- 文件不存在时给出合理默认值，不要直接报错退出
