#!/bin/sh
/usr/bin/ls -1 /var/run/user/1000/crun | wc -l
#podman ps -q | wc -w # starts a new scope every time
