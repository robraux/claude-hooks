#!/bin/zsh

# Audio Notifications for macOS
# Plays system sounds based on notification type

play_audio_notification() {
    local notification_type="$1"
    local config="$2"
    local directory_name="$3"
    
    # Get audio settings
    local sound_file=$(echo "$config" | jq -r '.audio.sound_file')
    local volume=$(echo "$config" | jq -r '.audio.volume')
    
    # Set default sound based on notification type if not specified
    if [[ -z "$sound_file" ]] || [[ "$sound_file" == "null" ]]; then
        case "$notification_type" in
            "waiting")
                sound_file="/System/Library/Sounds/Glass.aiff"
                ;;
            "success")
                sound_file="/System/Library/Sounds/Hero.aiff"
                ;;
            "error")
                sound_file="/System/Library/Sounds/Basso.aiff"
                ;;
            *)
                sound_file="/System/Library/Sounds/Glass.aiff"
                ;;
        esac
    fi
    
    # Check if sound file exists
    if [[ ! -f "$sound_file" ]]; then
        echo "Warning: Sound file not found: $sound_file" >&2
        return 1
    fi
    
    # Play sound using afplay
    if command -v afplay &> /dev/null; then
        if [[ -n "$volume" ]] && [[ "$volume" != "null" ]]; then
            afplay -v "$volume" "$sound_file" &
        else
            afplay "$sound_file" &
        fi
    else
        echo "Warning: afplay not found" >&2
        return 1
    fi
}