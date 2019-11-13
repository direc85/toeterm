/*
    ThumbTerm Copyright Olli Vanhoja
    FingerTerm Copyright 2011-2012 Heikki Holstila <heikki.holstila@gmail.com>
    ToeTerm Copyright R-033, 2019 Matti Viljanen

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
*/#ifndef TEXTRENDER_H
#define TEXTRENDER_H

#include <QQuickPaintedItem>
#include <QPainter>

#include "terminal.h"

class Util;

class TextRender : public QQuickPaintedItem
{
    Q_PROPERTY(int myWidth READ myWidth WRITE setMyWidth NOTIFY myWidthChanged)
    Q_PROPERTY(int myHeight READ myHeight WRITE setMyHeight NOTIFY myHeightChanged)
    Q_PROPERTY(int fontWidth READ fontWidth NOTIFY fontSizeChanged)
    Q_PROPERTY(int fontHeight READ fontHeight NOTIFY fontSizeChanged)
    Q_PROPERTY(int fontPointSize READ fontPointSize WRITE setFontPointSize NOTIFY fontSizeChanged)
    Q_PROPERTY(bool showBufferScrollIndicator READ showBufferScrollIndicator WRITE setShowBufferScrollIndicator NOTIFY showBufferScrollIndicatorChanged)

    Q_OBJECT
public:
    explicit TextRender(QQuickItem *parent = 0);
    virtual ~TextRender();
    void paint(QPainter*);

    void setTerminal(Terminal* term);
    void setUtil(Util* util) { iUtil = util; }

    int myWidth() { return iWidth; }
    int myHeight() { return iHeight; }
    void setMyWidth(int w) { if(iWidth!=w) { iWidth=w; emit myWidthChanged(w); } }
    void setMyHeight(int h) { if(iHeight!=h) { iHeight=h; emit myHeightChanged(h); } }
    float fontWidth() { return iFontWidth; }
    float fontHeight() { return iFontHeight; }
    float fontDescent() { return iFontDescent; }
    float fontAscent() { return iFontAscent; }
    float fontPointSize() { return iFont.pointSize(); }
    void setFontPointSize(int psize);
    bool showBufferScrollIndicator() { return iShowBufferScrollIndicator; }
    void setShowBufferScrollIndicator(bool s) { if(iShowBufferScrollIndicator!=s) { iShowBufferScrollIndicator=s; emit showBufferScrollIndicatorChanged(); } }

    Q_INVOKABLE QPoint cursorPixelPos();
    Q_INVOKABLE QSize cursorPixelSize();

    QColor qColorFromHex(QString hex);
    void updatePalette();
    Q_INVOKABLE void loadColorScheme(QString layoutName);
    Q_INVOKABLE QString getColor(QString name);
    Q_INVOKABLE QFont getFont();

signals:
    void myWidthChanged(int newWidth);
    void myHeightChanged(int newHeight);
    void fontSizeChanged();
    void showBufferScrollIndicatorChanged();

public slots:
    void redraw();
    void updateTermSize();

private:
    Q_DISABLE_COPY(TextRender)

    void paintFromBuffer(QPainter* painter, QList<QList<TermChar> >& buffer, int from, int to, int &y);
    void drawBgFragment(QPainter* painter, float x, float y, float width, TermChar style);
    void drawTextFragment(QPainter* painter, float x, float y, QString text, TermChar style);
    QPoint charsToPixels(QPoint pos);

    int iWidth;
    int iHeight;
    QFont iFont;
    float iFontWidth;
    float iFontHeight;
    float iFontDescent;
    float iFontAscent;
    bool iShowBufferScrollIndicator;

    Terminal *iTerm;
    Util *iUtil;

    QList<QColor> iColorTable;

    QSettings *colorScheme;
};

#endif // TEXTRENDER_H
