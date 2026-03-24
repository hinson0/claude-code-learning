#!/bin/bash
# block-config-change.sh
# ConfigChange hook 演示：阻止 Claude 自动修改 settings.json
#
# 测试方法：
#   让 Claude 尝试修改 settings.json（例如添加权限、修改 hook）
#   或使用 /allowed-tools 命令授权工具
#
# 阻止条件：source == "claude"（Claude 主动发起的配置变更）
# 允许条件：source == "user" （用户手动发起的配置变更）

INPUT=$(cat)

# 提取变更来源和目标文件
SOURCE=$(echo "$INPUT" | jq -r '.source // "unknown"')
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // "unknown"')

# 记录所有配置变更（审计日志）
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="$PROJECT_DIR/sandbox/config-change-audit.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "$INPUT" | jq -c \
  '{timestamp: now | todate, source: .source, file: .file_path, hook: "block-config-change"}' \
  >> "$LOG_FILE"

if [[ "$SOURCE" == "user" ]]; then
  echo "ConfigChange ALLOWED: source=$SOURCE, file=$FILE_PATH" >&2
  exit 0
fi

# 阻止 Claude 自动修改配置（只允许用户手动操作）
echo "ConfigChange BLOCKED: source="$SOURCE" 不允许修改配置文件 ($FILE_PATH)" >&2
exit 2
