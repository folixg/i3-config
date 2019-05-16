#!/usr/bin/env bash

i3status -c ~/.i3/i3status.conf | while :
do
  read line
  if [ "$line" == '{"version":1}' ] || [ "$line" == "[" ] ; then
    echo "$line" || exit 1
  else   
    KBD=$(~/.i3/scripts/keyboard_layout.sh)
    MUSIC=$(~/.i3/scripts/music_status.sh)
    echo "[$MUSIC,$KBD,${line#*[}," || exit 1
  fi
done
