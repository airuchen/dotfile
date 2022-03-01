#!/bin/sh

SRC_FILE="xmo-config/src/lib/Helpers.hs"
HOSTNAME=$(hostname -s)
[ -e ${SRC_FILE} ]\
    && grep --quiet -e "myHostname = \"${HOSTNAME}\"" $SRC_FILE\
    && grep --quiet -e "myHome = \"${HOME}\"" $SRC_FILE\
    && exit 0
sed\
    -e "s/<hostname>/${HOSTNAME}/"\
    -e "s#<home>#${HOME}#"\
    Helpers.hs.template > $SRC_FILE
