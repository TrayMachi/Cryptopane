import Quickshell
import QtQuick
import "components"

Scope {
    readonly property string widgetSymbol: "BTCUSDT"
    readonly property string widgetTimeframe: "5m"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            aboveWindows: false
            focusable: false
            color: "transparent"
            implicitWidth: 320
            implicitHeight: 180

            anchors {
                top: true
                right: true
            }

            margins {
                top: 24
                right: 24
            }

            CryptoWidget {
                anchors.fill: parent
                symbol: widgetSymbol
                timeframe: widgetTimeframe
            }
        }
    }
}
