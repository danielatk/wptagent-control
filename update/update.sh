#!/bin/bash

setupReproductionFile="/home/pi/wptagent-automation/scripts/setup_reproduction.py"
setupNavigationFile="/home/pi/wptagent-automation/scripts/setup_navigation.py"
setupWebpagetestFilesFile="/home/pi/wptagent-automation/scripts/setup_webpagetest_files.py"
navigationWebdriverFile="/home/pi/wptagent-automation/scripts/webdriver/navigation_webdriver.py"
reproductionWebdriverFile="/home/pi/wptagent-automation/scripts/webdriver/reproduction_webdriver.py"
reproductionPuppeteerFile="/home/pi/wptagent-automation/scripts/puppeteer/puppeteer_navigation/reproduction_puppeteer.js"
navigationPuppeteerFile="/home/pi/wptagent-automation/scripts/puppeteer/puppeteer_navigation/navigation_puppeteer.js"
executeFile="/home/pi/wptagent-automation/scripts/execute.sh"
ndtFile="/home/pi/wptagent-automation/scripts/ndt/measure_ndt.sh"
videosFile="/home/pi/wptagent-automation/videos"
versionFile="/home/pi/wptagent-automation/version"
newVersionFile="/home/pi/wptagent-automation/new_version"
checkOngoingFile="/home/pi/wptagent-automation/scripts/check_ongoing.sh"
checkUpdateFile="/home/pi/wptagent-automation/scripts/check_update.sh"
adblockFile="/home/pi/wptagent-automation/extensions/adblock.crx"
statusControlFile="/home/pi/wptagent-automation/scripts/status/status_control.sh"
statusControlLoopFile="/home/pi/wptagent-automation/scripts/status/status_control_loop.sh"
updateStatusFile="/home/pi/wptagent-automation/scripts/status/update_status.py"
togglePuppeteerFile="/home/pi/wptagent-automation/scripts/toggle_puppeteer.py"
top100File="/home/pi/wptagent-automation/top_100_brasil.csv"
navigationListFile="/home/pi/wptagent-automation/navigation_list.csv"
ndtListFile="/home/pi/wptagent-automation/lista_ufs"
automationSetupFile="/home/pi/wptagent-automation/scripts/automation_setup.sh"
backgroundScriptFile="/home/pi/wptagent-automation/extensions/ATF-chrome-plugin/background.js"
indexScriptFile="/home/pi/wptagent-automation/extensions/ATF-chrome-plugin/atfindex.js"
modifyBackgroundFile="/home/pi/wptagent-automation/scripts/modify_extension.py"
modifyIndexFile="/home/pi/wptagent-automation/scripts/modify_atfindex.sh"

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
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_ongoing.sh $checkOngoingFile >/dev/null 2>&1

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

if [ "$new_version" = "1.3.0" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_ongoing.sh $checkOngoingFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/setup_reproduction.py $setupReproductionFile >/dev/null 2>&1

    # remove the previous lines containing check_ongoing.sh and status_control_loop.sh
    crontab -l | sed '/check_ongoing.sh/d' | crontab -
    crontab -l | sed '/status_control_loop.sh/d' | crontab -

    crontab -l > mycron
    echo "@reboot bash /home/pi/wptagent-automation/scripts/check_ongoing.sh /home/pi/wptagent-automation/ongoing" >> mycron
    echo "@reboot bash /home/pi/wptagent-automation/scripts/check_ongoing.sh /home/pi/wptagent-automation/wpt_ongoing" >> mycron
    echo "@reboot bash /home/pi/wptagent-automation/scripts/status/status_control_loop.sh" >> mycron
    crontab mycron
    rm mycron
fi

if [ "$new_version" = "1.3.1" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_ongoing.sh $checkOngoingFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_update.sh $checkUpdateFile >/dev/null 2>&1
fi

if [ "$new_version" = "1.3.2" ]; then
    if [ "$version" != "1.3.1" ]; then
        # if it's not a direct update must do the 1.3.1 update too
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_ongoing.sh $checkOngoingFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_update.sh $checkUpdateFile >/dev/null 2>&1
    fi
fi

if [ "$new_version" = "1.3.3" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/execute.sh $executeFile >/dev/null 2>&1
    if [ "$version" != "1.3.1" ] && [ "$version" != "1.3.2" ]; then
        # if it's not a direct update must do the 1.3.1 update too
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_ongoing.sh $checkOngoingFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_update.sh $checkUpdateFile >/dev/null 2>&1
    fi
fi

if [ "$new_version" = "1.4.0" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/reproduction_webdriver.py $reproductionWebdriverFile >/dev/null 2>&1
    if [ "$version" != "1.3.1" ] || [ "$version" != "1.3.2" ] || [ "$version" != "1.3.3" ]; then
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/execute.sh $executeFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_ongoing.sh $checkOngoingFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_update.sh $checkUpdateFile >/dev/null 2>&1
    fi
fi

if [ "$new_version" = "1.5.0" ]; then
    if [ -f $adblockFile ]; then
        rm $adblockFile
    fi
    if [ -f $reproductionPuppeteerFile ]; then
        rm $reproductionPuppeteerFile
    fi
    if [ -f $statusControlFile ]; then
        rm $statusControlFile
    fi
    if [ -f $updateStatusFile ]; then
        rm $updateStatusFile
    fi
    if [ -f $togglePuppeteerFile ]; then
        rm $togglePuppeteerFile
    fi
    if [ -f $navigationWebdriverFile ]; then
        rm $navigationWebdriverFile
    fi
    if [ -f $top100File ]; then
        rm $top100File
    fi

    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/navigation_list.csv $navigationListFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/automation_setup.sh $automationSetupFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_update.sh $checkUpdateFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/execute.sh $executeFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/setup_navigation.py $setupNavigationFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/setup_reproduction.py $setupReproductionFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/setup_webpagetest_files.py $setupWebpagetestFilesFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/status_control_loop.sh $statusControlLoopFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/navigation_puppeteer.js $navigationPuppeteerFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/reproduction_webdriver.py $reproductionWebdriverFile >/dev/null 2>&1

fi

if [ "$new_version" = "1.5.1" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/background.js $backgroundScriptFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/navigation_puppeteer.js $navigationPuppeteerFile >/dev/null 2>&1

    if [ "$version" != "1.5.0" ]; then
        if [ -f $adblockFile ]; then
            rm $adblockFile
        fi
        if [ -f $reproductionPuppeteerFile ]; then
            rm $reproductionPuppeteerFile
        fi
        if [ -f $statusControlFile ]; then
            rm $statusControlFile
        fi
        if [ -f $updateStatusFile ]; then
            rm $updateStatusFile
        fi
        if [ -f $togglePuppeteerFile ]; then
            rm $togglePuppeteerFile
        fi
        if [ -f $navigationWebdriverFile ]; then
            rm $navigationWebdriverFile
        fi
        if [ -f $top100File ]; then
            rm $top100File
        fi

        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/navigation_list.csv $navigationListFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/automation_setup.sh $automationSetupFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_update.sh $checkUpdateFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/execute.sh $executeFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/setup_navigation.py $setupNavigationFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/setup_reproduction.py $setupReproductionFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/setup_webpagetest_files.py $setupWebpagetestFilesFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/status_control_loop.sh $statusControlLoopFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/navigation_puppeteer.js $navigationPuppeteerFile >/dev/null 2>&1
        scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/reproduction_webdriver.py $reproductionWebdriverFile >/dev/null 2>&1
    fi

fi

if [ "$new_version" = "1.6.0" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/background.js $backgroundScriptFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/navigation_puppeteer.js $navigationPuppeteerFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/navigation_list.csv $navigationListFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/modify_extension.py $modifyBackgroundFile >/dev/null 2>&1

    python3 $modifyBackgroundFile
    rm $modifyBackgroundFile
fi

if [ "$new_version" = "1.8.0" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/atfindex.js $indexScriptFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/navigation_puppeteer.js $navigationPuppeteerFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/lista_ufs $ndtListFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_update.sh $checkUpdateFile >/dev/null 2>&1
fi

if [ "$new_version" = "1.9.0" ] || [ "$new_version" = "1.10.0" ] || [ "$new_version" = "1.11.0" ]; then
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/atfindex.js $indexScriptFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/navigation_puppeteer.js $navigationPuppeteerFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/lista_ufs $ndtListFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/check_update.sh $checkUpdateFile >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -P $collectionServerSshPort $collectionServerUser@$collectionServerUrl:~/wptagent-control/update/modify_atfindex.sh $modifyIndexFile >/dev/null 2>&1

    bash $modifyIndexFile
    rm $modifyIndexFile
fi
