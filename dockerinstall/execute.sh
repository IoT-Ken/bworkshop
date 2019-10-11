#!/bin/sh
#############################################################################
# Filename: execute.sh
# Date Created: 09/28/19
# Author: Ken Osborn
#
# Version 1.0
#
# Description: Used via Campaign to install Docker if not already present
#
#
# 1.0 - Ken Osborn: First version of the script.
#############################################################################

# Set current Package dir variable and change into
dirname=$(echo `echo $(dirname "$0")`)
cd $dirname

echo "This is the script: execute" >> /tmp/campaign.log

## Call Docker Install Script 
chmod +x dockerinstall.sh
./dockerinstall.sh &
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "execute.sh executed successfully" >> /tmp/campaign.log
    sleep 2
else
    echo "execute.sh failed to start" >> /tmp/campaign.log
    exit 1
fi