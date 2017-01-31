import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.nx.softwarecenter 1.0

import "qrc:/actions/DisableSnapAction.js" as DisableSnapAction
import "qrc:/actions/EnableSnapAction.js" as EnableSnapAction
import "qrc:/actions/RefreshSnapAction.js" as RefreshSnapAction
import "qrc:/actions/RemoveSnapAction.js" as RemoveSnapAction

import "qrc:/scripts/Utils.js" as Utils

Item {
    id: homeViewRoot

    objectName: "homeView"
    Rectangle {
        color: "lightblue"
        anchors.fill: parent
        opacity: 0.1
    }

    ScrollView {
        anchors.fill: parent

        Flickable {
            contentWidth: snapsList.width
            contentHeight: snapsList.height
            anchors.margins: 20

            Flow {
                anchors.centerIn: parent
                id: snapsList
                width: homeViewRoot.width - 20

                Repeater {
                    model: installedSnapsModel
                    delegate: snaptElementDelegate
                }
            }
        }
    }

    Component {
        id: snaptElementDelegate
        Item {
            width: 192
            height: 192
            property bool busy: false
            property var request
            property bool selected: false

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                color: selected ? "lightblue" : "silver"
                opacity: 0.4
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 0
                Item {
                    Layout.alignment: Qt.AlignRight
                    height: 32
                    width: 32
                    Layout.topMargin: 10
                    Layout.rightMargin: 12

                    PlasmaComponents.BusyIndicator {
                        id: busyIndicator
                        visible: busy
                        width: 32
                        height: 32
                    }
                }

                PlasmaCore.IconItem {
                    id: snap_icon
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    Layout.alignment: Qt.AlignHCenter
                    source: model.icon ? model.icon : "package-available"

                    PlasmaCore.IconItem {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        id: snap_status_icon
                        source: "dialog-close"
                        visible: (model.status != 4) & (!busy)
                    }
                }

                Text {
                    id: snap_pkg_name
                    text: name
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    wrapMode: Text.WrapAnywhere
                    Layout.topMargin: 14
                    Layout.leftMargin: 12
                    Layout.maximumWidth: 140
                    font.bold: true
                }

                Text {
                    id: snap_version
                    text: i18n("Version: ") + version
                    Layout.leftMargin: 12
                    font.italic: true
                }
                Text {
                    id: snap_installed_size
                    property string sizeString: Utils.formatSize(installedSize)
                    text: installedSize ? sizeString : i18n("Unknown size")
                    Layout.leftMargin: 12
                    Layout.fillHeight: true
                }
            }

            MouseArea {
                id: snapElementArea
                anchors.fill: parent

                preventStealing: false
                propagateComposedEvents: true
                hoverEnabled: true

                onClicked: {
                    selected = !selected
                    if (selected)
                        installedSnapsModel.selectedItems[name] = "true"
                    else
                        delete installedSnapsModel.selectedItems[name]
                }
            }
        }
    }

    SnapsModel {
        id: installedSnapsModel
        fetchSnapsFunc: function () {
            var request = snapdClient.list()
            request.runSync()

            var list = []
            //            snapList.sort(function (a, b) { return a < b})
            for (var i = 0; i < request.snapCount; i++) {
                var snap = request.snap(i)
                list.push(snap)
            }

            return list;
        }
    }

    Connections {
        target: snapdClient
        onConnected: installedSnapsModel.refresh()
    }

    Component.onCompleted: {
        var actions = [DisableSnapAction.prepare(
                           SnapdRootClient,
                           installedSnapsModel), EnableSnapAction.prepare(
                           SnapdRootClient,
                           installedSnapsModel), RefreshSnapAction.prepare(
                           SnapdRootClient,
                           installedSnapsModel), RemoveSnapAction.prepare(
                           SnapdRootClient, installedSnapsModel)]
        statusArea.updateContext("documentinfo",
                                 i18n("Available actions"), actions)
    }
}