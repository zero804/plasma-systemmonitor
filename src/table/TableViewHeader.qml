import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQml.Models 2.12

import org.kde.kirigami 2.2 as Kirigami

import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.qqc2desktopstyle.private 1.0 as StylePrivate

Item {
    id: heading

    x: -view.contentX
    width: view.contentWidth
    height: headerRow.height

    property TableView view
    property int sortColumn: -1
    property int sortOrder: Qt.AscendingOrder

    property string idRole: "Attribute"
    property string sortName

    signal sort(int column, int order)
    signal resize(int column, real width)
    signal contextMenuRequested(int column, point position)

    function columnWidth(index) {
        return repeater.itemAt(index).width
    }

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Button

    StylePrivate.StyleItem {
        anchors.fill: parent
        elementType: "header"
        raised: false
        sunken: false
        properties: {
            "headerpos": "end"
        }
    }

    Row {
        id: headerRow

        Repeater {
            id: repeater

            model: KItemModels.KColumnHeadersModel {
                sourceModel: heading.view.model
            }

            delegate: StylePrivate.StyleItem {
                id: headerItem

                width: heading.view.columnWidthProvider(model.row)
                enabled: width > 0

                property string headerPosition: {
                    if (repeater.count === 1) {
                        return "only";
                    }

                    return "beginning";
                }

                property string columnId: model[heading.idRole] !== undefined ? model[heading.idRole] : ""

                elementType: "header"
                activeControl: heading.sortName == columnId ? (heading.sortOrder == Qt.AscendingOrder ? "down" : "up") : ""
                raised: false
                sunken: mouse.pressed
                text: model.display != undefined ? model.display : ""
                hover: mouse.containsMouse

                properties: {
                    "headerpos": headerPosition,
                    "textalignment": Text.AlignHCenter
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: {
                        if (mouse.button == Qt.RightButton) {
                            heading.contextMenuRequested(model.row, mapToGlobal(mouse.x, mouse.y))
                            return
                        }

                        if (heading.sortName == headerItem.columnId) {
                            heading.sortOrder = heading.sortOrder == Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder;
                        } else {
                            heading.sortColumn = model.row;
                            heading.sortName = headerItem.columnId
                            heading.sortOrder = Qt.AscendingOrder;
                        }

                        heading.sort(heading.sortColumn, heading.sortOrder)
                    }
                }
                MouseArea {
                    id: dragHandle
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    drag.target: dragHandle
                    drag.axis: Drag.XAxis
                    cursorShape: enabled ? Qt.SplitHCursor : undefined
                    width: Kirigami.Units.smallSpacing * 2
                    property real mouseDownX
                    property bool dragging: false
                    onPressed: {
                        dragging = true
                        mouseDownX = x
                        anchors.right = undefined
                    }
                    onXChanged: {
                        if (!dragging) {
                            return
                        }
                        heading.resize(model.row, headerItem.width + (x - mouseDownX))
                        mouseDownX = x

                    }
                    onReleased: {
                        dragging = false
                        anchors.right = parent.right
                    }
                }

                Component.onCompleted: {
                    if (heading.sortColumn == -1 && headerItem.columnId == heading.sortName) {
                        heading.sortColumn = model.row
                        heading.sort(model.row, heading.sortOrder)
                    }
                }
            }
        }
    }
}