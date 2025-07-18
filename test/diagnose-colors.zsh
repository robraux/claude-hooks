#!/bin/zsh

# Diagnostic script for iTerm2 color issues with Claude Code hooks

echo "=== iTerm2 Color Diagnostic ==="
echo ""

# 1. Environment Check
echo "1. Environment Variables:"
echo "   TERM: $TERM"
echo "   TERM_PROGRAM: $TERM_PROGRAM"
echo "   TERM_PROGRAM_VERSION: $TERM_PROGRAM_VERSION"
echo "   ITERM_SESSION_ID: $ITERM_SESSION_ID"
echo "   COLORTERM: $COLORTERM"
echo ""

# 2. TTY Check
echo "2. TTY Status:"
echo "   Current TTY: $(tty)"
echo "   STDIN is TTY: $([[ -t 0 ]] && echo "YES" || echo "NO")"
echo "   STDOUT is TTY: $([[ -t 1 ]] && echo "YES" || echo "NO")"
echo "   STDERR is TTY: $([[ -t 2 ]] && echo "YES" || echo "NO")"
echo "   /dev/tty writable: $([[ -w /dev/tty ]] && echo "YES" || echo "NO")"
echo ""

# 3. Process Information
echo "3. Process Information:"
echo "   Script PID: $$"
echo "   Parent PID: $PPID"
echo "   Parent Process:"
ps -p $PPID -o comm= 2>/dev/null || echo "   Unable to determine"
echo ""

# 4. Test Color Methods
echo "4. Testing Color Change Methods:"
echo ""

echo "   a) Testing escape sequences to stdout..."
printf "\033]6;1;bg;red;brightness;255\a"
printf "\033]6;1;bg;green;brightness;0\a"
printf "\033]6;1;bg;blue;brightness;0\a"
echo "      Did the color change to RED? (wait 2 seconds)"
sleep 2

echo "   b) Testing escape sequences to stderr..."
printf "\033]6;1;bg;red;brightness;0\a" >&2
printf "\033]6;1;bg;green;brightness;255\a" >&2
printf "\033]6;1;bg;blue;brightness;0\a" >&2
echo "      Did the color change to GREEN? (wait 2 seconds)"
sleep 2

echo "   c) Testing escape sequences to /dev/tty..."
if [[ -w /dev/tty ]]; then
    printf "\033]6;1;bg;red;brightness;0\a" > /dev/tty
    printf "\033]6;1;bg;green;brightness;0\a" > /dev/tty
    printf "\033]6;1;bg;blue;brightness;255\a" > /dev/tty
    echo "      Did the color change to BLUE? (wait 2 seconds)"
else
    echo "      SKIPPED - /dev/tty not writable"
fi
sleep 2

echo "   d) Testing osascript tab color..."
osascript -e 'tell application "iTerm2" to tell current session of current window to set tab color to {65535, 42405, 0}' 2>&1
echo "      Did the tab color change to ORANGE? (wait 2 seconds)"
sleep 2

echo "   e) Resetting colors..."
printf "\033]6;1;bg;*;default\a"
osascript -e 'tell application "iTerm2" to tell current session of current window to set tab color to {0, 0, 0}' 2>/dev/null

echo ""
echo "5. Hook Simulation:"
echo "   Creating a simulated Claude Code hook environment..."

# Simulate hook execution
(
    # Redirect stdout to capture output like Claude Code might
    exec 1>/tmp/hook-output.txt
    
    # Try color change
    printf "\033]6;1;bg;red;brightness;255\a"
    printf "\033]6;1;bg;green;brightness;255\a"
    printf "\033]6;1;bg;blue;brightness;0\a"
)

echo "   Hook simulation complete. Check if color changed to YELLOW."
echo ""

echo "6. Recommendations:"
echo "   - If manual tests work but hook simulation doesn't, the issue is output redirection"
echo "   - If osascript works, use that as the primary method"
echo "   - Check ~/.config/claude/notification-debug.log for hook execution details"
echo ""
echo "Done!"