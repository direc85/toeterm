/*
    Copyright 2011-2012 Heikki Holstila <heikki.holstila@gmail.com>

    This file is part of FingerTerm.

    FingerTerm is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    FingerTerm is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FingerTerm.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: keyboard
    color: "transparent"

    width: parent.width
    height: childrenRect.height

    property int keyModifiers: 0
    property variant resetSticky: 0
    property variant currentStickyPressed: null
    property variant currentKeyPressed: 0

    property string keyFgColor: "#ffffff"
    property string keyHilightBgColor: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    property string backgroundColorActive: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity * 0.5)
    property string indicatorColor: Theme.highlightBackgroundColor

    property bool active: false

    property int keysPerRow: keyLoader.vkbColumns()
    property real keywidth: keyboard.width/keysPerRow;

    // icon hack
    property var iconReference: {
        ":backspace": "icon-m-backspace",
        ":down": "icon-m-down",
        ":enter": "icon-m-enter",
        ":left": "icon-m-left",
        ":right": "icon-m-right",
        ":shift": "icon-m-autocaps",
        ":tab": "icon-m-transfer",
        ":up": "icon-m-up",
        "pgdn": "icon-m-page-down",
        "pgup": "icon-m-page-up"
    }

    Component {
        id: keyboardContents
        Column {
            id: col
            x: (keyboard.width-width)/2
            Repeater {
                id: rowRepeater
                model: keyLoader.vkbRows()
                delegate: Row {
                    Repeater {
                        id: colRepeater
                        property int rowIndex: index
                        model: keyLoader.vkbColumns()
                        delegate: Key {
                            property variant keydata: keyLoader.keyAt(colRepeater.rowIndex, index)
                            label: keydata[0]
                            code: keydata[1]
                            label_alt: keydata[2]
                            code_alt: keydata[3]
                            width: keyboard.keywidth * keydata[4]
                            sticky: keydata[5]
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: keyboardLoader
    }

    Component.onCompleted: {
        keyboardLoader.sourceComponent = keyboardContents;
    }

    onCurrentKeyPressedChanged: {
        if(     currentKeyPressed && currentKeyPressed != 0 &&
                currentKeyPressed.currentLabel.length === 1 &&
                currentKeyPressed.currentLabel !== " " &&
                active) {
            visualKeyFeedbackRect.label = currentKeyPressed.currentLabel
            visualKeyFeedbackRect.width = currentKeyPressed.width*2
            visualKeyFeedbackRect.height = currentKeyPressed.height*2.5
            var mappedCoord = window.mapFromItem(currentKeyPressed, 0, 0);
            visualKeyFeedbackRect.x = mappedCoord.x - (visualKeyFeedbackRect.width-currentKeyPressed.width)/2
            visualKeyFeedbackRect.y = mappedCoord.y - currentKeyPressed.height*2.5
            visualKeyFeedbackRect.visible = true;
        } else {
            visualKeyFeedbackRect.visible = false;
        }
    }

    // Returns whether or not the provided key is a passive key,
    // i.e. a key that doesn't wake up the keyboard when pressed.
    function isPassiveKey (key) {
        // Key values taken from qnamespace.h: https://qt.gitorious.org/qt/qt/source/src/corelib/global/qnamespace.h
        var Key_Left = 0x01000012;
        var Key_Up = 0x01000013;
        var Key_Right = 0x01000014;
        var Key_Down = 0x01000015;
        var Key_PageUp = 0x01000016;
        var Key_PageDown = 0x01000017;
        var Key_Return = 0x1000004;
        var Key_Back = 0x1000003;
        return (key === Key_Left ||
                key === Key_Up ||
                key === Key_Right ||
                key === Key_Down ||
                key === Key_PageUp ||
                key === Key_PageDown ||
                key === Key_Return ||
                key === Key_Back
                );
    }

    function reloadLayout()
    {
        resetSticky = 0;
        keyModifiers = 0;
        var ret = keyLoader.loadLayout(util.settingsValue("ui/keyboardLayout"));
        if (!ret) {
            window.showErrorMessage("There was an error loading the keyboard layout. Using the default one instead.");
            util.setSettingsValue("ui/keyboardLayout", "english");
            ret = keyLoader.loadLayout(":/data/english.layout"); //try the default as a fallback (load from resources to ensure it will succeed)
            if (!ret) {
                console.log("keyboard layout fail");
                Qt.quit();
            }
        }
        // makes the keyboard component reload itself with new data
        keyboardLoader.sourceComponent = undefined
        keyboardLoader.sourceComponent = keyboardContents
        updateWidth()
    }

    onWidthChanged: updateWidth()

    function updateWidth() {
        keysPerRow = keyLoader.vkbColumns()
        keywidth = keyboard.width/keysPerRow;
    }

    //borrowed from nemo-keyboard
    //Parameters: (x, y) in view coordinates
    function keyAt(x, y) {
        var item = keyboard
        x -= keyboard.x
        y -= keyboard.y

        while ((item = item.childAt(x, y)) != null) {
            //return the first "Key" element we find
            if (typeof item.currentCode !== 'undefined') {
                return item
            }

            // Cheaper mapToItem, assuming we're not using anything fancy.
            x -= item.x
            y -= item.y
        }

        return null
    }

    function nextLayout() {
        var layoutName = getLayoutNameAtPos(-1);
        util.setSettingsValue("ui/keyboardLayout", layoutName);
        vkb.reloadLayout();
        layoutName = layoutName.charAt(0).toUpperCase() + layoutName.slice(1);
        util.notifyText(layoutName);
    }

    function prevLayout() {
        var layoutName = getLayoutNameAtPos(1);
        util.setSettingsValue("ui/keyboardLayout", layoutName);
        vkb.reloadLayout();
        layoutName = layoutName.charAt(0).toUpperCase() + layoutName.slice(1);
        util.notifyText(layoutName);
    }

    function getLayoutNameAtPos(pos) {
        var layoutsList = keyLoader.availableLayouts();
        var layoutIndex = layoutsList.indexOf(util.settingsValue("ui/keyboardLayout")) + pos;
        if (layoutIndex < 0) {
            layoutIndex = layoutsList.length - 1;
        } else if (layoutIndex >= layoutsList.length) {
            layoutIndex = 0;
        }
        return layoutsList[layoutIndex];
    }
}
