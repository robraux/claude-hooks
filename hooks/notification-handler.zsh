#!/bin/zsh

# Claude Code Notification Handler
# Processes notification events from Claude Code hooks

# Get the directory where this script is located
SCRIPT_DIR="${0:a:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"

# Source notification modules
source "${PROJECT_DIR}/lib/visual-notifications.zsh"
source "${PROJECT_DIR}/lib/push-notifications.zsh"
source "${PROJECT_DIR}/lib/desktop-notifications.zsh"
source "${PROJECT_DIR}/lib/audio-notifications.zsh"

# Configuration file location
CONFIG_FILE="${HOME}/.config/claude/config.json"

# Read JSON input from stdin
INPUT=$(cat)

# Extract hook event name and message
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // empty')

# Exit if not a notification event
if [[ "$HOOK_EVENT" != "Notification" ]]; then
    exit 0
fi

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Warning: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

CONFIG=$(cat "$CONFIG_FILE")

# Determine notification type based on message content
NOTIFICATION_TYPE="info"
if [[ "$MESSAGE" =~ "permission" ]]; then
    NOTIFICATION_TYPE="waiting"
elif [[ "$MESSAGE" =~ "waiting for your input" ]]; then
    NOTIFICATION_TYPE="waiting"
elif [[ "$MESSAGE" =~ "completed successfully" ]]; then
    NOTIFICATION_TYPE="success"
elif [[ "$MESSAGE" =~ "error" ]] || [[ "$MESSAGE" =~ "failed" ]]; then
    NOTIFICATION_TYPE="error"
fi

# Check if visual notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.visual.enabled') == "true" ]]; then
    handle_visual_notification "$NOTIFICATION_TYPE" "$CONFIG"
fi

# Check if push notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.push.enabled') == "true" ]]; then
    send_push_notification "$MESSAGE" "$NOTIFICATION_TYPE" "$CONFIG"
fi

# Check if desktop notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.desktop.enabled') == "true" ]]; then
    send_desktop_notification "$MESSAGE" "$NOTIFICATION_TYPE" "$CONFIG"
fi

# Check if audio notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.audio.enabled') == "true" ]]; then
    play_audio_notification "$NOTIFICATION_TYPE" "$CONFIG"
fi

exit 0