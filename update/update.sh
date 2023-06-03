#!/bin/bash

setupReproductionFile="/home/pi/wptagent-automation/scripts/setup_reproduction.py"
executeFile="/home/pi/wptagent-automation/scripts/execute.sh"
navigationWebdriverFile="/home/pi/wptagent-automation/scripts/webdriver/navigation_webdriver.py"
reproductionWebdriverFile="/home/pi/wptagent-automation/scripts/webdriver/reproduction_webdriver.py"
ndtFile="/home/pi/wptagent-automation/scripts/ndt/measure_ndt.sh"
videosFile="/home/pi/wptagent-automation/videos"
versionFile="/home/pi/wptagent-automation/version"
newVersionFile="/home/pi/wptagent-automation/new_version"
checkOngoingFile="/home/pi/wptagent-automation/scripts/check_ongoing.sh"

collectionServerUrl=$(cat /home/pi/wptagent-automation/collection_server_url)
collectionServerUser=$(cat /home/pi/wptagent-automation/collection_server_user)
collectionServerSshPort=$(cat /home/pi/wptagent-automation/collection_server_ssh_port)

version="$(cat $versionFile)"
new_version="$(cat $newVersionFile)"

# updating from 1.0.0 to 1.1.0
if [ "$version" = "1.0.0" ] && [ "$new_version" = "1.1.0" ]; then

    mkdir /home/pi/wptagent-automation/sfn_data

    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/setup_reproduction.py $setupReproductionFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/navigation_webdriver.py $navigationWebdriverFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/reproduction_webdriver.py $reproductionWebdriverFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/execute.sh $executeFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/measure_ndt.sh $ndtFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/videos $videosFile >/dev/null 2>&1
fi

if [ "$new_version" = "1.1.2" ]; then
    crontab -l > mycron
    echo "@reboot rm /home/pi/wptagent-automation/wpt_ongoing" >> mycron
    crontab mycron
    rm mycron
fi

if [ "$new_version" = "1.1.3" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_ongoing.sh $setupReproductionFile >/dev/null 2>&1

    crontab -l > mycron
    echo "@reboot /home/pi/wptagent-automation/scripts/check_ongoing.sh /home/pi/wptagent-automation/ongoing" >> mycron
    echo "@reboot /home/pi/wptagent-automation/scripts/check_ongoing.sh /home/pi/wptagent-automation/wpt_ongoing" >> mycron
    crontab mycron
    rm mycron

    if [ "$version" != "1.1.2" ]; then
        # if it's not a direct update must do the 1.1.2 update too
        crontab -l > mycron
        echo "@reboot rm /home/pi/wptagent-automation/wpt_ongoing" >> mycron
        crontab mycron
        rm mycron
    fi
fi