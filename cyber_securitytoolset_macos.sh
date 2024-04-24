#!/bin/bash

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# List of cybersecurity tools to install
tools=("nmap" "wireshark" "metasploit" "burp-suite" "openvas" "snort" "aircrack-ng" "john" "hashcat" "gnupg" "tcpdump" "hydra" "sqlmap" "ettercap" "nessus")

echo "Installing cybersecurity tools..."

# Loop through the tools array and install each tool
for tool in "${tools[@]}"; do
    echo "Installing $tool..."
    brew install "$tool"
done

echo "Cybersecurity tools installation complete."
