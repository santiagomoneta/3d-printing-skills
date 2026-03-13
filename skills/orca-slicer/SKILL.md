---
name: orca-slicer
description: OrcaSlicer profile creation, calibration workflows, settings expert, and custom G-code helper
---

# Skill: orca-slicer

# OrcaSlicer Manager — Profile Creation, Calibration & Settings Expert

Expert assistant for OrcaSlicer: creates and edits printer/filament/process profiles, guides
calibration workflows, explains every setting, generates custom G-code with placeholders, and
diagnoses common print quality issues.

**Source:** https://github.com/OrcaSlicer/OrcaSlicer  
**Docs:** https://www.orcaslicer.com/wiki/

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
layer_height:          0.04–0.10mm (requires 0.2mm nozzle)
line_width:            0.10–0.15mm
wall_loops:            3
support:               tree support, small interface spacing
```

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

## References

- `references/profiles.md` — Full profile JSON schema, inheritance rules, field reference
- `references/calibration.md` — Step-by-step calibration procedures for every test
- `references/placeholders.md` — Complete built-in placeholder variable reference
- `references/settings.md` — Annotated settings reference for all three profile types

**Wiki:** https://www.orcaslicer.com/wiki/  
**GitHub:** https://github.com/OrcaSlicer/OrcaSlicer  
**Releases:** https://github.com/OrcaSlicer/OrcaSlicer/releases/latest
