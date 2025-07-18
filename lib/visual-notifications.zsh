#!/bin/zsh

# Visual Notifications for iTerm2
# Handles terminal color changes based on notification state

# State file to track current visual state
STATE_FILE="${HOME}/.config/claude/.visual-state"

# Debug log file (optional)
VISUAL_DEBUG_LOG="${HOME}/.config/claude/visual-debug.log"

# Function to detect terminal capabilities
detect_terminal_env() {
    local can_use_colors=false
    local terminal_info=""
    
    # Check if we're in iTerm2
    if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        terminal_info="iTerm2 detected"
        can_use_colors=true
    elif [[ -n "$ITERM_SESSION_ID" ]]; then
        terminal_info="iTerm2 detected via session ID"
        can_use_colors=true
    else
        terminal_info="Not running in iTerm2 (TERM_PROGRAM=$TERM_PROGRAM)"
    fi
    
    # Check TTY availability
    local tty_status=""
    if [[ -t 1 ]]; then
        tty_status="stdout is TTY"
    elif [[ -t 2 ]]; then
        tty_status="stderr is TTY"
    elif [[ -w /dev/tty ]]; then
        tty_status="/dev/tty is writable"
    else
        tty_status="No TTY available"
        can_use_colors=false
    fi
    
    if [[ -n "$VISUAL_DEBUG_LOG" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Terminal: $terminal_info, TTY: $tty_status" >> "$VISUAL_DEBUG_LOG"
    fi
    
    echo "$can_use_colors"
}

handle_visual_notification() {
    local notification_type="$1"
    local config="$2"
    
    # Check if we can use colors
    if [[ $(detect_terminal_env) != "true" ]]; then
        # Fallback: Try osascript if available
        if command -v osascript >/dev/null 2>&1 && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
            handle_visual_notification_osascript "$notification_type" "$config"
        fi
        return
    fi
    
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
    
    # Based on diagnostic results, prioritize stderr and /dev/tty
    # Method 1: Try /dev/tty first (most reliable when available)
    if [[ -w /dev/tty ]]; then
        printf "\033]6;1;bg;red;brightness;%d\a" "$r" > /dev/tty
        printf "\033]6;1;bg;green;brightness;%d\a" "$g" > /dev/tty
        printf "\033]6;1;bg;blue;brightness;%d\a" "$b" > /dev/tty
    # Method 2: Use stderr as fallback (works in Claude Code hooks)
    elif [[ -t 2 ]]; then
        printf "\033]6;1;bg;red;brightness;%d\a" "$r" >&2
        printf "\033]6;1;bg;green;brightness;%d\a" "$g" >&2
        printf "\033]6;1;bg;blue;brightness;%d\a" "$b" >&2
    # Method 3: Try stdout as last resort
    else
        printf "\033]6;1;bg;red;brightness;%d\a" "$r"
        printf "\033]6;1;bg;green;brightness;%d\a" "$g"
        printf "\033]6;1;bg;blue;brightness;%d\a" "$b"
    fi
}

reset_terminal_color() {
    local color="${1:-#000000}"
    
    # Check if we should reset (only reset if still in a temporary state)
    if [[ -f "$STATE_FILE" ]]; then
        local current_state=$(cat "$STATE_FILE")
        if [[ "$current_state" == "success" ]] || [[ "$current_state" == "error" ]]; then
            # Use same priority as set_terminal_color
            if [[ -w /dev/tty ]]; then
                printf "\033]6;1;bg;*;default\a" > /dev/tty
            elif [[ -t 2 ]]; then
                printf "\033]6;1;bg;*;default\a" >&2
            else
                printf "\033]6;1;bg;*;default\a"
            fi
            echo "default" > "$STATE_FILE"
        fi
    fi
}

# Manual reset function
reset_visual_notification() {
    local config="$1"
    
    # Use same priority as set_terminal_color
    if [[ -w /dev/tty ]]; then
        printf "\033]6;1;bg;*;default\a" > /dev/tty
    elif [[ -t 2 ]]; then
        printf "\033]6;1;bg;*;default\a" >&2
    else
        printf "\033]6;1;bg;*;default\a"
    fi
    echo "default" > "$STATE_FILE"
}

# Fallback method using osascript for iTerm2
handle_visual_notification_osascript() {
    local notification_type="$1"
    local config="$2"
    
    # Get colors from config
    local waiting_color=$(echo "$config" | jq -r '.visual.colors.waiting')
    local success_color=$(echo "$config" | jq -r '.visual.colors.complete_success')
    local error_color=$(echo "$config" | jq -r '.visual.colors.complete_error')
    
    # Convert hex color to RGB components
    convert_hex_to_rgb() {
        local hex="${1#\#}"
        local r=$((16#${hex:0:2} * 257))  # Scale to 16-bit (0-65535)
        local g=$((16#${hex:2:2} * 257))
        local b=$((16#${hex:4:2} * 257))
        echo "$r $g $b"
    }
    
    local rgb_values
    case "$notification_type" in
        "waiting")
            rgb_values=$(convert_hex_to_rgb "$waiting_color")
            echo "waiting" > "$STATE_FILE"
            ;;
        "success")
            rgb_values=$(convert_hex_to_rgb "$success_color")
            echo "success" > "$STATE_FILE"
            # Auto-reset after 3 seconds
            (sleep 3 && osascript -e 'tell application "iTerm2" to tell current session of current window to set background color to {0, 0, 0}') &
            ;;
        "error")
            rgb_values=$(convert_hex_to_rgb "$error_color")
            echo "error" > "$STATE_FILE"
            # Auto-reset after 3 seconds
            (sleep 3 && osascript -e 'tell application "iTerm2" to tell current session of current window to set background color to {0, 0, 0}') &
            ;;
        *)
            osascript -e 'tell application "iTerm2" to tell current session of current window to set background color to {0, 0, 0}'
            echo "default" > "$STATE_FILE"
            return
            ;;
    esac
    
    # Apply color using osascript
    if [[ -n "$rgb_values" ]]; then
        read r g b <<< "$rgb_values"
        osascript -e "tell application \"iTerm2\" to tell current session of current window to set background color to {$r, $g, $b}" 2>/dev/null || true
    fi
}