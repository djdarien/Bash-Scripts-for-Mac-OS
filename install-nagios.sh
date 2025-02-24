#!/bin/bash
set -e

########################################
# Nagios Core Uninstallation Script
# This script stops and disables the Nagios service,
# removes the installed files (including the installation
# directory and Apache configuration), and optionally
# deletes the nagios user and nagcmd group.
########################################

echo "----------------------------------------"
echo "Nagios Core Uninstallation Script Started"
echo "----------------------------------------"

# Step 1: Stop and disable the Nagios service
echo "Stopping Nagios service (if running)..."
if systemctl is-active --quiet nagios; then
    systemctl stop nagios
    echo "Nagios service stopped."
else
    echo "Nagios service is not running."
fi

echo "Disabling Nagios service..."
if systemctl is-enabled --quiet nagios; then
    systemctl disable nagios
    echo "Nagios service disabled."
else
    echo "Nagios service was not enabled."
fi

# Step 2: Remove the init script (if installed)
if [ -f /etc/init.d/nagios ]; then
    echo "Removing Nagios init script at /etc/init.d/nagios..."
    rm -f /etc/init.d/nagios
else
    echo "No Nagios init script found at /etc/init.d/nagios."
fi

# Step 3: Remove the Nagios installation directory
if [ -d /usr/local/nagios ]; then
    echo "Removing Nagios installation directory (/usr/local/nagios)..."
    rm -rf /usr/local/nagios
else
    echo "Nagios installation directory (/usr/local/nagios) not found."
fi

# Step 4: Remove Apache's Nagios configuration file
if [ -f /etc/httpd/conf.d/nagios.conf ]; then
    echo "Removing Apache Nagios configuration (/etc/httpd/conf.d/nagios.conf)..."
    rm -f /etc/httpd/conf.d/nagios.conf
else
    echo "Apache Nagios configuration file not found."
fi

# Step 5: Optionally remove nagios user and nagcmd group
read -p "Do you want to remove the nagios user and nagcmd group? [y/N]: " REMOVE_USER
if [[ "$REMOVE_USER" =~ ^[Yy]$ ]]; then
    if id nagios &>/dev/null; then
        echo "Removing nagios user..."
        userdel nagios
    else
        echo "nagios user does not exist."
    fi

    if getent group nagcmd &>/dev/null; then
        echo "Removing nagcmd group..."
        groupdel nagcmd
    else
        echo "nagcmd group does not exist."
    fi
fi

echo "----------------------------------------"
echo "Nagios Core uninstallation complete."
echo "You can now proceed with your Nagios XI installation."
echo "----------------------------------------"