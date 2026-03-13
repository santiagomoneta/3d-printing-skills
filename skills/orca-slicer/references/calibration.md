# OrcaSlicer Calibration Reference

Source: https://www.orcaslicer.com/wiki/calibration/Calibration.html

All calibrations are accessed via the **Calibration** tab in OrcaSlicer.
After completing any calibration, **create a new project** to exit calibration mode.

---

## Recommended Order

1. Temperature
2. Max Volumetric Speed
3. Pressure Advance (+ Adaptive PA)
4. Flow Rate
5. Retraction
6. Cornering (Jerk / Junction Deviation)
7. Input Shaping
8. VFA
9. Tolerance (optional, for tight-fitting parts)

---

## 1. Temperature Calibration

**Goal:** Find the nozzle temperature that balances layer adhesion, surface quality, and stringing.

**How:**
1. Calibration → Temperature
2. Set start temp (e.g. 190°C for PLA), end temp (e.g. 230°C), step (5°C)
3. Print the temp tower — each section prints at a different temperature
4. Inspect each band:
   - Too low: poor layer adhesion, rough surface, brittle
   - Too high: stringing, blobbing, glossy/burnt look
5. Pick the lowest temp with good adhesion and no defects
6. Set `nozzle_temperature` in the filament profile

**Tips:**
- Run this first — temperature affects every other calibration
- Different brands of the same material can vary 10–20°C
- If the part is structural, lean slightly warmer for better layer bonding
- If visual quality is priority, lean slightly cooler for less stringing

---

## 2. Max Volumetric Speed (MVS) Calibration

**Goal:** Find the maximum flow rate (mm³/s) before under-extrusion appears.

**How:**
1. Calibration → Volumetric Speed
2. Print the test — a single-wall line that increases in volumetric speed over height
3. Inspect where the line becomes irregular, rough, or starts skipping
4. Note the height where degradation begins, read the speed from the scale
5. Apply a 10–20% safety margin: `MVS_safe = measured_max × 0.85`
6. Set `filament_max_volumetric_speed` in the filament profile

**Typical values:**
- PLA: 12–20 mm³/s
- PETG: 8–15 mm³/s
- ABS/ASA: 8–12 mm³/s
- TPU: 3–8 mm³/s

**Formula to convert speed → volumetric:**
```
volumetric (mm³/s) = speed (mm/s) × layer_height (mm) × line_width (mm)
```

Example: 150 mm/s × 0.2mm × 0.42mm = 12.6 mm³/s

---

## 3. Pressure Advance (PA) Calibration

**Goal:** Compensate for pressure buildup/release in the nozzle to reduce corner bulging and improve
dimensional accuracy.

**Wiki:** https://www.orcaslicer.com/wiki/calibration/pressure-advance-calib.html

### Method 1 — PA Line (recommended for Klipper)
1. Calibration → Pressure Advance → PA Line
2. Print the test — a single line where PA value increases over the X axis
3. Find the point where corners are sharpest (no rounding, no bulge)
4. Read the PA value from the scale on the test
5. Set `pressure_advance` in the filament profile

### Method 2 — PA Tower
1. Calibration → Pressure Advance → PA Tower
2. Set start/end PA values and step
3. Print the tower — each layer has a different PA value
4. Find the layer with sharpest corners
5. Calculate: `PA = start + step × best_layer_number`

**Typical PA values:**
- Direct drive: 0.02–0.08
- Bowden: 0.4–1.2
- PETG/flexible: slightly higher than PLA for same setup

**Klipper note:** PA is called "Pressure Advance" in Klipper config (`pressure_advance` in `[extruder]`).
OrcaSlicer sends the value via `SET_PRESSURE_ADVANCE` in start G-code when enabled.

### Adaptive Pressure Advance (APA)
**Wiki:** https://www.orcaslicer.com/wiki/calibration/adaptive-pressure-advance-calib.html

- Varies PA based on print speed — more accurate than a single fixed value
- Run multiple PA tests at different speeds, plot a curve
- OrcaSlicer automatically adjusts PA as speed changes during the print
- Enable in: Filament → Flow ratio and pressure advance → Adaptive Pressure Advance

---

## 4. Flow Rate Calibration

**Goal:** Ensure the correct volume of filament is being extruded — fixing over/under-extrusion.

**Wiki:** https://www.orcaslicer.com/wiki/calibration/flow-rate-calib.html

**How:**
1. Calibration → Flow Rate
2. Print the calibration object (typically a single-wall cube or flow test structure)
3. Measure the wall thickness with calipers
4. Expected wall = 1× line width (e.g., 0.42mm for 0.4mm nozzle at 105%)
5. Calculate: `flow_ratio_new = flow_ratio_current × (expected / measured)`
6. Set `filament_flow_ratio` in the filament profile

**Example:**
- Expected: 0.42mm
- Measured: 0.45mm (over-extruding)
- New flow = 1.0 × (0.42 / 0.45) = 0.933

**Two-pass approach (OrcaSlicer):**
- Pass 1 (coarse): Start at 0.9–1.1, step 0.05 — narrow the range
- Pass 2 (fine): Start at result ± 0.05, step 0.01 — fine tune

---

## 5. Retraction Calibration

**Goal:** Minimize stringing without causing clogs, jams, or gaps.

**Wiki:** https://www.orcaslicer.com/wiki/calibration/retraction-calib.html

**How:**
1. Calibration → Retraction
2. Set retraction length range and step
3. Print the test — a tower with travel moves between pegs
4. Find the lowest retraction value with no stringing
5. Set `retract_length` in the printer or filament profile

**Starting ranges by extruder type:**
| Type | Start | End | Step |
|------|-------|-----|------|
| Direct drive | 0.2mm | 2.0mm | 0.1mm |
| Bowden short (<300mm) | 2.0mm | 6.0mm | 0.5mm |
| Bowden long (>300mm) | 4.0mm | 9.0mm | 0.5mm |

**Common mistake:** Retraction too high causes clogs. For direct drive, almost never go above 2mm.
For Klipper with pressure advance tuned, very low retraction (0.2–0.5mm) is often sufficient.

---

## 6. Cornering Calibration (Jerk / Junction Deviation)

**Goal:** Tune how much the printer decelerates at corners, affecting corner quality and speed.

**Wiki:** https://www.orcaslicer.com/wiki/calibration/cornering-calib.html

**How:**
1. Calibration → Cornering
2. Print the test — multiple copies at different Jerk/JD values
3. Inspect corners:
   - Too high: ringing / artifacts after corners
   - Too low: excessive deceleration, slower prints, visible corner blobs
4. Set in printer firmware or via SET_VELOCITY_LIMIT in start G-code

**Klipper:** Uses `square_corner_velocity` (default 5 mm/s) in `[printer]` section.  
**Marlin:** Uses `DEFAULT_JERK` or Junction Deviation (`JUNCTION_DEVIATION_MM`).

---

## 7. Input Shaping Calibration

**Goal:** Eliminate ringing/ghosting artifacts caused by printer frame resonance.

**Wiki:** https://www.orcaslicer.com/wiki/calibration/input-shaping-calib.html

**Prerequisites:** Accelerometer (ADXL345 for Klipper, or manual ringing tower method)

### Klipper (accelerometer)
1. Run `SHAPER_CALIBRATE` in Klipper terminal or via Mainsail/Fluidd
2. Klipper measures resonance and suggests shaper type + frequency
3. Apply to `[input_shaper]` section in `printer.cfg`
4. In OrcaSlicer, set acceleration limits per the result

### Manual (ringing tower)
1. Calibration → Input Shaping → Ringing Tower
2. Set start/end frequency range and step
3. Print the tower
4. Measure the layer height where ringing disappears
5. Calculate: `frequency = speed / (2 × measured_height_mm_per_oscillation)`
6. Enter in OrcaSlicer process profile: Speed → Input Shaping

**Shaper types (best to most aggressive smoothing):**
- `zv` — fastest, least smoothing
- `mzv` — good for most printers (recommended default)
- `ei` — more smoothing, good for moderate resonance
- `2hump_ei` — heavy smoothing
- `3hump_ei` — very complex resonance (check belt tension first)

---

## 8. VFA (Vertical Fine Artifact) Speed Test

**Goal:** Find printer speeds that cause VFA/zebra-stripe artifacts from resonance.

**Wiki:** https://www.orcaslicer.com/wiki/calibration/vfa-calib.html

**How:**
1. Calibration → VFA
2. Print the test — a cylinder or vase at increasing speeds
3. Identify bands where VFA appears (usually at specific resonant speeds)
4. Avoid those speeds in your process profiles

---

## 9. Tolerance Calibration

**Goal:** Ensure printed holes and shafts fit together correctly.

**Wiki:** https://www.orcaslicer.com/wiki/calibration/tolerance-calib.html

**How:**
1. Calibration → Tolerance
2. Print the test piece (a set of M6/M5/M3 holes or pins)
3. Test fit against real hardware or the mating part
4. Set `hole_to_hole_gap` or `contour_inner_offset` in the process profile
5. Alternatively, scale the model or use the OrcaSlicer "Size Compensation" feature

---

## Calibration Tips

- Always calibrate in order — temperature affects flow, flow affects PA, etc.
- Calibrate with the filament you'll actually print with (different brands vary)
- Re-run calibration when changing: nozzle size, nozzle material (brass → hardened), filament brand, or after major hardware changes
- After calibration, save results to a filament profile so you don't redo it every time
- For production profiles, save per-brand filament profiles (e.g., "Prusament PLA @MyPrinter@")
