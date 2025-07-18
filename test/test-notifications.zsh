#!/bin/zsh

# Test script for Claude Code Notification System
# Simulates different notification types to verify functionality

PROJECT_DIR="${0:a:h:h}"

echo "🧪 Testing Claude Code Notification System"
echo "========================================="

# Check if config exists
CONFIG_FILE="${HOME}/.config/claude/config.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Config file not found. Run './install.zsh' first."
    exit 1
fi

echo "✅ Config file found"

# Source the notification modules
source "${PROJECT_DIR}/lib/visual-notifications.zsh"
source "${PROJECT_DIR}/lib/push-notifications.zsh"
source "${PROJECT_DIR}/lib/desktop-notifications.zsh"
source "${PROJECT_DIR}/lib/audio-notifications.zsh"

# Load config
CONFIG=$(cat "$CONFIG_FILE")

echo ""
echo "📋 Current notification settings:"
echo "Push:    $(echo "$CONFIG" | jq -r '.push.enabled')"
echo "Visual:  $(echo "$CONFIG" | jq -r '.visual.enabled')"
echo "Desktop: $(echo "$CONFIG" | jq -r '.desktop.enabled')"
echo "Audio:   $(echo "$CONFIG" | jq -r '.audio.enabled')"
echo ""

# Test function
test_notification() {
    local type="$1"
    local message="$2"
    
    echo "🔔 Testing ${type} notification: $message"
    
    case "$type" in
        "visual")
            if [[ $(echo "$CONFIG" | jq -r '.visual.enabled') == "true" ]]; then
                handle_visual_notification "$message" "$CONFIG"
                echo "   ✅ Visual notification sent"
            else
                echo "   ⏭️  Visual notifications disabled"
            fi
            ;;
        "push")
            if [[ $(echo "$CONFIG" | jq -r '.push.enabled') == "true" ]]; then
                send_push_notification "Test: $message notification" "$message" "$CONFIG"
                echo "   ✅ Push notification sent"
            else
                echo "   ⏭️  Push notifications disabled"
            fi
            ;;
        "desktop")
            if [[ $(echo "$CONFIG" | jq -r '.desktop.enabled') == "true" ]]; then
                send_desktop_notification "Test: $message notification" "$message" "$CONFIG"
                echo "   ✅ Desktop notification sent"
            else
                echo "   ⏭️  Desktop notifications disabled"
            fi
            ;;
        "audio")
            if [[ $(echo "$CONFIG" | jq -r '.audio.enabled') == "true" ]]; then
                play_audio_notification "$message" "$CONFIG"
                echo "   ✅ Audio notification played"
            else
                echo "   ⏭️  Audio notifications disabled"
            fi
            ;;
    esac
    
    sleep 1
}

# Test all notification types
echo "🎯 Testing all notification channels..."
echo ""

# Test waiting state
test_notification "visual" "waiting"
test_notification "push" "waiting"
test_notification "desktop" "waiting"
test_notification "audio" "waiting"

echo ""
echo "⏳ Waiting 2 seconds..."
sleep 2

# Test success state
test_notification "visual" "success"
test_notification "push" "success"
test_notification "desktop" "success"
test_notification "audio" "success"

echo ""
echo "⏳ Waiting 2 seconds..."
sleep 2

# Test error state
test_notification "visual" "error"
test_notification "push" "error"
test_notification "desktop" "error"
test_notification "audio" "error"

echo ""
echo "⏳ Waiting 5 seconds for auto-reset..."
sleep 5

# Test hook handler directly
echo ""
echo "🔧 Testing hook handler directly..."
echo ""

# Simulate Claude Code notification events
test_hook_event() {
    local message="$1"
    local json_input="{\"hook_event_name\": \"Notification\", \"message\": \"$message\"}"
    
    echo "📨 Testing hook with message: $message"
    echo "$json_input" | "${PROJECT_DIR}/hooks/notification-handler.zsh"
    
    if [[ $? -eq 0 ]]; then
        echo "   ✅ Hook handler executed successfully"
    else
        echo "   ❌ Hook handler failed"
    fi
    
    sleep 2
}

test_hook_event "Claude needs your permission to use Bash"
test_hook_event "Claude is waiting for your input"
test_hook_event "Task completed successfully"
test_hook_event "Error: Command failed"

echo ""
echo "🎉 Testing complete!"
echo ""
echo "📝 Manual verification steps:"
echo "1. Check if your terminal color changed during visual tests"
echo "2. Look for desktop notifications in macOS notification center"
echo "3. Verify push notifications arrived on your mobile device (if configured)"
echo "4. Confirm you heard audio notifications"
echo ""
echo "💡 If any notifications didn't work:"
echo "- Check dependencies: brew install jq terminal-notifier"
echo "- Verify config: cat ~/.config/claude/config.json"
echo "- Test individual commands: ./bin/notifications status"