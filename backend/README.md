# Backend

This directory contains the Rust backend used by the widget.

Responsibilities:

- fetch Binance klines
- compute EMA20 and Bollinger Bands
- write widget JSON atomically to `data/`
- preserve the last successful snapshot when refreshes fail

Current module layout:

- `main.rs`
- `binance.rs`
- `indicators.rs`
- `model.rs`
- `output.rs`

Defaults:

- symbol: `BTCUSDT`
- interval: `5m`
- limit: `120`
- refresh: `10s`
- default REST host: `https://data-api.binance.vision`

Useful flags:

- `--once`
- `--symbol`
- `--interval`
- `--limit`
- `--refresh-secs`
- `--output-path`
- `--binance-base-url`
