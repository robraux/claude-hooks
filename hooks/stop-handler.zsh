#!/bin/zsh

# Claude Code Stop Hook Handler
# Processes Stop events when Claude Code finishes responding successfully
# (Does not run if stoppage was due to user interrupt)

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

# Extract hook event name
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')

# Exit if not a Stop event
if [[ "$HOOK_EVENT" != "Stop" ]]; then
    exit 0
fi

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Warning: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

CONFIG=$(cat "$CONFIG_FILE")

# Get current working directory name for context
DIRECTORY_NAME=$(basename "$(pwd)")

# Create success message
MESSAGE="Claude Code completed successfully in $DIRECTORY_NAME"

# Set notification type to success (green terminal)
NOTIFICATION_TYPE="success"

# Check if visual notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.visual.enabled') == "true" ]]; then
    handle_visual_notification "$NOTIFICATION_TYPE" "$CONFIG"
fi

# Check if push notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.push.enabled') == "true" ]]; then
    send_push_notification "$MESSAGE" "$NOTIFICATION_TYPE" "$CONFIG" "$DIRECTORY_NAME"
fi

# Check if desktop notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.desktop.enabled') == "true" ]]; then
    send_desktop_notification "$MESSAGE" "$NOTIFICATION_TYPE" "$CONFIG" "$DIRECTORY_NAME"
fi

# Check if audio notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.audio.enabled') == "true" ]]; then
    play_audio_notification "$NOTIFICATION_TYPE" "$CONFIG" "$DIRECTORY_NAME"
fi

exit 0