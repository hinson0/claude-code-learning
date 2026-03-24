# Shell 基础知识笔记（Hook 编写相关）

## 1. `INPUT=$(cat)` — 从 stdin 读取全部内容

```bash
INPUT=$(cat)
```

| 部分 | 含义 |
|------|------|
| `cat` | 不带参数时从 stdin 读取 |
| `$(...)` | 命令替换，把输出赋给变量 |
| `INPUT=` | 存到变量 |

Hook 脚本中，Claude Code 通过管道把 JSON 传入脚本的 stdin，`cat` 读取后存入变量：

```bash
#!/bin/bash
INPUT=$(cat)                              # 读取 Claude Code 传入的 JSON
TOOL=$(echo "$INPUT" | jq -r '.tool_name')  # 用 jq 解析字段
```

---

## 2. 管道与子 Shell 的变量隔离

管道 `|` 的每一段都在**独立的子 shell** 里运行，变量不能跨段传递：

```bash
# 错误示范
echo '{"foo": "bar"}' | INPUT=$(cat) | echo $INPUT
#                        ↑ 读到了内容   ↑ $INPUT 是空的！变量在另一个子 shell 里
```

两种传递机制的区别：

| 传递方式 | 能否跨子 shell |
|---------|--------------|
| 管道（stdout → stdin） | ✓ 可以，OS 层面的 IPC |
| Shell 变量 | ✗ 不行，子 shell 有独立变量空间 |

正确的测试写法：

```bash
# 方式1：分组括号，让两条命令在同一个子 shell 里
echo '{"foo": "bar"}' | (INPUT=$(cat); echo $INPUT)

# 方式2：不用管道，直接赋值
INPUT=$(echo '{"foo": "bar"}'); echo $INPUT
```

Hook 脚本里没有这个问题，因为**整个脚本是一个进程**，`INPUT` 在脚本范围内全局可见。

---

## 3. `echo $INPUT` vs `echo "$INPUT"`

加不加双引号，决定 Shell 是否对变量值做进一步展开：

| | `echo $INPUT` | `echo "$INPUT"` |
|---|---|---|
| 空格/换行 | 被 Shell 分词，压缩成一行 | 原样保留 |
| `*` `?` 等通配符 | 被 glob 展开为文件列表 | 当普通字符处理 |
| 多行 JSON | 换行丢失 | 结构保留 |

示例：

```bash
INPUT='{"a": 1,
"b": 2}'

echo $INPUT    # {"a": 1, "b": 2}      ← 换行丢失
echo "$INPUT"  # {"a": 1,
               # "b": 2}               ← 原样保留
```

通配符展开的危险情况：

```bash
INPUT="*.sh"

echo $INPUT    # block-rm.sh echo.sh protect-files.sh  ← 被展开成文件！
echo "$INPUT"  # *.sh                                   ← 原样输出
```

**结论：操作变量时始终加双引号**，尤其是传给 `jq` 时：

```bash
echo "$INPUT" | jq '.tool_name'   # ✓ 正确
echo $INPUT   | jq '.tool_name'   # ✗ JSON 含特殊字符时可能出错
```
