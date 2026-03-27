# CLAUDE.md

Claude Code 自定义能力学习仓库。

## 语言要求

**始终用中文回复用户**，包括所有解释、说明、错误信息和代码注释。

## 项目目录结构

```
项目根/
├── CLAUDE.md                              # 项目级指令（本文件）
├── README.md                              # 项目说明
├── .gitignore
│
├── sandbox/                               # 实验临时文件（已 gitignore）
├── knowledges/                            # 知识笔记（按主题分区）
│   ├── bash/                              # Bash 脚本基础（shell-basics, parameter-expansion）
│   └── claude-code/                       # Claude Code 各功能知识
│       ├── agents/                        # Agent 使用与学习笔记
│       ├── hooks/                         # Hook 事件、脚本示例、Prompt Hook
│       ├── hookify/                       # Hookify 规则学习
│       ├── plugins/                       # Plugin 开发（结构、设置、创建、hook 开发）
│       └── skills/                        # Skill 学习笔记
│
└── .claude/                               # 实际生效的 Claude Code 配置
    ├── settings.json                      # hooks 注册与权限
    ├── hookify.*.local.md                 # Hookify 规则文件
    ├── agents/                            # 自定义 Agent 定义
    ├── hooks/                             # Shell Hook 脚本
    └── skills/                            # 自定义 Skill 定义
```

> ⚠️ 本项目的 rm 命令会被 hookify 无条件拦截（`action: block`）。Claude 无法执行任何删除操作，用户需自行在终端运行（可用 `! rm ...` 前缀）。

## Hook 编写规范

### Shell Hook

文件位置：`.claude/hooks/<hook-name>.sh`

- 通过 `jq` 从 stdin 读取工具输入（如 `jq -r '.tool_input.file_path'`）
- 拦截时 `exit 2`（非零退出码）
- 允许时 `exit 0`
- 在 `settings.json` 的 `hooks` 中注册，指定事件类型和 matcher

### Hookify 规则

文件位置：`.claude/hookify/hookify.<rule-name>.local.md`

必需的 frontmatter 字段：`name`、`enabled`、`event`、`pattern`、`action`

正文为自然语言描述的行为规则。

## Agent 编写规范

文件位置：`.claude/agents/<agent-name>.md`

必需的 frontmatter 字段：`name`、`description`（含 `<example>`）、`tools`、`model`

## Skill 编写规范

文件位置：`.claude/skills/<skill-name>/SKILL.md`

必需的 frontmatter 字段：`name`、`description`、`origin`、`resources`

## Git 提交规范

```
<type>: <描述>
```

类型：feat / fix / refactor / docs / chore
