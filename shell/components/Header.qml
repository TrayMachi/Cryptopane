import QtQuick
import QtQuick.Layouts

Item {
    required property string symbol
    required property string timeframe
    required property string priceText
    required property string changeText
    required property bool positiveChange
    property string badgeText: "WAITING"

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
                text: timeframe + " data bridge"
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

                Rectangle {
                    radius: 999
                    color: "#3322C55E"
                    border.width: 1
                    border.color: "#664ADE80"
                    implicitHeight: statusLabel.implicitHeight + 10
                    implicitWidth: statusLabel.implicitWidth + 18

                    Text {
                        id: statusLabel

                        anchors.centerIn: parent
                        color: "#FFDCFCE7"
                        font.pixelSize: 11
                        font.bold: true
                        text: badgeText
                    }
                }
            }
        }
    }
}
