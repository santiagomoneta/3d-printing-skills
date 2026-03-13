# Moonraker API Reference

Base URL: `http://<IP>:7125`
All responses are JSON. All POST bodies are JSON unless using multipart (file upload).

Source: https://moonraker.readthedocs.io/

---

## Printer State

### GET /printer/info
Returns Klipper state and version info.
```json
{
  "result": {
    "state": "ready",          // ready|startup|shutdown|error
    "state_message": "Printer is ready",
    "hostname": "mainsailos",
    "klipper_path": "/home/pi/klipper",
    "python_path": "/home/pi/klippy-env/bin/python",
    "process_id": 563,
    "user_id": 1000,
    "group_id": 1000,
    "log_file": "/home/pi/printer_data/logs/klippy.log",
    "config_file": "/home/pi/printer_data/config/printer.cfg",
    "software_version": "v0.13.0-572-g88a71c3c",
    "cpu_info": "4 core ARMv7"
  }
}
```

### POST /printer/firmware_restart
Trigger a Klipper firmware restart (applies config changes).
```json
{"result": "ok"}
```

### POST /printer/restart
Restart Klipper host software (full restart).

---

## File Management

### GET /server/files/config/<filename>
Returns raw file content as text.

```bash
curl "http://<IP>:7125/server/files/config/printer.cfg"
```

### GET /server/files/list?root=config
List all files in config directory.
```json
{
  "result": [
    {"path": "printer.cfg", "modified": 1234567890.0, "size": 7196, "permissions": "rw"},
    {"path": "mainsail.cfg", "modified": ..., "size": ..., "permissions": "rw"}
  ]
}
```

### POST /server/files/upload (multipart)
Upload / overwrite a config file.
```bash
curl -X POST "http://<IP>:7125/server/files/upload" \
  -F "root=config" \
  -F "file=@/local/path/printer.cfg;filename=printer.cfg"
```
Success response (HTTP 201):
```json
{
  "action": "create_file",
  "item": {
    "path": "printer.cfg",
    "root": "config",
    "modified": 1234567890.0,
    "size": 7196,
    "permissions": "rw"
  }
}
```

### DELETE /server/files/config/<filename>
Delete a config file.

---

## GCode Execution

### POST /printer/gcode/script
Send a G-Code command.
```bash
curl -X POST "http://<IP>:7125/printer/gcode/script" \
  -H "Content-Type: application/json" \
  -d '{"script": "G28"}'
```
```json
{"result": "ok"}
```
Errors return:
```json
{"error": {"code": 400, "message": "error description"}}
```

### GET /printer/gcode/help
Returns all available G-code commands with help strings.

---

## Object Queries (Live State)

### GET /printer/objects/list
List all queryable printer objects.
```json
{
  "result": {
    "objects": ["webhooks", "configfile", "heaters", "gcode_move", "toolhead",
                "extruder", "heater_bed", "bed_mesh", "probe", "print_stats", ...]
  }
}
```

### GET /printer/objects/query?<object>[=field1,field2]
Query one or more objects. Use `null` (omit field list) for all fields.

```bash
# Query everything from multiple objects
curl "http://<IP>:7125/printer/objects/query?toolhead&extruder&heater_bed"

# Query specific fields
curl "http://<IP>:7125/printer/objects/query?toolhead=position,max_velocity,max_accel&extruder=temperature,target,pressure_advance"
```

Response:
```json
{
  "result": {
    "eventtime": 12345.678,
    "status": {
      "toolhead": {
        "position": [0.0, 0.0, 0.0, 0.0],
        "homed_axes": "xyz",
        "max_velocity": 300.0,
        "max_accel": 7000.0
      },
      "extruder": {
        "temperature": 23.4,
        "target": 0.0,
        "pressure_advance": 0.04
      }
    }
  }
}
```

### Key Objects and Fields

#### toolhead
```
position           [x, y, z, e]
homed_axes         "xyz" | "xy" | ""
max_velocity       mm/s (current runtime limit)
max_accel          mm/s²
minimum_cruise_ratio
square_corner_velocity
stalls             int (lost steps count)
axis_minimum       [x_min, y_min, z_min, 0]
axis_maximum       [x_max, y_max, z_max, 0]
extruder           "extruder" (name of active extruder)
```

#### extruder / heater_bed / heater_generic <name>
```
temperature        °C current
target             °C setpoint
power              0.0–1.0 (heater PWM duty cycle)
can_extrude        bool (extruder only)
pressure_advance   float (extruder only)
smooth_time        float (extruder only)
```

#### probe / bltouch
```
name               "probe" or "bltouch"
last_query         bool (triggered in last QUERY_PROBE)
last_probe_position [x, y, z, 0]
```

#### bed_mesh
```
profile_name       string (active profile)
mesh_min           [x, y]
mesh_max           [x, y]
probed_matrix      2D array of raw probe heights
mesh_matrix        2D array of interpolated mesh heights
profiles           dict of all saved profiles
```

#### print_stats
```
state              "standby"|"printing"|"paused"|"complete"|"cancelled"|"error"
filename           string
total_duration     seconds
print_duration     seconds
filament_used      mm
message            string
info.total_layer   int
info.current_layer int
```

#### idle_timeout
```
state              "Idle"|"Printing"|"Ready"
printing_time      seconds
idle_timeout       seconds
```

#### configfile
```
settings.<section>.<key>   resolved setting value
config.<section>.<key>     raw string from config file
save_config_pending        bool
save_config_pending_items  dict of pending changes
warnings                   list of config warnings
```

#### system_stats
```
sysload            float (CPU load)
cputime            seconds (process CPU time)
memavail           KB (available memory)
```

#### tmc2209 stepper_x (and other TMC objects)
```
run_current        Amps RMS
hold_current       Amps RMS (null if not set)
drv_status         dict of driver status register fields
temperature        °C (if supported)
mcu_phase_offset   int (or null)
phase_offset_position float (or null)
```

#### firmware_retraction
```
retract_length     mm
retract_speed      mm/s
unretract_extra_length mm
unretract_speed    mm/s
```

#### motion_report
```
live_position      [x, y, z, e] (real-time interpolated)
live_velocity      mm/s
live_extruder_velocity mm/s
```

#### webhooks
```
state              "ready"|"startup"|"shutdown"|"error"
state_message      string
```

#### gcode_move
```
gcode_position     [x, y, z, e]
position           [x, y, z, e]
homing_origin      [x, y, z, e]
speed              mm/s
speed_factor       float (M220 override)
extrude_factor     float (M221 override)
absolute_coordinates bool
absolute_extrude   bool
```

---

## Endstops

### GET /printer/query_endstops/status
```json
{
  "result": {
    "x": "open",
    "y": "open",
    "z": "TRIGGERED"
  }
}
```

---

## Machine Control (Moonraker)

### POST /machine/reboot
Reboot the host system.

### POST /machine/shutdown
Shut down the host system.

### GET /machine/system_info
Returns system information (OS, CPU, memory, network, etc.)

### GET /server/info
Returns Moonraker version and registered components.

---

## Logs

### GET /server/files/logs/<logfile>
Download a log file (e.g., `klippy.log`, `moonraker.log`).

### GET /server/logs/rollover
Trigger log rollover.

---

## Emergency Stop

### POST /printer/emergency_stop
Immediately halt all movement and disable heaters (equivalent to M112).

---

## Curl Examples

```bash
# Check printer state
curl -s "http://192.168.0.224:7125/printer/info" | python3 -m json.tool

# Send G28 (home all)
curl -s -X POST "http://192.168.0.224:7125/printer/gcode/script" \
  -H "Content-Type: application/json" \
  -d '{"script": "G28"}'

# Query temperatures
curl -s "http://192.168.0.224:7125/printer/objects/query?extruder=temperature,target&heater_bed=temperature,target"

# Query live position
curl -s "http://192.168.0.224:7125/printer/objects/query?toolhead=position,homed_axes"

# Dump TMC stepper_x settings
curl -s -X POST "http://192.168.0.224:7125/printer/gcode/script" \
  -H "Content-Type: application/json" \
  -d '{"script": "DUMP_TMC STEPPER=stepper_x"}'

# Upload modified config
curl -s -X POST "http://192.168.0.224:7125/server/files/upload" \
  -F "root=config" \
  -F "file=@/tmp/printer_modified.cfg;filename=printer.cfg"

# Firmware restart
curl -s -X POST "http://192.168.0.224:7125/printer/firmware_restart"

# Save calibration data
curl -s -X POST "http://192.168.0.224:7125/printer/gcode/script" \
  -H "Content-Type: application/json" \
  -d '{"script": "SAVE_CONFIG"}'
```
