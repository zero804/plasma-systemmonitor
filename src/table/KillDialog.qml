import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import org.kde.kirigami 2.8 as Kirigami

Dialog {
    id: dialog

    property var items: []
    property bool doNotAskAgain: false

    modal: true
    parent: Overlay.overlay

    x: parent ? parent.width / 2 - width / 2 : 0
    y: ApplicationWindow.window ? ApplicationWindow.window.pageStack.globalToolBar.height - Kirigami.Units.smallSpacing : 0

    leftPadding: 1 // Allow dialog background border to show
    rightPadding: 1 // Allow dialog background border to show
    bottomPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    bottomInset: -Kirigami.Units.smallSpacing

    property string killButtonText: "Exterminate"
    property string killButtonIcon: "killbots"
    property string questionText: "Ex-ter-mi-nate"

    property alias delegate: list.delegate

    contentItem: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
        implicitWidth: Kirigami.Units.gridUnit * 25
        implicitHeight: Kirigami.Units.gridUnit * 20

        Kirigami.Separator { anchors { left: parent.left; right: parent.right; top: parent.top } }

        ScrollView {
            anchors.fill: parent
            anchors.topMargin: 1
            anchors.bottomMargin: 1

            ListView {
                id: list

                header: Label {
                    id: questionLabel
                    padding: Kirigami.Units.gridUnit
                    text: dialog.questionText
                }

                model: dialog.items
                currentIndex: -1

                delegate: Kirigami.AbstractListItem {
                    leftPadding: Kirigami.Units.gridUnit
                    contentItem: Label { text: modelData; width: parent.width; elide: Text.ElideRight }
                    highlighted: false
                    hoverEnabled: false
                }
            }
        }

        Kirigami.Separator { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } }
    }

    footer: DialogButtonBox {
        CheckBox {
            implicitWidth: contentItem.implicitWidth + Kirigami.Units.smallSpacing * 2
            contentItem: Label { leftPadding: Kirigami.Units.gridUnit; text: i18n("Do not ask again") }
            DialogButtonBox.buttonRole: DialogButtonBox.ActionRole

            onToggled: dialog.doNotAskAgain = checked
        }
        Button {
            implicitWidth: contentItem.implicitWidth + Kirigami.Units.largeSpacing * 2
            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                //Workaround for QTBUG-81796
                Kirigami.Icon { source: dialog.killButtonIcon; width: Kirigami.Units.iconSizes.smallMedium; height: width }
                Label { text: dialog.killButtonText }
            }
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }
        Button {
            implicitWidth: contentItem.implicitWidth + Kirigami.Units.largeSpacing * 2
            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                //Workaround for QTBUG-81796
                Kirigami.Icon { source: "dialog-cancel"; width: Kirigami.Units.iconSizes.smallMedium; height: width }
                Label { text: i18n("Cancel") }
            }
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
