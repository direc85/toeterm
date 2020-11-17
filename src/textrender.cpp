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

#include <QtGui>
#include "textrender.h"
#include "terminal.h"
#include "util.h"

#include <QDebug>

TextRender::TextRender(QQuickItem *parent) :
    QQuickPaintedItem(parent),
    iTerm(0),
    iUtil(0)
{
    setFlag(ItemHasContents);
    connect(this,SIGNAL(myWidthChanged(int)),this,SLOT(updateTermSize()));
    connect(this,SIGNAL(myHeightChanged(int)),this,SLOT(updateTermSize()));
    connect(this,SIGNAL(fontSizeChanged()),this,SLOT(updateTermSize()));
    iShowBufferScrollIndicator = false;
}

void TextRender::loadColorScheme(QString layoutName) {
    colorScheme = new QSettings(QDir::homePath()+"/.config/ToeTerm/" + layoutName + ".colors", QSettings::IniFormat);
    if(!colorScheme->contains("colors/bgColor"))
        colorScheme->setValue("colors/bgColor", "000000");
    if(!colorScheme->contains("colors/bdColor"))
        colorScheme->setValue("colors/bdColor", "FFFFFF");
    if(!colorScheme->contains("colors/fgColor"))
        colorScheme->setValue("colors/fgColor", "D2D2D2");
    if(!colorScheme->contains("colors/vkbBgColor"))
        colorScheme->setValue("colors/vkbBgColor", "404040");
    if(!colorScheme->contains("paletteNormal/black"))
        colorScheme->setValue("paletteNormal/black", "000000");
    if(!colorScheme->contains("paletteNormal/red"))
        colorScheme->setValue("paletteNormal/red", "D20000");
    if(!colorScheme->contains("paletteNormal/green"))
        colorScheme->setValue("paletteNormal/green", "00D200");
    if(!colorScheme->contains("paletteNormal/yellow"))
        colorScheme->setValue("paletteNormal/yellow", "D2D200");
    if(!colorScheme->contains("paletteNormal/blue"))
        colorScheme->setValue("paletteNormal/blue", "0000D2");
    if(!colorScheme->contains("paletteNormal/magenta"))
        colorScheme->setValue("paletteNormal/magenta", "D200D2");
    if(!colorScheme->contains("paletteNormal/cyan"))
        colorScheme->setValue("paletteNormal/cyan", "00D2D2");
    if(!colorScheme->contains("paletteNormal/white"))
        colorScheme->setValue("paletteNormal/white", "D2D2D2");
    if(!colorScheme->contains("paletteBright/black"))
        colorScheme->setValue("paletteBright/black", "808080");
    if(!colorScheme->contains("paletteBright/red"))
        colorScheme->setValue("paletteBright/red", "FF0000");
    if(!colorScheme->contains("paletteBright/green"))
        colorScheme->setValue("paletteBright/green", "00FF00");
    if(!colorScheme->contains("paletteBright/yellow"))
        colorScheme->setValue("paletteBright/yellow", "FFFF00");
    if(!colorScheme->contains("paletteBright/blue"))
        colorScheme->setValue("paletteBright/blue", "0000FF");
    if(!colorScheme->contains("paletteBright/magenta"))
        colorScheme->setValue("paletteBright/magenta", "FF00FF");
    if(!colorScheme->contains("paletteBright/cyan"))
        colorScheme->setValue("paletteBright/cyan", "00FFFF");
    if(!colorScheme->contains("paletteBright/white"))
        colorScheme->setValue("paletteBright/white", "FFFFFF");
    updatePalette();
}

void TextRender::updatePalette() {
    iColorTable.clear();
    //normal
    iColorTable.append(qColorFromHex("paletteNormal/black"));
    iColorTable.append(qColorFromHex("paletteNormal/red"));
    iColorTable.append(qColorFromHex("paletteNormal/green"));
    iColorTable.append(qColorFromHex("paletteNormal/yellow"));
    iColorTable.append(qColorFromHex("paletteNormal/blue"));
    iColorTable.append(qColorFromHex("paletteNormal/magenta"));
    iColorTable.append(qColorFromHex("paletteNormal/cyan"));
    iColorTable.append(qColorFromHex("paletteNormal/white"));
    //bright
    iColorTable.append(qColorFromHex("paletteBright/black"));
    iColorTable.append(qColorFromHex("paletteBright/red"));
    iColorTable.append(qColorFromHex("paletteBright/green"));
    iColorTable.append(qColorFromHex("paletteBright/yellow"));
    iColorTable.append(qColorFromHex("paletteBright/blue"));
    iColorTable.append(qColorFromHex("paletteBright/magenta"));
    iColorTable.append(qColorFromHex("paletteBright/cyan"));
    iColorTable.append(qColorFromHex("paletteBright/white"));
    //colour cube
    for (int r = 0x00; r < 0x100; r += 0x33)
        for (int g = 0x00; g < 0x100; g += 0x33)
            for (int b = 0x00; b < 0x100; b += 0x33)
                iColorTable.append(QColor(r, g, b));
    //greyscale ramp
    int ramp[] = {
          0,  11,  22,  33,  44,  55,  66,  77,  88,  99, 110, 121,
        133, 144, 155, 166, 177, 188, 199, 210, 221, 232, 243, 255
    };
    for (int i = 0; i < 24; i++)
        iColorTable.append(QColor(ramp[i], ramp[i], ramp[i]));
    iColorTable.append(qColorFromHex("colors/bgColor"));
    iColorTable.append(qColorFromHex("colors/fgColor"));
    iColorTable.append(qColorFromHex("colors/bdColor"));
    if(iColorTable.size() != 256+3)
        qFatal("invalid color table");
    update();
}

QColor TextRender::qColorFromHex(QString hex) {
    int r, g, b;
    char *sthex = colorScheme->value(hex).toString().toUtf8().data();
    sscanf(sthex, "%02x%02x%02x", &r, &g, &b);
    return QColor(r, g, b);
}

QString TextRender::getColor(QString name) {
    return colorScheme->value(name).toString();
}

TextRender::~TextRender()
{
}

void TextRender::paint(QPainter* painter)
{
    if (!iTerm)
        return;

    painter->save();
    painter->setFont(iFont);

    int y=0;
    if (iTerm->backBufferScrollPos() != 0 && iTerm->backBuffer().size()>0) {
        int from = iTerm->backBuffer().size() - iTerm->backBufferScrollPos();
        if(from<0)
            from=0;
        int to = iTerm->backBuffer().size();
        if(to-from > iTerm->termSize().height())
            to = from + iTerm->termSize().height();
        paintFromBuffer(painter, iTerm->backBuffer(), from, to, y);
        if(to-from < iTerm->termSize().height() && iTerm->buffer().size()>0) {
            int to2 = iTerm->termSize().height() - (to-from);
            if(to2 > iTerm->buffer().size())
                to2 = iTerm->buffer().size();
            paintFromBuffer(painter, iTerm->buffer(), 0, to2, y);
        }
    } else {
        int count = qMin(iTerm->termSize().height(), iTerm->buffer().size());
        paintFromBuffer(painter, iTerm->buffer(), 0, count, y);
    }

    // cursor
    if (iTerm->showCursor()) {
        painter->setOpacity(0.5);
        QPoint cursor = cursorPixelPos();
        QSize csize = cursorPixelSize();
        painter->setPen(Qt::transparent);
        painter->setBrush(iColorTable[iTerm->defaultFgColor]);
        painter->drawRect(cursor.x(), cursor.y(), csize.width(), csize.height());
    }

    // selection
    QRect selection = iTerm->selection();
    if (!selection.isNull()) {
        painter->setOpacity(0.5);
        painter->setPen(Qt::transparent);
        painter->setBrush(Qt::white);
        QPoint start, end;

        if (selection.top() == selection.bottom()) {
            start = charsToPixels(selection.topLeft());
            end = charsToPixels(selection.bottomRight());
            painter->drawRect(start.x(), start.y(),
                              end.x()-start.x()+fontWidth(), end.y()-start.y()+fontHeight());
        } else {
            start = charsToPixels(selection.topLeft());
            end = charsToPixels(QPoint(iTerm->termSize().width(), selection.top()));
            painter->drawRect(start.x(), start.y(),
                              end.x()-start.x()+fontWidth(), end.y()-start.y()+fontHeight());

            start = charsToPixels(QPoint(1, selection.top()+1));
            end = charsToPixels(QPoint(iTerm->termSize().width(), selection.bottom()-1));
            painter->drawRect(start.x(), start.y(),
                              end.x()-start.x()+fontWidth(), end.y()-start.y()+fontHeight());

            start = charsToPixels(QPoint(1, selection.bottom()));
            end = charsToPixels(selection.bottomRight());
            painter->drawRect(start.x(), start.y(),
                              end.x()-start.x()+fontWidth(), end.y()-start.y()+fontHeight());
        }
    }

    painter->restore();
}

void TextRender::paintFromBuffer(QPainter* painter, QList<QList<TermChar> >& buffer, int from, int to, int &y)
{
    const int leftmargin = 2;
    int cutAfter = property("cutAfter").toInt() + iFontDescent;

    TermChar tmp = iTerm->zeroChar;
    TermChar nextAttrib = iTerm->zeroChar;
    TermChar currAttrib = iTerm->zeroChar;
    float currentX = leftmargin;
    for(int i=from; i<to; i++) {
        y += iFontHeight;

        if(y >= cutAfter)
            painter->setOpacity(0.3);
        else
            painter->setOpacity(1.0);

        int xcount = qMin(buffer.at(i).count(), iTerm->termSize().width());

        // background for the current line
        currentX = leftmargin;
        int fragWidth = 0;
        painter->setPen(Qt::transparent);
        for(int j=0; j<xcount; j++) {
            tmp = buffer[i][j];
            fragWidth += iFontWidth;
            if (j==0) {
                currAttrib = tmp;
                nextAttrib = tmp;
            } else if (j<xcount-1) {
                nextAttrib = buffer[i][j+1];
            }

            if (currAttrib.attrib != nextAttrib.attrib ||
                currAttrib.bgColor != nextAttrib.bgColor ||
                currAttrib.fgColor != nextAttrib.fgColor ||
                j==xcount-1)
            {
                drawBgFragment(painter, currentX, y-iFontHeight+iFontDescent, fragWidth, currAttrib);
                currentX += fragWidth;
                fragWidth = 0;
                currAttrib.attrib = nextAttrib.attrib;
                currAttrib.bgColor = nextAttrib.bgColor;
                currAttrib.fgColor = nextAttrib.fgColor;
            }
        }

        // text for the current line
        QString line;
        currentX = leftmargin;
        painter->setBrush(Qt::transparent);
        for (int j=0; j<xcount; j++) {
            tmp = buffer[i][j];
            line += tmp.c;
            if (j==0) {
                currAttrib = tmp;
                nextAttrib = tmp;
            } else if(j<xcount-1) {
                nextAttrib = buffer[i][j+1];
            }

            if (currAttrib.attrib != nextAttrib.attrib ||
                currAttrib.bgColor != nextAttrib.bgColor ||
                currAttrib.fgColor != nextAttrib.fgColor ||
                j==xcount-1)
            {
                drawTextFragment(painter, currentX, y, line, currAttrib);
                currentX += iFontWidth*line.length();
                line.clear();
                currAttrib.attrib = nextAttrib.attrib;
                currAttrib.bgColor = nextAttrib.bgColor;
                currAttrib.fgColor = nextAttrib.fgColor;
            }
        }
    }
}

void TextRender::drawBgFragment(QPainter* painter, float x, float y, float width, TermChar style)
{
    int bg = style.bgColor;
    int fg = style.fgColor;
    if (style.attrib & attribNegative) {
        int c = fg;
        fg = bg;
        bg = c;
    }

    if (bg == iTerm->defaultBgColor)
        return;

    painter->setBrush( iColorTable[bg] );
    painter->drawRect(x, y, width, iFontHeight);
}

void TextRender::drawTextFragment(QPainter* painter, float x, float y, QString text, TermChar style)
{
    int bg = style.bgColor;
    int fg = style.fgColor;
    if (style.attrib & attribNegative) {
        int c = fg;
        fg = bg;
        bg = c;
    }
    if (style.attrib & attribBold) {
        iFont.setBold(true);
        painter->setFont(iFont);
        if(fg < 8)
            fg += 8;
        if (fg == 257)
            fg++;
    } else if (iFont.bold()) {
        iFont.setBold(false);
        painter->setFont(iFont);
    }

    painter->setPen( iColorTable[fg] );
    painter->drawText(x, y, text);
}

void TextRender::redraw()
{
    update();
}

void TextRender::setTerminal(Terminal *term)
{
    if (!iUtil)
        qFatal("textrender: util class not set");

    iTerm = term;

    iFont = QFont(iUtil->settingsValue("ui/fontFamily").toString(),
                  iUtil->settingsValue("ui/fontSize").toInt());
    iFont.setBold(false);
    iFont.setStyleHint(QFont::Monospace);
    iFont.setFixedPitch(true);
    iFont.setKerning(false);
    iFont.setStyleStrategy(QFont::ForceIntegerMetrics);
    QFontMetrics fontMetrics(iFont);
    iFontHeight = fontMetrics.height();
    iFontWidth = fontMetrics.maxWidth();
    iFontDescent = fontMetrics.descent();
    iFontAscent = fontMetrics.ascent();
}

QFont TextRender::getFont() {
    return iFont;
}

void TextRender::updateTermSize()
{
    if (!iTerm)
        return;

    QSize s((iWidth-4)/iFontWidth, (iHeight-4)/iFontHeight);
    iTerm->setTermSize(s);
}

void TextRender::setFontPointSize(int psize)
{
    if (iFont.pointSize() != psize)
    {
        iFont.setBold(false);
        iFont.setPointSize(psize);
        QFontMetrics fontMetrics(iFont);
        iFontHeight = fontMetrics.height();
        iFontWidth = fontMetrics.maxWidth();
        iFontDescent = fontMetrics.descent();

        iUtil->setSettingsValue("ui/fontSize", psize);

        emit fontSizeChanged();
    }
}

QPoint TextRender::cursorPixelPos()
{
    return charsToPixels(iTerm->cursorPos());
}

QPoint TextRender::charsToPixels(QPoint pos)
{
    return QPoint(2+(pos.x()-1)*iFontWidth, (pos.y()-1)*iFontHeight+iFontDescent+1);
}

QSize TextRender::cursorPixelSize()
{
    return (QSize(iFontWidth, iFontHeight));
}
