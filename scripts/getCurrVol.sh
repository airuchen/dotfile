#!/bin/sh

VOL=`amixer -c0 sget Master | grep -oe '[0-9]\+%'`
amixer -c0 sget Master | grep -e '\[on\]' > /dev/null
echo -n "Vol: $VOL"
if [ $? -eq 0 ]; then
	echo -n "\n"
else
	echo " (M)"
fi
