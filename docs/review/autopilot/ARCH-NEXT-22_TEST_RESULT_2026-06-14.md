# ARCH-NEXT-22 Test Result 2026-06-14

Task: `ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION`
Date: `2026-06-14`

## Command

- `./tools/test.sh`

## Result

- **Status:** pass
- **Notes:** `./tools/test.sh` passed all test suites. A pre-existing macOS CA-certificate warning
  (`get_system_ca_certificates`) was repeatedly logged and is non-fatal. One benign `CanvasItem` RID leak
  warning was also observed in this run but did not affect test status.
