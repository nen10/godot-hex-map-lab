# PROFILE-30 UX

## User Goal

Users selecting Validation Rule Suite, Generation Profile, or Export Profile resources should see clear resource types instead of a generic `Resource` picker.

## Operation Steps

1. Open Validate, QA, or Export.
2. Create or select the relevant profile asset.
3. The ResourcePicker accepts the concrete profile class for that slot.
4. Created resources have names and fields that explain their purpose without relying on bundled samples.

## Adopted UX

- Validation Rule Suite uses `HexValidationRuleSuiteResource`.
- Generation Profile uses `HexGenerationProfileResource`.
- Export Profile uses `HexExportProfileResource`.
- Profile resources remain lightweight data resources in this task.

## Rejected UX

- No generic `Resource` picker for profile slots.
- No sample placeholder resource as proof of completion.
