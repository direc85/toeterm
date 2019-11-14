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
    id: key
    property string label: ""
    property string label_alt: ""
    property int code: 0
    property int code_alt: 0
    property int currentCode: (shiftActive && label_alt != '') ? code_alt : code
    property string currentLabel: (shiftActive && label_alt != '') ? label_alt : label
    property bool sticky: false     // can key be stickied?
    property bool becomesSticky: false // will this become sticky after release?
    property int stickiness: 0      // current stickiness status
    property bool passiveKey: keyboard.isPassiveKey(code)
    property real labelOpacity: keyboard.active ? 1.0 : key.passiveKey ? 0.75 : 0.15
    property real iconSize: Math.min(width, height)

    // mouse input handling
    property int clickThreshold: 20
    property bool isClick: false
    property int pressMouseY: 0
    property int pressMouseX: 0

    width: window.width/12   // some default
    height: window.height/8 < 55*window.pixelRatio ? window.height/8 : 55*window.pixelRatio

    Rectangle {
        anchors.fill: parent
        color: label=="" ? "transparent" : keyboard.backgroundColorActive
        opacity: keyboard.active ? 1 : 0
        Behavior on opacity {
            FadeAnimation {}
        }
    }

    color: "transparent"

    property bool shiftActive: (keyboard.keyModifiers & Qt.ShiftModifier) && !sticky

    Rectangle {
        id: highlightedBackground
        anchors.fill: parent
        visible: false
        color: keyboard.keyHilightBgColor
    }

    Image {
        id: keyImage
        anchors.centerIn: parent

        width: iconSize
        height: iconSize
        opacity: (key.label_alt == '' || !key.shiftActive) ? key.labelOpacity : 0
        Behavior on opacity {
            FadeAnimation {}
        }
        source: {
            if(key.label.length > 1 && keyboard.iconReference[key.label]) {
                if(key.label === ":enter") {
                    mirror = true
                    scale = 0.9
                }
                else if(key.label ===  "pgup")
                    scale = 0.9
                else if(key.label ===  "pgdn")
                    scale = 0.9
                else if(key.label === ":shift")
                    scale = 0.9
                else if(key.label === ":tab")
                    rotation = -90
                else if(key.label === ":left")
                    rotation = 90
                else if(key.label === ":right")
                    rotation = -90
                else if(key.label === ":up")
                    rotation = 180
                else if(key.label === ":backspace")
                    mirror = true
                return "image://theme/" + keyboard.iconReference[key.label] + "?"+keyboard.keyFgColor;
            }
            else
                return "";
        }
        transformOrigin: Item.Center
        visible: key.label != ":shift" || stickiness == 1
    }
    Image {
        id: capsImage
        anchors.centerIn: parent
        width: iconSize * 0.9
        height: iconSize * 0.9
        property real lop: key.labelOpacity
        opacity: lop * (stickiness == 0 ? 0.2 : 1)
        Behavior on opacity {
            FadeAnimation {}
        }
        source: "image://theme/icon-m-capslock?"+keyboard.keyFgColor
        visible: key.label == ":shift" && stickiness != 1
    }

    Column {
        visible: keyImage.source == "" || (key.label_alt != '' && key.shiftActive)
        anchors.centerIn: parent
        spacing: -17*window.pixelRatio

        Text {
            id: keyAltLabel
            property bool highlighted: key.shiftActive

            anchors.horizontalCenter: parent.horizontalCenter

            text: key.label_alt
            color: keyboard.keyFgColor

            opacity: keyImage.source == "" ? key.labelOpacity * (highlighted ? 1.0 : 0.5) : key.labelOpacity * (key.shiftActive ? 1 : 0)

            Behavior on opacity {
                FadeAnimation {}
            }

            font.pointSize: ((highlighted || keyImage.source != "") ? window.fontSizeLarge : window.fontSizeSmall) * (text.length > 1 ? 0.5 : 1.0)

            Behavior on font.pointSize {
                NumberAnimation { easing.type: Easing.InOutQuad }
            }
        }

        Text {
            id: keyLabel
            property bool highlighted: key.label_alt == '' || !key.shiftActive

            anchors.horizontalCenter: parent.horizontalCenter

            text: {
                if (key.label.length == 1 && key.label_alt == '') {
                    if (key.shiftActive) {
                        return key.label.toUpperCase();
                    } else {
                        return key.label.toLowerCase();
                    }
                }

                return key.label;
            }

            font.family: Theme.fontFamily

            color: keyboard.keyFgColor

            opacity: keyImage.source == "" ? key.labelOpacity * (highlighted ? 1.0 : 0.2) : 0

            Behavior on opacity {
                FadeAnimation {}
            }

            font.pointSize: ((highlighted && keyImage.source == "") ? window.fontSizeLarge : window.fontSizeSmall) * (text.length > 1 ? 0.5 : 1.0)

            Behavior on font.pointSize {
                NumberAnimation { easing.type: Easing.InOutQuad }
            }
        }
    }

    Text {
        id: spaceLayoutName
        color: keyboard.keyFgColor
        anchors.centerIn: parent
        text: util.settingsValue("ui/keyboardLayout").toUpperCase().substring(0, 3)
        font.family: Theme.fontFamily
        font.pointSize: window.fontSizeLarge * 0.75
        opacity: key.labelOpacity * 0.5
        Behavior on opacity {
            FadeAnimation {}
        }
        visible: key.code == 0x20 && keyLoader.availableLayouts().length > 1
    }

    Rectangle {
        id: stickIndicator
        visible: sticky && stickiness>0 && label != ":shift"
        color: keyboard.keyHilightBgColor
        anchors.fill: parent
        opacity: 0.75
        z: 1
        anchors.topMargin: key.height/2
    }

    function isAutoRepeatKey() {
        // Key values taken from qnamespace.h: https://qt.gitorious.org/qt/qt/source/src/corelib/global/qnamespace.h
        var Key_Left = 0x01000012;
        var Key_Up = 0x01000013;
        var Key_Right = 0x01000014;
        var Key_Down = 0x01000015;
        var Key_PageUp = 0x01000016;
        var Key_PageDown = 0x01000017;
        // Space key is used to switch languages
//      var Key_Space = 0x20;
        var Key_Backspace = 0x01000003;
        var Key_Return = 0x01000004;
        var Key_Delete = 0x01000007;

        return  code === Key_Left ||
                code === Key_Up ||
                code === Key_Right ||
                code === Key_Down ||
                code === Key_PageUp ||
                code === Key_PageDown ||
//              code === Key_Space ||
                code === Key_Backspace ||
                code === Key_Return ||
                code === Key_Delete
                ;
    }

    function handlePress(touchArea, x, y) {
        isClick = true;
        pressMouseX = x;
        pressMouseY = y;

        if (keyboard.active) {
            highlightedBackground.visible = true;
        }

        keyboard.currentKeyPressed = key;
        util.keyPressFeedback();

        if (isAutoRepeatKey()) {
            keyRepeatStarter.start();
        }

        if (sticky) {
            keyboard.keyModifiers |= code;
            key.becomesSticky = true;
            keyboard.currentStickyPressed = key;
        } else {
            if (keyboard.currentStickyPressed != null) {
                // Pressing a non-sticky key while a sticky key is pressed:
                // the sticky key will not become sticky when released
                keyboard.currentStickyPressed.becomesSticky = false;
            }
        }
    }

    function handleMove(touchArea, x, y) {
        var mappedPoint = key.mapFromItem(touchArea, x, y)
        if (!key.contains(Qt.point(mappedPoint.x, mappedPoint.y))) {
            key.handleRelease(touchArea, x, y);
            return false;
        }

        if (key.isClick) {
            if (Math.abs(x - key.pressMouseX) > key.clickThreshold ||
            Math.abs(y - key.pressMouseY) > key.clickThreshold )
            key.isClick = false
        }

        return true;
    }

    function handleRelease(touchArea, x, y, passKey) {
        keyRepeatStarter.stop();
        keyRepeatTimer.stop();
        highlightedBackground.visible = false;
        keyboard.currentKeyPressed = 0;

        if (sticky && !becomesSticky) {
            keyboard.keyModifiers &= ~code
            keyboard.currentStickyPressed = null;
        }

        if (vkb.keyAt(x, y) === key) {
            util.keyReleaseFeedback();

            if (key.sticky && key.becomesSticky) {
                setStickiness(-1);
            }

            if (!passKey) window.vkbKeypress(currentCode, keyboard.keyModifiers);

            // first non-sticky press will cause the sticky to be released
            if ( !sticky && keyboard.resetSticky != 0 && keyboard.resetSticky !== key ) {
                keyboard.resetSticky.setStickiness(0);
            }
        }
        else {
            // If user swiped out of a sticky key, cancel the stickiness
            if (sticky) {
                keyboard.keyModifiers &= ~code;
                key.becomesSticky = false;
                keyboard.currentStickyPressed = null;
            }
        }
    }

    Timer {
        id: keyRepeatStarter
        running: false
        repeat: false
        interval: 400
        triggeredOnStart: false
        onTriggered: {
            keyRepeatTimer.start();
        }
    }

    Timer {
        id: keyRepeatTimer
        running: false
        repeat: true
        triggeredOnStart: true
        interval: 80
        onTriggered: {
            window.vkbKeypress(currentCode, keyboard.keyModifiers);
        }
    }

    function setStickiness(val)
    {
        if(sticky) {
            if( keyboard.resetSticky && keyboard.resetSticky != 0 && keyboard.resetSticky !== key ) {
                keyboard.resetSticky.setStickiness(0);
            }

            if(val===-1)
                stickiness = (stickiness+1) % 3
            else
                stickiness = val

            // stickiness == 0 -> not pressed
            // stickiness == 1 -> release after next keypress
            // stickiness == 2 -> keep pressed

            if(stickiness>0) {
                keyboard.keyModifiers |= code
            } else {
                keyboard.keyModifiers &= ~code
            }

            keyboard.resetSticky = 0

            if(stickiness==1) {
                stickIndicator.anchors.topMargin = key.height/2
                keyboard.resetSticky = key
            } else if(stickiness==2) {
                stickIndicator.anchors.topMargin = 0
            }
        }
    }
}
