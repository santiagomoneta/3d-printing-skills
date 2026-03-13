# OrcaSlicer Settings Reference

Annotated reference for all major OrcaSlicer settings across the three profile types.
Hover any label in the OrcaSlicer UI to see its config key, which is also its placeholder name.

Wiki: https://www.orcaslicer.com/wiki/

---

## Printer Settings

### Printable Space
| Setting | Key | Notes |
|---------|-----|-------|
| Printable area | `printable_area` | List of XY corner points in mm, e.g. `["0x0","235x0","235x235","0x235"]`. For delta, use a circle. |
| Printable height | `printable_height` | Z max in mm |
| Bed exclude area | `bed_exclude_area` | Regions the toolhead must avoid (e.g. purge bucket, dock) |
| Origin offset | `bed_origin_x`, `bed_origin_y` | Shift the coordinate system origin |

### Advanced Printer Settings
| Setting | Key | Notes |
|---------|-----|-------|
| G-code flavor | `gcode_flavor` | `klipper` \| `marlin` \| `reprap` \| `reprapfirmware` \| `bambu` |
| Use relative E | `use_relative_e_distances` | `0`=absolute, `1`=relative. Klipper: usually `0`. |
| Silent mode | `silent_mode` | Enables silent mode speed caps |
| Single extruder MMU | `single_extruder_multi_material` | SEMM (single-nozzle color switching) |
| Host type | `host_type` | `klipper` \| `octoprint` \| `prusalink` \| `bambu` \| `repetier` |
| Print host | `print_host` | URL or IP of printer host (e.g. `http://192.168.1.100:7125`) |
| API key | `printhost_apikey` | Required for OctoPrint; usually blank for Klipper |

### Motion Limits
| Setting | Key | Typical Values |
|---------|-----|----------------|
| Max X/Y speed | `machine_max_speed_x/y` | 300–500 mm/s (CoreXY), 200–350 (Cartesian) |
| Max Z speed | `machine_max_speed_z` | 15–25 mm/s |
| Max E speed | `machine_max_speed_e` | 80–120 mm/s |
| Max X/Y accel | `machine_max_acceleration_x/y` | 3000–20000 mm/s² |
| Max Z accel | `machine_max_acceleration_z` | 100–500 mm/s² |
| Max E accel | `machine_max_acceleration_e` | 5000–10000 mm/s² |
| Max X/Y jerk | `machine_max_jerk_x/y` | 8–12 mm/s (Marlin only) |

### Extruder Settings
| Setting | Key | Notes |
|---------|-----|-------|
| Nozzle diameter | `nozzle_diameter` | Array per extruder. Common: `["0.4"]` |
| Nozzle type | `nozzle_type` | `brass` \| `stainless_steel` \| `hardened_steel` |
| Extruder offset | `extruder_offset` | XY offset of each nozzle from tool 0. E.g. `["0x0","20x0"]` |
| Retract length | `retract_length` | mm. Direct drive: 0.2–1.0. Bowden: 2–8. |
| Retract speed | `retract_speed` | mm/s. Typical: 30–60 |
| De-retract speed | `deretract_speed` | mm/s. Often same as retract or slightly slower |
| Retract on layer change | `retract_layer_change` | Boolean. Usually enabled. |
| Wipe while retracting | `wipe` | Moves nozzle while retracting to reduce ooze |
| Wipe distance | `wipe_distance` | mm the nozzle travels while wiping |

### Z-Hop
| Setting | Key | Notes |
|---------|-----|-------|
| Z-hop height | `z_hop` | mm. 0 = disabled. Common: 0.1–0.4mm |
| Z-hop type | `z_hop_types` | `Auto Lift` \| `Normal Lift` \| `Slope Lift` \| `Spiral Lift` |
| Z-hop on first layer | `z_hop_for_first_layer` | Avoid z-hop on first layer (recommend disabled) |

### Cooling Fan (Printer-level)
| Setting | Key | Notes |
|---------|-----|-------|
| Part cooling fan | `cooling_fan_speed` | Controlled per-layer by filament profile |
| Auxiliary fan | `auxiliary_fan` | Second cooling fan (some printers) |
| Chamber fan | `chamber_fan` | Chamber circulation fan |

### Machine G-Code Hooks
| Hook | Key | When it runs |
|------|-----|-------------|
| Start G-code | `machine_start_gcode` | Before first layer |
| End G-code | `machine_end_gcode` | After last layer |
| Before layer change | `before_layer_change_gcode` | Before each Z move |
| After layer change | `layer_change_gcode` | After each Z move |
| Change filament | `change_filament_gcode` | On toolchange |
| Machine pause | `machine_pause_gcode` | On M600 or manual pause |
| Timelapse | `timelapse_gcode` | For timelapse capture |
| Wrapping detection | `wrapping_detection_gcode` | First layer wrap detection |
| Change extrusion role | `change_extrusion_role_gcode` | On extrusion role transition |

---

## Process Settings (Print Quality)

### Layer Height
| Setting | Key | Notes |
|---------|-----|-------|
| Layer height | `layer_height` | mm. Rule of thumb: 25–80% of nozzle diameter |
| Initial layer height | `initial_layer_height` | mm. Often 50–100% more than layer height for adhesion |
| Variable layer height | (UI tool) | Per-region height override; edit in Prepare tab |

**Recommended layer heights by nozzle:**
| Nozzle | Min | Standard | Max |
|--------|-----|----------|-----|
| 0.2mm | 0.04 | 0.10 | 0.15 |
| 0.4mm | 0.08 | 0.20 | 0.30 |
| 0.6mm | 0.12 | 0.30 | 0.45 |
| 0.8mm | 0.16 | 0.40 | 0.60 |

### Line Width
| Setting | Key | Notes |
|---------|-----|-------|
| Default line width | `line_width` | mm or % of nozzle. ~100–110% is typical. |
| Outer wall width | `outer_wall_line_width` | Often same as nozzle or slightly smaller for detail |
| Inner wall width | `inner_wall_line_width` | Can be wider (110–120%) for speed |
| Top surface width | `top_surface_line_width` | Match nozzle or slightly smaller |
| Bottom surface width | `bottom_surface_line_width` | Same as top |
| Infill width | `infill_line_width` | Wider = faster. 110–140% of nozzle |
| Support width | `support_line_width` | Narrower = easier removal. 80–100% |
| Initial layer width | `initial_layer_line_width` | Wider for better adhesion. 110–140% |

### Wall Settings
| Setting | Key | Notes |
|---------|-----|-------|
| Wall loops | `wall_loops` | Number of perimeters. 2 = draft, 3–4 = standard, 5+ = structural |
| Top shell layers | `top_shell_layers` | Solid top layers. 4–5 for 0.2mm, 3 for 0.3mm+ |
| Bottom shell layers | `bottom_shell_layers` | Usually same as top |
| Top shell thickness | `top_shell_thickness` | mm alternative to layer count. 0 = use layer count. |
| Bottom shell thickness | `bottom_shell_thickness` | Same as top |
| Wall generator | `wall_generator` | `classic` = traditional, `arachne` = variable width |
| Wall sequence | `wall_sequence` | `inner wall/outer wall` (default), `outer wall/inner wall` (outer first), `inner/outer/inner` (sandwich) |
| Inner wall acceleration | `inner_wall_acceleration` | Higher for speed. Outer should be lower for quality. |

### Infill
| Setting | Key | Notes |
|---------|-----|-------|
| Infill density | `sparse_infill_density` | %. 0% = hollow, 15–20% = standard, 40%+ = structural |
| Infill pattern | `sparse_infill_pattern` | See patterns list below |
| Top surface pattern | `top_surface_pattern` | `monotonic` or `monotoniclines` for smoothest top |
| Bottom surface pattern | `bottom_surface_pattern` | Same as top usually |
| Infill direction | `infill_direction` | Degrees. 45° default |
| Infill/wall overlap | `infill_wall_overlap` | % overlap into walls. 15–25% |
| Infill anchor | `infill_anchor` | Length of infill anchor into walls. Prevents delamination. |
| Sparse infill speed | `sparse_infill_speed` | mm/s. Can be fast (150–300) |

**Infill patterns and use cases:**
| Pattern | Best for |
|---------|----------|
| `grid` | Fast, general use |
| `gyroid` | Strength + flexibility, PETG/TPU |
| `cubic` | Isotropic strength (equal in all directions) |
| `honeycomb` | Visual, moderate strength |
| `lightning` | Ultra-fast, just enough to support top surface |
| `concentric` | Flexible parts, vases |
| `triangles` | Good strength-to-speed ratio |
| `adaptivecubic` | Denser near surfaces, sparse inside |

### Speed Settings
| Setting | Key | Notes |
|---------|-----|-------|
| Outer wall speed | `outer_wall_speed` | mm/s. Slowest for quality. 40–80 typical. |
| Inner wall speed | `inner_wall_speed` | Can be 2–3× outer wall speed |
| Top surface speed | `top_surface_speed` | Slower = smoother. 40–60 mm/s |
| Bottom surface speed | `bottom_surface_speed` | Similar to top surface |
| Sparse infill speed | `sparse_infill_speed` | Fastest. Set to MVS-limited value. |
| Internal solid infill speed | `internal_solid_infill_speed` | Slightly slower than sparse |
| Support speed | `support_speed` | 60–100 mm/s |
| Support interface speed | `support_interface_speed` | Slower for better interface surface |
| Travel speed | `travel_speed` | mm/s. As fast as possible. 200–300+ |
| Travel acceleration | `travel_acceleration` | mm/s². 3000–10000 |
| Initial layer speed | `initial_layer_speed` | mm/s. 20–40 for adhesion |
| Initial layer infill speed | `initial_layer_infill_speed` | Slightly faster than outer first layer |
| First layer travel speed | `initial_layer_travel_speed` | Lower to avoid knocking part off |

### Acceleration
| Setting | Key | Notes |
|---------|-----|-------|
| Outer wall accel | `outer_wall_acceleration` | 500–2000 mm/s². Lower = less ringing. |
| Inner wall accel | `inner_wall_acceleration` | 1000–5000 mm/s² |
| Top surface accel | `top_surface_acceleration` | Same range as outer wall |
| Infill acceleration | `sparse_infill_acceleration` | Can be highest. 3000–10000 |
| Bridge acceleration | `bridge_acceleration` | Lower for bridging accuracy |
| Initial layer accel | `initial_layer_acceleration` | 300–500 mm/s² for adhesion |

### Seam
| Setting | Key | Options / Notes |
|---------|-----|-----------------|
| Seam position | `seam_position` | `nearest` \| `aligned` \| `back` \| `random` |
| Staggered inner seam | `staggered_inner_seam` | Offsets inner wall seams to reduce z-artifacts |
| Scarf seam | `enable_arc_fitting` + scarf settings | Blends seam gradually. Best visual seam quality. |
| Seam gap | `seam_gap` | Small negative = overlap, positive = gap. |

### Support
| Setting | Key | Notes |
|---------|-----|-------|
| Enable support | `enable_support` | Boolean |
| Support type | `support_type` | `normal(auto)` \| `normal(manual)` \| `tree(auto)` \| `tree(manual)` |
| Overhang threshold | `support_threshold_angle` | Degrees. 0° = vertical, 90° = horizontal. Generate supports above this angle. |
| Support top distance | `support_top_z_distance` | mm gap between support top and part. 0.1–0.3 |
| Support bottom distance | `support_bottom_z_distance` | mm gap at base. 0 = fused. |
| Support interface layers (top) | `support_interface_top_layers` | 2–3 for better contact surface |
| Support interface layers (bottom) | `support_interface_bottom_layers` | 0–2 |
| Support interface pattern | `support_interface_pattern` | `auto` \| `concentric` \| `rectilinear` \| `grid` |
| Support interface spacing | `support_interface_spacing` | mm between interface lines. Smaller = better surface. |
| Support filament | `support_filament` | Extruder index for support (multi-material) |
| Tree support angle | `tree_support_angle_slow` | Max angle for main branches |
| Tree support max diameter | `tree_support_max_diameter` | mm. Larger = more robust tree |

### Brim
| Setting | Key | Notes |
|---------|-----|-------|
| Brim type | `brim_type` | `no_brim` \| `outer_only` \| `inner_only` \| `outer_and_inner` \| `mouse_ear` |
| Brim width | `brim_width` | mm. 5–10 for tricky parts |
| Brim separation | `brim_object_gap` | Gap between brim and object. 0.1–0.2 for easy removal. |

### Ironing
| Setting | Key | Notes |
|---------|-----|-------|
| Ironing type | `ironing_type` | `no ironing` \| `top surfaces` \| `topmost surface` \| `all solid surfaces` |
| Ironing flow | `ironing_flow` | % of normal. 10–20% typical. |
| Ironing speed | `ironing_speed` | mm/s. 10–20 |
| Ironing spacing | `ironing_spacing` | mm between ironing lines. 0.1–0.2 |
| Ironing angle | `ironing_direction` | Degrees |

### Bridging
| Setting | Key | Notes |
|---------|-----|-------|
| Bridge flow | `bridge_flow` | % of normal. 80–100%. Lower = less sagging. |
| Bridge speed | `bridge_speed` | mm/s. Slower = better bridges. 20–50 |
| Overhang speed (4 thresholds) | `overhang_1_4_speed`…`overhang_4_4_speed` | Speed at 25%, 50%, 75%, 100% overhang |

### Special Modes
| Setting | Key | Notes |
|---------|-----|-------|
| Print sequence | `print_sequence` | `by layer` (standard) \| `by object` (sequential) |
| Spiral vase | `spiral_mode` | Single-wall, no top/bottom, continuous Z |
| Only one wall on top | `only_one_wall_top` | Single outer wall on top surfaces for quality |
| Precise Z height | `precise_z_height` | Adjusts layer heights to hit exact total height |
| Polyholes | `make_overhang_printable` | Converts round holes to polygon approximations |

### G-Code Output
| Setting | Key | Notes |
|---------|-----|-------|
| Filename format | `filename_format` | Template for output file name. Uses placeholders. |
| Label objects | `label_objects` | Embeds object labels in G-code (for exclude_object) |
| Exclude objects | `exclude_object` | Requires `[exclude_object]` in Klipper config |
| Arc fitting | `enable_arc_fitting` | Converts short line segments to G2/G3 arcs |
| Resolution | `resolution` | mm. Simplify curves below this threshold. 0.01–0.05 |
| G-code comments | `gcode_comments` | Include descriptive comments in output |

---

## Filament / Material Settings

### Temperatures
| Setting | Key | Notes |
|---------|-----|-------|
| Nozzle temp | `nozzle_temperature` | Array per extruder. Main printing temp. |
| Nozzle temp (first layer) | `nozzle_temperature_initial_layer` | Can be 5–10°C higher for adhesion |
| Bed temp | `bed_temperature` | Array per extruder |
| Bed temp (first layer) | `bed_temperature_initial_layer` | Can be 5°C higher |
| Chamber temp | `chamber_temperature` | 0 = no heating |

### Flow
| Setting | Key | Notes |
|---------|-----|-------|
| Flow ratio | `filament_flow_ratio` | Extrusion multiplier. 1.0 = 100%. Tuned via flow calibration. |
| Pressure advance | `pressure_advance` | Per-filament PA. Overrides process profile if set. |
| Max volumetric speed | `filament_max_volumetric_speed` | mm³/s ceiling. Found via MVS calibration. |
| Filament diameter | `filament_diameter` | mm. 1.75 or 2.85 |
| Filament density | `filament_density` | g/cm³. Used for weight estimates. |
| Filament cost | `filament_cost` | Per-kg cost. Used for cost estimates. |

### Cooling
| Setting | Key | Notes |
|---------|-----|-------|
| Fan always on | `fan_always_on` | Keep fan running at min speed between layers |
| Fan min speed | `fan_min_speed` | % minimum fan speed |
| Fan max speed | `fan_max_speed` | % maximum fan speed |
| Bridge fan speed | `bridge_fan_speed` | % fan speed for bridging (often 100%) |
| Overhang fan speed | `overhang_fan_speed` | % fan speed for overhangs |
| Overhang fan threshold | `overhang_fan_threshold` | % overhang angle to trigger overhang fan speed |
| Slow down for cooling | `slow_down_layer_time` | seconds. Slow print if layer finishes faster than this. |
| Min print speed | `slow_down_min_speed` | mm/s. Don't go below this even when cooling. |
| Fan cooling threshold | `fan_cooling_layer_time` | seconds. Turn fan on when layer time below this. |
| Full fan speed at layer | `full_fan_speed_layer` | Layer number when fan reaches max speed |
| Disable fan for first N layers | `disable_fan_first_layers` | Integer. Prevents warping on first layers. |

**Typical fan settings by material:**
| Material | First layers | Normal | Bridge | Overhang |
|----------|-------------|--------|--------|----------|
| PLA | 0% (layers 1–3) | 80–100% | 100% | 100% |
| PETG | 0% (layers 1–4) | 20–50% | 80% | 80% |
| ABS/ASA | 0% | 0–20% | 30% | 30% |
| TPU | 0% | 50–80% | 100% | 100% |
| PA | 0% | 0–30% | 50% | 50% |

### Shrinkage
| Setting | Key | Notes |
|---------|-----|-------|
| Filament shrinkage | `filament_shrinkage` | % compensation. 100% = no compensation. ABS: ~98–99%. |

### Multimaterial
| Setting | Key | Notes |
|---------|-----|-------|
| Load time | `filament_load_time` | seconds for filament to reach nozzle (SEMM/AMS) |
| Unload time | `filament_unload_time` | seconds for filament to retract |
| Loading speed | `filament_loading_speed` | mm/s |
| Unloading speed | `filament_unloading_speed` | mm/s |
| Ramming | `filament_ramming_parameters` | Ramming sequence for tip shaping |
| Filament color | `default_filament_colour` | Hex color shown in UI |
| Soluble support | `filament_soluble` | Mark as soluble (PVA/HIPS) |

---

## Settings Interaction Cheat Sheet

| You want | Primary settings to adjust |
|----------|---------------------------|
| Faster prints | ↑ `sparse_infill_speed`, ↑ `inner_wall_speed`, ↑ `travel_speed`, ↓ `wall_loops`, ↓ `infill_density` |
| Better quality | ↓ `layer_height`, ↓ `outer_wall_speed`, ↑ `top_shell_layers`, `wall_sequence: inner/outer/inner` |
| Less stringing | ↓ `nozzle_temperature`, ↑ `retract_length`, ↑ PA, ↑ `travel_speed` |
| Better overhangs | ↑ `fan_max_speed`, ↓ `overhang_speed`, ↑ `support_threshold_angle` (to generate more support) |
| Stronger parts | ↑ `wall_loops`, ↑ `infill_density`, `infill_pattern: gyroid/cubic`, ↑ `top_shell_layers` |
| Better first layer | ↓ `initial_layer_speed`, ↑ `initial_layer_line_width`, adjust z-offset |
| Reduce warping | ↑ `bed_temperature`, ↑ `brim_width`, ↓ fan on first layers, enclose printer |
| Better bridges | ↓ `bridge_flow`, ↓ `bridge_speed`, ↑ `bridge_fan_speed` |
| No elephant foot | ↑ z-offset slightly, enable "Elephant Foot Compensation" under Precision settings |
