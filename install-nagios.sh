#!/bin/bash
set -e

########################################
# 1. Update system and install packages
########################################
echo "Updating system packages..."
yum update -y

echo "Installing required packages..."
yum install -y httpd php gcc glibc glibc-common gd gd-devel make net-snmp openssl wget unzip

########################################
# 2. Create nagios user and groups
########################################
echo "Creating nagios user and configuring groups..."
if ! id nagios &>/dev/null; then
    useradd nagios
fi

if ! getent group nagcmd &>/dev/null; then
    groupadd nagcmd
fi

# Add both nagios and apache users to the nagcmd group
usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache

########################################
# 3. Download, compile and install Nagios Core
########################################
NAGIOS_VERSION="4.4.6"
cd /tmp
echo "Downloading Nagios Core version ${NAGIOS_VERSION}..."
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_VERSION}.tar.gz

echo "Extracting Nagios Core..."
tar zxvf nagios-${NAGIOS_VERSION}.tar.gz
cd nagios-${NAGIOS_VERSION}

echo "Configuring Nagios Core..."
./configure --with-command-group=nagcmd

echo "Compiling Nagios Core..."
make all

echo "Installing Nagios Core..."
make install
make install-init
make install-commandmode
make install-config
make install-webconf

########################################
# 4. Configure the Nagios web interface
########################################
echo "Setting up Nagios web interface user (nagiosadmin)..."
read -p "Enter password for nagiosadmin: " NAGIOS_PASS
htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin "$NAGIOS_PASS"

########################################
# 5. Download, compile and install Nagios Plugins
########################################
PLUGINS_VERSION="2.3.3"
cd /tmp
echo "Downloading Nagios Plugins version ${PLUGINS_VERSION}..."
wget https://nagios-plugins.org/download/nagios-plugins-${PLUGINS_VERSION}.tar.gz
tar zxvf nagios-plugins-${PLUGINS_VERSION}.tar.gz
cd nagios-plugins-${PLUGINS_VERSION}

echo "Configuring Nagios Plugins..."
./configure --with-nagios-user=nagios --with-nagios-group=nagios

echo "Compiling Nagios Plugins..."
make

echo "Installing Nagios Plugins..."
make install

########################################
# 6. Enable and start services
########################################
echo "Enabling and starting Apache (httpd) and Nagios services..."
systemctl enable httpd
systemctl start httpd

systemctl enable nagios
systemctl start nagios

########################################
# 7. Configure iptables to allow HTTP/HTTPS traffic
########################################
echo "Configuring iptables to allow HTTP (port 80) and HTTPS (port 443) traffic..."
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

# Restart iptables service if it is active
if systemctl is-active --quiet iptables; then
    systemctl restart iptables
fi

########################################
# Final Message
########################################
echo "Nagios Core installation and configuration complete."
echo "You can access the Nagios web interface at: http://<your_server_ip>/nagios"