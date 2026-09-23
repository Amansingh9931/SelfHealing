#!/bin/bash

URL="http://localhost:5000/api/health"

echo "Checking application health..."

if curl -f "$URL" > /dev/null 2>&1
then
    echo "[$(date)] HEALTHY"
    exit 0
else
    echo "[$(date)] UNHEALTHY"
    exit 1
fi