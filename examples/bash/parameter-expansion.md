# Bash 参数展开与命令替换

## `${}` 参数展开（Parameter Expansion）

`$变量名` 是 `${变量名}` 的简写。必须用 `{}` 的场景：紧跟其他字符时。

```bash
echo "${name}s"   # ✓ → "worlds"
echo "$names"     # ✗ 找的是变量 $names
```

### 默认值系列

```bash
${VAR:-default}   # 未设置或空 → 返回 default（VAR 不变）
${VAR-default}    # 仅未设置   → 返回 default（空字符串不触发）
${VAR:=default}   # 未设置或空 → 返回 default，且同时给 VAR 赋值
${VAR:?message}   # 未设置或空 → 打印 message 并 exit 1（强制校验）
${VAR:+other}     # 已设置且非空 → 返回 other，否则返回空
```

### 字符串长度

```bash
echo ${#str}      # 字符串长度
echo ${#arr[@]}   # 数组长度
```

### 子字符串截取

```bash
str="hello world"
echo ${str:6}     # → "world"（从第6位到末尾）
echo ${str:0:5}   # → "hello"（从第0位取5个字符）
echo ${str: -5}   # → "world"（从末尾数5个，注意空格）
```

### 模式删除（前缀/后缀）

```bash
path="/usr/local/bin/bash"

${path#*/}    # → "usr/local/bin/bash"（删最短前缀）
${path##*/}   # → "bash"（删最长前缀，等效 basename）
${path%/*}    # → "/usr/local/bin"（删最短后缀，等效 dirname）
${path%%/*}   # → ""（删最长后缀）
```

> 记忆技巧：`#` 在键盘 `$` 左边 → 删左边（前缀）；`%` 在右边 → 删右边（后缀）

### 替换

```bash
str="hello hello"
${str/hello/hi}    # → "hi hello"（替换第一个）
${str//hello/hi}   # → "hi hi"（替换所有）
${str/#hello/hi}   # → "hi hello"（替换开头）
${str/%hello/hi}   # → "hello hi"（替换结尾）
```

### 大小写转换（Bash 4+）

```bash
${str,,}   # 全小写
${str^^}   # 全大写
${str,}    # 首字母小写
${str^}    # 首字母大写
```

---

## `$()` 命令替换（Command Substitution）

把命令的**输出结果**作为值使用。

```bash
today=$(date +%Y-%m-%d)
echo "当前目录：$(pwd)"
echo "文件数量：$(ls | wc -l)"
```

### 与反引号的区别

```bash
result=$(command)   # 推荐，可嵌套
result=`command`    # 旧写法，嵌套需转义，不推荐
```

### 注意：输出会自动去掉末尾换行

```bash
result=$(printf "hello\n\n")
echo "$result"    # → "hello"（末尾换行被去掉）
# 保留空白需加引号：echo "$result" 而非 echo $result
```

---

## 两者对比

| 语法 | 类型 | 作用 |
|------|------|------|
| `${VAR}` | 参数展开 | 取/操作**变量**的值 |
| `$(cmd)` | 命令替换 | 取**命令执行**的输出 |

### 组合使用（hook 脚本中的典型模式）

```bash
# 未设置时用 pwd 输出作为默认值
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# 从路径提取文件名（不依赖外部命令）
FILENAME="${FILE_PATH##*/}"   # 等效 basename

# 提取扩展名
EXT="${FILE_PATH##*.}"        # → "json", "sh" 等
```

---

## 引号、Word Splitting 与 Glob 展开

### 三种写法对比

| 写法 | word splitting | glob 展开 | 界定变量边界 | 参数扩展 |
|------|:-:|:-:|:-:|:-:|
| `$input` | ✅ 会 | ✅ 会 | ❌ | ❌ |
| `${input}` | ✅ 会 | ✅ 会 | ✅ | ✅ |
| `"$input"` | ❌ 禁止 | ❌ 禁止 | ✅ | ❌ |
| `"${input}"` | ❌ 禁止 | ❌ 禁止 | ✅ | ✅ |

### Word Splitting（词分割）

变量未加引号时，Shell 会按 `$IFS`（默认空格/Tab/换行）把值拆成多个词：

```bash
input="hello world"
cp $input /tmp/      # 拆成 cp hello world /tmp/ → 两个参数，报错
cp "$input" /tmp/    # 正确：一个参数 "hello world"
```

### Glob 展开

变量未加引号时，若值匹配文件名通配符，会被展开为文件名列表：

```bash
input="*.txt"
echo $input          # 展开为当前目录所有 .txt 文件名！
echo "$input"        # 输出字面量 *.txt，安全
```

### 最佳实践

```bash
# 几乎所有情况都应加双引号
file_path="$1"
cp "${file_path}" "${file_path}.bak"   # 路径含空格也安全

# 仅在明确需要 word splitting 时才省略引号（如拆分命令参数列表）
args="--verbose --dry-run"
ls $args    # 刻意拆成两个参数
```

> **规则**：除非明确需要 word splitting，否则**始终加双引号**。

---

## 核心价值

`${}` 的字符串操作**不依赖外部命令**（`sed`/`awk`/`basename` 等），全部在 shell 内完成，更快也更可移植。
