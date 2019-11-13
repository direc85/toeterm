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
*/#ifndef PTYIFACE_H
#define PTYIFACE_H

#include <QObject>
#include <QSocketNotifier>
#include <QByteArray>
#include <QSize>
#include <QTextCodec>

class Terminal;

class PtyIFace : public QObject
{
    Q_OBJECT
public:
    explicit PtyIFace(int pid, int masterFd, Terminal *term, QString charset, QObject *parent = 0);
    virtual ~PtyIFace();

    void writeTerm(const QString &chars);
    bool failed() { return iFailed; }

    Q_INVOKABLE void changeCharset(QString charset_name);

public slots:
    void resize(QSize newSize);

private slots:
    void readActivated();

private:
    Q_DISABLE_COPY(PtyIFace)

    void writeTerm(const QByteArray &chars);
    void readTerm(QByteArray &chars);

    Terminal *iTerm;
    int iPid;
    int iMasterFd;
    bool iFailed;

    QSocketNotifier *iReadNotifier;

    QTextCodec *iTextCodec;
};

#endif // PTYIFACE_H
