# Agent 学习笔记

## 什么是 Agent

Agent（子智能体）是独立运行的 Claude 实例，拥有专属的工具集和系统提示词。适合处理需要专业知识的独立任务。

## 文件位置

`.claude/agents/<agent-name>.md`

## 必需的 frontmatter 字段

```yaml
---
name: agent-name          # kebab-case 标识名
description: |            # 触发描述，含 <example> 场景
  描述何时使用此 Agent...
tools:                    # 可用工具列表
  - Read
  - WebSearch
model: sonnet             # haiku/sonnet/opus
color: cyan               # 终端显示颜色
memory: project           # 开启项目级记忆
---
```

## 已有 Agent 示例

参见 `.claude/agents/`：

| Agent | 用途 | 工具限制 |
|-------|------|---------|
| `ai-trend-observer` | AI 前沿动态追踪 | WebSearch, WebFetch |
| `weather-report-master` | 天气查询与报告 | 全工具集 |
| `writing-master` | 多文体内容创作 | Read/Write/WebSearch |
| `emotion-counselor` | 情感支持 | 含 MCP 工具 |
| `code-reviewer` | 代码审查 | 只读（Read/Glob/Grep） |
| `safe-researcher` | 受限研究 | Read, Grep, Glob, Bash |

---

## 如何在主对话中调用 Agent（Agent 工具）

Claude Code 通过内置 `Agent` 工具在主对话中启动子 Agent。

### 基本参数

```
Agent(
  description: "3-5词的任务描述",   # 必填
  prompt: "给 agent 的完整任务描述", # 必填
  subagent_type: "safe-researcher",  # 指定自定义 agent 的 name
  run_in_background: false,          # true=后台运行，false=前台等待结果
  isolation: "worktree",             # 可选：在独立 git worktree 中运行
)
```

### 前台 vs 后台

| 模式 | 参数 | 适用场景 |
|------|------|---------|
| 前台（默认） | `run_in_background: false` | 需要结果才能继续下一步 |
| 后台 | `run_in_background: true` | 可以并行做其他事，完成后收到 task-notification 通知 |

### 后台 Agent 的生命周期

```
1. 调用 Agent(run_in_background: true)
   → 返回 agentId 和 output_file 路径

2. 主对话继续处理其他任务（不要 sleep 或轮询）

3. 收到 <task-notification> 时 agent 已完成
   → result 字段包含 agent 的输出

4. 如需继续同一个 agent：
   SendMessage(to: "<agentId>", ...)
```

### 追踪后台 Agent 进度

```bash
# 用 Bash tail 查看实时输出（不要反复调用 Read）
tail -f /private/tmp/claude-501/.../tasks/<agentId>.output
```

---

## 最小权限设计原则

Agent 的 `tools` 字段决定其能力边界，遵循最小权限原则：

```yaml
# 只读研究 agent — 即使被提示注入也无法破坏文件
tools: Read, Grep, Glob, Bash

# 代码审查 agent — 不能写文件，只能读
tools: Read, Glob, Grep

# 网络研究 agent — 只能上网，不能读写本地文件
tools: WebSearch, WebFetch
```

**好处：** 即使 agent 被恶意提示词注入（prompt injection），受限工具集能防止最坏情况发生。

---

## Agent 记忆系统

在 frontmatter 中添加 `memory: project` 开启持久化记忆：

```yaml
memory: project
```

记忆文件自动存储在 `.claude/agent-memory/<agent-name>/` 目录，跨会话保留上下文（如用户偏好、历史查询城市等）。
