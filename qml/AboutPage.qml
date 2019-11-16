/*
    ThumbTerm Copyright Olli Vanhoja
    FingerTerm Copyright 2011-2012 Heikki Holstila <heikki.holstila@gmail.com>
    ToeTerm Copyright 2018 ROZZ, 2019 Matti Viljanen

    This file is part of ToeTerm.

    ToeTerm is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    ToeTerm is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ToeTerm.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    allowedOrientations: Orientation.All
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge
        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("About")
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "file:///usr/share/icons/hicolor/172x172/apps/toeterm.png"
                width: Screen.width / 3
                height: Screen.width / 3
            }
            Column {
                width: parent.width
                spacing: Theme.paddingSmall
                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    text: "ToeTerm " + util.versionString()
                    color: Theme.highlightColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    anchors.right: parent.right
                    anchors.left: parent.left
                    text: "by ROZZ & direc85"
                    color: Theme.rgba(Theme.highlightColor, 0.5)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeSmall

                }
            }
            Column {
                width: parent.width
                spacing: Theme.paddingSmall
                Rectangle {
                    width: parent.width
                    height: nameText1.height
                    color: "transparent"
                    Label {
                        id: nameText1
                        x: 0
                        width: parent.width/2 - Theme.paddingMedium/2
                        text: qsTr("Terminal size")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.rgba(Theme.highlightColor, 0.5)
                        horizontalAlignment: Text.AlignRight
                    }
                    Label {
                        x: parent.width/2 + Theme.paddingMedium/2
                        width: parent.width/2 - Theme.paddingMedium/2
                        text: term.termSize().width + "×" + term.termSize().height
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                        horizontalAlignment: Text.AlignLeft
                    }
                }
                Rectangle {
                    width: parent.width
                    height: nameText1.height
                    color: "transparent"
                    Label {
                        id: nameText2
                        x: 0
                        width: parent.width/2 - Theme.paddingMedium/2
                        text: qsTr("Charset")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.rgba(Theme.highlightColor, 0.5)
                        horizontalAlignment: Text.AlignRight
                    }
                    Label {
                        x: parent.width/2 + Theme.paddingMedium/2
                        width: parent.width/2 - Theme.paddinMedium/2
                        text: util.settingsValue("terminal/charset")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }
            Label {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge * 2
                text: qsTr("Based on ThumbTerm by Olli Vanhoja, which is fork of FingerTerm by Heikki Holstila")
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                color: Theme.highlightColor
            }
            Column {
                width: parent.width
                Label {
                    x: Theme.paddingLarge
                    width: parent.width - Theme.paddingLarge * 2
                    text: qsTr("Config files for adjusting settings are at:")
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.Wrap
                    color: Theme.highlightColor
                }
                Label {
                    x: Theme.paddingLarge
                    width: parent.width - Theme.paddingLarge * 2
                    text: util.configPath()
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.Wrap
                    color: Theme.rgba(Theme.highlightColor, 0.5)
                }
            }
        }
    }
}
