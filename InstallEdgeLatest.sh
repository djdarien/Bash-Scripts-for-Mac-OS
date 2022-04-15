#!/bin/zsh

:<<'ABOUT_THIS_SCRIPT'
-----------------------------------------------------------------------

	Written by:William Smith
	Professional Services Engineer
	Jamf
	bill@talkingmoose.net
	https://gist.github.com/talkingmoose/a16ca849416ce5ce89316bacd75fc91a
	
	Originally posted: November 19, 2017
	Updated: January 20, 2020

	Purpose: Downloads and installs the latest available Microsoft
	product specified directly on the client. This avoids having to
	manually download and store an up-to-date installer on a
	distribution server every month.
	
	Instructions: Update the linkID value to one of the corresponding
	Microsoft products in the list and optionally update the sha256Checksum
	value with a known SHA 256 string. Run the script with elevated
	privileges. If using Jamf Pro, consider replacing the linkID and
	sha256Checksum values with "$4" and "$5", entering the ID as script
	parameters in a policy.

	Except where otherwise noted, this work is licensed under
	http://creativecommons.org/licenses/by/4.0/

	"You say goodbye and I say exit 0."
	
-----------------------------------------------------------------------
ABOUT_THIS_SCRIPT

# enter the Microsoft fwlink (permalink) product ID
# or leave blank if using a $4 script parameter with Jamf Pro

linkID="" # e.g. "525133" for Office 2019

# 525133 - Office 2019 for Mac SKUless download (aka Office 365)
# 2009112 - Office 2019 for Mac BusinessPro SKUless download (aka Office 365 with Teams)
# 871743 - Office 2016 for Mac SKUless download
# 830196 - AutoUpdate download
# 2069148 - Edge (Consumer Stable)
# 2069439 - Edge (Consumer Beta)
# 2069340 - Edge (Consumer Dev)
# 2069147 - Edge (Consumer Canary)
# 2093438 - Edge (Enterprise Stable)
# 2093294 - Edge (Enterprise Beta)
# 2093292 - Edge (Enterprise Dev)
# 525135 - Excel 2019 SKUless download
# 871750 - Excel 2016 SKUless download
# 869655 - InTune Company Portal download
# 823060 - OneDrive download
# 820886 - OneNote download
# 525137 - Outlook 2019 SKUless download
# 871753 - Outlook 2016 SKUless download
# 525136 - PowerPoint 2019 SKUless download
# 871751 - PowerPoint 2016 SKUless download
# 868963 - Remote Desktop
# 800050 - SharePoint Plugin download
# 832978 - Skype for Business download
# 869428 - Teams
# 525134 - Word 2019 SKUless download
# 871748 - Word 2016 SKUless download

# enter the SHA 256 checksum for the download file
# download the package and run '/usr/bin/shasum -a 256 /path/to/file.pkg'
# this will change with each version
# leave blank to to skip the checksum verification (less secure) or if using a $5 script parameter with Jamf Pro

sha256Checksum=  

    linkID=2069148


# this is the full fwlink URL
url="https://go.microsoft.com/fwlink/?linkid=$linkID"

# create temporary working directory
echo "Creating working directory '$tempDirectory'"
workDirectory=$( /usr/bin/basename $0 )
tempDirectory=$( /usr/bin/mktemp -d "/private/tmp/$workDirectory.XXXXXX" )

# change directory to temporary working directory
echo "Changing directory to working directory '$tempDirectory'"
cd "$tempDirectory"

# download the installer package and name it for the linkID
echo "Downloading package $linkID.pkg"
/usr/bin/curl --location --silent "$url" -o "$linkID.pkg"

# checksum the download
downloadChecksum=$( /usr/bin/shasum -a 256 "$tempDirectory/$linkID.pkg" | /usr/bin/awk '{ print $1 }' )
echo "Checksum for downloaded package: $downloadChecksum"

# install the package if checksum validates
if [ "$sha256Checksum" = "$downloadChecksum" ] || [ "$sha256Checksum" = "" ]; then
	echo "Checksum verified. Installing package $linkID.pkg"
	/usr/sbin/installer -pkg "$linkID.pkg" -target /
	exitCode=0
else
	echo "Checksum failed. Recalculate the SHA 256 checksum and try again. Or download may not be valid."
	exitCode=1
fi

# remove the temporary working directory when done
/bin/rm -Rf "$tempDirectory"
echo "Deleting working directory '$tempDirectory' and its contents"

exit $exitCode