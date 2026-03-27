# Skill 学习笔记

## 什么是 Skill

Skill（技能）为 Claude 注入特定领域的深度知识，按需激活。不同于 Agent 独立运行，Skill 是在主对话中增强 Claude 的能力。

## 文件位置

`.claude/skills/<skill-name>/SKILL.md`，补充资源放在同级目录。

## 必需的 frontmatter 字段

```yaml
---
name: skill-name
description: 触发描述
origin: local
resources:
  - 资源文件列表
---
```

## 标准正文结构

1. **When to Activate** — 触发场景
2. **Core Rules** — 核心规则（3-7 条）
3. **Workflow** — 操作步骤
4. **Quality Gate** — 完成检查清单
5. **Resources** — 补充资源索引

## 已有 Skill 示例

参见 `.claude/skills/`：

| Skill | 用途 |
|-------|------|
| `claude-code-learning-patterns` | 本仓库的编码模式规范 |
| `writing-master` | 写作大师，含风格说明、选题库、内容库 |
