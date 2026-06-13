# PROFILE-NEXT-10 UX

## User Goal

A level designer can select or create project profile Resources and see that Validate, QA, and Export are using concrete behavior settings rather than anonymous metadata bags or bundled samples.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Profile schema appears in each relevant screen context | high | low | medium | adopt | It confirms which behavior settings the screen will use. |
| B. Store schema only in Resource inspector fields | medium | medium | low | reject | Screen acceptance requires editor/screen connections, not hidden Resource data only. |
| C. Full form editor for every profile setting | high | high | high | reject | Useful later, but it is larger than this queue item. |
| D. Preset sample proof only | low | high | low | reject | It would be sample-only completion. |

## Required Experience Steps

1. Create or select a project Validation Rule Suite, Generation Profile, or Export Profile.
2. Open Validate / QA / Export and inspect the screen context snapshot.
3. Confirm the selected profile exposes a concrete schema kind, status, and behavior summary.
4. Missing optional profiles remain explicit optional-missing states instead of silently loading samples.

## First Impression Bar

- Profile contexts should read as real behavior configuration, not placeholder class labels.
- Optional missing state remains understandable and nonblocking.
- Raw JSON, path text, and sample defaults must not become the normal proof path.
