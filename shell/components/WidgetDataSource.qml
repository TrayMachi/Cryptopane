import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false

    required property string symbol
    required property string timeframe

    property int staleAfterMs: 30000
    property int nowMs: Date.now()
    property string dataPath: Qt.resolvedUrl("../../data/" + normalizedName(symbol) + "_" + normalizedName(timeframe) + ".json")
    property string symbolValue: symbol
    property string timeframeValue: timeframe
    property string rawStatus: "loading"
    property string detailText: "Waiting for backend JSON"
    property real price: 0
    property real changePoints: 0
    property real updatedAt: 0
    property var closes: []
    property var ema20: []
    property var bbMid: []
    property var bbUpper: []
    property var bbLower: []

    readonly property int candleCount: closes.length
    readonly property bool hasData: closes.length > 1
    readonly property bool stale: updatedAt > 0 && nowMs - updatedAt > staleAfterMs
    readonly property string displayStatus: {
        if (rawStatus === "error") {
            return "error"
        }

        if (!hasData) {
            return "loading"
        }

        if (rawStatus === "stale" || stale) {
            return "stale"
        }

        return "ok"
    }
    readonly property string badgeText: {
        switch (displayStatus) {
        case "ok":
            return "LIVE"
        case "stale":
            return "STALE"
        case "error":
            return "ERROR"
        default:
            return "WAITING"
        }
    }
    readonly property string freshnessText: {
        if (updatedAt <= 0) {
            return "No sync"
        }

        return formatAge(nowMs - updatedAt)
    }
    readonly property string placeholderTitle: {
        if (displayStatus === "error") {
            return "Backend Error"
        }

        return "Waiting For Data"
    }
    readonly property string placeholderDetail: {
        if (displayStatus === "error") {
            return detailText
        }

        return "Run the Rust backend to generate " + fileNameFromPath(dataPath)
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.nowMs = Date.now()
    }

    FileView {
        id: dataFile

        path: root.dataPath
        watchChanges: true
        preload: true
        printErrors: false

        onLoaded: root.parseLoadedFile()
        onFileChanged: reload()
        onLoadFailed: function(error) {
            root.handleLoadFailure(error)
        }
    }

    function normalizedName(value) {
        return value.toLowerCase().replace(/[^a-z0-9]+/g, "_")
    }

    function fileNameFromPath(pathValue) {
        var segments = String(pathValue).split("/")
        return segments[segments.length - 1]
    }

    function formatAge(ageMs) {
        var positiveAge = Math.max(0, ageMs)

        if (positiveAge < 2000) {
            return "Just now"
        }

        var seconds = Math.floor(positiveAge / 1000)

        if (seconds < 60) {
            return seconds + "s ago"
        }

        var minutes = Math.floor(seconds / 60)

        if (minutes < 60) {
            return minutes + "m ago"
        }

        var hours = Math.floor(minutes / 60)
        return hours + "h ago"
    }

    function parseNumericArray(value, allowNull) {
        if (!Array.isArray(value)) {
            throw new Error("expected an array")
        }

        var output = []

        for (var index = 0; index < value.length; index++) {
            var entry = value[index]

            if (allowNull && entry === null) {
                output.push(null)
                continue
            }

            if (typeof entry !== "number" || !isFinite(entry)) {
                throw new Error("expected numeric value at index " + index)
            }

            output.push(entry)
        }

        return output
    }

    function parseLoadedFile() {
        try {
            var text = dataFile.text()

            if (!text || !text.trim().length) {
                clearData("loading", "Widget data file is empty")
                return
            }

            applyPayload(JSON.parse(text))
        } catch (error) {
            clearData("error", String(error))
        }
    }

    function handleLoadFailure(error) {
        clearData("loading", error ? String(error) : "Widget data file not found")
    }

    function clearData(status, detail) {
        symbolValue = symbol
        timeframeValue = timeframe
        rawStatus = status
        detailText = detail
        price = 0
        changePoints = 0
        updatedAt = 0
        closes = []
        ema20 = []
        bbMid = []
        bbUpper = []
        bbLower = []
    }

    function applyPayload(payload) {
        if (!payload || typeof payload !== "object") {
            throw new Error("widget data must be a JSON object")
        }

        var nextCloses = parseNumericArray(payload.closes || [], false)
        var nextEma20 = parseNumericArray(payload.ema20 || [], true)
        var nextBbMid = parseNumericArray(payload.bb_mid || [], true)
        var nextBbUpper = parseNumericArray(payload.bb_upper || [], true)
        var nextBbLower = parseNumericArray(payload.bb_lower || [], true)

        var seriesLength = nextCloses.length
        var lengths = [nextEma20.length, nextBbMid.length, nextBbUpper.length, nextBbLower.length]

        for (var index = 0; index < lengths.length; index++) {
            if (lengths[index] !== seriesLength) {
                throw new Error("indicator arrays must stay aligned with closes")
            }
        }

        var nextPrice = typeof payload.price === "number" && isFinite(payload.price)
            ? payload.price
            : (seriesLength > 0 ? nextCloses[seriesLength - 1] : 0)
        var nextChangePoints = typeof payload.change_points === "number" && isFinite(payload.change_points)
            ? payload.change_points
            : (seriesLength > 1 ? nextCloses[seriesLength - 1] - nextCloses[0] : 0)
        var nextUpdatedAt = typeof payload.updated_at === "number" && isFinite(payload.updated_at)
            ? payload.updated_at
            : 0
        var nextStatus = typeof payload.status === "string" && payload.status.length
            ? payload.status
            : "ok"
        var nextSymbol = typeof payload.symbol === "string" && payload.symbol.length
            ? payload.symbol
            : symbol
        var nextTimeframe = typeof payload.interval === "string" && payload.interval.length
            ? payload.interval
            : timeframe
        var nextDetail = nextStatus === "error"
            ? "Backend reported an error"
            : (nextUpdatedAt > 0 ? "Synced " + formatAge(nowMs - nextUpdatedAt) : "Waiting for backend JSON")

        symbolValue = nextSymbol
        timeframeValue = nextTimeframe
        rawStatus = nextStatus
        detailText = nextDetail
        price = nextPrice
        changePoints = nextChangePoints
        updatedAt = nextUpdatedAt
        closes = nextCloses
        ema20 = nextEma20
        bbMid = nextBbMid
        bbUpper = nextBbUpper
        bbLower = nextBbLower
    }
}
