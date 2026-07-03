# GQM-14 Result Resource Save/Switch — UX

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| Save result near Generate/Apply/Revert | Users keep a named generated output at the moment it is visible | low | medium | adopt | The user is already in the confirmation zone for generated data. |
| Results dropdown near Apply/Revert | Users switch saved outputs without leaving Build | low | medium | adopt | It is the resource equivalent of choosing the currently previewed generated output. |
| Dialog-only result management | Avoids header growth | medium | medium | reject | Hides the switch path and weakens immediate list selection. |
| Thumbnail grid | More visual browsing | high | high | reject | Roadmap rejects thumbnails and large generated output previews as misleading/costly. |

## Experience Steps

1. User generates a graph result and sees a pending viewport preview.
2. User chooses `Save result...`, enters a name, and the generated output is saved under the project `results/` asset layer.
3. The `Results` dropdown lists project result names only; no thumbnails or score labels are shown.
4. User selects a saved result and presses `Load result` or selects through the control path; the saved data is projected to the viewport immediately without graph regeneration.
5. Apply commits the switched preview, Revert restores the pre-switch document state.
6. Existing Result row / generated layer promote behavior works from the switched data because the switched resource is promoted into the preview document.

## Rejected UX

- No thumbnail strip, score tree, validation dashboard, batch comparison, or raw file-path field.
- No save format that requires regeneration to inspect a saved result.
