import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false

    required property string symbol
    required property string timeframe

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

    readonly property bool hasData: closes.length > 1
    readonly property string badgeText: {
        if (rawStatus === "error") {
            return "ERROR"
        }

        if (!hasData) {
            return "WAITING"
        }

        return "LIVE"
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
        var nextDetail = nextStatus === "error" ? "Backend reported an error" : "Widget data loaded"

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
