# Claude Code Learning

Claude Code 自定义能力学习与实践仓库。通过动手创建 Agent、Skill、Hook 和 Hookify 规则，掌握 Claude Code 的扩展机制。

## 学习内容

### Agent（自定义智能体）

位于 `.claude/agents/`，通过 Markdown frontmatter 定义独立的子智能体：

| Agent | 用途 | 模型 |
|-------|------|------|
| `ai-trend-observer` | AI 前沿动态追踪与热点分析 | - |
| `weather-report-master` | 天气查询与格式化报告 | - |
| `writing-master` | 多文体内容创作（深度长文/社交文案/商业文案） | - |

### Skill（技能）

位于 `.claude/skills/`，为 Claude 提供特定领域的深度知识：

| Skill | 用途 |
|-------|------|
| `claude-code-learning-patterns` | 本仓库的编码模式与工作流规范 |
| `writing-master` | 写作大师技能，含风格说明、选题库、内容库 |

### Hook（钩子）

位于 `.claude/hooks/`，在工具调用前后执行的 Shell 脚本：

| Hook | 事件 | 功能 |
|------|------|------|
| `block-rm.sh` | PreToolUse | 拦截 `rm -rf` 危险命令 |
| `echo.sh` | SessionStart | 会话启动时写入日志 |

在 `settings.json` 中还注册了 Stop 事件钩子：
- 系统通知（macOS `display notification`）
- 语音提示（`say 'helloworld'`）

### Hookify 规则（Prompt 驱动的钩子）

位于 `.claude/hookify.*.local.md`，用自然语言定义行为规则：

| 规则 | 事件 | 状态 | 功能 |
|------|------|------|------|
| `tell-joke` | stop | 禁用 | 每 3 轮对话讲一个程序员笑话 |
| `tool-call-notify` | bash | 禁用 | 工具调用时发出提示 |
| `warn-dangerous-rm` | bash | 禁用 | 检测到 `rm -rf` 时警告 |
| `yzb-well-done` | stop | 启用 | 任务完成时输出鼓励语 |

## 项目结构

```
.
├── README.md                              # 本文件
├── CLAUDE.md                              # 项目级指令（Claude Code 读取）
├── .gitignore
│
├── examples/                              # 学习示例与笔记
│   ├── hooks/                             # Hook 示例脚本 + 知识笔记
│   ├── hookify/                           # Hookify 知识笔记
│   ├── agents/                            # Agent 知识笔记
│   ├── skills/                            # Skill 知识笔记
│   └── plugins/                           # Plugin 知识笔记
│
├── sandbox/                               # 实验临时文件（已 gitignore）
│
└── .claude/                               # 实际生效的配置
    ├── settings.json                      # hooks 注册
    ├── hookify.*.local.md                 # Hookify 规则文件
    ├── agents/                            # 自定义 Agent
    ├── hooks/                             # Shell Hook 脚本
    └── skills/                            # 自定义 Skill
```

## 核心概念速览

```
┌─────────────────────────────────────────────────────┐
│                  Claude Code 扩展体系                  │
├──────────┬──────────┬──────────┬────────────────────┤
│  Agent   │  Skill   │  Hook    │  Hookify           │
│  子智能体 │  技能包   │  Shell钩子│  Prompt钩子        │
├──────────┼──────────┼──────────┼────────────────────┤
│ 独立执行  │ 知识注入  │ 代码拦截  │ 自然语言规则        │
│ 有专属工具│ 按需激活  │ 精确匹配  │ 灵活匹配           │
│ 可选模型  │ 资源文件  │ stdin/出  │ YAML frontmatter  │
└──────────┴──────────┴──────────┴────────────────────┘
```

## 快速开始

```bash
# 克隆仓库
git clone <repo-url>
cd claude-code-learning

# 启动 Claude Code，自动加载 CLAUDE.md 及 .claude/ 下的配置
claude
```
