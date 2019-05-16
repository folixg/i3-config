#!/usr/bin/env bash

LED_STATUS="$(xset -q | grep 'LED')"
LED_STATUS=${LED_STATUS##* }
if [ "$LED_STATUS" == "00001001" ] || [ "$LED_STATUS" == "00001003" ]; then
  LAYOUT="US"
else
  LAYOUT="DE"
fi
echo "{\"name\":\"keyboard\",\"full_text\":\" $LAYOUT\"},"

