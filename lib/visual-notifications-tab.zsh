#!/bin/zsh

# Visual Notifications for iTerm2 - Tab Color Version
# Uses osascript to control tab colors which may be more reliable

# State file to track current visual state
STATE_FILE="${HOME}/.config/claude/.visual-state"

# Debug log file (optional)
VISUAL_DEBUG_LOG="${HOME}/.config/claude/visual-debug.log"

handle_visual_notification() {
    local notification_type="$1"
    local config="$2"
    
    # Get colors from config
    local waiting_color=$(echo "$config" | jq -r '.visual.colors.waiting')
    local success_color=$(echo "$config" | jq -r '.visual.colors.complete_success')
    local error_color=$(echo "$config" | jq -r '.visual.colors.complete_error')
    
    # Log if debug enabled
    if [[ -n "$VISUAL_DEBUG_LOG" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Visual notification: $notification_type" >> "$VISUAL_DEBUG_LOG"
    fi
    
    # Set tab color based on notification type
    case "$notification_type" in
        "waiting")
            set_tab_color "$waiting_color"
            echo "waiting" > "$STATE_FILE"
            ;;
        "success")
            set_tab_color "$success_color"
            echo "success" > "$STATE_FILE"
            # Auto-reset after 3 seconds
            (sleep 3 && reset_tab_color) &
            ;;
        "error")
            set_tab_color "$error_color"
            echo "error" > "$STATE_FILE"
            # Auto-reset after 3 seconds
            (sleep 3 && reset_tab_color) &
            ;;
        *)
            reset_tab_color
            echo "default" > "$STATE_FILE"
            ;;
    esac
}

set_tab_color() {
    local hex_color="$1"
    
    # Remove # from hex color if present
    hex_color="${hex_color#\#}"
    
    # Convert hex to RGB (0-1 scale for AppleScript)
    local r=$((16#${hex_color:0:2}))
    local g=$((16#${hex_color:2:2}))
    local b=$((16#${hex_color:4:2}))
    
    # AppleScript to set tab color
    osascript <<EOF 2>/dev/null || true
tell application "iTerm2"
    tell current session of current window
        set tab color to {$(($r * 257)), $(($g * 257)), $(($b * 257))}
    end tell
end tell
EOF
    
    # Also try the escape sequence method as backup
    printf "\033]6;1;bg;red;brightness;%d\a" "$r" 2>/dev/null || true
    printf "\033]6;1;bg;green;brightness;%d\a" "$g" 2>/dev/null || true
    printf "\033]6;1;bg;blue;brightness;%d\a" "$b" 2>/dev/null || true
}

reset_tab_color() {
    # Reset using AppleScript
    osascript <<EOF 2>/dev/null || true
tell application "iTerm2"
    tell current session of current window
        -- Reset tab color (iTerm2 doesn't have a direct "default" command, so we set to a neutral color)
        set tab color to {0, 0, 0}
    end tell
end tell
EOF
    
    # Also try escape sequence reset
    printf "\033]6;1;bg;*;default\a" 2>/dev/null || true
}

# Manual reset function
reset_visual_notification() {
    local config="$1"
    reset_tab_color
    echo "default" > "$STATE_FILE"
}