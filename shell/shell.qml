import Quickshell
import QtQuick
import "components"

Scope {
    Variants {
        model: Quickshell.screens.length > 0 ? [Quickshell.screens[0]] : []

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
            }
        }
    }
}
