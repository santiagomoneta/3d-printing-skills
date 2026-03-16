---
name: orca-slicer
description: OrcaSlicer profile creation, calibration workflows, settings expert, and custom G-code helper
---

# Skill: orca-slicer

# OrcaSlicer Manager — Profile Creation, Calibration & Settings Expert

Expert assistant for OrcaSlicer: creates and edits printer/filament/process profiles, guides
calibration workflows, explains every setting, generates custom G-code with placeholders, and
diagnoses common print quality issues.

> **Credits:** The compliance rules, pipeline checklist, model analysis checklist, and agent
> self-check table in this skill were adapted from
> [`bambu-studio-ai`](https://skills.sh/heyixuan2/bambu-studio-ai/bambu-studio-ai)
> by [@heyixuan2](https://github.com/heyixuan2), rewritten for OrcaSlicer and non-Bambu printers.

**Source:** https://github.com/OrcaSlicer/OrcaSlicer  
**Docs:** https://www.orcaslicer.com/wiki/

---

## ⛔ Compliance Rules — Follow Strictly

**Before every action, verify you are not violating these rules:**

| Rule | Meaning |
|------|---------|
| **MUST** | Non-negotiable. Skip = failure. |
| **NEVER** | Forbidden. Doing it = failure. |
| **WAIT** | Do not proceed until user responds. |

### NEVER Do These

- ❌ **NEVER give profile settings without knowing the printer setup** — Always complete Phase 1 first (printer, nozzle, filament, firmware, goal)
- ❌ **NEVER skip model analysis when a file is provided** — Run the 11-point checklist before recommending any settings
- ❌ **NEVER recommend calibration values without knowing the current symptom** — Use the decision tree, don't guess
- ❌ **NEVER write G-code without knowing the firmware** — Klipper, Marlin, and RepRapFirmware have incompatible syntax
- ❌ **NEVER skip reporting printability issues** — If a model has problems, tell the user before suggesting settings

### MUST Do These

1. **Collect setup info** → Printer, nozzle, filament, firmware, goal (Phase 1)
2. **Analyze model** → Run 11-point checklist if a file or description is provided
3. **Report issues** → Printability score + warnings before recommending settings
4. **Match settings to intent** → Use the correct Quick Values block (functional / visual / speed / miniature)
5. **Validate profiles** → Remind user to run the profile validator after creating/editing profiles

---

## Pipeline Checklist (verify before claiming done)

```text
[ ] Printer setup collected (Phase 1 complete)
[ ] Model analyzed (11-point checklist run, if applicable)
[ ] Printability score + issues reported to user
[ ] Settings matched to intent (functional / visual / speed / miniature)
[ ] Calibration order followed (if calibrating from scratch)
[ ] G-code syntax matched to firmware
[ ] Profile validator reminder given (if profiles were created/edited)
```

---

## Activation

Use this skill when the user asks about:
- Creating or editing OrcaSlicer profiles (printer, filament, process)
- Understanding any OrcaSlicer setting or what value to use
- Running a calibration (temperature, flow, pressure advance, retraction, etc.)
- Writing or debugging custom start/end G-code with placeholder variables
- Diagnosing print quality issues (stringing, under-extrusion, ringing, layer adhesion, etc.)
- Connecting OrcaSlicer to Klipper, OctoPrint, or PrusaLink
- Generating optimized profiles for specific use cases (functional parts, miniatures, speed, visual quality)

---

## Platform Notes

OrcaSlicer runs on **Windows, macOS, and Linux**. Profile files are JSON and work identically
across platforms. All paths below use the notation:

| Placeholder | Windows | macOS | Linux |
|-------------|---------|-------|-------|
| `<config>` | `%APPDATA%\OrcaSlicer` | `~/Library/Application Support/OrcaSlicer` | `~/.config/OrcaSlicer` |
| `<install>` | `C:\Program Files\OrcaSlicer` | `/Applications/OrcaSlicer.app/Contents` | AppImage mount or install dir |

Profile cache lives at `<config>/system/` — **delete it** to force OrcaSlicer to reload profiles
after manual edits to `<install>/resources/profiles/`.

User-created profiles live at `<config>/user/`.

---

## Phase 1: Understand the User's Setup

Before giving advice, establish:
1. **Printer** — make/model, kinematics (Cartesian, CoreXY, Delta), build volume
2. **Nozzle** — diameter (0.2 / 0.4 / 0.6 / 0.8mm), material (brass, hardened, ruby)
3. **Filament type** — PLA / PETG / ABS / ASA / TPU / PA / PC / etc.
4. **Firmware** — Klipper, Marlin, RepRapFirmware, PrusaFirmware, Bambu
5. **Goal** — speed, visual quality, functional strength, miniatures, multicolor

If the user has a Klipper printer, recommend adding to `printer.cfg`:
```ini
[exclude_object]
[gcode_arcs]
resolution: 0.1
```

---

## Phase 1b: Model Analysis (when a file or model description is provided)

Before recommending any settings, run this 11-point printability check and report results to the user.

### 11-Point Checklist

| # | Check | Pass Criteria |
|---|-------|---------------|
| 1 | **Wall thickness** | ≥ 1× nozzle diameter (min 0.4mm for 0.4mm nozzle) |
| 2 | **Overhangs** | ≤ 45° without support; flag anything steeper |
| 3 | **Print orientation** | Maximize flat base area; minimize unsupported overhangs |
| 4 | **Floating / disconnected parts** | No islands; all geometry connected |
| 5 | **Watertight / manifold** | No open edges, holes, or non-manifold geometry |
| 6 | **Build volume fit** | Model fits within printer's printable area + height |
| 7 | **Layer height compatibility** | Feature detail ≥ 2× chosen layer height |
| 8 | **Infill rate for load direction** | Structural parts: ≥ 40% with gyroid/cubic |
| 9 | **Top/bottom shell layers** | ≥ 5 layers for watertight top surfaces |
| 10 | **Material compatibility** | Geometry tolerances match material shrinkage (ABS/ASA warp risk) |
| 11 | **Unit detection** | Confirm mm vs meters (common in CAD exports) |

### Reporting Format (MANDATORY)

Always report in this format before giving settings:

```
Printability Score: X/10
Issues found: [list or "none"]
Repairs needed: [list or "none"]
Recommended settings: layer height X mm, infill Y%, walls Z, temp T°C
```

Example: *"Score 7/10. Overhang at 62° on left arm — recommend support or reorientation. Wall thickness 0.38mm at tip — borderline for 0.4mm nozzle. Recommended: 0.20mm layers, 40% gyroid infill, 4 walls, PLA 215°C."*

---

## Phase 2: Profile Architecture

OrcaSlicer uses a 4-level JSON profile hierarchy. See `references/profiles.md` for full details.

```
Vendor meta (.json)
└── Printer model (machine_model)
    └── Printer variant (machine)   ← nozzle-specific
        ├── Process profile          ← layer height, speeds, quality
        └── Filament profile         ← temps, flow, cooling, PA
```

### Profile Locations (installed)
```
<install>/resources/profiles/
├── VendorName.json               ← vendor meta
└── VendorName/
    ├── machine/
    │   ├── PrinterModel.json     ← machine_model
    │   └── PrinterModel 0.4 nozzle.json  ← machine
    ├── process/
    │   └── 0.20mm Standard @PrinterModel 0.4.json
    └── filament/
        └── Generic PLA @PrinterModel@.json
```

### Profile Naming Convention
| Type | Pattern |
|------|---------|
| Vendor meta | `VendorName.json` |
| Machine model | `VendorName PrinterName.json` |
| Machine variant | `VendorName PrinterName 0.4 nozzle.json` |
| Process | `0.20mm Standard @VendorName PrinterName 0.4.json` |
| Filament | `Generic PLA @VendorName PrinterName@.json` |

---

## Phase 3: Calibration Workflows

Always follow this order when calibrating from scratch. See `references/calibration.md` for
step-by-step detail on each test.

### Recommended Calibration Order

1. **Temperature** — find optimal nozzle temp for layer adhesion vs. stringing
2. **Max Volumetric Speed** — find the flow ceiling before under-extrusion
3. **Pressure Advance** — reduce corner bulging and improve dimensional accuracy
4. **Flow Rate** — fine-tune extrusion multiplier for accurate dimensions
5. **Retraction** — eliminate stringing
6. **Cornering** (Jerk / Junction Deviation) — reduce corner artifacts
7. **Input Shaping** — eliminate ringing/ghosting (accelerometer required)
8. **VFA** — find resonance-free speed ranges
9. **Tolerance** (optional) — tune for tight-fitting parts

> All calibrations are under **Calibration** tab in OrcaSlicer. After each calibration, **create
> a new project** to exit calibration mode before printing normally.

### Quick Calibration Decision Tree

| Symptom | Run This |
|---------|----------|
| Stringing | Temp ↓, then Retraction |
| Under-extrusion | Temp ↑, then Max Volumetric Speed, then Flow Rate |
| Corner bulging | Pressure Advance |
| Ringing / ghosting | Input Shaping |
| Wrong dimensions | Flow Rate, then Tolerance |
| VFA bands / zebra stripes | VFA speed test |
| Rough top surface | Flow Rate, Ironing |

---

## Phase 4: Key Settings Reference

See `references/settings.md` for the full annotated settings reference.

### Quick Values by Intent

#### Functional / Engineering Parts
```
layer_height:          0.20–0.30mm
wall_loops:            4–6
top/bottom_shell_layers: 5–7
infill_density:        40–60%
infill_pattern:        gyroid / cubic / grid
print_speed:           60–120 mm/s (match MVS)
enable_support:        true (tree support for overhangs > 50°)
```

#### Visual / Display Quality
```
layer_height:          0.08–0.15mm
wall_loops:            3–4
wall_sequence:         inner/outer/inner (sandwich)
seam_position:         back or aligned
ironing_type:          top surfaces
print_speed:           40–80 mm/s
```

#### Speed / Draft
```
layer_height:          0.25–0.35mm
wall_loops:            2
infill_density:        10–15%
print_speed:           150–300 mm/s (limited by MVS)
acceleration:          limited by printer capability / input shaper result
```

#### Miniatures / Fine Detail
```
layer_height:          0.06mm (optimal balance); 0.08mm acceptable; below 0.05mm diminishing returns
nozzle:                0.2mm strongly recommended — 0.4mm loses fine detail
line_width:            100% of nozzle diameter (0.20mm with 0.2mm nozzle)
inner_wall_line_width: 120%
outer_wall_line_width: 115%
top_surface_line_width: 105%
wall_loops:            3
wall_sequence:         inner-outer-inner (sandwich)
wall_generator:        classic (not Arachne — fewer edge-case artifacts at small scales)
sparse_infill_density: 20% gyroid; reduce to 15% only for single-piece supportless models
outer_wall_speed:      35 mm/s
inner_wall_speed:      55 mm/s
top_surface_speed:     35 mm/s
gap_infill_speed:      30 mm/s
overhang_1_4_speed:    40 mm/s
overhang_2_4_speed:    30 mm/s
overhang_3_4_speed:    20 mm/s
default_acceleration:  2000 mm/s² (outer wall + top surface: 1000 mm/s²)
initial_layer_height:  0.12mm
brim:                  outer_only, 6mm — critical for thin bases and multi-piece prints
skirt:                 2 loops, 2.5mm distance — primes nozzle before model
seam:                  scarf seam entire loop
xy_contour_compensation: 0.05mm
xy_hole_compensation:  -0.1mm
resolution:            0.001mm
reduce_crossing_wall:  enabled
reduce_infill_retraction: enabled only with calibrated filament; disable if nozzle hits print
bridge_flow:           0.85
```

**Support settings for miniatures (critical):**
```
support_type:              tree(auto) organic/grid — NOT slim (slim skips interface generation)
support_threshold_angle:   15° conservative; increase to 20–25° if spaghetti occurs, max 30°
support_top_z_distance:    must be a multiple of layer_height:
                             0.06mm layers → 0.18mm
                             0.08mm layers → 0.24mm (easier removal)
                             0.12mm layers → 0.12mm (cleaner surface, harder removal)
support_bottom_z_distance: 0mm
support_interface_spacing: 0.2mm
support_base_pattern:      rectilinear-grid, spacing 3mm
tree_support_tip_diameter: 1.2mm — CRITICAL: values below 1.0mm suppress interface generation,
                           causing supports to fuse directly to the model
tree_support_branch_diameter: 1.0mm
tree_support_branch_distance: 1.0mm
tree_support_wall_count:   2
support_on_build_plate_only: true
```

**Miniature-specific workflow tips (from community testing):**
- **Split complex models into parts** and orient each piece to minimize overhangs — bigger impact than any setting tweak
- **Orientation first**: maximize flat base area, rotate arms/weapons to reduce unsupported angles
- **Filament calibration** (flow ratio, PA, temperature) has more quality impact than going from 0.06mm to 0.05mm layers
- **Dry filament**: 8h at 50°C for PLA before printing — moisture causes surface defects at 0.06mm layers
- **Recommended filaments**: eSun PLA+ HS (better overhangs), Sunlu PLA+ 2.0 HS (better surface quality)
- **Ironing**: off for miniatures (few flat surfaces); enable only for vehicles/terrain with large flat tops
- **If nozzle hits print**: disable `reduce_infill_retraction` first — most common cause
- **If support trees fall over**: check first layer adhesion — tree supports need a solid anchor
- **If support interface is missing** in preview (dark green layer absent): increase `tree_support_tip_diameter` — without it, supports fuse to the model

> **Source:** "Dungeons and Derps" HQ Profile v2.0 by u/ObscuraNox
> ([r/FDMminiatures](https://www.reddit.com/r/FDMminiatures/comments/1rbnet7/high_quality_profile_version_20_is_here/)) —
> settings and rationale extracted from the v2.0 JSON profile and full documentation post.

---

## Phase 5: Custom G-Code

OrcaSlicer exposes rich placeholder variables in machine start/end G-code, filament
start/end G-code, layer change G-code, and toolchange G-code.

See `references/placeholders.md` for the complete variable reference.

### Common Start G-Code Patterns (Klipper)

```gcode
; --- Machine Start G-code for Klipper ---
M104 S0                          ; cancel any temp from preview
M140 S0
PRINT_START BED={first_layer_bed_temperature[0]} EXTRUDER={first_layer_temperature[0]}
```

```gcode
; --- Machine Start G-code (inline heating) ---
G28                              ; home
M190 S{first_layer_bed_temperature[0]}   ; wait for bed
M109 S{first_layer_temperature[0]}       ; wait for nozzle
G29                              ; bed leveling (if not in PRINT_START)
```

### Layer Change G-Code
```gcode
; pause at layer 3 for color change
{if layer_num == 3}M600{endif}
```

### Conditional G-Code Syntax
```gcode
{if condition}...{endif}
{if condition}...{else}...{endif}
{value|default(fallback)}
```

### Temperature Placeholders
```gcode
M104 S{first_layer_temperature[0]}         ; initial layer nozzle
M190 S{first_layer_bed_temperature[0]}     ; initial layer bed
M104 S{nozzle_temperature[0]}              ; normal printing temp
M140 S{bed_temperature[0]}                 ; normal bed temp
```

---

## Phase 6: Filament Profiles — Key Parameters

| Parameter | PLA | PETG | ABS/ASA | TPU | PA/Nylon |
|-----------|-----|------|---------|-----|----------|
| Nozzle temp | 190–220°C | 230–250°C | 235–260°C | 210–240°C | 240–280°C |
| Bed temp | 55–65°C | 70–85°C | 100–115°C | 30–60°C | 70–90°C |
| Chamber | — | — | 40–50°C | — | 50–60°C |
| Fan speed | 80–100% | 20–50% | 0–20% | 50–80% | 0–30% |
| Flow ratio | 0.95–1.0 | 0.95–1.0 | 0.95–1.0 | 0.9–1.0 | 0.95–1.0 |
| Max vol. speed | 12–20 mm³/s | 8–15 mm³/s | 8–12 mm³/s | 3–8 mm³/s | 6–12 mm³/s |
| Pressure advance | 0.02–0.06 | 0.04–0.10 | 0.02–0.06 | 0.05–0.15 | 0.03–0.08 |
| Retraction (DD) | 0.4–1.0mm | 0.5–1.5mm | 0.5–1.0mm | 1.0–3.0mm | 0.5–1.5mm |
| Retraction (Bowden) | 3–6mm | 4–7mm | 4–7mm | 2–4mm | 4–8mm |

---

## Phase 7: Diagnosing Print Quality Issues

| Issue | Likely Cause | Setting to Adjust |
|-------|-------------|-------------------|
| Stringing | Temp too high, retraction too low | Lower temp, increase retraction, check PA |
| Under-extrusion | Temp too low, flow too fast, clogged | Raise temp, reduce speed, check flow ratio |
| Over-extrusion | Flow ratio too high | Reduce `filament_flow_ratio` |
| Corner bulging | PA too low | Increase `pressure_advance` |
| Ringing/ghosting | Mechanical resonance | Run Input Shaping calibration |
| Layer adhesion failure | Temp too low | Raise nozzle temp |
| Warping | Bed temp too low, no enclosure | Raise bed temp, add brim, enclose printer |
| Elephant foot | First layer too squished | Raise z-offset, or enable "elephant foot compensation" |
| Gaps in top surface | Flow too low, or top speed too high | Increase flow ratio, reduce top surface speed |
| Pillowing on top | Cooling too aggressive, too few top layers | Reduce fan, add top layers |
| Support not removable | Interface too tight | Increase support/object gap, use PETG interface for PLA |
| Seam visible | Seam position not ideal | Use "aligned" or "rear" seam, or scarf seam |
| VFA / zebra bands | Resonance at specific speed | VFA test to find and avoid resonant speeds |

---

## Phase 8: Network Printer Integration

### Klipper (via Moonraker)
In OrcaSlicer: **Printer Settings → Connection**
- Protocol: `Moonraker`
- Hostname/IP: `<printer_ip>`
- Port: `7125`
- API key: (leave blank if not configured)

### OctoPrint
- Protocol: `OctoPrint`
- Hostname/IP: `<printer_ip>`
- Port: `5000` (default)
- API key: from OctoPrint → Settings → Application Keys

### PrusaLink (Prusa MK4 / XL)
- Protocol: `PrusaLink`
- Hostname/IP: `<printer_ip>`
- Password: found on printer screen

### Bambu Lab
- Uses the proprietary Bambu networking plugin (optional install)
- Cloud mode requires Bambu account
- LAN mode: enable on printer, set access code in OrcaSlicer

---

## Phase 9: Profile JSON Structure

### Minimal Printer Variant (machine) Profile
```json
{
  "type": "machine",
  "name": "MyPrinter 0.4 nozzle",
  "inherits": "fdm_machine_common",
  "from": "system",
  "instantiation": "true",
  "nozzle_diameter": ["0.4"],
  "printer_model": "MyPrinter",
  "printer_variant": "0.4",
  "printable_area": ["0x0", "235x0", "235x235", "0x235"],
  "printable_height": 250,
  "default_filament_profile": ["Generic PLA @System"],
  "default_print_profile": "0.20mm Standard @MyPrinter 0.4",
  "machine_start_gcode": "PRINT_START BED={first_layer_bed_temperature[0]} EXTRUDER={first_layer_temperature[0]}",
  "machine_end_gcode": "PRINT_END"
}
```

### Minimal Filament Profile
```json
{
  "type": "filament",
  "name": "Generic PLA @MyPrinter@",
  "inherits": "Generic PLA @System",
  "from": "system",
  "instantiation": "true",
  "nozzle_temperature": ["215"],
  "bed_temperature": ["60"],
  "filament_flow_ratio": ["0.98"],
  "compatible_printers": ["MyPrinter 0.4 nozzle"]
}
```

### Minimal Process Profile
```json
{
  "type": "process",
  "name": "0.20mm Standard @MyPrinter 0.4",
  "inherits": "fdm_process_common",
  "from": "system",
  "instantiation": "true",
  "layer_height": 0.2,
  "print_speed": 150,
  "compatible_printers": ["MyPrinter 0.4 nozzle"]
}
```

---

## Phase 10: Profile Validation

After creating or editing profiles, validate them:

### Method 1 — OrcaSlicer Profile Validator
```bash
# Linux / macOS
./OrcaSlicer_profile_validator -p /path/to/resources/profiles -l 2 -v VendorName

# Windows
OrcaSlicer_profile_validator.exe --path C:\path\to\resources\profiles -l 2 -v VendorName
```

### Method 2 — Python Script
```bash
python orca_extra_profile_check.py --vendor="VendorName" --check-filaments --check-materials
```

### Force Profile Reload (after editing installed profiles)
Delete the system cache:
- Windows: `%APPDATA%\OrcaSlicer\system\`
- macOS: `~/Library/Application Support/OrcaSlicer/system/`
- Linux: `~/.config/OrcaSlicer/system/`

Then restart OrcaSlicer.

---

## Common Agent Mistakes (self-check)

| Mistake | Correct Behavior |
|---------|-----------------|
| Giving settings without knowing the printer | MUST complete Phase 1 first — ask printer, nozzle, filament, firmware, goal |
| Skipping model analysis because "it's a simple shape" | ALL models need the 11-point check — simple shapes can still have bad walls or wrong units |
| Recommending calibration order out of sequence | Always follow: Temp → MVS → PA → Flow → Retraction → Cornering → Input Shaping |
| Writing Klipper G-code for a Marlin printer | MUST confirm firmware before writing any G-code |
| Giving a single "best" setting without knowing the goal | Always ask: functional / visual / speed / miniature — settings differ significantly |
| Skipping the printability score report | MUST report score + issues before recommending settings, even if score is 10/10 |
| Suggesting retraction values without knowing direct drive vs Bowden | MUST ask extruder type — values differ by 3–5× |
| Editing installed profiles without mentioning cache deletion | MUST remind user to delete `<config>/system/` cache and restart OrcaSlicer |

---

## References

- `references/profiles.md` — Full profile JSON schema, inheritance rules, field reference
- `references/calibration.md` — Step-by-step calibration procedures for every test
- `references/placeholders.md` — Complete built-in placeholder variable reference
- `references/settings.md` — Annotated settings reference for all three profile types

**Wiki:** https://www.orcaslicer.com/wiki/  
**GitHub:** https://github.com/OrcaSlicer/OrcaSlicer  
**Releases:** https://github.com/OrcaSlicer/OrcaSlicer/releases/latest
