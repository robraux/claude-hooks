#!/bin/zsh

# Claude Code Notification Handler - Debug Version
# Includes extensive logging to diagnose iTerm2 color issues

# Get the directory where this script is located
SCRIPT_DIR="${0:a:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"

# Debug log file
DEBUG_LOG="${HOME}/.config/claude/notification-debug.log"
mkdir -p "${HOME}/.config/claude"

# Function to log debug information
debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$DEBUG_LOG"
}

debug_log "=== NOTIFICATION HANDLER DEBUG START ==="
debug_log "Script: $0"
debug_log "PID: $$"
debug_log "PPID: $PPID"

# Log environment information
debug_log "--- Environment Variables ---"
debug_log "TERM: $TERM"
debug_log "TERM_PROGRAM: $TERM_PROGRAM"
debug_log "TERM_PROGRAM_VERSION: $TERM_PROGRAM_VERSION"
debug_log "TERM_SESSION_ID: $TERM_SESSION_ID"
debug_log "ITERM_SESSION_ID: $ITERM_SESSION_ID"
debug_log "COLORTERM: $COLORTERM"
debug_log "TTY: $(tty)"

# Check TTY status
if [[ -t 0 ]]; then
    debug_log "STDIN is a TTY"
else
    debug_log "STDIN is NOT a TTY"
fi

if [[ -t 1 ]]; then
    debug_log "STDOUT is a TTY"
else
    debug_log "STDOUT is NOT a TTY"
fi

if [[ -t 2 ]]; then
    debug_log "STDERR is a TTY"
else
    debug_log "STDERR is NOT a TTY"
fi

# Log process hierarchy
debug_log "--- Process Hierarchy ---"
ps -p $$ -o pid,ppid,comm,args >> "$DEBUG_LOG" 2>&1
ps -p $PPID -o pid,ppid,comm,args >> "$DEBUG_LOG" 2>&1

# Source notification modules
source "${PROJECT_DIR}/lib/visual-notifications.zsh"
source "${PROJECT_DIR}/lib/push-notifications.zsh"
source "${PROJECT_DIR}/lib/desktop-notifications.zsh"
source "${PROJECT_DIR}/lib/audio-notifications.zsh"

# Configuration file location
CONFIG_FILE="${HOME}/.config/claude/config.json"

# Read JSON input from stdin
INPUT=$(cat)
debug_log "--- Hook Input ---"
debug_log "$INPUT"

# Extract hook event name and message
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // empty')

debug_log "Hook Event: $HOOK_EVENT"
debug_log "Message: $MESSAGE"

# Exit if not a notification event
if [[ "$HOOK_EVENT" != "Notification" ]]; then
    debug_log "Not a notification event, exiting"
    exit 0
fi

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    debug_log "ERROR: Config file not found at $CONFIG_FILE"
    echo "Warning: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

CONFIG=$(cat "$CONFIG_FILE")
debug_log "Config loaded successfully"

# Get current working directory name for context
DIRECTORY_NAME=$(basename "$(pwd)")
debug_log "Directory: $DIRECTORY_NAME"

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

debug_log "Notification Type: $NOTIFICATION_TYPE"

# Check if visual notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.visual.enabled') == "true" ]]; then
    debug_log "Visual notifications enabled, attempting to send..."
    
    # Test direct escape sequence output
    debug_log "Testing direct escape sequence to stdout..."
    printf "\033]6;1;bg;red;brightness;255\a" | tee -a "$DEBUG_LOG"
    
    debug_log "Testing direct escape sequence to stderr..."
    printf "\033]6;1;bg;red;brightness;255\a" >&2
    
    debug_log "Testing direct escape sequence to /dev/tty..."
    if [[ -w /dev/tty ]]; then
        printf "\033]6;1;bg;red;brightness;255\a" > /dev/tty
        debug_log "Sent to /dev/tty"
    else
        debug_log "Cannot write to /dev/tty"
    fi
    
    # Call the standard handler
    handle_visual_notification "$NOTIFICATION_TYPE" "$CONFIG"
    debug_log "Visual notification handler called"
else
    debug_log "Visual notifications disabled"
fi

# Check if push notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.push.enabled') == "true" ]]; then
    debug_log "Sending push notification..."
    send_push_notification "$MESSAGE" "$NOTIFICATION_TYPE" "$CONFIG" "$DIRECTORY_NAME"
fi

# Check if desktop notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.desktop.enabled') == "true" ]]; then
    debug_log "Sending desktop notification..."
    send_desktop_notification "$MESSAGE" "$NOTIFICATION_TYPE" "$CONFIG" "$DIRECTORY_NAME"
fi

# Check if audio notifications are enabled
if [[ $(echo "$CONFIG" | jq -r '.audio.enabled') == "true" ]]; then
    debug_log "Playing audio notification..."
    play_audio_notification "$NOTIFICATION_TYPE" "$CONFIG" "$DIRECTORY_NAME"
fi

debug_log "=== NOTIFICATION HANDLER DEBUG END ==="
debug_log ""

exit 0