#!/bin/bash
# script made by Darien Entwistle  github.com/djarien
# Removes FireEye agent on macintosh computers.
echo removing FireEye agent

sudo /Library/FireEye/xagt/uninstall.tool

echo Removed!
exit 0 
