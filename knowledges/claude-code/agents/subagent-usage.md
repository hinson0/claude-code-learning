# Claude Code Subagent 使用指南

## Agent 工具核心参数

```
Agent(
  description: str,          # 必填，3-5 词任务摘要
  prompt: str,               # 必填，给 agent 的完整上下文和任务
  subagent_type: str,        # 自定义 agent 的 name（对应 .claude/agents/*.md 文件名）
  run_in_background: bool,   # 默认 false（前台阻塞）
  isolation: "worktree",     # 可选，在独立 git worktree 中运行
  model: "haiku|sonnet|opus" # 可选，覆盖 agent 定义中的 model
)
```

## 前台 vs 后台对比

```
前台：调用后等待结果，结果直接返回给主对话
后台：立即返回 agentId，通过 task-notification 通知完成
```

后台 agent 完成时收到：
```xml
<task-notification>
  <task-id>...</task-id>
  <status>completed</status>
  <result>agent 的完整输出</result>
</task-notification>
```

## 继续已有 Agent

```
SendMessage(to: "<agentId>", message: "继续任务...")
```

Agent 保留完整上下文继续执行，不重新启动。

## 工具权限设计（最小权限原则）

| 场景 | 推荐工具集 |
|------|-----------|
| 只读代码研究 | Read, Grep, Glob |
| 本地全功能研究 | Read, Grep, Glob, Bash |
| 网络情报收集 | WebSearch, WebFetch |
| 代码修改 | Read, Edit, Write, Bash |
| 全功能 | 不限制（慎用） |

受限工具集是防御提示注入的有效手段。

## Agent 触发机制

Claude 根据 `description` 中的文字和 `<example>` 场景自动决定调用哪个 agent。
描述写得越具体、场景越典型，触发越准确。

## 记忆持久化

```yaml
memory: project
```

记忆目录：`.claude/agent-memory/<agent-name>/`
跨会话保留，适合需要记住用户偏好的 agent（如天气、写作偏好）。
