import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.networkmanagement as PlasmaNM

import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces

import "../../../../plasma-systemmonitor-custom/config.js" as LocalConfig

Faces.SensorFace {
    id: root

    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredWidth: Kirigami.Units.gridUnit * 24

    readonly property var networks: LocalConfig.networks

    readonly property color downloadColor: Kirigami.Theme.highlightColor
    readonly property color uploadColor: "#F67400"
    readonly property int historySeconds: root.controller.faceConfiguration.historySeconds > 0
        ? root.controller.faceConfiguration.historySeconds
        : 60

    contentItem: Item {
        implicitWidth: contentLayout.implicitWidth
        implicitHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2
        Layout.minimumWidth: contentLayout.implicitWidth
        Layout.minimumHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: contentLayout.implicitWidth
        Layout.preferredHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.leftMargin: Kirigami.Units.smallSpacing * 2
            anchors.rightMargin: Kirigami.Units.smallSpacing * 2
            anchors.bottomMargin: Kirigami.Units.smallSpacing * 2
            clip: true
            spacing: Kirigami.Units.smallSpacing * 2

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing * 2
                spacing: Kirigami.Units.smallSpacing * 2

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium - Kirigami.Units.smallSpacing
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium - Kirigami.Units.smallSpacing
                    Layout.alignment: Qt.AlignVCenter
                    source: Qt.resolvedUrl("../../../../card-icons/network.svg")
                    isMask: true
                    color: Kirigami.Theme.highlightColor
                }

                Kirigami.Heading {
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
            }

            Repeater {
                model: root.networks

                Rectangle {
                    id: networkCard

                    readonly property string interfaceName: modelData.interfaceName

                    Layout.fillWidth: true
                    Layout.minimumHeight: rowLayout.implicitHeight + Kirigami.Units.smallSpacing * 6
                    Layout.preferredHeight: rowLayout.implicitHeight + Kirigami.Units.smallSpacing * 6
                    radius: Kirigami.Units.smallSpacing * 2
                    color: Kirigami.Theme.alternateBackgroundColor
                    border.width: 1
                    border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)

                    readonly property string downloadId: "network/" + networkCard.interfaceName + "/download"
                    readonly property string uploadId: "network/" + networkCard.interfaceName + "/upload"
                    readonly property string ipv4Id: "network/" + networkCard.interfaceName + "/ipv4address"
                    readonly property string ipv4Address: ipv4Sensor.formattedValue
                    readonly property real maxRate: modelData.maxRate
                    property bool connected: false

                    Component.onCompleted: Qt.callLater(updateConnectionState)

                    function updateConnectionState() {
                        for (let i = 0; i < connectionRepeater.count; ++i) {
                            const item = connectionRepeater.itemAt(i);
                            if (item && item.active) {
                                networkCard.connected = true;
                                return;
                            }
                        }
                        networkCard.connected = false;
                    }

                    PlasmaNM.NetworkModel {
                        id: networkModel
                    }

                    Repeater {
                        id: connectionRepeater
                        model: networkModel

                        delegate: Item {
                            visible: false

                            readonly property bool active: DeviceName === networkCard.interfaceName
                                && ConnectionState === PlasmaNM.Enums.Activated

                            onActiveChanged: networkCard.updateConnectionState()
                            Component.onCompleted: Qt.callLater(networkCard.updateConnectionState)
                            Component.onDestruction: Qt.callLater(networkCard.updateConnectionState)
                        }

                        onCountChanged: Qt.callLater(networkCard.updateConnectionState)
                    }

                    Sensors.Sensor {
                        id: ipv4Sensor
                        sensorId: networkCard.ipv4Id
                        updateRateLimit: root.controller.updateRateLimit
                    }

                    Sensors.Sensor {
                        id: downloadSensor
                        sensorId: networkCard.downloadId
                        updateRateLimit: root.controller.updateRateLimit
                    }

                    Sensors.Sensor {
                        id: uploadSensor
                        sensorId: networkCard.uploadId
                        updateRateLimit: root.controller.updateRateLimit
                    }

                    RowLayout {
                        id: rowLayout
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing * 3
                        spacing: Kirigami.Units.smallSpacing * 2

                        Kirigami.Icon {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.large - Kirigami.Units.smallSpacing
                            Layout.preferredHeight: Kirigami.Units.iconSizes.large - Kirigami.Units.smallSpacing
                            Layout.alignment: Qt.AlignVCenter
                            source: Qt.resolvedUrl("../../../../card-icons/" + modelData.icon)
                            isMask: true
                            color: Kirigami.Theme.highlightColor
                        }

                        ColumnLayout {
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 13
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 13
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: modelData.label
                                elide: Text.ElideRight
                                font.bold: true
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                            }

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: networkCard.connected
                                    ? (networkCard.ipv4Address.length > 0 ? "Conectado · IPv4 " + networkCard.ipv4Address : "Conectado")
                                    : "Desconectado"
                                elide: Text.ElideRight
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                opacity: 0.7
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        ColumnLayout {
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 9
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 9
                            Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Kirigami.Units.smallSpacing / 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Kirigami.Units.smallSpacing / 2

                                Kirigami.Icon {
                                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                    Layout.alignment: Qt.AlignVCenter
                                    source: "arrow-down-symbolic"
                                    color: root.downloadColor
                                }

                                QQC2.Label {
                                    Layout.fillWidth: true
                                    text: downloadSensor.formattedValue
                                    elide: Text.ElideRight
                                    font.bold: true
                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                }
                            }

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: "Download"
                                font: Kirigami.Theme.smallFont
                                opacity: 0.75
                            }

                            Sparkline {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5
                                sensorId: networkCard.downloadId
                                lineColor: root.downloadColor
                                historySeconds: root.historySeconds
                                updateRateLimit: root.controller.updateRateLimit
                                maximumValue: networkCard.maxRate
                            }
                        }

                        ColumnLayout {
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 9
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 9
                            Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                            Layout.leftMargin: Kirigami.Units.gridUnit
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Kirigami.Units.smallSpacing / 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Kirigami.Units.smallSpacing / 2

                                Kirigami.Icon {
                                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                    Layout.alignment: Qt.AlignVCenter
                                    source: "arrow-up-symbolic"
                                    color: root.uploadColor
                                }

                                QQC2.Label {
                                    Layout.fillWidth: true
                                    text: uploadSensor.formattedValue
                                    elide: Text.ElideRight
                                    font.bold: true
                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                }
                            }

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: "Upload"
                                font: Kirigami.Theme.smallFont
                                opacity: 0.75
                            }

                            Sparkline {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5
                                sensorId: networkCard.uploadId
                                lineColor: root.uploadColor
                                historySeconds: root.historySeconds
                                updateRateLimit: root.controller.updateRateLimit
                                maximumValue: networkCard.maxRate
                            }
                        }

                    }
                }
            }
        }
    }
}
