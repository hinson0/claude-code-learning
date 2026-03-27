# Hook Auditor 审查记录

**最后审查时间**：2026-03-27

## 项目 Hook 规范

### Shell Hook 标准格式
```bash
#!/bin/bash
# 描述注释

INPUT=$(cat)
FIELD=$(echo "$INPUT" | jq -r '.path.to.field // default_value')

# 业务逻辑
if condition; then
  exit 2  # 拦截
else
  exit 0  # 允许
fi
```

### 关键要点
1. **stdin 读取**：必须使用 `jq -r` 读取 JSON 输入
2. **退出码规范**：
   - `exit 0` = 允许执行
   - `exit 2` = 拦截（非零）
3. **settings.json 注册**：必须在对应事件的 hooks 数组中注册
4. **事件类型**：
   - SessionStart（会话启动）
   - PreToolUse（工具调用前）
   - ConfigChange（配置变更）

---

## 典型违规模式

### 模式 1：错误的拦截返回格式
**违规文件**：`block-rm.sh`

```bash
# 错误做法
jq -n '{
  hookSpecificOutput: {
    permissionDecision: "deny"
  }
}'
```

**问题**：
- Shell hook 不应输出 JSON 来表示拦截决策
- 应使用 `exit 2` 来拦截
- 混淆了 Shell Hook 和 Prompt Hook 的返回方式

**正确做法**：
```bash
if [[ condition ]]; then
  exit 2  # 直接拦截，无需输出
else
  exit 0
fi
```

---

### 模式 2：缺少显式退出码
**违规文件**：`command-log.sh`

```bash
jq -r '.tool_input.command' >> "$CLAUDE_PROJECT_DIR/sandbox/command-log.txt"
# 缺少 exit 0 或 exit 2
```

**问题**：
- 隐式返回最后命令的退出码
- 若 jq 失败，会以非零码结束（意外拦截）
- 规范要求显式声明是否允许或拦截

**正确做法**：
```bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')
echo "$COMMAND" >> "$CLAUDE_PROJECT_DIR/sandbox/command-log.txt"
exit 0  # 显式允许
```

---

### 模式 3：完全不符合规范的文件
**违规文件**：`echo.sh`

```bash
echo 1 >> ./log.txt
```

**问题**：
- 缺少 shebang `#!/bin/bash`
- 不读取 stdin（jq 缺失）
- 无明确退出码
- 无任何有效逻辑
- settings.json 中无注册

**处理方案**：应删除或根据实际需求重新编写

---

### 模式 4：不完整的命令检查
**违规文件**：`block-rm.sh` 的逻辑问题

```bash
if echo "$COMMAND" | grep -q 'rm -rf'; then
  # 拦截
fi
```

**问题**：
- 只检查 `rm -rf`，遗漏 `rm`、`rm -r`、`rm -f` 等变体
- 未处理路径中包含 "rm" 的情况（误判风险）

**正确做法**：
```bash
if echo "$COMMAND" | grep -qE '\brm\b|rm\s+-'; then
  exit 2
else
  exit 0
fi
```

---

## 合规 Hook 案例

### block-config-change.sh ✓
**优点**：
- 规范的 jq 读取
- 清晰的条件判断
- 正确的退出码
- 完整的审计日志
- settings.json 正式注册（ConfigChange）

### protect-files.sh ✓
**优点**：
- 数组遍历模式清晰
- 字符串匹配逻辑合理
- 正确的退出码
- 防保护文件的常见模式

### session-start-demo.sh ✓
**优点**：
- 完整的 JSON 提取（带默认值）
- 时间戳处理
- 日志和数据分离存储
- 演示性和实用性结合

---

## 建议行动清单

- [ ] 删除 `echo.sh`（完全无用）
- [ ] 修复 `block-rm.sh`（改为正确的 shell hook 返回方式）
- [ ] 修复 `command-log.sh`（补充 `exit 0`）
- [ ] 核实 `protect-files.sh` 的 settings.json 注册状态
- [ ] 考虑统一 logging 目录结构（sandbox/ vs .claude/）
- [ ] 为未注册的 hook 补充 settings.json 配置

