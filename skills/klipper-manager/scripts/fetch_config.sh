#!/bin/bash
# fetch_config.sh — Fetch printer.cfg from Moonraker
# Usage: bash fetch_config.sh <moonraker_ip> [output_file]
#
# Output: printer.cfg content to stdout or to output_file
# Exit codes: 0=success, 1=connection error, 2=file not found

IP="${1:?Usage: fetch_config.sh <moonraker_ip> [output_file]}"
OUTPUT="${2:-}"
URL="http://${IP}:7125"

# Verify connectivity
STATE=$(curl -s --connect-timeout 5 "${URL}/printer/info" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',{}).get('state','unknown'))" 2>/dev/null)
if [ -z "$STATE" ]; then
  echo "ERROR: Cannot connect to Moonraker at ${URL}" >&2
  exit 1
fi
echo "Printer state: ${STATE}" >&2

# Fetch config
if [ -n "$OUTPUT" ]; then
  HTTP_STATUS=$(curl -s -w "%{http_code}" -o "$OUTPUT" "${URL}/server/files/config/printer.cfg")
  if [ "$HTTP_STATUS" = "200" ]; then
    echo "Saved to: ${OUTPUT}" >&2
    echo "Lines: $(wc -l < "$OUTPUT")" >&2
  else
    echo "ERROR: HTTP ${HTTP_STATUS} fetching printer.cfg" >&2
    exit 2
  fi
else
  curl -s "${URL}/server/files/config/printer.cfg"
fi
