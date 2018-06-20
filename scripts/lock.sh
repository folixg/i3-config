#!/usr/bin/env bash

# the only valid argument is --suspend, which means we will suspend and lock
if [ "$1" == "--suspend" ]; then
  suspend=1
else
  suspend=0
fi

# if xautolock is running, disable it, before locking to avoid double locks
if [ "$(pgrep xautolock)" ] ; then
  xautolock -disable
fi

# pause spotify if it is playing
#
spotify_paused=0
spotify_status=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
  /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
  string:org.mpris.MediaPlayer2.Player string:'PlaybackStatus' 2> /dev/null)
if [ "$spotify_status" != "" ] ; then
  spotify_status=${spotify_status#*\"}
  spotify_status=${spotify_status::-1}
  if [ "$spotify_status" == "Playing" ] ; then
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
    spotify_paused=1
  fi
fi

# pause dunst notifications
killall -SIGUSR1 dunst

# if ffmpeg is not available use a simple lock screen
if [[ ! $(which ffmpeg) ]] ; then
  if [ $suspend -eq 1 ] ; then
    i3lock -c 2f343f && systemctl suspend
  else
    i3lock -n -c 2f343f 
  fi
else
  # get current resolution from xrandr output that looks like
  # Screen 0: minimum 8 x 8, current 3840 x 1200, maximum 32767 x 32767
  resolution=$(xrandr | grep current)
  resolution=($resolution)
  resolution="${resolution[7]}x${resolution[9]%,*}"
  image="/var/run/user/$UID/lockscreen.png"
  # select overlay image depending on number of screens
  if [[ $(xrandr | grep -c -w connected) -eq 2 ]] ; then
    overlay="$HOME/.i3/images/dualscreen_locked.png"
  else
    overlay="$HOME/.i3/images/locked.png"
  fi
  # perform blur and overlay
  ffmpeg -loglevel quiet -f x11grab -video_size 3840x1200 -y -i "$DISPLAY" \
    -i "$overlay" -filter_complex \
    "boxblur=4,overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" -vframes 1 \
    "$image"
  # perform lock
  if [ $suspend -eq 1 ] ; then
    i3lock -i "$image" && systemctl suspend
  else
    i3lock -n -i "$image"
  fi
fi
# resume music player if it was paused on lock (unless system was suspended)
if [ $suspend -eq 0 ] ; then
  if [ $spotify_paused -eq 1 ] ; then
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
    /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
  fi
fi

# resume dunst notifications
killall -SIGUSR2 dunst

# enable xautolock again
if [ "$(pgrep xautolock)" ] ; then
  xautolock -enable
fi
