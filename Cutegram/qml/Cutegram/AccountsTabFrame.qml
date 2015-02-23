import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0

Rectangle {
    id: acc_tab_frame
    width: 100
    height: 62
    color: backColor0

    property alias hash: tab_list.hash
    property alias list: tab_list.list

    Connections {
        target: profiles
        onKeysChanged: refresh()
        Component.onCompleted: refresh()

        function refresh() {
            for( var i=0; i<profiles.count; i++ ) {
                var key = profiles.keys[i]
                if( hash.containt(key) )
                    continue

                var item = profiles.get(key)
                var acc = account_component.createObject(frame, {"accountItem": item})
                hash.insert(key, acc)
                list.append(key)
            }

            var hashKeys = hash.keys()
            for( var j=0; j>hashKeys.length; i++ ) {
                var key = hashKeys[j]
                if( profiles.containt(key) )
                    continue

                var acc = hash.value(key)
                acc.destroy()

                hash.remove(key)
                list.remove(key)
            }
        }
    }

    Connections {
        target: Cutegram
        onConfigureRequest: conf_btn.clicked()
    }

    Item {
        id: frame
        anchors.left: left_frame.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    SlideMenu {
        id: slide_menu
        anchors.fill: frame
        textFont.family: AsemanApp.globalFont.family
        textFont.pixelSize: Math.floor(13*Devices.fontDensity)
    }

    Rectangle {
        id: left_frame
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 48*Devices.density
        color: Cutegram.highlightColor

        AccountsTabList {
            id: tab_list
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: add_secret_chat_btn.top
            selectColor: slide_menu.active? "#ffffff" : (Cutegram.lightUi? "#cccccc" :"#222222")
            z: 10
            onCurrentKeyChanged: {
                if(lastKey.length != 0)
                    hash.value(lastKey).visible = false

                hash.value(currentKey).visible = true
                lastKey = currentKey
            }

            property string lastKey
        }

        Button {
            id: add_secret_chat_btn
            anchors.bottom: add_chat_btn.top
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/lock.png"
            iconHeight: 18*Devices.density
            tooltipText: qsTr("Add Secret Chat")
            tooltipFont.family: AsemanApp.globalFont.family
            tooltipFont.pixelSize: Math.floor(9*Devices.fontDensity)
            onClicked: {
                slide_menu.text = ""
                slide_menu.show(add_secret_chat_component)
            }
        }

        Button {
            id: add_chat_btn
            anchors.bottom: add_user_btn.top
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/add_chat.png"
            iconHeight: 26*Devices.density
            tooltipText: qsTr("New group chat")
            tooltipFont.family: AsemanApp.globalFont.family
            tooltipFont.pixelSize: Math.floor(9*Devices.fontDensity)
            onClicked: {
                slide_menu.text = ""
                slide_menu.show(add_groupchat_component)
            }
        }

        Button {
            id: add_user_btn
            anchors.bottom: conf_btn.top
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/add_user.png"
            iconHeight: 22*Devices.density
            tooltipText: qsTr("Contact List")
            tooltipFont.family: AsemanApp.globalFont.family
            tooltipFont.pixelSize: Math.floor(9*Devices.fontDensity)
            onClicked: {
                slide_menu.text = ""
                showContactList()
            }
        }

        Button {
            id: conf_btn
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width
            height: width
            normalColor: "#00000000"
            highlightColor: "#88339DCC"
            cursorShape: Qt.PointingHandCursor
            icon: "files/configure.png"
            iconHeight: 22*Devices.density
            tooltipText: qsTr("Configure")
            tooltipFont.family: AsemanApp.globalFont.family
            tooltipFont.pixelSize: Math.floor(9*Devices.fontDensity)
            onClicked: {
                slide_menu.text = ""
                slide_menu.show(configure_component)
            }
        }

        Rectangle {
            anchors.bottom: parent.top
            anchors.right: parent.right
            transformOrigin: Item.BottomRight
            rotation: -90
            width: parent.height
            height: 5*Devices.density
            opacity: 0.6
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 1.0; color: "#88111111" }
            }
        }
    }

    Component {
        id: account_component
        AccountFrame {
            id: accfr
            anchors.fill: parent
            onUnreadCountChanged: refreshUnreadCounts()
            onActiveRequest: {
                tab_list.currentKey = hash.key(accfr)
            }
            onAddParticianRequest: {
                slide_menu.text = qsTr("Just drag and drop contacts here")
                showContactList()
            }
        }
    }

    Component {
        id: add_userchat_component

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 237*Devices.density

            AccountContactList {
                anchors.fill: parent
                telegram: accountView.telegramObject
                onSelected: {
                    slide_menu.end()
                    accountView.view.currentDialog = telegram.fakeDialogObject(cid, false)
                }

                property variant accountView: hash.value(tab_list.currentKey)
            }
        }
    }

    Component {
        id: add_secret_chat_component

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 237*Devices.density

            AccountContactList {
                anchors.fill: parent
                telegram: accountView.telegramObject
                onSelected: {
                    slide_menu.end()
                    telegram.messagesCreateEncryptedChat(cid)
                }

                property variant accountView: hash.value(tab_list.currentKey)
            }
        }
    }

    Component {
        id: configure_component

        Configure {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 357*Devices.density
            telegram: accountView.telegramObject

            property variant accountView: hash.value(tab_list.currentKey)
        }
    }

    Component {
        id: add_groupchat_component

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 237*Devices.density

            LineEdit {
                id: topic_txt
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4*Devices.density
                placeholder: qsTr("Group Topic")
                pickerEnable: Devices.isTouchDevice
            }

            AccountContactList {
                id: contact_list
                anchors.top: topic_txt.bottom
                anchors.bottom: done_btn.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 4*Devices.density
                anchors.bottomMargin: 4*Devices.density
                telegram: accountView.telegramObject

                property variant accountView: hash.value(tab_list.currentKey)
            }

            Button {
                id: done_btn
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                normalColor: Cutegram.highlightColor
                highlightColor: Qt.darker(Cutegram.highlightColor)
                textColor: masterPalette.highlightedText
                textFont.family: AsemanApp.globalFont.family
                textFont.pixelSize: Math.floor(9*Devices.fontDensity)
                textFont.bold: false
                height: 40*Devices.density
                text: qsTr("Create")
                onClicked: {
                    var topic = topic_txt.text.trim()
                    if( topic.length == 0 )
                        return

                    slide_menu.end()
                    contact_list.telegram.messagesCreateChat(contact_list.selecteds, topic)
                }
            }
        }
    }

    function refreshUnreadCounts() {
        var keys = hash.keys()
        var counter = 0
        for( var i=0; i<keys.length; i++ ) {
            var acc = hash.value(keys[i])
            counter += acc.unreadCount
        }

        Cutegram.sysTrayCounter = counter
    }

    function showContactList() {
        slide_menu.show(add_userchat_component)
    }
}
