# SCREEN-20 UX

## User Goal

A project author can manage the Level Document from the Document tab without relying on bundled samples.

## Operation Steps

1. Open the Document tab.
2. Create or select a Level Document project Resource.
3. See related dependency asset slots for catalog, object database, label database, and layer stack.
4. Open, save as, clear, and validate the Level Document from the Document screen.

## Adopted UX

- Level Document is the primary Document tab asset.
- Dependencies are visible as asset slots, not hidden sample defaults.
- Create and Save As write project `.tres` Resources through the shared asset context.

## Deferred UX

- Rich metadata editing and dirty-state tracking remain deferred.
- Full dependency issue navigation remains in Validate and later screen tasks.
