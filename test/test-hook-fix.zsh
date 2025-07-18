#!/bin/zsh

# Test the fixed visual notifications through a simulated hook environment

echo "=== Testing Fixed Visual Notifications ==="
echo ""

# Source the updated visual notifications
source "$(dirname "$0")/../lib/visual-notifications.zsh"

# Load config
CONFIG_FILE="${HOME}/.config/claude/config.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Creating test config..."
    mkdir -p "${HOME}/.config/claude"
    cat > "$CONFIG_FILE" << 'EOF'
{
  "visual": {
    "enabled": true,
    "colors": {
      "waiting": "#FFA500",
      "complete_success": "#00FF00",
      "complete_error": "#FF0000",
      "default": "#000000"
    }
  }
}
EOF
fi

CONFIG=$(cat "$CONFIG_FILE")

echo "1. Testing in simulated hook environment (stdout redirected)..."
(
    # Simulate Claude Code hook environment
    exec 1>/tmp/hook-test-output.txt
    
    echo "Testing WAITING color (orange)..."
    handle_visual_notification "waiting" "$CONFIG"
)
echo "   Did the terminal turn ORANGE? (wait 2 seconds)"
sleep 2

echo ""
echo "2. Testing SUCCESS notification..."
handle_visual_notification "success" "$CONFIG"
echo "   Did the terminal turn GREEN? (should auto-reset after 3 seconds)"
sleep 4

echo ""
echo "3. Testing ERROR notification..."
handle_visual_notification "error" "$CONFIG"
echo "   Did the terminal turn RED? (should auto-reset after 3 seconds)"
sleep 4

echo ""
echo "4. Testing manual reset..."
reset_visual_notification "$CONFIG"
echo "   Terminal should be back to default."

echo ""
echo "✅ Test complete!"
echo ""
echo "If colors changed correctly, the fix is working!"
echo "You can now use the regular notification handler with Claude Code."