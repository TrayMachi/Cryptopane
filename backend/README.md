# Backend

This directory will contain the Rust backend starting in Phase 3.

Planned responsibilities:

- fetch Binance klines
- compute EMA20 and Bollinger Bands
- write widget JSON atomically to `data/`

Planned module layout:

- `main.rs`
- `binance.rs`
- `indicators.rs`
- `model.rs`
- `output.rs`
