#!/bin/zsh

# Push Notifications via ntfy.sh
# Sends notifications to mobile devices

send_push_notification() {
    local message="$1"
    local notification_type="$2"
    local config="$3"
    
    # Get ntfy configuration
    local ntfy_topic=$(echo "$config" | jq -r '.push.ntfy_topic')
    local ntfy_server=$(echo "$config" | jq -r '.push.ntfy_server')
    
    # Check if topic is configured
    if [[ -z "$ntfy_topic" ]] || [[ "$ntfy_topic" == "REQUIRED: Set your unique topic name here" ]]; then
        echo "Warning: ntfy topic not configured" >&2
        return 1
    fi
    
    # Set priority and tags based on notification type
    local priority="default"
    local tags=""
    
    case "$notification_type" in
        "waiting")
            priority="high"
            tags="hourglass"
            ;;
        "success")
            priority="default"
            tags="white_check_mark"
            ;;
        "error")
            priority="urgent"
            tags="x"
            ;;
        *)
            priority="default"
            tags="information_source"
            ;;
    esac
    
    # Send notification via curl
    curl -s \
        -H "Priority: $priority" \
        -H "Tags: $tags" \
        -H "Title: Claude Code" \
        -d "$message" \
        "https://${ntfy_server}/${ntfy_topic}" > /dev/null
}