# Hook 学习笔记

## 什么是 Hook

Hook 是 Claude Code 的事件钩子机制，在特定时机自动执行 Shell 脚本。可以用来拦截危险操作、自动化流程、记录日志等。

## Hook 事件类型

| 事件 | 触发时机 | 典型用途 |
|------|---------|---------|
| `PreToolUse` | 工具执行**前** | 拦截危险命令、校验参数 |
| `PostToolUse` | 工具执行**后** | 自动格式化、检查结果 |
| `Stop` | Claude 停止响应时 | 系统通知、语音提示 |
| `SessionStart` | 会话启动时 | 注入上下文、写日志 |
| `UserPromptSubmit` | 用户提交提示词时 | 输入校验、上下文增强 |

## Hook 输入（stdin JSON）

每个 Hook 通过 stdin 接收 JSON 数据，用 `jq` 解析：

```json
{
  "session_id": "会话ID",
  "transcript_path": "会话记录文件路径",
  "cwd": "当前工作目录",
  "permission_mode": "权限模式",
  "hook_event_name": "事件名（如 PreToolUse）",
  "tool_name": "工具名（如 Bash、Read、Edit、Write）",
  "tool_input": { "工具的完整输入参数" },
  "tool_use_id": "本次调用的唯一ID"
}
```

不同工具的 `tool_input` 结构：
- **Bash**: `{ command, description }`
- **Read**: `{ file_path }`
- **Edit**: `{ file_path, old_string, new_string }`
- **Write**: `{ file_path, content }`

## Hook 输出（控制行为）

- `exit 0` — 放行，允许工具执行
- `exit 2`（非零） — 拦截，阻止工具执行
- 输出 JSON 可提供更精细的控制：

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "拒绝原因"
  }
}
```

## 注册方式

在 `.claude/settings.json` 中注册：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
```

- `matcher` 用正则匹配工具名（`.*` 匹配所有）
- `$CLAUDE_PROJECT_DIR` 指向项目根目录

## 本目录示例

| 文件 | 事件 | 功能 |
|------|------|------|
| `block-rm.sh` | PreToolUse | 拦截 `rm -rf` 命令 |
| `protect-files.sh` | PreToolUse | 保护 `.env`、`package-lock.json`、`.git/` 不被修改 |
| `dump-input.sh` | PreToolUse | 将完整 stdin JSON 记录到日志（调试用） |
| `echo.sh` | SessionStart | 会话启动时追加日志 |
| `hook-input-dump.json` | — | dump-input.sh 的输出结果示例 |
