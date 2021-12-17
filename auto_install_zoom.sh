#!/bin/bash
# script made by Darien Entwistle  github.com/djarien

#Auto update & or Install Zoom
echo Auto Zoom installer for Macintosh

#download latest Zoom pkg
sudo cd /tmp
sudo curl -O -sLo /tmp https://zoom.us/client/latest/Zoom.pkg

#install zoom and run pkg installer
sudo installer -allowUntrusted -pkg /tmp/Zoom.pkg -target /



sudo rm -rf /tmp/Zoom.pkg
echo Zoom installation complete
exit
