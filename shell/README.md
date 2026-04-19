# Shell

This directory contains the Quickshell/QML frontend.

Responsibilities:

- create the widget window
- draw the chart
- load widget JSON
- present state such as current price and freshness

Current files:

- `shell.qml`
- `components/CryptoWidget.qml`
- `components/ChartCanvas.qml`
- `components/Header.qml`
- `components/WidgetDataSource.qml`

Runtime behavior:

- creates one widget per detected screen
- watches `data/<symbol>_<timeframe>.json` for changes
- shows loading, stale, and error states without computing indicators in QML
- keeps symbol and timeframe configurable in `shell.qml`
