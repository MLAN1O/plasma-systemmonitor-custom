import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.faces as Faces
import org.kde.ksysguard.formatter as Formatter
import org.kde.quickcharts.controls as ChartsControls

import org.kde.plasma.plasma5support as P5Support

Faces.SensorFace {
    id: root

    Layout.minimumWidth: Kirigami.Units.gridUnit * 12
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20

    readonly property string mode: String(root.controller.faceConfiguration.mode || "memory")
    readonly property bool swapMode: root.mode === "swap"
    readonly property bool bothMode: root.mode === "both"
    readonly property string infoCommand: "grep -E '^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree):' /proc/meminfo"
    readonly property int elementSpacing: {
        var value = Number(root.controller.faceConfiguration.spacing);
        return isNaN(value) ? 8 : Math.max(0, Math.min(24, Math.round(value)));
    }

    property real memTotal: 0
    property real memFree: 0
    property real memAvailable: 0
    property real memCached: 0
    property real memBuffers: 0
    property real swapTotal: 0
    property real swapFree: 0

    readonly property real total: root.swapMode ? root.swapTotal : root.memTotal
    readonly property real free: root.swapMode ? root.swapFree : root.memAvailable
    readonly property real used: Math.max(0, root.total - root.free)
    readonly property real cache: root.memCached + root.memBuffers
    readonly property real percentage: root.total > 0 ? root.used / root.total : 0
    readonly property string percentageText: Math.round(root.percentage * 100) + "%"
    readonly property string totalText: Formatter.Formatter.formatValueShowNull(root.total, Formatter.Units.UnitByte)
    readonly property string usedText: Formatter.Formatter.formatValueShowNull(root.used, Formatter.Units.UnitByte)
    readonly property string freeText: Formatter.Formatter.formatValueShowNull(root.free, Formatter.Units.UnitByte)
    readonly property string cacheText: Formatter.Formatter.formatValueShowNull(root.cache, Formatter.Units.UnitByte)

    readonly property real memUsed: Math.max(0, root.memTotal - root.memAvailable)
    readonly property real memPercentage: root.memTotal > 0 ? root.memUsed / root.memTotal : 0
    readonly property string memPercentageText: Math.round(root.memPercentage * 100) + "%"
    readonly property string memTotalText: Formatter.Formatter.formatValueShowNull(root.memTotal, Formatter.Units.UnitByte)
    readonly property string memUsedText: Formatter.Formatter.formatValueShowNull(root.memUsed, Formatter.Units.UnitByte)
    readonly property string memFreeText: Formatter.Formatter.formatValueShowNull(root.memAvailable, Formatter.Units.UnitByte)
    readonly property string memCacheText: Formatter.Formatter.formatValueShowNull(root.cache, Formatter.Units.UnitByte)

    readonly property real swapUsed: Math.max(0, root.swapTotal - root.swapFree)
    readonly property real swapPercentage: root.swapTotal > 0 ? root.swapUsed / root.swapTotal : 0
    readonly property string swapPercentageText: Math.round(root.swapPercentage * 100) + "%"
    readonly property string swapTotalText: Formatter.Formatter.formatValueShowNull(root.swapTotal, Formatter.Units.UnitByte)
    readonly property string swapUsedText: Formatter.Formatter.formatValueShowNull(root.swapUsed, Formatter.Units.UnitByte)
    readonly property string swapFreeText: Formatter.Formatter.formatValueShowNull(root.swapFree, Formatter.Units.UnitByte)

    P5Support.DataSource {
        engine: "executable"
        interval: 2000
        connectedSources: [root.infoCommand]

        onNewData: (sourceName, data) => {
            var output = String(data["stdout"] || "");
            var values = {};
            output.split("\n").forEach(function(line) {
                var match = line.match(/^([A-Za-z]+):\s+(\d+)\s+kB/);
                if (match) {
                    values[match[1]] = parseInt(match[2], 10) * 1024;
                }
            });
            root.memTotal = values.MemTotal || 0;
            root.memFree = values.MemFree || 0;
            root.memAvailable = values.MemAvailable || 0;
            root.memCached = values.Cached || 0;
            root.memBuffers = values.Buffers || 0;
            root.swapTotal = values.SwapTotal || 0;
            root.swapFree = values.SwapFree || 0;
        }
    }

    contentItem: Item {
        implicitWidth: Kirigami.Units.gridUnit * 20
        implicitHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2
        Layout.minimumWidth: Kirigami.Units.gridUnit * 8
        Layout.minimumHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.leftMargin: Kirigami.Units.smallSpacing * 2
            anchors.rightMargin: Kirigami.Units.smallSpacing * 2
            anchors.bottomMargin: Kirigami.Units.smallSpacing * 2
            clip: true
            spacing: root.elementSpacing

        ColumnLayout {
            visible: root.bothMode
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.elementSpacing

            Kirigami.Heading {
                Layout.fillWidth: true
                visible: root.controller.showTitle && text.length > 0
                text: root.controller.title
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                level: 2
            }

            Item {
                Layout.preferredHeight: root.elementSpacing
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.elementSpacing * 2

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: root.elementSpacing

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: root.elementSpacing

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: "Memória"
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        QQC2.Label {
                            text: root.memPercentageText
                            font: Kirigami.Theme.smallFont
                            opacity: 0.75
                        }
                    }

                    Item {
                        Layout.preferredHeight: root.elementSpacing
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 7 / 6) + 8
                        radius: height / 2
                        color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.18)

                        Rectangle {
                            width: Math.max(0, Math.min(parent.width, parent.width * root.memPercentage))
                            height: parent.height
                            radius: height / 2
                            color: Kirigami.Theme.highlightColor
                        }
                    }

                    ChartsControls.LegendDelegate {
                        Layout.fillWidth: true
                        name: root.memUsedText + " usados"
                        value: root.memFreeText + " livres"
                        indicator: Item {}
                        maximumValueWidth: Kirigami.Units.gridUnit * 5
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.25)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: root.elementSpacing

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: root.elementSpacing

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: "Swap"
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        QQC2.Label {
                            text: root.swapPercentageText
                            font: Kirigami.Theme.smallFont
                            opacity: 0.75
                        }
                    }

                    Item {
                        Layout.preferredHeight: root.elementSpacing
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 7 / 6) + 8
                        radius: height / 2
                        color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.18)

                        Rectangle {
                            width: Math.max(0, Math.min(parent.width, parent.width * root.swapPercentage))
                            height: parent.height
                            radius: height / 2
                            color: "#f67400"
                        }
                    }

                    ChartsControls.LegendDelegate {
                        Layout.fillWidth: true
                        name: root.swapUsedText + " usados"
                        value: root.swapFreeText + " livres"
                        indicator: Item {}
                        maximumValueWidth: Kirigami.Units.gridUnit * 5
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: root.elementSpacing * 2

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: root.elementSpacing

                    QQC2.Label {
                        text: "Memória"
                        font.weight: Font.DemiBold
                        opacity: 0.9
                    }

                    Repeater {
                        model: [
                            { label: "Total", value: root.memTotalText },
                            { label: "Em uso", value: root.memUsedText },
                            { label: "Livre", value: root.memFreeText },
                            { label: "Em cache", value: root.memCacheText }
                        ]

                        ChartsControls.LegendDelegate {
                            Layout.fillWidth: true
                            name: modelData.label
                            value: modelData.value
                            indicator: Item {}
                            maximumValueWidth: Kirigami.Units.gridUnit * 4
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.25)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: root.elementSpacing

                    QQC2.Label {
                        text: "Swap"
                        font.weight: Font.DemiBold
                        opacity: 0.9
                    }

                    Repeater {
                        model: [
                            { label: "Total", value: root.swapTotalText },
                            { label: "Em uso", value: root.swapUsedText },
                            { label: "Livre", value: root.swapFreeText }
                        ]

                        ChartsControls.LegendDelegate {
                            Layout.fillWidth: true
                            name: modelData.label
                            value: modelData.value
                            indicator: Item {}
                            maximumValueWidth: Kirigami.Units.gridUnit * 4
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        ColumnLayout {
            visible: !root.bothMode
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: root.elementSpacing

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing * 2
                spacing: Kirigami.Units.smallSpacing * 2

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    Layout.alignment: Qt.AlignVCenter
                    source: root.swapMode
                        ? Qt.resolvedUrl("../../../../card-icons/swap.svg")
                        : Qt.resolvedUrl("../../../../card-icons/memory.svg")
                    isMask: true
                    color: Kirigami.Theme.highlightColor
                }

                Kirigami.Heading {
                    id: heading
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: root.controller.title
                    visible: root.controller.showTitle && text.length > 0
                    level: 2
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    text: root.percentageText
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                    opacity: 0.75
                }
            }

            Rectangle {
                id: track
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 7 / 6) + 8
                radius: height / 2
                color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.18)

                Rectangle {
                    width: Math.max(0, Math.min(parent.width, parent.width * root.percentage))
                    height: parent.height
                    radius: height / 2
                    color: root.swapMode ? "#f67400" : Kirigami.Theme.highlightColor
                }
            }

            ChartsControls.LegendDelegate {
                Layout.fillWidth: true
                name: root.usedText + " usados"
                value: root.freeText + " livres"
                indicator: Item {}
                maximumValueWidth: Kirigami.Units.gridUnit * 5
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                Layout.topMargin: 1

                Kirigami.Separator {
                    width: parent.width
                    height: 1
                    y: 1
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: root.swapMode
                        ? [
                            { label: "Total", value: root.totalText },
                            { label: "Em uso", value: root.usedText },
                            { label: "Livre", value: root.freeText }
                          ]
                        : [
                            { label: "Total", value: root.totalText },
                            { label: "Em uso", value: root.usedText },
                            { label: "Livre", value: root.freeText },
                            { label: "Em cache", value: root.cacheText }
                          ]

                    ChartsControls.LegendDelegate {
                        Layout.fillWidth: true
                        name: modelData.label
                        value: modelData.value
                        indicator: Item {}
                        maximumValueWidth: Kirigami.Units.gridUnit * 4
                    }
                }
            }

            Item {
                Layout.preferredHeight: root.swapMode ? Math.round(Kirigami.Units.gridUnit * 1.6) : 0
            }
        }
    }
    }
}
