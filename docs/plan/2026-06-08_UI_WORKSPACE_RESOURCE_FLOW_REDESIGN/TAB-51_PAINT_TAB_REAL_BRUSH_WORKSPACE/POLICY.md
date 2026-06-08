# TAB-51 Policy

Task: `TAB-51_PAINT_TAB_REAL_BRUSH_WORKSPACE`

## Decisions

- Paint is an editing tab. It must surface edit context and brush state before resource management controls.
- Resources is the owner of Object Database and Label Database asset slots. Paint may link to the needed slot through a CTA, but must not duplicate the ResourcePicker rows.
- Viewport editing is part of the Paint workflow. When the edit tool consumes a viewport input, the workspace selects the Paint tab.
- Missing brush prerequisites must be expressed as one concise next action, not raw path text or sample fallback.
- Existing sample assets remain learning/duplicate sources only.

## Completion Bar

- The Paint tab has a stable functional snapshot for document/layer/brush/cell/last-edit state.
- Tests prove Paint no longer owns object/label asset slots.
- Tests prove viewport editing routes the workspace to Paint.
- Tests prove Object/Label missing-resource CTAs point to Resources.
