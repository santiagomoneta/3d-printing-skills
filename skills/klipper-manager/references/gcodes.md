# Klipper G-Code & Extended Command Reference

Source: https://www.klipper3d.org/G-Codes.html

---

## Standard G-Codes

| Command | Description |
|---------|-------------|
| `G0` / `G1 [X] [Y] [Z] [E] [F]` | Move (F = speed in mm/min) |
| `G4 P<ms>` | Dwell (pause) for P milliseconds |
| `G28 [X] [Y] [Z]` | Home axes (all if none specified) |
| `G90` | Absolute positioning mode |
| `G91` | Relative positioning mode |
| `G92 [X] [Y] [Z] [E]` | Set position (reset coordinate origin) |
| `M18` / `M84` | Disable stepper motors |
| `M104 [T<idx>] [S<temp>]` | Set extruder temperature (no wait) |
| `M105` | Get extruder temperature |
| `M106 S<value>` | Set part cooling fan speed (0–255) |
| `M107` | Turn off part cooling fan |
| `M109 [T<idx>] S<temp>` | Set extruder temp and WAIT |
| `M112` | Emergency stop (shutdown) |
| `M114` | Get current position |
| `M115` | Get firmware version |
| `M117 <message>` | Set display message |
| `M140 [S<temp>]` | Set bed temperature (no wait) |
| `M190 S<temp>` | Set bed temp and WAIT |
| `M204 S<accel>` | Set acceleration |
| `M220 S<percent>` | Speed factor override (100 = normal) |
| `M221 S<percent>` | Extrude factor override |
| `M400` | Wait for current moves to finish |
| `M73 P<percent>` | Set build progress percentage |
| `M82` / `M83` | Absolute/relative extruder mode |

---

## Extended Commands (by module)

### [gcode] — always available

| Command | Description |
|---------|-------------|
| `RESTART` | Reload config and restart host software |
| `FIRMWARE_RESTART` | Reset MCU firmware and restart |
| `STATUS` | Print Klipper state to terminal |
| `HELP` | List all available extended commands with help text |

---

### [configfile] — always available

| Command | Description |
|---------|-------------|
| `SAVE_CONFIG` | Write pending calibration data to printer.cfg and restart |

---

### [gcode_move] — always available

| Command | Description |
|---------|-------------|
| `GET_POSITION` | Report current toolhead position |
| `SET_GCODE_OFFSET [X=] [Y=] [Z=] [Z_ADJUST=] [MOVE=1]` | Shift gcode coordinate origin |
| `SAVE_GCODE_STATE [NAME=]` | Save current gcode state |
| `RESTORE_GCODE_STATE [NAME=] [MOVE=0\|1] [MOVE_SPEED=]` | Restore saved state |

---

### [toolhead] — always available

| Command | Description |
|---------|-------------|
| `SET_VELOCITY_LIMIT [VELOCITY=] [ACCEL=] [MINIMUM_CRUISE_RATIO=] [SQUARE_CORNER_VELOCITY=]` | Override printer limits at runtime |

---

### [probe] / [bltouch]

| Command | Description |
|---------|-------------|
| `PROBE [PROBE_SPEED=] [LIFT_SPEED=] [SAMPLES=] [SAMPLE_RETRACT_DIST=] [SAMPLES_TOLERANCE=] [SAMPLES_TOLERANCE_RETRIES=] [SAMPLES_RESULT=]` | Perform a single probe |
| `QUERY_PROBE` | Report probe triggered state |
| `PROBE_ACCURACY [PROBE_SPEED=] [SAMPLES=] [SAMPLE_RETRACT_DIST=]` | Probe repeatedly and report statistics |
| `PROBE_CALIBRATE [SPEED=] [LIFT_SPEED=]` | Start interactive Z offset calibration (paper test) |
| `Z_OFFSET_APPLY_PROBE` | Apply current `SET_GCODE_OFFSET Z` to probe z_offset |
| `BLTOUCH_DEBUG COMMAND=<cmd>` | Send raw command to BLTouch: `pin_down\|touch_mode\|pin_up\|self_test\|reset\|set_5V_output_mode\|set_OD_output_mode\|output_mode_store` |
| `BLTOUCH_STORE MODE=<5V\|OD>` | Store output mode in BLTouch EEPROM (V3.1 only) |

---

### [manual_probe]

| Command | Description |
|---------|-------------|
| `MANUAL_PROBE [SPEED=]` | Interactive manual probe helper |
| `Z_ENDSTOP_CALIBRATE [SPEED=]` | Interactive Z endstop calibration |
| `Z_OFFSET_APPLY_ENDSTOP` | Apply SET_GCODE_OFFSET Z to endstop z_position |
| `TESTZ Z=<value>` | (during PROBE_CALIBRATE / Z_ENDSTOP_CALIBRATE) adjust Z |
| `ACCEPT` | (during calibration) accept current Z position |
| `ABORT` | (during calibration) abort without saving |

---

### [bed_mesh]

| Command | Description |
|---------|-------------|
| `BED_MESH_CALIBRATE [PROFILE=] [METHOD=manual] [ADAPTIVE=1] [ADAPTIVE_MARGIN=] [HORIZONTAL_MOVE_Z=]` | Probe bed and generate mesh |
| `BED_MESH_OUTPUT [PGP=0\|1]` | Print current mesh to terminal |
| `BED_MESH_MAP` | Print mesh as JSON |
| `BED_MESH_CLEAR` | Clear active mesh (add to end gcode) |
| `BED_MESH_PROFILE LOAD=<name>` | Load a saved mesh profile |
| `BED_MESH_PROFILE SAVE=<name>` | Save current mesh to profile |
| `BED_MESH_PROFILE REMOVE=<name>` | Delete a saved profile |
| `BED_MESH_OFFSET [X=] [Y=] [ZFADE=]` | Apply offset to mesh lookup |

---

### [axis_twist_compensation]

| Command | Description |
|---------|-------------|
| `AXIS_TWIST_COMPENSATION_CALIBRATE [AXIS=X\|Y] [SAMPLE_COUNT=]` | Run calibration (3 probe points along X by default) |

---

### [screws_tilt_adjust]

| Command | Description |
|---------|-------------|
| `SCREWS_TILT_CALCULATE [MAX_DEVIATION=]` | Probe each screw position and report turn adjustments |

---

### [bed_screws] (manual leveling)

| Command | Description |
|---------|-------------|
| `BED_SCREWS_ADJUST` | Interactive manual bed leveling tool |

---

### [z_tilt]

| Command | Description |
|---------|-------------|
| `Z_TILT_ADJUST [HORIZONTAL_MOVE_Z=] [RETRY_TOLERANCE=]` | Level multiple Z steppers |

---

### [quad_gantry_level]

| Command | Description |
|---------|-------------|
| `QUAD_GANTRY_LEVEL [HORIZONTAL_MOVE_Z=] [RETRY_TOLERANCE=]` | Level CoreXY gantry (4-point) |

---

### [extruder]

| Command | Description |
|---------|-------------|
| `SET_PRESSURE_ADVANCE [EXTRUDER=] [ADVANCE=] [SMOOTH_TIME=]` | Set PA at runtime |
| `SET_EXTRUDER_ROTATION_DISTANCE [EXTRUDER=] [DISTANCE=]` | Change rotation_distance at runtime |
| `SYNC_EXTRUDER_MOTION EXTRUDER=<name> MOTION_QUEUE=<name>` | Sync extruder stepper to another motion queue |
| `ACTIVATE_EXTRUDER EXTRUDER=<name>` | Switch active extruder (multi-extruder) |

---

### [tmcXXXX] (tmc2209, tmc2130, tmc5160, etc.)

| Command | Description |
|---------|-------------|
| `DUMP_TMC STEPPER=<name>` | Print all driver registers and configured values |
| `INIT_TMC STEPPER=<name>` | Re-initialize TMC driver from config |
| `SET_TMC_CURRENT STEPPER=<name> CURRENT=<amps> [HOLDCURRENT=<amps>]` | Change current at runtime |
| `SET_TMC_FIELD STEPPER=<name> FIELD=<field> VALUE=<value>` | Set a single driver register field |

---

### [resonance_tester]

| Command | Description |
|---------|-------------|
| `MEASURE_AXES_NOISE` | Measure accelerometer noise floor |
| `TEST_RESONANCES AXIS=<X\|Y> [FREQ_START=] [FREQ_END=] [HZ_PER_SEC=]` | Sweep resonance test |
| `SHAPER_CALIBRATE [AXIS=X\|Y] [MAX_SMOOTHING=]` | Auto-calibrate input shaper |

---

### [adxl345]

| Command | Description |
|---------|-------------|
| `ACCELEROMETER_QUERY [CHIP=] [RATE=]` | Read accelerometer value (test connection) |
| `ACCELEROMETER_MEASURE [CHIP=] [NAME=]` | Start/stop recording to CSV |

---

### [input_shaper]

| Command | Description |
|---------|-------------|
| `SET_INPUT_SHAPER [SHAPER_FREQ_X=] [SHAPER_FREQ_Y=] [SHAPER_TYPE=] [SHAPER_TYPE_X=] [SHAPER_TYPE_Y=] [DAMPING_RATIO_X=] [DAMPING_RATIO_Y=]` | Change shaper at runtime |

---

### [heaters]

| Command | Description |
|---------|-------------|
| `TURN_OFF_HEATERS` | Turn off all heaters |
| `TEMPERATURE_WAIT SENSOR=<name> [MINIMUM=] [MAXIMUM=]` | Wait for temperature range |
| `SET_HEATER_TEMPERATURE HEATER=<name> TARGET=<temp>` | Set heater target |

---

### [pid_calibrate]

| Command | Description |
|---------|-------------|
| `PID_CALIBRATE HEATER=<name> TARGET=<temp> [WRITE_FILE=1]` | Run PID autotune — follow with SAVE_CONFIG |

---

### [firmware_retraction]

| Command | Description |
|---------|-------------|
| `SET_RETRACTION [RETRACT_LENGTH=] [RETRACT_SPEED=] [UNRETRACT_EXTRA_LENGTH=] [UNRETRACT_SPEED=]` | Change retraction at runtime |
| `GET_RETRACTION` | Print current retraction settings |

---

### [skew_correction]

| Command | Description |
|---------|-------------|
| `SET_SKEW [XY=<dist>] [XZ=<dist>] [YZ=<dist>] [CLEAR=1]` | Set skew from measured diagonal distances |
| `GET_CURRENT_SKEW` | Report current skew values |
| `CALC_MEASURED_SKEW AC=<dist> BD=<dist> AD=<dist>` | Calculate skew from 3 measurements |
| `SKEW_PROFILE LOAD=<name> SAVE=<name> REMOVE=<name>` | Manage skew profiles |

---

### [exclude_object]

| Command | Description |
|---------|-------------|
| `EXCLUDE_OBJECT [NAME=<name>] [CURRENT=1] [RESET=1]` | Exclude object from print |
| `EXCLUDE_OBJECT_DEFINE NAME=<name> [CENTER=x,y] [POLYGON=...]` | Define an object boundary |
| `EXCLUDE_OBJECT_START NAME=<name>` | Mark start of object's gcode for current layer |
| `EXCLUDE_OBJECT_END NAME=<name>` | Mark end of object's gcode for current layer |

---

### [pause_resume]

| Command | Description |
|---------|-------------|
| `PAUSE` | Pause print |
| `RESUME [VELOCITY=]` | Resume print |
| `CLEAR_PAUSE` | Clear pause state without resuming |
| `CANCEL_PRINT` | Cancel current print |

---

### [query_endstops]

| Command | Description |
|---------|-------------|
| `QUERY_ENDSTOPS` | Report state of all endstops (open/triggered) |

---

### [stepper_enable]

| Command | Description |
|---------|-------------|
| `SET_STEPPER_ENABLE STEPPER=<name> ENABLE=0\|1` | Enable/disable a specific stepper |

---

### [force_move] (requires enable_force_move: True)

| Command | Description |
|---------|-------------|
| `STEPPER_BUZZ STEPPER=<name>` | Move stepper back and forth to verify wiring |
| `FORCE_MOVE STEPPER=<name> DISTANCE=<mm> VELOCITY=<mm/s> [ACCEL=]` | Move without homing checks |
| `SET_KINEMATIC_POSITION [X=] [Y=] [Z=]` | Override kinematic position without physical move |

---

### [tuning_tower]

| Command | Description |
|---------|-------------|
| `TUNING_TOWER COMMAND=<gcode_cmd> PARAMETER=<param> START=<val> [FACTOR=] [BAND=] [STEP_DELTA=] [STEP_HEIGHT=]` | Change a parameter with Z height (for towers) |

Common usage: `TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.005`

---

### [delta_calibrate]

| Command | Description |
|---------|-------------|
| `DELTA_CALIBRATE [METHOD=manual] [HORIZONTAL_MOVE_Z=]` | Calibrate delta printer |

---

### [output_pin]

| Command | Description |
|---------|-------------|
| `SET_PIN PIN=<name> VALUE=<0–1> [CYCLE_TIME=]` | Set output pin value |

---

### [fan_generic]

| Command | Description |
|---------|-------------|
| `SET_FAN_SPEED FAN=<name> SPEED=<0–1>` | Set generic fan speed |

---

### [gcode_macro]

| Command | Description |
|---------|-------------|
| `SET_GCODE_VARIABLE MACRO=<name> VARIABLE=<var> VALUE=<value>` | Set macro variable at runtime |

---

### [idle_timeout]

| Command | Description |
|---------|-------------|
| `SET_IDLE_TIMEOUT TIMEOUT=<seconds>` | Change idle timeout at runtime |

---

### [virtual_sdcard]

| Command | Description |
|---------|-------------|
| `SDCARD_PRINT_FILE FILENAME=<file>` | Start printing a file from virtual SD |
| `SDCARD_RESET_FILE` | Clear current file from virtual SD |

---

## Common Calibration Sequences

### Full startup calibration order (new printer):
1. `G28` — home all
2. `STEPPER_BUZZ STEPPER=stepper_x` — verify motor direction
3. `Z_ENDSTOP_CALIBRATE` or `PROBE_CALIBRATE` — set z_offset
4. `BED_MESH_CALIBRATE` — mesh the bed
5. `AXIS_TWIST_COMPENSATION_CALIBRATE` — if probe offsets are large
6. `PID_CALIBRATE HEATER=extruder TARGET=200` — PID hotend
7. `PID_CALIBRATE HEATER=heater_bed TARGET=60` — PID bed
8. `SHAPER_CALIBRATE` — if accelerometer present
9. `TUNING_TOWER ...` — pressure advance
10. `SCREWS_TILT_CALCULATE` — manual leveling check
11. `SAVE_CONFIG` after each step that produces data
