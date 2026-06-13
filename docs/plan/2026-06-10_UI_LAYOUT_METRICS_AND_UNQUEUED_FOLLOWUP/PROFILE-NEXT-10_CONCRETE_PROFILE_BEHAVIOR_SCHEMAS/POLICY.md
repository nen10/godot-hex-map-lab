# PROFILE-NEXT-10 Policy

## Scope

Add concrete behavior schemas to profile Resources and expose those schemas through the editor screen contexts that consume them. Keep the work focused on Resource/API and screen state, not a full profile editor redesign.

## Adopted Design

- `HexValidationRuleSuiteResource` owns validation behavior schema: enabled/disabled rules, severity overrides, rule parameters, target scopes, and fail-fast behavior.
- `HexGenerationProfileResource` owns generation behavior schema: generator id, shape, connectivity, seed policy, wall density, overlay policy, and parameter bag.
- `HexExportProfileResource` owns export behavior schema: output type, file extension, metadata/debug/validation inclusion, runtime query flag, and option bag.
- Workspace profile contexts include the schema when a profile Resource is selected.

## Rejected Design

| item | decision | why |
|---|---|---|
| Metadata-only profile behavior | reject | Open metadata cannot be used as the canonical behavior schema. |
| Sample preset-only behavior | reject | Project-created Resources must be valid completion proof. |
| Full visual profile editor | reject | Larger UX surface than this queue task. |

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| `parameters` / `options` dictionaries | keep as extension fields | They remain useful for generator/export-specific keyed values. | Remove only when all known dynamic options have typed fields. | Adapter tests assert typed schema includes copied extension dictionary. |
| `metadata` dictionary | keep as descriptive metadata | Preset/source labels still use metadata, but behavior must not depend on it. | None for this task. | Editor tests assert `behavior_schema` exists independently of preset metadata. |
| Missing optional profiles | keep optional missing state | Profiles remain optional dependencies. | Revisit only if roadmap makes a profile required. | Editor tests assert missing optional status remains. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Profile Resource | Schema is available from the concrete Resource without screen-specific code. | UI-only dictionaries diverge from saved Resource behavior. | Adapter save/load tests. |
| Validate screen | Selected Validation Suite context includes validation schema. | Validation UI cannot explain the active rule behavior. | Editor snapshot test. |
| QA screen | Selected Generation Profile and Validation Suite contexts include behavior schemas. | QA score context uses profile class only. | Editor snapshot test. |
| Export screen | Selected Export Profile context includes export schema. | Runtime handoff options remain opaque. | Editor snapshot test. |
| Optional missing profile | Missing remains explicit and does not load a sample default. | Sample-only completion or silent default. | Existing optional missing assertions remain plus new schema absence assertion. |

## Test Policy

- Add focused Resource/API tests for each schema helper and save/load persistence.
- Extend existing profile screen tests rather than creating new analog tests.
- Run `./tools/test.sh`.
