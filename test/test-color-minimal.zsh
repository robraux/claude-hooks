#!/bin/zsh

# Minimal test to isolate iTerm2 color change issue
# This script tests different methods of sending escape sequences

echo "=== iTerm2 Color Change Test ==="
echo "Testing different output methods..."
echo ""

# Test 1: Direct to stdout
echo "Test 1: Direct stdout (red)"
printf "\033]6;1;bg;red;brightness;255\a"
printf "\033]6;1;bg;green;brightness;0\a"
printf "\033]6;1;bg;blue;brightness;0\a"
sleep 2

# Test 2: Direct to stderr
echo "Test 2: Direct stderr (green)"
printf "\033]6;1;bg;red;brightness;0\a" >&2
printf "\033]6;1;bg;green;brightness;255\a" >&2
printf "\033]6;1;bg;blue;brightness;0\a" >&2
sleep 2

# Test 3: Direct to /dev/tty
echo "Test 3: Direct /dev/tty (blue)"
if [[ -w /dev/tty ]]; then
    printf "\033]6;1;bg;red;brightness;0\a" > /dev/tty
    printf "\033]6;1;bg;green;brightness;0\a" > /dev/tty
    printf "\033]6;1;bg;blue;brightness;255\a" > /dev/tty
else
    echo "  /dev/tty not writable"
fi
sleep 2

# Test 4: Using osascript
echo "Test 4: osascript (orange)"
osascript -e 'tell application "iTerm2" to tell current session of current window to set background color to {65535, 42405, 0}' 2>/dev/null || echo "  osascript failed"
sleep 2

# Reset
echo "Resetting to default..."
printf "\033]6;1;bg;*;default\a"

echo ""
echo "Environment info:"
echo "  TERM: $TERM"
echo "  TERM_PROGRAM: $TERM_PROGRAM"
echo "  TTY: $(tty)"
echo "  Is stdout TTY: $([[ -t 1 ]] && echo "yes" || echo "no")"
echo "  Is stderr TTY: $([[ -t 2 ]] && echo "yes" || echo "no")"