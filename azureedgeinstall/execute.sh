#! /bin/sh
#############################################################################
# Filename: execute.sh
# Date Created: 05/12/19
# Date Modified: 05/12/19
# Author: Ken Osborn
#
# Version 1.0
#
# Description: Installs AzureIoTEdge Platform on Gateways in IA (.548) Env
#              (https://iotc011-pulse.vmware.com/)
# Usage: Bundled as part of package file via package-cli utility
#
# 1.0 - Ken Osborn: First version of the script.
#############################################################################
# Set current dir variable and change into
dirname=$(echo `echo $(dirname "$0")`)
cd $dirname

#Set PATH to binaries otherwise anything that relies on them will fail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "This is the script: execute" >> /tmp/campaign.log

## Enroll SenseHat as Connected Thing
chmod +x azure-edge-install_ubuntu.sh
./azure-edge-install_ubuntu.sh &

RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "azure-edge-install_ubuntu.sh executed successfully" >> /tmp/campaign.log
    sleep 2
else
    echo "azure-edge-install_ubuntu.sh failed to start" >> /tmp/campaign.log
    exit 1
fi
