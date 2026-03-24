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

| Agent | 用途 |
|-------|------|
| `ai-trend-observer` | AI 前沿动态追踪 |
| `weather-report-master` | 天气查询与报告 |
| `writing-master` | 多文体内容创作 |
