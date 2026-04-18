# Roadmap

## Objective

Build a desktop crypto widget for Hyprland using Quickshell for rendering and Rust for data collection and indicator calculation.

## Architecture

- `shell/`: Quickshell/QML widget window, layout, and chart drawing
- `backend/`: Rust service for fetching klines, computing indicators, and writing widget data
- `data/`: local generated JSON output consumed by the widget
- `docs/`: phase plans, contracts, and project decisions

## V1 Product Target

A `320x180` top-right widget showing `BTCUSDT` on a `5m` timeframe as a line chart with `EMA20` and `Bollinger Bands (20, 2 sigma)`, refreshed every `10s`.

## Phase Plan

### Phase 0

Goal:
- lock architecture, repo structure, branch naming, and widget data contract

Deliverables:
- baseline docs
- project skeleton
- Phase 1 and Phase 2 definitions of done

### Phase 1

Branch:
- `feat/1-shell-window`

Goal:
- create a stable Quickshell widget window on Hyprland

Deliverables:
- transparent rounded card
- fixed widget size
- top-right placement
- placeholder text only

### Phase 2

Branch:
- `feat/2-static-chart`

Goal:
- render a chart with fake data before integrating networking or indicator calculations

Deliverables:
- Canvas-based chart component
- static close line
- static EMA line
- static Bollinger upper/mid/lower bands

### Phase 3

Branch:
- `feat/3-binance-fetch`

Goal:
- fetch live Binance klines in Rust and emit structured local output

### Phase 4

Branch:
- `feat/4-indicators`

Goal:
- compute EMA20 and Bollinger Bands in Rust and keep output arrays aligned

### Phase 5

Branch:
- `feat/5-ui-bridge`

Goal:
- connect widget rendering to the JSON data produced by the backend

### Phase 6

Branch:
- `feat/6-polish`

Goal:
- refine layout, typography, state display, and desktop feel

### Phase 7

Branch:
- `feat/7-performance`

Goal:
- measure and improve runtime behavior only after the basic product works

### Phase 8

Branch:
- `feat/8-post-v1-upgrades`

Goal:
- add optional future features such as websockets, multiple symbols, or richer IPC

## Merge Order

1. land Phase 0 on `main`
2. build `feat/1-shell-window`
3. merge to `main`
4. build `feat/2-static-chart`
5. merge to `main`
6. continue sequentially for later phases

Sequential merges keep the base stable and prevent later branches from re-deciding contracts.
