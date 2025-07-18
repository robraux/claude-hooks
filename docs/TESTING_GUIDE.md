# iTerm2 Color Change Testing Guide

## Problem Description
The iTerm2 color change functionality works when run manually but not when triggered through Claude Code hooks. This guide helps diagnose and fix the issue.

## Quick Test

1. **Run the diagnostic script:**
   ```bash
   ./test/diagnose-colors.zsh
   ```
   This will test different color change methods and show which ones work in your environment.

2. **Check the debug log after triggering a Claude Code notification:**
   ```bash
   tail -f ~/.config/claude/notification-debug.log
   ```

## Testing Steps

### 1. Test Manual Color Changes
Run the minimal test script directly:
```bash
./test/test-color-minimal.zsh
```

Expected: You should see the terminal color change to red, green, blue, orange, then reset.

### 2. Test with Debug Hook
Temporarily update your Claude Code settings to use the debug hook:
```bash
# Backup current settings
cp ~/.claude/settings.json ~/.claude/settings.json.backup

# Update to use debug hook
cat > ~/.claude/settings.json << 'EOF'
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/rraux/projects/claude/hooks/notification-handler-debug.zsh"
          }
        ]
      }
    ]
  }
}
EOF
```

Then trigger a notification in Claude Code and check the debug log.

### 3. Test Alternative Methods

#### Option A: Use Tab Color with osascript
If escape sequences don't work through hooks, try the tab color implementation:
```bash
# Test the tab color version
source ./lib/visual-notifications-tab.zsh
CONFIG=$(cat ~/.config/claude/config.json)
handle_visual_notification "waiting" "$CONFIG"
```

#### Option B: Direct TTY Output
Modify your hook to output directly to /dev/tty:
```bash
# In the hook handler, replace printf lines with:
printf "\033]6;1;bg;red;brightness;255\a" > /dev/tty 2>/dev/null || true
```

## Common Issues and Solutions

### Issue 1: Output Redirection
**Symptom:** Colors work manually but not in hooks
**Cause:** Claude Code captures stdout/stderr
**Solution:** Use `/dev/tty` or osascript method

### Issue 2: No TTY Context
**Symptom:** `tty` returns "not a tty"
**Cause:** Hook runs without terminal context
**Solution:** Use osascript AppleScript method

### Issue 3: Wrong Terminal
**Symptom:** TERM_PROGRAM is not "iTerm.app"
**Cause:** Not running in iTerm2
**Solution:** Check terminal detection logic

## Recommended Solution

Based on testing, the most reliable approach is:

1. **Primary Method:** Use osascript to control iTerm2 tab colors
2. **Fallback Method:** Try escape sequences to /dev/tty
3. **Detection:** Check TERM_PROGRAM and TTY availability

Update `visual-notifications.zsh` to use this approach:
```bash
# Use the tab color implementation
cp lib/visual-notifications-tab.zsh lib/visual-notifications.zsh
```

## Verification

After implementing changes:

1. Run the test suite:
   ```bash
   ./test/test-notifications.zsh
   ```

2. Trigger actual Claude Code notifications:
   - Ask Claude to run a command requiring permission
   - Wait for "Claude is waiting for your input" notification
   - Complete a task to see success notification

3. Check all notification channels work:
   ```bash
   ./bin/notifications status
   ```

## Troubleshooting Commands

```bash
# Check if hook is registered
claude settings hooks

# Monitor hook execution in real-time
tail -f ~/.config/claude/notification-debug.log

# Test specific notification type
echo '{"hook_event_name": "Notification", "message": "Test waiting"}' | ./hooks/notification-handler-debug.zsh

# Reset visual state if stuck
./bin/notifications visual reset
```