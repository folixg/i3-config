#!/usr/bin/env bash

MEDIAPLAYER="/org/mpris/MediaPlayer2"
GET_PROPERTIES="org.freedesktop.DBus.Properties.Get"
PLAYER="org.mpris.MediaPlayer2.Player"

# This function is taken from  https://gist.github.com/wandernauta/6800547
function player-metadata {
  # Prints the currently playing track in a parseable format.

  dbus-send                                                                   \
  --print-reply                                  `# We need the reply.`       \
  --dest="org.mpris.MediaPlayer2.$RUNNING"                                    \
  $MEDIAPLAYER                                                                \
  $GET_PROPERTIES                                                             \
  string:"$PLAYER" string:'Metadata'                                          \
  | grep -Ev "^method"                           `# Ignore the first line.`   \
  | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)' `# Filter interesting fiels.`\
  | sed -E '2~2 a|'                              `# Mark odd fields.`         \
  | tr -d '\n'                                   `# Remove all newlines.`     \
  | sed -E 's/\|/\n/g'                           `# Restore newlines.`        \
  | sed -E 's/(xesam:)|(mpris:)//'               `# Remove ns prefixes.`      \
  | sed -E 's/^"//'                              `# Strip leading...`         \
  | sed -E 's/"$//'                              `# ...and trailing quotes.`  \
  | sed -E 's/"+/|/'                             `# Regard "" as seperator.`  \
  | sed -E 's/ +/ /g'                            `# Merge consecutive spaces.`\
  | sed -E 's/\"/\\\"/g'                         `# Escape quotes for JSON.`
}

function player-status {
  STATUS=$(dbus-send --print-reply --dest="org.mpris.MediaPlayer2.$RUNNING" \
    "$MEDIAPLAYER" "$GET_PROPERTIES" string:"$PLAYER" string:'PlaybackStatus' \
    2> /dev/null)
  if [ "$STATUS" != "" ]; then
    STATUS=${STATUS#*\"}
    STATUS=${STATUS::-1}
  fi
} 

# first check if spotify is running
RUNNING="spotify"
player-status
if [ "$STATUS" == "" ] ; then
  # then check for rhythmbox
  RUNNING="rhythmbox"
  player-status
  if [ "$STATUS" == "" ] ; then
    echo "" || exit 1    
  fi
fi
if [ "$STATUS" == "Playing" ] || [ "$STATUS" == "Paused" ] ; then
  if [ "$STATUS" == "Playing" ] ; then
    ICON=""
  else
    ICON="" 
  fi
  METADATA=$(player-metadata)
  ARTIST=$(echo "$METADATA" | grep --color=never "artist")
  ARTIST=${ARTIST#*|}
  TITLE=$(echo "$METADATA" | grep --color=never "title")
  TITLE=${TITLE#*|}
  echo "{\"name\":\"music\",\"full_text\":\"$ICON $ARTIST - $TITLE\"}" || exit 1
fi
