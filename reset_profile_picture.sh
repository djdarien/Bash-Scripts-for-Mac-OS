#!/bin/sh

# get the current user
loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# Delete any Photo currently used.
dscl . delete /Users/$loggedInUser jpegphoto
sleep 1

# Delete File path
dscl . delete /Users/$loggedInUser Picture
sleep 1

echo profile picture reset
exit
