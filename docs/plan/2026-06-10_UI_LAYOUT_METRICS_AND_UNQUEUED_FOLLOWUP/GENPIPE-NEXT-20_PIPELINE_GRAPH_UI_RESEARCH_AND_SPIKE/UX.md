# GENPIPE-NEXT-20 UX

## User Job

A developer needs to understand how generated candidate data flows from inputs to result Resource, validation, QA comparison, and Level Document promotion without being forced into an unnecessary graph editor.

## Required Visible State Decision

| option | UX question |
|---|---|
| Resource pass | Can users inspect candidate Resource scope clearly enough? |
| Linear pipeline | Does a step sequence explain Generate/QA without overbuilding? |
| Node graph | Is graph editing justified by current workflows? |

## First Impression Bar

- Any future pipeline UI must clarify candidate/result boundaries.
- A graph must not make a linear workflow look more complex than it is.
- The selected direction must stay compatible with `HexGenerationResultResource`.

## Rejections

| rejected option | reason |
|---|---|
| Immediate node graph UI | No current user workflow needs arbitrary graph editing. |
| Hidden Resource pass | Users need visible result scope if the Resource boundary matters. |
| Graph prototype as completion proof | The task asks for research/spike decision; prototype is optional only if needed. |
