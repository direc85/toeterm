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

#include <sailfishapp.h>

#include "qplatformdefs.h"

#include <QtGui>
#include <QtQml>
#include <QGuiApplication>
#include <QQuickView>

extern "C" {
#include <pty.h>
#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <sys/types.h>
}

#include "ptyiface.h"
#include "terminal.h"
#include "textrender.h"
#include "util.h"
#include "keyloader.h"

void defaultSettings(QSettings* settings);
void copyFileFromResources(QString from, QString to);

int main(int argc, char *argv[])
{
    QSettings *settings = new QSettings(QDir::homePath()+"/.config/ToeTerm/settings.ini", QSettings::IniFormat);
    defaultSettings(settings);

    // fork the child process before creating QGuiApplication
    int socketM;
    int pid = forkpty(&socketM,NULL,NULL,NULL);
    if( pid==-1 ) {
        qFatal("forkpty failed");
        exit(1);
    } else if( pid==0 ) {
        setenv("TERM", settings->value("terminal/envVarTERM").toByteArray(), 1);

        QString execCmd;
        for(int i=0; i<argc-1; i++) {
            if( QString(argv[i]) == "-e" )
                execCmd = QString(argv[i+1]);
        }
        if(execCmd.isEmpty()) {
            execCmd = settings->value("gen/execCmd").toString();
        }
        if(execCmd.isEmpty()) {
            // Unset POSIXLY_CORRECT as having it set causes bash to start in POSIX mode (http://www.delorie.com/gnu/docs/bash/bashref_62.html#IDX214)
            // which causes it to not read the .bashrc on startup (http://lists.gnu.org/archive/html/bug-bash/2001-10/msg00117.html)
            unsetenv("POSIXLY_CORRECT");

            // execute the user's default shell
            passwd *pwdstruct = getpwuid(getuid());
            execCmd = QString(pwdstruct->pw_shell);
            execCmd.append(" --login");
        }

        if(settings)
            delete settings; // don't need 'em here

        QStringList execParts = execCmd.split(' ', QString::SkipEmptyParts);
        if(execParts.length()==0)
            exit(0);
        char *ptrs[execParts.length()+1];
        for(int i=0; i<execParts.length(); i++) {
            ptrs[i] = new char[execParts.at(i).toLatin1().length()+1];
            memcpy(ptrs[i], execParts.at(i).toLatin1().data(), execParts.at(i).toLatin1().length());
            ptrs[i][execParts.at(i).toLatin1().length()] = 0;
        }
        ptrs[execParts.length()] = 0;

        execvp(execParts.first().toLatin1(), ptrs);
        exit(0);
    }

    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();

    QQuickWindow::setDefaultAlphaBuffer(true);

    QScreen* sc = app->primaryScreen();
    if(sc){
    sc->setOrientationUpdateMask(Qt::PrimaryOrientation
                                 | Qt::LandscapeOrientation
                                 | Qt::PortraitOrientation
                                 | Qt::InvertedLandscapeOrientation
                                 | Qt::InvertedPortraitOrientation);
    }

    qmlRegisterType<TextRender>("TextRender",1,0,"TextRender");

    Terminal term;
    Util util(settings);
    term.setUtil(&util);
    QString startupErrorMsg;

    // copy the default config files to the config dir if they don't already exist
    copyFileFromResources(":/data/menu.xml", util.configPath()+"/menu.xml");
    copyFileFromResources(":/data/english.layout", util.configPath()+"/english.layout");
    copyFileFromResources(":/data/russian.layout", util.configPath()+"/russian.layout");
    copyFileFromResources(":/data/finnish.layout", util.configPath()+"/finnish.layout");
    copyFileFromResources(":/data/french.layout", util.configPath()+"/french.layout");
    copyFileFromResources(":/data/german.layout", util.configPath()+"/german.layout");
    copyFileFromResources(":/data/qwertz.layout", util.configPath()+"/qwertz.layout");
    copyFileFromResources(":/data/english_extra.layout", util.configPath()+"/english_extra.layout");
    copyFileFromResources(":/data/Default.colors", util.configPath()+"/Default.colors");
    copyFileFromResources(":/data/Solarized_Dark.colors", util.configPath()+"/Solarized_Dark.colors");
    copyFileFromResources(":/data/Solarized_Dark_Alternative.colors", util.configPath()+"/Solarized_Dark_Alternative.colors");
    copyFileFromResources(":/data/Solarized_Light.colors", util.configPath()+"/Solarized_Light.colors");

    KeyLoader keyLoader;
    keyLoader.setUtil(&util);
    bool ret = keyLoader.loadLayout( settings->value("ui/keyboardLayout").toString() );
    if(!ret) {
        // on failure, try to load the default one (english) directly from resources
        startupErrorMsg = "There was an error loading the keyboard layout. Using the default one instead.";
        settings->setValue("ui/keyboardLayout", "english");
        ret = keyLoader.loadLayout(":/data/english.layout");
        if(!ret)
            qFatal("failure loading keyboard layout");
    }

    keyLoader.getAvailableLayouts();
    keyLoader.loadDisabledLayouts();

    QQmlContext *context = view->rootContext();
    context->setContextProperty( "term", &term );
    context->setContextProperty( "util", &util );
    context->setContextProperty( "keyLoader", &keyLoader );

    view->setSource(QUrl("qrc:/qml/Main.qml"));

    QObject *root = view->rootObject();
    if(!root)
        qFatal("no root object - qml error");

    QObject* win = root->findChild<QObject*>("window");

    if(!startupErrorMsg.isEmpty())
        QMetaObject::invokeMethod(win, "showErrorMessage", Qt::QueuedConnection, Q_ARG(QVariant, startupErrorMsg));

    TextRender *tr = root->findChild<TextRender*>("textrender");
    tr->setUtil(&util);
    tr->setTerminal(&term);
    term.setRenderer(tr);
    util.setTerm(&term);
    util.setRenderer(tr);

    tr->loadColorScheme(settings->value("ui/colorScheme").toString());

    QObject::connect(&term,SIGNAL(displayBufferChanged()),win,SLOT(displayBufferChanged()));
    QObject::connect(view->engine(),SIGNAL(quit()),app,SLOT(quit()));

    PtyIFace ptyiface(pid, socketM, &term,
                       settings->value("terminal/charset").toString());

    if( ptyiface.failed() )
        qFatal("pty failure");

    context->setContextProperty( "ptyiface", &ptyiface );

    view->showFullScreen();

    util.updateSwipeLock(false);
    util.updateSwipeLock(true);

    return app->exec();
}

void defaultSettings(QSettings* settings)
{
    if(!settings->contains("gen/execCmd"))
        settings->setValue("gen/execCmd", "");
    if(!settings->contains("gen/visualBell"))
        settings->setValue("gen/visualBell", true);
    if(!settings->contains("gen/backgroundBellNotify"))
        settings->setValue("gen/backgroundBellNotify", true);
    if(!settings->contains("gen/grabUrlsFromBackbuffer"))
        settings->setValue("gen/grabUrlsFromBackbuffer", false);

    if(!settings->contains("terminal/envVarTERM"))
        settings->setValue("terminal/envVarTERM", "xterm-256color");
    if(!settings->contains("terminal/charset"))
        settings->setValue("terminal/charset", "UTF-8");

    if(!settings->contains("ui/keyboardLayout"))
        settings->setValue("ui/keyboardLayout", "english");
    if(!settings->contains("ui/disabledKeyboardLayouts"))
        settings->setValue("ui/disabledKeyboardLayouts", "");
    if(!settings->contains("ui/fontFamily"))
        settings->setValue("ui/fontFamily", "monospace");
    if(!settings->contains("ui/fontSize"))
        settings->setValue("ui/fontSize", 11);
    if(!settings->contains("ui/maxFontSize"))
        settings->setValue("ui/maxFontSize", 35);
    if(!settings->contains("ui/showBackground"))
        settings->setValue("ui/showBackground", false);
    if(!settings->contains("ui/colorScheme"))
        settings->setValue("ui/colorScheme", "Default");
    if(!settings->contains("ui/allowSwipe"))
        settings->setValue("ui/allowSwipe", "auto");   // "true", "false", "auto"
    if(!settings->contains("ui/keyboardFadeOutDelay"))
        settings->setValue("ui/keyboardFadeOutDelay", 4000);
    if(!settings->contains("ui/showExtraLinesFromCursor"))
        settings->setValue("ui/showExtraLinesFromCursor", 2);
    if(!settings->contains("ui/dockLineviewToTop"))
        settings->setValue("ui/dockLineviewToTop", false);
    if(!settings->contains("ui/allowedOrientations"))
        settings->setValue("ui/allowedOrientations", 15); // Orientation.All
    if(!settings->contains("ui/vkbShowMethod"))
        settings->setValue("ui/vkbShowMethod", "move");  // "fade", "move", "off"
    if(!settings->contains("ui/keyPressFeedback"))
        settings->setValue("ui/keyPressFeedback", true);
    if(!settings->contains("ui/dragMode"))
        settings->setValue("ui/dragMode", "scroll");  // "gestures, "scroll", "select" ("off" would also be ok)
    if(!settings->contains("ui/specialKeys"))
        settings->setValue("ui/specialKeys", false);

    if(!settings->contains("state/createdByVersion"))
        settings->setValue("state/createdByVersion", "1.6");

    if(!settings->contains("gestures/panLeftTitle"))
        settings->setValue("gestures/panLeftTitle", "Alt-Right");
    if(!settings->contains("gestures/panLeftCommand"))
        settings->setValue("gestures/panLeftCommand", "\\e\\e[C");
    if(!settings->contains("gestures/panRightTitle"))
        settings->setValue("gestures/panRightTitle", "Alt-Left");
    if(!settings->contains("gestures/panRightCommand"))
        settings->setValue("gestures/panRightCommand", "\\e\\e[D");
    if(!settings->contains("gestures/panUpTitle"))
        settings->setValue("gestures/panUpTitle", "Page Down");
    if(!settings->contains("gestures/panUpCommand"))
        settings->setValue("gestures/panUpCommand", "\\e[6~");
    if(!settings->contains("gestures/panDownTitle"))
        settings->setValue("gestures/panDownTitle", "Page Up");
    if(!settings->contains("gestures/panDownCommand"))
        settings->setValue("gestures/panDownCommand", "\\e[5~");
}

void copyFileFromResources(QString from, QString to)
{
    // copy a file from resources to the config dir if it does not exist there
    QFileInfo toFile(to);
    if(!toFile.exists()) {
        QFile newToFile(toFile.absoluteFilePath());
        QResource res(from);
        if (newToFile.open(QIODevice::WriteOnly)) {
            newToFile.write( reinterpret_cast<const char*>(res.data()) );
            newToFile.close();
        } else {
            qFatal("failed to copy default config from resources");
        }
    }
}
