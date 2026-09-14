#!/bin/bash

set -e

MEMORY=$(free |grep "Mem" | awk '{ print 100*$7/$2 }')
DISK=$(df --total |grep "total"|awk '{print $5}')
echo $DISK
echo $MEMORY
if systemctl is-active --quiet nginx ;then
        echo "nginx running"
else
        echo "nginx not active"
fi

if curl -fs http://localhost:3000/login > /dev/null; then
        echo "Frontend: OK"
else
        echo "Frontend: FAILED"
fi


if curl -fs http://localhost:3001/api/health > /dev/null; then
        echo "Backend: OK"
else
        echo "Backend: FAILED"
fi