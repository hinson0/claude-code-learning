# Plugin 学习笔记

## 什么是 Plugin

Plugin（插件）是 Claude Code 的扩展包，可以打包 Agent、Skill、Hook、Command 等组件，通过 Marketplace 分发安装。

## 插件安装位置

`~/.claude/plugins/` — 全局目录，对所有项目生效。

## 常用命令

```bash
/plugin              # 管理插件（安装/卸载/启用/禁用）
/reload-plugins      # 重新加载插件
```

## 插件结构

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # 插件清单（name, description, author）
├── hooks/
│   └── hooks.json         # Hook 注册
├── agents/                # Agent 定义
├── skills/                # Skill 定义
├── commands/              # 自定义命令
└── README.md
```

## 插件 vs 本地配置

| 特性 | 插件 | 本地配置 |
|------|------|---------|
| 作用范围 | 全局（所有项目） | 项目级 |
| 安装位置 | `~/.claude/plugins/` | `.claude/` |
| 分发方式 | Marketplace | 手动/Git |
| 管理方式 | `/plugin` 命令 | 直接编辑文件 |

## 已安装的插件示例

| 插件 | 功能 |
|------|------|
| `learning-output-style` | 学习模式，在关键决策点让用户写代码 |
| `hookify` | 用自然语言创建行为规则 |
| `superpowers` | 增强工作流（计划、评审、调试等） |
