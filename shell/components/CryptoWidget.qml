import QtQuick
import QtQuick.Layouts

Rectangle {
    id: widget

    property string symbol: "BTCUSDT"
    property string timeframe: "5m"

    readonly property real firstClose: dataSource.hasData ? dataSource.closes[0] : 0
    readonly property real changePercent: dataSource.hasData && firstClose !== 0
        ? (dataSource.changePoints / firstClose) * 100
        : 0

    function priceText() {
        return dataSource.hasData ? "$" + dataSource.price.toFixed(2) : "--"
    }

    function changeText() {
        if (!dataSource.hasData) {
            return dataSource.displayStatus === "error" ? "Unavailable" : "Waiting"
        }

        var points = (dataSource.changePoints >= 0 ? "+" : "") + dataSource.changePoints.toFixed(2)
        var percent = (changePercent >= 0 ? "+" : "") + changePercent.toFixed(2) + "%"
        return points + " (" + percent + ")"
    }

    WidgetDataSource {
        id: dataSource

        symbol: widget.symbol
        timeframe: widget.timeframe
    }

    radius: 24
    color: "#E00B1220"
    border.width: 1
    border.color: "#664B5563"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Header {
            Layout.fillWidth: true
            symbol: dataSource.symbolValue
            timeframe: dataSource.timeframeValue
            candleCount: dataSource.candleCount
            priceText: widget.priceText()
            changeText: widget.changeText()
            freshnessText: dataSource.freshnessText
            positiveChange: dataSource.changePoints >= 0
            badgeText: dataSource.badgeText
            badgeKind: dataSource.displayStatus
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: "#66161F2E"
            border.width: 1
            border.color: dataSource.displayStatus === "error" ? "#55F87171" : "#334B5563"

            ChartCanvas {
                anchors.fill: parent
                anchors.margins: 10
                opacity: dataSource.hasData ? 1 : 0.35
                closes: dataSource.closes
                ema20: dataSource.ema20
                bbUpper: dataSource.bbUpper
                bbMid: dataSource.bbMid
                bbLower: dataSource.bbLower
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                visible: dataSource.displayStatus !== "ok" && dataSource.hasData
                color: dataSource.displayStatus === "error" ? "#14EF4444" : "#14F59E0B"
            }

            Column {
                anchors.centerIn: parent
                width: parent.width - 32
                spacing: 6
                visible: !dataSource.hasData

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#FFF8FAFC"
                    font.pixelSize: 15
                    font.bold: true
                    text: dataSource.placeholderTitle
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    color: "#FF94A3B8"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: dataSource.placeholderDetail
                }
            }

            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: 12
                anchors.bottomMargin: 10
                visible: dataSource.displayStatus !== "ok" && dataSource.hasData
                color: dataSource.displayStatus === "error" ? "#FFFECACA" : "#FFFDE68A"
                font.pixelSize: 11
                font.bold: true
                text: dataSource.displayStatus === "error"
                    ? "Showing last successful snapshot"
                    : "Snapshot is older than 30s"
            }
        }
    }
}
