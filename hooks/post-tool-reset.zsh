#!/bin/zsh

# Claude Code PostToolUse Hook
# Resets visual indicators ONLY if currently in "waiting" state
# This handles the case where user approves/denies without typing a prompt

# Get the directory where this script is located
SCRIPT_DIR="${0:a:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"

# Source visual notifications
source "${PROJECT_DIR}/lib/visual-notifications.zsh"

# Configuration and state files
CONFIG_FILE="${HOME}/.config/claude/config.json"
STATE_FILE="${HOME}/.config/claude/.visual-state"

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    exit 0
fi

# Check if visual notifications are enabled
CONFIG=$(cat "$CONFIG_FILE")
if [[ $(echo "$CONFIG" | jq -r '.visual.enabled') != "true" ]]; then
    exit 0
fi

# Only reset if currently in "waiting" state
if [[ -f "$STATE_FILE" ]]; then
    current_state=$(cat "$STATE_FILE")
    if [[ "$current_state" == "waiting" ]]; then
        # Reset to normal color
        reset_visual_notification "$CONFIG"
    fi
fi

exit 0