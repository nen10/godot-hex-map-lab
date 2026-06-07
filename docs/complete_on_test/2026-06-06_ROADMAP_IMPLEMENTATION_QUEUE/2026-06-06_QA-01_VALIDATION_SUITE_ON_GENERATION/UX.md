# QA-01 Validation Suite On Generation UX

## Goal

Generated maps should enter the editor workflow with validation already attached to the generated result. A user can generate, inspect the validation outcome through debug/report state, and then rely on target apply or later seed promotion using the captured pass/fail result.

## Operation Steps

1. User runs primary generation or overlay generation from Hex Map Generate.
2. The dock builds a document snapshot from the latest generated result.
3. The dock runs the document validation suite before automatic target apply.
4. The dock stores a compact pass/fail summary and the raw validation result for debug/report and tests.
5. The normal status label remains short; detailed validation data stays in debug/report state.

## Scope

- Maintain the existing Generate button and automatic apply flow.
- Support valid generated map results and invalid generated document fixtures in tests.
- Keep validation routed through `HexMapDocumentValidator` and document adapter resources.

## Nonblocking Manual Check Candidate

- Generate a map in the editor and copy the Generate debug report; confirm the validation summary is present while the main status remains concise.
