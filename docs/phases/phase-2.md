# Phase 2

## Branch

- `feat/2-static-chart`

## Goal

Render a static chart with fake data before any networking or backend integration.

## Scope

- QML `Canvas` chart component
- fake aligned arrays for close, EMA, and Bollinger series
- line scaling and padding
- band fill between upper and lower Bollinger lines
- header placeholder values that match the fake chart

## Excludes

- JSON file loading
- Rust backend integration
- Binance requests
- indicator calculations in Rust

## Planned Files

- `shell/components/ChartCanvas.qml`
- `shell/components/CryptoWidget.qml`
- possible updates to `shell/shell.qml`

## Acceptance Criteria

- chart renders consistently from static data
- close, EMA, and Bollinger series are visually distinct
- scaling uses the full visible range without clipping
- UI structure remains compatible with the Phase 0 data contract
