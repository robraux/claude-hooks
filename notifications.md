# iTerm2 Claude Code Notification System PRD

## Overview
A comprehensive notification system that integrates with iTerm2 and Claude Code to provide multiple alert mechanisms for background processes requiring user attention.

## Core Requirements

### 1. Notification Types & Controls

#### Push Notifications
- **Feature**: Remote push notifications to mobile devices
- **Toggle**: `notifications push on|off`
- **Use Case**: Receive alerts when away from computer
- **Implementation**: Integration with push notification service (APNs/FCM)

#### Visual Terminal Indicators
- **Feature**: iTerm2 terminal header color changes based on status
- **States**:
  - Default color: Normal operation
  - Attention color: Waiting for user feedback
  - Error color: Process requires immediate attention
- **Toggle**: `notifications visual on|off`

#### Local Mac Notifications
- **Feature**: macOS native notification center alerts
- **Toggle**: `notifications local on|off`
- **Customization**: Sound, banner vs alert style, persistence

#### Audio Notifications
- **Feature**: Configurable audio alerts
- **Toggle**: `notifications audio on|off`
- **Options**: Custom sound files, volume control, repeat intervals

### 2. Status & Control Interface

#### Status Display
**Command**: `notifications status`
```
Push Notifications:  ✅ ON
Visual Indicators:   ✅ ON
Desktop Notifications: ❌ OFF
Audio Notifications: ✅ ON
```

#### Quick Controls
**Commands**:
```
notifications on          # Enable all notifications
notifications off         # Disable all notifications
notifications reset       # Reset to default settings
```

#### Individual Controls
```bash
notifications push on|off
notifications visual on|off
notifications local on|off
notifications audio on|off
```

### 3. Monitoring System

#### Background Process Monitoring
- **Hook Integration**: Claude Code process state changes
- **Trigger Events**:
  - Code execution completion
  - Error states requiring intervention
  - User input requested
  - Long-running process milestones

#### Notification Triggers
- Process completion (success/failure)
- User input required
- Error conditions
- Timeout events
- Custom trigger conditions

### 4. Configuration

#### Settings File Location
- `~/.config/claude/config.json` - Notification settings and toggles
- `~/.claude/settings.json` - Claude Code hook configuration

#### Customizable Options
```json
{
  "push": {
    "enabled": true,
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

#### Claude Code Hook Configuration
- **Notification Hook**: Processes incoming notification events
- **Reset Hook**: `UserPromptSubmit` event for visual indicator reset
- **Integration**: User manually adds hooks to their existing Claude Code settings
- **Safety**: No automatic modification of existing hook configurations
```

## Technical Specifications

## Technical Specifications

### Claude Code Hook Integration
- **Available Hook Events**: `PreToolUse`, `PostToolUse`, `Notification`, `Stop`
- **Used Events**:
  - `Notification`: Processes notification events from Claude Code
  - `UserPromptSubmit`: Resets visual indicators when user responds
- **Data Format**: JSON via stdin containing notification type and message
- **Configuration**: Hooks manually added to `~/.claude/settings.json`

### Claude Code Hook Events (from documentation)
**Available Events:**
- **PreToolUse**: Runs before tool calls, can block them
- **PostToolUse**: Runs after tool completes successfully
- **Notification**: Runs when Claude Code sends notifications *(this is what we use)*
- **Stop**: Runs when Claude Code finishes responding

**Our Usage:**
- **Notification hook**: Captures all notification events from Claude Code
- **Visual reset**: Manual reset command only (no automatic reset hook available)
- **Method**: Terminal escape sequences for color control
- **Color States**:
  - Default: Normal terminal color
  - Orange: Waiting for permission or input
  - Green: Task completed successfully (3-second auto-reset)
  - Red: Task completed with errors (3-second auto-reset)

### Notification Services
- **Desktop**: `terminal-notifier` for native macOS notifications
- **Push**: `ntfy.sh` for mobile/remote notifications
- **Audio**: macOS system sounds

### Dependencies
- **jq**: JSON parsing for hook data
- **terminal-notifier**: Desktop notifications
- **curl**: Push notifications (built into macOS)

## Implementation Approach

### Core Components
1. **Hook Handler Script**: Processes Claude Code notification events
2. **Configuration Management**: JSON config file for settings and toggles
3. **Control Commands**: CLI interface for toggling notification types
4. **Visual Integration**: Terminal color control via escape sequences

### Data Flow
1. Claude Code triggers notification event
2. Hook handler receives JSON with notification type and message
3. Handler checks current toggle states from `~/.config/claude/config.json`
4. Executes enabled notification types (visual, desktop, push, audio)
5. Visual indicators reset on UserPromptSubmit or after timeout

### Story 1: Background Development
"As a developer running long builds, I want to receive a push notification when my build completes so I can check results from anywhere."

### Story 2: Code Review
"As a developer using Claude Code for refactoring, I want my terminal to change color when Claude needs my input so I can easily see when attention is required."

### Story 3: Multi-tasking
"As a developer working on multiple projects, I want audio notifications for critical errors so I don't miss important issues while focused on other work."

### Story 4: Remote Work
"As a remote developer, I want to start long-running processes and receive mobile notifications so I can step away from my desk confidently."

## Success Metrics
- Reduced context switching time
- Improved responsiveness to process completion
- User adoption rate of different notification types
- Reduction in missed critical events

## Installation & Setup Requirements

### Installation Approach
**Manual Installation Only** (no automated script touching existing files)

### Setup Steps
1. **Install dependencies**: `jq`, `terminal-notifier`
2. **Download components**: Hook handler script and control commands
3. **Create configuration**: `~/.config/claude/config.json` with notification settings
4. **Manual hook integration**: User adds hooks to their Claude Code settings
5. **ntfy.sh setup**: User creates and configures topic

### File Safety Requirements
- **No automatic editing** of existing Claude Code settings
- **Backup prompts** before any file modifications
- **Additive only**: Only add new hooks, never modify existing ones
- **Validation**: Check existing hook structure before suggesting additions

### ntfy.sh Configuration
- **User-provided topic**: Must be manually generated and kept private
- **Setup guidance**: Clear instructions for topic creation and mobile setup
- **Validation**: Test connectivity before completing setup

## Implementation Phases

### Phase 1: Core Foundation
- Hook handler script with notification parsing
- Basic configuration file management
- Manual toggle commands (`notifications on|off`)
- ntfy.sh integration with topic configuration

### Phase 2: Visual Integration
- iTerm2 escape sequence integration for terminal colors
- Auto-reset mechanism using PreToolUse hook
- Color state management and manual reset commands

### Phase 3: Desktop Notifications
- `terminal-notifier` integration with contextual messages
- macOS system sound integration
- Desktop notification toggle controls

### Phase 4: Setup & Polish
- Automated installation script
- Error handling and fallback mechanisms
- Status display and comprehensive documentation

## Visual Reset Behavior

**Reset Triggers:**
- **UserPromptSubmit hook**: Automatically resets color when user submits input
- **Auto-timeout**: Complete notifications reset after 3 seconds
- **Manual reset**: `notifications visual reset` command

**Color Duration:**
- Waiting states: Persist until user submits input or manual reset
- Complete states: Auto-reset after brief display

### Dependencies
- **jq**: JSON parsing (`brew install jq`)
- **terminal-notifier**: Desktop notifications (`brew install terminal-notifier`)
- **curl**: Included with macOS (for ntfy.sh)
- **Claude Code**: Must be installed and configured

---
# CLAUDE HOOKS REFERENCE MATERIAL

> This page provides reference documentation for implementing hooks in Claude Code.

<Tip>
  For a quickstart guide with examples, see [Get started with Claude Code hooks](/en/docs/claude-code/hooks-guide).
</Tip>

## Configuration

Claude Code hooks are configured in your
[settings files](/en/docs/claude-code/settings):

* `~/.claude/settings.json` - User settings
* `.claude/settings.json` - Project settings
* `.claude/settings.local.json` - Local project settings (not committed)
* Enterprise managed policy settings

### Structure

Hooks are organized by matchers, where each matcher can have multiple hooks:

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "your-command-here"
          }
        ]
      }
    ]
  }
}
```

* **matcher**: Pattern to match tool names, case-sensitive (only applicable for
  `PreToolUse` and `PostToolUse`)
  * Simple strings match exactly: `Write` matches only the Write tool
  * Supports regex: `Edit|Write` or `Notebook.*`
  * If omitted or empty string, hooks run for all matching events
* **hooks**: Array of commands to execute when the pattern matches
  * `type`: Currently only `"command"` is supported
  * `command`: The bash command to execute
  * `timeout`: (Optional) How long a command should run, in seconds, before
    canceling that specific command.

For events like `UserPromptSubmit`, `Notification`, `Stop`, and `SubagentStop` that don't use matchers, you can omit the matcher field:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/prompt-validator.py"
          }
        ]
      }
    ]
  }
}
```

<Warning>
  `"matcher": "*"` is invalid. Instead, omit "matcher" or use `"matcher": ""`.
</Warning>

## Hook Events

### PreToolUse

Runs after Claude creates tool parameters and before processing the tool call.

**Common matchers:**

* `Task` - Agent tasks
* `Bash` - Shell commands
* `Glob` - File pattern matching
* `Grep` - Content search
* `Read` - File reading
* `Edit`, `MultiEdit` - File editing
* `Write` - File writing
* `WebFetch`, `WebSearch` - Web operations

### PostToolUse

Runs immediately after a tool completes successfully.

Recognizes the same matcher values as PreToolUse.

### Notification

Runs when Claude Code sends notifications. Notifications are sent when:

1. Claude needs your permission to use a tool. Example: "Claude needs your permission to use Bash"
2. The prompt input has been idle for at least 60 seconds. "Claude is waiting for your input"

### UserPromptSubmit

Runs when the user submits a prompt, before Claude processes it. This allows you to add additional context based on the prompt/conversation, validate prompts, or block certain types of prompts.

### Stop

Runs when the main Claude Code agent has finished responding. Does not run if the stoppage occurred due to a user interrupt.

### SubagentStop

Runs when a Claude Code subagent (Task tool call) has finished responding.

### PreCompact

Runs before Claude Code is about to run a compact operation.

**Matchers:**

* `manual` - Invoked from `/compact`
* `auto` - Invoked from auto-compact (due to full context window)

## Hook Input

Hooks receive JSON data via stdin containing session information and
event-specific data:

```typescript
{
  // Common fields
  session_id: string
  transcript_path: string  // Path to conversation JSON
  cwd: string              // The current working directory when the hook is invoked

  // Event-specific fields
  hook_event_name: string
  ...
}
```

### PreToolUse Input

The exact schema for `tool_input` depends on the tool.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  }
}
```

### PostToolUse Input

The exact schema for `tool_input` and `tool_response` depends on the tool.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  },
  "tool_response": {
    "filePath": "/path/to/file.txt",
    "success": true
  }
}
```

### Notification Input

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "Notification",
  "message": "Task completed successfully"
}
```

### UserPromptSubmit Input

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate the factorial of a number"
}
```

### Stop and SubagentStop Input

`stop_hook_active` is true when Claude Code is already continuing as a result of
a stop hook. Check this value or process the transcript to prevent Claude Code
from running indefinitely.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "hook_event_name": "Stop",
  "stop_hook_active": true
}
```

### PreCompact Input

For `manual`, `custom_instructions` comes from what the user passes into
`/compact`. For `auto`, `custom_instructions` is empty.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": ""
}
```

## Hook Output

There are two ways for hooks to return output back to Claude Code. The output
communicates whether to block and any feedback that should be shown to Claude
and the user.

### Simple: Exit Code

Hooks communicate status through exit codes, stdout, and stderr:

* **Exit code 0**: Success. `stdout` is shown to the user in transcript mode
  (CTRL-R).
* **Exit code 2**: Blocking error. `stderr` is fed back to Claude to process
  automatically. See per-hook-event behavior below.
* **Other exit codes**: Non-blocking error. `stderr` is shown to the user and
  execution continues.

<Warning>
  Reminder: Claude Code does not see stdout if the exit code is 0.
</Warning>

#### Exit Code 2 Behavior

| Hook Event         | Behavior                                                           |
| ------------------ | ------------------------------------------------------------------ |
| `PreToolUse`       | Blocks the tool call, shows stderr to Claude                       |
| `PostToolUse`      | Shows stderr to Claude (tool already ran)                          |
| `Notification`     | N/A, shows stderr to user only                                     |
| `UserPromptSubmit` | Blocks prompt processing, erases prompt, shows stderr to user only |
| `Stop`             | Blocks stoppage, shows stderr to Claude                            |
| `SubagentStop`     | Blocks stoppage, shows stderr to Claude subagent                   |
| `PreCompact`       | N/A, shows stderr to user only                                     |

### Advanced: JSON Output

Hooks can return structured JSON in `stdout` for more sophisticated control:

#### Common JSON Fields

All hook types can include these optional fields:

```json
{
  "continue": true, // Whether Claude should continue after hook execution (default: true)
  "stopReason": "string" // Message shown when continue is false
  "suppressOutput": true, // Hide stdout from transcript mode (default: false)
}
```

If `continue` is false, Claude stops processing after the hooks run.

* For `PreToolUse`, this is different from `"decision": "block"`, which only
  blocks a specific tool call and provides automatic feedback to Claude.
* For `PostToolUse`, this is different from `"decision": "block"`, which
  provides automated feedback to Claude.
* For `UserPromptSubmit`, this prevents the prompt from being processed.
* For `Stop` and `SubagentStop`, this takes precedence over any
  `"decision": "block"` output.
* In all cases, `"continue" = false` takes precedence over any
  `"decision": "block"` output.

`stopReason` accompanies `continue` with a reason shown to the user, not shown
to Claude.

#### `PreToolUse` Decision Control

`PreToolUse` hooks can control whether a tool call proceeds.

* "approve" bypasses the permission system. `reason` is shown to the user but
  not to Claude.
* "block" prevents the tool call from executing. `reason` is shown to Claude.
* `undefined` leads to the existing permission flow. `reason` is ignored.

```json
{
  "decision": "approve" | "block" | undefined,
  "reason": "Explanation for decision"
}
```

#### `PostToolUse` Decision Control

`PostToolUse` hooks can control whether a tool call proceeds.

* "block" automatically prompts Claude with `reason`.
* `undefined` does nothing. `reason` is ignored.

```json
{
  "decision": "block" | undefined,
  "reason": "Explanation for decision"
}
```

#### `UserPromptSubmit` Decision Control

`UserPromptSubmit` hooks can control whether a user prompt is processed.

* `"block"` prevents the prompt from being processed. The submitted prompt is erased from context. `"reason"` is shown to the user but not added to context.
* `undefined` allows the prompt to proceed normally. `"reason"` is ignored.

```json
{
  "decision": "block" | undefined,
  "reason": "Explanation for decision"
}
```

#### `Stop`/`SubagentStop` Decision Control

`Stop` and `SubagentStop` hooks can control whether Claude must continue.

* "block" prevents Claude from stopping. You must populate `reason` for Claude
  to know how to proceed.
* `undefined` allows Claude to stop. `reason` is ignored.

```json
{
  "decision": "block" | undefined,
  "reason": "Must be provided when Claude is blocked from stopping"
}
```

#### JSON Output Example: Bash Command Editing

```python
#!/usr/bin/env python3
import json
import re
import sys

# Define validation rules as a list of (regex pattern, message) tuples
VALIDATION_RULES = [
    (
        r"\bgrep\b(?!.*\|)",
        "Use 'rg' (ripgrep) instead of 'grep' for better performance and features",
    ),
    (
        r"\bfind\s+\S+\s+-name\b",
        "Use 'rg --files | rg pattern' or 'rg --files -g pattern' instead of 'find -name' for better performance",
    ),
]


def validate_command(command: str) -> list[str]:
    issues = []
    for pattern, message in VALIDATION_RULES:
        if re.search(pattern, command):
            issues.append(message)
    return issues


try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
    sys.exit(1)

tool_name = input_data.get("tool_name", "")
tool_input = input_data.get("tool_input", {})
command = tool_input.get("command", "")

if tool_name != "Bash" or not command:
    sys.exit(1)

# Validate the command
issues = validate_command(command)

if issues:
    for message in issues:
        print(f"• {message}", file=sys.stderr)
    # Exit code 2 blocks tool call and shows stderr to Claude
    sys.exit(2)
```

#### UserPromptSubmit Example: Adding Context and Validation

```python
#!/usr/bin/env python3
import json
import sys
import re
import datetime

# Load input from stdin
try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
    sys.exit(1)

prompt = input_data.get("prompt", "")

# Check for sensitive patterns
sensitive_patterns = [
    (r"(?i)\b(password|secret|key|token)\s*[:=]", "Prompt contains potential secrets"),
]

for pattern, message in sensitive_patterns:
    if re.search(pattern, prompt):
        # Use JSON output to block with a specific reason
        output = {
            "decision": "block",
            "reason": f"Security policy violation: {message}. Please rephrase your request without sensitive information."
        }
        print(json.dumps(output))
        sys.exit(0)

# Add current time to context
context = f"Current time: {datetime.datetime.now()}"
print(context)

# Allow the prompt to proceed with the additional context
sys.exit(0)
```

## Working with MCP Tools

Claude Code hooks work seamlessly with
[Model Context Protocol (MCP) tools](/en/docs/claude-code/mcp). When MCP servers
provide tools, they appear with a special naming pattern that you can match in
your hooks.

### MCP Tool Naming

MCP tools follow the pattern `mcp__<server>__<tool>`, for example:

* `mcp__memory__create_entities` - Memory server's create entities tool
* `mcp__filesystem__read_file` - Filesystem server's read file tool
* `mcp__github__search_repositories` - GitHub server's search tool

### Configuring Hooks for MCP Tools

You can target specific MCP tools or entire MCP servers:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__memory__.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Memory operation initiated' >> ~/mcp-operations.log"
          }
        ]
      },
      {
        "matcher": "mcp__.*__write.*",
        "hooks": [
          {
            "type": "command",
            "command": "/home/user/scripts/validate-mcp-write.py"
          }
        ]
      }
    ]
  }
}
```

## Examples

<Tip>
  For practical examples including code formatting, notifications, and file protection, see [More Examples](/en/docs/claude-code/hooks-guide#more-examples) in the get started guide.
</Tip>

## Security Considerations

### Disclaimer

**USE AT YOUR OWN RISK**: Claude Code hooks execute arbitrary shell commands on
your system automatically. By using hooks, you acknowledge that:

* You are solely responsible for the commands you configure
* Hooks can modify, delete, or access any files your user account can access
* Malicious or poorly written hooks can cause data loss or system damage
* Anthropic provides no warranty and assumes no liability for any damages
  resulting from hook usage
* You should thoroughly test hooks in a safe environment before production use

Always review and understand any hook commands before adding them to your
configuration.

### Security Best Practices

Here are some key practices for writing more secure hooks:

1. **Validate and sanitize inputs** - Never trust input data blindly
2. **Always quote shell variables** - Use `"$VAR"` not `$VAR`
3. **Block path traversal** - Check for `..` in file paths
4. **Use absolute paths** - Specify full paths for scripts
5. **Skip sensitive files** - Avoid `.env`, `.git/`, keys, etc.

### Configuration Safety

Direct edits to hooks in settings files don't take effect immediately. Claude
Code:

1. Captures a snapshot of hooks at startup
2. Uses this snapshot throughout the session
3. Warns if hooks are modified externally
4. Requires review in `/hooks` menu for changes to apply

This prevents malicious hook modifications from affecting your current session.

## Hook Execution Details

* **Timeout**: 60-second execution limit by default, configurable per command.
  * A timeout for an individual command does not affect the other commands.
* **Parallelization**: All matching hooks run in parallel
* **Environment**: Runs in current directory with Claude Code's environment
* **Input**: JSON via stdin
* **Output**:
  * PreToolUse/PostToolUse/Stop: Progress shown in transcript (Ctrl-R)
  * Notification: Logged to debug only (`--debug`)

## Debugging

### Basic Troubleshooting

If your hooks aren't working:

1. **Check configuration** - Run `/hooks` to see if your hook is registered
2. **Verify syntax** - Ensure your JSON settings are valid
3. **Test commands** - Run hook commands manually first
4. **Check permissions** - Make sure scripts are executable
5. **Review logs** - Use `claude --debug` to see hook execution details

Common issues:

* **Quotes not escaped** - Use `\"` inside JSON strings
* **Wrong matcher** - Check tool names match exactly (case-sensitive)
* **Command not found** - Use full paths for scripts

### Advanced Debugging

For complex hook issues:

1. **Inspect hook execution** - Use `claude --debug` to see detailed hook execution
2. **Validate JSON schemas** - Test hook input/output with external tools
3. **Check environment variables** - Verify Claude Code's environment is correct
4. **Test edge cases** - Try hooks with unusual file paths or inputs
5. **Monitor system resources** - Check for resource exhaustion during hook execution
6. **Use structured logging** - Implement logging in your hook scripts

### Debug Output Example

Use `claude --debug` to see hook execution details:

```
[DEBUG] Executing hooks for PostToolUse:Write
[DEBUG] Getting matching hook commands for PostToolUse with query: Write
[DEBUG] Found 1 hook matchers in settings
[DEBUG] Matched 1 hooks for query "Write"
[DEBUG] Found 1 hook commands to execute
[DEBUG] Executing hook command: <Your command> with timeout 60000ms
[DEBUG] Hook command completed with status 0: <Your stdout>
```

Progress messages appear in transcript mode (Ctrl-R) showing:

* Which hook is running
* Command being executed
* Success/failure status
* Output or error messages
