# ARCH-02 Generate Dock State Evaluation Split UX

Task: `ARCH-02`  
Created: 2026-06-07  
Status: COMPLETE

## Goal

Keep Generate Dock behavior unchanged while moving state decisions out of direct UI mutation code.

## Operation Steps

1. Generate Dock still exposes the same controls, labels, and generation blocking behavior.
2. The dock gathers current UI inputs into a compact state dictionary.
3. A pure evaluator returns visibility, disabled, label text, and block-reason decisions.
4. The dock applies the returned state to controls.
5. Headless tests cover the evaluator and existing Generate Dock behavior.

## Non-goals

- No UI redesign.
- No generator behavior change.
- No broad rewrite of `hex_map_gen_dock.gd`.
