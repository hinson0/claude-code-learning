# Prompt Hook 学习笔记

## 什么是 Prompt Hook

Hook 有两种类型：

| 类型 | 字段 `type` | 执行方式 |
|------|------------|---------|
| Shell Hook | `"command"` | 执行一个 Shell 脚本，通过 exit code 控制放行/拦截 |
| Prompt Hook | `"prompt"` | 用自然语言描述规则，由 Claude 判断是否放行 |

Prompt Hook 不需要写脚本，直接用中文描述检查逻辑。

## 注册方式

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "检查 $TOOL_INPUT 中的 bash 命令是否包含 rm（包括 rm、rm -r、rm -rf 等变体）。\n\n如果命令包含 rm，直接输出：{\"ok\": false, \"reason\": \"拦截原因\"}\n\n如果命令不包含 rm，直接输出：{\"ok\": true}"
          }
        ]
      }
    ]
  }
}
```

关键点：
- `$TOOL_INPUT` 是环境变量，包含工具的完整输入（JSON 字符串）
- 输出 `{"ok": false, "reason": "..."}` → 拦截，reason 会展示给用户
- 输出 `{"ok": true}` → 放行

## 实际演示

本次会话中，Claude 尝试执行：

```bash
rm /Users/a114514/claude-code-learning/sandbox/test-delete-me.txt
```

Prompt Hook 触发，输出：

```
⚠️ 检测到删除命令已被自动拦截。如需执行，请在消息中明确说明：'我已确认要执行此删除操作'
```

用户收到提示，命令被阻止。这证明 prompt hook 可以实现**需要用户二次确认的危险操作拦截**。

## 与 Shell Hook 的对比

| 维度 | Shell Hook | Prompt Hook |
|------|-----------|-------------|
| 编写难度 | 需要写 bash 脚本 | 用自然语言描述 |
| 执行速度 | 快 | 较慢（需要 LLM 推理） |
| 灵活性 | 精确，可处理复杂逻辑 | 适合语义判断，难以穷举规则 |
| 典型场景 | 精确匹配（文件路径、命令前缀） | 意图判断（"是否有危险操作"） |

## 当前项目中的 Prompt Hook

文件：`.claude/settings.json`

```json
{
  "type": "prompt",
  "prompt": "检查 $TOOL_INPUT 中的 bash 命令是否包含 rm（包括 rm、rm -r、rm -rf 等变体）。\n\n如果命令包含 rm，直接输出：{\"ok\": false, \"reason\": \"⚠️ 检测到删除命令已被自动拦截。如需执行，请在消息中明确说明：'我已确认要执行此删除操作'\"}\n\n如果命令不包含 rm，直接输出：{\"ok\": true}"
}
```

效果：所有 Bash 工具调用都会经过这个检查，含 `rm` 的命令会被拦截并提示用户确认。
