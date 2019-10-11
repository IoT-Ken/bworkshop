#!/bin/bash
# _______ .__   __. ____    ____    .___  ___.   ______   .__   __.  __  .___________.  ______   .______      
#|   ____||  \ |  | \   \  /   /    |   \/   |  /  __  \  |  \ |  | |  | |           | /  __  \  |   _  \     
#|  |__   |   \|  |  \   \/   /     |  \  /  | |  |  |  | |   \|  | |  | `---|  |----`|  |  |  | |  |_)  |    
#|   __|  |  . `  |   \      /      |  |\/|  | |  |  |  | |  . `  | |  |     |  |     |  |  |  | |      /     
#|  |____ |  |\   |    \    /       |  |  |  | |  `--'  | |  |\   | |  |     |  |     |  `--'  | |  |\  \----.
#|_______||__| \__|     \__/        |__|  |__|  \______/  |__| \__| |__|     |__|      \______/  | _| `._____|
                                                                                                             
# Author: Ken Osborn
# Version: 1.0
# Last Update: 03-Jul-19
# Last Update Notes: 

################################################################################
## Set Variables, Gather Environmental Metrics and Send Metrics to Pulse
################################################################################
AGENTBINPATH="/opt/vmware/iotc-agent/bin/"
AGENTDATAPATH="/opt/vmware/iotc-agent/data/data/"
TEMPLATE=G-Dell3K3-KO

while true; do
# Set Gateway and Temperature Device Variables 
GATEWAYID=$(${AGENTBINPATH}DefaultClient get-devices | head -n1 | awk '{print $1}')
INTSENSORS=$(${AGENTBINPATH}DefaultClient get-devices --parent-id=$GATEWAYID | head -n1 | awk '{print $1}')

# Set Variables for Built-in Temp/Humidity Sensors
INTTEMP=$(/opt/envmonitor/dg-query t)
INTHUMIDITY=$(/opt/envmonitor/dg-query h)
INTPRESSURE=$(/opt/envmonitor/dg-query p)

# Set uptime variable via bash command in -p 'pretty format' | sed strips out whitespace
# and occurences of ',-' and replaces with '-'
UP=$(uptime -p | sed -e 's/ /-/g' | sed -e 's/,-/,/g')

# Utilize iotc-agent-cli to send metrics
/opt/vmware/iotc-agent/bin/iotc-agent-cli send-metric --device-id=$INTSENSORS --name=Temperature --type=double --value=$INTTEMP
/opt/vmware/iotc-agent/bin/iotc-agent-cli send-metric --device-id=$INTSENSORS --name=Humidity --type=double --value=$INTHUMIDITY
/opt/vmware/iotc-agent/bin/iotc-agent-cli send-metric --device-id=$INTSENSORS --name='Barometric Pressure' --type=double --value=$INTPRESSURE

# Utilize iotc-agent-cli to send Utime System Property
/opt/vmware/iotc-agent/bin/iotc-agent-cli send-properties --device-id=$GATEWAYID --key=uptime --value=$UP

# Configure While Loop Interval
sleep 15
done