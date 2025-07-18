# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Product Requirements Document (PRD) project for designing an iTerm2 Claude Code Notification System. The project contains specifications rather than implementation code.

## Project Structure

- `notifications.md` - Main PRD document (26KB) containing:
  - Comprehensive specifications for iTerm2 notification system
  - Integration requirements with Claude Code hooks
  - Multiple notification channels (push, visual, desktop, audio)
  - Technical implementation approach
  - Claude Code hooks reference documentation

- `.claude/settings.local.json` - Local Claude Code configuration
  - Currently allows `ls` and `find` bash commands
  - Permission-based security model

## Key Concepts

### Notification System Design
The PRD describes a multi-channel notification system that would:
1. Monitor Claude Code processes via hooks (`Notification`, `UserPromptSubmit` events)
2. Send alerts through multiple channels (ntfy.sh push, terminal colors, desktop notifications, audio)
3. Provide toggle controls for each notification type
4. Integrate with iTerm2 for visual indicators

### Technical Components
- **Hook Handler Script**: Would process Claude Code notification events
- **Configuration Management**: JSON config at `~/.config/claude/config.json`
- **Control Commands**: CLI interface (`notifications on|off|status`)
- **Visual Integration**: iTerm2 escape sequences for color changes

## Development Notes

When working on this project:
1. This is a documentation/specification project - no implementation code exists yet
2. The PRD follows a phased implementation approach (4 phases)
3. Key dependencies would include: `jq`, `terminal-notifier`, Claude Code
4. Manual installation approach is specified (no automated modification of existing files)
5. Safety requirements emphasize no automatic editing of Claude Code settings

## Common Tasks

Since this is a PRD project, common tasks include:
- Reviewing and updating specifications in `notifications.md`
- Planning implementation phases
- Documenting technical requirements
- Designing hook integration patterns