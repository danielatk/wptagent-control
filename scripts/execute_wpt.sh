#!/bin/bash

setupNavigationFilePath="~/wptagent-control/scripts/setup_navigation.py"
setupReproductionFilePath="~/wptagent-control/scripts/setup_reproduction.py"
navigationFilePath="~/wptagent-control/scripts/navigation_wpt.py"
logFile="~/wptagent-control/log_wpt"
ongoingFile="~/wptagent-control/ongoing"

# before beginning sleep a random ammount of time
# (from 0 to 30 seconds in milliseconds granularity)
# this is to avoid beginning at the same time as experiments in the RPi

source "~/wptagent-control/env/bin/activate"

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

[ -z "$args" ] && echo "$(date +%s) | execute WPT -> setup script output was empty, aborting execution" >> $logFile && echo "--------------------" >> $logFile && exit

echo "$args" > ~/wptagent-control/tmp
wptagent=$(sed 's/.* //' ~/wptagent-control/tmp)
rm ~/wptagent-control/tmp
echo "$(date +%s) | execute WPT -> args: $args" >> $logFile
if [[ -f ~/wptagent-control/status/${wptagent}_ongoing_client ]]; then
    ongoing="$(cat ~/wptagent-control/status/${wptagent}_ongoing_client)"
    # if there is an ongoing experiment do not continue
    [ "$ongoing" = "1" ] && echo "$(date +%s) | execute WPT -> already ongoing experiment on $wptagent" >> $logFile && echo "--------------------" >> $logFile && exit
fi

if [ -f $ongoingFile ]; then
        ongoing=$(cat $ongoingFile)
else
        ongoing="0"
fi
[ "$ongoing" = "1" ] && echo "$(date +%s) | execute WPT -> already ongoing WPT experiment" >> $logFile && echo "-------------------" >> $logFile && exit

echo "1" > $ongoingFile

#removing everything after and including last space
argsToFile=$(echo $args | cut -d' ' -f1-3)
echo "wpt $argsToFile" > ~/wptagent-control/status/$wptagent
echo "1" > ~/wptagent-control/status/${wptagent}_ongoing

echo "$(date +%s) | execute WPT -> navigation time ($args)" >> $logFile
python3 $navigationFilePath $args 2>> $logFile

echo "--------------------" >> $logFile

echo "0" > ~/wptagent-control/status/${wptagent}_ongoing
echo "0" > $ongoingFile
