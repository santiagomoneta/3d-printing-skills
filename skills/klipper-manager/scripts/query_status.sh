#!/bin/bash
# query_status.sh — Query live printer status from Moonraker
# Usage: bash query_status.sh <moonraker_ip> [object1[=field1,field2] object2 ...]
#
# If no objects specified, queries a comprehensive default set.
# Output: JSON status to stdout

IP="${1:?Usage: query_status.sh <moonraker_ip> [objects...]}"
URL="http://${IP}:7125"
shift

if [ $# -eq 0 ]; then
  # Default comprehensive query
  QUERY="toolhead&extruder&heater_bed&bed_mesh=profile_name&print_stats&idle_timeout&webhooks&firmware_retraction&system_stats"
else
  # Join remaining args with &
  QUERY=$(printf "%s&" "$@" | sed 's/&$//')
fi

curl -s "${URL}/printer/objects/query?${QUERY}" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
result = data.get('result', {})
status = result.get('status', {})
print(json.dumps(status, indent=2))
"
