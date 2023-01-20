#!/bin/sh

echo "Cloning into wptagent-control repository"

git clone https://github.com/danielatk/wptagent-control ~/wptagent-control

set -eu
: ${WPT_SERVER:=''}

while [[ $WPT_SERVER == '' ]]; do
    read -p "WebPageTest server (i.e. www.webpagetest.org): " WPT_SERVER
done

echo $WPT_SERVER > ~/wptagent-control/wptserver_url

sudo apt -y install python python3 python3-pip
pip install chromedriver
virtualenv ~/wptagent-control/env -p python3

echo "Setup is complete. Do not forget to fill in wptagents file with all the agents' IDs."