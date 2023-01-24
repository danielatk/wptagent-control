#!/bin/sh

echo "Cloning into wptagent-control repository"

git clone https://github.com/danielatk/wptagent-control ~/wptagent-control

echo "Repository cloned. Before running automation_setup.sh please fill the wptagents file with one WPTagent per line. The file name is ~/wptagent-control/wptagents"