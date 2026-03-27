# Agent Frontmatter 字段指南

Agent 定义文件：`.claude/agents/<name>.md`

## 完整字段一览

```yaml
---
name: hook-auditor                    # 必填，agent 唯一标识（kebab-case）
description: 当用户说"审查 hooks"时使用  # 必填，触发条件描述
tools: Read, Glob, Bash               # 可选，省略则继承所有工具
model: haiku                          # 可选：haiku / sonnet / opus / inherit
memory: project                       # 可选：user / project / local
skills:
    - hook-writing-guide              # 可选，预加载的 skill ID 列表
hooks:
    Stop:
        - hooks:
            - type: prompt
              prompt: "..."           # 可选，agent 生命周期 hook
---

系统提示正文（agent 的行为指令）
```

---

## skills — 预加载 Skill

```yaml
skills:
    - hook-writing-guide
    - another-skill
```

**机制**：agent 启动时，每个 skill 的完整 SKILL.md 内容被注入到上下文。

**关键点**：
- 值是 skill 的**目录名**（`.claude/skills/<id>/`），不是文件路径
- Subagent **不继承**父对话的 skills，必须显式列出
- 注入的是全文内容，agent 无需主动读取文件即可知晓

**验证方法**：触发 agent 后，观察它是否在没有读取规范文档的情况下直接应用了规范。

---

## memory — 持久记忆

```yaml
memory: project
```

| 值 | 存储位置 | 适用场景 |
|----|----------|----------|
| `user` | `~/.claude/agent-memory/<name>/` | 跨项目通用知识 |
| `project` | `.claude/agent-memory/<name>/` | 项目专用，可提交 git |
| `local` | `.claude/agent-memory-local/<name>/` | 项目专用，不提交 |

**机制**：
- 自动启用 `Write`、`Edit` 工具（即使 `tools:` 未列出）
- 记忆目录的 `MEMORY.md` 前 200 行在每次启动时注入上下文

**注意**：目录不会自动创建，首次使用前需手动 `mkdir -p`：
```bash
mkdir -p .claude/agent-memory/<agent-name>
```

**系统提示建议**：给出明确路径，而非自然语言描述：
```
# 建议（明确）
把发现写入 .claude/agent-memory/hook-auditor/MEMORY.md

# 不建议（模糊，可能写错位置）
把发现写入项目的 agent memory
```

---

## hooks — Agent 级生命周期 Hook

Agent frontmatter 里的 hooks 只在**该 agent 活跃时**生效，agent 结束后自动清理。

```yaml
hooks:
    PreToolUse:
        - matcher: "Bash"
          hooks:
              - type: command
                command: "./scripts/validate.sh"
    PostToolUse:
        - matcher: "Write|Edit"
          hooks:
              - type: command
                command: "./scripts/lint.sh"
    Stop:
        - hooks:
            - type: command
              command: "osascript -e 'display notification \"审查完毕\"'"
```

**Stop 事件特殊性**：
- 没有 `matcher`（无工具名可匹配），直接写 `hooks:` 子列表
- Agent frontmatter 里写 `Stop:`，系统自动转换为 `SubagentStop` 事件

**`type: prompt` vs `type: command` 在 Stop 中的区别**：

| 类型 | 适用场景 | Stop hook 中的效果 |
|------|----------|--------------------|
| `type: command` | 副作用操作（写文件、发通知、清理） | ✅ 正常执行 |
| `type: prompt` | 注入 Claude 上下文 | ⚠️ 可能丢失（agent 已结束，上下文关闭）|

**YAML 缩进要求**（容易出错）：

```yaml
# ✅ 正确
hooks:
    Stop:
        - hooks:
            - type: prompt        # `-` 比 `- hooks:` 的 `-` 多 4 格
              prompt: "..."       # 和 `type` 对齐

# ❌ 错误（type 与 hooks 同级）
hooks:
    Stop:
        - hooks:
        - type: prompt            # 变成了兄弟列表项
          prompt: "..."
```

---

## model — 模型选择

```yaml
model: haiku    # 快速省钱，适合简单任务（审查、格式化）
model: sonnet   # 均衡，适合大多数任务
model: opus     # 最强，适合复杂推理
model: inherit  # 继承父对话模型（默认）
```

---

## tools — 最小权限设计

```yaml
tools: Read, Glob, Bash    # 显式允许列表
```

`memory:` 开启时，`Write` 和 `Edit` 会自动追加，无需手动添加。

---

## 四个维度的组合

| 字段 | 解决的问题 |
|------|-----------|
| `skills:` | 知道什么（静态知识注入） |
| `memory:` | 记住什么（动态跨会话积累） |
| `hooks:` | 完成时做什么（生命周期自动化） |
| `tools:` | 能做什么（权限边界） |
