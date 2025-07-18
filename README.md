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
2. Make scripts executable:
   ```bash
   chmod +x /Users/rraux/projects/claude/bin/notifications
   chmod +x /Users/rraux/projects/claude/hooks/notification-handler.zsh
   chmod +x /Users/rraux/projects/claude/test/test-notifications.zsh
   ```

### Step 3: Create Configuration Directory

Create the Claude Code configuration directory:
```bash
mkdir -p ~/.config/claude
```

### Step 4: Copy Default Configuration

Copy the default configuration file:
```bash
cp /Users/rraux/projects/claude/config/default-config.json ~/.config/claude/config.json
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
            "command": "/Users/rraux/projects/claude/hooks/notification-handler.zsh"
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
            "command": "/Users/rraux/projects/claude/hooks/notification-handler.zsh"
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
echo 'export PATH="/Users/rraux/projects/claude/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**For Bash:**
```bash
echo 'export PATH="/Users/rraux/projects/claude/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify PATH setup:
```bash
which notifications
```

### Step 7: Test Basic Functionality

Test the notifications command:
```bash
/Users/rraux/projects/claude/bin/notifications status
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
/Users/rraux/projects/claude/test/test-notifications.zsh
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

### Visual Indicators

The system changes your iTerm2 terminal color based on Claude Code's state:
- **Orange**: Waiting for user input or permission
- **Green**: Task completed successfully (auto-resets after 3 seconds)
- **Red**: Error occurred (auto-resets after 3 seconds)
- **Default**: Normal operation

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

## Project Structure

```
.
├── README.md                          # This file
├── bin/
│   └── notifications                  # Control CLI command
├── hooks/
│   └── notification-handler.zsh       # Main hook handler
├── lib/
│   ├── visual-notifications.zsh       # iTerm2 visual integration
│   ├── push-notifications.zsh         # ntfy.sh integration
│   ├── desktop-notifications.zsh      # macOS notifications
│   └── audio-notifications.zsh        # Sound alerts
├── config/
│   └── default-config.json           # Default configuration
└── test/
    └── test-notifications.zsh         # Testing utilities
```

## How It Works

1. Claude Code triggers a `Notification` hook event
2. The hook handler receives JSON data containing the notification message
3. Based on the message content, it determines the notification type (waiting, success, error)
4. The handler checks the configuration for enabled notification types
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

## License

This project is provided as-is for educational and personal use.