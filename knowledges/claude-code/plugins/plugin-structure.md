# Plugin Structure 学习笔记

## 是什么

插件是一个**约定好目录结构的文件夹**，Claude Code 扫描目录自动加载组件，无需手动注册。

---

## 标准目录结构

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json      ← 唯一必需文件
├── commands/            ← 斜杠命令（legacy，新插件用 skills/）
├── agents/              ← 子 Agent 定义（.md 文件）
├── skills/              ← 技能（每个技能一个子目录 + SKILL.md）
│   └── skill-name/
│       └── SKILL.md
├── hooks/
│   ├── hooks.json       ← Hook 注册
│   └── scripts/         ← Hook 脚本
└── .mcp.json            ← MCP 服务配置（可选）
```

**只创建实际用到的目录，不用全建。**

---

## plugin.json 最小写法

```json
{
  "name": "my-plugin"
}
```

name 用 kebab-case（小写加连字符）。

完整字段（可选）：

```json
{
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "插件描述",
  "author": { "name": "xxx", "email": "xxx@example.com" }
}
```

---

## 自动发现规则

| 目录 | 规则 | 结果 |
|------|------|------|
| `commands/` | 所有 `.md` 文件 | 斜杠命令（legacy） |
| `agents/` | 所有 `.md` 文件 | 子 Agent |
| `skills/` | 子目录中的 `SKILL.md` | 技能 |
| `hooks/hooks.json` | 自动加载 | Hook 注册 |

放进去就生效，不需要额外注册。

---

## 关键注意点

1. `plugin.json` 必须在 `.claude-plugin/` 里，其他组件目录放**插件根目录**
2. 路径用 `$CLAUDE_PLUGIN_ROOT`，不要硬编码绝对路径
3. 新插件优先用 `skills/` 而非 `commands/`（前者是推荐格式）
4. 修改后重启 Claude Code 才生效

---

## 三种典型规模

**最小插件**（单命令）：
```
my-plugin/
├── .claude-plugin/plugin.json
└── skills/hello/SKILL.md
```

**技能型插件**：
```
my-plugin/
├── .claude-plugin/plugin.json
└── skills/
    ├── skill-one/SKILL.md
    └── skill-two/SKILL.md
```

**完整插件**：
```
my-plugin/
├── .claude-plugin/plugin.json
├── skills/
├── agents/
├── hooks/
└── .mcp.json
```
