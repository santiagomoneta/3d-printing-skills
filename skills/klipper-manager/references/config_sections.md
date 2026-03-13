# Klipper Config Sections — Parameter Reference

All parameters from Klipper's Config_Reference. Required parameters marked with *.
Parameters in SAVE_CONFIG block marked with [SC].

Source: https://www.klipper3d.org/Config_Reference.html

---

## [mcu]
```ini
serial: *                  # /dev/serial/by-id/... or /dev/ttyUSB0
baud: 250000               # default 250000
canbus_uuid:               # if using CAN bus
restart_method: command    # arduino|cheetah|rpi_usb|command
```

## [printer]
```ini
kinematics: *              # cartesian|corexy|corexz|delta|deltesian|polar|rotary_delta|winch|none
max_velocity: *            # mm/s — SET_VELOCITY_LIMIT at runtime
max_accel: *               # mm/s²
minimum_cruise_ratio: 0.5  # 0.0–1.0
square_corner_velocity: 5.0 # mm/s
max_z_velocity:            # cartesian/corexy/corexz only
max_z_accel:               # cartesian/corexy/corexz only
```

## [stepper_x/y/z/a/b/c]
```ini
step_pin: *
dir_pin: *
enable_pin:
rotation_distance: *       # mm per full motor rotation
microsteps: *              # 8|16|32|64|128|256
full_steps_per_rotation: 200  # 200=1.8°|400=0.9°
gear_ratio:                # e.g. "5:1" or "57:11, 2:1"
endstop_pin: *             # for X/Y/Z on cartesian
position_endstop: *        # mm — must be at position_min or position_max
position_min: 0            # soft limit
position_max: *            # soft limit — CRITICAL for range validation
homing_speed: 5.0          # mm/s
homing_retract_dist: 5.0   # mm (set to 0 for sensorless homing)
second_homing_speed:       # default: homing_speed/2
```

## [extruder]
```ini
step_pin: *
dir_pin: *
enable_pin:
rotation_distance: *       # ~7-8 for BMG direct; ~20-40 for bowden
microsteps: *
nozzle_diameter: *         # 0.400
filament_diameter: 1.750
heater_pin: *
sensor_type: *             # thermistor type string
sensor_pin: *
control: pid               # pid|watermark
pid_Kp: [SC]
pid_Ki: [SC]
pid_Kd: [SC]
min_temp: 0
max_temp: 300
pressure_advance: 0.0      # 0=disabled; SET_PRESSURE_ADVANCE at runtime
pressure_advance_smooth_time: 0.040
max_extrude_only_distance: 50
max_extrude_cross_section: 4.0  # = 4 × nozzle_diameter²
min_extrude_temp: 170
```

## [heater_bed]
```ini
heater_pin: *
sensor_type: *
sensor_pin: *
control: pid
pid_Kp: [SC]
pid_Ki: [SC]
pid_Kd: [SC]
min_temp: 0
max_temp: 130
```

## [bltouch]
```ini
sensor_pin: *              # ^PC14 (^ = pull-up)
control_pin: *             # PA1
x_offset: *                # mm from nozzle; negative = probe left of nozzle
y_offset: *                # mm from nozzle; negative = probe in front of nozzle
# z_offset: [SC]           # set by PROBE_CALIBRATE + SAVE_CONFIG
speed: 5.0                 # probing speed mm/s
lift_speed:                # default = speed
samples: 1
sample_retract_dist: 5.0
samples_result: average    # average|median
samples_tolerance: 0.100
samples_tolerance_retries: 0
set_output_mode:           # 5V|OD (for BLTouch V3.1)
pin_move_time: 0.680
stow_on_each_sample: True  # False = faster but less safe
probe_with_touch_mode: False
pin_up_reports_not_triggered: True
pin_up_touch_mode_reports_triggered: True
```

## [probe]  (generic probe, not BLTouch)
```ini
pin: *
x_offset: 0.0
y_offset: 0.0
# z_offset: [SC]
speed: 5.0
samples: 1
sample_retract_dist: 5.0
samples_result: average
samples_tolerance: 0.100
samples_tolerance_retries: 0
activate_gcode:            # gcode to run before probing
deactivate_gcode:
```

## [bed_mesh]
```ini
speed: 50                  # mm/s non-probing moves
horizontal_move_z: 5       # mm — Z height before probing
mesh_min: *                # x,y in PROBE coordinates
mesh_max: *                # x,y in PROBE coordinates
probe_count: 3, 3          # points per axis (min 3×3 for bicubic)
mesh_pps: 2, 2             # mesh points per segment for interpolation
algorithm: lagrange        # lagrange (≤3×3) | bicubic (4×4+)
bicubic_tension: 0.2       # 0.0–1.0 (higher = more aggressive curve following)
move_check_distance: 5     # mm — fade/mesh check frequency
fade_start: 1.0            # mm height to start fading out correction
fade_end: 0.0              # mm height where correction = 0 (0=disabled)
fade_target: 0.0           # mesh height at which fading ends
split_delta_z: .025        # minimum Z delta to trigger segment split
adaptive_margin: 0         # margin around objects for ADAPTIVE=1
zero_reference_position:   # x,y — if set, mesh is zeroed at this probe point
```

## [axis_twist_compensation]
```ini
speed: 50
horizontal_move_z: 5
calibrate_start_x: *      # PROBE X coordinate (nozzle = start_x - x_offset)
calibrate_end_x: *        # PROBE X coordinate (nozzle = end_x - x_offset)
calibrate_y: *            # PROBE Y coordinate (nozzle = calibrate_y - y_offset)
# z_compensations: [SC]
# compensation_start_x: [SC]
# compensation_end_x: [SC]
```

## [safe_z_home]
```ini
home_xy_position: *       # x,y — NOZZLE position for Z homing
speed: 50                 # mm/s move to home position
z_hop: 0                  # mm — lift before moving to home position
z_hop_speed: 15
move_to_previous: False   # return to previous XY position after Z home
```

## [homing_override]
```ini
gcode: *                  # gcode to run instead of G28
axes: xyz                 # axes this override applies to
set_position_x:           # virtual position to set after override
set_position_y:
set_position_z:
```

## [screws_tilt_adjust]
```ini
screw1: *                 # x,y PROBE coordinates of screw 1 (base screw)
screw1_name:
screw2: *
screw2_name:
# ... up to screw12
horizontal_move_z: 10
speed: 50
screw_thread: CW-M4       # CW-M3|CCW-M3|CW-M4|CCW-M4|CW-M5|CCW-M5
```

## [bed_tilt]
```ini
# x_adjust: [SC]
# y_adjust: [SC]
# z_adjust: [SC]
points:                   # list of x,y probe points
speed: 50
horizontal_move_z: 5
```

## [z_tilt]
```ini
z_positions: *            # list of x,y positions of each Z stepper
points: *                 # list of x,y probe points
speed: 50
horizontal_move_z: 5
retries: 0
retry_tolerance: 0.0
```

## [quad_gantry_level]
```ini
gantry_corners: *         # two diagonally opposite corners of the gantry
points: *                 # four probe points (one near each gantry corner)
speed: 50
horizontal_move_z: 5
retries: 0
retry_tolerance: 0.0
```

## [input_shaper]
```ini
shaper_freq_x: 0          # Hz — 0=disabled; set by SHAPER_CALIBRATE [SC]
shaper_freq_y: 0
shaper_type: mzv          # zv|mzv|zvd|ei|2hump_ei|3hump_ei
shaper_type_x:            # override per-axis
shaper_type_y:
damping_ratio_x: 0.1      # 0.0–1.0
damping_ratio_y: 0.1
```

## [resonance_tester]
```ini
accel_chip: adxl345       # name of the accelerometer chip section
probe_points: *           # x,y,z list of points to test
min_freq: 5               # Hz start
max_freq: 133.33          # Hz end
accel_per_hz: 75          # mm/s² per Hz
hz_per_sec: 1             # Hz sweep rate
```

## [adxl345]
```ini
cs_pin: *                 # SPI CS pin OR rpi:None for RPi native SPI
spi_bus:                  # spi0|spi1|...
spi_speed: 5000000
axes_map: x,y,z           # remap axes if accelerometer is mounted differently
rate: 3200                # 3200|1600|800|400|200|100|50|25
```

## [firmware_retraction]
```ini
retract_length: 0         # mm — 0=disabled; direct: 0.4–1.0; bowden: 4–7
retract_speed: 20         # mm/s
unretract_extra_length: 0 # extra length to push on unretract
unretract_speed: 10       # mm/s
```

## [tmc2209 stepper_x]  (and stepper_y, stepper_z, extruder)
```ini
uart_pin: *
tx_pin:                   # if separate TX pin
uart_address: 0           # 0–3 (for multi-driver UART chains)
run_current: *            # Amps RMS — start at 70% rated motor current
hold_current:             # OMIT unless needed (causes vibration)
sense_resistor: 0.110
stealthchop_threshold: 0  # mm/s — 0=always spreadCycle; 999999=always stealthChop
interpolate: True         # micro-step interpolation (small positional error)
driver_SGTHRS:            # 0–255 for sensorless homing (255=most sensitive)
driver_TBL:               # tuning register
driver_TOFF:
driver_HEND:
driver_HSTRT:
```

## [tmc2130 stepper_x]
```ini
cs_pin: *
spi_bus:
run_current: *
hold_current:
sense_resistor: 0.110
stealthchop_threshold: 0
interpolate: True
driver_SGT: 0             # -64 to 63 for sensorless homing
```

## [tmc5160 stepper_x]
```ini
cs_pin: *
spi_bus:
run_current: *
hold_current:
sense_resistor: 0.075     # tmc5160 default differs
stealthchop_threshold: 0
interpolate: True
driver_SGT: 0
```

## [gcode_macro NAME]
```ini
gcode: *                  # gcode to execute when NAME is called
description:              # help text shown by HELP command
variable_<name>:          # initial value of a variable
rename_existing:          # rename the command this macro overrides
```

## [delayed_gcode NAME]
```ini
gcode: *
initial_duration: 0       # seconds — 0=don't run at startup
```

## [idle_timeout]
```ini
gcode:                    # gcode to run on idle timeout
timeout: 600              # seconds
```

## [virtual_sdcard]
```ini
path: *                   # /home/pi/printer_data/gcodes
on_error_gcode:           # gcode to run on print error
```

## [pause_resume]
```ini
recover_velocity: 50      # mm/s
```

## [exclude_object]
# No parameters — just include the section

## [gcode_arcs]
```ini
resolution: 1.0           # mm — arc interpolation resolution
```

## [respond]
```ini
default_type: echo        # echo|command|error
default_prefix: echo:
```

## [skew_correction]
# No parameters in section header — profiles saved by SAVE_CONFIG
# [SC] xy_skew, xz_skew, yz_skew stored per profile name

## [save_variables]
```ini
filename: *               # path to variables file e.g. ~/variables.cfg
```

## [force_move]
```ini
enable_force_move: False  # set True to enable FORCE_MOVE and SET_KINEMATIC_POSITION
```

## [fan]  (part cooling fan)
```ini
pin: *
max_power: 1.0
shutdown_speed: 0
cycle_time: 0.010
hardware_pwm: False
kick_start_time: 0.100    # seconds at full power on startup
off_below: 0.0            # min PWM (0.0–1.0)
tachometer_pin:
tachometer_ppr: 2
tachometer_poll_interval: 0.0015
```

## [heater_fan NAME]
```ini
pin: *
max_power: 1.0
heater: extruder          # which heater controls this fan
heater_temp: 50.0         # turn on when heater above this temp
fan_speed: 1.0
```

## [temperature_fan NAME]
```ini
pin: *
sensor_type: *
sensor_pin: *
target_temp: *
min_temp: *
max_temp: *
control: watermark        # watermark|pid
```

## [output_pin NAME]
```ini
pin: *
pwm: False
static_value:             # if set, pin is static at this value
value: 0                  # initial value 0.0–1.0
shutdown_value: 0
cycle_time: 0.100
hardware_pwm: False
scale:                    # scale factor for SET_PIN VALUE
```

## [neopixel NAME]
```ini
pin: *
chain_count: 1
color_order: GRB          # RGB|GRB|RGBW|GRBW
initial_RED: 0.0
initial_GREEN: 0.0
initial_BLUE: 0.0
initial_WHITE: 0.0
```

## [filament_switch_sensor NAME]
```ini
switch_pin: *
pause_on_runout: True
runout_gcode:
insert_gcode:
event_delay: 3.0
pause_delay: 0.5
```

## [endstop_phase stepper_z]
# Enables more precise endstop positioning using stepper phases
# Calibrated by ENDSTOP_PHASE_CALIBRATE STEPPER=stepper_z

## [temperature_sensor NAME]
```ini
sensor_type: *
sensor_pin: *
min_temp: -273.15
max_temp: 9999999
```

## [mcu rpi]  (Raspberry Pi as secondary MCU)
```ini
serial: /tmp/klipper_host_mcu
```

## [board_pins]  (alias map for board-specific pin names)
```ini
mcu:                      # which MCU these aliases apply to
aliases:                  # alias_name=GPIO_pin pairs
```

## [include path/to/file.cfg]
# Includes another config file. Supports glob: macros/*.cfg

---

## SAVE_CONFIG Block Format

Klipper automatically manages this block. Never edit manually.

```ini
#*# <---------------------- SAVE_CONFIG ---------------------->
#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
#*#
#*# [bltouch]
#*# z_offset = 3.439
#*#
#*# [input_shaper]
#*# shaper_type_y = ei
#*# shaper_freq_y = 45.0
#*# shaper_type_x = 3hump_ei
#*# shaper_freq_x = 66.2
#*#
#*# [extruder]
#*# control = pid
#*# pid_kp = 21.527
#*# pid_ki = 1.063
#*# pid_kd = 108.982
#*#
#*# [heater_bed]
#*# control = pid
#*# pid_kp = 54.027
#*# pid_ki = 0.770
#*# pid_kd = 948.182
#*#
#*# [bed_mesh default]
#*# version = 1
#*# points = ...
#*#
#*# [axis_twist_compensation]
#*# z_compensations = 0.012500, 0.005000, -0.017500
#*# compensation_start_x = 20.0
#*# compensation_end_x = 183.0
#*#
#*# [skew_correction CaliFlower]
#*# xy_skew = 0.0013986
#*# xz_skew = 0.0
#*# yz_skew = 0.0
```
