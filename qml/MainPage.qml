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
import TextRender 1.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

Page {
    id: page
    property Item windowItem: window
    property Item textRenderItem: textrender
    property Item lineViewItem: lineView
    property Item keyboardItem: vkb
    allowedOrientations: Orientation.All
    property bool settingsActionsOpened: false
    property bool settingsUrlsOpened: false
    property bool settingsLayoutsOpened: false
    property bool settingsColorsOpened: false
    property bool settingsSettingsOpened: false
    property Item bgDrawItem: bgDraw
    property Timer bgTimerItem: bgColorTimer
    property string settingsPagePath: Qt.resolvedUrl("SettingsMenu.qml")

    onStatusChanged: {
        if(status === PageStatus.Active) {
            allowedOrientations = (parseInt(util.settingsValue("ui/allowedOrientations")) & Orientation.All)
            lineView.anchorToTop = util.settingsValueBool("ui/dockLineviewToTop")
            fadeTimer.interval = util.settingsValue("ui/keyboardFadeOutDelay")
        }
    }

    Rectangle {
        property int fontSize: 14*pixelRatio

        property int fadeOutTime: 80
        property int fadeInTime: 350
        property real pixelRatio: appWindow.width / 540

        // layout constants
        property int buttonWidthSmall: 60*pixelRatio
        property int buttonWidthLarge: 180*pixelRatio
        property int buttonWidthHalf: 90*pixelRatio

        property int buttonHeightSmall: 48*pixelRatio
        property int buttonHeightLarge: 68*pixelRatio

        property int headerHeight: 20*pixelRatio

        property int radiusSmall: 5*pixelRatio
        property int radiusMedium: 10*pixelRatio
        property int radiusLarge: 15*pixelRatio

        property int paddingSmall: 5*pixelRatio
        property int paddingMedium: 10*pixelRatio

        property int fontSizeSmall: 14*pixelRatio
        property int fontSizeLarge: 24*pixelRatio

        property int uiFontSize: util.uiFontSize()*pixelRatio

        property int scrollBarWidth: 6*pixelRatio

        anchors.fill: parent

        id: window
        objectName: "window"

        color: "transparent"

        property string hcolor: Theme.highlightColor

        Rectangle {
            id: bgDraw
            anchors.fill: parent
            visible: false
            z: 0
        }

        Timer {
            id: bgColorTimer
            running: true
            repeat: false
            interval: 0
            onTriggered: {
                bgDraw.color = "#" + textrender.getColor("colors/bgColor");
                bgDraw.visible = util.settingsValueBool("ui/showBackground");
                if (util.settingsValueBool("ui/showBackground")) {
                    vkb.backgroundColorActive = Theme.rgba("#" + textrender.getColor("colors/vkbBgColor"), Theme.highlightBackgroundOpacity * 1.5);
                    vkb.keyHilightBgColor = Theme.rgba("#" + textrender.getColor("colors/vkbBgColor"), Theme.highlightBackgroundOpacity * 2.25);
                    vkb.indicatorColor = "#" + textrender.getColor("colors/vkbBgColor")
                    lineView.color = Theme.rgba("#" + textrender.getColor("colors/vkbBgColor"), Theme.highlightBackgroundOpacity * 1.5);
                    lineView.fgColor = "#" + textrender.getColor("colors/fgColor");
                } else {
                    vkb.backgroundColorActive = Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity * 0.5);
                    vkb.keyHilightBgColor = Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity);
                    vkb.indicatorColor = Theme.highlightBackgroundColor
                    lineView.color = Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity * 0.5);
                    lineView.fgColor = "#ffffff";
                }
            }
        }

        Image {
            // terminal buffer scroll indicator
            source: "image://theme/icon-m-enter-close"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            visible: textrender.showBufferScrollIndicator
            z: 5
        }

        Rectangle {
            // bell
            id: bellBg
            anchors.fill: parent
            color: "white"
            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: 80; easing.type: Easing.InOutQuad }
            }
            z: 1
        }

        TextRender {
            id: textrender
            objectName: "textrender"
            x: 0
            y: 0
            height: parent.height
            width: parent.width
            myWidth: width
            myHeight: height
            opacity: 1.0
            property int duration: 0;
            property int cutAfter: height

            Behavior on opacity {
                NumberAnimation { duration: textrender.duration; easing.type: Easing.InOutQuad }
            }

            Behavior on y {
                NumberAnimation { duration: textrender.duration; easing.type: Easing.InOutQuad }
            }

            onFontSizeChanged: {
                lineView.fontPointSize = textrender.fontPointSize;
            }

            onCutAfterChanged: {
                // this property is used in the paint function, so make sure that the element gets
                // painted with the updated value (might not otherwise happen because of caching)
                textrender.redraw();
            }

            z: 10
        }

        Timer {
            id: fadeTimer
            running: false
            repeat: false
            interval: util.settingsValue("ui/keyboardFadeOutDelay")
            onTriggered: {
                window.sleepVKB();
            }
        }

        Timer {
            id: bellTimer
            running: false
            repeat: false
            interval: 80
            onTriggered: {
                bellBg.opacity = 0
            }
        }

        Connections {
            target: util
            onVisualBell: {
                window.visualBell();
            }
            onGestureNotify: {
                textNotify.text = msg;
                textNotifyAnim.enabled = false;
                textNotify.opacity = 1.0;
                textNotifyAnim.enabled = true;
                textNotify.opacity = 0;
            }
            onWindowTitleChanged: {
                appWindow.windowTitle = util.currentWindowTitle()
            }
        }

        function vkbKeypress(key,modifiers) {

            // If the user pressed an arrow key, the Page Up / Page Down key or the space key,
            // process the key press normally but don't wake the keyboard (to make
            // it easier to navigate through long documents without having the keyboard
            // constantly pop-up).
            if (vkb.active || !vkb.isPassiveKey(key))
                wakeVKB();
            term.keyPress(key,modifiers);
        }

        function wakeVKB()
        {
            if(!vkb.visibleSetting)
                return;

            lineView.duration = window.fadeOutTime;
            textrender.duration = window.fadeOutTime;

            if (util.settingsValue("ui/keyboardFadeOutDelay") > 0)
            {
                fadeTimer.restart();
            }

            vkb.active = true;
            lineView.setVisibility(vkb.active);
            util.updateSwipeLock(!vkb.active);
            setTextRenderAttributes();
            updateGesturesAllowed();
        }

        function sleepVKB()
        {
            textrender.duration = window.fadeInTime;
            lineView.duration = window.fadeInTime;
            vkb.active = false;
            lineView.setVisibility(vkb.active);
            util.updateSwipeLock(!vkb.active);
            setTextRenderAttributes();
            updateGesturesAllowed();
        }

        function setTextRenderAttributes()
        {
            if(util.settingsValue("ui/vkbShowMethod")==="move")
            {
                vkb.visibleSetting = true;
                textrender.opacity = 1.0;
                if(vkb.active) {
                    var move = textrender.cursorPixelPos().y + textrender.fontHeight/2 + textrender.fontHeight;//*util.settingsValue("ui/showExtraLinesFromCursor");
                    if(move < vkb.y) {
                        textrender.y = 0;
                        textrender.cutAfter = vkb.y;
                    } else {
                        textrender.y = 0 - move + vkb.y
                        textrender.cutAfter = move;
                    }
                } else {
                    textrender.cutAfter = textrender.height;
                    textrender.y = 0;
                }
            }
            else if(util.settingsValue("ui/vkbShowMethod")==="fade")
            {
                vkb.visibleSetting = true;
                textrender.cutAfter = textrender.height;
                textrender.y = 0;
                if(vkb.active)
                    textrender.opacity = 0.5;
                else
                    textrender.opacity = 1.0;
            }
            else // "off" (vkb disabled)
            {
                vkb.visibleSetting = false;
                textrender.cutAfter = textrender.height;
                textrender.y = 0;
                textrender.opacity = 1.0;
            }
        }

        function displayBufferChanged()
        {
            lineView.lines = term.printableLinesFromCursor(util.settingsValue("ui/showExtraLinesFromCursor"), false);
            appWindow.lines = term.printableLinesFromCursor(30, true);
            lineView.cursorX = textrender.cursorPixelPos().x;
            lineView.cursorWidth = textrender.cursorPixelSize().width;
            lineView.cursorHeight = textrender.cursorPixelSize().height;
            setTextRenderAttributes();
        }

        Component.onCompleted: {
            util.updateSwipeLock(vkb.active);
        }

        Notification {
                 id: errorNotification
                 summary: qsTr("An error occurred")
        }

        function showErrorMessage(string)
        {
            errorNotification.body = string;
            errorNotification.publish()
        }

        function visualBell()
        {
            bellBg.opacity = 0.1;
            bellTimer.start();
        }

        function updateGesturesAllowed()
        {
            if(vkb.active)
                util.allowGestures = false;
            else
                util.allowGestures = true;
        }

        function lockModeStringToQtEnum(stringMode) {
            switch (stringMode) {
            case "auto":
                return Orientation.Automatic
            case "landscape":
                return Orientation.LockLandscape
            case "portrait":
                return Orientation.LockPortrait
            }
        }

        function getOrientationLockMode()
        {
            var stringMode = util.settingsValue("ui/orientationLockMode");
            page.orientation = lockModeStringToQtEnum(stringMode)
        }

        function setOrientationLockMode(mode_) {
            util.setSettingsValue("ui/orientationLockMode", mode_);
            page.orientation = lockModeStringToQtEnum(mode_)
        }
    }

    Text {
        // shows large text notification in the middle of the screen (for gestures)
        id: textNotify
        anchors.centerIn: parent
        color: Theme.highlightColor
        z: 100
        opacity: 0
        text: ""
        font.pointSize: 40*window.pixelRatio
        Behavior on opacity {
            id: textNotifyAnim
            NumberAnimation { duration: 500; }
        }
    }

    Rectangle {
        // visual key press feedback...
        // easier to work with the coordinates if it's here and not under keyboard element
        id: visualKeyFeedbackRect
        visible: false
        x: 0
        y: 0
        z: 200
        width: 0
        height: 0
        radius: 5
        color: vkb.indicatorColor
        property string label: ""
        Text {
            color: "#FFFFFF"
            font.pointSize: 64*window.pixelRatio
            anchors.centerIn: parent
            text: visualKeyFeedbackRect.label
        }
    }

    Lineview {
        id: lineView

        states: [
            State {
                name: 'landscape';
                when: lineView.anchorToTop === false
                AnchorChanges {
                    target: lineView
                    anchors.top: undefined
                    anchors.bottom: vkb.top
                }
            }
        ]

        property bool anchorToTop: true
        anchors.top: parent.top
        anchors.topMargin: undefined
        z: 20
        property int duration: 0;
        onFontPointSizeChanged: lineView.setVisibility(vkb.active)
    }

    Keyboard {
        id: vkb
        property bool visibleSetting: true
        x: 0
        y: parent.height-vkb.height
        visible: visibleSetting
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    function showLayoutSwitcher(key) {
        visualKeyFeedbackRect.width = key.width*2
        visualKeyFeedbackRect.height = key.height*2.5
        var mappedCoord = window.mapFromItem(key, 0, 0);
        visualKeyFeedbackRect.x = mappedCoord.x - (visualKeyFeedbackRect.width-key.width)/2
        visualKeyFeedbackRect.y = mappedCoord.y - key.height*2.5
        visualKeyFeedbackRect.visible = true;
    }

    function setLayoutSwitcherText(kbdl) {
        kbdl = kbdl.charAt(0).toUpperCase() + kbdl.slice(1)
        visualKeyFeedbackRect.label = kbdl
        window.wakeVKB();
    }

    // area that handles gestures/select/scroll modes and vkb-keypresses
    MultiPointTouchArea {
        id: multiTouchArea
        anchors.fill: parent
        property int firstTouchId: -1
        property var pressedKeys: ({})
        property real spaceXswipe;
        property bool spacePressed: false;
        onPressed: {
            touchPoints.forEach(function (touchPoint) {
                var t_y = touchPoint.y + y;
                if (multiTouchArea.firstTouchId == -1) {
                    multiTouchArea.firstTouchId = touchPoint.pointId;

                    //gestures c++ handler
                    util.mousePress(touchPoint.x, t_y);
                }

                var key = vkb.keyAt(touchPoint.x, t_y);
                if (key !== null) {
                    key.handlePress(multiTouchArea, touchPoint.x, t_y);
                    if (key.code === 0x20) {
                        spaceXswipe = touchPoint.x;
                        spacePressed = true;
                    }
                }
                multiTouchArea.pressedKeys[touchPoint.pointId] = key;
            });
        }
        onUpdated: {
            touchPoints.forEach(function (touchPoint) {
                var t_y = touchPoint.y + y;
                if (multiTouchArea.firstTouchId === touchPoint.pointId) {
                    //gestures c++ handler
                    util.mouseMove(touchPoint.x, t_y);
                }

                var key = multiTouchArea.pressedKeys[touchPoint.pointId];
                if (key !== null) {
                    if (!key.handleMove(multiTouchArea, touchPoint.x, t_y)) {
                        // This means that the user swiped out of the current key.
                        // Find the new key in that position and make it the currently
                        // highlighted key.
                        key = vkb.keyAt(touchPoint.x, t_y);
                        if (key !== null) {
                            if (!spacePressed) {
                                key.handlePress(multiTouchArea, touchPoint.x, t_y);
                            } else if (keyLoader.availableLayouts().length > 1) {
                                 if (Math.abs(spaceXswipe - touchPoint.x) > 50) {
                                    if (!visualKeyFeedbackRect.visible) {
                                        showLayoutSwitcher(multiTouchArea.pressedKeys[touchPoint.pointId]);
                                    }
                                    setLayoutSwitcherText(vkb.getLayoutNameAtPos(spaceXswipe < touchPoint.x - 50 ? -1 : 1));
                                } else {
                                    setLayoutSwitcherText(util.settingsValue("ui/keyboardLayout"));
                                }
                            }
                        }
                        delete multiTouchArea.pressedKeys[touchPoint.pointId];
                        multiTouchArea.pressedKeys[touchPoint.pointId] = key;
                    }
                }
            });
        }
        onReleased: {
            touchPoints.forEach(function (touchPoint) {
                var t_y = touchPoint.y + y;
                var t_y2 = touchPoint.startY + y;
                if (multiTouchArea.firstTouchId === touchPoint.pointId) {
                    // Toggle keyboard wake-up when tapping outside the keyboard, but:
                    //   - only when not scrolling (y-diff < 20 pixels)
                    //   - not in select mode, as it would be hard to select text
                    if (t_y < vkb.y && t_y2 < vkb.y &&
                            Math.abs(t_y - t_y2) < 20) {
                        if (vkb.active) {
                            window.sleepVKB();
                        } else if (util.settingsValue("ui/dragMode") !== "select") {
                            window.wakeVKB();
                        }
                    }

                    //gestures c++ handler
                    util.mouseRelease(touchPoint.x, t_y);
                    multiTouchArea.firstTouchId = -1;
                }

                var key = multiTouchArea.pressedKeys[touchPoint.pointId];
                if (key !== null) {
                    if (spacePressed) {
                        if (keyLoader.availableLayouts().length > 1) {
                            if (spaceXswipe < touchPoint.x - 50) {
                                vkb.nextLayout();
                            } else if (spaceXswipe > touchPoint.x + 50) {
                                vkb.prevLayout();
                            }
                        }
                        key.handleRelease(multiTouchArea, touchPoint.x, t_y, Math.abs(spaceXswipe - touchPoint.x) > 50);
                        spacePressed = false;
                        visualKeyFeedbackRect.visible = false;
                    } else key.handleRelease(multiTouchArea, touchPoint.x, t_y);
                }
                delete multiTouchArea.pressedKeys[touchPoint.pointId];
            });
        }
    }
    TextSwitch {
        checked: true
        x: parent.width - width/3.5
        y: Theme.paddingMedium
        width: Theme.iconSizeExtraLarge
        height: Theme.iconSizeExtraLarge
        onCheckedChanged: {
            if(checked === false)
                pageStack.push(settingsPagePath)
            checked = true
        }
        z: 100
    }
}
