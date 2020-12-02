import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.3 as Maui

import NXModels 1.0 as NX
import "../../templates"

Maui.Page
{
    id: control

    Maui.Dialog {
        id: appLaunchErrorDialog

        title: "Error"
        message: "Error launching application"
        rejectButton.visible: false

        acceptButton.onClicked: {
            appLaunchErrorDialog.visible = false;
        }

        function showDialog(fileName, errCode) {
            switch (errCode) {
            case 0:
                message = "Error launching application <b>" + fileName + "</b>. Please check if you have correct permission"
                break;

            default:
                message = "Error launching application " + fileName
                break;
            }

            appLaunchErrorDialog.visible = true;
        }
    }

    Maui.Dialog {
        property var filePath: ""

        id: appRemoveDialog

        title: "Remove"
        message: "Are you sure you want to remove this application?"

        acceptButton.onClicked: {
            _appsList.removeApp(filePath);
        }

        function showDialog(path) {
            appRemoveDialog.visible = true;
            filePath = path;
        }
    }

    headBar.middleContent: Maui.TextField
    {
        id: _filterBar
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Filter %1 installed apps", _appsList.count)
    }

    headBar.rightContent: [

        Maui.ToolButtonMenu
        {
            icon.name: "view-sort"

            MenuItem
            {
                text: i18n("Name")
                checkable: true
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Size")
                checkable: true
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Date")
                checkable: true
                autoExclusive: true
            }
        }
    ]

    Maui.Holder
    {
        title: i18n("Oops!")
        body: i18n("No apps found")
        visible: _appsListView.count === 0
        emoji: "qrc:/store.svg"
        emojiSize: Maui.Style.iconSizes.huge
    }

    Maui.ListBrowser
    {
        id: _appsListView
        anchors.fill: parent
        orientation: ListView.Vertical
        spacing: Maui.Style.space.medium
        section.property: "category"
        section.criteria: ViewSection.FullString
        section.delegate: Maui.LabelDelegate
        {
            id: delegate
            label: section
            labelTxt.font.pointSize: Maui.Style.fontSizes.big
            isSection: true
            labelTxt.font.bold: true
            height: Maui.Style.toolBarHeightAlt
            width: parent.width
        }

        model: Maui.BaseModel
        {
            id: _appsModel
            list: NX.Apps
            {
                id: _appsList
            }
        }

        delegate: Maui.SwipeBrowserDelegate
        {
            id: _delegate
            height: 64
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            label1.text: model.name
            label2.text: model.description
            iconSource: model.smallpic
            iconSizeHint: height * 0.7

            onClicked: console.log("JAJAJAJ")

            quickActions: [
                Action
                {
                    icon.name: "media-playback-start"
                    onTriggered: {
                        _appsListView.currentIndex = index;
                        _appsList.launchApp(model.path);
                    }
                },
                Action
                {
                    icon.name: "entry-delete"
                    onTriggered: {
                        _appsListView.currentIndex = index;
                        appRemoveDialog.showDialog(model.path);
                    }
                }
            ]
        }
    }

    Connections {
        target: _appsList

        function onAppLaunchError(err) {
            console.log("App Launch Error", err);
            appLaunchErrorDialog.showDialog(_appsListView.model.get(_appsListView.currentIndex).path.split("/").pop(), err);
            _appsListView.currentIndex = -1;
        }

        function onAppLaunchSuccess() {
            _appsListView.currentIndex = -1;
        }

        function onAppDeleteSuccess() {
            appRemoveDialog.visible = false;
        }
    }
}



