
TEMPLATE = app
CONFIG += qt
CONFIG += static
QT += widgets

SOURCES += main.cpp

HEADERS += mainwindow.h
SOURCES += mainwindow.cpp

INCLUDEPATH += $$PWD

RESOURCES += fonts.qrc
RESOURCES += qtapp.qrc

LIBS += -static
