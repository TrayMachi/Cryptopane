# Widget Data Schema

This contract defines the data written by the Rust backend and consumed by the Quickshell widget.

## Transport

- medium: local JSON file
- writer: Rust backend
- reader: Quickshell/QML frontend
- first target path: `data/btcusdt_5m.json`

## Design Rules

- all plotted arrays must have the same length
- indicator warm-up positions should be `null` rather than omitted
- the frontend should not compute EMA or Bollinger values
- the frontend should tolerate stale, missing, or invalid files gracefully

## Schema

```json
{
  "symbol": "BTCUSDT",
  "interval": "5m",
  "updated_at": 0,
  "status": "ok",
  "price": 0.0,
  "change_points": 0.0,
  "closes": [0.0],
  "ema20": [0.0],
  "bb_mid": [0.0],
  "bb_upper": [0.0],
  "bb_lower": [0.0]
}
```

## Field Notes

- `symbol`: exchange symbol, fixed to `BTCUSDT` in v1
- `interval`: candle interval, fixed to `5m` in v1
- `updated_at`: Unix timestamp in seconds or milliseconds; final unit must be documented when implemented in Phase 3
- `status`: expected values include `ok`, `stale`, or `error`
- `price`: latest close price
- `change_points`: visible-range change in absolute points; percentage can be derived later if needed
- `closes`: visible close series
- `ema20`: EMA20 aligned to `closes`
- `bb_mid`: middle Bollinger line aligned to `closes`
- `bb_upper`: upper Bollinger line aligned to `closes`
- `bb_lower`: lower Bollinger line aligned to `closes`

## Open Implementation Detail

Phase 3 should decide whether `updated_at` is stored as Unix seconds or Unix milliseconds. The unit must remain consistent after that choice is made.
