# OrcaSlicer Profile Reference

Source: https://www.orcaslicer.com/wiki/developer-reference/How-to-create-profiles.html

---

## Profile Types

| Type | JSON `"type"` value | Purpose |
|------|---------------------|---------|
| Vendor meta | (no type field, it's the root) | Lists all profiles for a vendor |
| Printer model | `machine_model` | General printer info, bed model/texture |
| Printer variant | `machine` | Nozzle-specific settings, start/end G-code |
| Filament | `filament` | Temps, flow, cooling, pressure advance |
| Process | `process` | Layer height, speeds, walls, infill, supports |

---

## Directory Layout

```
<install>/resources/profiles/
├── OrcaFilamentLibrary.json        ← global filament library meta
├── OrcaFilamentLibrary/
│   └── filament/
│       ├── Generic PLA @System.json
│       ├── Generic PETG @System.json
│       └── ...
├── VendorName.json                 ← vendor meta
└── VendorName/
    ├── machine/
    │   ├── VendorName PrinterModel.json          (machine_model)
    │   ├── VendorName PrinterModel 0.2 nozzle.json  (machine)
    │   └── VendorName PrinterModel 0.4 nozzle.json  (machine)
    ├── process/
    │   ├── 0.10mm Fine @VendorName PrinterModel 0.2.json
    │   └── 0.20mm Standard @VendorName PrinterModel 0.4.json
    └── filament/
        └── Generic PLA @VendorName PrinterModel@.json
```

User profiles live at:
- Windows: `%APPDATA%\OrcaSlicer\user\`
- macOS: `~/Library/Application Support/OrcaSlicer/user/`
- Linux: `~/.config/OrcaSlicer/user/`

---

## Inheritance System

Profiles use `"inherits"` to extend a parent. Only fields that differ from the parent need
to be specified. The base profiles are:
- `fdm_machine_common` — base for all machine variants
- `fdm_process_common` — base for all process profiles
- `fdm_filament_common` — base for all filament profiles
- `fdm_filament_pla` / `fdm_filament_petg` / `fdm_filament_abs` / etc. — material-type bases
- `Generic PLA @System` / `Generic PETG @System` / etc. — vendor override bases

---

## Vendor Meta File

`VendorName.json` — required, lives in `resources/profiles/`

```json
{
  "name": "VendorName",
  "version": "01.00.00.00",
  "force_update": "0",
  "description": "Human readable description",
  "machine_model_list": [
    { "name": "VendorName PrinterModel", "sub_path": "machine/VendorName PrinterModel.json" }
  ],
  "machine_list": [
    { "name": "fdm_machine_common", "sub_path": "machine/fdm_machine_common.json" },
    { "name": "VendorName PrinterModel 0.4 nozzle", "sub_path": "machine/VendorName PrinterModel 0.4 nozzle.json" }
  ],
  "process_list": [
    { "name": "0.20mm Standard @VendorName PrinterModel 0.4", "sub_path": "process/0.20mm Standard @VendorName PrinterModel 0.4.json" }
  ],
  "filament_list": [
    { "name": "Generic PLA @VendorName PrinterModel@", "sub_path": "filament/Generic PLA @VendorName PrinterModel@.json" }
  ]
}
```

---

## Machine Model Profile Fields

```json
{
  "type": "machine_model",
  "name": "VendorName PrinterModel",
  "nozzle_diameter": "0.2;0.4;0.6;0.8",   // semicolon-separated supported sizes
  "bed_model": "printer-bed.stl",           // optional, 3D bed model filename
  "bed_texture": "printer-bed.svg",         // optional, bed texture filename
  "model_id": "PM001",                      // arbitrary unique ID
  "family": "PrinterFamily",               // optional grouping
  "machine_tech": "FFF",
  "default_materials": "Generic PLA @System;Generic PETG @System"
}
```

---

## Machine Variant (Printer) Profile Fields

```json
{
  "type": "machine",
  "name": "VendorName PrinterModel 0.4 nozzle",
  "inherits": "fdm_machine_common",
  "from": "system",
  "instantiation": "true",
  "setting_id": "GM001",                   // unique ID, e.g. "GM" + index
  "nozzle_diameter": ["0.4"],
  "printer_model": "VendorName PrinterModel",
  "printer_variant": "0.4",
  "default_filament_profile": ["Generic PLA @System"],
  "default_print_profile": "0.20mm Standard @VendorName PrinterModel 0.4",

  // Printable area — list of XY corner points (mm)
  "printable_area": ["0x0", "235x0", "235x235", "0x235"],
  "printable_height": 250,

  // Extruder
  "nozzle_type": "brass",                  // brass | stainless_steel | hardened_steel
  "extruder_offset": ["0x0"],              // XY offset per extruder
  "retract_length": ["0.5"],              // retraction distance (mm)
  "retract_speed": ["40"],               // retraction speed (mm/s)
  "deretract_speed": ["40"],             // de-retraction speed (mm/s)
  "z_hop": ["0.2"],                      // z-hop height (mm)
  "z_hop_types": ["Auto Lift"],          // Auto Lift | Normal Lift | Slope Lift | Spiral Lift

  // Motion limits
  "machine_max_speed_x": ["500"],        // mm/s
  "machine_max_speed_y": ["500"],
  "machine_max_speed_z": ["20"],
  "machine_max_speed_e": ["120"],
  "machine_max_acceleration_x": ["10000"],
  "machine_max_acceleration_y": ["10000"],
  "machine_max_acceleration_z": ["1000"],
  "machine_max_acceleration_e": ["10000"],
  "machine_max_jerk_x": ["10"],
  "machine_max_jerk_y": ["10"],
  "machine_max_jerk_z": ["0.4"],
  "machine_max_jerk_e": ["2.5"],

  // Firmware type
  "gcode_flavor": "klipper",             // klipper | marlin | reprap | reprapfirmware | bambu

  // G-code scripts
  "machine_start_gcode": "...",
  "machine_end_gcode": "...",
  "before_layer_change_gcode": "",
  "layer_change_gcode": "",
  "change_filament_gcode": "",
  "machine_pause_gcode": "PAUSE",
  "template_custom_gcode": "",

  // Features
  "use_relative_e_distances": "0",       // 1 = relative E, 0 = absolute E
  "silent_mode": "0",
  "single_extruder_multi_material": "0",
  "host_type": "klipper",               // klipper | octoprint | prusalink | bambu | repetier
  "print_host": "http://192.168.1.100:7125",
  "printhost_apikey": ""
}
```

---

## Process Profile Fields

```json
{
  "type": "process",
  "name": "0.20mm Standard @VendorName PrinterModel 0.4",
  "inherits": "fdm_process_common",
  "from": "system",
  "instantiation": "true",
  "compatible_printers": ["VendorName PrinterModel 0.4 nozzle"],

  // Layer
  "layer_height": 0.2,
  "initial_layer_height": 0.2,

  // Line widths (mm or % of nozzle diameter)
  "line_width": "0.42",                  // default: ~105% of nozzle
  "outer_wall_line_width": "0.42",
  "inner_wall_line_width": "0.45",
  "top_surface_line_width": "0.42",
  "bottom_surface_line_width": "0.42",
  "infill_line_width": "0.45",
  "support_line_width": "0.38",

  // Walls
  "wall_loops": 3,
  "top_shell_layers": 4,
  "bottom_shell_layers": 4,
  "top_shell_thickness": 0,             // 0 = use top_shell_layers
  "bottom_shell_thickness": 0,

  // Wall generator
  "wall_generator": "classic",          // classic | arachne
  "wall_sequence": "inner wall/outer wall", // outer/inner, inner/outer, inner/outer/inner

  // Infill
  "sparse_infill_density": "15%",
  "sparse_infill_pattern": "grid",      // see patterns list below
  "top_surface_pattern": "monotonic",
  "bottom_surface_pattern": "monotonic",
  "infill_direction": 45,

  // Speed (mm/s)
  "outer_wall_speed": 60,
  "inner_wall_speed": 90,
  "top_surface_speed": 60,
  "bottom_surface_speed": 60,
  "sparse_infill_speed": 150,
  "internal_solid_infill_speed": 150,
  "support_speed": 80,
  "travel_speed": 200,
  "initial_layer_speed": 30,
  "initial_layer_infill_speed": 60,

  // Acceleration (mm/s²)
  "outer_wall_acceleration": 500,
  "inner_wall_acceleration": 2000,
  "top_surface_acceleration": 500,
  "travel_acceleration": 5000,
  "initial_layer_acceleration": 300,

  // Seam
  "seam_position": "aligned",           // nearest | aligned | back | random
  "staggered_inner_seam": false,

  // Support
  "enable_support": false,
  "support_type": "tree(auto)",         // normal(auto) | normal(manual) | tree(auto) | tree(manual)
  "support_threshold_angle": 35,
  "support_interface_top_layers": 2,
  "support_interface_bottom_layers": 0,
  "support_top_z_distance": 0.2,
  "support_bottom_z_distance": 0,
  "support_interface_pattern": "auto",

  // Brim
  "brim_type": "no_brim",              // no_brim | outer_only | inner_only | outer_and_inner | mouse_ear
  "brim_width": 5.0,

  // Ironing
  "ironing_type": "no ironing",        // no ironing | top surfaces | topmost surface | all solid surfaces
  "ironing_flow": 0.15,
  "ironing_speed": 15,

  // Fuzzy skin
  "fuzzy_skin": "none",               // none | external | all

  // Pressure advance (can also be per-filament)
  "enable_pressure_advance": false,
  "pressure_advance": 0.04,

  // Special mode
  "print_sequence": "by layer",        // by layer | by object
  "spiral_mode": false
}
```

### Infill Patterns
`grid` | `lines` | `triangles` | `tri-hexagon` | `cubic` | `cubicsubdiv` | `concentric` |
`honeycomb` | `3dhoneycomb` | `gyroid` | `hilbert` | `lightning` | `crosshatch` | `adaptivecubic` |
`supportcubic` | `monotonic` | `monotoniclines` | `alignedrectilinear` | `zigzag`

---

## Filament Profile Fields

```json
{
  "type": "filament",
  "filament_id": "GFL00",              // max 8 chars for AMS compatibility
  "setting_id": "GFSA00",
  "name": "Generic PLA @VendorName PrinterModel@",
  "inherits": "Generic PLA @System",
  "from": "system",
  "instantiation": "true",
  "compatible_printers": ["VendorName PrinterModel 0.4 nozzle"],

  // Temperatures
  "nozzle_temperature": ["215"],       // printing nozzle temp (°C)
  "nozzle_temperature_initial_layer": ["215"],
  "bed_temperature": ["60"],
  "bed_temperature_initial_layer": ["60"],
  "chamber_temperature": ["0"],        // 0 = no chamber heating

  // Flow
  "filament_flow_ratio": ["0.98"],     // extrusion multiplier
  "filament_density": ["1.24"],        // g/cm³ (for weight estimates)
  "filament_diameter": ["1.75"],

  // Pressure advance
  "pressure_advance": ["0.04"],        // per-filament PA (overrides process if set)

  // Cooling
  "fan_always_on": ["0"],
  "fan_cooling_layer_time": ["100"],   // seconds — cool below this time/layer
  "slow_down_layer_time": ["5"],
  "slow_down_min_speed": ["15"],
  "full_fan_speed_layer": ["4"],
  "fan_max_speed": ["100"],
  "fan_min_speed": ["35"],
  "overhang_fan_speed": ["100"],
  "overhang_fan_threshold": ["50%"],

  // Max volumetric speed (mm³/s)
  "filament_max_volumetric_speed": ["15"],

  // Retraction overrides (leave unset to use printer default)
  "retract_length": ["0.5"],
  "retract_speed": ["40"],
  "deretract_speed": ["40"],

  // Shrinkage compensation
  "filament_shrinkage": ["100%"],      // 100% = no compensation

  // Type label shown in UI
  "filament_type": ["PLA"],            // PLA | PETG | ABS | ASA | TPU | PA | PC | etc.
  "filament_vendor": ["Generic"]
}
```

---

## Profile Validation

```bash
# OrcaSlicer built-in validator
OrcaSlicer_profile_validator[.exe] -p <path_to_resources/profiles> -v <VendorName> -l 2

# Python extra checks
python orca_extra_profile_check.py --vendor="VendorName" --check-filaments --check-materials
```

Force cache reload: delete `<config>/system/` then restart OrcaSlicer.
