#!/bin/zsh

# Test different osascript methods for iTerm2 color control

echo "=== Testing iTerm2 osascript Methods ==="
echo ""

# Method 1: Background color (what the diagnostic tried)
echo "1. Testing background color change..."
osascript <<'EOF' 2>&1
tell application "iTerm2"
    tell current session of current window
        set background color to {65535, 0, 0}  -- Red
    end tell
end tell
EOF
echo "   Did the BACKGROUND turn red? (wait 2 seconds)"
sleep 2

# Method 2: Tab color (using correct property name)
echo ""
echo "2. Testing tab color indicator..."
osascript <<'EOF' 2>&1
tell application "iTerm2"
    tell current window
        tell current tab
            set tint color to {65535, 42405, 0}  -- Orange
        end tell
    end tell
end tell
EOF
echo "   Did the TAB COLOR INDICATOR turn orange? (wait 2 seconds)"
sleep 2

# Method 3: Title bar color (newer iTerm2 feature)
echo ""
echo "3. Testing title bar color..."
osascript <<'EOF' 2>&1
tell application "iTerm2"
    tell current window
        tell current tab
            tell current session
                -- This might work on newer versions
                set background color to {0, 65535, 0}  -- Green
            end tell
        end tell
    end tell
end tell
EOF
echo "   Did anything turn green? (wait 2 seconds)"
sleep 2

# Reset
echo ""
echo "4. Resetting colors..."
osascript <<'EOF' 2>&1
tell application "iTerm2"
    tell current window
        tell current tab
            -- Reset tint
            set tint color to {0, 0, 0}
        end tell
    end tell
end tell
EOF

# Reset using escape sequences too
printf "\033]6;1;bg;*;default\a" >&2

echo ""
echo "Done! Which methods worked?"
echo ""
echo "Note: Different iTerm2 versions support different AppleScript properties."
echo "The error you saw suggests 'tab color' isn't the right property name."