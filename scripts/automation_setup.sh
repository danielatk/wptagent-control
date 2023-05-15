#!/bin/sh

set -eu
: ${WPT_SERVER:=''}
: ${NODE_PORT:=''}
: ${EXPERIMENTS_INTERVAL:=''}

while [[ $WPT_SERVER == '' ]]; do
    read -p "WebPageTest server (i.e. www.webpagetest.org): " WPT_SERVER
done
while [[ $NODE_PORT == '' ]]; do
    read -p "Port the node server will be receiving files from: " NODE_PORT
done
while [[ $EXPERIMENTS_INTERVAL == '' ]]; do
    read -p "Interval between WPT jobs to agents (minimum recommended: 3 minutes): " EXPERIMENTS_INTERVAL
done

echo "Setting up directory structure"

mkdir ~/wptagent-control/wpt_data
mkdir ~/wptagent-control/ndt_data
mkdir ~/wptagent-control/other_data
mkdir ~/wptagent-control/update
mkdir ~/wptagent-control/status
mkdir ~/wptagent-control/logs
mkdir ~/wptagent-control/pids
mkdir ~/wptagent-control/tcpdump

echo "Substituting environment variables where appropriate"

echo $WPT_SERVER > ~/wptagent-control/wptserver_url
sed -i 's/65535/$NODE_PORT/' ~/wptagent-control/upload_server/pserver.py

echo "Installing dependencies and setting up environment"

sudo apt -y install python python3 python3-pip python3-virtualenv
python3 -m pip install chromedriver
python3 -m pip install selenium
python3 -m pip install pandas
python3 -m pip install requests
virtualenv ~/wptagent-control/env -p python3
sudo npm install pm2 -g
echo '{
  "apps": [{
    "name": "collection server",
    "script": "app.js",
    "log_date_format": "YYYY-MM-DD HH:mm:ss Z",
    "autorestart": true,
    "env": {
      "production": true,
      "TZ": "America/Sao_Paulo",
      "PORT": '$NODE_PORT'
    },
    "exec_mode": "cluster"
  }]
}' > ~/wptagent-control/upload_server/environment.config.json

echo "Initializing node server and WPTagent scheduling"

pm2 start ~/wptagent-control/upload_server/environment.config.json

# starting WPTagent scheduling
crontab -l > mycron
echo "*/$EXPERIMENTS_INTERVAL * * * * bash ~/wptagent-control/scripts/execute_wpt.sh > ~/wptagent-control/crontab_log 2> ~/wptagent-control/crontab_error" >> mycron
crontab mycron
rm mycron

echo "Setup is complete."