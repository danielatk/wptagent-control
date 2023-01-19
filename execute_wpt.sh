#!/bin/bash

setupNavigationFilePath="/home/localuser/wpt_control/setup_navigation.py"
setupReproductionFilePath="/home/localuser/wpt_control/setup_reproduction.py"
navigationFilePath="/home/localuser/wpt_control/navigation_wpt.py"
logFile="/home/localuser/wpt_control/log_wpt"
ongoingFile="/home/localuser/wpt_control/ongoing"

# before beginning sleep a random ammount of time
# (from 0 to 30 seconds in milliseconds granularity)
# this is to avoid beginning at the same time as experiments in the RPi

source "/home/localuser/wpt_control/wpt_control_env/bin/activate"

randomMs=$[ $RANDOM % 30000 + 1 ]
ms_unit=0.001
sleep_time=$(echo "scale=3; $randomMs*$ms_unit" | bc)
sleep $sleep_time

echo "$(date +%s) | execute WPT -> setup time" >> $logFile
coin=$[ RANDOM % 2 ]
args=""
if [[ $coin -eq 1 ]]; then
    args="$(python3 $setupNavigationFilePath)"
else
    args="$(python3 $setupReproductionFilePath)"
fi

echo "$args" > /home/localuser/wpt_control/tmp
raspberryPi=$(sed 's/.* //' /home/localuser/wpt_control/tmp)
echo "$(date +%s) | execute WPT -> args: $args" >> $logFile
if [[ -f /home/localuser/wpt_control/status/${raspberryPi}_ongoing_client ]]; then
    ongoing="$(cat /home/localuser/wpt_control/status/${raspberryPi}_ongoing_client)"
    # if there is an ongoing experiment do not continue
    [ "$ongoing" = "1" ] && echo "$(date +%s) | execute WPT -> already ongoing experiment on $raspberryPi" >> $logFile && echo "--------------------" >> $logFile && rm /home/localuser/wpt_control/tmp && exit
fi

if [ -f $ongoingFile ]; then
        ongoing=$(cat $ongoingFile)
else
        ongoing="0"
fi
[ "$ongoing" = "1" ] && echo "$(date +%s) | execute WPT -> already ongoing WPT experiment" >> $logFile && echo "-------------------" >> $logFile && rm /home/localuser/wpt_control/tmp && exit

echo "1" > $ongoingFile

#removing everything before and including first space
argsToFile=$(sed 's/[^ ]* //' /home/localuser/wpt_control/tmp)
echo "$argsToFile" > /home/localuser/wpt_control/tmp
#removing everything after and including last space
argsToFile=$(sed 's/2 .*/2/' /home/localuser/wpt_control/tmp)
echo "$argsToFile" > /home/localuser/wpt_control/tmp
argsToFile=$(sed 's/1 .*/1/' /home/localuser/wpt_control/tmp)
rm /home/localuser/wpt_control/tmp
echo "wpt $argsToFile" > /home/localuser/wpt_control/status/$raspberryPi
echo "1" > /home/localuser/wpt_control/status/${raspberryPi}_ongoing

echo "$(date +%s) | execute WPT -> navigation time ($args)" >> $logFile
python3 $navigationFilePath $args 2>> $logFile

echo "--------------------" >> $logFile

echo "0" > /home/localuser/wpt_control/status/${raspberryPi}_ongoing
echo "0" > $ongoingFile
