TARGET = toeterm
CONFIG += sailfishapp link_pkgconfig
PKGCONFIG += sailfishapp nemonotifications-qt5
LIBS += -lutil

VER = 1.9.6
REL = 1

VERSION = $${VER}-$${REL}
$$system(bash update-spec-version.sh $$TARGET $$VER $$REL)
DEFINES += APP_VERSION=\"\\\"$$VERSION\\\"\"
DEFINES += APP_NAME=\"\\\"$$TARGET\\\"\"

QT += feedback

HEADERS += \
    src/ptyiface.h \
    src/terminal.h \
    src/textrender.h \
    src/util.h \
    src/keyloader.h

SOURCES += \
    src/main.cpp \
    src/terminal.cpp \
    src/textrender.cpp \
    src/ptyiface.cpp \
    src/util.cpp \
    src/keyloader.cpp

OTHER_FILES += qml/*

RESOURCES += \
    resources.qrc

target.path = /usr/bin

images.files = images
images.path = /usr/share/$${TARGET}

INSTALLS += target images

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n

TRANSLATIONS += \
    translations/toeterm-es.ts \
    translations/toeterm-fi_FI.ts \
    translations/toeterm-nl.ts \
    translations/toeterm-nl_BE.ts \
    translations/toeterm-pl_PL.ts \
    translations/toeterm-ru.ts \
    translations/toeterm-sv.ts \
    translations/toeterm-zh_CN.ts

DISTFILES += \
    translations/toeterm-es.ts \
    translations/toeterm-fi_FI.ts \
    translations/toeterm-nl.ts \
    translations/toeterm-nl_BE.ts \
    translations/toeterm-pl_PL.ts \
    translations/toeterm-ru.ts \
    translations/toeterm-sv.ts \
    translations/toeterm-zh_CN.ts \
    rpm/toeterm.changes \
    rpm/toeterm.yaml \
    rpm/toeterm.spec
