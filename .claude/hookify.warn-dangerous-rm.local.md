---
name: block-dangerous-rm
enabled: true
event: bash
pattern: ^\s*rm\s+-\w*r\w*f
action: block
---

⚠️ **检测到 rm -rf 命令**

你正在执行带有 `-rf` 标志的删除操作，这会递归强制删除文件且不可恢复。

**请确认：**
- 目标路径是否正确？
- 是否有更安全的替代方式（如 `rmdir` 删除空目录、逐个删除等）？
- 重要文件是否已备份？

在确认无误后再继续执行。
