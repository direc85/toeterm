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

#ifndef KEYLOADER_H
#define KEYLOADER_H

#include <QtCore>

class Util;

struct KeyData {
    QString label;
    int code;
    QString label_alt;
    int code_alt;
    int width;
    bool isModifier;
};

class KeyLoader : public QObject
{
    Q_OBJECT
public:
    explicit KeyLoader(QObject *parent = nullptr);
    virtual ~KeyLoader();

    void setUtil(Util* util) { iUtil = util; }

    Q_INVOKABLE bool loadLayout(QString layout);

    Q_INVOKABLE int vkbRows() { return iVkbRows; }
    Q_INVOKABLE int vkbColumns() { return iVkbColumns; }
    Q_INVOKABLE QVariantList keyAt(int row, int col);
    Q_INVOKABLE const QStringList availableLayouts();
    Q_INVOKABLE const QStringList allAvailableLayouts();
    Q_INVOKABLE const QStringList availableColorSchemes();
    void getAvailableLayouts();

    Q_INVOKABLE void toggleLayout(QString name, bool enable);
    Q_INVOKABLE bool layoutEnabled(QString name);

    void loadDisabledLayouts();

signals:

public slots:

private:
    Q_DISABLE_COPY(KeyLoader)
    bool loadLayoutInternal(QIODevice &from);
    void cleanUpKey(KeyData &key);

    int iVkbRows;
    int iVkbColumns;

    QList<QList<KeyData> > iKeyData;
    QList<QString> disabledLayouts;

    Util *iUtil;

    QStringList allLayouts;
};

#endif // KEYLOADER_H
