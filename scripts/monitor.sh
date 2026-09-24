#!/bin/bash

URL="http://localhost:5000/api/health"

echo "========================================"
echo "   Self-Healing Monitor Started"
echo "========================================"
echo "Checking every 10 seconds..."
echo ""

while true
do

    if curl -f "$URL" > /dev/null 2>&1
    then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] HEALTHY"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILURE DETECTED"

        ./scripts/recover.sh
    fi

    sleep 10

done