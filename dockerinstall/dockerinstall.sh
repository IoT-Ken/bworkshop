#!/bin/sh
#  _______   ______     ______  __  ___  _______ .______          __  .__   __.      _______.___________.    ___       __       __
# |       \ /  __  \   /      ||  |/  / |   ____||   _  \        |  | |  \ |  |     /       |           |   /   \     |  |     |  |
# |  .--.  |  |  |  | |  ,----'|  '  /  |  |__   |  |_)  |       |  | |   \|  |    |   (----`---|  |----`  /  ^  \    |  |     |  |
# |  |  |  |  |  |  | |  |     |    <   |   __|  |      /        |  | |  . `  |     \   \       |  |      /  /_\  \   |  |     |  |
# |  '--'  |  `--'  | |  `----.|  .  \  |  |____ |  |\  \----.   |  | |  |\   | .----)   |      |  |     /  _____  \  |  `----.|  `----.
# |_______/ \______/   \______||__|\__\ |_______|| _| `._____|   |__| |__| \__| |_______/       |__|    /__/     \__\ |_______||_______|

# Author: Ken Osborn
# Version: 1.0
# Last Update: 18-Jul-19
# Purpose: Install Docker if not already installed
# Tested On: Ubuntu 18.04.2 LTS

# Set current Package dir variable and change into
dirname=$(echo `echo $(dirname "$0")`)
cd $dirname

echo "This is the script: execute phase" >> /tmp/campaign.log

################################################################################
## Install Docker if it is not present
################################################################################
which docker

if [ $? -eq 0 ]; then
    echo "Docker is already installed, no need to install Docker" >> /tmp/campaign.log
else
    echo "Docker is not installed, installing Docker" >> /tmp/campaign.log 
    yes | sudo apt-get update
    yes | sudo apt install docker.io
    RESULT=$?
        if [ $RESULT -eq 0 ]; then
            echo "Docker service started successfully" >> /tmp/campaign.log
        else
            echo "Docker service start failed" >> /tmp/campaign.log
        fi
    sudo systemctl start docker
    sudo systemctl enable docker
fi
