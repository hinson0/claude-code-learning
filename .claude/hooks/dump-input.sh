#!/bin/bash
# dump-input.sh — 将 hook 收到的完整 JSON 输入记录到日志文件

INPUT=$(cat)
echo "$INPUT" | jq '.' >> "$CLAUDE_PROJECT_DIR/hook-input-dump.json"

exit 0
