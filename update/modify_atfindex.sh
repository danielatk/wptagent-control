#!/bin/bash

mac=$(cat /home/pi/wptagent-automation/mac)
sed -i "s/00:00:00:00:00:00/$mac/" /home/pi/wptagent-automation/extensions/ATF-chrome-plugin/atfindex.js