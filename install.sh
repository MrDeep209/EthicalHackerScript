#!/bin/bash

# Convert to Kali Linux
# Update and install software
mv /etc/apt/sources.list /etc/apt/sources.list.bak
echo "
deb http://http.kali.org/kali kali-rolling main non-free contrib
deb-src http://http.kali.org/kali kali-rolling main non-free contrib" >> /etc/apt/sources.list

# Add the Kali Linux GPG keys to aptitude ###
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED444FF07D8D0BF6

# Update and install base packages 
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install kali-linux
apt-get install -y fail2ban tmux screen vim git ntp sudo dnsutils apache2 metasploit* nikto sqlninja wpscan tor

# If you'd rather the full Kali Linux install uncomment
# apt-get install kali-linux-full

apt-get -y autoremove --purge && apt-get clean
systemctl enable fail2ban
systemctl start fail2ban
systemctl enable apache2
systemctl start apache2
systemctl enable ntp
systemctl start ntp

# Configure ssh and restart
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "
# Added on Startup Script
AllowTcpForwarding no
ClientAliveCountMax 2
Compression no
MaxAuthTries 5
MaxSessions 2
UsePrivilegeSeparation sandbox
AllowAgentForwarding no" >> /etc/ssh/sshd_config
systemctl restart sshd

# Configure TOR Hidden Service


# configure your tor hidden service
echo "
HiddenServiceDir /var/lib/tor/
HiddenServicePort 80 127.0.0.1:80" >> /etc/tor/torrc

# Restart TOR
systemctl restart tor

# Print your exit node URL
echo "Your exit node url is:" && cat /var/lib/tor/hostname


# Empire
cd /opt
git clone https://github.com/EmpireProject/Empire.git
cd Empire/setup/
./install.sh



