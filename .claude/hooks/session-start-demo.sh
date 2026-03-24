#!/bin/bash
# session-start-demo.sh — SessionStart hook 演示
# 记录每次会话启动的信息

INPUT=$(cat)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')

# 记录到日志
echo "[$TIMESTAMP] event=$EVENT session=$SESSION_ID" >> "$CLAUDE_PROJECT_DIR/sandbox/session-start.log"

# 完整 JSON 也记录一份，方便学习
echo "$INPUT" | jq '.' >> "$CLAUDE_PROJECT_DIR/sandbox/session-start-dump.json"

exit 0
