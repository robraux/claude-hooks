#!/bin/zsh

# Desktop Notifications for macOS
# Uses terminal-notifier for native notifications

send_desktop_notification() {
    local message="$1"
    local notification_type="$2"
    local config="$3"
    local directory_name="$4"
    
    # Check if terminal-notifier is installed
    if ! command -v terminal-notifier &> /dev/null; then
        echo "Warning: terminal-notifier not installed" >&2
        return 1
    fi
    
    # Get desktop notification settings
    local sound=$(echo "$config" | jq -r '.desktop.sound')
    local sticky=$(echo "$config" | jq -r '.desktop.sticky')
    
    # Build notification command
    local cmd=(terminal-notifier)
    cmd+=(-title "$directory_name: Claude Code")
    cmd+=(-message "$message")
    cmd+=(-group "claude-code-notifications")
    
    # Add sound if not "none"
    if [[ "$sound" != "none" ]] && [[ -n "$sound" ]]; then
        cmd+=(-sound "$sound")
    fi
    
    # Add subtitle based on notification type
    case "$notification_type" in
        "waiting")
            cmd+=(-subtitle "Action Required")
            ;;
        "success")
            cmd+=(-subtitle "Task Completed")
            ;;
        "error")
            cmd+=(-subtitle "Error Occurred")
            ;;
        *)
            cmd+=(-subtitle "Notification")
            ;;
    esac
    
    # Execute notification command
    "${cmd[@]}" &> /dev/null
}