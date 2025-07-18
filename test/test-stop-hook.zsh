#!/bin/zsh

# Test script for Stop hook functionality
# Simulates the Stop hook input and tests the handler

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing Stop Hook Handler${NC}"
echo "==============================="

# Get the directory where this script is located
SCRIPT_DIR="${0:a:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"

# Path to the stop handler
STOP_HANDLER="${PROJECT_DIR}/hooks/stop-handler.zsh"

# Check if stop handler exists
if [[ ! -f "$STOP_HANDLER" ]]; then
    echo -e "${RED}✗ Stop handler not found at $STOP_HANDLER${NC}"
    exit 1
fi

# Check if stop handler is executable
if [[ ! -x "$STOP_HANDLER" ]]; then
    echo -e "${RED}✗ Stop handler is not executable${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Stop handler found and executable${NC}"

# Create test JSON input that simulates Claude Code Stop hook
TEST_INPUT='{
  "hook_event_name": "Stop",
  "stop_hook_active": true,
  "session_id": "test-session-123",
  "transcript_path": "~/.claude/projects/test/transcript.jsonl"
}'

echo ""
echo -e "${YELLOW}Test Input:${NC}"
echo "$TEST_INPUT"
echo ""

# Test the stop handler
echo -e "${YELLOW}Running Stop Hook Handler...${NC}"
echo "$TEST_INPUT" | "$STOP_HANDLER"

RESULT=$?

echo ""
if [[ $RESULT -eq 0 ]]; then
    echo -e "${GREEN}✓ Stop hook handler executed successfully${NC}"
    echo ""
    echo -e "${YELLOW}Expected Results:${NC}"
    echo "- Terminal should now be green (if visual notifications enabled)"
    echo "- Push notification sent (if push notifications enabled)"
    echo "- Desktop notification shown (if desktop notifications enabled)"
    echo "- Audio notification played (if audio notifications enabled)"
    echo ""
    echo -e "${YELLOW}Check your terminal color and notification channels!${NC}"
else
    echo -e "${RED}✗ Stop hook handler failed with exit code $RESULT${NC}"
    exit 1
fi

# Check if visual state was updated
STATE_FILE="${HOME}/.config/claude/.visual-state"
if [[ -f "$STATE_FILE" ]]; then
    STATE=$(cat "$STATE_FILE")
    echo -e "${GREEN}✓ Visual state updated to: $STATE${NC}"
else
    echo -e "${YELLOW}⚠ Visual state file not found (may be normal if visual notifications disabled)${NC}"
fi

echo ""
echo -e "${GREEN}Stop hook test completed!${NC}"