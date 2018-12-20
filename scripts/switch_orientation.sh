#!/usr/bin/env bash

resolution=$(xrandr | grep current)
resolution=($resolution)
resolution="${resolution[7]}x${resolution[9]%,*}"
if [ ${resolution[7]} == "3840" ] ; then
  xrandr --output HDMI3 --mode 1920x1200 --pos 1920x0 --rotate left \
    --output HDMI2 --primary --mode 1920x1200 --pos 0x0 --rotate normal
  feh --bg-center ~/.i3/images/bg-h.jpg ~/.i3/images/bg-v.jpg
else
  xrandr --output HDMI3 --mode 1920x1200 --pos 1920x0 --rotate normal \
    --output HDMI2 --primary --mode 1920x1200 --pos 0x0 --rotate normal
  feh --bg-center ~/.i3/images/bg-h.jpg ~/.i3/images/bg-h.jpg
fi
