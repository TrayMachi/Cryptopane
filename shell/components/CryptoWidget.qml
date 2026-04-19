import QtQuick
import QtQuick.Layouts

Rectangle {
    readonly property var sampleCloses: [84210.4, 84235.8, 84288.9, 84302.7, 84274.6, 84320.1, 84364.8, 84401.3, 84392.4, 84426.2, 84470.8, 84455.1, 84492.6, 84540.4, 84528.2, 84571.7, 84612.5, 84648.1, 84691.4, 84742.8]
    readonly property var sampleEma20: [null, null, null, null, 84282.5, 84295.6, 84314.5, 84340.9, 84358.2, 84384.7, 84417.7, 84433.8, 84461.3, 84493.4, 84511.0, 84539.6, 84572.4, 84606.3, 84642.0, 84680.2]
    readonly property var sampleBbUpper: [null, null, null, null, 84354.8, 84378.1, 84412.4, 84454.7, 84476.2, 84508.6, 84549.7, 84576.5, 84609.4, 84646.3, 84669.9, 84702.7, 84739.8, 84779.6, 84820.7, 84865.4]
    readonly property var sampleBbMid: [null, null, null, null, 84262.4, 84284.3, 84309.6, 84340.1, 84355.9, 84379.2, 84408.0, 84434.9, 84463.4, 84494.1, 84518.0, 84546.1, 84578.5, 84613.4, 84650.0, 84689.4]
    readonly property var sampleBbLower: [null, null, null, null, 84170.0, 84190.5, 84206.8, 84225.4, 84235.6, 84249.8, 84266.3, 84293.3, 84317.4, 84341.9, 84366.1, 84389.5, 84417.2, 84447.1, 84479.3, 84513.3]
    readonly property real lastClose: sampleCloses[sampleCloses.length - 1]
    readonly property real firstClose: sampleCloses[0]
    readonly property real changePoints: lastClose - firstClose
    readonly property real changePercent: (changePoints / firstClose) * 100

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
            priceText: "$" + lastClose.toFixed(2)
            changeText: (changePoints >= 0 ? "+" : "") + changePoints.toFixed(2) + " (" + (changePercent >= 0 ? "+" : "") + changePercent.toFixed(2) + "%)"
            positiveChange: changePoints >= 0
        }

        ChartCanvas {
            Layout.fillWidth: true
            Layout.fillHeight: true
            closes: sampleCloses
            ema20: sampleEma20
            bbUpper: sampleBbUpper
            bbMid: sampleBbMid
            bbLower: sampleBbLower
        }
    }
}
