#!/bin/bash

SPEC=rpm/$1.spec
CPP=src/main.cpp

if [[ $(grep "^Version:    $2$" $SPEC | wc -l) = 0 ]]
then
  sed -i "/^Version:    /c\Version:    $2" $SPEC
  touch $CPP
fi
if [[ $(grep "^Release:    $3$" $SPEC | wc -l) = 0 ]]
then
  sed -i "/^Release:    /c\Release:    $3" $SPEC
  touch $CPP
fi


YAML=rpm/$1.yaml
if [[ $(grep "^Version: $2$" $YAML | wc -l) = 0 ]]
then
  sed -i "/^Version: /c\Version: $2" $YAML
  touch $CPP
fi
if [[ $(grep "^Release: $3$" $YAML | wc -l) = 0 ]]
then
  sed -i "/^Release: /c\Release: $3" $YAML
  touch $CPP
fi

echo true
