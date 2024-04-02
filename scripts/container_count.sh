#!/bin/sh
/usr/bin/ls -1 /run/user/${UID}/crun | wc -l
#podman ps -q | wc -w # starts a new scope every time
