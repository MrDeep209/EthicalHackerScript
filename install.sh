#!/bin/bash

# Update and install software
apt-get update -y ; apt-get dist-upgrade -y
apt-get install -y fail2ban tmux screen vim git ntp sudo dnsutils apache2
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

# Add tor repositories to sources
echo "
deb http://deb.torproject.org/torproject.org jessie main
deb-src http://deb.torproject.org/torproject.org jessie main" > /etc/apt/sources.list

# Add the gpg key used to sign the packages
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

# update sources, install tor and gpg keyring
apt-get update
apt-get install tor 

# configure your tor hidden service
echo "
HiddenServiceDir /var/lib/tor/
HiddenServicePort 80 127.0.0.1:80" >> /etc/tor/torrc

# Restart TOR
systemctl restart tor

# Print your exit node URL
echo "Your exit node url is:" && cat /var/lib/tor/hostname

#TODO configure webserver correctly to minimize IP leaks

# Kali

# Replace repositories 
mv /etc/apt/sources.list /etc/apt/sources.list.debian
echo "
deb http://http.kali.org/kali kali-rolling main non-free contrib
deb-src http://http.kali.org/kali kali-rolling main non-free contrib"> /etc/apt/sources.list

# Add the Kali Linux GPG keys to aptitude ###
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED444FF07D8D0BF6

# Update and install base packages 
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install kali-linux

# Configure Kali specific applications
apt-get -y --force-yes install tzdata=2015d-0+deb8u1
apt-get -y --force-yes install libc6=2.19-18
apt-get -y --force-yes install systemd=215-17+deb8u1 libsystemd0=215-17+deb8u1

# Remove uneccesary applications
apt-get -y autoremove --purge && apt-get clean

# Install Kali tools as you see fit
apt-get -y install metasploit* nikto sqlninja


# Empire
cd /opt
git clone https://github.com/EmpireProject/Empire.git
cd Empire/setup/
./install.sh



