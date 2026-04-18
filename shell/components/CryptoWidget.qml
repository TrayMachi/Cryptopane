import QtQuick
import QtQuick.Layouts

Rectangle {
    radius: 24
    color: "#D90B1220"
    border.width: 1
    border.color: "#664B5563"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        Header {
            Layout.fillWidth: true
            symbol: "BTCUSDT"
            timeframe: "5m"
            statusText: "Waiting for data"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: "#66161F2E"
            border.width: 1
            border.color: "#334B5563"

            Text {
                anchors.centerIn: parent
                color: "#FFCBD5E1"
                font.pixelSize: 15
                text: "Chart area reserved for Phase 2"
            }
        }
    }
}
