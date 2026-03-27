# Create Plugin 学习笔记

## 是什么

`plugin-dev:create-plugin` 是一个**引导式插件创建工作流 Skill**，带你从零到完整地创建一个 Claude Code 插件，每个关键决策点都等用户确认，不乱猜。

---

## 8 个阶段

| 阶段 | 目标 |
|------|------|
| 1. Discovery | 搞清楚插件要解决什么问题 |
| 2. Component Planning | 决定需要哪些组件 |
| 3. Detailed Design | 细化每个组件，澄清所有模糊点 |
| 4. Structure Creation | 创建目录结构和 `plugin.json` |
| 5. Implementation | 逐个实现每个组件 |
| 6. Validation | 用 plugin-validator agent 检查质量 |
| 7. Testing | 给出测试清单，指导验证 |
| 8. Documentation | 完善 README，准备发布 |

---

## 关键特点

- **每个决策点等用户确认**，不会自作主张直接实现
- Phase 3（详细设计）最重要，不能跳过——在这里澄清所有模糊点
- 按需加载其他 `plugin-dev:*` 技能（hook-development、agent-development 等）
- 用 TodoWrite 跟踪所有阶段进度

---

## 与其他 Skill 的关系

```
create-plugin（入口/总流程）
  ├── plugin-structure    ← Phase 2 加载
  ├── skill-development   ← Phase 5 加载
  ├── hook-development    ← Phase 5 加载
  ├── agent-development   ← Phase 5 加载
  ├── mcp-integration     ← Phase 5 加载
  └── plugin-settings     ← Phase 5 加载
```

它是**入口 Skill**，其他 Skill 是它的子模块，按需加载。

---

## 怎么使用

直接说"帮我创建一个 XXX 插件"即可触发，或者：

```
/plugin-dev:create-plugin
```

然后按照引导一步步回答问题。
