# EXPORT-NEXT-10 Policy

## Decision

Package build remains **process-only** (`tools/package_addon.sh`). The editor
Export tab does NOT gain a package-build / zip / upload affordance.

## Adopted invariants

- The Export screen is a **Runtime Handoff** surface: select level document,
  optional Export Profile, destination, run handoff. It does not build, zip, or
  upload addon packages.
- Addon packaging stays a CLI/process step (`tools/package_addon.sh`,
  `--check` in `tools/test.sh`), owned by the roadmap final process tasks
  (`PROC-NEXT-90`) and documented in `docs/manual/MANUAL_PACKAGE.md`.
- `dist` freshness stays outside the normal test gate.

## Rejected

- A package-build button/control inside the Export tab.
- Any public-upload / release action in the editor.
- A package-artifact status row in normal Export workflow result UI.

## Why

- `AGENTS.md`: "public package upload is not auto queued"; `dist` freshness is a
  final-process step, not normal testing.
- `ROADMAP.md` §2: public package upload is not auto-queued.
- Mixing distribution into the authoring Export tab confuses the runtime-handoff
  task taxonomy and the editor first impression.
