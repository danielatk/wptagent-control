#!/bin/bash

setupNavigationFilePath="./setup_navigation.py"
setupReproductionFilePath="./setup_reproduction.py"
navigationFilePath="./navigation_wpt.py"
logFile="./log_wpt"
ongoingFile="./ongoing"

# before beginning sleep a random ammount of time
# (from 0 to 30 seconds in milliseconds granularity)
# this is to avoid beginning at the same time as experiments in the RPi

source "./wpt_control_env/bin/activate"

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

echo "$args" > ./tmp
raspberryPi=$(sed 's/.* //' ./tmp)
echo "$(date +%s) | execute WPT -> args: $args" >> $logFile
if [[ -f ./status/${raspberryPi}_ongoing_client ]]; then
    ongoing="$(cat ./status/${raspberryPi}_ongoing_client)"
    # if there is an ongoing experiment do not continue
    [ "$ongoing" = "1" ] && echo "$(date +%s) | execute WPT -> already ongoing experiment on $raspberryPi" >> $logFile && echo "--------------------" >> $logFile && rm ./tmp && exit
fi

if [ -f $ongoingFile ]; then
        ongoing=$(cat $ongoingFile)
else
        ongoing="0"
fi
[ "$ongoing" = "1" ] && echo "$(date +%s) | execute WPT -> already ongoing WPT experiment" >> $logFile && echo "-------------------" >> $logFile && rm ./tmp && exit

echo "1" > $ongoingFile

#removing everything before and including first space
argsToFile=$(sed 's/[^ ]* //' ./tmp)
echo "$argsToFile" > ./tmp
#removing everything after and including last space
argsToFile=$(sed 's/2 .*/2/' ./tmp)
echo "$argsToFile" > ./tmp
argsToFile=$(sed 's/1 .*/1/' ./tmp)
rm ./tmp
echo "wpt $argsToFile" > ./status/$raspberryPi
echo "1" > ./status/${raspberryPi}_ongoing

echo "$(date +%s) | execute WPT -> navigation time ($args)" >> $logFile
python3 $navigationFilePath $args 2>> $logFile

echo "--------------------" >> $logFile

echo "0" > ./status/${raspberryPi}_ongoing
echo "0" > $ongoingFile
