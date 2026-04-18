# Phase 0

## Goal

Establish a stable project baseline on `main` without starting widget or backend implementation.

## Branch

- `main`

## Includes

- repository structure
- branch naming convention
- v1 scope lock
- backend/frontend boundary
- widget data contract
- implementation plan for Phases 1 and 2

## Excludes

- Quickshell window implementation
- chart drawing
- Rust crate implementation
- Binance integration
- indicator math

## Deliverables

- `README.md`
- `docs/roadmap.md`
- `docs/contracts/widget-data-schema.md`
- `docs/contracts/widget-data.example.json`
- `docs/phases/phase-1.md`
- `docs/phases/phase-2.md`
- repository skeleton directories for `backend/`, `shell/`, and `data/`

## Acceptance Criteria

- branch naming is fixed as `feat/<phase-number>-<title>`
- v1 scope is documented and explicit
- backend and frontend responsibilities are documented separately
- frontend/backend data shape is documented before implementation starts
- Phase 1 can begin without reopening architecture decisions

## Definition Of Done

Phase 0 is done when the repository contains the agreed baseline documentation and structure, and no implementation work for the widget or backend has started.
