# Hook Development 学习笔记

## 是什么

Hook 是 Claude Code 的**事件钩子**——在特定时机自动触发逻辑，实现拦截、验证、自动化。

`plugin-dev:hook-development` 这个 Skill 是给 Claude 看的"参考文档"，
调用它 = 让 Claude 带着这份文档来帮你写 Hook。

---

## 两种实现方式

| 类型 | 写法 | 适用场景 |
|------|------|---------|
| **Prompt Hook**（推荐） | 自然语言描述判断逻辑 | 需要语义理解、灵活判断 |
| **Command Hook** | 执行 bash 脚本 | 确定性检查、文件操作、速度快 |

```json
// Prompt Hook
{ "type": "prompt", "prompt": "检查文件路径是否安全，返回 approve 或 deny" }

// Command Hook
{ "type": "command", "command": "bash $CLAUDE_PLUGIN_ROOT/scripts/validate.sh" }
```

---

## 9 个事件时机

| 事件 | 触发时机 | 常见用途 |
|------|---------|---------|
| `PreToolUse` | 工具执行**前** | 拦截危险操作（最常用） |
| `PostToolUse` | 工具执行**后** | 分析结果、日志 |
| `Stop` | Agent 准备停止时 | 检查任务是否真正完成 |
| `SubagentStop` | 子 Agent 停止时 | 同上，针对子 Agent |
| `UserPromptSubmit` | 用户提交消息时 | 添加上下文、过滤内容 |
| `SessionStart` | 会话开始时 | 加载项目上下文 |
| `SessionEnd` | 会话结束时 | 清理、保存状态 |
| `PreCompact` | 上下文压缩前 | 保留关键信息 |
| `Notification` | 发送通知时 | 日志记录 |

---

## hooks.json 结构

### 插件格式（`hooks/hooks.json`）：套一层 `"hooks"`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "prompt", "prompt": "检查写入安全性" }
        ]
      }
    ]
  }
}
```

### settings.json 格式：直接写事件名

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        { "type": "prompt", "prompt": "检查写入安全性" }
      ]
    }
  ]
}
```

---

## Hook 输入格式

所有 Hook 从 stdin 读 JSON：

```json
{
  "session_id": "abc123",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": { "file_path": "/etc/passwd" },
  "cwd": "/Users/me/project"
}
```

Command Hook 用 `jq` 读取：

```bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path')
```

---

## 决策返回值

| 场景 | 返回字段 | 可选值 |
|------|---------|--------|
| PreToolUse | `permissionDecision` | `allow / deny / ask` |
| Stop | `decision` | `approve / block` |
| Command Hook | 退出码 | `0`=通过 / `2`=拦截 |

```json
// PreToolUse 返回示例
{
  "hookSpecificOutput": { "permissionDecision": "deny" },
  "systemMessage": "路径包含 .. ，拒绝写入"
}

// Stop 返回示例
{ "decision": "block", "reason": "还没跑测试，不能停" }
```

---

## matcher 写法

```json
"matcher": "Write"            // 精确匹配（大小写敏感）
"matcher": "Write|Edit"       // 多个工具
"matcher": "*"                // 所有工具
"matcher": "mcp__.*__delete"  // 正则
```

---

## SessionStart 特殊能力

可以往会话注入环境变量，整个会话都能用：

```bash
echo "export PROJECT_TYPE=nodejs" >> "$CLAUDE_ENV_FILE"
```

其他事件没有这个能力。

---

## 关键限制

1. **修改后必须重启 Claude Code**，Hook 不支持热加载
2. **所有匹配的 Hook 并行执行**，不能依赖顺序
3. **路径必须用 `$CLAUDE_PLUGIN_ROOT`**，不能硬编码
4. **bash 变量必须加引号**，防止注入：`echo "$file_path"` 而非 `echo $file_path`

---

## 调试方法

```bash
# 开启 debug 模式
claude --debug

# 直接测试脚本
echo '{"tool_name":"Write","tool_input":{"file_path":"/test"}}' | bash validate.sh
echo "退出码: $?"
```
