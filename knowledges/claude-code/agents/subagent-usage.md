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

## Agent 安全设计模式：双层防护

以 `db-reader` 为例，只读约束通过两层实现：

```
第一层：系统提示（LLM 自我约束）
  → agent 理解"只读角色"，主动拒绝 INSERT/UPDATE/DELETE 请求
  → 对"善意 LLM"有效，代价几乎为零

第二层：PreToolUse Hook（硬性拦截）
  → validate-readonly-query.sh 扫描 SQL 关键词
  → 发现写操作立即 exit 2，无论 LLM 怎么想
  → 对"不守规矩"或被注入攻击的 LLM 也有效
```

**关键观察**（来自实测）：
- CRUD 测试中，LLM 在系统提示层就拒绝了写操作，hook **从未被触发**
- 这说明第一层通常够用；第二层是"不信任 LLM"时的兜底
- Hook 的价值：**不依赖 LLM 的自我约束**，防止提示注入绕过

```
防御深度 = 系统提示（语义约束）+ Hook（代码约束）
```

---

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
