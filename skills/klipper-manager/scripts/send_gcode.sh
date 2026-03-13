#!/bin/bash
# send_gcode.sh — Send a G-Code command to Klipper via Moonraker
# Usage: bash send_gcode.sh <moonraker_ip> "<gcode_command>"
#
# Output: Klipper terminal response (if any)
# Exit codes: 0=success, 1=error

IP="${1:?Usage: send_gcode.sh <moonraker_ip> \"GCODE_COMMAND\"}"
CMD="${2:?Provide a G-Code command}"
URL="http://${IP}:7125"

RESPONSE=$(curl -s -X POST "${URL}/printer/gcode/script" \
  -H "Content-Type: application/json" \
  -d "{\"script\": $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$CMD")}")

# Check for error
ERROR=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error',{}).get('message',''))" 2>/dev/null)
if [ -n "$ERROR" ]; then
  echo "ERROR: ${ERROR}" >&2
  exit 1
fi

echo "$RESPONSE"
