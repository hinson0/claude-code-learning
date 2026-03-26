#!/bin/bash

jq -r '.tool_input.command' >> "$CLAUDE_PROJECT_DIR/sandbox/command-log.txt"


