#!/bin/bash
#     ___      ________   __    __  .______       _______     _______  _______   _______  _______
#    /   \    |       /  |  |  |  | |   _  \     |   ____|   |   ____||       \ /  _____||   ____|
#   /  ^  \   `---/  /   |  |  |  | |  |_)  |    |  |__      |  |__   |  .--.  |  |  __  |  |__
#  /  /_\  \     /  /    |  |  |  | |      /     |   __|     |   __|  |  |  |  |  | |_ | |   __|
# /  _____  \   /  /----.|  `--'  | |  |\  \----.|  |____    |  |____ |  '--'  |  |__| | |  |____
#/__/     \__\ /________| \______/  | _| `._____||_______|   |_______||_______/ \______| |_______|
#
# Author: Ken Osborn
# AzureEdgeInstall_Ubuntu
# Version: 1.0
# Last Update: 18-May-19

# Set Variables
HUB=PulseAzure-BetterTogetherDemo
DEVICEID=$(hostname)
echo $HUB >> /tmp/campaign.log
echo $DEVICEID >> /tmp/campaign.log

# Check if Azure iotedge is present and install if not
which iotedge

if [ $? -eq 0 ]; then
    echo "IoT Edge is already installed, no need to install." >> /tmp/campaign.log
    sleep 2
else
    # Install Azure IoT Edge Framework
    # Install Ubuntu Repository Configuration
    sudo curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > ./microsoft-prod.list
    # Copy the generate list
    sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/
    # Install Microsoft GPG public key
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/
    # Perform app update
    sudo apt-get update
    # Install the Moby engine
    sudo apt-get -y install moby-engine
    # Install Moby cli 
    sudo apt-get -y install moby-cli
    # Perform app update
    sudo apt-get update
    # Install Security Daemon
    sudo apt-get -y install iotedge
    # Install Azure CLI
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    # Install Azure CLI IoT Extension
    az extension add --name azure-cli-iot-ext
    # Sign in to Azure IoT Hub using Service Principal (this can be changed to Certificate vs Password)
    az login --service-principal -u [uid] -p [password] --tenant [tenant id]
    echo "Just logged in via az" >> /tmp/campaign.log
    # Create new Device using Hostname as Device ID (Name)
    az iot hub device-identity create --device-id $DEVICEID --hub-name $HUB --edge-enabled
    echo "Just created device in iot hub" >> /tmp/campaign.log
    # Set Device Connection String equal to $cstring
    CSTRING=$(az iot hub device-identity show-connection-string --device-id $DEVICEID --hub-name $HUB | awk -F ':' '{print $2'} | awk -F '"' '{print $2}')
    echo $CSTRING >> /tmp/campaign.log
    # Remove Newline from CSTRING variable
    NEWCSTRING=${CSTRING//$'\n'/}
    # Update config.yaml file with Connection String Variable
    sudo sed -i "s|<ADD DEVICE CONNECTION STRING HERE>|$NEWCSTRING|g" /tmp/config.yaml
    echo "Just replaced string in config.yaml" >> /tmp/campaign.log
    sudo cp /tmp/config.yaml /etc/iotedge/config.yaml
    # Restart IoT Edge
    sudo systemctl restart iotedge
    echo "Just restarted iotedge" >> /tmp/campaign.log
    # Deploy Sample Module - Note that this virtual temp sensor will send messages / drive up your count
    az iot edge set-modules --device-id $HOSTNAME --hub-name $HUB --content sample_deployment.json
    echo "Just deployed module" >> /tmp/campaign.log
fi


#Delete this when finished
cd /tmp
curl -o iotc-agent.tar.gz https://iotc011-pulse.vmware.com/api/iotc-agent/iotc-agent-x86_64-2.0.0.631.tar.gz
tar -xvf iotc-agent.tar.gz
cd iotc-agent
./install.sh
reboot

#Phase 2 
cd /opt/vmware/iotc-agent/bin
./DefaultClient enroll --auth-type=BASIC --template=G-UbuntuVM-KO --name=$HOSTNAME --username=kosborn@vmware.com
