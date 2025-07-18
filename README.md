# iTerm2 Claude Code Notification System

A comprehensive notification system that integrates with iTerm2 and Claude Code to provide multiple alert mechanisms for background processes requiring user attention.

## Features

- **Push Notifications**: Remote notifications to mobile devices via ntfy.sh
- **Visual Indicators**: iTerm2 terminal color changes based on process status
- **Desktop Notifications**: Native macOS notification center alerts
- **Audio Notifications**: Configurable sound alerts
- **Simple Controls**: Easy toggle commands for each notification type

## Installation

### Step 1: Install Dependencies

Install required dependencies via Homebrew:
```bash
brew install jq terminal-notifier
```

Verify installation:
```bash
which jq
which terminal-notifier
```

### Step 2: Download and Setup Project

1. Clone or download this project to your desired location
2. Navigate to the project directory:
   ```bash
   cd /path/to/your/claude-notifications
   ```
3. Make scripts executable:
   ```bash
   chmod +x bin/notifications
   chmod +x hooks/notification-handler.zsh
   chmod +x hooks/post-tool-reset.zsh
   chmod +x hooks/user-prompt-reset.zsh
   chmod +x hooks/stop-handler.zsh
   chmod +x test/test-notifications.zsh
   ```

### Step 3: Create Configuration Directory

Create the Claude Code configuration directory:
```bash
mkdir -p ~/.config/claude
```

### Step 4: Copy Default Configuration

Copy the default configuration file (from the project directory):
```bash
cp config/default-config.json ~/.config/claude/config.json
```

Verify the config file was created:
```bash
ls -la ~/.config/claude/config.json
```

### Step 5: Configure Claude Code Hooks

Edit your Claude Code settings file to add the notification hook:
```bash
nano ~/.claude/settings.json
```

Add the following JSON configuration (if the file is empty, use the entire JSON below. If it has existing content, merge the hooks section):

**Complete configuration (for empty settings file):**
```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$PWD/hooks/notification-handler.zsh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$PWD/hooks/post-tool-reset.zsh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$PWD/hooks/user-prompt-reset.zsh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$PWD/hooks/stop-handler.zsh"
          }
        ]
      }
    ]
  }
}
```

**If you have existing hooks, merge this into your existing configuration:**
```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$PWD/hooks/notification-handler.zsh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$PWD/hooks/post-tool-reset.zsh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$PWD/hooks/user-prompt-reset.zsh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$PWD/hooks/stop-handler.zsh"
          }
        ]
      }
    ]
  }
}
```

### Step 6: Add Notifications Command to PATH (Optional)

To use the `notifications` command from anywhere, add it to your PATH:

**For Zsh (default on macOS):**
```bash
echo "export PATH=\"$PWD/bin:\$PATH\"" >> ~/.zshrc
source ~/.zshrc
```

**For Bash:**
```bash
echo "export PATH=\"$PWD/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc
```

Verify PATH setup:
```bash
which notifications
```

### Step 7: Test Basic Functionality

Test the notifications command:
```bash
./bin/notifications status
```

You should see output showing the current notification settings.

### Step 8: Configure Push Notifications (Optional)

If you want mobile push notifications:

1. Visit [ntfy.sh](https://ntfy.sh)
2. Create a unique topic name (e.g., `claude-notifications-yourname-12345`)
3. Install the ntfy mobile app on your device
4. Subscribe to your topic in the mobile app
5. Edit the configuration file:
   ```bash
   nano ~/.config/claude/config.json
   ```
6. Update the push notification settings:
   ```json
   {
     "push": {
       "enabled": true,
       "ntfy_topic": "your-unique-topic-name",
       "ntfy_server": "ntfy.sh"
     }
   }
   ```
7. Test push notifications:
   ```bash
   curl -d "Test notification" ntfy.sh/your-unique-topic-name
   ```

### Step 9: Run Full System Test

Test all notification channels:
```bash
./test/test-notifications.zsh
```

This will test visual, desktop, push, and audio notifications.

## Usage

### Control Commands

Check notification status:
```bash
./bin/notifications status
```

Enable/disable all notifications:
```bash
./bin/notifications on
./bin/notifications off
```

Initialize configuration:
```bash
./bin/notifications init
```

Toggle individual notification types:
```bash
./bin/notifications push on
./bin/notifications visual off
./bin/notifications desktop on
./bin/notifications audio off
```

Reset visual indicators manually:
```bash
./bin/notifications visual reset
```

Reset to default settings:
```bash
./bin/notifications reset
```

View all available commands:
```bash
./bin/notifications help
```

### Visual Indicators

The system changes your iTerm2 terminal color based on Claude Code's state:
- **Orange**: Waiting for user input or permission
- **Green**: Task completed successfully (auto-resets after 3 seconds)
- **Red**: Error occurred (auto-resets after 3 seconds)
- **Default**: Normal operation

#### Visual State Management
The system includes intelligent state management to automatically reset visual indicators:
- **Persistent State Tracking**: Current visual state is stored in `~/.config/claude/visual/.visual-state`
- **State Directory**: Visual state files are kept in `~/.config/claude/visual/` for organization
- **Automatic Reset**: Visual indicators reset to default when:
  - User submits input via `UserPromptSubmit` hook
  - User approves/denies tool use via `PostToolUse` hook (only if currently in "waiting" state)
- **Manual Reset**: Use `./bin/notifications visual reset` to manually reset indicators
- **Smart Detection**: The system only resets when appropriate, preserving indicators for ongoing states

### Push Notifications

Configure your ntfy.sh topic in `~/.config/claude/config.json`:
```json
{
  "push": {
    "enabled": true,
    "ntfy_topic": "your-unique-topic-name",
    "ntfy_server": "ntfy.sh"
  }
}
```

## Configuration

The configuration file is located at `~/.config/claude/config.json`. Here's the default structure:

```json
{
  "push": {
    "enabled": false,
    "ntfy_topic": "REQUIRED: Set your unique topic name here",
    "ntfy_server": "ntfy.sh"
  },
  "visual": {
    "enabled": true,
    "colors": {
      "waiting": "#FFA500",
      "complete_success": "#00FF00",
      "complete_error": "#FF0000",
      "default": "#000000"
    }
  },
  "desktop": {
    "enabled": true,
    "sound": "default",
    "sticky": false
  },
  "audio": {
    "enabled": true,
    "sound_file": "/System/Library/Sounds/Glass.aiff",
    "volume": 0.5
  }
}
```

## Testing

Run the test script to verify all notification channels work:
```bash
./test/test-notifications.zsh
```

For comprehensive testing and debugging, see the [Testing Guide](docs/TESTING_GUIDE.md) which includes:
- Diagnostic utilities for troubleshooting color issues
- Alternative implementation testing
- Hook debugging procedures
- Manual testing workflows

## Project Structure

```
.
├── README.md                          # This file
├── CLAUDE.md                          # Claude Code instructions
├── notifications.md                   # Original PRD document
├── bin/
│   └── notifications                  # Control CLI command
├── hooks/
│   ├── notification-handler.zsh       # Main notification processor
│   ├── post-tool-reset.zsh           # Visual state reset after tool use
│   ├── user-prompt-reset.zsh         # Visual state reset on user input
│   └── stop-handler.zsh              # Success notification on completion
├── lib/
│   ├── visual-notifications.zsh       # iTerm2 visual integration
│   ├── visual-notifications-tab.zsh   # Tab-specific visual integration
│   ├── push-notifications.zsh         # ntfy.sh integration
│   ├── desktop-notifications.zsh      # macOS notifications
│   └── audio-notifications.zsh        # Sound alerts
├── config/
│   └── default-config.json           # Default configuration
├── test/
│   ├── test-notifications.zsh         # Full system test
│   ├── diagnose-colors.zsh           # Color diagnostics
│   ├── test-color-minimal.zsh        # Minimal color test
│   ├── test-hook-fix.zsh             # Hook debugging test
│   ├── test-hook-minimal.json        # Minimal hook configuration
│   ├── test-osascript-colors.zsh     # osascript color test
│   └── test-stop-hook.zsh            # Stop hook test
└── docs/
    └── TESTING_GUIDE.md               # Testing documentation
```

## How It Works

The system uses multiple Claude Code hooks to provide intelligent notification management:

### Hook System
1. **Notification Hook**: Triggered when Claude Code sends notification messages
   - Receives JSON data containing the notification message
   - Determines notification type based on message content (waiting, success, error)
   - Activates all enabled notification channels
   - Sets visual state for terminal color changes

2. **PostToolUse Hook**: Triggered after Claude Code tool execution
   - Automatically resets visual indicators if currently in "waiting" state
   - Handles cases where user approves/denies tool use without typing

3. **UserPromptSubmit Hook**: Triggered when user submits input
   - Resets visual indicators to default state
   - Ensures clean state after user interaction

4. **Stop Hook**: Triggered when Claude Code finishes responding successfully
   - Sets terminal to green (success) color
   - Sends completion notifications through all enabled channels
   - Does not trigger if stopped due to user interrupt

### Notification Process
1. Claude Code triggers one of the hook events
2. The appropriate hook handler processes the event
3. For notifications: determines notification type and activates channels
4. For resets: intelligently manages visual state
5. Each enabled notification channel is triggered:
   - Visual: Changes terminal color via iTerm2 escape sequences
   - Push: Sends notification to ntfy.sh topic
   - Desktop: Shows macOS notification via terminal-notifier
   - Audio: Plays system sound via afplay

## Troubleshooting

### Notifications not working
1. Check that hooks are properly configured in Claude Code settings
2. Verify dependencies are installed (`jq`, `terminal-notifier`)
3. Test each notification type individually
4. Check config file permissions and syntax

### Visual indicators not changing
1. Ensure you're using iTerm2 (not Terminal.app)
2. Check that visual notifications are enabled in config
3. Try manually resetting: `./bin/notifications visual reset`

### Push notifications not received
1. Verify your ntfy.sh topic is correctly configured
2. Check mobile app subscription
3. Test with curl: `curl -d "test" ntfy.sh/your-topic`

### Advanced Troubleshooting
For detailed debugging and testing procedures, see the [Testing Guide](docs/TESTING_GUIDE.md). This includes:
- Diagnostic scripts for color change issues
- Alternative implementation methods (osascript vs escape sequences)
- Hook debugging techniques
- Manual testing procedures

### Debug Features
The system includes comprehensive debug logging:
- **Debug Log**: `~/.config/claude/notification-debug.log` - Contains detailed execution logs
- **Visual State**: `~/.config/claude/visual/.visual-state` - Tracks current visual state
- **Diagnostic Tools**: Run `./test/diagnose-colors.zsh` to test color functionality

## License

This project is provided as-is for educational and personal use.