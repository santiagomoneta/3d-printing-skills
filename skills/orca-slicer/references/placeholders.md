# OrcaSlicer Built-in Placeholder Variables

Source: https://www.orcaslicer.com/wiki/developer-reference/Built-in-placeholders-variables.html

Used in: Machine start/end G-code, filament start/end G-code, layer change G-code, toolchange G-code.

## Conventions
- Names are case-sensitive, snake_case
- `[]` = vector (per-extruder or per-object), zero-based index. No index = current extruder.
- Distances in mm, temperatures in °C, volumes in mm³, weights in g, feedrates in mm/min
- `layer_num` is 1-based (first layer = 1). All other indices are 0-based.
- Every print/filament/printer setting key is also a valid placeholder (hover label in UI to see key)

---

## Global Slicing State

### Read Only
| Placeholder | Type | Description |
|-------------|------|-------------|
| `zhop` | float mm | Z-hop height present when custom block starts |

### Read/Write
| Placeholder | Type | Description |
|-------------|------|-------------|
| `position[]` | float[3] mm | XYZ toolhead position at block entry — update if you move |
| `e_position[]` | float/extruder mm | Absolute E axis position (absolute E mode only) |
| `e_retracted[]` | float/extruder mm | Retraction state at block entry — update if you manually retract |
| `e_restart_extra[]` | float/extruder mm | Extra priming planned after next de-retraction |

---

## Slicing State

| Placeholder | Type | Description |
|-------------|------|-------------|
| `current_extruder` | int | Zero-based index of active extruder |
| `current_object_idx` | int | Zero-based index of object being printed (sequential mode) |
| `has_wipe_tower` | bool | True when wipe tower is present |
| `has_single_extruder_multi_material_priming` | bool | SEMM priming area in use |
| `initial_extruder` / `initial_tool` | int | First extruder used in the print |
| `initial_no_support_extruder` | int | First extruder printing without supports |
| `is_extruder_used[]` | bool/extruder | Whether each extruder participates |
| `num_extruders` | int | Total configured extruders |
| `retraction_distance_when_cut` | float mm | Cut retraction for current extruder |
| `long_retraction_when_cut` | bool | "Long retraction when cut" enabled |
| `in_head_wrap_detect_zone` | bool | First layer intersects wrap detection area |

---

## Print Statistics

| Placeholder | Type | Description |
|-------------|------|-------------|
| `normal_print_time` / `print_time` | string hh:mm:ss | Estimated duration |
| `silent_print_time` | string hh:mm:ss | Silent mode estimated duration |
| `total_layer_count` | int | Number of sliced layers |
| `total_toolchanges` | int | Planned tool changes |
| `used_filament` | float mm | Total filament length |
| `extruded_volume[]` | float/extruder mm³ | Volume per extruder |
| `extruded_volume_total` | float mm³ | Sum of all extruder volumes |
| `extruded_weight[]` | float/extruder g | Weight per extruder |
| `extruded_weight_total` / `total_weight` | float g | Total material weight |
| `total_cost` | float | Combined material cost |
| `total_wipe_tower_cost` | float | Cost spent on wipe tower |
| `total_wipe_tower_filament` | float mm³ | Volume used on wipe tower |

---

## Objects

| Placeholder | Type | Description |
|-------------|------|-------------|
| `num_objects` | int | Number of distinct objects on plate |
| `num_instances` | int | Total printed instances across all objects |
| `scale[]` | string/object | Human-readable scale per object |
| `input_filename_base` | string | First imported filename without extension |
| `input_filename` | string | First imported full filename with extension |

---

## Plates

| Placeholder | Type | Description |
|-------------|------|-------------|
| `plate_name` | string | Name of the active plate |

---

## Dimensions

| Placeholder | Type | Description |
|-------------|------|-------------|
| `first_layer_print_convex_hull` | [x,y] pairs mm | Convex hull polygon of first layer |
| `first_layer_print_min` | float[2] mm | Bottom-left corner of first layer bbox |
| `first_layer_print_max` | float[2] mm | Top-right corner of first layer bbox |
| `first_layer_print_size` | float[2] mm | Width and depth of first layer bbox |
| `first_layer_center_no_wipe_tower` | float[2] mm | Center of first layer excluding wipe tower |
| `first_layer_height` | float mm | First layer height |
| `print_bed_min` | float[2] mm | Bed minimum (bottom-left) |
| `print_bed_max` | float[2] mm | Bed maximum (top-right) |
| `print_bed_size` | float[2] mm | Printable bed width and depth |

---

## Temperatures

| Placeholder | Type | Description |
|-------------|------|-------------|
| `bed_temperature[]` | int/extruder °C | Bed temp per filament |
| `bed_temperature_initial_layer[]` / `first_layer_bed_temperature[]` | int/extruder °C | Initial layer bed temps |
| `bed_temperature_initial_layer_single` | int °C | Initial layer bed temp for initial_extruder |
| `first_layer_temperature[]` | int/extruder °C | Initial layer nozzle temps |
| `nozzle_temperature[]` | int/extruder °C | Normal printing nozzle temps |
| `chamber_temperature[]` | int/extruder °C | Chamber set-point per filament |
| `overall_chamber_temperature` | int °C | Max of chamber_temperature[] across used extruders |

---

## Timestamps

| Placeholder | Type | Description |
|-------------|------|-------------|
| `timestamp` | string yyyyMMdd-hhmmss | Local timestamp when slicing ran |
| `year` / `month` / `day` | int | Date components |
| `hour` / `minute` / `second` | int | Time-of-day components |

---

## Environment

| Placeholder | Type | Description |
|-------------|------|-------------|
| `user` | string | Username (from USER/USERNAME env var) |
| `version` | string | OrcaSlicer version string |

Environment variables prefixed with `SLIC3R_` are also available as placeholders.

---

## Preset Metadata

| Placeholder | Type | Description |
|-------------|------|-------------|
| `print_preset` | string | Active print preset name |
| `filament_preset[]` | string/extruder | Filament preset name per slot |
| `filament_type[]` | string/extruder | Material type label (PLA, PETG, ABS…) |
| `printer_preset` | string | Active printer preset name |

---

## Layer-Aware Placeholders
*(available in layer change, before layer change, timelapse, change filament, filament start/end, machine end G-code)*

| Placeholder | Type | Description |
|-------------|------|-------------|
| `layer_num` | int (1-based) | Current layer index |
| `layer_z` | float mm | Top of current layer Z height |
| `max_layer_z` | float mm | Z height of the final layer |
| `filament_extruder_id` | int | Zero-based extruder whose macro is executing |

---

## Toolchange Placeholders
*(available in `change_filament_gcode` only)*

| Placeholder | Type | Description |
|-------------|------|-------------|
| `previous_extruder` / `next_extruder` | int | Outgoing / incoming extruder IDs |
| `toolchange_z` | float mm | Z height at moment of toolchange |
| `outer_wall_volumetric_speed` | float mm³/s | Volumetric speed of new extruder outer walls |
| `relative_e_axis` | bool | True if relative E mode |
| `toolchange_count` | int | Number of toolchanges so far |
| `old_retract_length` / `new_retract_length` | float mm | Retraction distances |
| `old_retract_length_toolchange` / `new_retract_length_toolchange` | float mm | Toolchange-specific retraction |
| `old_filament_temp` / `new_filament_temp` | int °C | Nozzle temps before/after |
| `old_filament_e_feedrate` / `new_filament_e_feedrate` | int mm/min | Extrusion feedrates |
| `x_after_toolchange` / `y_after_toolchange` / `z_after_toolchange` | float mm | Expected position after toolchange |
| `first_flush_volume` / `second_flush_volume` | float mm | Purge half-lengths |
| `flush_length` | float mm | Total purge length |
| `flush_length_1`…`flush_length_4` | float mm | Individual purge segments |
| `flush_volumetric_speeds[]` | float/extruder mm³/s | Calibration purge speeds |
| `flush_temperatures[]` | int/extruder °C | Temperatures per flush stage |
| `wipe_avoid_perimeter` | bool | Wipe tower avoidance active |
| `wipe_avoid_pos_x` | float mm | X coordinate of avoidance barrier |
| `travel_point_1_x` / `travel_point_1_y` | float mm | Intermediate travel waypoint 1 |
| `travel_point_2_x` / `travel_point_2_y` | float mm | Intermediate travel waypoint 2 |
| `travel_point_3_x` / `travel_point_3_y` | float mm | Intermediate travel waypoint 3 |

---

## Timelapse / Wrapping Detection

| Placeholder | Type | Description |
|-------------|------|-------------|
| `most_used_physical_extruder_id` | int | Extruder printing most of the layer |
| `curr_physical_extruder_id` | int | Currently active physical extruder |
| `timelapse_pos_x` / `timelapse_pos_y` | int mm | Snapshot XY coordinates |
| `has_timelapse_safe_pos` | bool | Safe snapshot position found |

---

## Extrusion Role Changes
*(available in `change_extrusion_role_gcode`)*

| Placeholder | Type | Description |
|-------------|------|-------------|
| `extrusion_role` | string | Upcoming extrusion role (Perimeter, ExternalPerimeter, Support, …) |
| `last_extrusion_role` | string | Previous extrusion role |

---

## Pause / Color Change

| Placeholder | Type | Description |
|-------------|------|-------------|
| `color_change_extruder` | int | Extruder associated with M600 color change |

---

## Filename Template Limitations

When building the export filename (`filename_format`), only placeholders known **before** G-code
generation are available:
- Config keys from all presets
- `print_preset`, `filament_preset[]`, `printer_preset`
- Object metadata: `input_filename`, `num_objects`, `scale[]`, `plate_name`, timestamps, `user`
- Print statistics: `print_time`, `used_filament`, `total_cost`, etc.

**NOT available in filename templates:**
- `layer_num`, `layer_z`, toolchange vars, timelapse vars, extrusion role vars, pause/color vars

---

## Common G-Code Examples

### Conditional by layer
```gcode
{if layer_num == 1}
M117 Printing first layer
{endif}
```

### Conditional by filament type
```gcode
{if filament_type[0] == "ABS"}
M106 S0   ; no fan for ABS on first layers
{else}
M106 S255 ; full fan for PLA
{endif}
```

### Purge position using bed geometry
```gcode
G1 X{print_bed_min[0]} Y{print_bed_min[1]} F9000
```

### First layer temp + normal temp
```gcode
M109 S{first_layer_temperature[0]}   ; heat to first layer temp
; ... print first layer ...
M104 S{nozzle_temperature[0]}        ; switch to normal temp
```

### Layer pause
```gcode
{if layer_z >= 5.0}
PAUSE   ; pause at 5mm height
{endif}
```
