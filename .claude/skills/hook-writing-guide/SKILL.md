---
name: hook-writing-guide
description: 使用这个skill,当用户要编写hook时
---

## Hook 编写规范

### Shell Hook

文件位置：`.claude/hooks/<hook-name>.sh`

- 通过 `jq` 从 stdin 读取工具输入（如 `jq -r '.tool_input.file_path'`）
- 拦截时 `exit 2`（非零退出码）
- 允许时 `exit 0`
- 在 `settings.json` 的 `hooks` 中注册，指定事件类型和 matcher

### Hookify 规则

文件位置：`.claude/hookify.<rule-name>.local.md`

必需的 frontmatter 字段：`name`、`enabled`、`event`、`pattern`、`action`

正文为自然语言描述的行为规则。