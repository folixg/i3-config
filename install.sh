#!/usr/bin/env bash

sudo apt update || exit 1
sudo apt install i3 dunst feh xautolock scrot || exit 1

FONT_DIR="$HOME"/.local/share/fonts
if [ ! -d "$FONT_DIR" ] ; then
  echo "Creating fonts folder $FONT_DIR ###"
  mkdir "$FONT_DIR" || exit 1
fi
if [ "$(fc-list | grep -c "Source Code Pro")" == "0" ] ; then
  echo "Installing Source Code Pro. "
  wget -P "$FONT_DIR" https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.tar.gz || exit 1
  tar xvf "$FONT_DIR"/1.050R-it.tar.gz -C "$FONT_DIR" || exit 1
  rm "$FONT_DIR"/1.050R-it.tar.gz || exit 1
fi
if [ "$(fc-list | grep -c "FontAwesome")" == "0" ] ; then
  echo "Installing Font Awesome."
  wget -P "$FONT_DIR" https://github.com/FortAwesome/Font-Awesome/archive/v4.7.0.tar.gz || exit 1
  tar xvf "$FONT_DIR"/v4.7.0.tar.gz -C "$FONT_DIR" || exit 1
  rm "$FONT_DIR"/v4.7.0.tar.gz || exit 1
fi
echo "Updating font cache."
fc-cache -f "$FONT_DIR" || exit 1
