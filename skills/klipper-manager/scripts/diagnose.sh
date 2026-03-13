#!/bin/bash
# diagnose.sh — Full diagnostic of a Klipper printer via Moonraker
# Usage: bash diagnose.sh <moonraker_ip>
#
# Fetches printer.cfg, parses key values, and runs all validation checks.
# Output: Diagnostic report to stdout (issues listed as WARN or ERROR)

IP="${1:?Usage: diagnose.sh <moonraker_ip>}"
URL="http://${IP}:7125"
TMP_CFG="/tmp/klipper_diag_$$.cfg"
trap "rm -f $TMP_CFG" EXIT

echo "======================================"
echo "Klipper Diagnostic — ${IP}"
echo "======================================"
echo ""

# 1. Connectivity
echo "[INFO]  Checking Moonraker connectivity..."
PRINTER_INFO=$(curl -s --connect-timeout 5 "${URL}/printer/info")
if [ -z "$PRINTER_INFO" ]; then
  echo "[ERROR] Cannot connect to Moonraker at ${URL}"
  exit 1
fi

STATE=$(echo "$PRINTER_INFO" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',{}).get('state','unknown'))" 2>/dev/null)
HOSTNAME=$(echo "$PRINTER_INFO" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',{}).get('hostname','unknown'))" 2>/dev/null)
VERSION=$(echo "$PRINTER_INFO" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',{}).get('software_version','unknown'))" 2>/dev/null)

echo "[INFO]  Hostname: ${HOSTNAME}"
echo "[INFO]  Klipper:  ${VERSION}"

if [ "$STATE" = "ready" ]; then
  echo "[OK]    Printer state: ready"
else
  echo "[ERROR] Printer state: ${STATE} (not ready)"
fi

echo ""
echo "--- Config Analysis ---"

# 2. Fetch config to temp file
HTTP_STATUS=$(curl -s -w "%{http_code}" -o "$TMP_CFG" "${URL}/server/files/config/printer.cfg")
if [ "$HTTP_STATUS" != "200" ]; then
  echo "[ERROR] Could not fetch printer.cfg (HTTP ${HTTP_STATUS})"
  exit 1
fi

# 3. Run Python diagnostic on the config file
python3 - "$TMP_CFG" << 'PYEOF'
import re
import sys

with open(sys.argv[1], 'r', encoding='utf-8', errors='replace') as f:
    config = f.read()

def get_section(name):
    pat = r'(?m)^\[' + re.escape(name) + r'\][ \t]*$(.+?)(?=^\[|\Z)'
    m = re.search(pat, config, re.DOTALL | re.MULTILINE)
    return m.group(1) if m else None

def get_val(section_name, key, default=None):
    sec = get_section(section_name)
    if not sec:
        return default
    m = re.search(r'(?m)^\s*' + re.escape(key) + r'\s*:\s*([^\n]+)', sec)
    if m:
        return m.group(1).split('#')[0].strip()
    return default

def get_float(section_name, key, default=None):
    v = get_val(section_name, key)
    if v is None:
        return default
    try:
        return float(re.split(r'[,\s]+', v.strip())[0])
    except:
        return default

def get_xy(val):
    if val is None:
        return None, None
    parts = re.split(r'[,\s]+', val.strip())
    try:
        return float(parts[0]), float(parts[1])
    except:
        return None, None

def has_section(name):
    return bool(re.search(r'(?mi)^\[' + re.escape(name) + r'\]', config))

issues = []
warnings = []
oks = []

# Axis limits
x_max = get_float('stepper_x', 'position_max')
x_min = get_float('stepper_x', 'position_min', 0.0)
y_max = get_float('stepper_y', 'position_max')
y_min = get_float('stepper_y', 'position_min', 0.0)

if x_max:
    oks.append(f"stepper_x range: [{x_min}, {x_max}] mm")
if y_max:
    oks.append(f"stepper_y range: [{y_min}, {y_max}] mm")

# Probe offsets
probe_type = None
if has_section('bltouch'):
    probe_type = 'bltouch'
elif has_section('probe'):
    probe_type = 'probe'

if probe_type:
    px = get_float(probe_type, 'x_offset', 0.0)
    py = get_float(probe_type, 'y_offset', 0.0)
    oks.append(f"Probe type: [{probe_type}]  x_offset={px}  y_offset={py}")
else:
    warnings.append("No [bltouch] or [probe] section found")
    px, py = 0.0, 0.0

# axis_twist_compensation validation
start_x = get_float('axis_twist_compensation', 'calibrate_start_x')
end_x   = get_float('axis_twist_compensation', 'calibrate_end_x')
cal_y   = get_float('axis_twist_compensation', 'calibrate_y')

if end_x is not None and x_max is not None:
    nozzle_end_x = end_x - px
    nozzle_start_x = (start_x - px) if start_x is not None else None
    nozzle_y = (cal_y - py) if cal_y is not None else None

    if nozzle_end_x > x_max:
        max_safe = x_max + px
        issues.append(
            f"axis_twist_compensation: calibrate_end_x={end_x} moves nozzle to "
            f"X={nozzle_end_x:.1f}, exceeding position_max={x_max}. "
            f"Fix: set calibrate_end_x <= {max_safe:.0f}"
        )
    else:
        oks.append(f"axis_twist_compensation end_x OK (nozzle X={nozzle_end_x:.1f} <= {x_max})")

    if nozzle_start_x is not None and nozzle_start_x < x_min:
        issues.append(
            f"axis_twist_compensation: calibrate_start_x={start_x} moves nozzle to "
            f"X={nozzle_start_x:.1f}, below position_min={x_min}."
        )
    elif nozzle_start_x is not None:
        oks.append(f"axis_twist_compensation start_x OK (nozzle X={nozzle_start_x:.1f} >= {x_min})")

    if nozzle_y is not None and y_max is not None:
        if nozzle_y > y_max:
            issues.append(f"axis_twist_compensation: calibrate_y={cal_y} moves nozzle to Y={nozzle_y:.1f} > position_max_y={y_max}")
        elif nozzle_y < y_min:
            issues.append(f"axis_twist_compensation: calibrate_y={cal_y} moves nozzle to Y={nozzle_y:.1f} < position_min_y={y_min}")
        else:
            oks.append(f"axis_twist_compensation calibrate_y OK (nozzle Y={nozzle_y:.1f})")

# bed_mesh validation
mesh_min_val = get_val('bed_mesh', 'mesh_min')
mesh_max_val = get_val('bed_mesh', 'mesh_max')
if mesh_min_val and mesh_max_val and x_max is not None:
    mx1, my1 = get_xy(mesh_min_val)
    mx2, my2 = get_xy(mesh_max_val)
    if mx1 is not None and mx2 is not None:
        nx1 = mx1 - px; nx2 = mx2 - px
        ny1 = my1 - py; ny2 = my2 - py
        bed_mesh_ok = True
        if nx1 < x_min:
            issues.append(f"bed_mesh mesh_min.x={mx1} moves nozzle to X={nx1:.1f} < position_min={x_min}"); bed_mesh_ok=False
        if nx2 > x_max:
            issues.append(f"bed_mesh mesh_max.x={mx2} moves nozzle to X={nx2:.1f} > position_max={x_max}"); bed_mesh_ok=False
        if ny1 < y_min:
            issues.append(f"bed_mesh mesh_min.y={my1} moves nozzle to Y={ny1:.1f} < position_min_y={y_min}"); bed_mesh_ok=False
        if y_max is not None and ny2 > y_max:
            issues.append(f"bed_mesh mesh_max.y={my2} moves nozzle to Y={ny2:.1f} > position_max_y={y_max}"); bed_mesh_ok=False
        if bed_mesh_ok:
            oks.append(f"bed_mesh bounds OK (nozzle range X {nx1:.0f}–{nx2:.0f}, Y {ny1:.0f}–{ny2:.0f})")

# safe_z_home validation
home_xy = get_val('safe_z_home', 'home_xy_position')
if home_xy and x_max is not None:
    hx, hy = get_xy(home_xy)
    if hx is not None:
        home_ok = True
        if hx < x_min or hx > x_max:
            issues.append(f"safe_z_home home_xy_position X={hx} out of range [{x_min}, {x_max}]"); home_ok=False
        if y_max is not None and (hy < y_min or hy > y_max):
            issues.append(f"safe_z_home home_xy_position Y={hy} out of range [{y_min}, {y_max}]"); home_ok=False
        if home_ok:
            oks.append(f"safe_z_home position OK (nozzle X={hx}, Y={hy})")

# TMC warnings
for axis in ['stepper_x', 'stepper_y', 'stepper_z', 'extruder']:
    for drv in ['tmc2209', 'tmc2130', 'tmc5160', 'tmc2208', 'tmc2660', 'tmc2240']:
        sec = f'{drv} {axis}'
        if not has_section(sec):
            continue
        hc = get_float(sec, 'hold_current')
        if hc is not None:
            warnings.append(f"[{sec}]: hold_current={hc} — Klipper docs recommend omitting (can cause vibration)")
        sc = get_val(sec, 'stealthchop_threshold')
        if axis == 'extruder' and sc == '999999':
            pa = get_float('extruder', 'pressure_advance', 0.0)
            if pa and pa > 0:
                warnings.append(f"extruder: stealthchop=999999 with pressure_advance={pa} — may reduce torque at high speeds")

# Input shaper
shaper_x = get_val('input_shaper', 'shaper_type_x') or get_val('input_shaper', 'shaper_type', '')
if shaper_x in ('3hump_ei', '2hump_ei'):
    warnings.append(f"input_shaper shaper_type_x={shaper_x} — complex resonance, verify belt tension before re-running SHAPER_CALIBRATE")
elif shaper_x:
    oks.append(f"input_shaper shaper_type_x={shaper_x}")

if not has_section('input_shaper'):
    warnings.append("No [input_shaper] section — recommend SHAPER_CALIBRATE if you have an accelerometer")

# Missing recommended sections
for section, desc in [
    ('exclude_object', 'object cancellation / KAMP'),
    ('firmware_retraction', 'runtime retraction tuning'),
    ('gcode_arcs', 'arc support'),
    ('pause_resume', 'pause/cancel functionality'),
]:
    if not has_section(section):
        warnings.append(f"Missing [{section}] — enables {desc}")

# Pressure advance
pa = get_float('extruder', 'pressure_advance')
if pa is None or pa == 0:
    warnings.append("pressure_advance not configured — recommend TUNING_TOWER calibration")
else:
    oks.append(f"pressure_advance = {pa}")

# PID check
for heater in ['extruder', 'heater_bed']:
    ctrl = get_val(heater, 'control')
    if ctrl == 'watermark':
        warnings.append(f"[{heater}] control=watermark — recommend PID calibration: PID_CALIBRATE HEATER={heater} TARGET=<temp>")
    elif ctrl == 'pid':
        oks.append(f"[{heater}] PID control configured")

# Print results
for msg in oks:
    print(f"[OK]    {msg}")
for msg in warnings:
    print(f"[WARN]  {msg}")
for msg in issues:
    print(f"[ERROR] {msg}")

total = len(issues) + len(warnings)
print(f"\nSummary: {len(issues)} error(s), {len(warnings)} warning(s), {len(oks)} check(s) passed")
PYEOF

echo ""
echo "======================================"
echo "Diagnostic complete."
echo "======================================"
