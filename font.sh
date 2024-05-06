#!/bin/sh

cd .config/rstudio/
mkdir fonts
cd fonts/

HACKGEN_VER="2.9.0"
# HackGen
    mkdir -p HackGen/400
    mkdir -p HackGen/700
    mkdir -p HackGen\ Console/400
    mkdir -p HackGen\ Console/700
    mkdir -p HackGen35/400
    mkdir -p HackGen35/700
    mkdir -p HackGen35\ Console/400
    mkdir -p HackGen35\ Console/700

if [ -e HackGen_v$HACKGEN_VER.zip ]; then
    echo "HackGen_v$HACKGEN_VER.zip found."

    else 
	wget https://github.com/yuru7/HackGen/releases/download/v$HACKGEN_VER/HackGen_v$HACKGEN_VER.zip

fi
    unzip HackGen_v$HACKGEN_VER.zip

    mv HackGen_v$HACKGEN_VER/HackGen-Regular.ttf HackGen/400
    mv HackGen_v$HACKGEN_VER/HackGen-Bold.ttf HackGen/700
    mv HackGen_v$HACKGEN_VER/HackGenConsole-Regular.ttf HackGen\ Console/400
    mv HackGen_v$HACKGEN_VER/HackGenConsole-Bold.ttf HackGen\ Console/700
    mv HackGen_v$HACKGEN_VER/HackGen35-Regular.ttf HackGen35/400
    mv HackGen_v$HACKGEN_VER/HackGen35-Bold.ttf HackGen35/700
    mv HackGen_v$HACKGEN_VER/HackGen35Console-Regular.ttf HackGen35\ Console/400
    mv HackGen_v$HACKGEN_VER/HackGen35Console-Bold.ttf HackGen35\ Console/700

    rm -r HackGen_v$HACKGEN_VER
