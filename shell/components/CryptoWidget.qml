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
            return dataSource.rawStatus === "error" ? "Unavailable" : "Waiting"
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
            priceText: widget.priceText()
            changeText: widget.changeText()
            positiveChange: dataSource.changePoints >= 0
            badgeText: dataSource.badgeText
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: "#66161F2E"
            border.width: 1
            border.color: "#334B5563"

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
                    text: dataSource.rawStatus === "error" ? "Backend Error" : "Waiting For Data"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    color: "#FF94A3B8"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: dataSource.rawStatus === "error"
                        ? dataSource.detailText
                        : "Run the Rust backend to generate live widget JSON"
                }
            }
        }
    }
}
