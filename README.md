# Cryptopane

Cryptopane is a desktop crypto widget for Arch Linux, Hyprland, and Quickshell.

The project is intentionally split into phases so architecture lands on `main` first and implementation work stays isolated in small feature branches.

## Current Status

The repository now includes the Phase 1-8 implementation on `main`.

Implemented today:

- Quickshell widget shell with one window per screen
- Canvas chart for closes, EMA20, and Bollinger Bands
- Rust backend that fetches Binance klines and writes widget JSON atomically
- indicator calculations with Rust tests
- live QML file bridge with loading, stale, and error states
- lightweight performance guards to avoid unnecessary JSON writes and chart array churn
- a small configuration upgrade via QML-level symbol and timeframe properties

Known environment caveat:

- this environment rejects `api.binance.com` TLS, so the backend defaults to `https://data-api.binance.vision`
- the REST host remains overrideable via `CRYPTOPANE_BINANCE_BASE_URL` or `--binance-base-url`

## Branch Strategy

- `main`: baseline architecture and accepted phase docs
- feature work: `feat/<phase-number>-<title>`

Initial branch plan:

- `feat/1-shell-window`
- `feat/2-static-chart`
- `feat/3-binance-fetch`
- `feat/4-indicators`
- `feat/5-ui-bridge`
- `feat/6-polish`
- `feat/7-performance`
- `feat/8-post-v1-upgrades`

## V1 Scope

- symbol: `BTCUSDT`
- interval: `5m`
- refresh cadence: `10s`
- chart type: line chart
- indicators:
  - `EMA20`
  - `Bollinger Bands (20, 2 sigma)`
- frontend: Quickshell/QML
- backend: Rust
- IPC: local JSON file

Explicitly out of scope for v1:

- candlesticks
- websocket streaming
- multiple symbols
- multiple timeframes
- volume bars
- config UI

## Repo Layout

```text
.
├── backend/
│   ├── Cargo.toml
│   └── src/
├── data/
├── docs/
│   ├── contracts/
│   └── phases/
└── shell/
    └── components/
```

See `docs/roadmap.md` for the full project plan.

## Running

Backend once:

```bash
cargo run --manifest-path backend/Cargo.toml -- --once
```

Backend loop:

```bash
cargo run --manifest-path backend/Cargo.toml
```

Shell:

```bash
quickshell -p shell --no-duplicate
```
