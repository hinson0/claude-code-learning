---
name: claude-code-learning-patterns
description: 从 claude-code-learning 仓库 git 历史中提取的编码模式和工作流规范
version: 1.0.0
source: local-git-analysis
analyzed_commits: 4
---

# Claude Code Learning 项目模式

从本仓库 git 历史中提取的团队规范与工作流约定。

## Commit Conventions

本项目使用**约定式提交（Conventional Commits）**，格式为：

```
<type>: <描述>（closes #<issue编号>）
```

检测到的提交类型：

| 类型 | 用途 | 示例 |
|------|------|------|
| `feat:` | 新功能 | `feat: 新增写作大师 skill（closes #1）` |
| `fix:` | 修复问题 | `fix: 重构 writing-master skill 为标准格式（closes #3）` |

**规则**：
- 提交信息使用**中文**
- 关联 issue 时在末尾加 `（closes #N）`
- 描述简洁，控制在 50 字以内

## Code Architecture

```
项目根/
├── CLAUDE.md                    # Claude Code 项目级指令（中文规范）
├── log.txt                      # 会话日志（由 SessionStart hook 写入）
└── .claude/
    ├── settings.local.json      # 权限配置与 hooks 注册
    ├── agents/                  # 自定义 Agent 定义
    │   ├── ai-trend-observer.md
    │   ├── weather-report-master.md
    │   └── writing-master.md
    ├── hooks/                   # 自动化 hook 脚本
    │   ├── block-rm.sh          # PreToolUse：拦截 rm -rf
    │   └── echo.sh              # SessionStart：写入日志
    └── skills/                  # 自定义 Skill 定义
        └── <skill-name>/
            ├── SKILL.md         # skill 入口（meta + body）
            └── <资源文件>/      # 补充资源
```

## Agent File Format

每个 agent 文件（`.claude/agents/*.md`）必须包含 YAML frontmatter：

```markdown
---
name: agent-name
description: "触发描述，含 <example> 标签说明使用场景"
tools: Glob, Grep, Read, Write, WebSearch, ...
model: haiku | sonnet | opus
color: blue | purple | green | ...
memory: project
---

# Agent 正文内容
...
```

**规则**：
- `description` 中必须包含至少 2 个 `<example>` 使用场景
- `model` 轻量任务用 `haiku`，复杂创作用 `sonnet`
- 所有 agent 使用 `memory: project` 开启项目级记忆

## Skill File Format

每个 skill 存放在独立目录，入口文件为 `SKILL.md`：

```markdown
---
name: skill-name
description: 一句话描述，说明何时激活
origin: local
resources:
  - 资源文件.md
  - 资源目录/
---

# Skill 标题

## When to Activate
列举触发场景

## Core Rules
核心规则列表（3-7条）

## Workflow
具体操作步骤

## Quality Gate
- [ ] 检查项1
- [ ] 检查项2

## Resources
补充资源索引
```

## Hook Patterns

### PreToolUse - 安全拦截

```bash
# .claude/hooks/block-rm.sh
# 拦截危险的 rm -rf 命令
COMMAND=$(jq -r '.tool_input.command')
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{"hookSpecificOutput": {"permissionDecision": "deny"}}'
fi
```

### SessionStart - 日志记录

```bash
# .claude/hooks/echo.sh
echo 1 >> ./log.txt
```

### 在 settings.local.json 中注册 hooks

```json
{
  "hooks": {
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": ".claude/hooks/block-rm.sh"}]}],
    "SessionStart": [{"matcher": "*", "hooks": [{"type": "command", "command": ".claude/hooks/echo.sh"}]}]
  }
}
```

## GitHub Workflow

本项目遵循 **Issue 驱动开发**：

1. **Issue 创建**：描述需求，含具体要求列表
2. **功能分支**：`git checkout -b feature/<feature-name>` 或 `fix/<fix-name>`
3. **实现**：在分支上完成开发
4. **提交**：`feat/fix: 描述（closes #N）`
5. **推送**：`git push -u origin <branch>`
6. **PR**：`gh pr create`，body 包含 Summary、Test plan、`Closes #N`

```bash
# 标准工作流命令
git checkout -b feature/my-feature
# ... 开发 ...
git add <specific-files>
git commit -m "feat: 功能描述（closes #N）"
git push -u origin feature/my-feature
gh pr create --title "feat: ..." --body "..."
```

## Permissions Configuration

`settings.local.json` 中预授权的操作：

```json
{
  "permissions": {
    "allow": [
      "WebSearch",
      "WebFetch(domain:trusted-domain.com)",
      "Bash(gh issue:*)",
      "Bash(git checkout:*)",
      "Bash(git merge:*)",
      "Bash(git push:*)"
    ]
  }
}
```

**规则**：
- 常用的安全操作预先授权，减少中断
- WebFetch 按域名精细化授权
- Bash 按命令前缀授权

## Language Convention

- **所有文档、提交信息、agent/skill 说明**均使用**中文**
- 代码本身使用英文（变量名、函数名等）
- CLAUDE.md 中明确声明语言要求
