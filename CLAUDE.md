# CLAUDE.md

Claude Code 工作流配置与学习仓库。本项目用于探索和实践 Claude Code 的自定义能力：Agent、Skill、Hook 及 Hookify 规则。

## 语言要求

**始终用中文回复用户**，包括所有解释、说明、错误信息和代码注释。

## 项目目录结构

```
项目根/
├── CLAUDE.md                          # 项目级指令（本文件）
├── .gitignore
├── log.txt                            # 会话日志（SessionStart hook 写入）
├── writing-master/                    # writing-master skill 资源（根目录副本）
└── .claude/
    ├── settings.local.json            # 权限配置与 hooks 注册（已 gitignore）
    ├── hookify.*.local.md             # Hookify 规则文件
    ├── agents/                        # 自定义 Agent 定义
    │   ├── ai-trend-observer.md       # AI 前沿动态追踪
    │   ├── weather-report-master.md   # 天气查询与报告
    │   └── writing-master.md          # 多文体内容创作
    ├── hooks/                         # Shell hook 脚本
    │   ├── block-rm.sh                # PreToolUse：拦截 rm -rf
    │   └── echo.sh                    # SessionStart：写入日志
    └── skills/                        # 自定义 Skill 定义
        ├── claude-code-learning-patterns/
        │   └── SKILL.md              # 本仓库的编码模式规范
        └── writing-master/
            ├── SKILL.md              # 写作大师 skill 入口
            ├── 风格说明.md
            ├── 选题库/
            └── 内容库/
```

## Agent 编写规范

文件位置：`.claude/agents/<agent-name>.md`

必需的 frontmatter 字段：

| 字段 | 说明 |
|------|------|
| `name` | Agent 标识名（kebab-case） |
| `description` | 触发描述，必须包含至少 2 个 `<example>` 使用场景 |
| `tools` | 该 Agent 可用的工具列表 |
| `model` | `haiku`（轻量/高频任务）、`sonnet`（复杂创作）、`opus`（深度推理） |
| `color` | 终端显示颜色 |
| `memory` | 设为 `project` 开启项目级记忆 |

> 详细格式规范见 `claude-code-learning-patterns` skill。

## Skill 编写规范

文件位置：`.claude/skills/<skill-name>/SKILL.md`，补充资源放在同级目录。

必需的 frontmatter 字段：`name`、`description`、`origin`（通常为 `local`）、`resources`（资源文件列表）

标准正文结构：
1. **When to Activate** — 触发场景列表
2. **Core Rules** — 核心规则（3-7 条）
3. **Workflow** — 操作步骤
4. **Quality Gate** — 完成检查清单
5. **Resources** — 补充资源索引

> 详细格式规范见 `claude-code-learning-patterns` skill。

## Hook 编写规范

### Shell Hook

文件位置：`.claude/hooks/<hook-name>.sh`

- 通过 `jq` 从 stdin 读取工具输入（如 `jq -r '.tool_input.command'`）
- 拦截时输出 JSON：`{"hookSpecificOutput": {"permissionDecision": "deny"}}`
- 允许时直接 `exit 0`
- 在 `settings.local.json` 的 `hooks` 中注册，指定事件类型和 matcher

### Hookify 规则

文件位置：`.claude/hookify.<rule-name>.local.md`

必需的 frontmatter 字段：`name`、`enabled`、`event`（如 `stop`）、`pattern`、`action`（如 `warn`）

正文为自然语言描述的行为规则。

> 详细格式规范见 `claude-code-learning-patterns` skill。

## Git 提交规范

使用**约定式提交（Conventional Commits）**，中文描述：

```
<type>: <描述>（closes #<issue编号>）
```

| 类型 | 用途 |
|------|------|
| `feat:` | 新功能 |
| `fix:` | 修复问题 |
| `refactor:` | 重构 |
| `docs:` | 文档 |
| `chore:` | 杂项维护 |

**Issue 驱动开发流程**：创建 Issue → 功能分支 → 实现 → 提交（关联 Issue） → PR

## 常用命令

```bash
# 分支管理
git checkout -b feature/<feature-name>

# 提交与推送
git add <specific-files>
git commit -m "feat: 功能描述（closes #N）"
git push -u origin feature/<feature-name>

# PR 创建
gh pr create --title "feat: ..." --body "..."

# Issue 管理
gh issue create --title "..." --body "..."
gh issue list
```
