# Cryptopane

Cryptopane is a desktop crypto widget for Arch Linux, Hyprland, and Quickshell.

The project is intentionally split into phases so architecture lands on `main` first and implementation work stays isolated in small feature branches.

## Current Status

This repository is currently at Phase 0 only.

Phase 0 establishes:

- repository structure
- branch naming convention
- frontend/backend boundaries
- widget data contract
- delivery scope for Phases 1 and 2

No widget window, Rust backend, or live market integration is implemented yet.

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
│   └── src/
├── data/
├── docs/
│   ├── contracts/
│   └── phases/
└── shell/
    └── components/
```

See `docs/roadmap.md` for the full project plan.
