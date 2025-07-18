#!/bin/zsh

# Visual Notifications for iTerm2
# Handles terminal color changes based on notification state

# State file to track current visual state
STATE_FILE="${HOME}/.config/claude/.visual-state"

handle_visual_notification() {
    local notification_type="$1"
    local config="$2"
    
    # Get colors from config
    local waiting_color=$(echo "$config" | jq -r '.visual.colors.waiting')
    local success_color=$(echo "$config" | jq -r '.visual.colors.complete_success')
    local error_color=$(echo "$config" | jq -r '.visual.colors.complete_error')
    local default_color=$(echo "$config" | jq -r '.visual.colors.default')
    
    # Set color based on notification type
    case "$notification_type" in
        "waiting")
            set_terminal_color "$waiting_color"
            echo "waiting" > "$STATE_FILE"
            ;;
        "success")
            set_terminal_color "$success_color"
            echo "success" > "$STATE_FILE"
            # Auto-reset after 3 seconds
            (sleep 3 && reset_terminal_color "$default_color") &
            ;;
        "error")
            set_terminal_color "$error_color"
            echo "error" > "$STATE_FILE"
            # Auto-reset after 3 seconds
            (sleep 3 && reset_terminal_color "$default_color") &
            ;;
        *)
            # Use iTerm2's reset to default instead of setting a specific color
            printf "\033]6;1;bg;*;default\a"
            echo "default" > "$STATE_FILE"
            ;;
    esac
}

set_terminal_color() {
    local color="$1"
    
    # Remove # from hex color if present
    color="${color#\#}"
    
    # Convert hex to RGB
    local r=$((16#${color:0:2}))
    local g=$((16#${color:2:2}))
    local b=$((16#${color:4:2}))
    
    # iTerm2 proprietary escape sequence for tab color
    printf "\033]6;1;bg;red;brightness;%d\a" "$r"
    printf "\033]6;1;bg;green;brightness;%d\a" "$g"
    printf "\033]6;1;bg;blue;brightness;%d\a" "$b"
}

reset_terminal_color() {
    local color="${1:-#000000}"
    
    # Check if we should reset (only reset if still in a temporary state)
    if [[ -f "$STATE_FILE" ]]; then
        local current_state=$(cat "$STATE_FILE")
        if [[ "$current_state" == "success" ]] || [[ "$current_state" == "error" ]]; then
            # Use iTerm2's reset to default instead of setting a specific color
            printf "\033]6;1;bg;*;default\a"
            echo "default" > "$STATE_FILE"
        fi
    fi
}

# Manual reset function
reset_visual_notification() {
    local config="$1"
    
    # Use iTerm2's reset to default instead of setting a specific color
    printf "\033]6;1;bg;*;default\a"
    echo "default" > "$STATE_FILE"
}