# CLEAN-14 UX Notes

## Goal

Labels and document dependencies should use typed resources as their authoring surface. Users should pick or assign resources, not maintain arrays of loose dictionaries or editable dependency path strings.

## User-Facing Contract

- Label databases own `HexLabelDefinitionResource` entries through `definitions`.
- Label definitions expose `label_id`, display text defaults, style keys, tags, and metadata.
- Dependencies own a `resource: Resource` reference, plus `kind`, `role`, `required`, and metadata.
- Validation reports missing required dependency resources and resource-kind mismatches.
- Debug/reporting code may read `resource.resource_path`; the saved dependency field is not an editable path string.

## Acceptance

- Label database save/load works with typed definitions only.
- Required dependency with null resource reports missing dependency.
- Dependency kind mismatch reports a type mismatch.
- Manual/API/test docs no longer present path strings as standard dependency input.
