#!/bin/bash

directory=~/wptagent-control/status

cd "$directory" || exit

find . -name "*_ongoing*" -type f -delete