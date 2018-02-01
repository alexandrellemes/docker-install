#!/bin/bash
##########################################
# install-docker-on-linux-mint-18.sh
##########################################

versionlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}
versionlt() {
    [ "$1" = "$2" ] && return 1 || versionlte $1 $2
}

kernel_version=$(uname -r)
minimum_kernel_version="3.10"

# Check if kernel version is above 3.10
if versionlt $kernel_version $minimum_kernel_version; then
	echo "Kernel version is below 3.10"
	exit
fi

# Check that HTTPS transport is available to APT
if [ ! -e /usr/lib/apt/methods/https ]; then
	sudo apt-get update
	sudo apt-get install -y apt-transport-https
fi

# Add docker GPG key
sudo apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Add deb for 16.04
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update

# Check docker-engine is pulling from dockerproject.org
if ! `echo $(apt-cache policy docker-engine) | grep "apt.dockerproject.org" 1>/dev/null 2>&1`
then
	echo "Docker project not correctly added to apt"
	exit
fi

# Install extra packages
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual

# Install Docker
sudo apt-get install -y docker-engine

# Start Docker
sudo service docker start

# Add current user to docker group
sudo usermod -a -G docker $USER

# Note
echo "Install docker-compose by going to https://docs.docker.com/compose/install/"
