# Klipper Troubleshooting Reference

Error patterns, causes, and fixes. Each entry includes the regex pattern to match,
the root cause, and the precise remediation steps with config formulas.

---

## Move / Kinematics Errors

### `!! Move out of range: X Y Z [steps]`

**Pattern:** `Move out of range: (\d+\.\d+) (\d+\.\d+) (\d+\.\d+)`

**Cause:** Klipper computed a nozzle position that exceeds a `position_max` or `position_min`
of one of the steppers. Most commonly triggered during probe-based operations (bed mesh,
axis twist compensation, screws tilt adjust) because calibration coordinates are PROBE
positions — Klipper moves the **nozzle** to put the **probe** at the target, which means
the nozzle travels further than the coordinate value.

**Diagnosis steps:**
1. Note the failing X/Y/Z coordinate from the error
2. Identify which section triggered the move (axis_twist_compensation, bed_mesh, etc.)
3. Get `probe.x_offset` and `probe.y_offset` from config
4. Compute: `nozzle_x = coord_x - probe.x_offset`
5. Compare to `stepper_x.position_max` / `stepper_x.position_min`

**Fix formulas:**

For `[axis_twist_compensation]`:
```
calibrate_end_x   ≤ stepper_x.position_max + probe.x_offset   (x_offset is negative)
calibrate_start_x ≥ stepper_x.position_min - probe.x_offset   (x_offset is positive)
calibrate_y       ≥ stepper_y.position_min - probe.y_offset
calibrate_y       ≤ stepper_y.position_max + probe.y_offset
```

Example: `position_max=246`, `x_offset=-62` → `calibrate_end_x ≤ 246 + (-62) = 184`

For `[bed_mesh]`:
```
mesh_max.x ≤ stepper_x.position_max + probe.x_offset
mesh_min.x ≥ stepper_x.position_min - probe.x_offset
mesh_max.y ≤ stepper_y.position_max + probe.y_offset
mesh_min.y ≥ stepper_y.position_min - probe.y_offset
```

For `[screws_tilt_adjust]`:
```
Each screw (x,y) must satisfy:
  x - probe.x_offset  within [position_min_x, position_max_x]
  y - probe.y_offset  within [position_min_y, position_max_y]
```

---

### `!! Must home axis first: X Y Z [steps]`

**Cause:** A move command was issued before homing. The printer doesn't know its position.

**Fix:** Run `G28` (home all axes) or `G28 X` / `G28 Y` / `G28 Z` for individual axes.

---

### `!! Endstop stepper_x still triggered after retract`

**Cause:** The endstop switch is reporting as triggered even after backing away from it.
Either the endstop is stuck, wiring is shorted, or the pin polarity is wrong.

**Fix:**
1. Run `QUERY_ENDSTOPS` and check the state
2. If always triggered: check endstop wiring / switch mechanism
3. If pin polarity inverted: add/remove `!` prefix on `endstop_pin` in config
   - `endstop_pin: ^PC0` → always low = triggered → try `endstop_pin: ^!PC0`

---

### `!! Probe triggered prior to movement`

**Cause:** The probe is reporting as triggered before any move begins. Common with BLTouch
when the pin is deployed unexpectedly or z_offset is set too far negative.

**Fix:**
1. Send `BLTOUCH_DEBUG COMMAND=reset` to reset the probe
2. Home Z: `G28 Z`
3. If persistent: check `z_offset` — if too large a positive value the probe may be
   triggering at home position
4. Check `horizontal_move_z` in `[bed_mesh]` — must be high enough to clear bed obstacles

---

### `!! Lost communication with MCU 'mcu'`

**Cause:** USB connection to the MCU was interrupted, or the MCU firmware crashed.

**Fix:**
1. Try `FIRMWARE_RESTART`
2. Check USB cable quality and connections
3. If using Raspberry Pi: check power supply (Pi under-voltage can cause USB issues)
4. Re-flash firmware if persistent

---

## TMC Driver Errors

### `!! TMC reports error: ... ot=1(OvertempError!)`

**Cause:** TMC driver overheated. Motor driver chip temperature exceeded threshold.

**Fix:**
1. Reduce `run_current` by ~10-15%
2. Improve airflow / cooling over drivers
3. Check for shorted or high-resistance motor windings
4. `hold_current` if set too high — remove it

---

### `!! TMC reports error: ... ShortToGND` or `ShortToSupply`

**Cause:** Very high current detected — shorted motor wire or defective motor.

**Fix:**
1. Power off and check motor wiring (loose, shorted, or swapped wires)
2. Test motor with a multimeter: each coil pair should be 1–5 Ω
3. If using stealthChop: test with spreadCycle (`stealthchop_threshold: 0`) — stealthChop
   can false-trigger this if load prediction fails

---

### `!! TMC reports error: ... reset=1(Reset)` or `CS_ACTUAL=0`

**Cause:** TMC driver spontaneously reset mid-print. Voltage dropout or EMI.

**Fix:**
1. Check PSU output voltage under load
2. Check stepper driver power connections (common: loose VIN wire to driver board)
3. Add capacitors across stepper driver power rails if PSU has ripple

---

### `!! TMC reports error: ... uv_cp=1(Undervoltage!)`

**Cause:** Charge pump undervoltage on TMC driver — PSU voltage too low.

**Fix:**
1. Verify PSU is 12V or 24V (match to driver spec)
2. Check wiring for resistance causing voltage drop under load
3. Replace PSU if output drops below spec under load

---

### `Unable to read tmc uart 'stepper_x' register IFCNT`

**Cause:** Klipper cannot communicate with a TMC2208/2209 driver via UART.

**Fix:**
1. Check that motor power (VIN) is connected — driver won't respond without it
2. Verify `uart_pin`, `tx_pin`, and `uart_address` in config match your board's wiring
3. Power-cycle the printer (unplug USB and power for 10 seconds) — driver may be in a bad state
4. Check for crossed TX/RX wires

---

### `Unable to write tmc spi 'stepper_x' register`

**Cause:** SPI communication failure with TMC2130/5160/2660.

**Fix:**
1. Verify SPI wiring (MOSI, MISO, SCK, CS pins)
2. Check that no other device on the same SPI bus is unconfigured (floating CS pins)
3. For shared SPI bus: ensure all devices have `[static_digital_output]` or proper config

---

## Probe / BLTouch Errors

### `!! BLTouch failed to deploy`

**Cause:** BLTouch pin did not extend. May be wired wrong or power issue.

**Fix:**
1. `BLTOUCH_DEBUG COMMAND=pin_down` — manually deploy
2. If no movement: check 5V supply to BLTouch signal wire
3. Check `control_pin` in config matches actual wiring

---

### `!! Probe samples exceed tolerance`

**Cause:** Multiple probe samples have a range exceeding `samples_tolerance`.

**Fix:**
1. Increase `samples_tolerance` from 0.010 to 0.025 as a temporary measure
2. Root cause: bed surface contamination, loose nozzle, or probe triggering inconsistently
3. Clean nozzle and probe tip
4. For BLTouch: store 5V mode — `BLTOUCH_STORE MODE=5V`
5. Increase `sample_retract_dist` from 2mm to 5mm for more consistent re-deployment

---

## Heater Errors

### `!! Heater extruder not heating at expected rate`

**Cause:** Heater is on but temperature isn't rising fast enough. Heater may be failing,
thermistor wrong type, or heater power insufficient.

**Fix:**
1. Verify `sensor_type` matches your thermistor (wrong type = wrong temperature reading)
2. Common types: `EPCOS 100K B57560G104F`, `ATC Semitec 104GT-2`, `NTC 100K B3950`
3. Run PID calibration: `PID_CALIBRATE HEATER=extruder TARGET=200`
4. Check heater cartridge resistance (24V system: ~13–15 Ω; 12V: ~3–6 Ω)

---

### `!! Thermal runaway detected on extruder`

**Cause:** Temperature drop was detected while heater was supposed to be maintaining temp.

**Fix:**
1. Check for airflow hitting the heater block (part cooling fan blowing on block)
2. Add a silicone sock to the heater block
3. Increase `heating_gain` in `[verify_heater]` or add `[verify_heater extruder]` section
4. Check heater wiring for intermittent connection

---

## Configuration / Startup Errors

### `!! Config error: Section 'X' is not a valid config`

**Cause:** A `[include ...]` file is missing or a section name is misspelled.

**Fix:**
1. Check all `[include path/file.cfg]` lines — verify files exist
2. Verify section names are spelled correctly (case-insensitive but must match exactly)

---

### `!! Option 'X' in section 'Y' must be specified`

**Cause:** A required parameter is missing from a config section.

**Fix:** Add the required parameter. Consult `references/config_sections.md` for what's
mandatory in each section.

---

### `!! Option 'X' in section 'Y' is not valid`

**Cause:** A parameter name is wrong or not supported by the installed Klipper version.

**Fix:**
1. Check spelling against `Config_Reference.html`
2. May be a deprecated option — check `Config_Changes.html` for your Klipper version

---

## Calibration-Specific Issues

### Axis Twist Compensation — `z_compensations` mismatch after bounds change

When `calibrate_end_x` changes, the previously saved `z_compensations` in SAVE_CONFIG
correspond to the OLD bounds (`compensation_end_x`). The saved data is not automatically
re-validated.

**Fix:** Re-run `AXIS_TWIST_COMPENSATION_CALIBRATE` after any bounds change.

---

### Bed Mesh — points outside mesh when printing

If the slicer or KAMP places probe points outside `mesh_min`/`mesh_max`, Klipper will
use the nearest mesh point value for interpolation (not error). But it means part of the
bed is uncorrected.

**Fix:** Expand `mesh_min`/`mesh_max` — ensuring probe coords stay within the valid
reachable area after accounting for probe offsets.

---

### Safe Z Home — probe lands off bed

If `home_xy_position` is such that when the probe is deployed, it would be off the bed
edge, Z probing will give a bad result or miss the bed entirely.

**Fix:** Ensure that at `home_xy_position`:
- Nozzle is at `home_xy_position` (these are NOZZLE coords)
- Probe is at `home_xy_position.x + probe.x_offset`, `home_xy_position.y + probe.y_offset`
- That probe position must be over a solid part of the bed

---

## Performance / Quality Issues

### Ringing / Ghosting in prints

**Cause:** Resonance not compensated or input shaper not tuned.

**Diagnosis:** Run `SHAPER_CALIBRATE` or manually check `[input_shaper]` settings.

**Fix:**
1. If no `[input_shaper]`: add it and run `SHAPER_CALIBRATE`
2. If `shaper_type: 3hump_ei`: suggests high resonance — check belt tension first
3. Belt tension target: ~80-120 Hz for GT2 6mm (measure with phone app: Gates Carbon Drive)

---

### Pressure advance blobs/zits at corners

**Cause:** Pressure advance too high or too low.

**Diagnosis:** Print a PA tower: `TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.005`

**Fix:**
- Blobs at corners: PA too low — increase
- Thinning/gaps at start of lines after corners: PA too high — decrease
- Typical range: 0.02–0.08 for direct drive; 0.4–1.2 for bowden

---

### Under-extrusion after extruder changes

**Cause:** `rotation_distance` incorrect after extruder upgrade.

**Fix:** Calibrate rotation distance:
1. Mark 120mm of filament from the extruder entrance
2. Request 100mm extrusion: `G1 E100 F100`
3. Measure how much was actually consumed
4. `new_rotation_distance = old_rotation_distance × actual_distance / requested_distance`
