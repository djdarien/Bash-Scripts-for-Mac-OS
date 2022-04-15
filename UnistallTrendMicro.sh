#!/bin/bash
# unistall Trend Micro completley and silently
#Forked by Darien Entwistle ,  github.com/djdarien




launchctl unload /Library/LaunchAgents/com.trendmicro.TmLoginMgr.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.aot.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.endpointbasecamp.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.tmsm.rpd.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.tmsm.launcher.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.tmsm.monitor.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.tmsm.plugin.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.tmes.uploader.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.tmes.plugin.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.icore.xdr.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.icore.ec.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.icore.av.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.icore.wp.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.icore.misc.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.icore.main.plist
launchctl unload /Library/LaunchDaemons/com.trendmicro.WSC.plist
killall MainUI TmLoginMgr UIMgmt TrendMicroSecurity
sleep 5

sudo /usr/libexec/PlistBuddy -c "Delete :GlobalStatus:bHasRegToSrv" /Library/Application\ Support/TrendMicro/common/conf/EPStatus.plist
sudo /usr/libexec/PlistBuddy -c "Set :GlobalStatus:bHasRegToSrv bool false" /Library/Application\ Support/TrendMicro/common/conf/EPStatus.plist
sleep 5


#Switch to the /tmp directory
cd /tmp

#Download the Trend Uninstaller
curl -O -k https://relb6z.manage.trendmicro.com/officescan/console/html/TMSM_HTML/ActiveUpdate/ClientInstall/tmsmuninstall.zip

#Unzip the installer
unzip tmsmuninstall.zip

# change directory to uninstaller script
cd /tmp/tmsmuninstall

sudo /tmp/tmsmuninstall/TMUninstallLauncher.app/Contents/MacOS/TMUninstallLauncher --uninstall


