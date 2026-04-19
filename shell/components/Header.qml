import QtQuick
import QtQuick.Layouts

Item {
    required property string symbol
    required property string timeframe
    required property int candleCount
    required property string priceText
    required property string changeText
    required property string freshnessText
    required property bool positiveChange
    property string badgeText: "WAITING"
    property string badgeKind: "loading"

    function badgeFill() {
        switch (badgeKind) {
        case "ok":
            return "#3322C55E"
        case "stale":
            return "#33F59E0B"
        case "error":
            return "#33EF4444"
        default:
            return "#33475569"
        }
    }

    function badgeBorder() {
        switch (badgeKind) {
        case "ok":
            return "#664ADE80"
        case "stale":
            return "#66FBBF24"
        case "error":
            return "#66F87171"
        default:
            return "#665E7186"
        }
    }

    function badgeTextColor() {
        switch (badgeKind) {
        case "ok":
            return "#FFDCFCE7"
        case "stale":
            return "#FFFEF3C7"
        case "error":
            return "#FFFEE2E2"
        default:
            return "#FFE2E8F0"
        }
    }

    implicitHeight: headerLayout.implicitHeight

    RowLayout {
        id: headerLayout

        anchors.fill: parent
        spacing: 12

        ColumnLayout {
            spacing: 2

            Text {
                color: "#FFF8FAFC"
                font.pixelSize: 18
                font.bold: true
                text: symbol
            }

            Text {
                color: "#FF94A3B8"
                font.pixelSize: 12
                text: timeframe + " · " + candleCount + " candles"
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: 4

            Text {
                Layout.alignment: Qt.AlignRight
                color: "#FFF8FAFC"
                font.pixelSize: 18
                font.bold: true
                text: priceText
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Text {
                    color: positiveChange ? "#FF4ADE80" : "#FFF87171"
                    font.pixelSize: 12
                    font.bold: true
                    text: changeText
                }

                Text {
                    color: "#FF94A3B8"
                    font.pixelSize: 11
                    text: freshnessText
                }

                Rectangle {
                    radius: 999
                    color: badgeFill()
                    border.width: 1
                    border.color: badgeBorder()
                    implicitHeight: statusLabel.implicitHeight + 10
                    implicitWidth: statusLabel.implicitWidth + 18

                    Text {
                        id: statusLabel

                        anchors.centerIn: parent
                        color: badgeTextColor()
                        font.pixelSize: 11
                        font.bold: true
                        text: badgeText
                    }
                }
            }
        }
    }
}
