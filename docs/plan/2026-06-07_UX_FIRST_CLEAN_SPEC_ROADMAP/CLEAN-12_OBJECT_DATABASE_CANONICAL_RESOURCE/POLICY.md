# CLEAN-12 Policy

## Constraints

- Follow the clean-spec roadmap: remove compatibility fields because the addon is unpublished.
- Do not preserve `version`, legacy `objects`, migration helpers, `scene_path`, `preview`, or `preview_path` as normal API.
- Keep object placement payload schema scoped; this task changes object definition resources and runtime resolution, not the whole placement document schema.
- Keep explicit `scene_prototypes` support as a runtime injection hook, not a compatibility fallback.

## Validation

- Object scene validation checks for a `PackedScene` from placement or object definition.
- Object uniqueness still uses `default_properties`.
- Runtime export must duplicate mutable dictionaries while returning resource references directly.
