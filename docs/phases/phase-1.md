# Phase 1

## Branch

- `feat/1-shell-window`

## Goal

Create a stable Quickshell widget window on Hyprland.

## Scope

- one transparent layer-shell style window
- fixed size around `320x180`
- top-right placement
- rounded translucent card background
- placeholder text only

## Excludes

- live data loading
- Rust backend integration
- chart rendering
- indicator calculations

## Planned Files

- `shell/shell.qml`
- optionally `shell/components/CryptoWidget.qml`
- optionally `shell/components/Header.qml`

## Acceptance Criteria

- widget launches without Quickshell config errors
- placement is visually stable on Hyprland
- transparent card remains readable on desktop background
- component structure is ready for a chart to be inserted in Phase 2
