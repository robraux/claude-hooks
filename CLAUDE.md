# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a fully implemented iTerm2 Claude Code Notification System that provides comprehensive multi-channel notifications for Claude Code processes. The system integrates with Claude Code via hooks to deliver real-time alerts when user attention is required.

## Project Structure

- `README.md` - Complete installation and usage guide
- `notifications.md` - Original PRD document and technical specifications
- `bin/notifications` - Main CLI control interface
- `hooks/` - Claude Code hook handlers:
  - `notification-handler.zsh` - Main notification processor
  - `post-tool-reset.zsh` - Visual state reset after tool usage
  - `user-prompt-reset.zsh` - Visual state reset on user input
  - `stop-handler.zsh` - Success notification on completion
- `lib/` - Notification implementation modules:
  - `visual-notifications.zsh` - iTerm2 color integration
  - `push-notifications.zsh` - ntfy.sh integration
  - `desktop-notifications.zsh` - macOS native notifications
  - `audio-notifications.zsh` - Sound alerts
- `config/default-config.json` - Default configuration template
- `test/` - Testing and diagnostic utilities
- `.claude/settings.local.json` - Local Claude Code configuration

## Key Concepts

### Notification System Design
The implemented system provides a multi-channel notification system that:
1. Monitors Claude Code processes via multiple hooks (`Notification`, `PostToolUse`, `UserPromptSubmit`, `Stop`)
2. Sends alerts through four channels: ntfy.sh push, iTerm2 terminal colors, macOS desktop notifications, and audio
3. Provides granular toggle controls for each notification type
4. Integrates with iTerm2 for intelligent visual state management

### Technical Components
- **Hook Handler System**: Multiple specialized handlers for different Claude Code events
- **Configuration Management**: JSON config at `~/.config/claude/config.json` with backup/restore
- **Control Commands**: Full-featured CLI interface (`notifications on|off|status|reset`)
- **Visual Integration**: iTerm2 escape sequences with automatic state reset logic
- **State Management**: Persistent visual state tracking and intelligent reset behavior

## Development Notes

When working on this project:
1. This is a fully implemented system with production-ready code
2. The system uses a modular architecture with separate libraries for each notification type
3. Key dependencies: `jq`, `terminal-notifier`, Claude Code
4. Installation requires manual configuration of Claude Code hooks for security
5. The system maintains backward compatibility and includes comprehensive error handling

## Common Tasks

Common development tasks include:
- Updating notification logic in `lib/` modules
- Enhancing hook handlers in `hooks/` directory
- Adding new notification channels or customization options
- Improving CLI interface in `bin/notifications`
- Updating configuration schema in `config/default-config.json`
- Adding tests in `test/` directory