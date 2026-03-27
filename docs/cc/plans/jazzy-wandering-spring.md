# 计划：合并 examples/ 到 knowledges/

## Context

`examples/` 和 `knowledges/` 承担相同的职责（学习笔记），存在大量重复内容。
用户希望合并两个目录，保留 `knowledges/` 作为唯一的知识库目录。

**重叠文件分析（共 7 个）：全部内容完全相同（diff 为空）**
- bash/parameter-expansion.md
- bash/shell-basics.md（路径不同但内容一致）
- hooks/prompt-hook.md
- plugins/ 下 4 个文件（plugin-structure、hook-development、plugin-settings、create-plugin）

**仅存在于 examples/ 的文件（需迁移，共 10 个）：**

| 源路径 | 目标路径 |
|--------|---------|
| `examples/agents/README.md` | `knowledges/claude-code/agents/README.md` |
| `examples/hookify/README.md` | `knowledges/claude-code/hookify/README.md` |
| `examples/hooks/README.md` | `knowledges/claude-code/hooks/README.md` |
| `examples/hooks/block-rm.sh` | `knowledges/claude-code/hooks/block-rm.sh` |
| `examples/hooks/protect-files.sh` | `knowledges/claude-code/hooks/protect-files.sh` |
| `examples/hooks/echo.sh` | `knowledges/claude-code/hooks/echo.sh` |
| `examples/hooks/dump-input.sh` | `knowledges/claude-code/hooks/dump-input.sh` |
| `examples/hooks/hook-input-dump.json` | `knowledges/claude-code/hooks/hook-input-dump.json` |
| `examples/plugins/README.md` | `knowledges/claude-code/plugins/README.md` |
| `examples/skills/README.md` | `knowledges/claude-code/skills/README.md` |

**仅存在于 knowledges/ 的文件（保持不动）：**
- `knowledges/claude-code/claude-code-hud-and-rate-limits.md`
- `knowledges/claude-code/agents/subagent-usage.md`

---

## 实施步骤

### 步骤 1：复制仅在 examples/ 的文件到 knowledges/

```bash
cp examples/agents/README.md knowledges/claude-code/agents/README.md
cp examples/hookify/README.md knowledges/claude-code/hookify/README.md
cp examples/hooks/README.md knowledges/claude-code/hooks/README.md
cp examples/hooks/block-rm.sh knowledges/claude-code/hooks/block-rm.sh
cp examples/hooks/protect-files.sh knowledges/claude-code/hooks/protect-files.sh
cp examples/hooks/echo.sh knowledges/claude-code/hooks/echo.sh
cp examples/hooks/dump-input.sh knowledges/claude-code/hooks/dump-input.sh
cp examples/hooks/hook-input-dump.json knowledges/claude-code/hooks/hook-input-dump.json
cp examples/plugins/README.md knowledges/claude-code/plugins/README.md
cp examples/skills/README.md knowledges/claude-code/skills/README.md
```

（`knowledges/claude-code/hookify/` 和 `knowledges/claude-code/skills/` 目录需先创建）

### 步骤 2：删除 examples/ 目录

```bash
rm -rf examples/
```

> ⚠️ 此操作会触发 rm prompt hook，需用户手动确认执行（或在消息中说"我已确认"）。

### 步骤 3：更新 CLAUDE.md 目录结构说明

移除 `examples/` 条目，将 `knowledges/` 描述更新为合并后的结构：

```
├── knowledges/                            # 知识笔记（按主题分区）
│   ├── bash/                             # Bash 脚本基础（shell-basics, parameter-expansion）
│   └── claude-code/                      # Claude Code 各功能知识
│       ├── agents/                       # Agent 使用与学习笔记
│       ├── hooks/                        # Hook 事件、脚本示例、Prompt Hook
│       ├── hookify/                      # Hookify 规则学习
│       ├── plugins/                      # Plugin 开发（结构、设置、创建、hook 开发）
│       └── skills/                       # Skill 学习笔记
```

---

## 合并后 knowledges/ 最终结构

```
knowledges/
├── bash/
│   ├── shell-basics.md
│   └── parameter-expansion.md
└── claude-code/
    ├── claude-code-hud-and-rate-limits.md
    ├── agents/
    │   ├── subagent-usage.md
    │   └── README.md
    ├── hooks/
    │   ├── prompt-hook.md
    │   ├── README.md
    │   ├── block-rm.sh
    │   ├── protect-files.sh
    │   ├── echo.sh
    │   ├── dump-input.sh
    │   └── hook-input-dump.json
    ├── hookify/
    │   └── README.md
    ├── plugins/
    │   ├── plugin-structure.md
    │   ├── plugin-settings.md
    │   ├── hook-development.md
    │   ├── create-plugin.md
    │   └── README.md
    └── skills/
        └── README.md
```

---

## 验证

1. `ls knowledges/claude-code/` 确认所有子目录存在
2. `ls examples/` 应报错（目录已删除）
3. 检查 `CLAUDE.md` 目录结构章节已更新
