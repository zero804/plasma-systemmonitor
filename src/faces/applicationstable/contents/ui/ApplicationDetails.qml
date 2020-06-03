import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

import org.kde.kirigami 2.4 as Kirigami

import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.quickcharts 1.0 as Charts

import org.kde.ksysguard.formatter 1.0 as Formatter
import org.kde.ksysguard.process 1.0 as Process
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.table 1.0 as Table

Page {
    id: root

    property var applications: []

    readonly property var firstApplication: applications.length > 0 ? applications[0] : null

    property real headerHeight: Kirigami.Units.gridUnit

    signal close()

    Kirigami.Theme.colorSet: Kirigami.Theme.View

    background: Rectangle { color: Kirigami.Theme.backgroundColor }

    header: ToolBar {
        implicitHeight: root.headerHeight
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Window

        Label { text: i18n("Details") }

        ToolButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: Math.min(root.headerHeight, implicitHeight)
            width: height
            icon.name: "dialog-close"
            onClicked: root.close()
        }
    }

    ColumnLayout {
        visible: root.firstApplication != null

        anchors {
            fill: parent
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.largeSpacing
            topMargin: Kirigami.Units.smallSpacing
        }

        Label {
            text: i18n("CPU")
        }

        LineChartCard {
            Layout.fillHeight: false
            Layout.preferredHeight: Kirigami.Units.gridUnit * 3

            legendVisible: false

            yRange { from: 0; to: 100; automatic: false }
            xRange { from: 0; to: 50 }
            unit: Formatter.Units.UnitPercent

            colorSource: Charts.SingleValueSource { value: Kirigami.Theme.negativeTextColor }
            valueSources: [
                Charts.ValueHistorySource {
                    id: cpuHistory
                    value: root.firstApplication ? root.firstApplication.cpu : 0
                    maximumHistory: 50
                    interval: 500
                }
            ]
        }
        Label {
            text: i18n("Memory")
        }
        LineChartCard {
            Layout.fillHeight: false
            Layout.preferredHeight: Kirigami.Units.gridUnit * 3

            legendVisible: false

//             yRange { from: 0; to: totalMemorySensor.value; automatic: false }
            xRange { from: 0; to: 50 }
            unit: totalMemorySensor.unit

            colorSource: Charts.SingleValueSource { value: Kirigami.Theme.positiveTextColor }
            valueSources: [
                Charts.ValueHistorySource {
                    id: memoryHistory
                    value: root.firstApplication ? root.firstApplication.memory : 0
                    maximumHistory: 50
                    interval: 500
                }
            ]

            Sensors.Sensor { id: totalMemorySensor; sensorId: "mem/physical/total" }
        }
        Label {
            text: i18n("Network")
        }
        LineChartCard {
            Layout.fillHeight: false
            Layout.preferredHeight: Kirigami.Units.gridUnit * 3

            legendVisible: false
            xRange { from: 0; to: 50 }
            unit: Formatter.Units.UnitKiloByteRate

            valueSources: [
                Charts.ValueHistorySource {
                    id: netInboundHistory
                    value: root.firstApplication ? root.firstApplication.netInbound : 0;
                    maximumHistory: 50
                    interval: 500
                },
                Charts.ValueHistorySource {
                    id: netOutboundHistory
                    value: root.firstApplication ? root.firstApplication.netOutbound : 0;
                    maximumHistory: 50
                    interval: 500
                }
            ]
        }
        Label {
            text: i18n("Disk")
        }
        LineChartCard {
            Layout.fillHeight: false
            Layout.preferredHeight: Kirigami.Units.gridUnit * 3

            legendVisible: false
            xRange { from: 0; to: 50 }
            unit: Formatter.Units.UnitKiloByteRate

            valueSources: [
                Charts.ValueHistorySource {
                    id: diskReadHistory
                    value: root.firstApplication ? root.firstApplication.diskRead : 0;
                    maximumHistory: 50
                    interval: 500
                },
                Charts.ValueHistorySource {
                    id: diskWriteHistory
                    value: root.firstApplication ? root.firstApplication.diskWrite : 0;
                    maximumHistory: 50
                    interval: 500
                }
            ]
        }

//         Label { text: i18n("Threads: %1", processTable.rows) }
        Label { text: i18n("Processes: %1", processTable.rows) }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: -Kirigami.Units.largeSpacing;
            Layout.rightMargin: -Kirigami.Units.largeSpacing;

            color: Kirigami.Theme.backgroundColor
            Kirigami.Theme.colorSet: Kirigami.Theme.View

            Table.BaseTableView {
                id: processTable

                anchors.fill: parent

                columnWidths: [0.5, 0.25, 0.25]
                sortName: "name"
                idRole: Process.ProcessDataModel.Attribute

                model: KItemModels.KSortFilterProxyModel {
                    id: sortFilter

//                     sourceModel: processModel

                    filterColumnCallback: function(column, parent) {
                        if (column == processModel.enabledAttributes.indexOf("pid")) {
                            return false
                        }
                        return true
                    }

                    filterRowCallback: function(row, parent) {
                        var index = processModel.index(row, processModel.enabledAttributes.indexOf("pid"))
                        var pid = processModel.data(index, Process.ProcessDataModel.Value)
                        if (root.firstApplication) {
                            for (var i in root.firstApplication.pids) {
                                if (root.firstApplication.pids[i] == pid) {
                                    return true
                                }
                            }
                        }
                        return false
                    }
                }

                Process.ProcessDataModel {
                    id: processModel

                    enabled: root.visible && root.firstApplication != null

                    enabledAttributes: [
                        "name",
                        "usage",
                        "vmPSS",
                        "pid",
                    ]
                }

                delegate: Table.BasicCellDelegate { }
            }

            Kirigami.Separator { anchors.bottom: processTable.top; width: parent.width }
        }
    }

    Label {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        text: i18n("Select an application to see its details.")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        visible: root.firstApplication == null
    }

    onApplicationsChanged: {
        cpuHistory.clear()
        memoryHistory.clear()
        netInboundHistory.clear()
        netOutboundHistory.clear()
        diskReadHistory.clear()
        diskWriteHistory.clear()
    }
    onFirstApplicationChanged: {
        sortFilter.invalidate()
    }
}