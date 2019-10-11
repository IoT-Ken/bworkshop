#!/bin/bash
#  _______   ______     ______  __  ___  _______ .______         .___  ___.   ______   .__   __.  __  .___________.  ______   .______
# |       \ /  __  \   /      ||  |/  / |   ____||   _  \        |   \/   |  /  __  \  |  \ |  | |  | |           | /  __  \  |   _  \
# |  .--.  |  |  |  | |  ,----'|  '  /  |  |__   |  |_)  |       |  \  /  | |  |  |  | |   \|  | |  | `---|  |----`|  |  |  | |  |_)  |
# |  |  |  |  |  |  | |  |     |    <   |   __|  |      /        |  |\/|  | |  |  |  | |  . `  | |  |     |  |     |  |  |  | |      /
# |  '--'  |  `--'  | |  `----.|  .  \  |  |____ |  |\  \----.   |  |  |  | |  `--'  | |  |\   | |  |     |  |     |  `--'  | |  |\  \----.
# |_______/ \______/   \______||__|\__\ |_______|| _| `._____|   |__|  |__|  \______/  |__| \__| |__|     |__|      \______/  | _| `._____|

# Author: Ken Osborn
# Version: 1.1
# Last Update: 06-Jun-19

################################################################################
## Set Variables
################################################################################
AGENTBINPATH="/opt/vmware/iotc-agent/bin/"
AGENTDATAPATH="/opt/vmware/iotc-agent/data/data/"
DEVICEID=$(${AGENTBINPATH}DefaultClient get-devices | head -n1 | awk '{print $1}')
TEMPLATE=T-DockerContainer

#Start While Loop
while true; do

################################################################################
## Check to see if running Containers are registered in Pulse, if not, Register
################################################################################
for i in $(docker ps -a --format "{{.Names}}"); do
        if ls $AGENTDATAPATH | grep "$i"; then
            echo "Container" ${i} "is registered"
        else
            echo "Container is not registered"
            (sudo ${AGENTBINPATH}DefaultClient enroll-device --template=$TEMPLATE --name=T-DockerContainer-${i} --parent-id=$DEVICEID) | grep "Device Id:" | head -1 > ${AGENTDATAPATH}${i}.container
            RESULT=$?
                if [ $RESULT -eq 0 ]; then
                    echo "Container " ${i} " registered successfully" 
                else
                    echo "Unable to register Container " ${i}  
                    exit 1
                fi
        fi
done

################################################################################
## Check to see if Docker Containers are no longer active, if not, Un-Register
################################################################################
for a in $(ls $AGENTDATAPATH | grep .container | awk -F '.' '{print $1}'); do
        if docker ps -a --format "{{.Names}}" | grep "$a"; then
            echo "Container" ${a} "is present - do not unregister"
        else
            echo "Container is not present - unregister"
            sudo ${AGENTBINPATH}DefaultClient unenroll --device-id=$(cat ${AGENTDATAPATH}${a}.container | grep "Device Id:" | awk -F ': ' '{print $2}')
            RESULT=$?
                if [ $RESULT -eq 0 ]; then
                    echo "Container " ${a} " un-registered successfully" 
                    rm ${AGENTDATAPATH}${a}.container
                else
                    echo "Unable to un-register Container " ${a}  
                    exit 1
                fi
            # Capture and Send total Docker Containers (Gateway) System Property 
            dcount=$(docker ps -aq | wc -l)
            sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$DEVICEID --key=docker-containers --value=$dcount
        fi
done

################################################################################
## Capture and Send Container System Properties and Metrics
################################################################################
for i in $(docker ps -a --format "{{.Names}}"); do
        if ls $AGENTDATAPATH | grep "$i"; then
            # Declare containerid variable using Pulse Id stored in [container.docker]
            containerid=$(cat ${AGENTDATAPATH}$i.container | awk -F ': ' '{print $2}')
            # Capture and Send Container PID System Property
            pid=$(docker inspect --format='{{.State.Pid}}' $i)
            sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$containerid --key=container-pid --value=$pid
            # Capture and Send Container Status System Property
            status=$(docker inspect --format='{{.State.Status}}' $i)
            sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$containerid --key=container-status --value=$status
            # Capture and Send Container Name System Property
            cname=$(docker inspect --format='{{.Name}}' $i | sed 's|/||g')
            sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$containerid --key=container-name --value=$cname
            # Capture and Send Image Name System Property
            iname=$(docker inspect --format='{{.Config.Image}}' $i) 
            sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$containerid --key=image-name --value=$iname
            # Capture and Send ImageId System Property
            imageid=$(docker inspect --format='{{.Config.Hostname}}' $i) 
            sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$containerid --key=image-id --value=$imageid
            # Capture and Send IPAddress System Property
            ipaddress=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $i)
            sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$containerid --key=ip-address --value=$ipaddress
            # Capture and Send CPU Utilization Metric
            cpu=$(docker stats --no-stream --format "{\"{{ .CPUPerc }}\"}" $i | sed 's/{"//g' | sed 's/%"}//g')
            sudo ${AGENTBINPATH}iotc-agent-cli send-metric --device-id=$containerid --name=CPU-Utilization --type=double --value=$cpu
            # Capture and Send ContainerRunstate Metric
            runstate=$(docker inspect --format='{{.State.Running}}' $i) 
            sudo ${AGENTBINPATH}iotc-agent-cli send-metric --device-id=$containerid --name=Container-Runstate --type=boolean --value=$runstate
            # Capture and Send total Docker Containers (Gateway) System Property 
            dcount=$(docker ps -aq | wc -l)
            sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$DEVICEID --key=docker-containers --value=$dcount
        else
            echo "Container is not registered"
        fi

################################################################################
## Check to see if Docker is installed, update docker-installed System Property
################################################################################
which docker

if [ $? -eq 0 ]; then
    #echo "Docker is already installed, no need to install Docker" >> /tmp/campaign.log
    sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$DEVICEID --key=docker-installed --value="Yes"
else
    #echo "Docker is not installed" >> /tmp/campaign.log
    sudo ${AGENTBINPATH}iotc-agent-cli send-properties --device-id=$DEVICEID --key=docker-installed --value="No"
    exit 1
fi

done

# Configure Collection Interval
sleep 15
done
