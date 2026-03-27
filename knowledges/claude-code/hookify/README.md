# Hookify 学习笔记

## 什么是 Hookify

Hookify 是 Prompt 驱动的钩子，用**自然语言**而非 Shell 脚本定义行为规则。它本质上是在特定事件触发时向 Claude 注入额外的 prompt 指令。

## 与 Shell Hook 的区别

| 特性 | Shell Hook | Hookify |
|------|-----------|---------|
| 定义方式 | Shell 脚本 | Markdown + 自然语言 |
| 文件位置 | `.claude/hooks/*.sh` | `.claude/hookify.*.local.md` |
| 注册方式 | `settings.json` | 自动发现（文件命名约定） |
| 匹配方式 | 精确正则 | 灵活的 pattern |
| 适合场景 | 精确拦截/自动化 | 行为引导/提醒 |

## 文件格式

```markdown
---
name: 规则名称
enabled: true/false
event: stop/bash/edit/write 等
pattern: 正则匹配模式
action: warn/block
conditions:              # 可选
  - field: reason
    operator: regex_match
    pattern: .*
---

自然语言描述的行为规则内容
```

## 已有规则示例

参见 `.claude/hookify.*.local.md`：

| 规则 | 事件 | 功能 |
|------|------|------|
| `tell-joke` | stop | 每 3 轮讲一个程序员笑话 |
| `tool-call-notify` | bash | 工具调用时提示 |
| `warn-dangerous-rm` | bash | 检测到 rm -rf 时警告 |
| `yzb-well-done` | stop | 任务完成时鼓励 |
