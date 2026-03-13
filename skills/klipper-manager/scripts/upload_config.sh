#!/bin/bash
# upload_config.sh — Upload a modified printer.cfg to Moonraker and restart firmware
# Usage: bash upload_config.sh <moonraker_ip> <local_config_file> [--no-restart]
#
# Exit codes: 0=success, 1=connection error, 2=upload error, 3=restart error

IP="${1:?Usage: upload_config.sh <moonraker_ip> <local_config_file> [--no-restart]}"
LOCAL_FILE="${2:?Provide path to local config file}"
NO_RESTART="${3:-}"
URL="http://${IP}:7125"

if [ ! -f "$LOCAL_FILE" ]; then
  echo "ERROR: File not found: ${LOCAL_FILE}" >&2
  exit 1
fi

echo "Uploading $(basename "$LOCAL_FILE") to ${URL}..." >&2

# Upload
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "${URL}/server/files/upload" \
  -F "root=config" \
  -F "file=@${LOCAL_FILE};filename=printer.cfg")

HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_STATUS:")

if [ "$HTTP_STATUS" != "201" ] && [ "$HTTP_STATUS" != "200" ]; then
  echo "ERROR: Upload failed with HTTP ${HTTP_STATUS}" >&2
  echo "$BODY" >&2
  exit 2
fi

echo "Upload successful (HTTP ${HTTP_STATUS})" >&2

if [ "$NO_RESTART" = "--no-restart" ]; then
  echo "Skipping firmware restart (--no-restart flag)" >&2
  exit 0
fi

# Firmware restart
echo "Restarting firmware..." >&2
RESTART=$(curl -s -X POST "${URL}/printer/firmware_restart")
echo "Restart response: ${RESTART}" >&2

# Wait for Klipper to come back up
echo "Waiting for Klipper to be ready..." >&2
for i in $(seq 1 15); do
  sleep 2
  STATE=$(curl -s --connect-timeout 3 "${URL}/printer/info" | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',{}).get('state','unknown'))" 2>/dev/null)
  echo "  [${i}] state: ${STATE}" >&2
  if [ "$STATE" = "ready" ]; then
    echo "Klipper is ready." >&2
    exit 0
  elif [ "$STATE" = "error" ] || [ "$STATE" = "shutdown" ]; then
    echo "ERROR: Klipper entered ${STATE} state after restart" >&2
    # Get error message
    MSG=$(curl -s "${URL}/printer/info" | \
      python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',{}).get('state_message',''))" 2>/dev/null)
    echo "Message: ${MSG}" >&2
    exit 3
  fi
done

echo "WARNING: Klipper did not reach ready state within 30s" >&2
exit 3
