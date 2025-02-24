#!/bin/bash
set -e

########################################
# 1. Update System & Install Prerequisites
########################################
echo "Updating system packages..."
yum update -y

echo "Installing required packages..."
yum install -y httpd php gcc glibc glibc-common gd gd-devel make net-snmp \
    openssl wget unzip httpd-tools policycoreutils-python

########################################
# 2. Create Nagios User and Groups
########################################
echo "Creating nagios user and nagcmd group (if they don't exist)..."
if ! id nagios &>/dev/null; then
    useradd nagios
fi

if ! getent group nagcmd &>/dev/null; then
    groupadd nagcmd
fi

# Add both nagios and Apache users to the nagcmd group
usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache

########################################
# 3. Download, Compile, and Install Nagios Core (v4.5.9)
########################################
NAGIOS_CORE_VERSION="4.5.9"
cd /tmp
echo "Downloading Nagios Core v${NAGIOS_CORE_VERSION}..."
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_CORE_VERSION}.tar.gz

echo "Extracting Nagios Core..."
tar zxvf nagios-${NAGIOS_CORE_VERSION}.tar.gz
cd nagios-${NAGIOS_CORE_VERSION}

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
# 4. Configure the Nagios Web Interface
########################################
echo "Setting up Nagios web interface user (nagiosadmin)..."
read -p "Enter password for nagiosadmin: " NAGIOS_PASS
htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin "$NAGIOS_PASS"

########################################
# 5. Download, Compile, and Install Nagios Plugins (v2.4.3)
########################################
NAGIOS_PLUGINS_VERSION="2.4.3"
cd /tmp
echo "Downloading Nagios Plugins v${NAGIOS_PLUGINS_VERSION}..."
wget https://nagios-plugins.org/download/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz

echo "Extracting Nagios Plugins..."
tar zxvf nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz
cd nagios-plugins-${NAGIOS_PLUGINS_VERSION}

echo "Configuring Nagios Plugins..."
./configure --with-nagios-user=nagios --with-nagios-group=nagios

echo "Compiling Nagios Plugins..."
make

echo "Installing Nagios Plugins..."
make install

########################################
# 6. SELinux Adjustments (if Enabled)
########################################
if sestatus | grep "SELinux status:" | grep -q "enabled"; then
    echo "SELinux is enabled. Adjusting file contexts..."
    semanage fcontext -a -t httpd_sys_content_t "/usr/local/nagios(/.*)?"
    restorecon -Rv /usr/local/nagios
    # Allow Apache to connect to Nagios resources
    setsebool -P httpd_can_connect_nagios=1
fi

########################################
# 7. Update Apache Configuration for Nagios
########################################
echo "Ensuring Apache is configured to allow access to Nagios..."
NAGIOS_CONF="/etc/httpd/conf.d/nagios.conf"
if [ -f "$NAGIOS_CONF" ]; then
    # Modify the Directory block for /usr/local/nagios/share if necessary.
    sed -i '/<Directory "\/usr\/local\/nagios\/share">/,/<\/Directory>/ {
        s/AllowOverride None/AllowOverride All/g;
        s/Order allow,deny/Require all granted/g;
    }' "$NAGIOS_CONF"
fi

########################################
# 8. Enable and Start Services
########################################
echo "Enabling and starting Apache (httpd) and Nagios services..."
systemctl enable httpd
systemctl start httpd

systemctl enable nagios
systemctl start nagios

########################################
# 9. Configure iptables Firewall (Allow HTTP/HTTPS)
########################################
echo "Configuring iptables to allow HTTP (port 80) and HTTPS (port 443) traffic..."
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

if systemctl is-active --quiet iptables; then
    systemctl restart iptables
fi

########################################
# Final Message
########################################
echo "Nagios Core installation (v${NAGIOS_CORE_VERSION}) with Plugins (v${NAGIOS_PLUGINS_VERSION}) is complete."
echo "Access the Nagios web interface at: http://<your_server_ip>/nagios"