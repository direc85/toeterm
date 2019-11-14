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

Rectangle {
    id: lineView
    property variant lines: [""]
    property int fontPointSize: util.settingsValue("ui/fontSize")*window.pixelRatio;
    property int cursorX: 1
    property int cursorWidth: 10
    property int cursorHeight: 10
    property int extraLines: 1
    property string fgColor: "#ffffff"

    color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity * 0.5)
    height: 0
    width: parent.width
    visible: opacity > 0
    opacity: 0

    Behavior on opacity {
        FadeAnimation { }
    }

    Rectangle {
        x: cursorX
        anchors.bottom: lineTextCol.bottom
        width: cursorWidth
        height: cursorHeight
        color: lineView.fgColor
        opacity: 0.75
    }

    Column {
        id: lineTextCol
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 2*window.pixelRatio
        anchors.rightMargin: 2*window.pixelRatio
        Repeater {
            model: lines
            delegate:
                Rectangle {
                height: textrender.fontHeight
                width: lineTextCol.width
                color: "transparent"
                Text {
                    color: lineView.fgColor
                    font: textrender.getFont()
                    text: modelData
                    textFormat: Text.PlainText
                    wrapMode: Text.NoWrap
                    elide: Text.ElideNone
                    maximumLineCount: 1
                }
            }
        }
        onHeightChanged: {
            lineView.height = height+8*window.pixelRatio
            setPosition(vkb.active)
        }
    }

    Component.onCompleted: {
        extraLines = util.settingsValue("ui/showExtraLinesFromCursor");
    }

    function setPosition(vkbActive)
    {
        if(util.settingsValue("ui/vkbShowMethod")==="off") {
            lineView.opacity = 0;
            return;
        }
        y = (util.settingsValue("ui/vkbShowMethod")!=="move") ? 0 : -(height+window.paddingSmall);
        lineView.opacity = vkbActive ? 1 : 0;
    }
}
