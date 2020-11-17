/*
    ThumbTerm Copyright Olli Vanhoja
    FingerTerm Copyright 2011-2012 Heikki Holstila <heikki.holstila@gmail.com>
    ToeTerm Copyright 2018 ROZZ, 2019-2020 Matti Viljanen <matti.viljanen@kapsi.fi>

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

    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    SilicaFlickable {
        id: aboutFlickable
        anchors.fill: parent
        contentHeight: header.height + column.height

        VerticalScrollDecorator {
            flickable: aboutFlickable
        }

        PageHeader {
            id: header
            title: qsTr("About")
        }

        Column {
            id: column
            anchors {
                top: header.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: Math.min(Screen.width, aboutFlickable.width)
            spacing: Theme.paddingLarge

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "file:///usr/share/icons/hicolor/172x172/apps/toeterm.png"
                width: Theme.iconSizeExtraLarge
                height: Theme.iconSizeExtraLarge
                smooth: true
                asynchronous: true
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                text: "ToeTerm" + util.versionString()
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
                text: "by ROZZ & direc85"
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("Based on ThumbTerm by Olli Vanhoja, which is fork of FingerTerm by Heikki Holstila")
            }

            DetailItem {
                label: qsTr("Terminal size")
                value: term.termSize().width + "×" + term.termSize().height
            }

            DetailItem {
                label: qsTr("Charset")
                value: util.settingsValue("terminal/charset")
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                text: qsTr("Config files for adjusting settings are at:")
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                text: util.configPath() + "/"
            }

            BackgroundItem {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.iconSizeExtraLarge * 1.2
                height: Theme.iconSizeExtraLarge * 1.2
                onClicked: Qt.openUrlExternally("https://ko-fi.com/direc85")
                contentItem.radius: Theme.paddingSmall

                Image {
                    anchors.centerIn: parent
                    source: "file:///usr/share/toeterm/images/Ko-fi_Icon_RGB_rounded.png"
                    width: Theme.iconSizeExtraLarge
                    height: Theme.iconSizeExtraLarge
                    smooth: true
                    asynchronous: true
                }
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("If you like my work and would like to support me, you can buy me a coffee!")
            }

/*

            // Translations credits will be added in a later release
            AboutLabel {
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                text: qsTr("Translations")
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: "Suomi: Matti Viljanen"
            }
*/

            Button {
                text: "GitHub"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: Qt.openUrlExternally("https://github.com/direc85/toeterm")
            }

            Item {
                width: parent.width
                height: Theme.paddingMedium
            }
        }
    }
}
