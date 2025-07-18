#!/bin/zsh

# Claude Code UserPromptSubmit Hook
# Resets visual indicators when user submits input

# Get the directory where this script is located
SCRIPT_DIR="${0:a:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"

# Source visual notifications
source "${PROJECT_DIR}/lib/visual-notifications.zsh"

# Configuration file location
CONFIG_FILE="${HOME}/.config/claude/config.json"

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    exit 0
fi

CONFIG=$(cat "$CONFIG_FILE")

# Check if visual notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.visual.enabled') == "true" ]]; then
    # Reset visual indicators
    reset_visual_notification "$CONFIG"
fi

exit 0