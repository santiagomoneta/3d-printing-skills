# 3D Printing Skills

AI agent skills for 3D printing workflows — manage your Klipper printer and OrcaSlicer profiles through natural language.

## Skills

### klipper-manager

Full AI-driven Klipper printer configuration, diagnostics, and calibration via the Moonraker API. Reads and edits `printer.cfg`, runs calibration sequences (PID, bed mesh, input shaper, pressure advance), monitors live status, and fixes config issues.

**Includes:** 4 reference docs (config sections, G-codes, Moonraker API, troubleshooting) + 5 helper scripts.

### orca-slicer

OrcaSlicer profile creation, calibration workflows, settings expert, and custom G-code helper. Creates and edits printer/filament/process profiles, guides all 9 calibration tests, explains every setting, and generates custom G-code with placeholders.

**Includes:** 4 reference docs (profiles schema, calibration guide, placeholders, settings).

## Installation

```bash
npx skills add santiagxf/3d-printing-skills
```

Or install a single skill:

```bash
npx skills add santiagxf/3d-printing-skills@klipper-manager
npx skills add santiagxf/3d-printing-skills@orca-slicer
```

## License

MIT
